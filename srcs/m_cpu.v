`timescale 1ns / 1ps

`include "constants.vh"

module cpu(
    input wire i_clk,
    input wire i_rst,
    input wire [15:0] i_i_ad_rst,
    output wire o_insn_ce,
    output wire [15:0] o_i_ad,
    input wire [15:0] i_insn,
    input wire i_hit,
    output wire [15:0] o_d_ad,
    input wire i_rdy,
    output wire o_sw,
    output wire o_sb,
    output wire o_lw,
    output wire o_lb,
    output wire [15:0] o_data_out,
    input wire [15:0] i_data_in,
    input wire i_irq_take,
    input wire [15:0] i_irq_vector,
    output wire o_in_irq,
    output wire o_int_en,
    output wire o_iret_detected,
    output wire o_br_taken
);

/*************************************************************************************
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/
    reg [1:0] _irq_depth;
    reg [1:0] _irq_depth_n;
    reg _in_irq;

    wire [3:0] _rd;
    wire [3:0] _rs;
    wire [3:0] _imm;
    wire [7:0] _disp;
    wire _imm_pre;
    wire [11:0] _i12_pre;
    wire _rf_we;
    wire _ccz;
    wire _ccn;
    wire _ccc;
    wire _ccv;
    wire _irq_save;
    wire _restore_cc;
    wire _exec_ce;
    wire _is_jal;
    wire _is_addi;
    wire _is_rr;
    wire _is_ri;
    wire _is_lw;
    wire _is_lb;
    wire _is_sw;
    wire _is_alu;
    wire _is_sub;
    wire _is_xor;
    wire _is_adc;
    wire _is_sbc;
    wire _is_cmp;
    wire _is_sra;
    wire _is_sum;
    wire _is_log;
    wire _is_sr;
    wire _is_getcc;

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

/*************************************************************************************
 * 2.1 IRQ Depth Tracking
 ************************************************************************************/
    always @(*) begin
        _irq_depth_n = _irq_depth;
        case ({i_irq_take, o_iret_detected})
            2'b10: begin
                if (_irq_depth != 2'b11) begin
                    _irq_depth_n = _irq_depth + 2'd1;
                end
            end
            2'b01: begin
                if (_irq_depth != 2'b00) begin
                    _irq_depth_n = _irq_depth - 2'd1;
                end
            end
            2'b11: _irq_depth_n = _irq_depth;
            default: ;
        endcase
    end

    always @(posedge i_clk) begin
        if (i_rst) begin
            _irq_depth <= 2'b00;
            _in_irq <= 1'b0;
        end else begin
            _irq_depth <= _irq_depth_n;
            _in_irq <= (_irq_depth_n != 2'b00);
        end
    end

    assign o_in_irq = _in_irq;

/*************************************************************************************
 * 2.2 Control Unit
 ************************************************************************************/
    ctrl_unit u_ctrl (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_insn(i_insn),
        .i_hit(i_hit),
        .i_rdy(i_rdy),
        .i_ccz(_ccz),
        .i_ccn(_ccn),
        .i_ccc(_ccc),
        .i_ccv(_ccv),
        .i_irq_take(i_irq_take),
        .o_irq_save(_irq_save),
        .o_rd(_rd),
        .o_rs(_rs),
        .o_imm(_imm),
        .o_disp(_disp),
        .o_insn_ce(o_insn_ce),
        .o_imm_pre(_imm_pre),
        .o_i12_pre(_i12_pre),
        .o_rf_we(_rf_we),
        .o_lw(o_lw),
        .o_lb(o_lb),
        .o_sw(o_sw),
        .o_sb(o_sb),
        .o_int_en(o_int_en),
        .o_br_taken(o_br_taken),
        .o_iret_detected(o_iret_detected),
        .o_valid_insn_ce(),
        .o_exec_ce(_exec_ce),
        .o_restore_cc(_restore_cc),
        .o_is_jal(_is_jal),
        .o_is_addi(_is_addi),
        .o_is_rr(_is_rr),
        .o_is_ri(_is_ri),
        .o_is_lw(_is_lw),
        .o_is_lb(_is_lb),
        .o_is_sw(_is_sw),
        .o_is_alu(_is_alu),
        .o_is_sub(_is_sub),
        .o_is_xor(_is_xor),
        .o_is_adc(_is_adc),
        .o_is_sbc(_is_sbc),
        .o_is_cmp(_is_cmp),
        .o_is_sra(_is_sra),
        .o_is_sum(_is_sum),
        .o_is_log(_is_log),
        .o_is_sr(_is_sr),
        .o_is_getcc(_is_getcc)
    );

/*************************************************************************************
 * 2.3 Datapath
 ************************************************************************************/
    datapath u_datapath (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_hit(i_hit),
        .i_exec_ce(_exec_ce),
        .i_i_ad_rst(i_i_ad_rst),
        .i_rd(_rd),
        .i_rs(_rs),
        .i_imm(_imm),
        .i_disp(_disp),
        .i_imm_pre(_imm_pre),
        .i_i12_pre(_i12_pre),
        .i_rf_we(_rf_we),
        .i_br_taken(o_br_taken),
        .i_irq_take(i_irq_take),
        .i_irq_save(_irq_save),
        .i_irq_vector(i_irq_vector),
        .i_restore_cc(_restore_cc),
        .i_is_jal(_is_jal),
        .i_is_addi(_is_addi),
        .i_is_rr(_is_rr),
        .i_is_ri(_is_ri),
        .i_is_lw(_is_lw),
        .i_is_lb(_is_lb),
        .i_is_sw(_is_sw),
        .i_is_alu(_is_alu),
        .i_is_sub(_is_sub),
        .i_is_xor(_is_xor),
        .i_is_adc(_is_adc),
        .i_is_sbc(_is_sbc),
        .i_is_cmp(_is_cmp),
        .i_is_sra(_is_sra),
        .i_is_sum(_is_sum),
        .i_is_log(_is_log),
        .i_is_sr(_is_sr),
        .i_is_getcc(_is_getcc),
        .i_data_in(i_data_in),
        .o_data_out(o_data_out),
        .o_i_ad(o_i_ad),
        .o_d_ad(o_d_ad),
        .o_ccz(_ccz),
        .o_ccn(_ccn),
        .o_ccc(_ccc),
        .o_ccv(_ccv)
    );

endmodule
