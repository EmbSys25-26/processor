`timescale 1ns / 1ps

`include "constants.vh"

module datapath(
    input wire i_clk,
    input wire i_rst,
    input wire i_hit,
    input wire i_exec_ce,
    input wire [`CPU_AN:0] i_i_ad_rst,
    input wire [3:0] i_rd,
    input wire [3:0] i_rs,
    input wire [3:0] i_imm,
    input wire [7:0] i_disp,
    input wire i_imm_pre,
    input wire [11:0] i_i12_pre,
    input wire i_rf_we,
    input wire i_br_taken,
    input wire i_irq_take,
    input wire i_irq_save,
    input wire [15:0] i_irq_vector,
    input wire i_restore_cc,
    input wire i_is_jal,
    input wire i_is_addi,
    input wire i_is_rr,
    input wire i_is_ri,
    input wire i_is_lw,
    input wire i_is_lb,
    input wire i_is_sw,
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
    input wire [`CPU_N:0] i_data_in,
    output wire [`CPU_N:0] o_data_out,
    output wire [`CPU_AN:0] o_i_ad,
    output wire [`CPU_AN:0] o_d_ad,
    output wire o_ccz,
    output wire o_ccn,
    output wire o_ccc,
    output wire o_ccv
);

/*************************************************************************************
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/
    (* mark_debug = "true" *) reg [`CPU_AN:0] _pc;
    reg [`CPU_AN:0] _pc_q;
    wire [`CPU_N:0] _pcincd;

    reg _c;
    reg _ccz;
    reg _ccn;
    reg _ccc;
    reg _ccv;
    wire [4:0] _psw_vector;

    wire [`CPU_N:0] _dreg;
    wire [`CPU_N:0] _sreg;
    wire [`CPU_N:0] _regfile_din_normal;
    (* mark_debug = "true" *) wire _rf_we_final;
    wire [3:0] _rf_wr_ad_final;
    (* mark_debug = "true" *) wire [`CPU_N:0] _regfile_din;

    wire [`CPU_N:0] _a;
    wire [`CPU_N:0] _b;

    wire [`CPU_N:0] _sum;
    wire _add;
    wire _ci;
    wire _c_w;
    wire _x;

    wire [`CPU_N:0] _log;
    wire [`CPU_N:0] _sr;
    wire [`CPU_N:0] _alu_res;

    wire _z;
    wire _n;
    wire _co;
    wire _v;

    wire [3:0] _cc_restore;
    wire _c_restore;
    wire _update_cc;

    wire _word_off;
    wire _sxi;
    wire [10:0] _sxi11;
    wire _i_4;
    wire _i_0;
    wire [`CPU_N:0] _imm16;

    wire [6:0] _sxd7;
    wire [`CPU_N:0] _sxd16;
    wire [`CPU_N:0] _pcinc;

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

/*************************************************************************************
 * 2.1 Control Qualifiers (from ctrl_unit)
 ************************************************************************************/
/*************************************************************************************
 * 2.2 Register File and Writeback Mux
 ************************************************************************************/
    assign _regfile_din_normal = (i_is_lw | i_is_lb) ? i_data_in : _alu_res;

    assign _rf_we_final = (i_irq_save | i_is_getcc) ? 1'b1 : i_rf_we;
    assign _rf_wr_ad_final = i_irq_save ? 4'hE : i_rd;
    assign _regfile_din = i_irq_save ? _pc_q : (i_is_getcc ? {11'b0, _psw_vector} : _regfile_din_normal);

    regfile16x16 u_regfile (
        .i_clk(i_clk),
        .i_we(_rf_we_final),
        .i_wr_ad(_rf_wr_ad_final),
        .i_ad(i_is_ri ? i_rd : i_rs),
        .i_d(_regfile_din),
        .o_wr_o(_dreg),
        .o_o(_sreg)
    );

/*************************************************************************************
 * 2.3 PC and Immediate Paths
 ************************************************************************************/
    always @(posedge i_clk) begin
        _pc_q <= _pc;
        if (i_br_taken) begin
            _pc_q <= _pcincd;
        end

        if (i_rst) begin
            _pc <= i_i_ad_rst - 16'h0002;
        end else if (i_exec_ce | i_irq_take) begin
            _pc <= o_i_ad;
        end
    end

    assign _word_off = i_is_lw | i_is_sw | i_is_jal;
    assign _sxi = (i_is_addi | i_is_alu) & i_imm[3];
    assign _sxi11 = {11{_sxi}};
    assign _i_4 = _sxi | (_word_off & i_imm[0]);
    assign _i_0 = (~_word_off) & i_imm[0];
    assign _imm16 = i_imm_pre ? {i_i12_pre, i_imm} : {_sxi11, _i_4, i_imm[3:1], _i_0};

/*************************************************************************************
 * 2.4 ALU and Flags
 ************************************************************************************/
    assign _a = i_is_rr ? _dreg : _imm16;
    assign _b = _sreg;

    assign _add = ~(i_is_alu & (i_is_sub | i_is_sbc | i_is_cmp));
    assign _ci = _add ? _c : ~_c;

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

    assign _psw_vector = {_c, _ccz, _ccn, _ccc, _ccv};

    assign _cc_restore = i_restore_cc ? _sreg[3:0] : 4'b0000;
    assign _c_restore = i_restore_cc ? _sreg[4] : 1'b0;

    assign _update_cc = i_exec_ce & (((i_is_rr | i_is_ri) & (i_is_sum | i_is_cmp)) | i_is_addi);

    always @(posedge i_clk) begin
        if (i_rst) begin
            {_ccz, _ccn, _ccc, _ccv} <= 4'b0000;
        end else if (i_restore_cc) begin
            {_ccz, _ccn, _ccc, _ccv} <= _cc_restore;
        end else if (_update_cc) begin
            {_ccz, _ccn, _ccc, _ccv} <= {_z, _n, _co, _v};
        end
    end

    always @(posedge i_clk) begin
        if (i_rst) begin
            _c <= 1'b0;
        end else if (i_restore_cc) begin
            _c <= _c_restore;
        end else if (i_exec_ce) begin
            _c <= _co & (i_is_alu & (i_is_adc | i_is_sbc));
        end
    end

    assign _alu_res = ((i_is_alu & i_is_sum) | i_is_addi) ? _sum :
                      ((i_is_alu & i_is_log) ? _log :
                      ((i_is_alu & i_is_sr) ? _sr :
                      (i_is_jal ? _pc : 16'h0000)));

/*************************************************************************************
 * 2.5 External Buses
 ************************************************************************************/
    assign o_data_out = _dreg;

    assign _sxd7 = {7{i_disp[7]}};
    assign _sxd16 = {_sxd7, i_disp, 1'b0};
    assign _pcinc = i_br_taken ? _sxd16 : {14'b0, i_hit, 1'b0};
    assign _pcincd = _pcinc + _pc;

    assign o_i_ad = i_rst ? i_i_ad_rst :
                    (i_irq_take ? i_irq_vector :
                    ((i_hit & i_is_jal) ? _sum : _pcincd));

    assign o_d_ad = (_sum << 1);

    assign o_ccz = _ccz;
    assign o_ccn = _ccn;
    assign o_ccc = _ccc;
    assign o_ccv = _ccv;

endmodule
