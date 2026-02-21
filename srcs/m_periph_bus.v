`timescale 1ns / 1ps

/*************************************************************************************
 * PERIPHERAL BUS MODULE
 *  Interface to all SoC peripherals 
 *  - TIMER0/1
 *  - PARIO
 *  - UART
 *  - I2C
 *  - IRQ
 ************************************************************************************/

module periph_bus(
    input wire i_clk,
    input wire i_rst,
    input wire [15:0] i_addr,           // Address used to identify the peripheral - (11:8 bits are used)
    input wire i_sel,                   // IO selection
    input wire i_we,                    // IO write enable
    input wire i_re,                    // IO read enable
    input wire [15:0] i_wdata,          // Data to Write
    output wire [15:0] o_rdata,         // Data Read
    output wire o_rdy,                  // Feadback peripheral ready
    input wire [3:0] i_par_i,           // PARIO - Input
    output wire [3:0] o_par_o,          // PARIO - Output
    input wire i_uart_rx,               // UART - Receive
    output wire o_uart_tx,              // UART - Transmit
    inout wire io_i2c_sda,              // I2C - SDA
    inout wire io_i2c_scl,              // I2C - SCL
    input wire i_int_en,                // IRQ - Enable Interrupt Signal
    input wire i_in_irq,                // IRQ - Is there an Interrupt currently running?
    output wire [15:0] o_irq_vector,    // IRQ - Interrupt Vector
    output wire o_irq_take,             // IRQ - Signal to Take the Interrupt
    input wire i_irq_ret                // IRQ - Return from interrupt (RETI) detected
);

/*************************************************************************************
 * SECTION 1. DECLARE/DEFINE Variables/Registers/Wires
 ************************************************************************************/

/****************************************************************************
 * 1.1 DEFINE MEMORY ADDRESS for the peripherals (2nd MS nibble - 11:8 bits)
 ***************************************************************************/
    localparam [3:0] TIMER0 = 4'h0;
    localparam [3:0] TIMER1 = 4'h1;
    localparam [3:0] PARIO = 4'h2;
    localparam [3:0] UART = 4'h3;
    localparam [3:0] I2C = 4'h4;
    localparam [3:0] IRQ = 4'hF;

/****************************************************************************
 * 1.2 DECLARE WIRES / REGS
 ***************************************************************************/
    wire _sel_timer0;
    wire _sel_timer1;
    wire _sel_pario;
    wire _sel_uart;
    wire _sel_i2c;
    wire _sel_irq;

    wire _timer0_rdy;
    wire _timer1_rdy;
    wire _pario_rdy;
    wire _uart_rdy;
    wire _i2c_rdy;
    wire _irq_rdy;

    wire _timer0_int_req;
    wire _timer1_int_req;
    wire _pario_int_req;
    wire _uart_int_req;
    wire _i2c_int_req;

    wire [7:0] _int_cause;

    wire [15:0] _timer0_rdata;
    wire [15:0] _timer1_rdata;
    wire [15:0] _pario_rdata;
    wire [15:0] _uart_rdata;
    wire [15:0] _i2c_rdata;
    wire [15:0] _irq_rdata;

/****************************************************************************
 * 1.2 DEFINE INTERRUPT SOURCE LINES
 ***************************************************************************/
    localparam integer _irq_timer0 = 0;
    localparam integer _irq_timer1 = 1;
    localparam integer _irq_pario = 2;
    localparam integer _irq_uart = 3;
    localparam integer _irq_i2c = 4;

/****************************************************************************
 * 1.3 DEFINE UART BAUDRATE
 ***************************************************************************/

`ifdef SIM
    localparam integer BAUDRATE_UART = 2_000_000;
`else
    localparam integer BAUDRATE_UART = 115200;
`endif

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

/****************************************************************************
 * 2.1 Peripheral Select Decode
 ***************************************************************************/
    assign _sel_timer0 = i_sel && (i_addr[11:8] == TIMER0);
    assign _sel_timer1 = i_sel && (i_addr[11:8] == TIMER1);
    assign _sel_pario = i_sel && (i_addr[11:8] == PARIO);
    assign _sel_uart = i_sel && (i_addr[11:8] == UART);
    assign _sel_i2c = i_sel && (i_addr[11:8] == I2C);
    assign _sel_irq = i_sel && (i_addr[11:8] == IRQ);

// _int_cause register
//  BIT 7 6 5  4   3     2   1  0
//  SRC - - - I2C UART PARIO T0 T1
    assign _int_cause[_irq_timer0] = _timer0_int_req;
    assign _int_cause[_irq_timer1] = _timer1_int_req;
    assign _int_cause[_irq_pario] = _pario_int_req;
    assign _int_cause[_irq_uart] = _uart_int_req;
    assign _int_cause[_irq_i2c] = _i2c_int_req;
    assign _int_cause[7:5] = 3'b000;

/****************************************************************************
 * 2.2 Peripheral Instances
 ***************************************************************************/
    timer16 u_timer0 (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_sel(_sel_timer0),
        .i_we(i_we),
        .i_re(i_re),
        .i_addr(i_addr[2:1]),
        .i_wdata(i_wdata),
        .o_rdata(_timer0_rdata),
        .o_rdy(_timer0_rdy),
        .o_int_req(_timer0_int_req)
    );

    timerH u_timer1 (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_sel(_sel_timer1),
        .i_we(i_we),
        .i_re(i_re),
        .i_addr(i_addr[2:1]),
        .i_wdata(i_wdata),
        .o_rdata(_timer1_rdata),
        .o_rdy(_timer1_rdy),
        .o_int_req(_timer1_int_req)
    );

    pario u_pario (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_sel(_sel_pario),
        .i_we(i_we),
        .i_re(i_re),
        .i_addr(i_addr[2:1]),
        .i_wdata(i_wdata),
        .o_rdata(_pario_rdata),
        .o_rdy(_pario_rdy),
        .i_i(i_par_i),
        .o_o(o_par_o),
        .o_int_req(_pario_int_req)
    );

    uart_mmio #(
        .CLK_FREQ(100_000_000),
        .BAUD_RATE(BAUDRATE_UART)
    ) u_uart (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_sel(_sel_uart),
        .i_we(i_we),
        .i_re(i_re),
        .i_addr(i_addr[2:1]),
        .i_wdata(i_wdata),
        .o_rdata(_uart_rdata),
        .o_rdy(_uart_rdy),
        .i_rx_in(i_uart_rx),
        .o_tx_out(o_uart_tx),
        .o_irq_req(_uart_int_req)
    );

    i2c_mmio u_i2c (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_sel(_sel_i2c),
        .i_we(i_we),
        .i_re(i_re),
        .i_addr(i_addr[3:1]),
        .i_wdata(i_wdata),
        .o_rdata(_i2c_rdata),
        .o_rdy(_i2c_rdy),
        .o_irq_req(_i2c_int_req),
        .io_i2c_sda(io_i2c_sda),
        .io_i2c_scl(io_i2c_scl)
    );

    irq_ctrl u_irq_ctrl (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_sel(_sel_irq),
        .i_we(i_we),
        .i_re(i_re),
        .i_wdata(i_wdata),
        .o_rdata(_irq_rdata),
        .i_addr(i_addr[3:1]),
        .o_rdy(_irq_rdy),
        .i_src_irq(_int_cause),
        .i_in_irq(i_in_irq),
        .i_int_en(i_int_en),
        .i_irq_ret(i_irq_ret),
        .o_irq_take(o_irq_take),
        .o_irq_vector(o_irq_vector)
    );

/****************************************************************************
 * 2.3 Return Muxes
 ***************************************************************************/
    assign o_rdy = _sel_timer0 ? _timer0_rdy :
                   (_sel_timer1 ? _timer1_rdy :
                   (_sel_pario ? _pario_rdy :
                   (_sel_uart ? _uart_rdy :
                   (_sel_i2c ? _i2c_rdy :
                   (_sel_irq ? _irq_rdy : 1'b1)))));

    assign o_rdata = (_sel_timer0 && i_re) ? _timer0_rdata :
                     ((_sel_timer1 && i_re) ? _timer1_rdata :
                     ((_sel_pario && i_re) ? _pario_rdata :
                     ((_sel_uart && i_re) ? _uart_rdata :
                     ((_sel_i2c && i_re) ? _i2c_rdata :
                     ((_sel_irq && i_re) ? _irq_rdata : 16'h0000)))));

endmodule
