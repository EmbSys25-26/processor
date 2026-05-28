`timescale 1ns / 1ps
`default_nettype none

// =====================================================================
// test_tb.v — minimal Vivado-GUI behavioural testbench for a single C
// program built with scripts/build_c_e2e.sh.
//
// Drop this file into the pipeline Vivado project as a SIMULATION
// source (sim_1, NOT the design sources).  Set it as the simulation
// top.  See FLASHING.md in this directory for the full procedure.
//
// The codegen-emitted boot stub puts `BR _halt` at PC 0x0110 once
// main() returns; this testbench just runs the SoC for a generous
// 200k cycles and prints the final PC + a0 so you can read the answer
// from the console or the waveform.  Add more probes as needed.
// =====================================================================

module test_tb;
    reg clk = 1'b0;
    reg rst = 1'b1;

    // soc is defined in pipeline/srcs/m_soc.v
    soc dut (
        .i_clk      (clk),
        .i_rst      (rst),
        .i_par_i    (4'h0),
        .o_par_o    (),
        .i_uart_rx  (1'b1),
        .o_uart_tx  (),
        .io_i2c_sda (),
        .io_i2c_scl ()
    );

    // 100 MHz-ish clock (10 ns period).
    always #5 clk = ~clk;

    initial begin
        repeat (12) @(posedge clk);
        rst = 1'b0;

        // Run long enough for any reasonable C exercise to finish.
        repeat (200000) @(posedge clk);

        $display("test_tb done  pc=0x%04X  a0=0x%04X",
            dut.u_cpu._pc, dut.u_cpu.u_regfile._a0);
        $finish;
    end
endmodule
