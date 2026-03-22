`timescale 1ns / 1ps

module tb_bram_latency;

    reg         clk;
    reg         rst;
    reg         en;
    reg         we_h;
    reg         we_l;
    reg  [9:1]  addr;
    reg  [7:0]  din_h;
    reg  [7:0]  din_l;
    wire [7:0]  dout_h;
    wire [7:0]  dout_l;

    integer cycle_count;
    integer start_cycle;

    reg load_req;
    reg load_req_d;

    bram_1kb_be uut (
        .i_clk(clk),
        .i_rst(rst),
        .i_en(en),
        .i_we_h(we_h),
        .i_we_l(we_l),
        .i_addr(addr),
        .i_din_h(din_h),
        .i_din_l(din_l),
        .o_dout_h(dout_h),
        .o_dout_l(dout_l)
    );

    /******** CLOCK ********/
    always #5 clk = ~clk;

    /******** CYCLE COUNTER ********/
    always @(posedge clk) begin
        cycle_count <= cycle_count + 1;
    end

    /******** LOAD TRACKING ********/
    always @(posedge clk) begin
        load_req_d <= load_req;

        // mark when request is issued
        if (load_req) begin
            start_cycle <= cycle_count;
        end

        // detect when data returns (1 cycle later)
        if (load_req_d) begin
            $display("LOAD complete @ cycle %0d | latency = %0d | data = %h%h",
                     cycle_count,
                     cycle_count - start_cycle,
                     dout_h, dout_l);
        end
    end

    /******** TEST ********/
    initial begin
        clk = 0;
        rst = 1;
        en  = 0;
        we_h = 0;
        we_l = 0;
        addr = 0;
        din_h = 0;
        din_l = 0;
        cycle_count = 0;
        load_req = 0;
        load_req_d = 0;

        #20;
        rst = 0;

        /******** WRITE KNOWN VALUE ********/
        @(posedge clk);
        en   = 1;
        we_h = 1;
        we_l = 1;
        addr = 9'd5;
        din_h = 8'hAA;
        din_l = 8'h55;

        @(posedge clk);
        we_h = 0;
        we_l = 0;

        /******** ISSUE SINGLE-CYCLE LOAD ********/
        @(posedge clk);
        addr = 9'd5;
        load_req = 1;

        @(posedge clk);
        load_req = 0;

        /******** WAIT ********/
        repeat (5) @(posedge clk);

        $finish;
    end

endmodule