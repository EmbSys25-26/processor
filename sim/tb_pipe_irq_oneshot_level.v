`timescale 1ns / 1ps
`default_nettype none

`include "constants.vh"

module tb_pipe_irq_oneshot_level;

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

    integer _accept_count_phase1 = 0;
    integer _accept_count_phase2 = 0;
    reg [1:0] _phase = 2'd0;

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

/*************************************************************************************
 * 2.1 DUT
 ************************************************************************************/
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
            16'h0020: _insn = `CPU_IRET_INSN;
            16'h0022: _insn = `CPU_IRET_INSN;
            16'h0024: _insn = `CPU_IRET_INSN;
            default:  _insn = `CPU_NOP_INSN;
        endcase
    end

    always @(posedge _clk) begin
        if (!_rst && dut._accept_irq) begin
            if (_phase == 2'd1) begin
                _accept_count_phase1 <= _accept_count_phase1 + 1;
            end else if (_phase == 2'd2) begin
                _accept_count_phase2 <= _accept_count_phase2 + 1;
            end
        end
    end

    initial begin
        repeat (3) @(posedge _clk);
        _rst = 1'b0;

        // Phase 1: keep IRQ high continuously.
        _phase = 2'd1;
        _irq_take = 1'b1;
        repeat (30) @(posedge _clk);
        _irq_take = 1'b0;

        // Gap to clear oneshot latch.
        repeat (6) @(posedge _clk);

        // Phase 2: assert again, expect one more accept.
        _phase = 2'd2;
        _irq_take = 1'b1;
        repeat (24) @(posedge _clk);
        _irq_take = 1'b0;

        repeat (20) @(posedge _clk);

        if (_accept_count_phase1 != 1) begin
            $display("FAIL tb_pipe_irq_oneshot_level: expected exactly 1 accept in phase1, got %0d", _accept_count_phase1);
            $fatal(1);
        end

        if (_accept_count_phase2 != 1) begin
            $display("FAIL tb_pipe_irq_oneshot_level: expected exactly 1 accept in phase2, got %0d", _accept_count_phase2);
            $fatal(1);
        end

        $display("PASS tb_pipe_irq_oneshot_level");
        $finish;
    end

endmodule
