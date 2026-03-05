`timescale 1ns / 1ps
`default_nettype none

`include "constants.vh"

module tb_pipe_carry_dependency;

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

    reg _seen_adc_stall = 1'b0;

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

    function [15:0] enc_imm;
        input [11:0] i_i12;
        begin
            enc_imm = {`OP_IMM, i_i12};
        end
    endfunction

    function [15:0] enc_ri;
        input [3:0] i_rd;
        input [3:0] i_fn;
        input [3:0] i_imm;
        begin
            enc_ri = {`OP_RI, i_rd, i_fn, i_imm};
        end
    endfunction

    function [15:0] enc_sys;
        input [3:0] i_rd;
        input [3:0] i_rs;
        input [3:0] i_fn;
        begin
            enc_sys = {`OP_SYS, i_rd, i_rs, i_fn};
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
            16'h0100: _insn = enc_imm(12'h001);                          // upper immediate => 0x0010
            16'h0102: _insn = enc_rri(`OP_ADDI, 4'h4, 4'h0, 4'h0);      // r4=0x0010
            16'h0104: _insn = enc_sys(4'h0, 4'h4, `FN_SETCC);           // carry=1 (from r4[4])
            16'h0106: _insn = enc_ri(4'h2, `FN_ADC, 4'h0);              // r2=carry -> 1
            16'h0108: _insn = `CPU_NOP_INSN;                            // valid insn resets carry to 0 in current design
            16'h010A: _insn = enc_ri(4'h3, `FN_ADC, 4'h0);              // r3=carry -> 0
            default:  _insn = `CPU_NOP_INSN;
        endcase
    end

    always @(posedge _clk) begin
        if (!_rst) begin
            if (dut._stall_id && (dut._ifid_insn[15:12] == `OP_RI) && (dut._ifid_insn[7:4] == `FN_ADC)) begin
                _seen_adc_stall <= 1'b1;
            end
        end
    end

    initial begin
        repeat (3) @(posedge _clk);
        _rst = 1'b0;

        repeat (140) @(posedge _clk);

        if (!_seen_adc_stall) begin
            $display("FAIL tb_pipe_carry_dependency: expected ADC stall due carry dependency");
            $fatal(1);
        end

        if (dut.u_regfile._a1 !== 16'h0001) begin
            $display("FAIL tb_pipe_carry_dependency: r2 expected 0x0001 got 0x%04h", dut.u_regfile._a1);
            $fatal(1);
        end

        if (dut.u_regfile._a2 !== 16'h0000) begin
            $display("FAIL tb_pipe_carry_dependency: r3 expected 0x0000 got 0x%04h", dut.u_regfile._a2);
            $fatal(1);
        end

        $display("PASS tb_pipe_carry_dependency");
        $finish;
    end

endmodule
