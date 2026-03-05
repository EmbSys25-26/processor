`timescale 1ns / 1ps

/*
WB stage
Commits architectural updates into the register/flag state.
- Applies register writeback and flag/carry updates when instruction is valid.
- Bubbles/flushes are naturally blocked by valid-gating.
- Emits iret commit event for interrupt-depth bookkeeping.
*/

module wb_stage(
    input wire i_valid,
    input wire [3:0] i_rd,
    input wire i_rf_we,
    input wire [15:0] i_wb_data,
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

    output wire o_rf_we,
    output wire [3:0] o_wa,
    output wire [15:0] o_wd,
    output wire o_flag_we,
    output wire o_new_ccz,
    output wire o_new_ccn,
    output wire o_new_ccc,
    output wire o_new_ccv,
    output wire o_carry_we,
    output wire o_new_c,
    output wire o_updates_cc_hz,
    output wire o_updates_carry_hz,
    output wire o_iret_event
);

/*************************************************************************************
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

/*************************************************************************************
 * 2.1 Writeback Outputs
 ************************************************************************************/
    assign o_rf_we = i_valid & i_rf_we;
    assign o_wa = i_rd;
    assign o_wd = i_wb_data;

    assign o_flag_we = i_valid & i_flag_we;
    assign o_new_ccz = i_new_ccz;
    assign o_new_ccn = i_new_ccn;
    assign o_new_ccc = i_new_ccc;
    assign o_new_ccv = i_new_ccv;

    assign o_carry_we = i_valid & i_carry_we;
    assign o_new_c = i_new_c;

    assign o_updates_cc_hz = i_valid & i_updates_cc_hz;
    assign o_updates_carry_hz = i_valid & i_updates_carry_hz;
    assign o_iret_event = i_valid & i_is_iret;

endmodule
