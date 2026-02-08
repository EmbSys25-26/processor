`timescale 1ns / 1ps
`default_nettype none

module tb_soc_byte_lane;

/*************************************************************************************
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/
    reg _clk = 1'b0;
    reg _rst = 1'b1;
    reg [3:0] _par_i = 4'h0;
    reg _uart_rx = 1'b1;

    wire [3:0] _par_o;
    wire _uart_tx;

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

/*************************************************************************************
 * 2.1 DUT and Clock
 ************************************************************************************/
    always #5 _clk = ~_clk;

    soc dut (
        .i_clk(_clk),
        .i_rst(_rst),
        .i_par_i(_par_i),
        .o_par_o(_par_o),
        .i_uart_rx(_uart_rx),
        .o_uart_tx(_uart_tx)
    );

/*************************************************************************************
 * 2.2 Directed Byte-Lane Checks
 ************************************************************************************/
    initial begin
        repeat (3) @(posedge _clk);
        _rst = 1'b0;
        @(posedge _clk);

        // Freeze CPU requests; drive SoC memory-side signals directly.
        force dut._sw = 1'b0;
        force dut._sb = 1'b0;
        force dut._lw = 1'b0;
        force dut._lb = 1'b0;

        // Seed word index 1 with 0x1234.
        force dut._d_ad = 16'h0002;
        force dut._cpu_do = 16'h1234;
        force dut._sw = 1'b1;
        @(posedge _clk);
        #1;
        force dut._sw = 1'b0;

        // SB to low lane (lane select comes from d_ad[1]).
        force dut._d_ad = 16'h0002;
        force dut._cpu_do = 16'hABCD;
        force dut._sb = 1'b1;
        @(posedge _clk);
        #1;
        force dut._sb = 1'b0;

        $display("WAVE lane write idx1 hi=0x%02h lo=0x%02h", dut.u_mem._mem_h[9'd1], dut.u_mem._mem_l[9'd1]);
        if (dut.u_mem._mem_h[9'd1] !== 8'h12 || dut.u_mem._mem_l[9'd1] !== 8'hCD) begin
            $display("FAIL SB lane-select/write behavior");
            $fatal(1);
        end

        // Set word index 0 to 0x5678 and validate LB high-lane zero extension.
        force dut._d_ad = 16'h0000;
        force dut._cpu_do = 16'h5678;
        force dut._sw = 1'b1;
        @(posedge _clk);
        #1;
        force dut._sw = 1'b0;

        force dut._d_ad = 16'h0000;
        force dut._lb = 1'b1;
        @(posedge _clk);
        #1;
        $display("WAVE lb high lane cpu_di=0x%04h", dut._cpu_di);
        if (dut._cpu_di !== 16'h0056) begin
            $display("FAIL LB high-lane read expected 0x0056 got 0x%04h", dut._cpu_di);
            $fatal(1);
        end
        force dut._lb = 1'b0;

        // Validate LB low-lane zero extension from word index 1.
        force dut._d_ad = 16'h0002;
        force dut._lb = 1'b1;
        @(posedge _clk);
        #1;
        $display("WAVE lb low lane cpu_di=0x%04h", dut._cpu_di);
        if (dut._cpu_di !== 16'h00CD) begin
            $display("FAIL LB low-lane read expected 0x00CD got 0x%04h", dut._cpu_di);
            $fatal(1);
        end

        release dut._sw;
        release dut._sb;
        release dut._lw;
        release dut._lb;
        release dut._d_ad;
        release dut._cpu_do;

        $display("PASS tb_soc_byte_lane");
        $finish;
    end

endmodule
