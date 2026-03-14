`timescale 1ns / 1ps

`include "constants.vh"

/*
EX stage
Executes ALU/address operations and prepares writeback/memory candidates.
- Consumes decoded control and operand data from ID/EX.
- Computes tentative condition-code and carry updates for architectural commit.
- All outputs are valid-gated so bubbles/flushes do not create side effects.
*/

module ex_stage(
    input wire i_valid,
    input wire [15:0] i_pc,
    input wire [3:0] i_rd,
    input wire [15:0] i_rd_data,
    input wire [15:0] i_rs_data,
    input wire [15:0] i_imm16,
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
    input wire i_restore_cc,
    input wire i_is_iret,
    input wire i_c,
    input wire i_ccz,
    input wire i_ccn,
    input wire i_ccc,
    input wire i_ccv,

    output wire o_valid,
    output wire [15:0] o_pc,
    output wire [3:0] o_rd,
    output wire o_rf_we,
    output wire o_lw,
    output wire o_lb,
    output wire o_sw,
    output wire o_sb,
    output wire [15:0] o_d_ad,
    output wire [15:0] o_store_data,
    output wire [15:0] o_wb_pre_data,
    output wire o_flag_we,
    output wire o_new_ccz,
    output wire o_new_ccn,
    output wire o_new_ccc,
    output wire o_new_ccv,
    output wire o_carry_we,
    output wire o_new_c,
    output wire o_updates_cc_hz,
    output wire o_updates_carry_hz,
    output wire o_is_load,
    output wire o_is_iret
);

/*************************************************************************************
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/
    wire [15:0] _src;
    wire [15:0] _a;
    wire [15:0] _b;
    wire _add;
    wire _ci;
    wire [15:0] _sum;
    wire [15:0] _log;
    wire [15:0] _sr;
    wire _c_w;
    wire _x;
    wire _z;
    wire _n;
    wire _co;
    wire _v;
    wire [15:0] _alu_res;
    wire [4:0] _psw_vector;
    wire _update_cc;

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

/*************************************************************************************
 * 2.1 ALU Datapath
 ************************************************************************************/
    assign _src = i_is_ri ? i_rd_data : i_rs_data;
    assign _a = i_is_rr ? i_rd_data : i_imm16;
    assign _b = _src;

    assign _add = ~(i_is_alu & (i_is_sub | i_is_sbc | i_is_cmp));
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
        .o_co(_c_w),
        .o_x(_x)
    );

    assign _z = (_sum == 16'h0000);
    assign _n = _sum[`CPU_N];
    assign _co = _add ? _c_w : ~_c_w;
    assign _v = _c_w ^ _sum[`CPU_N] ^ _a[`CPU_N] ^ _b[`CPU_N];

    assign _alu_res = ((i_is_alu & i_is_sum) | i_is_addi) ? _sum :
                      ((i_is_alu & i_is_log) ? _log :
                      ((i_is_alu & i_is_sr) ? _sr :
                      (i_is_jal ? (i_pc + 16'h0004) : 16'h0000)));

/*************************************************************************************
 * 2.2 Flag and Writeback Candidates
 ************************************************************************************/
    assign _psw_vector = {i_c, i_ccz, i_ccn, i_ccc, i_ccv};
    assign _update_cc = i_valid & (((i_is_rr | i_is_ri) & (i_is_sum | i_is_cmp)) | i_is_addi);

    assign o_wb_pre_data = i_is_getcc ? {11'b0, _psw_vector} : _alu_res;
    assign o_d_ad = (_sum << 1);
    assign o_store_data = i_rd_data;

    assign o_flag_we = _update_cc | (i_valid & i_restore_cc);
    assign o_new_ccz = i_restore_cc ? i_rs_data[3] : _z;
    assign o_new_ccn = i_restore_cc ? i_rs_data[2] : _n;
    assign o_new_ccc = i_restore_cc ? i_rs_data[1] : _co;
    assign o_new_ccv = i_restore_cc ? i_rs_data[0] : _v;

    assign o_carry_we = i_valid;
    assign o_new_c = i_restore_cc ? i_rs_data[4] : (_co & (i_is_alu & (i_is_adc | i_is_sbc)));

/*************************************************************************************
 * 2.3 Pass-through Controls
 ************************************************************************************/
    assign o_valid = i_valid;
    assign o_pc = i_pc;
    assign o_rd = i_rd;
    assign o_rf_we = i_valid & i_rf_we;
    assign o_lw = i_valid & i_lw;
    assign o_lb = i_valid & i_lb;
    assign o_sw = i_valid & i_sw;
    assign o_sb = i_valid & i_sb;
    assign o_updates_cc_hz = i_valid & ((((i_is_rr | i_is_ri) & (i_is_sum | i_is_cmp)) | i_is_addi | i_restore_cc));
    assign o_updates_carry_hz = i_valid;
    assign o_is_load = i_valid & (i_lw | i_lb);
    assign o_is_iret = i_valid & i_is_iret;

endmodule