`timescale 1ns / 1ps

// ============================================================
// WB (Write-Back) stage
//
// Final pipeline stage.  All outputs are combinational and
// valid-gated (Bubbles/flushes are naturally blocked) — the 
// actual commits (register write, flag update,carry update) 
// happen in the top-level cpu.v always blocks that
// are driven by these outputs.
//
// The WB stage itself is stateless; it just asserts the right
// write-enable signals and presents the correct data/address.
//
// o_iret_event is a single-cycle pulse that the top-level uses
// to decrement the IRQ nesting depth counter: interrupt-depth 
// bookkeeping.
// ============================================================
module wb_stage(
    input wire i_valid,
    input wire [3:0] i_rd,
    input wire i_rf_we,
    input wire [15:0] i_wb_data,    // Final writeback value from MEM stage
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

    output wire o_rf_we,            // Write-enable to the register file
    output wire [3:0] o_wa,         // Write address (destination register)
    output wire [15:0] o_wd,        // Write data
    output wire o_flag_we,          // Update condition-code flags
    output wire o_new_ccz,
    output wire o_new_ccn,
    output wire o_new_ccc,
    output wire o_new_ccv,
    output wire o_carry_we,         // Update carry bit
    output wire o_new_c,
    output wire o_updates_cc_hz,    // Hazard hint (still needed for back-to-back tracking)
    output wire o_updates_carry_hz,
    output wire o_iret_event        // IRET has committed: decrement IRQ depth
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

    // Register file write: valid-gated so bubbles never commit spurious writes
    assign o_rf_we = i_valid & i_rf_we;
    assign o_wa    = i_rd;          // Destination register address
    assign o_wd    = i_wb_data;     // Data to write

    // Condition-code update: valid-gated
    assign o_flag_we  = i_valid & i_flag_we;
    assign o_new_ccz  = i_new_ccz;
    assign o_new_ccn  = i_new_ccn;
    assign o_new_ccc  = i_new_ccc;
    assign o_new_ccv  = i_new_ccv;

    // Carry update: valid-gated
    assign o_carry_we = i_valid & i_carry_we;
    assign o_new_c    = i_new_c;

    // Hazard hints: valid-gated so hazard unit doesn't see phantom CC/carry updates
    assign o_updates_cc_hz    = i_valid & i_updates_cc_hz;
    assign o_updates_carry_hz = i_valid & i_updates_carry_hz;

    // IRET event pulse: valid-gated; signals to the top-level that an ISR is returning
    assign o_iret_event = i_valid & i_is_iret;

endmodule