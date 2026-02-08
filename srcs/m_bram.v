`timescale 1ns / 1ps

module bram_1kb_be(
    input wire i_clk,
    input wire i_rst,
    input wire i_a_en,
    input wire [9:1] i_a_addr,
    output wire [7:0] o_a_dout_h,
    output wire [7:0] o_a_dout_l,
    input wire i_b_en,
    input wire i_b_we_h,
    input wire i_b_we_l,
    input wire [9:1] i_b_addr,
    input wire [7:0] i_b_din_h,
    input wire [7:0] i_b_din_l,
    output wire [7:0] o_b_dout_h,
    output wire [7:0] o_b_dout_l
);

/*************************************************************************************
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/
    reg [7:0] _mem_h [0:511];
    reg [7:0] _mem_l [0:511];

    reg [7:0] _a_dout_h;
    reg [7:0] _a_dout_l;
    reg [7:0] _b_dout_h;
    reg [7:0] _b_dout_l;

    integer _i;

    reg [1023:0] _mem_hex_lo;
    reg [1023:0] _mem_hex_hi;

    (* mark_debug = "true" *) reg [15:0] _mem0_dbg;
    (* mark_debug = "true" *) reg [15:0] _mem1_dbg;
    (* mark_debug = "true" *) reg [15:0] _mem2_dbg;

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
    end

    initial begin
        // Optional overrides for synthesis/implementation:
        // -DBRAM_MEM_LO_PATH=\"/abs/path/to/mem_lo.hex\"
        // -DBRAM_MEM_HI_PATH=\"/abs/path/to/mem_hi.hex\"
`ifdef BRAM_MEM_LO_PATH
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
        // Board-flow default absolute paths (override via BRAM_MEM_*_PATH if needed).
        _mem_hex_lo = "/home/josesilvaa/processor/srcs/mem/mem_lo.hex";
        _mem_hex_hi = "/home/josesilvaa/processor/srcs/mem/mem_hi.hex";
`endif
        $readmemh(_mem_hex_lo, _mem_l);
        $readmemh(_mem_hex_hi, _mem_h);
    end

/*************************************************************************************
 * 2.2 Port A (Instruction)
 ************************************************************************************/
    always @(posedge i_clk) begin
        if (i_rst) begin
            _a_dout_h <= 8'hF0;
            _a_dout_l <= 8'h00;
        end else if (i_a_en) begin
            _a_dout_h <= _mem_h[i_a_addr];
            _a_dout_l <= _mem_l[i_a_addr];
        end
    end

/*************************************************************************************
 * 2.3 Port B (Data)
 ************************************************************************************/
    always @(posedge i_clk) begin
        if (~i_rst & i_b_en) begin
            if (i_b_we_h) begin
                _mem_h[i_b_addr] <= i_b_din_h;
            end
            if (i_b_we_l) begin
                _mem_l[i_b_addr] <= i_b_din_l;
            end
        end
    end

    always @(posedge i_clk) begin
        if (i_rst) begin
            _b_dout_h <= 8'h00;
            _b_dout_l <= 8'h00;
        end else if (i_b_en) begin
            _b_dout_h <= _mem_h[i_b_addr];
            _b_dout_l <= _mem_l[i_b_addr];
        end
    end

/*************************************************************************************
 * 2.4 Debug regs
 ************************************************************************************/
    always @(posedge i_clk) begin
        if (i_b_en) begin
            case (i_b_addr)
                9'd0: _mem0_dbg <= {i_b_we_h ? i_b_din_h : _b_dout_h, i_b_we_l ? i_b_din_l : _b_dout_l};
                9'd1: _mem1_dbg <= {i_b_we_h ? i_b_din_h : _b_dout_h, i_b_we_l ? i_b_din_l : _b_dout_l};
                9'd2: _mem2_dbg <= {i_b_we_h ? i_b_din_h : _b_dout_h, i_b_we_l ? i_b_din_l : _b_dout_l};
                default: ;
            endcase
        end
    end

    assign o_a_dout_h = _a_dout_h;
    assign o_a_dout_l = _a_dout_l;
    assign o_b_dout_h = _b_dout_h;
    assign o_b_dout_l = _b_dout_l;

endmodule
