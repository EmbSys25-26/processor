`timescale 1ns / 1ps

/*
MEM stage
Mediates data-memory operations and selects final writeback data.
- Drives load/store requests and waits on i_rdy for memory completion.
- Memory operations hold retirement until ready; non-memory ops pass through.
- Preserves control/flag update metadata into the WB path.
*/

module mem_stage(
    input wire i_valid,
    input wire [3:0] i_rd,
    input wire i_rf_we,
    input wire i_lw,
    input wire i_lb,
    input wire i_sw,
    input wire i_sb,
    input wire [15:0] i_d_ad,
    input wire [15:0] i_store_data,
    input wire [15:0] i_wb_pre_data,
    input wire i_flag_we,
    input wire i_new_ccz,
    input wire i_new_ccn,
    input wire i_new_ccc,
    input wire i_new_ccv,
    input wire i_carry_we,
    input wire i_new_c,
    input wire i_updates_cc_hz,
    input wire i_updates_carry_hz,
    input wire i_is_load,
    input wire i_is_iret,
    input wire [15:0] i_data_in,
    input wire i_rdy,

    output wire o_mem_wait,
    output wire o_mem_complete,
    output wire o_sw,
    output wire o_sb,
    output wire o_lw,
    output wire o_lb,
    output wire [15:0] o_d_ad,
    output wire [15:0] o_data_out,
    output wire o_valid,
    output wire [3:0] o_rd,
    output wire o_rf_we,
    output wire [15:0] o_wb_data,
    output wire o_flag_we,
    output wire o_new_ccz,
    output wire o_new_ccn,
    output wire o_new_ccc,
    output wire o_new_ccv,
    output wire o_carry_we,
    output wire o_new_c,
    output wire o_updates_cc_hz,
    output wire o_updates_carry_hz,
    output wire o_is_iret
);

/*************************************************************************************
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/
    wire _is_mem_op;

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

/*************************************************************************************
 * 2.1 DM access
 ************************************************************************************/
    assign _is_mem_op = i_lw | i_lb | i_sw | i_sb;
    assign o_mem_wait = i_valid & _is_mem_op & ~i_rdy;
    assign o_mem_complete = i_valid & (~_is_mem_op | i_rdy);

/*************************************************************************************
 * 2.2 External Bus
 ************************************************************************************/
    assign o_sw = i_valid & i_sw;
    assign o_sb = i_valid & i_sb;
    assign o_lw = i_valid & i_lw;
    assign o_lb = i_valid & i_lb;
    assign o_d_ad = i_d_ad;
    assign o_data_out = i_store_data;

/*************************************************************************************
 * 2.3 WB Candidate
 ************************************************************************************/
    assign o_valid = i_valid & (~_is_mem_op | i_rdy);
    assign o_rd = i_rd;
    assign o_rf_we = i_rf_we;
    assign o_wb_data = i_is_load ? i_data_in : i_wb_pre_data;
    assign o_flag_we = i_flag_we;
    assign o_new_ccz = i_new_ccz;
    assign o_new_ccn = i_new_ccn;
    assign o_new_ccc = i_new_ccc;
    assign o_new_ccv = i_new_ccv;
    assign o_carry_we = i_carry_we;
    assign o_new_c = i_new_c;
    assign o_updates_cc_hz = i_updates_cc_hz;
    assign o_updates_carry_hz = i_updates_carry_hz;
    assign o_is_iret = i_is_iret;

endmodule