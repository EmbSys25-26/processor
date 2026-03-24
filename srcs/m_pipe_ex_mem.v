`timescale 1ns / 1ps

// ============================================================
// EX/MEM pipeline register
//
// Captures the EX stage outputs between the Execute and Memory
// access stages.
//
// Flush behaviour: the EX/MEM register is flushed on IRQ accept
// (_accept_irq) to squash the instruction that completed EX while
// the interrupt is being taken.  Note that it is NOT flushed on
// branch commits — by the time a branch fires in ID, the instruction
// that was in EX is unrelated to the branch and should retire normally.
//
// Stall behaviour: frozen during a MEM wait (_stall_ex), keeping
// the same instruction visible to MEM until it completes.
// ============================================================
module pipe_ex_mem(
    input wire i_clk,
    input wire i_rst,
    input wire i_stall,             // Freeze: MEM wait in progress
    input wire i_flush,             // Squash: IRQ accepted
    input wire i_valid,
    input wire [15:0] i_pc,
    input wire [3:0] i_rd,
    input wire i_rf_we,
    input wire i_lw,
    input wire i_lb,
    input wire i_sw,
    input wire i_sb,
    input wire [15:0] i_d_ad,       // Data-memory address from EX
    input wire [15:0] i_store_data, // Store data from EX
    input wire [15:0] i_wb_pre_data,// Pre-writeback ALU result from EX
    input wire i_is_load,
    output reg o_valid,
    output reg [15:0] o_pc,
    output reg [3:0] o_rd,
    output reg o_rf_we,
    output reg o_lw,
    output reg o_lb,
    output reg o_sw,
    output reg o_sb,
    output reg [15:0] o_d_ad,
    output reg [15:0] o_store_data,
    output reg [15:0] o_wb_pre_data,
    output reg o_is_load
);

/*************************************************************************************
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

/*************************************************************************************
 * 2.1 EX/MEM Register
 ************************************************************************************/
    always @(posedge i_clk) begin
        if (i_rst || i_flush) begin
            // Clear to NOP on reset or IRQ accept
            o_valid            <= 1'b0;
            o_pc               <= 16'h0000;
            o_rd               <= 4'h0;
            o_rf_we            <= 1'b0;
            o_lw               <= 1'b0;
            o_lb               <= 1'b0;
            o_sw               <= 1'b0;
            o_sb               <= 1'b0;
            o_d_ad             <= 16'h0000;
            o_store_data       <= 16'h0000;
            o_wb_pre_data      <= 16'h0000;
            o_is_load          <= 1'b0;
        end else if (!i_stall) begin
            // Normal advance: capture all EX outputs
            o_valid            <= i_valid;
            o_pc               <= i_pc;
            o_rd               <= i_rd;
            o_rf_we            <= i_rf_we;
            o_lw               <= i_lw;
            o_lb               <= i_lb;
            o_sw               <= i_sw;
            o_sb               <= i_sb;
            o_d_ad             <= i_d_ad;
            o_store_data       <= i_store_data;
            o_wb_pre_data      <= i_wb_pre_data;
            o_is_load          <= i_is_load;
        end
        // If stalled: hold all outputs frozen
    end

endmodule