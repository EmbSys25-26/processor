`timescale 1ns / 1ps
// Run with SIM_FIFO_FALLBACK for Icarus/Verilator; without it for Vivado xsim (uses XPM models).
// Icarus: iverilog -D SIM_FIFO_FALLBACK -o tb_i2s_fifo tb_i2s_fifo.v ../srcs/m_i2s_fifo.v && vvp tb_i2s_fifo

module tb_i2s_fifo;

    localparam DEPTH_LOG2 = 4;
    localparam DEPTH      = 1 << DEPTH_LOG2;  // 16 entries

    // wclk = 100 MHz (T=10ns), rclk ≈ 3.072 MHz (T≈326ns)
    localparam WCLK_HLF = 5;
    localparam RCLK_HLF = 163;

    // ── DUT signals ──────────────────────────────────────────────────────────────
    reg        wclk, wrst, wr_en;
    reg [31:0] wdata;
    wire       full, almost_full;

    reg        rclk, rrst, rd_en;
    wire[31:0] rdata;
    wire       empty, almost_empty;

    i2s_fifo #(.DEPTH_LOG2(DEPTH_LOG2)) dut (
        .i_wclk        (wclk),  .i_wrst        (wrst),
        .i_wr_en       (wr_en), .i_wdata       (wdata),
        .o_full        (full),  .o_almost_full (almost_full),
        .i_rclk        (rclk),  .i_rrst        (rrst),
        .i_rd_en       (rd_en), .o_rdata       (rdata),
        .o_empty       (empty), .o_almost_empty(almost_empty)
    );

    initial wclk = 0; always #WCLK_HLF wclk = ~wclk;
    initial rclk = 0; always #RCLK_HLF rclk = ~rclk;

    // ── Variables ─────────────────────────────────────────────────────────────────
    integer    fails;
    integer    i;
    reg [31:0] rd_got;
    reg [31:0] expected [0:DEPTH-1];

    // ── Utility tasks ─────────────────────────────────────────────────────────────

    // Check a 1-bit flag and print PASS/FAIL
    task chk1;
        input [8*32-1:0] label;
        input            got, exp;
        begin
            if (got !== exp) begin
                $display("FAIL  %-40s  got=%b  exp=%b  @%0t ns", label, got, exp, $time/1000);
                fails = fails + 1;
            end else
                $display("pass  %0s", label);
        end
    endtask

    // Check a 32-bit value and print PASS/FAIL
    task chk32;
        input [8*32-1:0] label;
        input [31:0]     got, exp;
        begin
            if (got !== exp) begin
                $display("FAIL  %-40s  got=0x%08h  exp=0x%08h  @%0t ns",
                         label, got, exp, $time/1000);
                fails = fails + 1;
            end else
                $display("pass  %0s", label);
        end
    endtask

    // Write one 32-bit word into the FIFO (wclk domain)
    task do_write;
        input [31:0] d;
        begin
            @(negedge wclk); wr_en = 1; wdata = d;
            @(posedge wclk); #1;
            wr_en = 0;
        end
    endtask

    // Pop one 32-bit word from the FIFO (rclk domain); captures rdata at posedge
    task do_read;
        output [31:0] d;
        begin
            @(negedge rclk); rd_en = 1;
            @(posedge rclk); d = rdata; #1;
            rd_en = 0;
        end
    endtask

    // Wait for write→read CDC to propagate (2 rclk sync stages + margin)
    task rclk_settle; begin repeat(5) @(posedge rclk); end endtask

    // Wait for read→write CDC to propagate (2 wclk sync stages + margin)
    task wclk_settle; begin repeat(5) @(posedge wclk); end endtask

    // ── Test body ─────────────────────────────────────────────────────────────────
    initial begin : test_body

        fails = 0;
        wr_en = 0; rd_en = 0; wdata = 0;
        wrst = 1; rrst = 1;
        repeat(6) @(posedge wclk);
        wrst = 0; rrst = 0;
        repeat(4) @(posedge wclk);

        // ────────────────────────────────────────────────────────────────────────
        // T1  Flags immediately after reset
        // ────────────────────────────────────────────────────────────────────────
        rclk_settle;
        $display("\n--- T1: post-reset flags ---");
        chk1("empty  = 1 after reset",        empty,        1'b1);
        chk1("full   = 0 after reset",         full,         1'b0);
        chk1("afull  = 0 after reset",         almost_full,  1'b0);
        chk1("aempty = 1 after reset",         almost_empty, 1'b1);

        // ────────────────────────────────────────────────────────────────────────
        // T2  Single write → FWFT read → empty again
        // ────────────────────────────────────────────────────────────────────────
        $display("\n--- T2: single write / FWFT read ---");
        do_write(32'hDEAD_BEEF);
        rclk_settle;
        chk1 ("!empty after one write",        empty,  1'b0);
        chk32("FWFT rdata before rd_en",       rdata,  32'hDEAD_BEEF);

        do_read(rd_got);
        chk32("captured read value",           rd_got, 32'hDEAD_BEEF);
        rclk_settle;
        chk1 ("empty after pop",               empty,  1'b1);

        // ────────────────────────────────────────────────────────────────────────
        // T3  Fill to full; verify full and almost_full
        // ────────────────────────────────────────────────────────────────────────
        $display("\n--- T3: fill to full ---");
        for (i = 0; i < DEPTH; i = i+1) begin
            expected[i] = 32'hA000_0000 | i;
            do_write(expected[i]);
        end
        wclk_settle;
        chk1("full after DEPTH writes",       full,        1'b1);
        chk1("almost_full after DEPTH writes", almost_full, 1'b1);

        // ────────────────────────────────────────────────────────────────────────
        // T4  Overflow write is silently dropped
        // ────────────────────────────────────────────────────────────────────────
        $display("\n--- T4: overflow write dropped ---");
        do_write(32'hBAD_CAFE);
        wclk_settle;
        chk1("still full after overflow write", full, 1'b1);

        // ────────────────────────────────────────────────────────────────────────
        // T5  Drain completely; verify FIFO order (FWFT at each step)
        // ────────────────────────────────────────────────────────────────────────
        $display("\n--- T5: drain and verify order ---");
        for (i = 0; i < DEPTH; i = i+1) begin
            rclk_settle;
            chk32("FWFT rdata[i]", rdata, expected[i]);
            do_read(rd_got);
            chk32("popped rdata[i]", rd_got, expected[i]);
        end
        rclk_settle;
        chk1("empty after full drain", empty, 1'b1);

        // ────────────────────────────────────────────────────────────────────────
        // T6  almost_full boundary: asserts at occupancy = AF_THRESH (DEPTH-4=12)
        // ────────────────────────────────────────────────────────────────────────
        $display("\n--- T6: almost_full boundary ---");
        // Write 11 entries → occupancy = 11 < 12; almost_full must be 0
        for (i = 0; i < 11; i = i+1) do_write(32'hB000_0000 | i);
        wclk_settle;
        chk1("!almost_full at occupancy 11", almost_full, 1'b0);

        // Write one more → occupancy = 12 = AF_THRESH; almost_full must assert
        do_write(32'hB000_000B);
        wclk_settle;
        chk1("almost_full at occupancy 12",  almost_full, 1'b1);

        // Let rclk domain see the 12 writes (wclk→rclk CDC = 2 rclk cycles)
        rclk_settle;
        for (i = 0; i < 12; i = i+1) do_read(rd_got);
        rclk_settle;
        chk1("empty after T6 drain", empty, 1'b1);

        // ────────────────────────────────────────────────────────────────────────
        // T7  almost_empty boundary: asserts at occupancy <= AE_THRESH (3)
        // ────────────────────────────────────────────────────────────────────────
        $display("\n--- T7: almost_empty boundary ---");
        // Write 4 entries; occupancy = 4 > 3; almost_empty must be 0
        for (i = 0; i < 4; i = i+1) do_write(32'hC000_0000 | i);
        rclk_settle;
        chk1("!almost_empty at occupancy 4", almost_empty, 1'b0);

        // Pop one → occupancy = 3 = AE_THRESH; almost_empty must assert
        do_read(rd_got);
        rclk_settle;
        chk1("almost_empty at occupancy 3",  almost_empty, 1'b1);

        // Pop remaining 3; FIFO empties
        do_read(rd_got); do_read(rd_got); do_read(rd_got);
        rclk_settle;
        chk1("empty after T7 drain", empty, 1'b1);

        // ────────────────────────────────────────────────────────────────────────
        // T8  Concurrent write + read (fork-join, independent clock domains)
        // ────────────────────────────────────────────────────────────────────────
        $display("\n--- T8: concurrent write and read ---");
        // Pre-fill with 2 known words, let rclk domain see them
        do_write(32'hF000_0001); do_write(32'hF000_0002);
        rclk_settle;

        // Fork: wclk-domain write and rclk-domain read run concurrently
        // Expected result: WORD1 popped, WORD3 appended → {WORD2, WORD3} remain
        fork
            do_write(32'hF000_0003);
            do_read(rd_got);
        join
        chk32("concurrent rw: oldest word popped", rd_got, 32'hF000_0001);

        // Drain remaining 2 words and verify order
        rclk_settle;
        do_read(rd_got); chk32("conc drain[1]", rd_got, 32'hF000_0002);
        rclk_settle;
        do_read(rd_got); chk32("conc drain[2]", rd_got, 32'hF000_0003);
        rclk_settle;
        chk1("empty after T8 drain", empty, 1'b1);

        // ────────────────────────────────────────────────────────────────────────
        // Summary
        // ────────────────────────────────────────────────────────────────────────
        repeat(10) @(posedge wclk);
        $display("");
        if (fails == 0)
            $display("*** ALL TESTS PASSED ***");
        else
            $display("*** %0d TEST(S) FAILED ***", fails);
        $finish;
    end

    // Safety timeout
    initial begin
        #50_000_000; $display("TIMEOUT"); $finish;
    end

endmodule
