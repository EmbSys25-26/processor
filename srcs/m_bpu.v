`timescale 1ns / 1ps

// ============================================================
// Branch Prediction Unit (BHT + BTB)
//
// - BHT: 2-bit saturating counters per entry
// - BTB: target cache with valid + tag per entry
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

    // Lookup (combinational)
    input wire [15:0] i_lookup_pc,      // PC of the instruction being fetched (IF stage)
    output wire o_pred_taken,           // Prediction for the i_lookup_pc instruction being taken
    output wire [15:0] o_pred_target,   // Predicted target if the i_lookup_pc instruction is predicted taken

    // Update (on resolved branch)
    input wire i_update_en,             // Enable signal for updating the BPU state based on a resolved branch
    input wire [15:0] i_update_pc,      // PC of the instruction being resolved (EX/MEM stage)
    input wire i_update_taken,          // Whether the resolved branch was actually taken (from EX/MEM stage)
    input wire [15:0] i_update_target   // Resolved target address for the branch
);

/*************************************************************************************
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/
    localparam integer BPU_ENTRIES = 128;
    localparam integer BPU_IDX_W = 7;
    localparam integer BPU_TAG_W = 8;

    // Branch History Table (BHT) storage: 2-bit saturating counters
    reg [1:0] _bht [0:BPU_ENTRIES-1];

    // Branch Target Buffer (BTB) storage: valid bit, tag, and target address
    reg _btb_valid [0:BPU_ENTRIES-1];

    // Branch Tag Buffer tag and target storage
    // The tag stores the upper bits of the PC to verify that a BTB hit corresponds to the correct branch instruction
    // The target is the predicted target address to jump to if the branch is predicted taken
    reg [BPU_TAG_W-1:0] _btb_tag [0:BPU_ENTRIES-1];
    reg [15:0] _btb_target [0:BPU_ENTRIES-1];

    // 7-bit lookup index and 8-bit tag derived from the lookup PC
    wire [BPU_IDX_W-1:0] _lookup_idx;
    // Directly use the tag bits from the PC for lookup
    wire [BPU_TAG_W-1:0] _lookup_tag;
    wire _lookup_hit;

    // 7-bit update index
    wire [BPU_IDX_W-1:0] _update_idx;
    // 8-bit update tag extracted from the resolved branch PC
    wire [BPU_TAG_W-1:0] _update_tag;

    integer _i;

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

/*************************************************************************************
 * 2.1 Combinational Lookup
 ************************************************************************************/
    // 16-bit ISA with PC+2 sequencing:
    // - bit[0] is always 0 (halfword aligned)
    // - bits[6:1] provide 6 index bits for 64 entries
    // Therefore, index with [6:1] and use [15:7] as tag.
    assign _lookup_idx = i_lookup_pc[BPU_IDX_W:1];
    assign _lookup_tag = i_lookup_pc[15:(16-BPU_TAG_W)];

    // A BTB hit occurs when the valid bit is set and the tag matches the lookup tag.
    assign _lookup_hit = _btb_valid[_lookup_idx] && (_btb_tag[_lookup_idx] == _lookup_tag);

    // pred_taken is set to high if correspodent entry in bht is at least weakly taken (10 or 11).
    assign o_pred_taken = _lookup_hit && _bht[_lookup_idx][1];

    // If the lookup hits, forward the corresponding BTB target. 
    // Otherwise, default to 0 (could be any value, it will be ignored when pred_taken is false).
    assign o_pred_target = _lookup_hit ? _btb_target[_lookup_idx] : 16'h0000;

/*************************************************************************************
 * 2.2 State Update
 ************************************************************************************/

    /*  The BHT is not a true shift window like register, and so the last branch entry 
        registered isnt necessarily the lowest index.
        The update logic uses the resolved branch PC to compute the index and tag for the entry 
        to update.
     */
    assign _update_idx = i_update_pc[BPU_IDX_W:1];
    assign _update_tag = i_update_pc[15:(16-BPU_TAG_W)];

    always @(posedge i_clk) begin
        if (i_rst) begin
            for (_i = 0; _i < BPU_ENTRIES; _i = _i + 1) begin
                _bht[_i] <= 2'b01;          // Weakly not-taken default
                _btb_valid[_i] <= 1'b0;
                _btb_tag[_i] <= {BPU_TAG_W{1'b0}};
                _btb_target[_i] <= 16'h0000;
            end
        end else if (i_update_en) begin
            if (i_update_taken) begin
                if (_bht[_update_idx] != 2'b11)
                    _bht[_update_idx] <= _bht[_update_idx] + 2'b01;
                _btb_valid[_update_idx] <= 1'b1;
                _btb_tag[_update_idx] <= _update_tag;
                _btb_target[_update_idx] <= i_update_target;
            end else begin
                if (_bht[_update_idx] != 2'b00)
                    _bht[_update_idx] <= _bht[_update_idx] - 2'b01;
            end
        end
    end

endmodule
