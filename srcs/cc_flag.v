`timescale 1ns / 1ps

// ============================================================
// CC Register with bypass
//
// Stores the architectural condition codes (Z, N, C, V) and
// the carry bit used by ADC/SBC.
//
// Problem solved:
//   When a flag-updating instruction (CMP, ADD, etc.) is in EX
//   and a branch (BLT, BEQ, etc.) is in ID, both need the flags
//   in the same cycle. A plain register would give the BDU the
//   old flags (updated only on the next clock edge).
//
// Solution - write-first bypass (same principle as the regfile):
//   - Registers update synchronously on posedge clk (no comb loop)
//   - Outputs are combinational: if i_flag_we is asserted this
//     cycle, the new values are forwarded directly to the output
//     bypassing the register. Otherwise the stored value is used.
//
// This means the BDU in ID always sees the correct, up-to-date
// flags regardless of whether EX is updating them this cycle.
// ============================================================
module cc_flag (
    input  wire i_clk,
    input  wire i_rst,

    // Write port - driven by EX stage
    input  wire i_flag_we,      // EX is updating flags this cycle
    input  wire i_new_ccz,      // New Zero flag
    input  wire i_new_ccn,      // New Negative flag
    input  wire i_new_ccc,      // New Carry flag
    input  wire i_new_ccv,      // New Overflow flag
    input  wire i_carry_we,     // EX is updating carry bit this cycle
    input  wire i_new_c,        // New carry bit (for ADC/SBC)

    // Read port - with bypass, seen by ID (BDU) and EX (ADC/SBC)
    output wire o_ccz,
    output wire o_ccn,
    output wire o_ccc,
    output wire o_ccv,
    output wire o_c
);

/*************************************************************************************
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/

    reg _ccz;
    reg _ccn;
    reg _ccc;
    reg _ccv;
    reg _c;

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

/*************************************************************************************
 * 2.1 Synchronous Write - no combinational loop
 *
 * Flags update on the clock edge, exactly as before.
 * The bypass on the read side means this is safe - no path
 * from output back to input exists combinationally.
 ************************************************************************************/
    always @(posedge i_clk) begin
        if (i_rst) begin
            _ccz <= 1'b0;
            _ccn <= 1'b0;
            _ccc <= 1'b0;
            _ccv <= 1'b0;
            _c   <= 1'b0;
        end else begin
            if (i_flag_we) begin
                _ccz <= i_new_ccz;
                _ccn <= i_new_ccn;
                _ccc <= i_new_ccc;
                _ccv <= i_new_ccv;
            end
            if (i_carry_we) begin
                _c <= i_new_c;
            end
        end
    end
    
    assign o_c   = _c;

/*************************************************************************************
 * 2.2 Combinational Read with Bypass
 *
 * If EX is writing flags right now (i_flag_we=1), forward the
 * new value directly to the output - same cycle, no wait.
 * Otherwise, return the stored register value.
 *
 * This is identical in principle to the write-first register file:
 *   assign o_ra = (we && wa==ra) ? i_wd : _mem[ra];
 ************************************************************************************/
    // Pure registered outputs — no write-first bypass.
    // The CC hazard (CMP in EX, BX in ID) is now resolved by a 1-cycle
    // stall in the hazard unit instead of a combinational bypass here.
    // This breaks the critical path EX→CC→BDU→PC that violated timing.
    assign o_ccz = _ccz;
    assign o_ccn = _ccn;
    assign o_ccc = _ccc;
    assign o_ccv = _ccv;
      
endmodule