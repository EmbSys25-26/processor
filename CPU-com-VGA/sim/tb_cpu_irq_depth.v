`timescale 1ns / 1ps
`default_nettype none

`include "constants.vh"

module tb_cpu_irq_depth;

/*************************************************************************************
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/
    reg _clk = 1'b0;
    reg _rst = 1'b1;

    reg [15:0] _insn = 16'h0000;
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

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

/*************************************************************************************
 * 2.1 DUT and Clock
 ************************************************************************************/
    always #5 _clk = ~_clk;

    cpu dut (
        .i_clk(_clk),
        .i_rst(_rst),
        .i_i_ad_rst(16'h0100),
        .o_insn_ce(_insn_ce),
        .o_PC(_i_ad),
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
 * 2.2 Stimulus and Checks
 ************************************************************************************/
    initial begin
        repeat (3) @(posedge _clk);
        _rst = 1'b0;

        // 1) Stray IRETs must not underflow depth.
        _insn = `CPU_IRET_INSN;
        repeat (4) @(posedge _clk);
        if (dut._irq_depth != 2'b00 || _in_irq !== 1'b0) begin
            $display("FAIL depth underflow guard: depth=%0d in_irq=%0b", dut._irq_depth, _in_irq);
            $fatal(1);
        end
        $display("WAVE depth-guard depth=%0d in_irq=%0b", dut._irq_depth, _in_irq);

        // 2) Single IRQ entry/exit.
        _irq_take = 1'b1;
        _insn = 16'hF000;
        @(posedge _clk);
        _irq_take = 1'b0;
        @(posedge _clk);
        if (dut._irq_depth != 2'b01 || _in_irq !== 1'b1) begin
            $display("FAIL single irq enter: depth=%0d in_irq=%0b", dut._irq_depth, _in_irq);
            $fatal(1);
        end
        $display("WAVE single-enter depth=%0d in_irq=%0b", dut._irq_depth, _in_irq);

        _insn = `CPU_IRET_INSN;
        @(posedge _clk);
        @(posedge _clk);
        if (dut._irq_depth != 2'b00 || _in_irq !== 1'b0) begin
            $display("FAIL single irq exit: depth=%0d in_irq=%0b", dut._irq_depth, _in_irq);
            $fatal(1);
        end
        $display("WAVE single-exit depth=%0d in_irq=%0b", dut._irq_depth, _in_irq);

        // 3) Nested entry and ordered exits.
        _insn = 16'hF000;
        _irq_take = 1'b1;
        @(posedge _clk);
        _irq_take = 1'b0;
        @(posedge _clk);

        _irq_take = 1'b1;
        @(posedge _clk);
        _irq_take = 1'b0;
        @(posedge _clk);

        if (dut._irq_depth != 2'b10 || _in_irq !== 1'b1) begin
            $display("FAIL nested enter: depth=%0d in_irq=%0b", dut._irq_depth, _in_irq);
            $fatal(1);
        end
        $display("WAVE nested-enter depth=%0d in_irq=%0b", dut._irq_depth, _in_irq);

        _insn = `CPU_IRET_INSN;
        @(posedge _clk);
        @(posedge _clk);
        if (dut._irq_depth != 2'b01 || _in_irq !== 1'b1) begin
            $display("FAIL nested exit #1: depth=%0d in_irq=%0b", dut._irq_depth, _in_irq);
            $fatal(1);
        end

        @(posedge _clk);
        @(posedge _clk);
        if (dut._irq_depth != 2'b00 || _in_irq !== 1'b0) begin
            $display("FAIL nested exit #2: depth=%0d in_irq=%0b", dut._irq_depth, _in_irq);
            $fatal(1);
        end
        $display("WAVE nested-exit depth=%0d in_irq=%0b", dut._irq_depth, _in_irq);

        $display("PASS tb_cpu_irq_depth");
        $finish;
    end

endmodule
