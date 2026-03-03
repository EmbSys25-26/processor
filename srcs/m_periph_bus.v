`timescale 1ns / 1ps

/*************************************************************************************
 * PERIPHERAL BUS MODULE - UPDATED FOR I2S
 *  Changes from original m_periph_bus.v:
 *    1. Added I2S peripheral address localparam (4'h7)
 *    2. Added I2S port declarations (mclk input, I2S output signals)
 *    3. Added _sel_i2s wire + decode
 *    4. Added _i2s_rdy, _i2s_rdata, _i2s_int_req wires
 *    5. Added _irq_i2s interrupt source line
 *    6. Instantiated i2s_mmio
 *    7. Updated o_rdy and o_rdata mux chains
 *
 *  Everything else is UNCHANGED from the original.
 ************************************************************************************/

module periph_bus(
    input wire i_clk,
    input wire i_rst,
    input wire [15:0] i_addr,
    input wire i_sel,
    input wire i_we,
    input wire i_re,
    input wire [15:0] i_wdata,
    output wire [15:0] o_rdata,
    output wire o_rdy,
    input wire [3:0] i_par_i,
    output wire [3:0] o_par_o,
    input wire i_uart_rx,
    output wire o_uart_tx,
    inout wire io_i2c_sda,
    inout wire io_i2c_scl,
    // ── NEW: I2S ports ──────────────────────────────────────────────────────
    input  wire i_i2s_mclk,        // 12.288 MHz from top-level MMCM
    output wire o_i2s_mclk,        // -> SSM2603 MCLK pin
    output wire o_i2s_bclk,        // -> SSM2603 BCLK pin
    output wire o_i2s_lrclk,       // -> SSM2603 PBLRC pin
    output wire o_i2s_pbdat,       // -> SSM2603 PBDAT pin
    inout  wire io_i2s_sda,        // I2C for SSM2603 config (can share io_i2c_sda)
    inout  wire io_i2s_scl,        // I2C for SSM2603 config (can share io_i2c_scl)
    // ────────────────────────────────────────────────────────────────────────
    input wire i_int_en,
    input wire i_in_irq,
    output wire [15:0] o_irq_vector,
    output wire o_irq_take,
    input wire i_irq_ret
);

/*************************************************************************************
 * SECTION 1. DECLARE/DEFINE Variables
 ************************************************************************************/

    localparam [3:0] TIMER0 = 4'h0;
    localparam [3:0] TIMER1 = 4'h1;
    localparam [3:0] PARIO  = 4'h2;
    localparam [3:0] UART   = 4'h3;
    localparam [3:0] I2C    = 4'h4;
    localparam [3:0] I2S    = 4'h7;   // ← NEW: 0x87xx
    localparam [3:0] IRQ    = 4'hF;

    wire _sel_timer0, _sel_timer1, _sel_pario, _sel_uart, _sel_i2c, _sel_irq;
    wire _sel_i2s;                     // ← NEW

    wire _timer0_rdy, _timer1_rdy, _pario_rdy, _uart_rdy, _i2c_rdy, _irq_rdy;
    wire _i2s_rdy;                     // ← NEW

    wire _timer0_int_req, _timer1_int_req, _pario_int_req, _uart_int_req, _i2c_int_req;
    wire _i2s_int_req;                 // ← NEW

    wire [7:0] _int_cause;

    wire [15:0] _timer0_rdata, _timer1_rdata, _pario_rdata, _uart_rdata, _i2c_rdata, _irq_rdata;
    wire [15:0] _i2s_rdata;            // ← NEW

    localparam integer _irq_timer0 = 0;
    localparam integer _irq_timer1 = 1;
    localparam integer _irq_pario  = 2;
    localparam integer _irq_uart   = 3;
    localparam integer _irq_i2c    = 4;
    localparam integer _irq_i2s    = 5;  // ← NEW

`ifdef SIM
    localparam integer BAUDRATE_UART = 2_000_000;
`else
    localparam integer BAUDRATE_UART = 115200;
`endif

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

    assign _sel_timer0 = i_sel && (i_addr[11:8] == TIMER0);
    assign _sel_timer1 = i_sel && (i_addr[11:8] == TIMER1);
    assign _sel_pario  = i_sel && (i_addr[11:8] == PARIO);
    assign _sel_uart   = i_sel && (i_addr[11:8] == UART);
    assign _sel_i2c    = i_sel && (i_addr[11:8] == I2C);
    assign _sel_i2s    = i_sel && (i_addr[11:8] == I2S);   // ← NEW
    assign _sel_irq    = i_sel && (i_addr[11:8] == IRQ);

    assign _int_cause[_irq_timer0] = _timer0_int_req;
    assign _int_cause[_irq_timer1] = _timer1_int_req;
    assign _int_cause[_irq_pario]  = _pario_int_req;
    assign _int_cause[_irq_uart]   = _uart_int_req;
    assign _int_cause[_irq_i2c]    = _i2c_int_req;
    assign _int_cause[_irq_i2s]    = _i2s_int_req;   // ← NEW
    assign _int_cause[7:6]         = 2'b00;           // (was 7:5 = 3'b000 before)

    // ── Existing peripheral instances (UNCHANGED) ────────────────────────────────
    timer16 u_timer0 (
        .i_clk(i_clk), .i_rst(i_rst),
        .i_sel(_sel_timer0), .i_we(i_we), .i_re(i_re),
        .i_addr(i_addr[2:1]), .i_wdata(i_wdata),
        .o_rdata(_timer0_rdata), .o_rdy(_timer0_rdy), .o_int_req(_timer0_int_req)
    );

    timerH u_timer1 (
        .i_clk(i_clk), .i_rst(i_rst),
        .i_sel(_sel_timer1), .i_we(i_we), .i_re(i_re),
        .i_addr(i_addr[2:1]), .i_wdata(i_wdata),
        .o_rdata(_timer1_rdata), .o_rdy(_timer1_rdy), .o_int_req(_timer1_int_req)
    );

    pario u_pario (
        .i_clk(i_clk), .i_rst(i_rst),
        .i_sel(_sel_pario), .i_we(i_we), .i_re(i_re),
        .i_addr(i_addr[2:1]), .i_wdata(i_wdata),
        .o_rdata(_pario_rdata), .o_rdy(_pario_rdy),
        .i_i(i_par_i), .o_o(o_par_o), .o_int_req(_pario_int_req)
    );

    uart_mmio #(
        .CLK_FREQ(100_000_000),
        .BAUD_RATE(BAUDRATE_UART)
    ) u_uart (
        .i_clk(i_clk), .i_rst(i_rst),
        .i_sel(_sel_uart), .i_we(i_we), .i_re(i_re),
        .i_addr(i_addr[2:1]), .i_wdata(i_wdata),
        .o_rdata(_uart_rdata), .o_rdy(_uart_rdy),
        .i_rx_in(i_uart_rx), .o_tx_out(o_uart_tx), .o_irq_req(_uart_int_req)
    );

    i2c_mmio u_i2c (
        .i_clk(i_clk), .i_rst(i_rst),
        .i_sel(_sel_i2c), .i_we(i_we), .i_re(i_re),
        .i_addr(i_addr[3:1]), .i_wdata(i_wdata),
        .o_rdata(_i2c_rdata), .o_rdy(_i2c_rdy), .o_irq_req(_i2c_int_req),
        .io_i2c_sda(io_i2c_sda), .io_i2c_scl(io_i2c_scl)
    );

    irq_ctrl u_irq_ctrl (
        .i_clk(i_clk), .i_rst(i_rst),
        .i_sel(_sel_irq), .i_we(i_we), .i_re(i_re),
        .i_wdata(i_wdata), .o_rdata(_irq_rdata),
        .i_addr(i_addr[3:1]), .o_rdy(_irq_rdy),
        .i_src_irq(_int_cause),
        .i_in_irq(i_in_irq), .i_int_en(i_int_en), .i_irq_ret(i_irq_ret),
        .o_irq_take(o_irq_take), .o_irq_vector(o_irq_vector)
    );

    // ── NEW: I2S instance ────────────────────────────────────────────────────────
    i2s_mmio u_i2s (
        .i_clk       (i_clk),
        .i_rst       (i_rst),
        .i_mclk      (i_i2s_mclk),
        .i_sel       (_sel_i2s),
        .i_we        (i_we),
        .i_re        (i_re),
        .i_addr      (i_addr[3:1]),
        .i_wdata     (i_wdata),
        .o_rdata     (_i2s_rdata),
        .o_rdy       (_i2s_rdy),
        .o_irq_req   (_i2s_int_req),
        .o_mclk      (o_i2s_mclk),
        .o_bclk      (o_i2s_bclk),
        .o_lrclk     (o_i2s_lrclk),
        .o_pbdat     (o_i2s_pbdat),
        .io_i2c_sda  (io_i2s_sda),
        .io_i2c_scl  (io_i2s_scl)
    );

    // ── Return muxes (I2S added) ─────────────────────────────────────────────────
    assign o_rdy = _sel_timer0 ? _timer0_rdy :
                   (_sel_timer1 ? _timer1_rdy :
                   (_sel_pario  ? _pario_rdy  :
                   (_sel_uart   ? _uart_rdy   :
                   (_sel_i2c    ? _i2c_rdy    :
                   (_sel_i2s    ? _i2s_rdy    :   // ← NEW
                   (_sel_irq    ? _irq_rdy    : 1'b1))))));

    assign o_rdata = (_sel_timer0 && i_re) ? _timer0_rdata :
                     ((_sel_timer1 && i_re) ? _timer1_rdata :
                     ((_sel_pario  && i_re) ? _pario_rdata  :
                     ((_sel_uart   && i_re) ? _uart_rdata   :
                     ((_sel_i2c    && i_re) ? _i2c_rdata    :
                     ((_sel_i2s    && i_re) ? _i2s_rdata    :  // ← NEW
                     ((_sel_irq    && i_re) ? _irq_rdata    : 16'h0000))))));

endmodule