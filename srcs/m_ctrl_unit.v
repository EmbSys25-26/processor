`timescale 1ns / 1ps

`include "constants.vh"

module ctrl_unit(
    input wire [`CPU_IN:0] i_insn,
    output wire [3:0] o_rd,
    output wire [3:0] o_rs,
    output wire [3:0] o_fn,
    output wire [3:0] o_imm,
    output wire [3:0] o_cond,
    output wire [7:0] o_disp,
    output wire [11:0] o_i12,

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

    output wire o_is_alu,
    output wire o_is_add,
    output wire o_is_sub,
    output wire o_is_and,
    output wire o_is_xor,
    output wire o_is_adc,
    output wire o_is_sbc,
    output wire o_is_cmp,
    output wire o_is_srl,
    output wire o_is_sra,

    output wire o_is_sum,
    output wire o_is_log,
    output wire o_is_sr,

    output wire o_is_setcc,
    output wire o_is_getcc
    ,
    output wire o_is_iret,
    output wire o_reads_rd,
    output wire o_reads_rs,
    output wire o_writes_rd,
    output wire o_is_load,
    output wire o_is_store,
    output wire o_uses_cc,
    output wire o_uses_carry,
    output wire o_updates_cc,
    output wire o_irq_interlock
);

/*************************************************************************************
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/
    wire [3:0] _op;
    wire [3:0] _rd;
    wire [3:0] _rs;
    wire [3:0] _fn;
    wire [3:0] _imm;
    wire [11:0] _i12;
    wire [3:0] _cond;
    wire [7:0] _disp;

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

    wire _is_add;
    wire _is_sub;
    wire _is_and;
    wire _is_xor;
    wire _is_adc;
    wire _is_sbc;
    wire _is_cmp;
    wire _is_srl;
    wire _is_sra;

    wire _is_alu;
    wire _is_sum;
    wire _is_log;
    wire _is_sr;
    wire _interlocked_insns;
    wire _is_getcc;
    wire _is_setcc;

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

/*************************************************************************************
 * 2.1 Instruction Decode
 ************************************************************************************/
    assign _op = i_insn[15:12];
    assign _rd = i_insn[11:8];
    assign _rs = i_insn[7:4];
    assign _fn = (_op == `OP_RI) ? i_insn[7:4] : i_insn[3:0];
    assign _imm = i_insn[3:0];
    assign _i12 = i_insn[11:0];
    assign _cond = i_insn[11:8];
    assign _disp = i_insn[7:0];

    assign o_rd = _rd;
    assign o_rs = _rs;
    assign o_fn = _fn;
    assign o_imm = _imm;
    assign o_cond = _cond;
    assign o_disp = _disp;
    assign o_i12 = _i12;

    assign _is_jal = (_op == `OP_JAL);
    assign _is_addi = (_op == `OP_ADDI);
    assign _is_rr = (_op == `OP_RR);
    assign _is_ri = (_op == `OP_RI);
    assign _is_lw = (_op == `OP_LW);
    assign _is_lb = (_op == `OP_LB);
    assign _is_sw = (_op == `OP_SW);
    assign _is_sb = (_op == `OP_SB);
    assign _is_imm = (_op == `OP_IMM);
    assign _is_bx = (_op == `OP_BX);
    assign _is_sys = (_op == `OP_SYS);
    assign _is_cli = (_op == `OP_CLI);
    assign _is_sti = (_op == `OP_STI);

    assign _is_add = (_fn == `FN_ADD);
    assign _is_sub = (_fn == `FN_SUB);
    assign _is_and = (_fn == `FN_AND);
    assign _is_xor = (_fn == `FN_XOR);
    assign _is_adc = (_fn == `FN_ADC);
    assign _is_sbc = (_fn == `FN_SBC);
    assign _is_cmp = (_fn == `FN_CMP);
    assign _is_srl = (_fn == `FN_SRL);
    assign _is_sra = (_fn == `FN_SRA);

    assign _is_alu = _is_rr | _is_ri;
    assign _is_getcc = _is_sys & (_fn == `FN_GETCC);
    assign _is_setcc = _is_sys & (_fn == `FN_SETCC);

    assign o_is_imm = _is_imm;
    assign o_is_bx = _is_bx;
    assign o_is_sys = _is_sys;
    assign o_is_cli = _is_cli;
    assign o_is_sti = _is_sti;

    assign o_is_jal = _is_jal;
    assign o_is_addi = _is_addi;
    assign o_is_rr = _is_rr;
    assign o_is_ri = _is_ri;
    assign o_is_lw = _is_lw;
    assign o_is_lb = _is_lb;
    assign o_is_sw = _is_sw;
    assign o_is_sb = _is_sb;
    assign o_is_alu = _is_alu;
    assign o_is_add = _is_add;
    assign o_is_sub = _is_sub;
    assign o_is_and = _is_and;
    assign o_is_xor = _is_xor;
    assign o_is_adc = _is_adc;
    assign o_is_sbc = _is_sbc;
    assign o_is_cmp = _is_cmp;
    assign o_is_srl = _is_srl;
    assign o_is_sra = _is_sra;
    assign _is_sum = _is_add | _is_sub | _is_adc | _is_sbc;
    assign _is_log = _is_and | _is_xor;
    assign _is_sr = _is_srl | _is_sra;
    assign o_is_sum = _is_sum;
    assign o_is_log = _is_log;
    assign o_is_sr = _is_sr;
    assign o_is_setcc = _is_setcc;
    assign o_is_getcc = _is_getcc;
    assign o_is_iret = (i_insn == `CPU_IRET_INSN);

/*************************************************************************************
 * 2.2 Side-Effect and Hazard Qualifiers
 ************************************************************************************/
    assign _interlocked_insns = _is_imm | (_is_alu & (_is_adc | _is_sbc | _is_cmp));

    assign o_reads_rd = _is_rr | _is_ri | _is_sw | _is_sb;
    assign o_reads_rs = _is_rr | _is_addi | _is_lw | _is_lb | _is_sw | _is_sb | _is_jal | _is_setcc;
    assign o_writes_rd = (_is_alu & ~_is_cmp) | _is_addi | _is_lb | _is_lw | _is_jal | _is_getcc;
    assign o_is_load = _is_lw | _is_lb;
    assign o_is_store = _is_sw | _is_sb;

    assign o_uses_cc = _is_bx;
    assign o_uses_carry = _is_alu & (_is_adc | _is_sbc);
    assign o_updates_cc = ((_is_alu & (_is_sum | _is_cmp)) | _is_addi | _is_setcc);
    assign o_irq_interlock = _interlocked_insns;

endmodule
