`timescale 1ns / 1ps
`default_nettype none

`include "constants.vh"

module tb_pipe_irq_branch_priority;

/*************************************************************************************
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/
    reg _clk = 1'b0;
    reg _rst = 1'b1;

    reg [15:0] _insn;

    wire _irq_take;
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

    reg _seen_conflict = 1'b0;
    reg _seen_branch_suppressed = 1'b0;
    reg _seen_vector = 1'b0;

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

    // Assert IRQ exactly while branch is in ID.
    assign _irq_take = (!_rst && dut._id_valid && dut._id_is_bx);

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
            16'h0100: _insn = enc_bx(`BR_BR, 8'h02);
            16'h0102: _insn = enc_rri(`OP_ADDI, 4'h1, 4'h0, 4'hF);
            16'h0104: _insn = enc_rri(`OP_ADDI, 4'h2, 4'h0, 4'h1);
            16'h0020: _insn = `CPU_IRET_INSN;
            default:  _insn = `CPU_NOP_INSN;
        endcase
    end

    always @(posedge _clk) begin
        if (!_rst) begin
            if (dut._id_valid && dut._id_is_bx && dut._accept_irq) begin
                _seen_conflict <= 1'b1;
                if (!dut._branch_take_commit) begin
                    _seen_branch_suppressed <= 1'b1;
                end
            end
            if (_i_ad == 16'h0020) begin
                _seen_vector <= 1'b1;
            end
        end
    end

    initial begin
        repeat (3) @(posedge _clk);
        _rst = 1'b0;

        repeat (80) @(posedge _clk);

        if (!_seen_conflict) begin
            $display("FAIL tb_pipe_irq_branch_priority: did not observe branch/IRQ conflict window");
            $fatal(1);
        end

        if (!_seen_branch_suppressed) begin
            $display("FAIL tb_pipe_irq_branch_priority: branch was not suppressed when IRQ accepted");
            $fatal(1);
        end

        if (!_seen_vector) begin
            $display("FAIL tb_pipe_irq_branch_priority: did not fetch IRQ vector after conflict");
            $fatal(1);
        end

        $display("PASS tb_pipe_irq_branch_priority");
        $finish;
    end

endmodule
