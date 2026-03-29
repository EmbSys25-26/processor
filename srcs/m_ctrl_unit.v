`timescale 1ns / 1ps

`include "constants.vh"

// ============================================================
// Control Unit (Instruction Decoder)
//
// Pure combinational decode of a 16-bit instruction word.
// Extracts all register fields, immediate fields, and derives
// every control flag needed by the rest of the pipeline.
//
// Instruction encoding summary:
//   [15:12] = opcode (_op)
//   [11:8]  = Rd destination / condition code field (_rd / _cond)
//   [7:4]   = Rs source / RI function field (_rs / _fn for RI)
//   [3:0]   = immediate / function field (_imm / _fn for RR)
//   [11:0]  = 12-bit immediate (used by the IMM prefix instruction, _i12)
//   [7:0]   = 8-bit signed displacement for BX branches (_disp)
//
// Instruction classes:
//   JAL   — Jump and Link  (absolute indirect: PC+4 → Rd, Rs+imm16 → PC)
//   ADDI  — Add Immediate  (Rd = Rs + imm16)
//   RR    — Register-Register ALU
//   RI    — Register-Immediate ALU
//   LW/LB — Load word/byte
//   SW/SB — Store word/byte
//   IMM   — Immediate prefix (sets upper 12 bits for next instruction)
//   BX    — Conditional branch (PC-relative, signed 8-bit displacement × 2)
//   SYS   — System operations (GETCC, SETCC)
//   CLI   — Clear interrupt enable
//   STI   — Set interrupt enable
//   IRET  — Return from interrupt
//
// ALU function sub-codes (FN field):
//   ADD, SUB, AND, XOR, ADC, SBC, CMP, SRL, SRA
//   Grouped as: sum (ADD/SUB/ADC/SBC), log (AND/XOR), sr (SRL/SRA)
//
// Hazard metadata outputs (read/write/use qualifiers):
//   o_reads_rd   — instruction reads the Rd field as a source operand
//   o_reads_rs   — instruction reads the Rs field as a source operand
//   o_writes_rd  — instruction will write a result to Rd
//   o_is_load    — instruction is a load (LW or LB)
//   o_is_store   — instruction is a store (SW or SB)
//   o_uses_cc    — instruction reads the condition codes (BX)
//   o_uses_carry — instruction reads the carry bit (ADC/SBC)
//   o_updates_cc — instruction will write condition codes
//   o_irq_interlock — IRQ must not be accepted while this is in ID
//                     (IMM prefix and carry-using ALU ops need the following
//                      instruction to also be present before an IRQ fires)
// ============================================================
module ctrl_unit(
    input wire [`CPU_IN:0] i_insn,  // 16-bit instruction word

    // ---- Decoded register / immediate fields ----
    output wire [3:0] o_rd,         // Destination register index
    output wire [3:0] o_rs,         // Source register index
    output wire [3:0] o_fn,         // ALU function code
    output wire [3:0] o_imm,        // 4-bit immediate field
    output wire [3:0] o_cond,       // Branch condition code
    output wire [7:0] o_disp,       // 8-bit signed branch displacement
    output wire [11:0] o_i12,       // 12-bit immediate (for IMM prefix)

    // ---- Opcode-level classification ----
    output wire o_is_imm,
    output wire o_is_bx,
    output wire o_is_sys,
    output wire o_is_cli,
    output wire o_is_sti,

    output wire o_is_jal,
    output wire o_is_addi,
    output wire o_is_rr,
    output wire o_is_ri,
    output wire o_is_lw,
    output wire o_is_lb,
    output wire o_is_sw,
    output wire o_is_sb,

    // ---- ALU function classification ----
    output wire o_is_alu,           // Any ALU instruction (RR or RI)
    output wire o_is_add,
    output wire o_is_sub,
    output wire o_is_and,
    output wire o_is_xor,
    output wire o_is_adc,
    output wire o_is_sbc,
    output wire o_is_cmp,
    output wire o_is_srl,
    output wire o_is_sra,

    // ---- ALU sub-group flags ----
    output wire o_is_sum,           // ADD/SUB/ADC/SBC (arithmetic)
    output wire o_is_log,           // AND/XOR (logical)
    output wire o_is_sr,            // SRL/SRA (shift)

    // ---- System instruction flags ----
    output wire o_is_setcc,         // SETCC: restore PSW from register
    output wire o_is_getcc,         // GETCC: read PSW into register

    // ---- Interrupt / hazard qualifiers ----
    output wire o_is_iret,          // IRET instruction
    output wire o_reads_rd,
    output wire o_reads_rs,
    output wire o_writes_rd,
    output wire o_is_load,
    output wire o_is_store,
    //output wire o_uses_cc,
    //output wire o_uses_carry,
    output wire o_updates_cc,
    output wire o_irq_interlock
);

/*************************************************************************************
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/

    // Internal decoded fields
    wire [3:0] _op;     // Opcode (bits [15:12])
    wire [3:0] _rd;
    wire [3:0] _rs;
    wire [3:0] _fn;     // Function field: bits [3:0] for RR, bits [7:4] for RI
    wire [3:0] _imm;
    wire [11:0] _i12;
    wire [3:0] _cond;
    wire [7:0] _disp;

    // Opcode classification flags
    wire _is_jal;
    wire _is_addi;
    wire _is_rr;
    wire _is_ri;
    wire _is_lw;
    wire _is_lb;
    wire _is_sw;
    wire _is_sb;
    wire _is_imm;
    wire _is_bx;
    wire _is_sys;
    wire _is_cli;
    wire _is_sti;

    // ALU function flags
    wire _is_add;
    wire _is_sub;
    wire _is_and;
    wire _is_xor;
    wire _is_adc;
    wire _is_sbc;
    wire _is_cmp;
    wire _is_srl;
    wire _is_sra;

    // ALU group flags
    wire _is_alu;
    wire _is_sum;
    wire _is_log;
    wire _is_sr;

    // Hazard interlock qualification
    wire _interlocked_insns;

    // System instruction flags
    wire _is_getcc;
    wire _is_setcc;

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

/*************************************************************************************
 * 2.1 Instruction Decode
 ************************************************************************************/

    // Extract raw fields from the 16-bit instruction word
    assign _op   = i_insn[15:12];
    assign _rd   = i_insn[11:8];
    assign _rs   = i_insn[7:4];
    // Function field position depends on format:
    //   RI format: fn is in [7:4] (same bits as rs in RR, since rs is implicit)
    //   RR format: fn is in [3:0]
    assign _fn   = (_op == `OP_RI) ? i_insn[7:4] : i_insn[3:0];
    assign _imm  = i_insn[3:0];
    assign _i12  = i_insn[11:0];     // Full lower 12 bits for IMM prefix payload
    assign _cond = i_insn[11:8];     // Condition code selector for BX
    assign _disp = i_insn[7:0];      // Signed 8-bit branch displacement (scaled ×2 in ID)

    // Forward raw fields to output ports
    assign o_rd   = _rd;
    assign o_rs   = _rs;
    assign o_fn   = _fn;
    assign o_imm  = _imm;
    assign o_cond = _cond;
    assign o_disp = _disp;
    assign o_i12  = _i12;

    // Primary opcode decoding
    assign _is_jal  = (_op == `OP_JAL);
    assign _is_addi = (_op == `OP_ADDI);
    assign _is_rr   = (_op == `OP_RR);
    assign _is_ri   = (_op == `OP_RI);
    assign _is_lw   = (_op == `OP_LW);
    assign _is_lb   = (_op == `OP_LB);
    assign _is_sw   = (_op == `OP_SW);
    assign _is_sb   = (_op == `OP_SB);
    assign _is_imm  = (_op == `OP_IMM);
    assign _is_bx   = (_op == `OP_BX);
    assign _is_sys  = (_op == `OP_SYS);
    assign _is_cli  = (_op == `OP_CLI);
    assign _is_sti  = (_op == `OP_STI);

    // ALU function sub-decoding (only meaningful when _is_alu is true)
    assign _is_add = (_fn == `FN_ADD);
    assign _is_sub = (_fn == `FN_SUB);
    assign _is_and = (_fn == `FN_AND);
    assign _is_xor = (_fn == `FN_XOR);
    assign _is_adc = (_fn == `FN_ADC);
    assign _is_sbc = (_fn == `FN_SBC);
    assign _is_cmp = (_fn == `FN_CMP);
    assign _is_srl = (_fn == `FN_SRL);
    assign _is_sra = (_fn == `FN_SRA);

    // ALU group: any RR or RI instruction
    assign _is_alu = _is_rr | _is_ri;

    // System instruction sub-decode
    assign _is_getcc = _is_sys & (_fn == `FN_GETCC);
    assign _is_setcc = _is_sys & (_fn == `FN_SETCC);

    // Forward opcode flags
    assign o_is_imm  = _is_imm;
    assign o_is_bx   = _is_bx;
    assign o_is_sys  = _is_sys;
    assign o_is_cli  = _is_cli;
    assign o_is_sti  = _is_sti;
    assign o_is_jal  = _is_jal;
    assign o_is_addi = _is_addi;
    assign o_is_rr   = _is_rr;
    assign o_is_ri   = _is_ri;
    assign o_is_lw   = _is_lw;
    assign o_is_lb   = _is_lb;
    assign o_is_sw   = _is_sw;
    assign o_is_sb   = _is_sb;
    assign o_is_alu  = _is_alu;
    assign o_is_add  = _is_add;
    assign o_is_sub  = _is_sub;
    assign o_is_and  = _is_and;
    assign o_is_xor  = _is_xor;
    assign o_is_adc  = _is_adc;
    assign o_is_sbc  = _is_sbc;
    assign o_is_cmp  = _is_cmp;
    assign o_is_srl  = _is_srl;
    assign o_is_sra  = _is_sra;

    // ALU sub-group classification
    assign _is_sum = _is_add | _is_sub | _is_adc | _is_sbc;    // Arithmetic operations
    assign _is_log = _is_and | _is_xor;                          // Logical operations
    assign _is_sr  = _is_srl | _is_sra;                          // Shift operations
    assign o_is_sum    = _is_sum;
    assign o_is_log    = _is_log;
    assign o_is_sr     = _is_sr;
    assign o_is_setcc  = _is_setcc;
    assign o_is_getcc  = _is_getcc;

    // IRET: identified by matching the full instruction encoding (not just the opcode)
    assign o_is_iret = (i_insn == `CPU_IRET_INSN);

/*************************************************************************************
 * 2.2 Side-Effect and Hazard Qualifiers
 ************************************************************************************/

    // Instructions that must prevent an IRQ from being accepted while in the ID stage:
    //   - IMM prefix: the following instruction is paired with this one; an IRQ between
    //     them would corrupt the immediate state.
    //   - ADC/SBC/CMP: these read the carry flag; an IRQ between a cc-update and
    //     the carry-consumer would corrupt the carry value seen by the instruction.
    assign _interlocked_insns = _is_imm | (_is_alu & (_is_adc | _is_sbc | _is_cmp));

    // Hazard-detection register read qualifiers
    assign o_reads_rd  = _is_rr | _is_ri | _is_sw | _is_sb;
    assign o_reads_rs  = _is_rr | _is_addi | _is_lw | _is_lb | _is_sw | _is_sb | _is_jal | _is_setcc;
    // Writeback qualifier: CMP does not write a result despite being an ALU op
    assign o_writes_rd = (_is_alu & ~_is_cmp) | _is_addi | _is_lb | _is_lw | _is_jal | _is_getcc;
    assign o_is_load   = _is_lw | _is_lb;
    assign o_is_store  = _is_sw | _is_sb;

    //assign o_uses_cc      = _is_bx;
    //assign o_uses_carry   = _is_alu & (_is_adc | _is_sbc);
    // An instruction updates CCs if it performs arithmetic (sum/cmp group) or ADDI or SETCC
    assign o_updates_cc   = ((_is_alu & (_is_sum | _is_cmp)) | _is_addi | _is_setcc);
    assign o_irq_interlock = _interlocked_insns;

endmodule