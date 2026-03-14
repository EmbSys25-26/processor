`timescale 1ns / 1ps
`default_nettype none

// =============================================================================
//  tb_wdt.v  -  Testbench for wdt.v + wdt_core.v
//
//  Tested scenarios
//  ─────────────────────────────────────────────────────────────────────────
//  TC1  - Reset / external reset clears all registers
//  TC2  - Prescaler & Reload config
//  TC3  - Enable WDT with RSTEN (WEN=1, RSTEN=1, IEN=0)
//  TC4  - KICK prevents timeout
//  TC5  - WDT timeout fires rst_pulse and sets RSTF
//  TC6  - STOP (0xDEAD) disables the watchdog mid-run
//  TC7  - WDTIF interrupt flag (WEN=1, IEN=1, RSTEN=0)
//  TC8  - Write-1-to-clear for WDTIF and RSTF
//  TC9  - Read-back of all four registers
// =============================================================================

module tb_wdt;

// ---------------------------------------------------------------------------
// Clock & DUT signals
// ---------------------------------------------------------------------------
    reg         clk    = 0;
    reg         rst    = 0;
    reg         rst_ext = 0;
    reg         sel    = 0;
    reg         we     = 0;
    reg         re     = 0;
    reg  [1:0]  addr   = 0;
    reg  [15:0] wdata  = 0;
    wire [15:0] rdata;
    wire        rdy;
    wire        int_req;
    wire        rst_req;

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
// Register address map
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
    integer _errors = 0;

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
            if (got !== expected) begin
                $display("FAIL tb_wdt: %0s  got=%0b expected=%0b", name, got, expected);
                _errors = _errors + 1;
            end
        end
    endtask

    task check16;
        input [255:0] name;
        input [15:0]  got;
        input [15:0]  expected;
        begin
            if (got !== expected) begin
                $display("FAIL tb_wdt: %0s  got=0x%04X expected=0x%04X", name, got, expected);
                _errors = _errors + 1;
            end
        end
    endtask

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

    initial begin
        // ----------------------------------------------------------------
        // TC1 - External reset clears everything
        // ----------------------------------------------------------------
        do_rst_ext;
        clk_n(2);
        bus_read(ADDR_CTRL, rd);
        check16("TC1 CTRL == 0 after rst_ext", rd, 16'h0000);
        bus_read(ADDR_PS, rd);
        check16("TC1 PS == 0 after rst_ext", rd, 16'h0000);
        bus_read(ADDR_RELOAD, rd);
        check16("TC1 RELOAD == 0 after rst_ext", rd, 16'h0000);

        // ----------------------------------------------------------------
        // TC2 - Prescaler & Reload config
        // ----------------------------------------------------------------
        bus_write(ADDR_PS,     16'd8);
        bus_write(ADDR_RELOAD, 16'd4);
        clk_n(2);
        bus_read(ADDR_PS, rd);
        check16("TC2 PS readback == 8", rd, 16'd8);
        bus_read(ADDR_RELOAD, rd);
        check16("TC2 RELOAD readback == 4", rd, 16'd4);

        // ----------------------------------------------------------------
        // TC3 - Enable WDT with RSTEN
        // ----------------------------------------------------------------
        bus_write(ADDR_CTRL, 16'h0003);
        clk_n(2);
        bus_read(ADDR_CTRL, rd);
        check("TC3 WEN set",   rd[0], 1'b1);
        check("TC3 RSTEN set", rd[1], 1'b1);
        check("TC3 IEN clear", rd[2], 1'b0);
        bus_read(ADDR_CMD, rd);
        check16("TC3 CNT == RELOAD after enable", rd, 16'd4);

        // ----------------------------------------------------------------
        // TC4 - KICK prevents timeout
        // ----------------------------------------------------------------
        clk_n(20);
        bus_write(ADDR_CMD, KEY_KICK);
        clk_n(20);
        bus_read(ADDR_CTRL, rd);
        check("TC4 No RSTF after kick", rd[4], 1'b0);
        check("TC4 rst_req low",        rst_req, 1'b0);
        bus_read(ADDR_CMD, rd);
        check("TC4 CNT > 0 after kick", (rd > 0), 1'b1);

        // ----------------------------------------------------------------
        // TC5 - Timeout fires rst_req and sets RSTF
        // ----------------------------------------------------------------
        do_rst_ext;
        clk_n(2);
        bus_write(ADDR_PS,     16'd2);
        bus_write(ADDR_RELOAD, 16'd3);
        bus_write(ADDR_CTRL,   16'h0003);

        begin : wait_rst
            integer timeout_watch;
            timeout_watch = 0;
            while (rst_req === 1'b0 && timeout_watch < 200) begin
                @(posedge clk); #1;
                timeout_watch = timeout_watch + 1;
            end
            check("TC5 rst_req pulsed high", rst_req, 1'b1);
        end

        @(posedge clk); #1;
        check("TC5 rst_req one-cycle pulse", rst_req, 1'b0);
        bus_read(ADDR_CTRL, rd);
        check("TC5 RSTF set after timeout",  rd[4], 1'b1);
        check("TC5 WEN cleared after reset", rd[0], 1'b0);

        // ----------------------------------------------------------------
        // TC6 - STOP disables WDT mid-run
        // ----------------------------------------------------------------
        do_rst_ext;
        clk_n(2);
        bus_write(ADDR_PS,     16'd10);
        bus_write(ADDR_RELOAD, 16'd50);
        bus_write(ADDR_CTRL,   16'h0003);
        clk_n(10);
        bus_write(ADDR_CMD, KEY_STOP);
        clk_n(20);
        bus_read(ADDR_CTRL, rd);
        check("TC6 WEN=0 after STOP",   rd[0], 1'b0);
        check("TC6 RSTEN=0 after STOP", rd[1], 1'b0);
        bus_read(ADDR_CMD, rd);
        begin : tc6_frozen
            reg [15:0] cnt_a, cnt_b;
            cnt_a = rd;
            clk_n(20);
            bus_read(ADDR_CMD, cnt_b);
            check("TC6 CNT frozen after STOP", (cnt_a == cnt_b), 1'b1);
        end

        // ----------------------------------------------------------------
        // TC7 - Interrupt-only timeout (IEN=1, RSTEN=0)
        // ----------------------------------------------------------------
        do_rst_ext;
        clk_n(2);
        bus_write(ADDR_PS,     16'd2);
        bus_write(ADDR_RELOAD, 16'd3);
        bus_write(ADDR_CTRL,   16'h0005);

        begin : wait_int
            integer tw2;
            tw2 = 0;
            while (int_req === 1'b0 && tw2 < 200) begin
                @(posedge clk); #1;
                tw2 = tw2 + 1;
            end
            check("TC7 int_req asserted",     int_req, 1'b1);
            check("TC7 rst_req NOT asserted", rst_req, 1'b0);
        end

        bus_read(ADDR_CTRL, rd);
        check("TC7 WDTIF set",  rd[3], 1'b1);
        check("TC7 RSTF clear", rd[4], 1'b0);

        // ----------------------------------------------------------------
        // TC8 - Write-1-to-clear WDTIF and RSTF
        // ----------------------------------------------------------------
        bus_write(ADDR_CMD, KEY_STOP);
        clk_n(4);
        bus_write(ADDR_CTRL, 16'h0008);
        clk_n(4);
        bus_read(ADDR_CTRL, rd);
        check("TC8 WDTIF cleared (w1c)", rd[3], 1'b0);

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
        bus_write(ADDR_CTRL, 16'h0010);
        clk_n(2);
        bus_read(ADDR_CTRL, rd);
        check("TC8 RSTF cleared (w1c)", rd[4], 1'b0);

        // ----------------------------------------------------------------
        // TC9 - Read-back all registers
        // ----------------------------------------------------------------
        do_rst_ext;
        clk_n(2);
        bus_write(ADDR_PS,     16'h00AA);
        bus_write(ADDR_RELOAD, 16'h00BB);
        bus_read(ADDR_PS, rd);
        check16("TC9 PS readback",           rd, 16'h00AA);
        bus_read(ADDR_RELOAD, rd);
        check16("TC9 RELOAD readback",       rd, 16'h00BB);
        bus_read(ADDR_CTRL, rd);
        check16("TC9 CTRL readback (all 0)", rd, 16'h0000);
        bus_read(ADDR_CMD, rd);
        check16("TC9 CNT == 0 (not started)", rd, 16'h0000);

        // ----------------------------------------------------------------
        // Summary
        // ----------------------------------------------------------------
        if (_errors == 0) begin
            $display("PASS tb_wdt");
        end else begin
            $display("FAIL tb_wdt errors=%0d", _errors);
            $fatal(1);
        end
        $finish;
    end

endmodule