`timescale 1ns / 1ps

// =============================================================================
//  wdt_tb.v  -  Testbench for wdt.v + wdt_core.v
//
//  Tested scenarios
//  ─────────────────────────────────────────────────────────────────────────
//  TC1  - Reset / external reset clears all registers
//  TC2  - Prescaler & Reload config (mirrors the assembly example)
//  TC3  - Enable WDT with RSTEN (WEN=1, RSTEN=1, IEN=0)
//  TC4  - KICK prevents timeout
//  TC5  - WDT timeout fires rst_pulse and sets RSTF
//  TC6  - STOP (0xDEAD) disables the watchdog mid-run
//  TC7  - WDTIF interrupt flag (WEN=1, IEN=1, RSTEN=0)
//  TC8  - Write-1-to-clear for WDTIF and RSTF
//  TC9  - Read-back of all four registers
// =============================================================================

module wdt_tb;

// ---------------------------------------------------------------------------
// Clock & DUT signals
// ---------------------------------------------------------------------------
    reg         clk   = 0;
    reg         rst   = 0;
    reg         rst_ext = 0;
    reg         sel   = 0;
    reg         we    = 0;
    reg         re    = 0;
    reg  [1:0]  addr  = 0;
    reg  [15:0] wdata = 0;
    wire [15:0] rdata;
    wire        rdy;
    wire        int_req;
    wire        rst_req;

    // Clock: 10 ns period
    always #5 clk = ~clk;

// ---------------------------------------------------------------------------
// DUT
// ---------------------------------------------------------------------------
    wdt u_dut (
        .i_clk     (clk),
        .i_rst     (rst),
        .i_rst_ext (rst_ext),
        .i_sel     (sel),
        .i_we      (we),
        .i_re      (re),
        .i_addr    (addr),
        .i_wdata   (wdata),
        .o_rdata   (rdata),
        .o_rdy     (rdy),
        .o_int_req (int_req),
        .o_rst_req (rst_req)
    );

// ---------------------------------------------------------------------------
// Register address map (same as in wdt.v)
// ---------------------------------------------------------------------------
    localparam ADDR_CTRL   = 2'b00;
    localparam ADDR_PS     = 2'b01;
    localparam ADDR_RELOAD = 2'b10;
    localparam ADDR_CMD    = 2'b11;

    localparam KEY_KICK = 16'hA5A5;
    localparam KEY_STOP = 16'hDEAD;

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------
    integer pass_cnt = 0;
    integer fail_cnt = 0;

    task bus_write;
        input [1:0]  a;
        input [15:0] d;
        begin
            @(negedge clk);
            sel = 1; we = 1; re = 0; addr = a; wdata = d;
            @(posedge clk); #1;
            sel = 0; we = 0;
        end
    endtask

    task bus_read;
        input  [1:0]  a;
        output [15:0] d;
        begin
            @(negedge clk);
            sel = 1; we = 0; re = 1; addr = a; wdata = 0;
            @(posedge clk); #1;
            d = rdata;
            sel = 0; re = 0;
        end
    endtask

    task do_rst;
        begin
            @(negedge clk);
            rst = 1;
            @(posedge clk); #1;
            rst = 0;
        end
    endtask

    task do_rst_ext;
        begin
            @(negedge clk);
            rst_ext = 1;
            @(posedge clk); #1;
            rst_ext = 0;
        end
    endtask

    task check;
        input [255:0] name;
        input         got;
        input         expected;
        begin
            if (got === expected) begin
                $display("  PASS  %0s", name);
                pass_cnt = pass_cnt + 1;
            end else begin
                $display("  FAIL  %0s  got=%0b expected=%0b", name, got, expected);
                fail_cnt = fail_cnt + 1;
            end
        end
    endtask

    task check16;
        input [255:0] name;
        input [15:0]  got;
        input [15:0]  expected;
        begin
            if (got === expected) begin
                $display("  PASS  %0s", name);
                pass_cnt = pass_cnt + 1;
            end else begin
                $display("  FAIL  %0s  got=0x%04X expected=0x%04X", name, got, expected);
                fail_cnt = fail_cnt + 1;
            end
        end
    endtask

    // Advance N clock cycles
    task clk_n;
        input integer n;
        integer i;
        begin
            for (i = 0; i < n; i = i + 1)
                @(posedge clk);
            #1;
        end
    endtask

// ---------------------------------------------------------------------------
// Main test body
// ---------------------------------------------------------------------------
    reg [15:0] rd;
    integer    i;

    initial begin
        $dumpfile("wdt_tb.vcd");
        $dumpvars(0, wdt_tb);

        $display("=== WDT Testbench ===");

        // ----------------------------------------------------------------
        // TC1 - External reset clears everything
        // ----------------------------------------------------------------
        $display("\n[TC1] External reset");
        do_rst_ext;
        clk_n(2);
        bus_read(ADDR_CTRL, rd);
        check16("CTRL == 0 after rst_ext", rd, 16'h0000);
        bus_read(ADDR_PS, rd);
        check16("PS   == 0 after rst_ext", rd, 16'h0000);
        bus_read(ADDR_RELOAD, rd);
        check16("RELOAD == 0 after rst_ext", rd, 16'h0000);

        // ----------------------------------------------------------------
        // TC2 - Prescaler & Reload config  (like the assembly example)
        //        PS = 8, RELOAD = 4
        // ----------------------------------------------------------------
        $display("\n[TC2] Configure PS=8, RELOAD=4");
        bus_write(ADDR_PS,     16'd8);
        bus_write(ADDR_RELOAD, 16'd4);
        clk_n(2);
        bus_read(ADDR_PS, rd);
        check16("PS readback == 8",     rd, 16'd8);
        bus_read(ADDR_RELOAD, rd);
        check16("RELOAD readback == 4", rd, 16'd4);

        // ----------------------------------------------------------------
        // TC3 - Enable WDT with RSTEN (WEN=1 RSTEN=1 IEN=0) → like SW a0,zero,#0
        // ----------------------------------------------------------------
        $display("\n[TC3] Enable WDT (WEN=1, RSTEN=1, IEN=0)");
        bus_write(ADDR_CTRL, 16'h0003);   // bits[1:0] = WEN|RSTEN
        clk_n(2);
        bus_read(ADDR_CTRL, rd);
        check("WEN  set",   rd[0], 1'b1);
        check("RSTEN set",  rd[1], 1'b1);
        check("IEN  clear", rd[2], 1'b0);

        // Verify counter loaded with reload value
        bus_read(ADDR_CMD, rd);
        check16("CNT == RELOAD after enable", rd, 16'd4);

        // ----------------------------------------------------------------
        // TC4 - KICK prevents timeout
        //        With PS=8 each tick takes 9 clocks (0..8).
        //        RELOAD=4 so timeout after 5 ticks = ~45 clocks.
        //        We kick after ~20 clocks so it should NOT time out.
        // ----------------------------------------------------------------
        $display("\n[TC4] KICK prevents timeout");
        clk_n(20);
        bus_write(ADDR_CMD, KEY_KICK);    // kick
        clk_n(20);
        bus_read(ADDR_CTRL, rd);
        check("No RSTF after kick", rd[4], 1'b0);
        check("rst_req low",        rst_req, 1'b0);
        // Counter should be reloaded to 4 and counting down
        bus_read(ADDR_CMD, rd);
        check("CNT > 0 after kick", (rd > 0), 1'b1);

        // ----------------------------------------------------------------
        // TC5 - Timeout: let counter expire → rst_pulse + RSTF set
        //        Also triggers internal WDT reset (i_rst from external logic).
        //        We just wait long enough: 5 ticks × 9 clocks = 45 + margin.
        // ----------------------------------------------------------------
        $display("\n[TC5] Timeout fires rst_req and sets RSTF");

        // Fresh config to keep things short
        do_rst_ext;
        clk_n(2);
        bus_write(ADDR_PS,     16'd2);    // tick every 3 clocks
        bus_write(ADDR_RELOAD, 16'd3);    // 4 ticks to zero
        bus_write(ADDR_CTRL,   16'h0003); // WEN=1, RSTEN=1

        // Wait for timeout: 4 ticks × 3 clocks + a few extra = ~20 clocks
        // Sample rst_req for at least one cycle
        begin : wait_rst
            integer timeout_watch;
            timeout_watch = 0;
            while (rst_req === 1'b0 && timeout_watch < 200) begin
                @(posedge clk); #1;
                timeout_watch = timeout_watch + 1;
            end
            check("rst_req pulsed high", rst_req, 1'b1);
        end

        // rst_req is one cycle wide; wait one more cycle for it to drop
        @(posedge clk); #1;
        check("rst_req one-cycle pulse (back low)", rst_req, 1'b0);

        // WDT auto-disables after reset pulse; RSTF should still be set
        // (it survives the internal WDT reset)
        bus_read(ADDR_CTRL, rd);
        check("RSTF set after timeout",  rd[4], 1'b1);
        check("WEN cleared after reset", rd[0], 1'b0);

        // ----------------------------------------------------------------
        // TC6 - STOP (KEY_STOP = 0xDEAD) disables the WDT mid-run
        // ----------------------------------------------------------------
        $display("\n[TC6] STOP disables WDT mid-run");
        do_rst_ext;
        clk_n(2);
        bus_write(ADDR_PS,     16'd10);
        bus_write(ADDR_RELOAD, 16'd50);
        bus_write(ADDR_CTRL,   16'h0003);
        clk_n(10);                         // let it run a bit
        bus_write(ADDR_CMD, KEY_STOP);
        clk_n(20);                         // wait enough for core to clear CNT
        bus_read(ADDR_CTRL, rd);
        check("WEN=0 after STOP",   rd[0], 1'b0);
        check("RSTEN=0 after STOP", rd[1], 1'b0);
        // Counter should be frozen (not decrementing) after STOP
        bus_read(ADDR_CMD, rd);
        begin : tc6_frozen
            reg [15:0] cnt_a, cnt_b;
            cnt_a = rd;
            clk_n(20);
            bus_read(ADDR_CMD, cnt_b);
            check("CNT frozen after STOP", (cnt_a == cnt_b), 1'b1);
        end

        // ----------------------------------------------------------------
        // TC7 - Interrupt flag (WEN=1, IEN=1, RSTEN=0)
        //        Timeout should set WDTIF and assert int_req, NOT rst_req.
        // ----------------------------------------------------------------
        $display("\n[TC7] Interrupt-only timeout (IEN=1, RSTEN=0)");
        do_rst_ext;
        clk_n(2);
        bus_write(ADDR_PS,     16'd2);
        bus_write(ADDR_RELOAD, 16'd3);
        bus_write(ADDR_CTRL,   16'h0005); // WEN=1 IEN=1 RSTEN=0

        begin : wait_int
            integer tw2;
            tw2 = 0;
            while (int_req === 1'b0 && tw2 < 200) begin
                @(posedge clk); #1;
                tw2 = tw2 + 1;
            end
            check("int_req asserted",    int_req, 1'b1);
            check("rst_req NOT asserted", rst_req, 1'b0);
        end

        bus_read(ADDR_CTRL, rd);
        check("WDTIF set",  rd[3], 1'b1);
        check("RSTF clear", rd[4], 1'b0);

        // ----------------------------------------------------------------
        // TC8 - Write-1-to-clear WDTIF and RSTF
        // ----------------------------------------------------------------
        $display("\n[TC8] Write-1-to-clear flags");
        // First STOP the WDT so it stops re-setting WDTIF on every timeout
        bus_write(ADDR_CMD, KEY_STOP);
        clk_n(4);
        // Now clear WDTIF (bit[3]=1)
        bus_write(ADDR_CTRL, 16'h0008);
        clk_n(4);
        bus_read(ADDR_CTRL, rd);
        check("WDTIF cleared (w1c)", rd[3], 1'b0);

        // Set RSTF by triggering a reset timeout
        do_rst_ext;
        clk_n(2);
        bus_write(ADDR_PS,     16'd2);
        bus_write(ADDR_RELOAD, 16'd2);
        bus_write(ADDR_CTRL,   16'h0003);
        begin : wait_rstf
            integer tw3;
            tw3 = 0;
            while (tw3 < 60) begin
                @(posedge clk); #1;
                tw3 = tw3 + 1;
            end
        end
        bus_read(ADDR_CTRL, rd);
        // Clear RSTF
        bus_write(ADDR_CTRL, 16'h0010);   // bit[4]=1 → clr RSTF
        clk_n(2);
        bus_read(ADDR_CTRL, rd);
        check("RSTF cleared (w1c)", rd[4], 1'b0);

        // ----------------------------------------------------------------
        // TC9 - Read-back of all four registers in a known state
        // ----------------------------------------------------------------
        $display("\n[TC9] Read-back all registers");
        do_rst_ext;
        clk_n(2);
        bus_write(ADDR_PS,     16'h00AA);
        bus_write(ADDR_RELOAD, 16'h00BB);
        // Don't enable WDT yet
        bus_read(ADDR_PS, rd);
        check16("PS readback",     rd, 16'h00AA);
        bus_read(ADDR_RELOAD, rd);
        check16("RELOAD readback", rd, 16'h00BB);
        bus_read(ADDR_CTRL, rd);
        check16("CTRL readback (all 0)", rd, 16'h0000);
        bus_read(ADDR_CMD, rd);
        check16("CNT == 0 (not started)", rd, 16'h0000);

        // ----------------------------------------------------------------
        // Summary
        // ----------------------------------------------------------------
        $display("\n====================================");
        $display("  Results: %0d PASS  /  %0d FAIL", pass_cnt, fail_cnt);
        $display("====================================\n");

        if (fail_cnt == 0)
            $display("ALL TESTS PASSED");
        else
            $display("SOME TESTS FAILED - check output above");

        $finish;
    end

endmodule