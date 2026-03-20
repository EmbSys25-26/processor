`timescale 1ns / 1ps

module tb_regfile;

    // Inputs
    reg clk;
    reg we;
    reg [3:0] wa;
    reg [3:0] ra;
    reg [3:0] rb;
    reg [15:0] wd;

    // Outputs
    wire [15:0] rd_a;
    wire [15:0] rd_b;

    // Instantiate DUT
    regfile16x16 uut (
        .i_clk(clk),
        .i_we(we),
        .i_wa(wa),
        .i_ra(ra),
        .i_rb(rb),
        .i_wd(wd),
        .o_ra(rd_a),
        .o_rb(rd_b)
    );

    // Clock (10ns period)
    always #5 clk = ~clk;

    initial begin
        // Init
        clk = 0;
        we  = 0;
        wa  = 0;
        ra  = 0;
        rb  = 0;
        wd  = 0;

        // Wait a bit
        #15;

        /***********************
         * TEST 1: Write-first (same cycle)
         ***********************/
        $display("TEST 1: Write-first (same cycle)");
        
        we = 1;
        wa = 4'd3;
        wd = 16'h1234;
        ra = 4'd3;
        
        // BEFORE clock edge → should use bypass
        #1;
        $display("Before clk edge: Read A = %h (expected 1234)", rd_a);
        
        // Now trigger write
        #9; // reach posedge
        
        // AFTER clock edge → value should be in memory
        we = 0;
        #1;
        $display("After clk edge: Read A = %h (expected 1234)", rd_a);


        /*******************************
         * TEST 2: Write-first (bypass)
         *******************************/
        $display("\nTEST 2: Write-first bypass");

        we = 1;
        wa = 4'd5;
        wd = 16'hABCD;
        ra = 4'd5;   // same register!
        #1;          // no clock edge yet

        $display("Bypass Read A = %h (expected ABCD)", rd_a);

        #9; // finish cycle (posedge happens)

        /***********************************
         * TEST 3: Dual read (ra and rb)
         ***********************************/
        $display("\nTEST 3: Dual read");

        we = 0;
        ra = 4'd3;
        rb = 4'd5;
        #10;

        $display("Read A = %h (expected 1234)", rd_a);
        $display("Read B = %h (expected ABCD)", rd_b);

        /***********************************
         * TEST 4: Write to r0 (should ignore)
         ***********************************/
        $display("\nTEST 4: Write to r0 (should stay 0)");

        we = 1;
        wa = 4'd0;
        wd = 16'hFFFF;
        #10;

        we = 0;
        ra = 4'd0;
        #10;

        $display("Read r0 = %h (expected 0000)", rd_a);

        /***********************************
         * TEST 5: Bypass should NOT trigger for r0
         ***********************************/
        $display("\nTEST 5: No bypass on r0");

        we = 1;
        wa = 4'd0;
        wd = 16'hEEEE;
        ra = 4'd0;
        #1;

        $display("Bypass r0 = %h (expected 0000)", rd_a);

        #20;

        $display("\nAll tests done.");
        $finish;
    end

endmodule

