`timescale 1ns / 1ps
//`define SIM 

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
     input wire i_rst_ext,
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
     input wire i_int_en,
     input wire i_in_irq,
     output wire [15:0] o_irq_vector,
     output wire o_irq_take,
     input wire i_irq_ret,
     output wire o_wdt_rst,
 
     // --- NEW VGA & PS/2 & DDR PORTS ---
     inout wire io_ps2_clk,
     inout wire io_ps2_data,
     input  wire        i_clkVGA,
     output wire [3:0]  o_vga_red,
     output wire [3:0]  o_vga_green,
     output wire [3:0]  o_vga_blue,
     output wire        o_hsync,
     output wire        o_vsync,
     input wire i_mode_switch,
     input wire i_img_switch,
     inout  [14:0] io_DDR_addr,
     inout  [2:0]  io_DDR_ba,
     inout         io_DDR_cas_n,
     inout         io_DDR_ck_n,
     inout         io_DDR_ck_p,
     inout         io_DDR_cke,
     inout         io_DDR_cs_n,
     inout  [3:0]  io_DDR_dm,
     inout  [31:0] io_DDR_dq,
     inout  [3:0]  io_DDR_dqs_n,
     inout  [3:0]  io_DDR_dqs_p,
     inout         io_DDR_odt,
     inout         io_DDR_ras_n,
     inout         io_DDR_reset_n,
     inout         io_DDR_we_n,
     inout         io_FIXED_IO_ddr_vrn,
     inout         io_FIXED_IO_ddr_vrp,
     inout  [53:0] io_FIXED_IO_mio,
     inout         io_FIXED_IO_ps_clk,
     inout         io_FIXED_IO_ps_porb,
     inout         io_FIXED_IO_ps_srstb
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
    localparam [3:0] WDT = 4'h8;
    localparam [3:0] IRQ = 4'hF;
    localparam [3:0] PS2 = 4'h5;
    localparam [3:0] VGA = 4'h6;

/****************************************************************************
 * 1.2 DECLARE WIRES / REGS
 ***************************************************************************/
    wire _sel_timer0;
    wire _sel_timer1;
    wire _sel_pario;
    wire _sel_uart;
    wire _sel_i2c;
    wire _sel_irq;
    wire _sel_wdt;

    wire _timer0_rdy;
    wire _timer1_rdy;
    wire _pario_rdy;
    wire _uart_rdy;
    wire _i2c_rdy;
    wire _irq_rdy;
    wire _wdt_rdy;

    wire _timer0_int_req;
    wire _timer1_int_req;
    wire _pario_int_req;
    wire _uart_int_req;
    wire _i2c_int_req;
    wire _wdt_int_req;

    wire [7:0] _int_cause;

    wire [15:0] _timer0_rdata;
    wire [15:0] _timer1_rdata;
    wire [15:0] _pario_rdata;
    wire [15:0] _uart_rdata;
    wire [15:0] _i2c_rdata;
    wire [15:0] _irq_rdata;
    wire [15:0] _wdt_rdata;
    wire _sel_ps2;
    wire _sel_vga;
    
    wire _ps2_rdy;
    wire _vga_rdy;
    
    wire _ps2_int_req;
    
    wire [15:0] _ps2_rdata;
    wire [15:0] _vga_rdata;
// PS/2 to VGA bridge wires
    wire [7:0] _ps2_rx_data;
    wire       _ps2_rx_valid;
    wire [7:0] _ascii_code;
    wire       _ascii_valid;

    

/****************************************************************************
 * 1.2 DEFINE INTERRUPT SOURCE LINES
 ***************************************************************************/
    localparam integer _irq_timer0 = 0;
    localparam integer _irq_timer1 = 1;
    localparam integer _irq_pario = 2;
    localparam integer _irq_uart = 3;
    localparam integer _irq_i2c = 4;
    localparam integer _irq_wdt = 5;

/****************************************************************************
 * 1.3 DEFINE UART BAUDRATE
 ***************************************************************************/

`ifdef SIM
    localparam integer BAUDRATE_UART = 2_000_000;
`else
    localparam integer BAUDRATE_UART = 115200;
`endif
localparam integer _irq_ps2 = 6; // Moved to IRQ 6 to avoid WDT clash

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

/****************************************************************************
 * 2.1 Peripheral Select Decode
 ***************************************************************************/
    assign _sel_ps2 = i_sel && (i_addr[11:8] == PS2);
    assign _sel_vga = i_sel && (i_addr[11:8] == VGA);
    assign _sel_timer0 = i_sel && (i_addr[11:8] == TIMER0);
    assign _sel_timer1 = i_sel && (i_addr[11:8] == TIMER1);
    assign _sel_pario = i_sel && (i_addr[11:8] == PARIO);
    assign _sel_uart = i_sel && (i_addr[11:8] == UART);
    assign _sel_i2c = i_sel && (i_addr[11:8] == I2C);
    assign _sel_irq = i_sel && (i_addr[11:8] == IRQ);
    assign _sel_wdt = i_sel && (i_addr[11:8] == WDT);

// _int_cause register
//  BIT 7 6 5  4   3     2   1  0
//  SRC - - - I2C UART PARIO T0 T1
    assign _int_cause[_irq_timer0] = _timer0_int_req;
    assign _int_cause[_irq_timer1] = _timer1_int_req;
    assign _int_cause[_irq_pario] = _pario_int_req;
    assign _int_cause[_irq_uart] = _uart_int_req;
    assign _int_cause[_irq_i2c] = _i2c_int_req;
    assign _int_cause[_irq_wdt] = _wdt_int_req;
    assign _int_cause[_irq_ps2] = _ps2_int_req;
    
    //assign _int_cause[7] = 2'b000;
    assign _int_cause[7] = 1'b0;

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
        .i_wdata(i_wdata[7:0]),
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
    
    wdt u_wdt (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_rst_ext(i_rst_ext),
        .i_sel(_sel_wdt),
        .i_we(i_we),
        .i_re(i_re),
        .i_addr(i_addr[2:1]),
        .i_wdata(i_wdata),
        .o_rdata(_wdt_rdata),
        .o_rdy(_wdt_rdy),
        .o_int_req(_wdt_int_req),
        .o_rst_req(o_wdt_rst) 
    );
    ps2_mmio u_ps2 (
            .i_clk       (i_clk),
            .i_rst       (i_rst),
            .i_sel       (_sel_ps2),
            .i_we        (i_we),
            .i_re        (i_re),
            .i_addr      (i_addr[2:1]),
            .i_wdata     (i_wdata),
            .o_rdata     (_ps2_rdata),
            .o_rdy       (_ps2_rdy),
            .o_rx_data   (_ps2_rx_data),
            .o_rx_valid  (_ps2_rx_valid),
            .io_ps2_clk  (io_ps2_clk),
            .io_ps2_data (io_ps2_data),
            .o_irq_req   (_ps2_int_req)
        );
    
        ps2_to_ascii_filter u_ps2_filter (
            .i_clk         (i_clk),
            .i_rst         (i_rst),
            .i_scancode    (_ps2_rx_data),
            .i_valid       (_ps2_rx_valid),
            .o_ascii       (_ascii_code),
            .o_ascii_valid (_ascii_valid)
        );
    
        m_vga_mmio u_vga (
            .i_clkSystem  (i_clk),
            .i_clkVGA     (i_clkVGA),
            .i_rst        (i_rst),
            .i_sel        (_sel_vga),
            .i_we         (i_we),
            .i_re         (i_re),
            .i_addr       (i_addr[2:1]),
            .i_wdata      (i_wdata),
            .i_ascii_code (_ascii_code),
            .i_ascii_valid(_ascii_valid),
            .o_rdata      (_vga_rdata),
            .o_rdy        (_vga_rdy),
            .o_vga_red    (o_vga_red),
            .o_vga_green  (o_vga_green),
            .o_vga_blue   (o_vga_blue),
            .o_hsync      (o_hsync),
            .o_vsync      (o_vsync),
            .i_mode_switch(i_mode_switch),
            .i_img_switch (i_img_switch),
            .io_DDR_addr          (io_DDR_addr),
            .io_DDR_ba            (io_DDR_ba),
            .io_DDR_cas_n         (io_DDR_cas_n),
            .io_DDR_ck_n          (io_DDR_ck_n),
            .io_DDR_ck_p          (io_DDR_ck_p),
            .io_DDR_cke           (io_DDR_cke),
            .io_DDR_cs_n          (io_DDR_cs_n),
            .io_DDR_dm            (io_DDR_dm),
            .io_DDR_dq            (io_DDR_dq),
            .io_DDR_dqs_n         (io_DDR_dqs_n),
            .io_DDR_dqs_p         (io_DDR_dqs_p),
            .io_DDR_odt           (io_DDR_odt),
            .io_DDR_ras_n         (io_DDR_ras_n),
            .io_DDR_reset_n       (io_DDR_reset_n),
            .io_DDR_we_n          (io_DDR_we_n),
            .io_FIXED_IO_ddr_vrn  (io_FIXED_IO_ddr_vrn),
            .io_FIXED_IO_ddr_vrp  (io_FIXED_IO_ddr_vrp),
            .io_FIXED_IO_mio      (io_FIXED_IO_mio),
            .io_FIXED_IO_ps_clk   (io_FIXED_IO_ps_clk),
            .io_FIXED_IO_ps_porb  (io_FIXED_IO_ps_porb),
            .io_FIXED_IO_ps_srstb (io_FIXED_IO_ps_srstb)
        );

/****************************************************************************
 * 2.3 Return Muxes
 ***************************************************************************/
    assign o_rdy = _sel_timer0 ? _timer0_rdy :
                    (_sel_timer1 ? _timer1_rdy :
                    (_sel_pario ? _pario_rdy :
                    (_sel_uart ? _uart_rdy :
                    (_sel_i2c ? _i2c_rdy :
                    (_sel_ps2 ? _ps2_rdy :          // <--- ADDED
                    (_sel_vga ? _vga_rdy :          // <--- ADDED
                    (_sel_wdt ? _wdt_rdy :
                    (_sel_irq ? _irq_rdy : 1'b1))))))));
 
     assign o_rdata = (_sel_timer0 && i_re) ? _timer0_rdata :
                      ((_sel_timer1 && i_re) ? _timer1_rdata :
                      ((_sel_pario && i_re) ? _pario_rdata :
                      ((_sel_uart && i_re) ? _uart_rdata :
                      ((_sel_i2c && i_re) ? _i2c_rdata :
                      ((_sel_ps2 && i_re) ? _ps2_rdata :       // <--- ADDED
                      ((_sel_vga && i_re) ? _vga_rdata :       // <--- ADDED
                      ((_sel_wdt && i_re) ? _wdt_rdata :
                      ((_sel_irq && i_re) ? _irq_rdata : 16'h0000))))))));

endmodule
