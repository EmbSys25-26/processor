`timescale 1ns / 1ps

module bram_1kb_be(
    input wire i_clk,
    input wire i_rst,
    input wire i_en,
    input wire i_we_h,
    input wire i_we_l,
    input wire [9:1] i_addr,
    input wire [7:0] i_din_h,
    input wire [7:0] i_din_l,
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
            _mem_h[_i] = 8'h00;
            _mem_l[_i] = 8'h00;
        end
        _dout_h = 8'h00;
        _dout_l = 8'h00;
    end

/*************************************************************************************
 * 2.2 Data Read / Write
 ************************************************************************************/
    always @(posedge i_clk) begin
        if (~i_rst & i_en) begin
            if (i_we_h) begin
                _mem_h[i_addr] <= i_din_h;
            end
            if (i_we_l) begin
                _mem_l[i_addr] <= i_din_l;
            end
        end
    end

    always @(posedge i_clk) begin
        if (i_rst) begin
            _dout_h <= 8'h00;
            _dout_l <= 8'h00;
        end else if (i_en) begin
            _dout_h <= _mem_h[i_addr];
            _dout_l <= _mem_l[i_addr];
        end
    end

/*************************************************************************************
 * 2.3 Debug regs
 ************************************************************************************/
    always @(posedge i_clk) begin
        if (i_en) begin
            case (i_addr)
                9'd0: _mem0_dbg <= {i_we_h ? i_din_h : _dout_h, i_we_l ? i_din_l : _dout_l};
                9'd1: _mem1_dbg <= {i_we_h ? i_din_h : _dout_h, i_we_l ? i_din_l : _dout_l};
                9'd2: _mem2_dbg <= {i_we_h ? i_din_h : _dout_h, i_we_l ? i_din_l : _dout_l};
                default: ;
            endcase
        end
    end

    assign o_dout_h = _dout_h;
    assign o_dout_l = _dout_l;

endmodule
