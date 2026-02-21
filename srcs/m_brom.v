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

    reg [1023:0] _mem_hex_lo;
    reg [1023:0] _mem_hex_hi;

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
        // Optional overrides for synthesis/implementation:
        // -DBROM_MEM_LO_PATH=\"/abs/path/to/mem_lo.hex\"
        // -DBROM_MEM_HI_PATH=\"/abs/path/to/mem_hi.hex\"
`ifdef BROM_MEM_LO_PATH
        _mem_hex_lo = `BROM_MEM_LO_PATH;
        _mem_hex_hi = `BROM_MEM_HI_PATH;
`elsif BRAM_MEM_LO_PATH
        // Backward compatibility with existing board-flow defines.
        _mem_hex_lo = `BRAM_MEM_LO_PATH;
        _mem_hex_hi = `BRAM_MEM_HI_PATH;
`elsif CI
        // CI/local script flow runs from repository root.
        _mem_hex_lo = "srcs/mem/mem_lo.hex";
        _mem_hex_hi = "srcs/mem/mem_hi.hex";
`elsif SIM
        // Vivado behavioral sim launch directory depth.
        _mem_hex_lo = "../../../../srcs/mem/mem_lo.hex";
        _mem_hex_hi = "../../../../srcs/mem/mem_hi.hex";
`else
        // Board-flow default absolute paths (override via BROM_MEM_*_PATH if needed).
        _mem_hex_lo = "/home/josesilvaa/processor/srcs/mem/mem_lo.hex";
        _mem_hex_hi = "/home/josesilvaa/processor/srcs/mem/mem_hi.hex";
`endif
        $readmemh(_mem_hex_lo, _mem_l);
        $readmemh(_mem_hex_hi, _mem_h);
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
