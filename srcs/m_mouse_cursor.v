`timescale 1ns / 1ps

// ============================================================================
// Module  : m_mouse_cursor
// Project : PS/2 Mouse Controller
// File    : m_mouse_cursor.v
//
// Description:
//   Maintains the mouse cursor position in text-mode screen coordinates
//   (column 0..COLS-1, row 0..ROWS-1) and drives a direct write port on the
//   VGA character buffer to render the cursor on screen.
//
//   On every valid packet from m_mouse_packet the module:
//     1. Erases the cursor at its current position by writing ERASE_CHAR (0x20,
//        ASCII space) to the character buffer at the current address.
//     2. Computes the new position from the accumulated dx/dy movement.
//     3. Draws the cursor at the new position by writing CURSOR_CHAR (0xDB,
//        IBM CP437 solid block) to the character buffer.
//
// Coordinate conventions (PS/2 specification):
//   dx positive  = move right  -> column increases
//   dy positive  = move up     -> row decreases (Y axis is inverted here)
//
// Sub-character accumulation (SCALE parameter):
//   The PS/2 mouse reports movement in raw counts.  At typical 400 DPI
//   sensitivity, small movements produce counts of ±1 or ±2 per packet.
//   Without accumulation every count would move the cursor by one full
//   character cell, making it jittery and over-responsive.
//
//   The accumulators _acc_x and _acc_y collect fractional counts.
//   The cursor moves by one character cell for every SCALE raw counts.
//   The remainder (count % SCALE) is kept in the accumulator across packets.
//
// Character buffer interface (m_vga_mmio):
//   The VGA MMIO module exposes a direct write port:
//     o_buf_addr  [11:0]  – linear address = row * COLS + col
//     o_buf_wdata [7:0]   – character code to write (IBM CP437)
//     o_buf_we            – write enable (1 clock wide)
//   This module drives those signals.  The write port must have higher
//   priority than the UART/CPU write path inside m_vga_mmio.
//
// Write FSM:
//   Each packet requires two sequential character-buffer writes (erase then
//   draw).  A 3-state FSM serialises them:
//     S_IDLE  – wait for i_pkt_valid; compute new position when it arrives
//     S_ERASE – write ERASE_CHAR to the old cursor address
//     S_DRAW  – write CURSOR_CHAR to the new cursor address, update o_col/o_row
//
// Address calculation:
//   addr = row * COLS + col
//   For COLS = 80:  addr = (row << 6) + (row << 4) + col
//   This decomposition avoids a general multiplier.
//
// Parameters:
//   COLS  – Number of text columns (default 80)
//   ROWS  – Number of text rows    (default 30)
//   SCALE – Raw PS/2 counts per character cell (default 3)
//
// Port list:
//   i_clk       System clock, rising-edge sensitive
//   i_rst       Synchronous active-high reset
//   i_dx        9-bit signed X displacement from m_mouse_packet
//   i_dy        9-bit signed Y displacement from m_mouse_packet
//   i_btn_l     Left button state from m_mouse_packet (unused here, available)
//   i_btn_r     Right button state from m_mouse_packet (unused here, available)
//   i_pkt_valid 1-cycle pulse from m_mouse_packet: new decoded packet ready
//   o_buf_addr  12-bit linear address into the VGA character buffer
//   o_buf_wdata 8-bit character code to write
//   o_buf_we    Write-enable pulse (1 clock wide)
//   o_col       Current cursor column (output / debug)
//   o_row       Current cursor row    (output / debug)
// ============================================================================

module m_mouse_cursor #(
    parameter COLS  = 80,    // Number of text columns
    parameter ROWS  = 30,    // Number of text rows
    parameter SCALE = 3      // Raw PS/2 counts required to move one cell
)(
    input  wire        i_clk,
    input  wire        i_rst,

    // Movement and button inputs from m_mouse_packet
    input  wire signed [8:0] i_dx,
    input  wire signed [8:0] i_dy,
    input  wire              i_btn_l,
    input  wire              i_btn_r,
    input  wire              i_pkt_valid,

    // Direct write port to the VGA character buffer (m_vga_mmio)
    output reg [11:0] o_buf_addr,
    output reg [7:0]  o_buf_wdata,
    output reg        o_buf_we,

    // Current cursor position (exposed for debug and external use)
    output reg [$clog2(COLS)-1:0] o_col,
    output reg [$clog2(ROWS)-1:0] o_row
);

    // -------------------------------------------------------------------------
    // Character codes (IBM CP437 encoding)
    // -------------------------------------------------------------------------
    localparam [7:0] CURSOR_CHAR = 8'hDB;   // 0xDB = solid full-block character
    localparam [7:0] ERASE_CHAR  = 8'h20;   // 0x20 = ASCII space

    // -------------------------------------------------------------------------
    // Sub-character movement accumulators
    //   Signed 12-bit to handle ±SCALE * max_delta without overflow.
    // -------------------------------------------------------------------------
    reg signed [11:0] _acc_x;   // Accumulated X counts not yet applied
    reg signed [11:0] _acc_y;   // Accumulated Y counts not yet applied

    // -------------------------------------------------------------------------
    // New cursor position – latched during S_IDLE, committed during S_DRAW
    // -------------------------------------------------------------------------
    reg [$clog2(COLS)-1:0] _new_col;
    reg [$clog2(ROWS)-1:0] _new_row;

    // -------------------------------------------------------------------------
    // Write FSM state encoding
    // -------------------------------------------------------------------------
    localparam [1:0]
        S_IDLE  = 2'd0,   // Waiting for a new valid packet
        S_ERASE = 2'd1,   // Writing ERASE_CHAR to the old cursor position
        S_DRAW  = 2'd2;   // Writing CURSOR_CHAR to the new cursor position

    reg [1:0] _state;

    // -------------------------------------------------------------------------
    // Function: addr_of
    //   Compute the linear character-buffer address for (col, row).
    //   Formula: addr = row * 80 + col
    //   Implemented as shift-adds to avoid synthesising a multiplier:
    //     row * 80 = row * 64 + row * 16 = (row << 6) + (row << 4)
    // -------------------------------------------------------------------------
    function [11:0] addr_of;
        input [$clog2(COLS)-1:0] col;
        input [$clog2(ROWS)-1:0] row;
        begin
            addr_of = ({7'b0, row} << 6) + ({7'b0, row} << 4) + {5'b0, col};
        end
    endfunction

    // -------------------------------------------------------------------------
    // Function: clamp_col
    //   Clamp a signed 12-bit value to the valid column range [0, COLS-1].
    // -------------------------------------------------------------------------
    function [$clog2(COLS)-1:0] clamp_col;
        input signed [11:0] v;
        begin
            if (v < 0)           clamp_col = 0;
            else if (v >= COLS)  clamp_col = COLS - 1;
            else                 clamp_col = v[$clog2(COLS)-1:0];
        end
    endfunction

    // -------------------------------------------------------------------------
    // Function: clamp_row
    //   Clamp a signed 12-bit value to the valid row range [0, ROWS-1].
    // -------------------------------------------------------------------------
    function [$clog2(ROWS)-1:0] clamp_row;
        input signed [11:0] v;
        begin
            if (v < 0)           clamp_row = 0;
            else if (v >= ROWS)  clamp_row = ROWS - 1;
            else                 clamp_row = v[$clog2(ROWS)-1:0];
        end
    endfunction

    // =========================================================================
    // Synchronous FSM process
    // =========================================================================
    always @(posedge i_clk) begin
        if (i_rst) begin
            // -----------------------------------------------------------------
            // Reset: place cursor at the centre of the screen, clear accumulators
            // -----------------------------------------------------------------
            o_col       <= COLS / 2;
            o_row       <= ROWS / 2;
            _new_col    <= COLS / 2;
            _new_row    <= ROWS / 2;
            _acc_x      <= 12'sd0;
            _acc_y      <= 12'sd0;
            _state      <= S_IDLE;
            o_buf_we    <= 1'b0;
            o_buf_wdata <= 8'h00;
            o_buf_addr  <= 12'd0;
        end else begin
            // Default: de-assert write enable each cycle
            o_buf_we <= 1'b0;

            case (_state)

                // =============================================================
                // S_IDLE
                //   Wait for a valid decoded packet from m_mouse_packet.
                //   When it arrives, accumulate the raw movement counts and
                //   convert them to a new character-cell position.
                //
                //   Accumulation:
                //     _acc_x += sign_extend(i_dx)
                //     _acc_y -= sign_extend(i_dy)   (Y axis inversion)
                //
                //   Position delta in cells:
                //     new_col = current_col + (_acc_x / SCALE)
                //     new_row = current_row + (_acc_y / SCALE)
                //
                //   Remainder (sub-cell fraction) is kept for the next packet.
                //   Both new_col and new_row are clamped to screen boundaries.
                // =============================================================
                S_IDLE: begin
                    if (i_pkt_valid) begin
                        begin : calc
                            reg signed [11:0] ax, ay;   // Updated accumulators
                            reg signed [11:0] nc, nr;   // Candidate new position

                            // Accumulate X: sign-extend 9-bit i_dx to 12 bits
                            ax = _acc_x + {{3{i_dx[8]}}, i_dx};

                            // Accumulate Y: PS/2 dy positive means up,
                            // so subtract to make row decrease when moving up
                            ay = _acc_y - {{3{i_dy[8]}}, i_dy};

                            // Convert accumulated counts to character-cell deltas
                            nc = $signed({1'b0, o_col}) + (ax / $signed(12'd1 * SCALE));
                            nr = $signed({1'b0, o_row}) + (ay / $signed(12'd1 * SCALE));

                            // Clamp to valid screen boundaries
                            _new_col <= clamp_col(nc);
                            _new_row <= clamp_row(nr);

                            // Retain sub-cell remainder for next packet
                            _acc_x <= ax % $signed(12'd1 * SCALE);
                            _acc_y <= ay % $signed(12'd1 * SCALE);
                        end

                        // Proceed to erase the cursor at its current position
                        _state <= S_ERASE;
                    end
                end

                // =============================================================
                // S_ERASE
                //   Write ERASE_CHAR (space) to the character buffer at the
                //   current cursor address, effectively removing the cursor
                //   from its old position.
                //   o_buf_we is pulsed for exactly one clock cycle.
                // =============================================================
                S_ERASE: begin
                    o_buf_addr  <= addr_of(o_col, o_row);   // Old position
                    o_buf_wdata <= ERASE_CHAR;
                    o_buf_we    <= 1'b1;                    // Write for 1 cycle
                    _state      <= S_DRAW;
                end

                // =============================================================
                // S_DRAW
                //   Write CURSOR_CHAR (solid block) to the character buffer at
                //   the new cursor address, rendering the cursor at its new
                //   position.  Also update o_col and o_row so that S_ERASE
                //   knows the correct old position on the next packet.
                //   o_buf_we is pulsed for exactly one clock cycle.
                // =============================================================
                S_DRAW: begin
                    o_buf_addr  <= addr_of(_new_col, _new_row);   // New position
                    o_buf_wdata <= CURSOR_CHAR;
                    o_buf_we    <= 1'b1;                          // Write for 1 cycle
                    o_col       <= _new_col;                      // Commit position
                    o_row       <= _new_row;
                    _state      <= S_IDLE;
                end

                // Safety net: illegal state -> return to idle
                default: _state <= S_IDLE;

            endcase
        end
    end

endmodule
