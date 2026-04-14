`timescale 1ns / 1ps

// ============================================================================
// Module  : m_mouse_packet
// Project : PS/2 Mouse Controller
// File    : m_mouse_packet.v
//
// Description:
//   Assembles the raw PS/2 byte stream into complete 3-byte mouse packets
//   and decodes movement and button information from each packet.
//
// PS/2 3-byte packet format (standard PS/2 mouse, per specification):
//
//   Byte 1 (status / flags):
//     [7]  YV  – Y-axis overflow flag  (1 = overflow, discard Y movement)
//     [6]  XV  – X-axis overflow flag  (1 = overflow, discard X movement)
//     [5]  Y8  – Y movement sign bit   (MSB of the 9-bit signed integer)
//     [4]  X8  – X movement sign bit   (MSB of the 9-bit signed integer)
//     [3]  1   – Always 1 (synchronisation marker)
//     [2]  M   – Middle button pressed
//     [1]  R   – Right button pressed
//     [0]  L   – Left button pressed
//
//   Byte 2:  X-axis movement [7:0]  (lower 8 bits)
//   Byte 3:  Y-axis movement [7:0]  (lower 8 bits)
//
// Decoded outputs:
//   dx = { X8, Byte2[7:0] }  – 9-bit signed, positive = right
//   dy = { Y8, Byte3[7:0] }  – 9-bit signed, positive = up
//   If XV = 1, dx is forced to 0 (overflow: movement too fast to be trusted)
//   If YV = 1, dy is forced to 0
//
// Synchronisation:
//   Byte 1 is only accepted when bit[3] == 1.  This is a protocol invariant
//   that allows the FSM to self-synchronise after a lost byte or power-up
//   mis-alignment without requiring an explicit reset.  A byte received in
//   the BYTE1 state with bit[3] == 0 is silently discarded and the FSM
//   remains in BYTE1, waiting for a valid first byte.
//
// Enable gate:
//   The module only processes incoming bytes when i_mouse_ready is high.
//   This prevents partial packets being accepted before m_mouse_init has
//   finished the initialisation sequence.
//
// Output timing:
//   o_valid is a 1-cycle pulse asserted on the clock edge after Byte 3 is
//   received.  All output fields (o_dx, o_dy, o_btn_*) are stable from that
//   edge until the next o_valid pulse.
//
// Parameters:
//   None.
//
// Port list:
//   i_clk         System clock, rising-edge sensitive
//   i_rst         Synchronous active-high reset
//   i_rx_data     8-bit byte from the PS/2 receiver
//   i_rx_valid    1-cycle pulse: i_rx_data contains a new valid byte
//   i_mouse_ready Enable gate from m_mouse_init (high once init is done)
//   o_dx          9-bit signed X displacement (positive = right)
//   o_dy          9-bit signed Y displacement (positive = up)
//   o_btn_l       Left button state (1 = pressed)
//   o_btn_r       Right button state (1 = pressed)
//   o_btn_m       Middle button state (1 = pressed)
//   o_valid       1-cycle pulse: packet decoded, all outputs are valid
// ============================================================================

module m_mouse_packet (
    input  wire       i_clk,
    input  wire       i_rst,

    input  wire [7:0] i_rx_data,
    input  wire       i_rx_valid,
    input  wire       i_mouse_ready,   // Enable gate: only process after init

    output reg signed [8:0] o_dx,     // X displacement, 9-bit signed
    output reg signed [8:0] o_dy,     // Y displacement, 9-bit signed
    output reg              o_btn_l,  // Left button
    output reg              o_btn_r,  // Right button
    output reg              o_btn_m,  // Middle button
    output reg              o_valid   // 1-cycle pulse: decoded packet ready
);

    // -------------------------------------------------------------------------
    // FSM state encoding
    // Each state corresponds to which byte of the 3-byte packet is expected next
    // -------------------------------------------------------------------------
    localparam [1:0]
        BYTE1 = 2'd0,   // Waiting for the status/flags byte
        BYTE2 = 2'd1,   // Waiting for the X-movement byte
        BYTE3 = 2'd2;   // Waiting for the Y-movement byte

    // -------------------------------------------------------------------------
    // Internal registers
    // -------------------------------------------------------------------------
    reg [1:0] _state;   // Current FSM state
    reg [7:0] _b1;      // Latched copy of Byte 1 (status/flags)
    reg [7:0] _b2;      // Latched copy of Byte 2 (X movement low byte)

    // =========================================================================
    // Synchronous FSM process
    // =========================================================================
    always @(posedge i_clk) begin
        if (i_rst) begin
            // -----------------------------------------------------------------
            // Reset: clear state and all outputs
            // -----------------------------------------------------------------
            _state  <= BYTE1;
            _b1     <= 8'h00;
            _b2     <= 8'h00;
            o_dx    <= 9'd0;
            o_dy    <= 9'd0;
            o_btn_l <= 1'b0;
            o_btn_r <= 1'b0;
            o_btn_m <= 1'b0;
            o_valid <= 1'b0;
        end else begin
            // De-assert the valid pulse every cycle; BYTE3 re-asserts it
            o_valid <= 1'b0;

            // Only process incoming bytes once the mouse has been initialised
            if (i_rx_valid && i_mouse_ready) begin
                case (_state)

                    // =========================================================
                    // BYTE1 – Status / flags byte
                    //   Accept the byte only when bit[3] == 1.
                    //   bit[3] is defined by the PS/2 specification as always 1
                    //   in Byte 1, making it a reliable synchronisation marker.
                    //   If bit[3] == 0 the byte belongs to a previous incomplete
                    //   packet or was mis-framed; discard it and stay in BYTE1.
                    // =========================================================
                    BYTE1: begin
                        if (i_rx_data[3] == 1'b1) begin
                            _b1    <= i_rx_data;   // Latch valid status byte
                            _state <= BYTE2;
                        end
                        // bit[3] == 0: silently discard, remain in BYTE1 (resync)
                    end

                    // =========================================================
                    // BYTE2 – X-axis movement, lower 8 bits
                    //   No validation needed; any byte value is a legal delta.
                    //   Latch and advance to BYTE3.
                    // =========================================================
                    BYTE2: begin
                        _b2    <= i_rx_data;   // Latch X movement low byte
                        _state <= BYTE3;
                    end

                    // =========================================================
                    // BYTE3 – Y-axis movement, lower 8 bits
                    //   This is the final byte of the packet.  Decode all fields
                    //   and assert o_valid for one clock cycle.
                    //
                    //   X displacement:
                    //     XV (_b1[6]) = 1 -> overflow, force dx = 0
                    //     XV = 0          -> dx = { X8(_b1[4]), _b2[7:0] }
                    //
                    //   Y displacement:
                    //     YV (_b1[7]) = 1 -> overflow, force dy = 0
                    //     YV = 0          -> dy = { Y8(_b1[5]), Byte3[7:0] }
                    //
                    //   Button states are taken directly from Byte 1 bits [2:0].
                    // =========================================================
                    BYTE3: begin
                        // Decode X displacement (overflow -> zero)
                        o_dx <= _b1[6] ? 9'sd0 : $signed({_b1[4], _b2});

                        // Decode Y displacement (overflow -> zero)
                        o_dy <= _b1[7] ? 9'sd0 : $signed({_b1[5], i_rx_data});

                        // Decode button states from Byte 1
                        o_btn_l <= _b1[0];   // Left button
                        o_btn_r <= _b1[1];   // Right button
                        o_btn_m <= _b1[2];   // Middle button

                        // Pulse the valid flag for one clock to notify consumers
                        o_valid <= 1'b1;

                        // Return to BYTE1 to await the next packet
                        _state <= BYTE1;
                    end

                    // Safety net: illegal state -> resynchronise
                    default: _state <= BYTE1;

                endcase
            end
        end
    end

endmodule
