`timescale 1ns / 1ps
`default_nettype none

// =================================================================
// tb_c_e2e — generic execution testbench for C-compiled programs.
//
// Loads a 16-bit BROM hex pair into the SoC, runs main(), and checks
// the return value against an expected constant.  The compiler emits
// a boot stub at PC 0x100 (CLI + sp init + CALL main + halt-loop);
// main's RET lands the CPU in `BR _halt` at PC 0x0110, which the
// testbench detects by watching for `_pc == 0x0110` 8 cycles running.
// At that point a0 holds main's return value.
//
// Verilog +defines (set via xvlog -d):
//   EXPECT_A0 = 16'hXXXX   expected return value (required for PASS)
//   TEST_NAME = "<str>"    name in the result line
//   MAX_CYC   = <int>      cycle cap before declaring TIMEOUT
//   BROM_MEM_LO_PATH       absolute path to <stem>_lo.hex
//   BROM_MEM_HI_PATH       absolute path to <stem>_hi.hex
//   GHR_W, BPU_ENTRIES, BPU_IDX_W, BPU_TAG_W — BPU geometry
//   DUMP_CYC = <int>       optional: dump cycle-by-cycle state up to N
// =================================================================

`ifndef EXPECT_A0
    `define EXPECT_A0 16'hDEAD
`endif
`ifndef MAX_CYC
    `define MAX_CYC 50000
`endif
`ifndef TEST_NAME
    `define TEST_NAME "c_e2e"
`endif

module tb_c_e2e;
    reg _clk = 1'b0;
    reg _rst = 1'b1;
    soc dut (.i_clk(_clk),.i_rst(_rst),.i_par_i(4'h0),.o_par_o(),
             .i_uart_rx(1'b1),.o_uart_tx(),.io_i2c_sda(),.io_i2c_scl());
    always #5 _clk = ~_clk;
    initial begin
        repeat (12) @(posedge _clk); _rst = 1'b0;
    end

    // Boot stub layout (emitted by codegen):
    //   0x100 CLI       (mask IRQs)
    //   0x102 NOP       (CLI hazard guard)
    //   0x104 IMM       (LI sp, 0x01FE — high half)
    //   0x106 ADDI sp   (LI sp, 0x01FE — low half;  sp = 0x01FE)
    //   0x108 NOP       (LI consumer hazard guard)
    //   0x10A IMM main  (CALL high half)
    //   0x10C JAL lr    (CALL low half — lr <- 0x110)
    //   0x10E NOP       (CALL delay slot)
    //   0x110 BR _halt  (self-loop, runs forever after main returns)
    localparam [15:0] HALT_PC = 16'h0110;

    reg _main_returned = 1'b0;
    reg [15:0] _final_a0 = 16'hxxxx;
    integer _return_cyc = -1;
    integer _halt_streak = 0;
    integer cyc = 0;

    always @(posedge _clk) if (!_rst) begin
        cyc = cyc + 1;
`ifdef DUMP_CYC
        if (cyc < `DUMP_CYC)
            $display("cyc=%0d pc=%h insn=%h id_fire=%b is_jal=%b is_iret=%b is_cli=%b gie=%b accept_irq=%b sp=%h lr=%h a0=%h redirect=%b",
                cyc, dut.u_cpu._pc, dut.u_cpu._ifid_insn,
                dut.u_cpu._id_fire, dut.u_cpu._id_is_jal, dut.u_cpu._id_is_iret,
                dut.u_cpu._id_is_cli, dut.u_cpu._gie, dut.u_cpu._accept_irq,
                dut.u_cpu.u_regfile._sp, dut.u_cpu.u_regfile._lr, dut.u_cpu.u_regfile._a0,
                dut.u_cpu._redirect);
`endif
        if (dut.u_cpu._pc == HALT_PC) begin
            _halt_streak = _halt_streak + 1;
        end else begin
            _halt_streak = 0;
        end
        if (!_main_returned && _halt_streak >= 8) begin
            _main_returned <= 1'b1;
            _final_a0      <= dut.u_cpu.u_regfile._a0;
            _return_cyc    <= cyc;
        end
    end

    initial begin
        wait (_rst == 1'b0);
        repeat (`MAX_CYC) begin
            @(posedge _clk);
            if (_main_returned) begin
                $display("E2E  %s  a0=0x%04X  expected=0x%04X  cyc=%0d",
                    `TEST_NAME, _final_a0, `EXPECT_A0, _return_cyc);
                if (_final_a0 === `EXPECT_A0)
                    $display("PASS  %s  a0 matches expected", `TEST_NAME);
                else
                    $display("FAIL  %s  a0=0x%04X != expected 0x%04X",
                        `TEST_NAME, _final_a0, `EXPECT_A0);
                $finish;
            end
        end
        $display("TIMEOUT  %s  main never returned within %0d cycles  pc=0x%04X  a0=0x%04X",
            `TEST_NAME, `MAX_CYC, dut.u_cpu._pc, dut.u_cpu.u_regfile._a0);
        $finish;
    end
    initial begin # 5000000; $display("WALL_TIMEOUT"); $finish; end
endmodule
