`timescale 1ns / 1ps
module brom_1kb_be(
    input wire i_clk,
    input wire i_rst,
    input wire i_en,
    input wire [9:1] i_addr,
    output wire [7:0] o_dout_h,
    output wire [7:0] o_dout_l
);
/*************************************************************************************
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/
    reg [7:0] _mem_h [0:511];
    reg [7:0] _mem_l [0:511];
    reg [7:0] _dout_h;
    reg [7:0] _dout_l;
    integer _i;
/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/
/*************************************************************************************
 * 2.1 Initialization
 ************************************************************************************/
    initial begin
        for (_i = 0; _i < 512; _i = _i + 1) begin
            _mem_h[_i] = 8'hF0;
            _mem_l[_i] = 8'h00;
        end
        _dout_h = 8'hF0;
        _dout_l = 8'h00;
    end

    initial begin
`ifdef BROM_MEM_LO_PATH
        $readmemh(`BROM_MEM_LO_PATH, _mem_l);
        $readmemh(`BROM_MEM_HI_PATH, _mem_h);
`elsif BRAM_MEM_LO_PATH
        $readmemh(`BRAM_MEM_LO_PATH, _mem_l);
        $readmemh(`BRAM_MEM_HI_PATH, _mem_h);
`elsif CI
        $readmemh("srcs/mem/mem_lo.hex", _mem_l);
        $readmemh("srcs/mem/mem_hi.hex", _mem_h);
`else
        $readmemh("/home/vasco/processor/srcs/mem/mem_lo.hex", _mem_l);
        $readmemh("/home/vasco/processor/srcs/mem/mem_hi.hex", _mem_h);
`endif
    end
/*************************************************************************************
 * 2.2 Instruction Read
 ************************************************************************************/
    always @(posedge i_clk) begin
        if (i_rst) begin
            _dout_h <= 8'hF0;
            _dout_l <= 8'h00;
        end else if (i_en) begin
            _dout_h <= _mem_h[i_addr];
            _dout_l <= _mem_l[i_addr];
        end
    end

    assign o_dout_h = _dout_h;
    assign o_dout_l = _dout_l;
endmodule