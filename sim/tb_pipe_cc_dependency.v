`timescale 1ns / 1ps
`default_nettype none

`include "constants.vh"

module tb_pipe_cc_dependency;

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

    reg _seen_cc_stall = 1'b0;

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
            16'h0100: _insn = enc_rri(`OP_ADDI, 4'h1, 4'h0, 4'h0);
            16'h0102: _insn = enc_bx(`BR_BEQ, 8'h02);
            16'h0104: _insn = enc_rri(`OP_ADDI, 4'h2, 4'h0, 4'h9);
            16'h0106: _insn = enc_rri(`OP_ADDI, 4'h3, 4'h0, 4'h1);
            16'h0108: _insn = enc_rri(`OP_ADDI, 4'h3, 4'h0, 4'h1);
            default:  _insn = `CPU_NOP_INSN;
        endcase
    end

    always @(posedge _clk) begin
        if (!_rst) begin
            if (dut._stall_id && (dut._ifid_insn[15:12] == `OP_BX)) begin
                _seen_cc_stall <= 1'b1;
            end
        end
    end

    initial begin
        repeat (3) @(posedge _clk);
        _rst = 1'b0;

        repeat (50) @(posedge _clk);

        if (!_seen_cc_stall) begin
            $display("FAIL tb_pipe_cc_dependency: expected CC interlock stall on BX");
            $fatal(1);
        end

        if (dut.u_regfile._a1 !== 16'h0000) begin
            $display("FAIL tb_pipe_cc_dependency: r2 should remain 0 when branch taken, got 0x%04h", dut.u_regfile._a1);
            $fatal(1);
        end

        if (dut.u_regfile._a2 !== 16'h0001) begin
            $display("FAIL tb_pipe_cc_dependency: r3 expected 0x0001, got 0x%04h", dut.u_regfile._a2);
            $fatal(1);
        end

        $display("PASS tb_pipe_cc_dependency");
        $finish;
    end

endmodule
