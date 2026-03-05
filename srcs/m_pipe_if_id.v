`timescale 1ns / 1ps

`include "constants.vh"

/*
IF/ID pipeline register
Captures fetched PC and instruction between IF and ID.
- Flush/reset clears valid and injects NOP into the instruction field.
- Stall freezes current contents (no register update).
- Otherwise forwards i_valid/i_pc/i_insn to decode.
*/

module pipe_if_id(
    input wire i_clk,
    input wire i_rst,
    input wire i_stall,
    input wire i_flush,
    input wire i_valid,
    input wire [15:0] i_pc,
    input wire [15:0] i_insn,
    output reg o_valid,
    output reg [15:0] o_pc,
    output reg [15:0] o_insn
);

/*************************************************************************************
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

/*************************************************************************************
 * 2.1 IF/ID Register
 ************************************************************************************/
    always @(posedge i_clk) begin
        if (i_rst || i_flush) begin
            o_valid <= 1'b0;
            o_pc <= 16'h0000;
            o_insn <= `CPU_NOP_INSN;
        end else if (!i_stall) begin
            o_valid <= i_valid;
            o_pc <= i_pc;
            o_insn <= i_insn;
        end
    end

endmodule
