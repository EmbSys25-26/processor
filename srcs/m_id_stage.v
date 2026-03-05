`timescale 1ns / 1ps

`include "constants.vh"

/*
ID stage
Decodes instruction fields and derives execution/memory/control intent.
- Builds immediate and branch decision signals from the fetched instruction.
- Emits hazard metadata (reads/writes/load/store/cc/carry usage) for stall logic.
- Invalid input is propagated as a bubble (no downstream side effects).
*/

module id_stage(
    input wire i_valid,
    input wire [15:0] i_pc,
    input wire [15:0] i_insn,
    input wire [15:0] i_rd_data,
    input wire [15:0] i_rs_data,
    input wire i_imm_pre_state,
    input wire [11:0] i_i12_pre_state,
    input wire i_ccz,
    input wire i_ccn,
    input wire i_ccc,
    input wire i_ccv,

    output wire o_valid,
    output wire o_exec_valid,
    output wire [15:0] o_pc,
    output wire [3:0] o_rd,
    output wire [3:0] o_rs,
    output wire [3:0] o_imm,
    output wire [11:0] o_i12,
    output wire [15:0] o_rd_data,
    output wire [15:0] o_rs_data,
    output wire [15:0] o_imm16,
    output wire [15:0] o_branch_target,
    output wire o_branch_take,

    output wire o_is_imm,
    output wire o_is_bx,
    output wire o_is_cli,
    output wire o_is_sti,
    output wire o_is_iret,
    output wire o_irq_interlock,

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
    output wire o_restore_cc,

    output wire o_reads_rd,
    output wire o_reads_rs,
    output wire o_writes_rd,
    output wire o_is_load,
    output wire o_is_store,
    output wire o_uses_cc,
    output wire o_uses_carry,
    output wire o_updates_cc
);

/*************************************************************************************
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/
    wire [3:0] _rd;
    wire [3:0] _rs;
    wire [3:0] _fn;
    wire [3:0] _imm;
    wire [3:0] _cond;
    wire [7:0] _disp;
    wire [11:0] _i12;

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

    wire _reads_rd;
    wire _reads_rs;
    wire _writes_rd;
    wire _is_load;
    wire _is_store;
    wire _uses_cc;
    wire _uses_carry;
    wire _updates_cc;
    wire _irq_interlock;

    wire _word_off;
    wire _sxi;
    wire [10:0] _sxi11;
    wire _i_4;
    wire _i_0;
    wire [15:0] _imm16;

    wire [6:0] _sxd7;
    wire [15:0] _sxd16;
    wire _bdu_take;

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

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
        .o_is_load(_is_load),
        .o_is_store(_is_store),
        .o_uses_cc(_uses_cc),
        .o_uses_carry(_uses_carry),
        .o_updates_cc(_updates_cc),
        .o_irq_interlock(_irq_interlock)
    );

    bdu u_bdu (
        .i_cond(_cond),
        .i_ccz(i_ccz),
        .i_ccn(i_ccn),
        .i_ccc(i_ccc),
        .i_ccv(i_ccv),
        .o_take(_bdu_take)
    );


    assign _word_off = _is_lw | _is_sw | _is_jal;
    assign _sxi = (_is_addi | _is_alu) & _imm[3];
    assign _sxi11 = {11{_sxi}};
    assign _i_4 = _sxi | (_word_off & _imm[0]);
    assign _i_0 = (~_word_off) & _imm[0];
    assign _imm16 = i_imm_pre_state ? {i_i12_pre_state, _imm} : {_sxi11, _i_4, _imm[3:1], _i_0};

    assign _sxd7 = {7{_disp[7]}};
    assign _sxd16 = {_sxd7, _disp, 1'b0};

    assign o_branch_take = i_valid & (_is_jal | (_is_bx & _bdu_take));
    assign o_branch_target = _is_jal ? (_imm16 + i_rs_data) : (i_pc + _sxd16);

    assign o_valid = i_valid;
    assign o_exec_valid = i_valid & ~(_is_imm | _is_cli | _is_sti | _is_bx);
    assign o_pc = i_pc;
    assign o_rd = _rd;
    assign o_rs = _rs;
    assign o_imm = _imm;
    assign o_i12 = _i12;
    assign o_rd_data = i_rd_data;
    assign o_rs_data = i_rs_data;
    assign o_imm16 = _imm16;

    assign o_is_imm = _is_imm;
    assign o_is_bx = _is_bx;
    assign o_is_cli = _is_cli;
    assign o_is_sti = _is_sti;
    assign o_is_iret = _is_iret;
    assign o_irq_interlock = _irq_interlock;

    assign o_rf_we = i_valid & _writes_rd;
    assign o_lw = i_valid & _is_lw;
    assign o_lb = i_valid & _is_lb;
    assign o_sw = i_valid & _is_sw;
    assign o_sb = i_valid & _is_sb;
    assign o_is_jal = _is_jal;
    assign o_is_addi = _is_addi;
    assign o_is_rr = _is_rr;
    assign o_is_ri = _is_ri;
    assign o_is_alu = _is_alu;
    assign o_is_sub = _is_sub;
    assign o_is_xor = _is_xor;
    assign o_is_adc = _is_adc;
    assign o_is_sbc = _is_sbc;
    assign o_is_cmp = _is_cmp;
    assign o_is_sra = _is_sra;
    assign o_is_sum = _is_sum;
    assign o_is_log = _is_log;
    assign o_is_sr = _is_sr;
    assign o_is_getcc = _is_getcc;
    assign o_restore_cc = _is_setcc;

    assign o_reads_rd = _reads_rd;
    assign o_reads_rs = _reads_rs;
    assign o_writes_rd = _writes_rd;
    assign o_is_load = _is_load;
    assign o_is_store = _is_store;
    assign o_uses_cc = _uses_cc;
    assign o_uses_carry = _uses_carry;
    assign o_updates_cc = _updates_cc;

endmodule
