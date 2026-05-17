`timescale 1ns / 1ps

`include "constants.vh"

module soc(
    input wire i_clk,
    input wire i_rst,
    input wire [3:0] i_par_i,
    output wire [3:0] o_par_o,
    input wire i_uart_rx,
    output wire o_uart_tx,
    inout wire io_i2c_sda,
    inout wire io_i2c_scl,
    // --- ADDED FOR VGA & PS2 ---
    inout wire io_ps2_clk,
    inout wire io_ps2_data,
    output wire [3:0] o_vga_red,
    output wire [3:0] o_vga_green,
    output wire [3:0] o_vga_blue,
    output wire       o_hsync,
    output wire       o_vsync,
    input wire i_sw_1,
    input wire i_sw_0,
    // --- ADDED FOR ZYNQ PS / DDR ---
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
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/
    localparam [15:0] _default_nop = `CPU_NOP_INSN;
    localparam [15:0] _reset_vec = `CPU_RESET_VEC;

    wire _insn_ce;
    wire [15:0] _PC;
    wire _hit;

    wire [15:0] _d_ad;
    wire _sw;
    wire _sb;
    wire _lw;
    wire _lb;

    wire [15:0] _cpu_do;
    wire [15:0] _cpu_di;

    wire [7:0] _imem_dout_h;
    wire [7:0] _imem_dout_l;
    wire [7:0] _dmem_dout_h;
    wire [7:0] _dmem_dout_l;

    wire [15:0] _i_ad_rst;

    (* max_fanout = 10 *)reg [15:0] _insn_q;
    wire _br_taken;

    wire [15:0] _imem_dout;
    wire _imem_invalid;

    reg _loaded;
    wire _mem_rdy;

    wire _is_io;
    wire _byte_lane;
    wire _mem_we_h;
    wire _mem_we_l;
    wire [7:0] _mem_din_h;
    wire [7:0] _mem_din_l;
    wire [15:0] _mem_dout;
    wire [15:0] _mem_load_data;

    wire _io_sel;
    wire _io_we;
    wire _io_re;
    wire [15:0] _io_wdata;
    wire [15:0] _io_rdata;
    wire _io_rdy;

    wire _rdy;
    wire _wdt_rst_req; 
    wire _irq_take;
    wire [15:0] _irq_vector;
    wire _in_irq;
    wire _int_en_cpu;
    wire _iret_detected;

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/
`ifdef SIM
     // Simulation Clock
     wire i_clkk  = i_clk;
     wire _clkVGA = i_clk;
 `else
     wire i_clkk;
     wire _clkVGA; // 25.175 MHz for vga
     wire locked;
 
     clk_wiz_0 clk_gen (
         .clk_out1 (i_clkk),
         .clk_out2 (_clkVGA),
         .reset    (1'b0),
         .locked   (locked),
         .clk_in1  (i_clk)
     );
 `endif
/*************************************************************************************
 * 2.1 Static Assignments
 ************************************************************************************/
   // assign _hit = ~i_rst;
  
    wire _total_rst = i_rst | _wdt_rst_req; // watchdog reset or external reset
    assign _hit = ~_total_rst;
    assign _i_ad_rst = _reset_vec;

    assign _imem_dout = {_imem_dout_h, _imem_dout_l};
    assign _imem_invalid = ~|_imem_dout;

/*************************************************************************************
 * 2.2 Instruction Fetch Latch
 ************************************************************************************/
    always @(posedge i_clk) begin
        if (i_rst | _imem_invalid) begin
            _insn_q <= _default_nop;
        end else if (_insn_ce) begin
            _insn_q <= _imem_dout;
        end
    end

/*************************************************************************************
 * 2.3 Load Ready Tracking
 ************************************************************************************/
    reg _insn_ce_r;
    //RECENTLY ADDED
    always @(posedge i_clk) begin
        if (i_rst)
            _insn_ce_r <= 1'b0;
        else
            _insn_ce_r <= _insn_ce;
    end
    
    always @(posedge i_clk) begin
        if (i_rst) begin
            _loaded <= 1'b0;
        end else if (_insn_ce_r) begin
            _loaded <= 1'b0;
        end else begin
            _loaded <= (_lw | _lb);
        end
    end

    assign _mem_rdy = ~((_lw | _lb) & ~_loaded);

/*************************************************************************************
 * 2.4 Data/IO Split and Bus Muxing
 ************************************************************************************/
    assign _is_io = _d_ad[15];
    assign _byte_lane = _d_ad[1];
    assign _mem_we_h = (_sw | (_sb & ~_byte_lane)) & ~_is_io;
    assign _mem_we_l = (_sw | (_sb & _byte_lane)) & ~_is_io;

    assign _mem_din_h = _sw ? _cpu_do[15:8] : _cpu_do[7:0];
    assign _mem_din_l = _cpu_do[7:0];

    assign _mem_dout = {_dmem_dout_h, _dmem_dout_l};
    assign _mem_load_data = _lb ? (_byte_lane ? {8'h00, _dmem_dout_l} : {8'h00, _dmem_dout_h}) : _mem_dout;

    assign _io_sel = _is_io;
    assign _io_we = _is_io & (_sw | _sb);
    assign _io_re = _is_io & (_lw | _lb);
    assign _io_wdata = _cpu_do;

    assign _cpu_di = _is_io ? _io_rdata : _mem_load_data;
    assign _rdy = _is_io ? _io_rdy : _mem_rdy;

/*************************************************************************************
 * 2.5 CPU, ROM, RAM, and Peripheral Instances
 ************************************************************************************/
    cpu u_cpu (
        .i_clk(i_clkk),
        .i_rst(_total_rst),
        .i_i_ad_rst(_i_ad_rst),
        .o_insn_ce(_insn_ce),
        .o_i_ad(_PC),
        .i_insn(_insn_q),
        .i_hit(_hit),
        .o_d_ad(_d_ad),
        .i_rdy(_rdy),
        .o_sw(_sw),
        .o_sb(_sb),
        .o_lw(_lw),
        .o_lb(_lb),
        .o_data_out(_cpu_do),
        .i_data_in(_cpu_di),
        .i_irq_take(_irq_take),
        .i_irq_vector(_irq_vector),
        .o_in_irq(_in_irq),
        .o_int_en(_int_en_cpu),
        .o_iret_detected(_iret_detected),
        .o_br_taken(_br_taken)
    );

    brom_1kb_be u_rom (
        .i_clk(i_clkk),
        .i_rst(_total_rst),
        .i_en(_insn_ce),
        .i_addr(_PC[9:1]),
        .o_dout_h(_imem_dout_h),
        .o_dout_l(_imem_dout_l)
    );

    bram_1kb_be u_mem (
        .i_clk(i_clkk),
        .i_rst(_total_rst),
        .i_en(_sw | _sb | _lw | _lb),
        .i_addr(_d_ad[9:1]),
        .i_we_h(_mem_we_h),
        .i_we_l(_mem_we_l),
        .i_din_h(_mem_din_h),
        .i_din_l(_mem_din_l),
        .o_dout_h(_dmem_dout_h),
        .o_dout_l(_dmem_dout_l)
    );

    periph_bus u_periph (
            .i_clk(i_clkk), // Updated to use the clock wizard output
            .i_rst(_total_rst),
            .i_rst_ext(i_rst),   
            .i_addr(_d_ad),
            .i_sel(_io_sel),
            .i_we(_io_we),
            .i_re(_io_re),
            .i_wdata(_io_wdata),
            .o_rdata(_io_rdata),
            .o_rdy(_io_rdy),
            .i_par_i(i_par_i),
            .o_par_o(o_par_o),
            .i_uart_rx(i_uart_rx),
            .o_uart_tx(o_uart_tx),
            .io_i2c_sda(io_i2c_sda),
            .io_i2c_scl(io_i2c_scl),
            .i_int_en(_int_en_cpu),
            .i_in_irq(_in_irq),
            .o_irq_vector(_irq_vector),
            .o_irq_take(_irq_take),
            .i_irq_ret(_iret_detected),
            .o_wdt_rst(_wdt_rst_req),    
    
            // --- NEW VGA / PS2 / DDR CONNECTIONS BELOW ---
            .io_ps2_clk   (io_ps2_clk),
            .io_ps2_data  (io_ps2_data),
            .i_clkVGA     (_clkVGA),
            .o_vga_red    (o_vga_red),
            .o_vga_green  (o_vga_green),
            .o_vga_blue   (o_vga_blue),
            .o_hsync      (o_hsync),
            .o_vsync      (o_vsync),
            .i_mode_switch(i_sw_1),
            .i_img_switch(i_sw_0),
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

endmodule
