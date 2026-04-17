`timescale 1ns / 1ps

module tb_i2s();

    reg clk_100m;
    reg clk_12m;
    reg rst;

    // Periph Bus Signals (MMIO)
    reg [2:0]  addr;
    reg        sel, we, re;
    reg [15:0] wdata;
    wire [15:0] rdata;
    wire        rdy;

    // AXI-Stream Signals (Simulating DMA)
    reg [31:0] axis_tdata;
    reg        axis_tvalid;
    wire       axis_tready;

    //  Output signals to I2S Codec
    wire o_mclk, o_bclk, o_lrclk, o_pbdat;
    wire io_i2c_sda, io_i2c_scl;

    // Instanciate module I2S
    i2s_mmio uut (
        .i_clk(clk_100m),
        .i_rst(rst),
        .i_mclk(clk_12m),
        .i_sel(sel),
        .i_we(we),
        .i_re(re),
        .i_addr(addr),
        .i_wdata(wdata),
        .o_rdata(rdata),
        .o_rdy(rdy),
        .o_irq_req(),
        .s_axis_tdata(axis_tdata),
        .s_axis_tvalid(axis_tvalid),
        .s_axis_tready(axis_tready),
        .o_mclk(o_mclk),
        .o_bclk(o_bclk),
        .o_lrclk(o_lrclk),
        .o_pbdat(o_pbdat),
        .io_i2c_sda(io_i2c_sda),
        .io_i2c_scl(io_i2c_scl)
    );

    // Clock generation
    initial clk_100m = 0;
    always #5 clk_100m = ~clk_100m; // System Clock (100 MHz)

    initial clk_12m = 0;
    always #40.69 clk_12m = ~clk_12m; // Audio Clock (~12.288 MHz)

    // Simulation
    initial begin
        // Init and reset
        rst = 1;
        sel = 0; we = 0; re = 0; addr = 0; wdata = 0;
        axis_tvalid = 0; axis_tdata = 0;
        
        #100;
        rst = 0;
        #100;

        //Force flag to 1, the board thinks it is ready to play
        force uut._codec_init_done = 1'b1;

        // Processador (ARM) turns on I2S via MMIO register
        // Write 1 in CTRL register (address 3) to activate _tx_enable
        @(posedge clk_100m);
        sel = 1; we = 1; addr = 3'd3; wdata = 16'h0001;
        @(posedge clk_100m);
        sel = 0; we = 0;

        #500;

        // DMA wakes up and sends first "sample" (32-bits)
        // Send 0xAAAA (Left) e 0x5555 (Right)
        @(posedge clk_100m);
        axis_tvalid = 1;
        axis_tdata = 32'hAAAA5555; 
        
        // Wait for I2S to accept sample (tready == 1)
        wait(axis_tready);
        @(posedge clk_100m);
        
        // DMA sends a different sample
        axis_tdata = 32'h12345678;
        wait(axis_tready);
        @(posedge clk_100m);
        
        // DMA turns off
        axis_tvalid = 0; 

        // G. Deixamos a simulação correr durante algum tempo para vermos os bits a sair
        #50000;
        $stop;
    end
endmodule