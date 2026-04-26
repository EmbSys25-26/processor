`timescale 1ns / 1ps

`include "constants.vh"

// ============================================================
// IF (Instruction Fetch) stage
//
// Responsible for presenting the current PC and returning the
// instruction word from the instruction memory.
//
// Key behaviours:
//   - o_valid is deasserted during flush bubbles (2-cycle drain
//     after a flush event) and whenever i_hit is not asserted.
//   - o_insn_ce drives the instruction-memory chip-enable:
//     active when there is a hit and no stall.
//   - On flush, the stage immediately loads the redirect PC and
//     injects 2 bubble cycles (_flush_bubble counter) to drain
//     the in-flight pipeline slots.
//   - On stall (load-use / decode hazard / MEM wait), all state
//     is frozen; no counter or PC update happens.
//
//  - Flushes are taken on mispredicted branches and interrupts - 
//    both require updating the PC to a non-sequential value and 
//    flushing the pipeline.
//  - Bubbles occur on stalls (currently flushes too, though this 
//    must be improved) - i.e. waiting for a load to complete,
//    meaning the IF stage should not update its PC or output a 
//    valid insn.
//
// The 2-deep PC shift register (_pc → _pc_d1 → o_pc) SHOULD
// model the instruction-memory latency + the path until IF 
// module : the PC is presented to the memory some cycles 
// before the instruction arrives,so o_pc tracks which 
// instruction actually came back.
// ============================================================


module if_stage(
    input wire i_clk,
    input wire i_rst,
    input wire i_hit,                   // Instruction memory hit (instruction is valid)
    input wire i_stall,                 // Stall request from the hazard unit
    input wire i_flush,                 // Flush request (branch taken or IRQ accepted)
    input wire [15:0] i_flush_pc,       // PC to redirect to after flush
    input wire [15:0] i_pc,             // Current PC (from the top-level PC register)
    input wire [15:0] i_insn,           // Instruction word returned by instruction memory
    input wire i_pred_taken,            // Predicted taken for i_pc
    input wire [15:0] i_pred_target,    // Predicted target for i_pc
    input wire [`GHR_W-1:0] i_lookup_ghr,      // GHR value for prediction metadata
    output wire o_insn_ce,              // Chip-enable to instruction memory
    output wire o_valid,                // Instruction at output is valid
    output reg [15:0] o_pc,             // PC associated with the current instruction
    output wire [15:0] o_insn,          // Instruction word passed to IF/ID register
    output reg o_pred_taken,            // Prediction metadata aligned with o_pc/o_insn
    output reg [15:0] o_pred_target,
    output reg [`GHR_W-1:0] o_lookup_ghr       // GHR value passed to IF/ID for prediction metadata
);

/*************************************************************************************
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/

    // One intermediate register to align the PC with the instruction on insn
    reg [15:0] _pc_d1;          // PC delayed by 1 cycle
    reg _pred_taken_d1;
    reg [15:0] _pred_target_d1;
    reg [`GHR_W-1:0] _lookup_ghr_d1;

    // Counter for post-flush bubble cycles (flush bad inflight instructions)
    // After a flush, 1 bubble slot must be injected to drain the pipeline
    // before a valid instruction from the new PC can appear.
    (* mark_debug = "true" *)   reg [1:0]_flush_bubble;    // Counts down from 1 to 0 after a flush

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

    // Instruction memory is enabled only when there is a hit and no stall.
    assign o_insn_ce = i_hit & ~i_stall;

    // Output is valid only when: instruction memory has a hit AND there are
    // no outstanding flush bubbles still being drained.
    reg o_valid_r;

    always @(posedge i_clk) begin
        if (i_rst || i_flush)                
            o_valid_r <= 1'b0;
        else if (!i_stall)
            o_valid_r <= i_hit & (_flush_bubble == 2'd0);
    end
        
    assign o_valid = o_valid_r;

    // Pass the instruction word with validation
    // If insn is not valid, a bubble (NOP) is inserted
    assign o_insn = (_flush_bubble == 2'd0) ? i_insn : `CPU_NOP_INSN;

    always @(posedge i_clk) begin
        if (i_rst) begin
            // On reset, seed the entire PC pipeline with the reset address
            // so there is no spurious old-PC instruction in flight.
            _pc_d1 <= i_pc;
            o_pc   <= i_pc;
            _pred_taken_d1 <= 1'b0;
            _pred_target_d1 <= 16'h0000;
            o_pred_taken <= 1'b0;
            o_pred_target <= 16'h0000;
            _lookup_ghr_d1 <= {`GHR_W{1'b0}};
            o_lookup_ghr <= {`GHR_W{1'b0}};
            _flush_bubble <= 2'd0;
        end else if (i_flush) begin
            // Redirect: load the flush target into all pipeline stages immediately,
            // and arm the 1-cycle bubble counter.
            _pc_d1 <= i_flush_pc;
            o_pc   <= i_flush_pc;
            _pred_taken_d1 <= 1'b0;
            _pred_target_d1 <= 16'h0000;
            o_pred_taken <= 1'b0;
            o_pred_target <= 16'h0000;
            _lookup_ghr_d1 <= {`GHR_W{1'b0}};
            o_lookup_ghr <= {`GHR_W{1'b0}};
            _flush_bubble <= 2'd1; // note if its need 2
        end else begin
            if (i_hit & ~i_stall) begin
                // Normal advance: shift the PC pipeline forward and
                // decrement the bubble counter if it is non-zero.
                _pc_d1 <= i_pc;
                o_pc   <= _pc_d1;
                _pred_taken_d1 <= i_pred_taken;
                _pred_target_d1 <= i_pred_target;
                o_pred_taken <= _pred_taken_d1;
                o_pred_target <= _pred_target_d1;
                _lookup_ghr_d1 <= i_lookup_ghr;
                o_lookup_ghr <= _lookup_ghr_d1;
                if (_flush_bubble != 2'd0) begin
                    _flush_bubble <= _flush_bubble - 2'd1;
                end
            end
            // If stalled (i_stall asserted) or no hit: hold everything frozen.
        end
    end

endmodule