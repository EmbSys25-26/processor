`timescale 1ns / 1ps

`include "constants.vh"

(* keep_hierarchy = "true", dont_touch = "true" *)
module regfile16x16(
    input wire i_clk,
    input wire i_we,
    input wire [3:0] i_wa,
    input wire [3:0] i_ra,
    input wire [3:0] i_rb,
    input wire [`CPU_N:0] i_wd,
    output wire [`CPU_N:0] o_ra,
    output wire [`CPU_N:0] o_rb
);

/*************************************************************************************
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/
    reg [`CPU_N:0] _mem [15:0];

    (* mark_debug = "true" *) reg [15:0] _r0;
    (* mark_debug = "true" *) reg [15:0] _a0;
    (* mark_debug = "true" *) reg [15:0] _a1;
    (* mark_debug = "true" *) reg [15:0] _a2;
    (* mark_debug = "true" *) reg [15:0] _t0;
    (* mark_debug = "true" *) reg [15:0] _t1;
    (* mark_debug = "true" *) reg [15:0] _t2;
    (* mark_debug = "true" *) reg [15:0] _t3;
    (* mark_debug = "true" *) reg [15:0] _s0;
    (* mark_debug = "true" *) reg [15:0] _s1;
    (* mark_debug = "true" *) reg [15:0] _s2;
    (* mark_debug = "true" *) reg [15:0] _s3;
    (* mark_debug = "true" *) reg [15:0] _fp;
    (* mark_debug = "true" *) reg [15:0] _sp;
    (* mark_debug = "true" *) reg [15:0] _lr;
    (* mark_debug = "true" *) reg [15:0] _gp;

    reg [4:0] _i;

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

/*************************************************************************************
 * 2.1 Debug Mirrors
 ************************************************************************************/
    always @(*) begin
        _r0 = _mem[0];
        _a0 = _mem[1];
        _a1 = _mem[2];
        _a2 = _mem[3];
        _t0 = _mem[4];
        _t1 = _mem[5];
        _t2 = _mem[6];
        _t3 = _mem[7];
        _s0 = _mem[8];
        _s1 = _mem[9];
        _s2 = _mem[10];
        _s3 = _mem[11];
        _fp = _mem[12];
        _sp = _mem[13];
        _lr = _mem[14];
        _gp = _mem[15];
    end

/*************************************************************************************
 * 2.2 Reset/Init and Write Path
 ************************************************************************************/
    initial begin
        for (_i = 0; _i < 16; _i = _i + 1) begin
            _mem[_i] = 16'h0000;
        end
    end

    always @(posedge i_clk) begin
        if (i_we && (i_wa != 4'b0000)) begin
            _mem[i_wa] <= i_wd;
        end
    end

/*************************************************************************************
 * 2.3 Read Path
 ************************************************************************************/
    assign o_ra = _mem[i_ra];
    assign o_rb = _mem[i_rb];

endmodule