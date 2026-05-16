`timescale 1ns / 1ps

// ============================================================
// Hazard Unit
//
// Pure combinational unit. Monitors the pipeline stages and
// computes all stall, bubble, and flush signals required to
// maintain correct in-order execution.
//
// Hazard types detected:
//
//   1. RAW (Read-After-Write) data hazard:
//      Resolved by the forwarding unit in the EX stage.
//      No stall is required for standard RAW hazards.
//      Only the load-use case still requires a stall (see point 2).
//
//   2. Load-use hazard:
//      A load instruction in EX/ID-EX will not have its result
//      available until after the MEM stage. If the immediately
//      following instruction needs that value, an extra stall
//      cycle is required (even with forwarding this would be 1
//      stall; here it falls under the RAW detection as well,
//      but is separately identified).
//      Detection: ID/EX is a load AND its destination matches
//      what the current ID instruction reads.
//
// Control outputs:
//
//   o_stall_if   - Stall the IF stage (freeze PC register)
//   o_stall_id   - Stall the ID stage (freeze IF/ID register)
//   o_stall_ex   - Stall the EX stage (freeze ID/EX and EX/MEM)
//   o_flush_ifid - Flush IF/ID (redirect or IRQ accepted)
//   o_flush_idex - Flush ID/EX (redirect or IRQ accepted)
//   o_accept_irq - Acknowledge an interrupt this cycle
//
// Stall vs bubble distinction:
//   When a decode hazard occurs without a concurrent MEM wait,
//   only a bubble is needed in ID/EX - the IF and ID stages
//   stall but EX/MEM keeps moving. When a MEM wait is active,
//   the entire pipeline upstream of MEM must freeze (stall_ex);
//   no bubble is injected because EX/MEM is frozen in place.
// ============================================================
module hazard_unit(
    // ---- Instruction in ID ----
    input wire i_id_valid,
    input wire [3:0] i_id_rd,          // Rd field of instruction in ID
    input wire [3:0] i_id_rs,          // Rs field
    input wire i_id_reads_rd,          // Instruction reads Rd as a source
    input wire i_id_reads_rs,          // Instruction reads Rs as a source

    // ---- External control events ----
    input wire i_redirect,             // Control-flow redirect required this cycle (from EX stage)
    input wire i_mem_wait,             // MEM stage is waiting for data memory
    input wire i_irq_take,             // An interrupt request is pending (one-shot)

    // ---- ID/EX stage state (instruction in EX) ----
    input wire i_idex_valid,
    input wire [3:0] i_idex_rd,        // Destination register of EX instruction
    input wire i_idex_is_load,         // EX instruction is a load (extra latency)

    // ---- Control outputs ----
    output wire o_stall_if,
    output wire o_stall_id,
    output wire o_stall_ex,
    output wire o_flush_ifid,
    output wire o_flush_idex,
    output wire o_accept_irq
);

/*************************************************************************************
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/

    // Register address match: ID instruction reads a register that a downstream
    // stage is about to write
    wire _match_idex;

    // Hazard type flags
    wire _load_use_hazard; // Load-use subset of RAW (extra stall cycle needed)
    wire _decode_hazard;   // Any hazard that requires stalling the decode stage

    wire _accept_irq;      // Internal IRQ accept signal

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

/*************************************************************************************
 * 2.1 Data Hazard Predicates
 ************************************************************************************/

    // Register address match: ID instruction reads a register that the EX stage
    // is about to write. Used exclusively for load-use hazard detection.
    assign _match_idex  = (i_id_reads_rd & (i_id_rd == i_idex_rd))  |
                          (i_id_reads_rs & (i_id_rs == i_idex_rd));

    // Load-use hazard: the instruction immediately following a load reads the loaded
    // register. The load result is only available after MEM, so an extra stall is
    // needed. R0 destination excluded - writes to R0 are discarded.
    // Ignore load-use hazards on rd=r0, since r0 is architecturally constant zero.
    assign _load_use_hazard = i_id_valid & i_idex_valid & i_idex_is_load &
                              (i_idex_rd != 4'h0) & _match_idex;

    // Any hazard that requires inserting a stall/bubble at the decode boundary
    assign _decode_hazard = _load_use_hazard;

/*************************************************************************************
 * 2.2 Control Outputs
 ************************************************************************************/

    // An IRQ can only be accepted when:
    //   - The interrupt line is asserted (one-shot pulse), AND
    //   - The MEM stage is not stalling (we don't want to disturb an in-flight
    //     memory operation by also trying to save PC into R14 simultaneously)
    assign _accept_irq = i_irq_take & ~i_mem_wait;

    // IF stalls when data memory is busy OR there is a decode hazard.
    // Both cases freeze the PC so the same instruction is re-fetched.
    assign o_stall_if  = i_mem_wait | _decode_hazard;

    // ID stalls for the same reasons as IF (they are always stalled together).
    assign o_stall_id  = i_mem_wait | _decode_hazard;

    // EX stalls only during a MEM wait (the pipeline above MEM freezes).
    assign o_stall_ex  = i_mem_wait;

    // Flush IF/ID on redirect or IRQ accept.
    assign o_flush_ifid = i_redirect | _accept_irq;

    // Because branch evaluation moved to EX, a redirect means we need to flush
    // both the IF/ID stage and the ID/EX stage.
    assign o_flush_idex = i_redirect | _accept_irq || (_decode_hazard & ~i_mem_wait);

    assign o_accept_irq = _accept_irq;

endmodule