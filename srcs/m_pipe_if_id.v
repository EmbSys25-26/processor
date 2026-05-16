`timescale 1ns / 1ps

`include "constants.vh"

// ============================================================
// IF/ID pipeline register
//
// Sits between the IF and ID stages.
// Standard pipeline register behaviour:
//   - Reset or flush  → clears valid, writes NOP to instruction field
//                       (ensures ID never sees a garbage instruction)
//   - Stall           → register frozen (contents unchanged)
//   - Normal          → captures IF outputs on the rising clock edge: forwards i_valid/i_pc/i_insn to decode
// ============================================================
module pipe_if_id(
    input wire i_clk,
    input wire i_rst,
    input wire i_stall,
    input wire i_flush,
    input wire i_valid,
    (* mark_debug = "true" *)   input wire [15:0] i_pc,
    (* mark_debug = "true" *)   input wire [15:0] i_insn,
    input wire i_pred_taken,
    input wire [15:0] i_pred_target,
    input wire [`GHR_W-1:0] i_lookup_ghr,
    output reg o_valid,
    (* mark_debug = "true" *) output reg [15:0] o_pc,
    (* mark_debug = "true" *)(* max_fanout = 10 *) output reg [15:0] o_insn,
    output reg o_pred_taken,
    output reg [15:0] o_pred_target,
    output reg [`GHR_W-1:0] o_lookup_ghr
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
            o_pred_taken <= 1'b0;
            o_pred_target <= 16'h0000;
            o_lookup_ghr <= {`GHR_W{1'b0}};
        end else if (!i_stall) begin
            o_valid <= i_valid;
            o_pc <= i_pc;
            o_insn <= i_insn;
            o_pred_taken <= i_pred_taken;
            o_pred_target <= i_pred_target;
            o_lookup_ghr <= i_lookup_ghr;
        end
        // If stalled: all outputs hold their current values (implicit register freeze)
    end

endmodule