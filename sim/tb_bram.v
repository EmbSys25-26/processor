`timescale 1ns / 1ps

module tb_bram_latency();

    // Standard BRAM signals
    reg i_clk, i_rst, i_en;
    reg i_we_h, i_we_l;
    reg [9:1] i_addr;
    reg [7:0] i_din_h, i_din_l;
    wire [7:0] o_dout_h, o_dout_l;

    // --- NEW DEBUG VARIABLE ---
    // This exists only in the testbench to mark the "Request Phase"
    reg read_requested; 

    bram_1kb_be uut (
        .i_clk(i_clk), .i_rst(i_rst), .i_en(i_en),
        .i_we_h(i_we_h), .i_we_l(i_we_l), .i_addr(i_addr),
        .i_din_h(i_din_h), .i_din_l(i_din_l),
        .o_dout_h(o_dout_h), .o_dout_l(o_dout_l)
    );

    always #5 i_clk = ~i_clk; // 100MHz clock

    initial begin
        // 1. Setup
        i_clk = 0; i_rst = 1; i_en = 0; 
        i_we_h = 0; i_we_l = 0; i_addr = 0;
        read_requested = 0;
        #20 i_rst = 0;
        
        // 2. Pre-fill memory with 0xDEAD at address 0x050
        @(posedge i_clk);
        #1; // Wait slightly after edge
        i_en = 1; i_we_h = 1; i_we_l = 1; i_addr = 9'h050;
        i_din_h = 8'hDE; i_din_l = 8'hAD;
        @(posedge i_clk);
        #1;
        i_we_h = 0; i_we_l = 0; i_en = 0;

        #20;

        // 3. THE READ TEST
        @(posedge i_clk);
        #1; 
        read_requested = 1; // Mark the START of the request
        i_en = 1;
        i_addr = 9'h050;    // CPU puts address on the bus
        
        @(posedge i_clk); 
        // Edge 1: BRAM captures the address internally. 
        // o_dout is still 0000 here because the register hasn't updated yet.
        #1;
        read_requested = 0; // Request phase over
        $display("[%0t] Edge 1 (Capture): Address sampled. Data is NOT ready yet.", $time);

        @(posedge i_clk);
        // Edge 2: The BRAM output register finally shows the data.
        #1;
        $display("[%0t] Edge 2 (Valid): Data is now %h%h", $time, o_dout_h, o_dout_l);

        #50 $finish;
    end
endmodule