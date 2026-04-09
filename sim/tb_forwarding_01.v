`timescale 1ns / 1ps
`default_nettype none

// ============================================================
// tb_forwarding_01.v — self-checking testbench para forwarding_01.asm
//
// Testes cobertos:
//   TEST 1: MEM→EX dist 1 sem gap        → t1=2
//   TEST 2: MEM→EX dist 2 com 1 gap      → t1=11
//   TEST 3: dois forwards simultâneos     → t2=8, t3=5
//   TEST 4: cadeia com gaps alternados    → t0=8
//   TEST 5: SUB + CMP com 1 gap          → t0=5, Z=0, N=0
//
// Uso (iverilog):
//   iverilog -g2012 -I srcs/ -D SIM=1 -D CI=1 \
//     sim/tb_forwarding_01.v srcs/m_soc.v srcs/m_cpu.v \
//     srcs/m_ctrl_unit.v srcs/m_alu.v srcs/m_regfile16x16.v \
//     srcs/m_hazard_unit.v srcs/m_forwarding.v srcs/m_if_stage.v \
//     srcs/m_id_stage.v srcs/m_ex_stage.v srcs/m_mem_stage.v \
//     srcs/m_pipe_if_id.v srcs/m_pipe_id_ex.v srcs/m_pipe_ex_mem.v \
//     srcs/m_bdu.v srcs/m_pc_next.v srcs/m_brom.v srcs/m_bram.v \
//     srcs/m_periph_bus.v srcs/m_irq_ctrl.v srcs/m_timer16.v \
//     srcs/m_timerH.v srcs/m_pario.v srcs/m_uart_mmio.v \
//     srcs/m_uart_rx.v srcs/m_uart_tx.v srcs/m_i2c_mmio.v \
//     srcs/m_i2c_master.v srcs/m_wdt.v srcs/m_wdt_mmio.v \
//     -o tb_fwd1 && vvp tb_fwd1
// ============================================================

module tb_forwarding_01;

// ============================================================
// 1. CLOCK / RESET
// ============================================================
reg _clk = 1'b0;
reg _rst = 1'b1;

always #5 _clk = ~_clk;

task wait_clocks(input integer n);
    repeat (n) @(posedge _clk);
endtask

// ============================================================
// 2. DUT
// ============================================================
soc dut (
    .i_clk      (_clk),
    .i_rst      (_rst),
    .i_par_i    (4'h0),
    .o_par_o    (),
    .i_uart_rx  (1'b1),
    .o_uart_tx  (),
    .io_i2c_sda (),
    .io_i2c_scl ()
);

// ============================================================
// 3. ALIASES
// ============================================================
wire [15:0] if_pc   = dut.u_cpu.u_if_stage.o_pc;
wire [15:0] id_pc   = dut.u_cpu.u_id_stage.i_pc;
wire [15:0] ex_pc   = dut.u_cpu.u_ex_stage.i_pc_dbg;
wire [15:0] mem_pc  = dut.u_cpu.u_mem_stage.i_pc_dbg;

wire if_v  = dut.u_cpu._if_valid;
wire id_v  = dut.u_cpu._ifid_valid;
wire ex_v  = dut.u_cpu._idex_valid;
wire mem_v = dut.u_cpu._exmem_valid;
wire wb_v  = dut.u_cpu._mem_valid;

wire        fwd_a   = dut.u_cpu.u_forwarding.o_ForwardAE;
wire        fwd_b   = dut.u_cpu.u_forwarding.o_ForwardBE;
wire [3:0]  frd_ex  = dut.u_cpu.u_forwarding.i_rdE;
wire [3:0]  frs_ex  = dut.u_cpu.u_forwarding.i_rsE;
wire [3:0]  frd_mem = dut.u_cpu.u_forwarding.i_WriteRegM;
wire [15:0] fwd_dat = dut.u_cpu._exmem_wb_pre_data;

wire stall_if = dut.u_cpu.u_hazard_unit.o_stall_if;
wire stall_id = dut.u_cpu.u_hazard_unit.o_stall_id;
wire luh      = dut.u_cpu.u_hazard_unit._load_use_hazard;
wire flush_if = dut.u_cpu.u_hazard_unit.o_flush_ifid;

wire        rf_we  = dut.u_cpu._rf_we;
wire [3:0]  rf_wa  = dut.u_cpu._rf_wa;
wire [15:0] rf_wd  = dut.u_cpu._rf_wd;

// EX stage CC (amostrados antes do reset implícito em m_cpu.v)
wire ex_flag_we = dut.u_cpu._ex_flag_we;
wire ex_ccz     = dut.u_cpu._ex_new_ccz;
wire ex_ccn     = dut.u_cpu._ex_new_ccn;

// ============================================================
// 4. CONTADORES
// ============================================================
integer pass_cnt = 0;
integer fail_cnt = 0;
integer cycle_n  = 0;

always @(posedge _clk) if (!_rst) cycle_n = cycle_n + 1;

task check16(input [255:0] label, input [15:0] got, input [15:0] exp);
    if (got === exp) begin
        $display("    [PASS] %-24s = %0d", label, got);
        pass_cnt = pass_cnt + 1;
    end else begin
        $display("    [FAIL] %-24s : got=%0d  expected=%0d", label, got, exp);
        fail_cnt = fail_cnt + 1;
    end
endtask

task check1(input [255:0] label, input got, input exp);
    if (got === exp) begin
        $display("    [PASS] %-24s = %0b", label, got);
        pass_cnt = pass_cnt + 1;
    end else begin
        $display("    [FAIL] %-24s : got=%0b  expected=%0b", label, got, exp);
        fail_cnt = fail_cnt + 1;
    end
endtask

// ============================================================
// 5. MONITOR DE PIPELINE (75 ciclos)
// ============================================================
initial begin
    @(negedge _rst); #1;
    $display("");
    $display("CY   IF    ID    EX    MEM  WB  FwA FwB  FWD_DAT  sIF sID LUH fIF  rf_wa rf_wd");
    $display("---- ----- ----- ----- ---- --- --- ---  -------  --- --- --- ---  ----- -----");
end

always @(posedge _clk) begin
    if (!_rst && cycle_n <= 75) begin
        $display("%3d  %4h  %4h  %4h  %4h  %b   %b   %b   %5d   %b   %b   %b   %b    r%0d   %0d",
            cycle_n,
            if_v  ? if_pc  : 16'hxxxx,
            id_v  ? id_pc  : 16'hxxxx,
            ex_v  ? ex_pc  : 16'hxxxx,
            mem_v ? mem_pc : 16'hxxxx,
            wb_v,
            fwd_a, fwd_b,
            (fwd_a | fwd_b) ? fwd_dat : 16'h0,
            stall_if, stall_id, luh, flush_if,
            rf_we ? rf_wa : 4'hf,
            rf_we ? rf_wd : 16'h0
        );
    end
end

// ============================================================
// 6. LOG DE FORWARDING (sempre activo)
// ============================================================
always @(posedge _clk) begin
    if (!_rst && (fwd_a || fwd_b))
        $display("  >> FWD cy=%0d ex_pc=%4h: rdE=r%0d rsE=r%0d WriteRegM=r%0d dat=%0d  FwA=%b FwB=%b",
            cycle_n, ex_pc, frd_ex, frs_ex, frd_mem, fwd_dat, fwd_a, fwd_b);
end

// ============================================================
// 7. CAPTURA POR PC DE WRITEBACK
//
// PCs relevantes (forwarding_01.asm):
//   TEST 1 — 0x010C  ADDI t1,t0,#1     rf_wa=5  → t1=2
//   TEST 2 — 0x0114  ADDI t1,t0,#1     rf_wa=5  → t1=11
//   TEST 3 — 0x0128  ADD  t3,t1        rf_wa=7  → t3=5
//          — 0x012A  ADD  t2,t3        rf_wa=6  → t2=8
//   TEST 4 — 0x013A  ADD  t0,t0        rf_wa=4  → t0=8  (último da cadeia)
//   TEST 5 — 0x0146  SUB  t0,t1        rf_wa=4  → t0=5
//          — 0x014A  CMP  t0,t1        (CC only — Z=0, N=0)
//
// NOTA: TEST 2 escreve em rf_wa=5 tal como TEST 1.
// Disambiguamos pelo mem_pc.
// ============================================================
reg [15:0] cap_t1_test1 = 16'hDEAD;
reg [15:0] cap_t1_test2 = 16'hDEAD;
reg [15:0] cap_t3_test3 = 16'hDEAD;
reg [15:0] cap_t2_test3 = 16'hDEAD;
reg [15:0] cap_t0_test4 = 16'hDEAD;
reg [15:0] cap_t0_test5 = 16'hDEAD;
reg        cap_ccz      = 1'bx;
reg        cap_ccn      = 1'bx;
reg        cc_seen      = 0;

always @(posedge _clk) begin
    if (!_rst) begin
        // TEST 1
        if (rf_we && rf_wa==4'd5 && mem_pc==16'h010C)
            cap_t1_test1 <= rf_wd;

        // TEST 2
        if (rf_we && rf_wa==4'd5 && mem_pc==16'h0114)
            cap_t1_test2 <= rf_wd;

        // TEST 3 — t3 primeiro, depois t2
        if (rf_we && rf_wa==4'd7 && mem_pc==16'h0128)
            cap_t3_test3 <= rf_wd;
        if (rf_we && rf_wa==4'd6 && mem_pc==16'h012A)
            cap_t2_test3 <= rf_wd;

        // TEST 4 — último ADD t0,t0 em 0x013A
        if (rf_we && rf_wa==4'd4 && mem_pc==16'h013A)
            cap_t0_test4 <= rf_wd;

        // TEST 5 — SUB t0,t1
        if (rf_we && rf_wa==4'd4 && mem_pc==16'h0146)
            cap_t0_test5 <= rf_wd;

        // TEST 5 CC — CMP em 0x014A
        // Amostrar _ex_new_ccz quando ex_flag_we=1 e ex_pc=0x014A
        // (_ccz arquitectural reseta a 0 a cada ciclo — ver nota abaixo)
        if (ex_flag_we && ex_v && ex_pc==16'h014A && !cc_seen) begin
            cap_ccz <= ex_ccz;
            cap_ccn <= ex_ccn;
            cc_seen <= 1;
        end
    end
end

// ============================================================
// 8. HALT DETECTION + REPORT
// ============================================================
reg        halted  = 0;
reg [15:0] pc_prev = 0;

always @(posedge _clk) begin
    if (!_rst) begin
        if (if_pc==16'h014C && pc_prev==16'h014C && !halted) halted <= 1;
        pc_prev <= if_pc;
    end
end

always @(posedge halted) begin
    wait_clocks(8);

    $display("");
    $display("════════════════════════════════════════════════════════════");
    $display("  HALT @ 0x014C — verificação de resultados");
    $display("════════════════════════════════════════════════════════════");

    // ---- TEST 1 ----
    $display("");
    $display("── TEST 1: MEM→EX dist 1 sem gap");
    $display("   ADDI t1,t0,#1 @ 0x010C  — FwB esperado = 1");
    if (cap_t1_test1===16'hDEAD)
        begin $display("    [MISS] t1@010C nunca capturado"); fail_cnt=fail_cnt+1; end
    else check16("t1 (r5)", cap_t1_test1, 16'd2);

    // ---- TEST 2 ----
    $display("");
    $display("── TEST 2: MEM→EX dist 2 com 1 gap");
    $display("   ADDI t1,t0,#1 @ 0x0114  — bypass regfile (FwB=0 esperado)");
    if (cap_t1_test2===16'hDEAD)
        begin $display("    [MISS] t1@0114 nunca capturado"); fail_cnt=fail_cnt+1; end
    else check16("t1 (r5)", cap_t1_test2, 16'd11);

    // ---- TEST 3 ----
    $display("");
    $display("── TEST 3: dois forwards simultâneos");
    $display("   ADD t2,t0 | ADD t3,t1 | ADD t2,t3");
    if (cap_t3_test3===16'hDEAD)
        begin $display("    [MISS] t3@0128 nunca capturado"); fail_cnt=fail_cnt+1; end
    else check16("t3 (r7)", cap_t3_test3, 16'd5);
    if (cap_t2_test3===16'hDEAD)
        begin $display("    [MISS] t2@012A nunca capturado"); fail_cnt=fail_cnt+1; end
    else check16("t2 (r6)", cap_t2_test3, 16'd8);

    // ---- TEST 4 ----
    $display("");
    $display("── TEST 4: cadeia com gaps alternados (t0: 1→2→4→8)");
    $display("   ADD t0,t0 @ 0x0132/0136/013A  — ultimo = 0x013A");
    if (cap_t0_test4===16'hDEAD)
        begin $display("    [MISS] t0@013A nunca capturado"); fail_cnt=fail_cnt+1; end
    else check16("t0 (r4)", cap_t0_test4, 16'd8);

    // ---- TEST 5 ----
    $display("");
    $display("── TEST 5: SUB + CMP com 1 gap");
    $display("   SUB t0,t1 @ 0x0146 | CMP t0,t1 @ 0x014A  (CMP(5,3): Z=0 N=0)");
    if (cap_t0_test5===16'hDEAD)
        begin $display("    [MISS] t0@0146 (SUB) nunca capturado"); fail_cnt=fail_cnt+1; end
    else check16("t0 pos-SUB (r4)", cap_t0_test5, 16'd5);

    if (!cc_seen) begin
        $display("    [MISS] CC do CMP @ ex_pc=014A nunca capturado");
        fail_cnt = fail_cnt + 1;
    end else begin
        $display("    CC amostrados de _ex_new_cc* (ex_flag_we=1 @ ex_pc=014A):");
        check1("_ex_new_ccz (Z=0)", cap_ccz, 1'b0);
        check1("_ex_new_ccn (N=0)", cap_ccn, 1'b0);
    end

    $display("");
    $display("  NOTA RTL: _ccz arquitectural reseta a 0 a cada ciclo (m_cpu.v).");
    $display("  CC só é válido no ciclo em que ex_flag_we=1.");
    $display("  Fix sugerido: usar else-if na secção 2.8 de m_cpu.v.");

    $display("");
    $display("════════════════════════════════════════════════════════════");
    $display("  RESULTADO: %0d PASS  /  %0d FAIL", pass_cnt, fail_cnt);
    if (fail_cnt==0)
        $display("  OK — forwarding correcto em todos os testes.");
    else
        $display("  Ver [FAIL]/[MISS] acima.");
    $display("════════════════════════════════════════════════════════════");
    $display("");
    $finish;
end

// ============================================================
// 9. TIMEOUT
// ============================================================
initial begin
    wait_clocks(12);
    _rst = 1'b0;
    wait_clocks(600);
    if (!halted) begin
        $display("[TIMEOUT] Halt nao detectado. if_pc=0x%04h", if_pc);
        $finish;
    end
end

// ============================================================
// 10. WAVEFORM
// ============================================================
initial begin
    $dumpfile("waves_forwarding_01.vcd");
    $dumpvars(0, tb_forwarding_01);
end

endmodule
