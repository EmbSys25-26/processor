`timescale 1ns / 1ps

// ============================================================
// MEM/WB pipeline register
//
// Captures the MEM stage outputs between the Memory access and
// Write-Back stages.
//
// In the current design, this register is never stalled or
// flushed during normal operation (both inputs are tied to 0 at
// the instantiation site in cpu.v).  The always block handles
// reset only.  This is because:
//   - Once an instruction completes MEM (i_rdy asserted), it is
//     guaranteed to retire — there is no mechanism to abort it.
//   - The MEM stage holds the pipeline until i_rdy arrives, so
//     by the time data enters this register, the instruction is
//     already committed to retiring.
// The stall/flush ports are present for structural consistency
// with the other pipeline registers and potential future use.
// ============================================================
module pipe_mem_wb(
    input wire i_clk,
    input wire i_rst,
    input wire i_stall,             // Unused in current implementation (tied to 0)
    input wire i_flush,             // Unused in current implementation (tied to 0)
    input wire i_valid,
    input wire [3:0] i_rd,
    input wire i_rf_we,
    input wire [15:0] i_wb_data,    // Final writeback data (load result or ALU result)
    input wire i_flag_we,
    input wire i_new_ccz,
    input wire i_new_ccn,
    input wire i_new_ccc,
    input wire i_new_ccv,
    input wire i_carry_we,
    input wire i_new_c,
    input wire i_updates_cc_hz,
    input wire i_updates_carry_hz,
    input wire i_is_iret,
    output reg o_valid,
    output reg [3:0] o_rd,
    output reg o_rf_we,
    output reg [15:0] o_wb_data,
    output reg o_flag_we,
    output reg o_new_ccz,
    output reg o_new_ccn,
    output reg o_new_ccc,
    output reg o_new_ccv,
    output reg o_carry_we,
    output reg o_new_c,
    output reg o_updates_cc_hz,
    output reg o_updates_carry_hz,
    output reg o_is_iret
);

/*************************************************************************************
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

/*************************************************************************************
 * 2.1 MEM/WB Register
 ************************************************************************************/
    always @(posedge i_clk) begin
        if (i_rst || i_flush) begin
            // Clear to NOP on reset (or theoretical flush)
            o_valid            <= 1'b0;
            o_rd               <= 4'h0;
            o_rf_we            <= 1'b0;
            o_wb_data          <= 16'h0000;
            o_flag_we          <= 1'b0;
            o_new_ccz          <= 1'b0;
            o_new_ccn          <= 1'b0;
            o_new_ccc          <= 1'b0;
            o_new_ccv          <= 1'b0;
            o_carry_we         <= 1'b0;
            o_new_c            <= 1'b0;
            o_updates_cc_hz    <= 1'b0;
            o_updates_carry_hz <= 1'b0;
            o_is_iret          <= 1'b0;
        end else if (!i_stall) begin
            // Normal advance: capture MEM outputs for the WB stage
            o_valid            <= i_valid;
            o_rd               <= i_rd;
            o_rf_we            <= i_rf_we;
            o_wb_data          <= i_wb_data;
            o_flag_we          <= i_flag_we;
            o_new_ccz          <= i_new_ccz;
            o_new_ccn          <= i_new_ccn;
            o_new_ccc          <= i_new_ccc;
            o_new_ccv          <= i_new_ccv;
            o_carry_we         <= i_carry_we;
            o_new_c            <= i_new_c;
            o_updates_cc_hz    <= i_updates_cc_hz;
            o_updates_carry_hz <= i_updates_carry_hz;
            o_is_iret          <= i_is_iret;
        end
    end

endmodule