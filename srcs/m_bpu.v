`timescale 1ns / 1ps

`include "constants.vh"

// ============================================================
// Branch Prediction Unit (PHT + BTB + GHR) 
//
// - BHT: 2-bit saturating counters per entry
// - BTB: target cache with valid + tag per entry
// - GHR: Global History Register for gshare indexing
//
// Prediction policy:
//   counter[1] = 1 => predict taken
//   counter[1] = 0 => predict not-taken
//
// Update policy (on resolved conditional branch):
//   taken     => increment counter (saturating)
//   not-taken => decrement counter (saturating)
//
// BTB policy:
//   updated on taken branches with resolved target.
// ============================================================
module bpu(
    input wire i_clk,
    input wire i_rst,
    
    // Update (on resolved branch)
    input wire i_update_en,             // Enable signal for updating the BPU state based on a resolved branch
    input wire [15:0] i_update_pc,      // PC of the instruction being resolved (EX/MEM stage)
    input wire i_update_taken,          // Whether the resolved branch was actually taken (from EX/MEM stage)
    input wire [15:0] i_update_target,  // Resolved target address for the branch
    input wire [`GHR_W-1:0] i_update_ghr,      // Current value of the Global History Register for gshare indexing
    // Lookup (combinational)
    input wire [15:0] i_lookup_pc,      // PC of the instruction being fetched (IF stage)
    input wire i_br_uncond,             // Whether the instruction being fetched is an unconditional branch
    
    output wire o_pred_taken,           // Prediction for the i_lookup_pc instruction being taken
    output wire [15:0] o_pred_target,   // Predicted target if the i_lookup_pc instruction is predicted taken
    output wire [`GHR_W-1:0] o_lookup_ghr      // Output the current GHR value for monitoring/debugging
    
);

/*************************************************************************************
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/
    // Global History Register for gshare indexing
    reg [`GHR_W-1:0] _ghr; 

    // Pattern History Table (PHT) storage: 2-bit saturating counters
    reg [1:0] _pht [0:`BPU_ENTRIES-1];

    // Branch Target Buffer (BTB) storage: valid bit, tag, and target address
    reg _btb_valid [0:`BPU_ENTRIES-1];
    // Whether the entry corresponds to an unconditional branch
    reg _btb_uncond [0:`BPU_ENTRIES-1];  

    // Branch Tag Buffer tag and target storage
    // The tag stores the upper bits of the PC to verify that a BTB hit corresponds to the correct branch instruction
    // The target is the predicted target address to jump to if the branch is predicted taken
    reg [`BPU_TAG_W-1:0] _btb_tag [0:`BPU_ENTRIES-1];
    reg [15:0] _btb_target [0:`BPU_ENTRIES-1];

    // Global History Register (GHR) for gshare indexing 
    wire [`BPU_IDX_W-1:0] _gshare_idx;

    // 7-bit lookup index and 8-bit tag derived from the lookup PC
    wire [`BPU_IDX_W-1:0] _lookup_idx;
    // Directly use the tag bits from the PC for lookup
    wire [`BPU_TAG_W-1:0] _lookup_tag;
    wire _lookup_hit;

    // Index to update the global shared index
    wire [`BPU_IDX_W-1:0] _update_gshare_idx;
    // 7-bit update index
    wire [`BPU_IDX_W-1:0] _update_idx;
    // 8-bit update tag extracted from the resolved branch PC
    wire [`BPU_TAG_W-1:0] _update_tag;

    integer _i;

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

/*************************************************************************************
 * 2.1 Combinational Lookup
 ************************************************************************************/
    // XOR GHR with index bits for gshare indexing
    assign _gshare_idx = _lookup_idx ^ _ghr; 

    // 16-bit ISA with PC+2 sequencing:
    // - bit[0] is always 0 (word aligned)
    // - bits[`BPU_IDX_W:1] provide `BPU_IDX_W index bits for N entries
    assign _lookup_idx = i_lookup_pc[`BPU_IDX_W:1];
    assign _lookup_tag = i_lookup_pc[15:(16-`BPU_TAG_W)];

    // A BTB hit occurs when the valid bit is set and the tag matches the lookup tag.
    assign _lookup_hit = _btb_valid[_lookup_idx] && (_btb_tag[_lookup_idx] == _lookup_tag);

    // Output the current GHR value for temporal alignment with the later update stage
    assign o_lookup_ghr = _ghr; 

    // pred_taken is set to high if correspodent entry in pht is at least weakly taken (10 or 11).
    // Unconditional branches are always predicted taken regardless of the PHT state
    assign o_pred_taken = _lookup_hit && (_pht[_gshare_idx][1] || _btb_uncond[_lookup_idx]); 

    // If the lookup hits, forward the corresponding BTB target. 
    // Otherwise, default to 0 (could be any value, it will be ignored when pred_taken is false).
    assign o_pred_target = _lookup_hit ? _btb_target[_lookup_idx] : 16'h0000;

/*************************************************************************************
 * 2.2 State Update
 ************************************************************************************/

    assign _update_gshare_idx = _update_idx ^ i_update_ghr;
    assign _update_idx = i_update_pc[`BPU_IDX_W:1];
    assign _update_tag = i_update_pc[15:(16-`BPU_TAG_W)];

    always @(posedge i_clk) begin
        if (i_rst) begin
            _ghr <= 0;
            for (_i = 0; _i < `BPU_ENTRIES; _i = _i + 1) begin
                _pht[_i] <= 2'b01;          // Weakly not-taken default
                _btb_valid[_i] <= 1'b0;
            end
        end else if (i_update_en) begin
            if (i_update_taken) begin
                _ghr <= {_ghr[`GHR_W-2:0], 1'b1}; // Shift in a '1' for taken

                if ((!i_br_uncond) && (_pht[_update_gshare_idx] != 2'b11)) begin
                    _pht[_update_gshare_idx] <= _pht[_update_gshare_idx] + 2'b01;
                end
                _btb_valid[_update_idx] <= 1'b1;
                _btb_uncond[_update_idx] <= i_br_uncond; 
                _btb_tag[_update_idx] <= _update_tag;
                _btb_target[_update_idx] <= i_update_target;
            end else begin
                _ghr <= {_ghr[`GHR_W-2:0], 1'b0}; // Shift in a '0' for not taken

                if (_pht[_update_gshare_idx] != 2'b00) begin
                    _pht[_update_gshare_idx] <= _pht[_update_gshare_idx] - 2'b01;
                end
            end
        end
    end

endmodule
