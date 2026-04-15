`timescale 1ns / 1ps

// ============================================================
// MEM (Memory Access) stage
//
// This stage is the interface between the pipeline and the
// external data memory bus.
//
// Behaviour:
//   - If the current instruction is a memory operation (LW/LB/SW/SB):
//       The stage asserts the appropriate strobe (o_lw/o_lb/o_sw/o_sb)
//       and drives the address and store data onto the external bus.
//       It then waits until i_rdy is asserted by the memory controller.
//       While waiting, o_mem_wait is asserted → the hazard unit stalls
//       the entire pipeline upstream.
//       o_valid is de-asserted until i_rdy arrives; when i_rdy arrives
//       the instruction retires (o_valid = 1) and the load data is
//       selected as the writeback value.
//   - If no memory operation: the instruction passes straight through
//       (o_mem_wait = 0, o_valid = i_valid, o_data = i_wb_pre_data).
//
// Writeback data selection:
//   Loads: o_data = i_data_in (data received from memory)
//   Others: o_data = i_wb_pre_data (ALU result from EX stage)

// ============================================================
module mem_stage(
    input wire i_valid,
    input wire [3:0] i_rd,
    input wire i_rf_we,
    input wire i_lw,
    input wire i_lb,
    input wire i_sw,
    input wire i_sb,
    input wire [15:0] i_d_ad,           // Data-memory byte address from EX
    input wire [15:0] i_store_data,     // Data to write to memory (for stores)
    input wire [15:0] i_wb_pre_data,    // ALU result for writeback (for non-loads)
    input wire i_is_load,
    input wire [15:0] i_data_in,        // Load data returned by data memory
    input wire i_rdy,                   // Data memory ready (load/store complete)
    input wire [15:0] i_pc_dbg,

    output wire o_mem_wait,             // 1 = pipeline stall: waiting for memory
    output wire o_sw,
    output wire o_sb,
    output wire o_lw,
    output wire o_lb,
    output wire [15:0] o_d_ad,          // Address driven to external data memory bus
    output wire [15:0] o_data_out,      // Store data driven to external data memory bus
    output wire o_valid,                // Instruction has retired from MEM
    output wire [3:0] o_rd,
    output wire o_rf_we,
    output wire [15:0] o_data       // Final writeback value (load result or ALU result)
);

/*************************************************************************************
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/

    wire _is_mem_op;    // 1 if the instruction accesses data memory

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

/*************************************************************************************
 * 2.1 DM access
 ************************************************************************************/

    // Any of the four memory strobes means this is a memory operation
    assign _is_mem_op = i_lw | i_lb | i_sw | i_sb;

    // Pipeline stall: instruction is valid, it's a memory op, and memory isn't ready yet
    assign o_mem_wait     = i_valid & _is_mem_op & ~i_rdy;


/*************************************************************************************
 * 2.2 External Bus
 ************************************************************************************/

    // Drive memory control signals onto the external bus (valid-gated)
    assign o_sw       = i_valid & i_sw;
    assign o_sb       = i_valid & i_sb;
    assign o_lw       = i_valid & i_lw;
    assign o_lb       = i_valid & i_lb;
    assign o_d_ad     = i_d_ad;
    assign o_data_out = i_store_data;       // For stores: the value to be written

/*************************************************************************************
 * 2.3 WB Candidate
 ************************************************************************************/

    // Instruction is valid for WB only when the memory operation (if any) is complete
    assign o_valid   = i_valid & (~_is_mem_op | i_rdy);
    assign o_rd      = i_rd;
    assign o_rf_we   = i_rf_we;
    // Select final writeback data: load instructions get memory data, others get ALU result
    assign o_data = i_is_load ? i_data_in : i_wb_pre_data;


endmodule