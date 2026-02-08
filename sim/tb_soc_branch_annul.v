`timescale 1ns / 1ps
`default_nettype none

`include "constants.vh"

module tb_soc_branch_annul;

/*************************************************************************************
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/
    reg _clk = 1'b0;
    reg _rst = 1'b1;
    reg [3:0] _par_i = 4'h0;
    reg _uart_rx = 1'b1;

    wire [3:0] _par_o;
    wire _uart_tx;

    integer _cycles = 0;
    integer _errors = 0;
    integer _annul_checks = 0;
    integer _branch_prints = 0;

    reg _seen_branch = 1'b0;
    reg _seen_branch_in_irq = 1'b0;
    reg _pending_annul_check = 1'b0;

    localparam integer _max_cycles = 8000;
    localparam integer _max_branch_prints = 20;

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

/*************************************************************************************
 * 2.1 DUT and Clock
 ************************************************************************************/
    always #5 _clk = ~_clk;

    soc dut (
        .i_clk(_clk),
        .i_rst(_rst),
        .i_par_i(_par_i),
        .o_par_o(_par_o),
        .i_uart_rx(_uart_rx),
        .o_uart_tx(_uart_tx)
    );

/*************************************************************************************
 * 2.2 Branch-Annul Monitors
 ************************************************************************************/
    always @(posedge _clk) begin
        if (_rst) begin
            _cycles <= 0;
            _errors <= 0;
            _annul_checks <= 0;
            _seen_branch <= 1'b0;
            _seen_branch_in_irq <= 1'b0;
            _pending_annul_check <= 1'b0;
        end else begin
            _cycles = _cycles + 1;

            // One cycle after any taken branch, insn_q must be annulled to NOP.
            if (_pending_annul_check) begin
                if (dut._insn_q !== `CPU_NOP_INSN) begin
                    $display("FAIL branch_annul: insn_q=0x%04h expected NOP at cycle=%0d", dut._insn_q, _cycles);
                    _errors = _errors + 1;
                end
                _annul_checks = _annul_checks + 1;
            end

            if (dut._br_taken && dut._insn_ce) begin
                _seen_branch <= 1'b1;
                if (dut._in_irq) begin
                    _seen_branch_in_irq <= 1'b1;
                end
                if (_branch_prints < _max_branch_prints) begin
                    $display("WAVE branch_annul trigger cycle=%0d in_irq=%0b i_ad=0x%04h", _cycles, dut._in_irq, dut._i_ad);
                    _branch_prints = _branch_prints + 1;
                end
            end

            _pending_annul_check <= (dut._br_taken && dut._insn_ce);

            if ((_cycles >= _max_cycles) && !_pending_annul_check) begin
                if (!_seen_branch) begin
                    $display("FAIL branch_annul: no taken branch observed");
                    _errors = _errors + 1;
                end
                if (_annul_checks == 0) begin
                    $display("FAIL branch_annul: no annul checks executed");
                    _errors = _errors + 1;
                end
                if (!_seen_branch_in_irq) begin
                    $display("WARN branch_annul: no taken branch observed while in_irq=1");
                end

                if (_errors == 0) begin
                    $display("PASS tb_soc_branch_annul checks=%0d", _annul_checks);
                end else begin
                    $display("FAIL tb_soc_branch_annul errors=%0d", _errors);
                    $fatal(1);
                end
                $finish;
            end
        end
    end

/*************************************************************************************
 * 2.3 Stimulus
 ************************************************************************************/
    initial begin
        repeat (5) @(posedge _clk);
        _rst = 1'b0;

        // Optional deterministic activity for MMIO/UART background load.
        repeat (100) @(posedge _clk);
    end

endmodule
