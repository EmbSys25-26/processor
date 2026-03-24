`timescale 1ns / 1ps

/*************************************************************************************
 * ASYNC STEREO FIFO FOR I2S AUDIO
 *  Stores 32-bit stereo sample pairs: { left[15:0], right[15:0] }.
 *  Design: classic gray-code pointer async FIFO, First-Word Fall-Through (FWFT).
 *
 *  Core contract:
 *    - Write is accepted on i_wclk when (i_wr_en && !o_full).
 *    - Read  is accepted on i_rclk when (i_rd_en && !o_empty).
 *    - o_rdata always reflects the current head element (FWFT).
 *    - A successful read advances the head pointer by one.
 *    - A successful write appends one new element at the tail pointer.
 *
 *  Parameters:
 *    DEPTH_LOG2 : log2 of FIFO depth. Default 4 -> 16 stereo entries.
 *
 *  Clock domains:
 *    Write side : i_wclk  (system clock - sample producer writes here)
 *    Read  side : i_rclk  (BCLK domain - i2s_tx pops samples here)
 *
 *  Status flags:
 *    o_full, o_almost_full   -> valid in i_wclk domain
 *    o_empty, o_almost_empty -> valid in i_rclk domain
 *
 *  Thresholds:
 *    o_almost_full  = occupancy >= DEPTH-4 (default: >=12 for DEPTH=16)
 *    o_almost_empty = occupancy <= 2
 *
 *  FWFT: o_rdata is combinationally valid before i_rd_en is asserted.
 *  The read pointer advances on the posedge of i_rclk after i_rd_en.
 *
 *  CDC note:
 *    Using the same i_rst signal for both sides is an acceptable simplification
 *    for bring-up. In production, each domain should use a reset synchronized
 *    to its own clock.
 ************************************************************************************/

module i2s_fifo #(
    parameter DEPTH_LOG2 = 4            // Default: 16 entries (DEPTH=16 stereo pairs)
)(
    // ── Write side (system clock domain) ──────────────────────────────────────────
    input  wire        i_wclk,          // System clock domain (sample producer writes here)
    input  wire        i_wrst,
    input  wire        i_wr_en,
    input  wire [31:0] i_wdata,         // { left[15:0], right[15:0] }
    output wire        o_full,
    output wire        o_almost_full,   // <= 4 free slots remaining

    // ── Read side (BCLK domain) ───────────────────────────────────────────────────
    input  wire        i_rclk,          // 3.072 MHz bit clock (BCLK domain, i2s_tx reads here)
    input  wire        i_rrst,          // read reset
    input  wire        i_rd_en,
    output wire [31:0] o_rdata,         // { left[15:0], right[15:0] } - FWFT
    output wire        o_empty,
    output wire        o_almost_empty   // <= 2 entries remaining
);

    localparam DEPTH = 1 << DEPTH_LOG2; // 16 entries for DEPTH_LOG2=4
    localparam PTR_W = DEPTH_LOG2 + 1;  // Extra MSB distinguishes full from empty

/*************************************************************************************
 * SECTION 1. MEMORY AND POINTERS
 ************************************************************************************/
    reg [31:0]       _mem [0:DEPTH-1];  // DEPTH slots of { left[15:0], right[15:0] }

    reg [PTR_W-1:0]  _wptr;             // Write pointer (wclk domain, binary)
    reg [PTR_W-1:0]  _rptr;             // Read  pointer (rclk domain, binary)

    wire [PTR_W-1:0] _wptr_gray;        // Write pointer (wclk domain, gray code for synchronization)
    wire [PTR_W-1:0] _rptr_gray;        // Read pointer (rclk domain, gray code for synchronization)

/*************************************************************************************)
 * SECTION 2. GRAY-CODE SYNCHRONIZERS (2-FF each direction)
 ************************************************************************************/
    // Write gray synced to rclk
    reg [PTR_W-1:0] _wgray_r1, _wgray_r2;   // 2-FF sync stages in read domain
    // Read gray synced to wclk
    reg [PTR_W-1:0] _rgray_w1, _rgray_w2;   // 2-FF sync stages in write domain

    // Binary to gray conversion for local pointers (for synchronization to opposite domain).
    assign _wptr_gray = _wptr ^ (_wptr >> 1);       // Binary to gray write pointer
    assign _rptr_gray = _rptr ^ (_rptr >> 1);       // Binary to gray read pointer

    // Synchronize write-pointer gray into read-clock domain.
    // Purpose: let read domain compute empty/almost_empty safely.
    // Implements dual flip-flop synchronizer to mitigate metastability.
    // _wgray_r1 -> first stage captures write pointer gray; _wgray_r2 -> second stage for stability.
    always @(posedge i_rclk or posedge i_rrst) begin
        if (i_rrst) { _wgray_r2, _wgray_r1 } <= 0;
        else        { _wgray_r2, _wgray_r1 } <= { _wgray_r1, _wptr_gray };
    end

    // Synchronize read-pointer gray into write-clock domain.
    // Purpose: let write domain compute full/almost_full safely.
    // Implements dual flip-flop synchronizer to mitigate metastability.
    // _rgray_w1 -> first stage captures read pointer gray; _rgray_w2 -> second stage for stability.
    always @(posedge i_wclk or posedge i_wrst) begin
        if (i_wrst) { _rgray_w2, _rgray_w1 } <= 0;
        else        { _rgray_w2, _rgray_w1 } <= { _rgray_w1, _rptr_gray };
    end

/*************************************************************************************
 * SECTION 3. GRAY-TO-BINARY DECODE (for flag computation)
 ************************************************************************************/
    wire [PTR_W-1:0] _wptr_in_rclk;   // Reconstructed write pointer in rclk domain
    wire [PTR_W-1:0] _rptr_in_wclk;   // Reconstructed read  pointer in wclk domain

    // Generate loop for gray-to-binary conversion of synchronized pointers.
    // The binary pointer is reconstructed by XORing the gray code bits cumulatively.
    genvar _gi;
    generate
        for (_gi = 0; _gi < PTR_W; _gi = _gi + 1) begin : g2b
            assign _wptr_in_rclk[_gi] = ^(_wgray_r2 >> _gi);
            assign _rptr_in_wclk[_gi] = ^(_rgray_w2 >> _gi);
        end
    endgenerate

/*************************************************************************************
 * SECTION 4. STATUS FLAGS
 ************************************************************************************/
    // Local-domain occupancy estimates derived from synchronized opposite pointer.
    // Width PTR_W (= DEPTH_LOG2+1) preserves modulo arithmetic across wrap-around.
    wire [PTR_W-1:0] _used_wclk;
    wire [PTR_W-1:0] _used_rclk;
    assign _used_wclk = (_wptr - _rptr_in_wclk);
    assign _used_rclk = (_wptr_in_rclk - _rptr);

    // Full (wclk domain): MSB differs, remaining bits equal
    assign o_full        = (_wptr[PTR_W-1]   != _rptr_in_wclk[PTR_W-1]) &&
                           (_wptr[PTR_W-2:0] == _rptr_in_wclk[PTR_W-2:0]);
                           
    assign o_almost_full = (_used_wclk >= (DEPTH - 4));

    // Empty (rclk domain): all bits equal
    assign o_empty        = (_wptr_in_rclk == _rptr);
    assign o_almost_empty = (_used_rclk <= 2);

/*************************************************************************************
 * SECTION 5. READ / WRITE LOGIC
 ************************************************************************************/
    always @(posedge i_wclk or posedge i_wrst) begin
        if (i_wrst) begin
            _wptr <= 0;
        end else if (i_wr_en && !o_full) begin
            _mem[_wptr[DEPTH_LOG2-1:0]] <= i_wdata;
            _wptr <= _wptr + 1'b1;
        end
    end

    always @(posedge i_rclk or posedge i_rrst) begin
        if (i_rrst) begin
            _rptr <= 0;
        end else if (i_rd_en && !o_empty) begin
            _rptr <= _rptr + 1'b1;
        end
    end

    // FWFT: combinational output - data valid at head before rd_en.
    // Consumer (i2s_tx) samples this and then pulses i_rd_en to pop.
    assign o_rdata = _mem[_rptr[DEPTH_LOG2-1:0]];

endmodule