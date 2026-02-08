`timescale 1ns / 1ps

`include "constants.vh"

module soc(
    input wire i_clk,
    input wire i_rst,
    input wire [3:0] i_par_i,
    output wire [3:0] o_par_o,
    input wire i_uart_rx,
    output wire o_uart_tx
);

/*************************************************************************************
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/
    localparam [15:0] _default_nop = `CPU_NOP_INSN;
    localparam [15:0] _reset_vec = `CPU_RESET_VEC;

    wire _insn_ce;
    wire [15:0] _i_ad;
    wire _hit;

    (* mark_debug = "true" *) wire [15:0] _d_ad;
    wire _sw;
    wire _sb;
    wire _lw;
    wire _lb;

    (* mark_debug = "true" *) wire [15:0] _cpu_do;
    (* mark_debug = "true" *) wire [15:0] _cpu_di;

    wire [7:0] _imem_dout_h;
    wire [7:0] _imem_dout_l;
    wire [7:0] _dmem_dout_h;
    wire [7:0] _dmem_dout_l;

    wire [15:0] _i_ad_rst;

    (* mark_debug = "true" *) reg [15:0] _insn_q;
    wire _br_taken;

    (* mark_debug = "true" *) wire [15:0] _imem_dout;
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

    wire _irq_take;
    wire [15:0] _irq_vector;
    wire _in_irq;
    wire _int_en_cpu;
    wire _iret_detected;

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

/*************************************************************************************
 * 2.1 Static Assignments
 ************************************************************************************/
    assign _hit = ~i_rst;
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
            if (_br_taken) begin
                _insn_q <= _default_nop;
            end
        end
    end

/*************************************************************************************
 * 2.3 Load Ready Tracking
 ************************************************************************************/
    always @(posedge i_clk) begin
        if (i_rst) begin
            _loaded <= 1'b0;
        end else if (_insn_ce) begin
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
 * 2.5 CPU, BRAM, and Peripheral Instances
 ************************************************************************************/
    cpu u_cpu (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_i_ad_rst(_i_ad_rst),
        .o_insn_ce(_insn_ce),
        .o_i_ad(_i_ad),
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

    bram_1kb_be u_mem (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_a_en(_insn_ce),
        .i_a_addr(_i_ad[9:1]),
        .o_a_dout_h(_imem_dout_h),
        .o_a_dout_l(_imem_dout_l),
        .i_b_en(_sw | _sb | _lw | _lb),
        .i_b_addr(_d_ad[9:1]),
        .i_b_we_h(_mem_we_h),
        .i_b_we_l(_mem_we_l),
        .i_b_din_h(_mem_din_h),
        .i_b_din_l(_mem_din_l),
        .o_b_dout_h(_dmem_dout_h),
        .o_b_dout_l(_dmem_dout_l)
    );

    periph_bus u_periph (
        .i_clk(i_clk),
        .i_rst(i_rst),
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
        .i_int_en(_int_en_cpu),
        .i_in_irq(_in_irq),
        .o_irq_vector(_irq_vector),
        .o_irq_take(_irq_take),
        .i_irq_ret(_iret_detected)
    );

endmodule
