`timescale 1ns / 1ps

`include "constants.vh"

// ============================================================
// ID (Instruction Decode) stage
//
// Decodes instruction fields and derives execution/memory/control intent.
//    - Builds immediate and branch decision signals from the fetched instruction.
//    - Emits hazard metadata (reads/writes/load/store/cc/carry usage) for stall logic.
//    - Invalid input is propagated as a bubble (no downstream side effects).
//
// The ID stage combines three sub-units:
//   1. ctrl_unit  — pure combinational instruction decoder
//   2. bdu        — Branch Decision Unit: evaluates branch conditions
//   3. Immediate/address computation logic (inline)
//
// Immediate generation (imm16):
//   If the previous instruction was an IMM prefix (_imm_pre_state=1), the
//   current instruction's 4-bit imm field is concatenated with the saved
//   12-bit payload (_i12_pre_state) to form a full 16-bit immediate.
//   Otherwise, the 4-bit immediate is sign/zero extended depending on the
//   instruction type:
//     - ADDI / ALU: sign-extend bit 3 into bits [15:5]; bit 4 = sign-extend
//     - LW/SW/JAL:  word-address aligned (bit 0 of imm reused for address bit 1)
//     - All others: zero-extend
//
// Branch target computation:
//   - JAL:  Rs + imm16  (register-indirect)
//   - BX:   PC + sign_extend(disp[7:0]) × 2  (PC-relative, byte-addressed but
//           always 2-byte aligned, hence the ×2)
//
// o_exec_valid vs o_valid:
//   o_valid is asserted for any valid instruction including IMM/CLI/STI/BX.
//   o_exec_valid is only asserted for instructions that actually enter the EX
//   stage (i.e., those that produce an EX-stage result or a memory operation).
//   IMM, CLI, STI, and BX are "decode-only" and never enter EX.
// ============================================================
module id_stage(
    input wire i_valid,                 // Instruction in IF/ID is valid
    input wire [15:0] i_pc,             // PC of the instruction
    input wire [15:0] i_insn,           // Raw instruction word
    input wire [15:0] i_rd_data,        // Register-file read data for Rd
    input wire [15:0] i_rs_data,        // Register-file read data for Rs
    input wire i_imm_pre_state,         // 1 if previous instruction was IMM prefix
    input wire [11:0] i_i12_pre_state,  // Saved upper 12-bit payload from IMM prefix
    input wire i_ccz,                   // Zero flag (for BDU)
    input wire i_ccn,                   // Negative flag
    input wire i_ccc,                   // Carry flag
    input wire i_ccv,                   // Overflow flag

    output wire o_valid,                // Instruction is valid
    output wire o_exec_valid,           // Instruction dispatches to EX stage
    output wire [15:0] o_pc,
    output wire [3:0] o_rd,
    output wire [3:0] o_rs,
    output wire [3:0] o_imm,
    output wire [11:0] o_i12,
    output wire [15:0] o_rd_data,
    output wire [15:0] o_rs_data,
    output wire [15:0] o_imm16,         // Fully-extended 16-bit immediate
   (* mark_debug = "true" *)  output wire [15:0] o_branch_target, // Resolved branch/jump target address
    (* mark_debug = "true" *) output wire o_branch_take,          // Branch is taken (combinational — before commit gate)

    output wire o_is_imm,
    output wire o_is_bx,
    output wire o_is_cli,
    output wire o_is_sti,
    output wire o_is_iret,
    output wire o_irq_interlock,        // Prevent IRQ accept while this insn is in ID

    output wire o_rf_we,
    output wire o_lw,
    output wire o_lb,
    output wire o_sw,
    output wire o_sb,
    output wire o_is_jal,
    output wire o_is_addi,
    output wire o_is_rr,
    output wire o_is_ri,
    output wire o_is_alu,
    output wire o_is_sub,
    output wire o_is_xor,
    output wire o_is_adc,
    output wire o_is_sbc,
    output wire o_is_cmp,
    output wire o_is_sra,
    output wire o_is_sum,
    output wire o_is_log,
    output wire o_is_sr,
    output wire o_is_getcc,
    output wire o_restore_cc,           // Instruction is SETCC (will restore the PSW)

    output wire o_reads_rd,
    output wire o_reads_rs,
    output wire o_is_load
    //output wire o_uses_cc,
    //output wire o_uses_carry    
);

/*************************************************************************************
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/

    // Control-unit decoded fields
    wire [3:0] _rd;
    wire [3:0] _rs;
    wire [3:0] _fn;
    wire [3:0] _imm;
    wire [3:0] _cond;
    wire [7:0] _disp;
    wire [11:0] _i12;

    // Control-unit classification flags (all of these are from ctrl_unit)
    wire _is_imm;
    wire _is_bx;
    wire _is_sys;
    wire _is_cli;
    wire _is_sti;
    wire _is_jal;
    wire _is_addi;
    wire _is_rr;
    wire _is_ri;
    wire _is_lw;
    wire _is_lb;
    wire _is_sw;
    wire _is_sb;
    wire _is_alu;
    wire _is_add;
    wire _is_sub;
    wire _is_and;
    wire _is_xor;
    wire _is_adc;
    wire _is_sbc;
    wire _is_cmp;
    wire _is_srl;
    wire _is_sra;
    wire _is_sum;
    wire _is_log;
    wire _is_sr;
    wire _is_setcc;
    wire _is_getcc;
    wire _is_iret;

    // Hazard qualifiers from ctrl_unit
    wire _reads_rd;
    wire _reads_rs;
    wire _writes_rd;
    wire _is_load;
    wire _is_store;
    //wire _uses_cc;
    //wire _uses_carry;
    wire _updates_cc;
    wire _irq_interlock;

    // Immediate extension intermediates
    wire _word_off;     // 1 if instruction uses word-addressed offset (LW/SW/JAL)
    wire _sxi;          // Sign-extend bit: bit 3 of immediate for ADDI/ALU
    wire [10:0] _sxi11; // 11-bit sign-extension mask
    wire _i_4;          // Reconstructed bit 4 of the immediate
    wire _i_0;          // Reconstructed bit 0 of the immediate
    wire [15:0] _imm16; // Final 16-bit immediate (after IMM prefix merging or extension)

    // Branch displacement sign-extension
    wire [6:0] _sxd7;   // 7-bit sign extension of disp[7]
    wire [15:0] _sxd16; // 16-bit sign-extended displacement × 2

    // BDU output
    wire _bdu_take;     // 1 if branch condition is satisfied

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

    // Instantiate the combinational instruction decoder
    ctrl_unit u_ctrl_dec (
        .i_insn(i_insn),
        .o_rd(_rd),
        .o_rs(_rs),
        .o_fn(_fn),
        .o_imm(_imm),
        .o_cond(_cond),
        .o_disp(_disp),
        .o_i12(_i12),
        .o_is_imm(_is_imm),
        .o_is_bx(_is_bx),
        .o_is_sys(_is_sys),
        .o_is_cli(_is_cli),
        .o_is_sti(_is_sti),
        .o_is_jal(_is_jal),
        .o_is_addi(_is_addi),
        .o_is_rr(_is_rr),
        .o_is_ri(_is_ri),
        .o_is_lw(_is_lw),
        .o_is_lb(_is_lb),
        .o_is_sw(_is_sw),
        .o_is_sb(_is_sb),
        .o_is_alu(_is_alu),
        .o_is_add(_is_add),
        .o_is_sub(_is_sub),
        .o_is_and(_is_and),
        .o_is_xor(_is_xor),
        .o_is_adc(_is_adc),
        .o_is_sbc(_is_sbc),
        .o_is_cmp(_is_cmp),
        .o_is_srl(_is_srl),
        .o_is_sra(_is_sra),
        .o_is_sum(_is_sum),
        .o_is_log(_is_log),
        .o_is_sr(_is_sr),
        .o_is_setcc(_is_setcc),
        .o_is_getcc(_is_getcc),
        .o_is_iret(_is_iret),
        .o_reads_rd(_reads_rd),
        .o_reads_rs(_reads_rs),
        .o_writes_rd(_writes_rd),
        .o_is_store(_is_store),
        .o_updates_cc(_updates_cc),
        .o_is_load(_is_load),
        //.o_uses_cc(_uses_cc),
        //.o_uses_carry(_uses_carry),
        .o_irq_interlock(_irq_interlock)
    );

    // Branch Decision Unit: evaluates the condition-code field against the
    // current architectural flags to decide if a BX branch is taken.
    bdu u_bdu (
        .i_cond(_cond),
        .i_ccz(i_ccz),
        .i_ccn(i_ccn),
        .i_ccc(i_ccc),
        .i_ccv(i_ccv),
        .o_take(_bdu_take)
    );

    // ---- Immediate construction ----

    // Word-offset instructions (LW, SW, JAL) encode the address offset in units of 2 bytes.
    // Because all memory accesses are naturally aligned, bit 0 of the immediate is
    // repurposed: it contributes to bit 1 of the byte address (i.e., the offset is × 2).
    assign _word_off = _is_lw | _is_sw | _is_jal;

    // Sign-extension of the 4-bit immediate for ADDI and ALU:
    // bit 3 of the immediate is the sign bit.
    assign _sxi   = (_is_addi | _is_alu) & _imm[3];
    assign _sxi11 = {11{_sxi}};    // Replicate sign bit across upper 11 bits

    // Reconstruct bits [4] and [0] of the effective immediate:
    //   bit 4 = sign-extend OR (word-aligned AND original bit 0 in the offset role)
    //   bit 0 = 0 for word-offset instructions (offset is already × 2); otherwise = _imm[0]
    assign _i_4 = _sxi | (_word_off & _imm[0]);
    assign _i_0 = (~_word_off) & _imm[0];

    // Final imm16:
    //   - If preceded by an IMM prefix: concatenate the saved 12-bit payload with
    //     the current 4-bit immediate field → full 16-bit literal.
    //   - Otherwise: build from sign/zero-extended 4-bit immediate.
    assign _imm16 = i_imm_pre_state ? {i_i12_pre_state, _imm}
                                    : {_sxi11, _i_4, _imm[3:1], _i_0};

    // ---- Branch displacement ----
    // Sign-extend the 8-bit displacement, then shift left by 1 (×2, word-addressing).
    assign _sxd7  = {7{_disp[7]}};
    assign _sxd16 = {_sxd7, _disp, 1'b0};  // {sign×7, disp[7:0], 0} = signed offset in bytes

    // ---- Branch decision ----
    // Branch is taken if: instruction is valid AND (it's a JAL unconditional, OR
    // it's a BX with the condition satisfied by the current flags).
    assign o_branch_take   = i_valid & (_is_jal | (_is_bx & _bdu_take));
    // Branch target:
    //   JAL  → register indirect: Rs + imm16
    //   BX   → PC-relative: PC + sign_extend(disp) × 2
    assign o_branch_target = _is_jal ? (_imm16 + i_rs_data) : (i_pc + _sxd16);

    // ---- Output assignments ----
    assign o_valid       = i_valid;
    
    
    // Exclude IMM/CLI/STI/BX from the EX pipeline: they are handled entirely in ID
    assign o_exec_valid  = i_valid & ~(_is_imm | _is_cli | _is_sti | _is_bx);
    
    
    assign o_pc          = i_pc;    // Pass data Unchanged
    assign o_rd          = _rd;
    assign o_rs          = _rs;
    assign o_imm         = _imm;
    assign o_i12         = _i12;
    assign o_rd_data     = i_rd_data;
    assign o_rs_data     = i_rs_data;
    assign o_imm16       = _imm16;

    assign o_is_imm      = _is_imm;
    assign o_is_bx       = _is_bx;
    assign o_is_cli      = _is_cli;
    assign o_is_sti      = _is_sti;
    assign o_is_iret     = _is_iret;
    assign o_irq_interlock = _irq_interlock;

    // Register-file write-enable is valid-gated: no write if the instruction is a bubble
    assign o_rf_we       = i_valid & _writes_rd;
    // Load/store signals are also valid-gated
    assign o_lw = i_valid & _is_lw;
    assign o_lb = i_valid & _is_lb;
    assign o_sw = i_valid & _is_sw;
    assign o_sb = i_valid & _is_sb;

    assign o_is_jal    = _is_jal;
    assign o_is_addi   = _is_addi;
    assign o_is_rr     = _is_rr;
    assign o_is_ri     = _is_ri;
    assign o_is_alu    = _is_alu;
    assign o_is_sub    = _is_sub;
    assign o_is_xor    = _is_xor;
    assign o_is_adc    = _is_adc;
    assign o_is_sbc    = _is_sbc;
    assign o_is_cmp    = _is_cmp;
    assign o_is_sra    = _is_sra;
    assign o_is_sum    = _is_sum;
    assign o_is_log    = _is_log;
    assign o_is_sr     = _is_sr;
    assign o_is_getcc  = _is_getcc;
    // restore_cc = SETCC: instructs EX to load PSW from a register value
    assign o_restore_cc = _is_setcc;

    assign o_reads_rd   = _reads_rd;
    assign o_reads_rs   = _reads_rs;
    assign o_is_load    = _is_load;
    //assign o_uses_cc    = _uses_cc;
    //assign o_uses_carry = _uses_carry;

endmodule