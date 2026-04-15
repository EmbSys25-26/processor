`timescale 1ns / 1ps

`include "constants.vh"

// ============================================================
// EX (Execute) stage
//
// Executes ALU/address operations and prepares writeback/memory candidates.
//
// Instantiates the ALU and drives its inputs based on the decoded
// instruction type.  Also computes:
//   - Data-memory address (o_d_ad)
//   - Store data (o_store_data = Rd contents)
//   - Pre-writeback result (o_wb_pre_data)
//   - New condition-code values (Z, N, C, V) and carry bit
//
// ALU operand selection:
//   - RI format: A = Rd (destination used as source), B = Rd (same)
//                 actually: A = imm16, B = Rd_data  (ri uses rd as src)
//   - RR format: A = Rd (left operand), B = Rs (right operand)
//   - ADDI:      A = imm16,            B = Rs (base register)
//
// Carry-in (_ci) logic:
//   - For ADD/ADDI: carry-in = current carry (_c)
//   - For SUB/SBC/CMP: carry-in = ~_c (borrow convention)
//   This is a standard "borrow = ~carry" ALU convention.
//
// Data-memory address:
//   The ALU sum is used as the raw address, then shifted left by 1
//   (o_d_ad = _sum << 1).  This converts the word-indexed offset
//   produced by the ALU into a byte address for word/byte access.
//
// Condition-code update:
//   - Z: result == 0
//   - N: result[15] (MSB = sign bit)
//   - C: carry-out (for additions); inverted carry-out (for subtractions)
//   - V: overflow = carry_out XOR result_MSB XOR A_MSB XOR B_MSB
//        (standard 2's-complement overflow detection)
//
// PSW vector (for GETCC):
//   Packed as {_c, _ccz, _ccn, _ccc, _ccv} → 5 bits → stored in Rd[4:0].
//
// SETCC (restore_cc):
//   Reads the PSW back from Rs: Rs[4]=c, Rs[3]=z, Rs[2]=n, Rs[1]=c_flag, Rs[0]=v.
// ============================================================
module ex_stage(
    input wire i_valid,
    input wire [15:0] i_pc_dbg,
    input wire [3:0] i_rd,
    input wire [15:0] i_rd_data,    // Register-file value of Rd
    input wire [15:0] i_rs_data,    // Register-file value of Rs
    input wire [15:0] i_imm16,      // Sign/zero-extended immediate
    input wire i_rf_we,
    input wire i_lw,
    input wire i_lb,
    input wire i_sw,
    input wire i_sb,
    input wire i_is_jal,
    input wire i_is_addi,
    input wire i_is_rr,
    input wire i_is_ri,
    input wire i_is_alu,
    input wire i_is_sub,
    input wire i_is_xor,
    input wire i_is_adc,
    input wire i_is_sbc,
    input wire i_is_cmp,
    input wire i_is_sra,
    input wire i_is_sum,
    input wire i_is_log,
    input wire i_is_sr,
    input wire i_is_getcc,
    input wire i_restore_cc,        // SETCC: restore PSW from Rs

    
    input wire i_forward_a,
    input wire i_forward_b,
    input wire [15:0] i_exmem_wb_data,
    
    // Current committed condition-code state (read directly from top-level regs)
    input wire i_c,     // Carry bit (for ADC/SBC)
    input wire i_ccz,   // Zero flag
    input wire i_ccn,   // Negative flag
    input wire i_ccc,   // Carry flag (for branches)
    input wire i_ccv,   // Overflow flag

    output wire o_valid,
    output wire [15:0] o_pc,
    output wire [3:0] o_rd,
    output wire o_rf_we,
    output wire o_lw,
    output wire o_lb,
    output wire o_sw,
    output wire o_sb,
    output wire [15:0] o_d_ad,          // Data-memory byte address
    output wire [15:0] o_store_data,    // Value to write to data memory
    output wire [15:0] o_wb_pre_data,   // ALU result for register writeback (non-load)
    output wire o_flag_we,              // Condition codes should be updated
    output wire o_new_ccz,
    output wire o_new_ccn,
    output wire o_new_ccc,
    output wire o_new_ccv,
    output wire o_carry_we,             // Carry bit should be updated
    output wire o_new_c,
    output wire o_is_load
);

/*************************************************************************************
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/

    wire [15:0] _src;       // ALU B operand source (Rs or Rd depending on RI/RR)
    wire [15:0] _a;         // ALU left operand
    wire [15:0] _b;         // ALU right operand
    wire _add;              // 1 = perform addition; 0 = subtraction (fed to ALU)
    wire _ci;               // Carry-in to the ALU adder
    
    // Forwarded operand values: select between EX/MEM result (10), MEM/WB result (01),
    // or the original register-file value (00) based on forwarding control signals.
    (* keep = "true" *) wire [15:0] _rd_fwd;  // Forwarded value for Rd (ALU operand A / store source)
    (* keep = "true" *) wire [15:0] _rs_fwd; // Forwarded value for Rs (ALU operand B)

    // ALU outputs
    wire [15:0] _sum;       // Arithmetic result (add/sub)
    wire [15:0] _log;       // Logical result (AND/XOR)
    wire [15:0] _sr;        // Shift result (SRL/SRA)
    wire _c_w;              // Raw carry-out from the adder
    wire _x;                // Extra bit output from the ALU (architecture-specific)

    // Derived flag values
    wire _z;                // Zero flag: sum == 0
    wire _n;                // Negative flag: MSB of sum
    wire _co;               // Carry-out (normalised for add/sub)
    wire _v;                // Overflow flag

    wire [15:0] _alu_res;   // Final selected ALU result for writeback
    wire [4:0] _psw_vector; // Packed PSW {c, ccz, ccn, ccc, ccv} for GETCC
    wire _update_cc;        // 1 when condition codes should actually be written

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

/*************************************************************************************
 * 2.1 ALU Datapath
 ************************************************************************************/
 
    // muxes for the forwarding
    
    assign _rd_fwd = (i_forward_a == 1'b1) ? i_exmem_wb_data: i_rd_data;

    assign _rs_fwd = (i_forward_b == 1'b1) ? i_exmem_wb_data : i_rs_data;

    // Operand mux for RI vs RR:
    //   RI: Rd is the destination AND the left source; Rs is unused.
    //       _src = Rd_data (right operand for ALU)
    //       _a   = imm16   (left operand, the immediate)
    //   RR: Rd is left, Rs is right.
    //       _src = Rs_data
    //       _a   = Rd_data
    assign _src = i_is_ri ? _rd_fwd : _rs_fwd;
    assign _a   = i_is_rr ? _rd_fwd : i_imm16;
    assign _b   = _src;

    // Add/subtract control:
    //   Subtraction operations (SUB, SBC, CMP) use _add=0 to signal the ALU
    //   to negate the B operand (two's-complement adder with inverted carry-in).
    assign _add = ~(i_is_alu & (i_is_sub | i_is_sbc | i_is_cmp));

    // Carry-in:
    //   Addition:    ci = _c (propagate carry for ADC, or 0-equivalent for ADD via _c init)
    //   Subtraction: ci = ~_c (borrow = ~carry convention)
    assign _ci = _add ? i_c : ~i_c;

    alu u_alu (
        .i_is_add(_add),
        .i_a(_a),
        .i_b(_b),
        .i_ci(_ci),
        .i_is_xor(i_is_xor),
        .i_is_sra(i_is_sra),
        .o_sum(_sum),
        .o_log(_log),
        .o_sr(_sr),
        .o_co(_c_w),    // Raw carry-out from adder
        .o_x(_x)
    );

    // Derive condition flags from the arithmetic result
    assign _z  = (_sum == 16'h0000);
    assign _n  = _sum[`CPU_N];         // Negative = MSB

    // Normalise carry: for subtraction, carry-out is inverted
    // (borrow convention: C=1 means no borrow for SUB)
    assign _co = _add ? _c_w : ~_c_w;

    // Overflow: XOR of carry-out, result MSB, A MSB, and B MSB
    // Standard two's-complement overflow detection formula.
    assign _v = _c_w ^ _sum[`CPU_N] ^ _a[`CPU_N] ^ _b[`CPU_N];

    // Result mux: select the appropriate ALU output based on operation type
    assign _alu_res =
        ((i_is_alu & i_is_sum) | i_is_addi) ? _sum :    // Arithmetic → sum
        ((i_is_alu & i_is_log)              ? _log :    // Logical    → log
        ((i_is_alu & i_is_sr)               ? _sr  :    // Shift      → sr
        (i_is_jal ? (i_pc_dbg + 16'h0004)       : 16'h0000))); // JAL → return addr (PC+4)

/*************************************************************************************
 * 2.2 Flag and Writeback Candidates
 ************************************************************************************/

    // PSW vector packed for GETCC instruction: {c, Z, N, C_flag, V}
    assign _psw_vector = {i_c, i_ccz, i_ccn, i_ccc, i_ccv};

    // Condition codes are updated only by arithmetic/sum ALU ops, CMP, and ADDI
    assign _update_cc = i_valid & (((i_is_rr | i_is_ri) & (i_is_sum | i_is_cmp)) | i_is_addi);

    // Pre-writeback data:
    //   GETCC → lower 5 bits = packed PSW; upper 11 bits = 0
    //   Others → ALU result
    assign o_wb_pre_data = i_is_getcc ? {11'b0, _psw_vector} : _alu_res;

    // Data-memory address: ALU sum shifted left by 1 (word index → byte address)
    assign o_d_ad = (_sum << 1);

    // Store data is always the Rd register value (the source for SW/SB)
    assign o_store_data = _rd_fwd;

    // Flag write-enable: set for arithmetic that updates CCs, or for SETCC restore
    assign o_flag_we = _update_cc | (i_valid & i_restore_cc);

    // New flag values:
    //   SETCC (restore_cc): unpack from Rs[3:0]
    //   Otherwise: computed from ALU result
    assign o_new_ccz = i_restore_cc ? _rs_fwd[3] : _z;
    assign o_new_ccn = i_restore_cc ? _rs_fwd[2] : _n;
    assign o_new_ccc = i_restore_cc ? _rs_fwd[1] : _co;
    assign o_new_ccv = i_restore_cc ? _rs_fwd[0] : _v;

    // Carry write: always asserted for valid instructions.
    // carry value: SETCC restores from Rs[4]; ADC/SBC sets from carry-out; others clear it.
    assign o_carry_we = i_valid;
    assign o_new_c = i_restore_cc ? _rs_fwd[4]
                                  : (_co & (i_is_alu & (i_is_adc | i_is_sbc)));

/*************************************************************************************
 * 2.3 Pass-through Controls
 ************************************************************************************/

    // Most control signals pass through with valid-gating to suppress bubbles
    assign o_valid   = i_valid;
    assign o_pc      = i_pc_dbg;
    assign o_rd      = i_rd;
    assign o_rf_we   = i_valid & i_rf_we;
    assign o_lw      = i_valid & i_lw;
    assign o_lb      = i_valid & i_lb;
    assign o_sw      = i_valid & i_sw;
    assign o_sb      = i_valid & i_sb;

  

    assign o_is_load  = i_valid & (i_lw | i_lb);

endmodule