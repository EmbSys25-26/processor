`timescale 1ns / 1ps
`default_nettype none

`include "constants.vh"

module tb_pipe_branch_flush;

/*************************************************************************************
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/
    reg _clk = 1'b0;
    reg _rst = 1'b1;

    reg [15:0] _insn;

    wire _insn_ce;
    wire [15:0] _i_ad;
    wire [15:0] _d_ad;
    wire _sw;
    wire _sb;
    wire _lw;
    wire _lb;
    wire [15:0] _data_out;
    wire _in_irq;
    wire _int_en;
    wire _iret_detected;
    wire _br_taken;

    reg _seen_flush = 1'b0;

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

/*************************************************************************************
 * 2.1 Helpers and DUT
 ************************************************************************************/
    function [15:0] enc_rri;
        input [3:0] i_op;
        input [3:0] i_rd;
        input [3:0] i_rs;
        input [3:0] i_imm;
        begin
            enc_rri = {i_op, i_rd, i_rs, i_imm};
        end
    endfunction

    function [15:0] enc_bx;
        input [3:0] i_cond;
        input [7:0] i_disp;
        begin
            enc_bx = {`OP_BX, i_cond, i_disp};
        end
    endfunction

    always #5 _clk = ~_clk;

    cpu dut (
        .i_clk(_clk),
        .i_rst(_rst),
        .i_i_ad_rst(16'h0100),
        .o_insn_ce(_insn_ce),
        .o_i_ad(_i_ad),
        .i_insn(_insn),
        .i_hit(1'b1),
        .o_d_ad(_d_ad),
        .i_rdy(1'b1),
        .o_sw(_sw),
        .o_sb(_sb),
        .o_lw(_lw),
        .o_lb(_lb),
        .o_data_out(_data_out),
        .i_data_in(16'h0000),
        .i_irq_take(1'b0),
        .i_irq_vector(16'h0020),
        .o_in_irq(_in_irq),
        .o_int_en(_int_en),
        .o_iret_detected(_iret_detected),
        .o_br_taken(_br_taken)
    );

/*************************************************************************************
 * 2.2 Program and Checks
 ************************************************************************************/
    always @(*) begin
        case (_i_ad)
            16'h0100: _insn = enc_bx(`BR_BR, 8'h02);
            16'h0102: _insn = enc_rri(`OP_ADDI, 4'h1, 4'h0, 4'hF);
            16'h0104: _insn = enc_rri(`OP_ADDI, 4'h1, 4'h0, 4'h1);
            16'h0106: _insn = enc_rri(`OP_ADDI, 4'h1, 4'h0, 4'h1);
            16'h0108: _insn = enc_rri(`OP_ADDI, 4'h1, 4'h0, 4'h1);
            default:  _insn = `CPU_NOP_INSN;
        endcase
    end

    always @(posedge _clk) begin
        if (!_rst && dut._flush_ifid) begin
            _seen_flush <= 1'b1;
        end
    end

    initial begin
        repeat (3) @(posedge _clk);
        _rst = 1'b0;

        repeat (40) @(posedge _clk);

        if (!_seen_flush) begin
            $display("FAIL tb_pipe_branch_flush: expected IF/ID flush on taken branch");
            $fatal(1);
        end

        if (dut.u_regfile._a0 !== 16'h0001) begin
            $display("FAIL tb_pipe_branch_flush: r1 expected 0x0001 got 0x%04h", dut.u_regfile._a0);
            $fatal(1);
        end

        $display("PASS tb_pipe_branch_flush");
        $finish;
    end

endmodule
