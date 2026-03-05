`timescale 1ns / 1ps
`default_nettype none

`include "constants.vh"

module tb_pipe_imm_prefix_irq_clear;

/*************************************************************************************
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/
    reg _clk = 1'b0;
    reg _rst = 1'b1;

    reg [15:0] _insn;
    reg _irq_take = 1'b0;

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

    reg _seen_prefix = 1'b0;
    reg _seen_accept = 1'b0;
    reg _imm_not_cleared_after_accept = 1'b0;
    reg _accept_d1 = 1'b0;

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

/*************************************************************************************
 * 2.1 Helpers and DUT
 ************************************************************************************/
    function [15:0] enc_imm;
        input [11:0] i_i12;
        begin
            enc_imm = {`OP_IMM, i_i12};
        end
    endfunction

    function [15:0] enc_rri;
        input [3:0] i_op;
        input [3:0] i_rd;
        input [3:0] i_rs;
        input [3:0] i_imm;
        begin
            enc_rri = {i_op, i_rd, i_rs, i_imm};
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
        .i_irq_take(_irq_take),
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
            16'h0100: _insn = enc_imm(12'hABC);
            16'h0102: _insn = `CPU_NOP_INSN;
            16'h0104: _insn = enc_rri(`OP_ADDI, 4'h2, 4'h0, 4'h2);
            16'h0106: _insn = enc_rri(`OP_ADDI, 4'h2, 4'h0, 4'h2);
            16'h0020: _insn = `CPU_IRET_INSN;
            default:  _insn = `CPU_NOP_INSN;
        endcase
    end

    always @(posedge _clk) begin
        if (_rst) begin
            _accept_d1 <= 1'b0;
        end else begin
            _accept_d1 <= dut._accept_irq;

            if (dut._imm_pre_state) begin
                _seen_prefix <= 1'b1;
            end

            if (dut._accept_irq) begin
                _seen_accept <= 1'b1;
            end

            if (_accept_d1 && dut._imm_pre_state) begin
                _imm_not_cleared_after_accept <= 1'b1;
            end
        end
    end

    initial begin
        repeat (3) @(posedge _clk);
        _rst = 1'b0;

        wait (_seen_prefix == 1'b1);

        _irq_take = 1'b1;
        wait (_seen_accept == 1'b1);
        _irq_take = 1'b0;

        repeat (80) @(posedge _clk);

        if (!_seen_prefix) begin
            $display("FAIL tb_pipe_imm_prefix_irq_clear: IMM prefix state was never observed");
            $fatal(1);
        end

        if (!_seen_accept) begin
            $display("FAIL tb_pipe_imm_prefix_irq_clear: IRQ accept was never observed");
            $fatal(1);
        end

        if (_imm_not_cleared_after_accept) begin
            $display("FAIL tb_pipe_imm_prefix_irq_clear: imm_pre_state remained set after IRQ accept");
            $fatal(1);
        end

        $display("PASS tb_pipe_imm_prefix_irq_clear");
        $finish;
    end

endmodule
