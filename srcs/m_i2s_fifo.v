`timescale 1ns / 1ps

/*************************************************************************************
 * ASYNC STEREO FIFO FOR I2S AUDIO
 *
 *  Stores 32-bit stereo sample pairs: { left[15:0], right[15:0] }.
 *  Two build paths, selected by a compile-time define:
 *
 *    Default (no define)   → xpm_fifo_async  (Vivado synthesis + Vivado sim)
 *    `define SIM_FIFO_FALLBACK → Gray-code behavioral model (Icarus / Verilator)
 *
 *  Interface contract:
 *    - Write accepted on i_wclk when (i_wr_en && !o_full).
 *    - Read  accepted on i_rclk when (i_rd_en && !o_empty).
 *    - o_rdata is combinationally valid before i_rd_en (FWFT).
 *    - o_full / o_almost_full  are valid in the i_wclk domain.
 *    - o_empty / o_almost_empty are valid in the i_rclk domain.
 *
 *  Thresholds (both paths):
 *    o_almost_full  asserts when occupancy >= DEPTH-4
 *    o_almost_empty asserts when occupancy <= 3
 *
 *  Parameters:
 *    DEPTH_LOG2 : log2 of FIFO depth (default 4 → 16 stereo entries)
 ************************************************************************************/
module i2s_fifo #(
    parameter DEPTH_LOG2 = 4
)(
    // ── Write side (system clock domain) ──────────────────────────────────────────
    input  wire        i_wclk,
    input  wire        i_wrst,
    input  wire        i_wr_en,
    input  wire [31:0] i_wdata,
    output wire        o_full,
    output wire        o_almost_full,

    // ── Read side (BCLK domain) ───────────────────────────────────────────────────
    input  wire        i_rclk,
    input  wire        i_rrst,
    input  wire        i_rd_en,
    output wire [31:0] o_rdata,
    output wire        o_empty,
    output wire        o_almost_empty
);

    localparam DEPTH     = 1 << DEPTH_LOG2;
    localparam AF_THRESH = DEPTH - 4;   // almost_full  : occupancy >= DEPTH-4
    localparam AE_THRESH = 3;           // almost_empty : occupancy <= 3  (XPM min=3)

`ifndef SIM_FIFO_FALLBACK

    // ── XPM path: Vivado synthesis + Vivado simulation ────────────────────────────
    // xpm_fifo_async handles gray-code CDC, FWFT output register, and distributed-RAM
    // storage internally.  USE_ADV_FEATURES "0404" enables prog_full (bit 2) and
    // prog_empty (bit 10) only; all other advanced outputs are left unconnected.
    xpm_fifo_async #(
        .CDC_SYNC_STAGES    (2),
        .DOUT_RESET_VALUE   ("0"),
        .ECC_MODE           ("no_ecc"),
        .FIFO_MEMORY_TYPE   ("distributed"),
        .FIFO_READ_LATENCY  (0),
        .FIFO_WRITE_DEPTH   (DEPTH),
        .FULL_RESET_VALUE   (0),
        .PROG_EMPTY_THRESH  (AE_THRESH),
        .PROG_FULL_THRESH   (AF_THRESH),
        .RD_DATA_COUNT_WIDTH(DEPTH_LOG2 + 1),
        .READ_DATA_WIDTH    (32),
        .READ_MODE          ("fwft"),
        .RELATED_CLOCKS     (0),
        .SIM_ASSERT_CHK     (0),
        .USE_ADV_FEATURES   ("0404"),
        .WAKEUP_TIME        (0),
        .WRITE_DATA_WIDTH   (32),
        .WR_DATA_COUNT_WIDTH(DEPTH_LOG2 + 1)
    ) u_xpm (
        .wr_clk       (i_wclk),
        .rd_clk       (i_rclk),
        .rst          (i_wrst),
        .din          (i_wdata),
        .wr_en        (i_wr_en),
        .dout         (o_rdata),
        .rd_en        (i_rd_en),
        .full         (o_full),
        .empty        (o_empty),
        .prog_full    (o_almost_full),
        .prog_empty   (o_almost_empty),
        // unused outputs
        .almost_full  (),
        .almost_empty (),
        .overflow     (),
        .underflow    (),
        .wr_ack       (),
        .data_valid   (),
        .rd_data_count(),
        .wr_data_count(),
        .rd_rst_busy  (),
        .wr_rst_busy  (),
        .dbiterr      (),
        .sbiterr      (),
        // unused inputs
        .injectdbiterr(1'b0),
        .injectsbiterr(1'b0),
        .sleep        (1'b0)
    );

`else

    // ── Behavioral fallback: gray-code async FIFO (Icarus / Verilator) ────────────

    localparam PTR_W = DEPTH_LOG2 + 1;

    reg [31:0]      _mem [0:DEPTH-1];
    reg [PTR_W-1:0] _wptr, _rptr;

    wire [PTR_W-1:0] _wptr_gray = _wptr ^ (_wptr >> 1);
    wire [PTR_W-1:0] _rptr_gray = _rptr ^ (_rptr >> 1);

    reg [PTR_W-1:0] _wgray_r1, _wgray_r2;
    reg [PTR_W-1:0] _rgray_w1, _rgray_w2;

    always @(posedge i_rclk or posedge i_rrst)
        if (i_rrst) { _wgray_r2, _wgray_r1 } <= 0;
        else        { _wgray_r2, _wgray_r1 } <= { _wgray_r1, _wptr_gray };

    always @(posedge i_wclk or posedge i_wrst)
        if (i_wrst) { _rgray_w2, _rgray_w1 } <= 0;
        else        { _rgray_w2, _rgray_w1 } <= { _rgray_w1, _rptr_gray };

    wire [PTR_W-1:0] _wptr_in_rclk, _rptr_in_wclk;
    genvar _gi;
    generate
        for (_gi = 0; _gi < PTR_W; _gi = _gi + 1) begin : g2b
            assign _wptr_in_rclk[_gi] = ^(_wgray_r2 >> _gi);
            assign _rptr_in_wclk[_gi] = ^(_rgray_w2 >> _gi);
        end
    endgenerate

    wire [PTR_W-1:0] _used_wclk = _wptr        - _rptr_in_wclk;
    wire [PTR_W-1:0] _used_rclk = _wptr_in_rclk - _rptr;

    assign o_full        = (_wptr[PTR_W-1]   != _rptr_in_wclk[PTR_W-1]) &&
                           (_wptr[PTR_W-2:0] == _rptr_in_wclk[PTR_W-2:0]);
    assign o_almost_full  = (_used_wclk >= AF_THRESH);
    assign o_empty        = (_wptr_in_rclk == _rptr);
    assign o_almost_empty = (_used_rclk <= AE_THRESH);

    always @(posedge i_wclk or posedge i_wrst)
        if (i_wrst)
            _wptr <= 0;
        else if (i_wr_en && !o_full) begin
            _mem[_wptr[DEPTH_LOG2-1:0]] <= i_wdata;
            _wptr <= _wptr + 1'b1;
        end

    always @(posedge i_rclk or posedge i_rrst)
        if (i_rrst)
            _rptr <= 0;
        else if (i_rd_en && !o_empty)
            _rptr <= _rptr + 1'b1;

    assign o_rdata = _mem[_rptr[DEPTH_LOG2-1:0]];

`endif

endmodule
