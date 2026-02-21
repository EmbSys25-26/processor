`timescale 1ns / 1ps
`default_nettype none

module tb_soc_word_rw;

/*************************************************************************************
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/
    reg _clk = 1'b0;
    reg _rst = 1'b1;
    reg [3:0] _par_i = 4'h0;
    reg _uart_rx = 1'b1;
    tri1 _i2c_sda;
    tri1 _i2c_scl;

    wire [3:0] _par_o;
    wire _uart_tx;

    reg [15:0] _rd0;
    reg [15:0] _rd1;

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
        .o_uart_tx(_uart_tx),
        .io_i2c_sda(_i2c_sda),
        .io_i2c_scl(_i2c_scl)
    );

/*************************************************************************************
 * 2.2 Word Read/Write Round-Trip Checks
 ************************************************************************************/
    initial begin
        repeat (3) @(posedge _clk);
        _rst = 1'b0;
        @(posedge _clk);

        // Freeze CPU bus requests and drive SoC memory datapath directly.
        force dut._sw = 1'b0;
        force dut._sb = 1'b0;
        force dut._lw = 1'b0;
        force dut._lb = 1'b0;

        // Write word 0xCAFE at word index 3 (byte address 0x0006).
        force dut._d_ad = 16'h0006;
        force dut._cpu_do = 16'hCAFE;
        force dut._sw = 1'b1;
        @(posedge _clk);
        #1;
        force dut._sw = 1'b0;

        // Read back as LW.
        force dut._lw = 1'b1;
        @(posedge _clk);
        @(posedge _clk);
        #1;
        _rd0 = dut._cpu_di;
        force dut._lw = 1'b0;

        // Write a second word at a different address to ensure no alias.
        force dut._d_ad = 16'h0008;
        force dut._cpu_do = 16'h1357;
        force dut._sw = 1'b1;
        @(posedge _clk);
        #1;
        force dut._sw = 1'b0;

        // Read second word.
        force dut._lw = 1'b1;
        @(posedge _clk);
        @(posedge _clk);
        #1;
        _rd1 = dut._cpu_di;
        force dut._lw = 1'b0;

        $display("WAVE word-rw idx3=0x%04h idx4=0x%04h", _rd0, _rd1);

        if (_rd0 !== 16'hCAFE) begin
            $display("FAIL tb_soc_word_rw: LW mismatch at idx3 expected=0xCAFE got=0x%04h", _rd0);
            $fatal(1);
        end

        if (_rd1 !== 16'h1357) begin
            $display("FAIL tb_soc_word_rw: LW mismatch at idx4 expected=0x1357 got=0x%04h", _rd1);
            $fatal(1);
        end

        // Check memory arrays directly for evidence.
        if ({dut.u_mem._mem_h[9'd3], dut.u_mem._mem_l[9'd3]} !== 16'hCAFE) begin
            $display("FAIL tb_soc_word_rw: RAM content mismatch idx3");
            $fatal(1);
        end
        if ({dut.u_mem._mem_h[9'd4], dut.u_mem._mem_l[9'd4]} !== 16'h1357) begin
            $display("FAIL tb_soc_word_rw: RAM content mismatch idx4");
            $fatal(1);
        end

        release dut._sw;
        release dut._sb;
        release dut._lw;
        release dut._lb;
        release dut._d_ad;
        release dut._cpu_do;

        $display("PASS tb_soc_word_rw");
        $finish;
    end

endmodule
