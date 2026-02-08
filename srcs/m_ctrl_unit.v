`timescale 1ns / 1ps

`include "constants.vh"

module ctrl_unit(
    input wire i_clk,
    input wire i_rst,
    input wire [`CPU_IN:0] i_insn,
    input wire i_hit,
    input wire i_rdy,
    input wire i_ccz,
    input wire i_ccn,
    input wire i_ccc,
    input wire i_ccv,
    input wire i_irq_take,
    output wire o_irq_save,
    output wire [3:0] o_rd,
    output wire [3:0] o_rs,
    output wire [3:0] o_imm,
    output wire [7:0] o_disp,
    output wire o_insn_ce,
    output wire o_imm_pre,
    output wire [11:0] o_i12_pre,
    output wire o_rf_we,
    output wire o_lw,
    output wire o_lb,
    output wire o_sw,
    output wire o_sb,
    output wire o_int_en,
    output wire o_br_taken,
    output wire o_iret_detected,
    output wire o_valid_insn_ce,
    output wire o_exec_ce,
    output wire o_restore_cc,
    output wire o_is_jal,
    output wire o_is_addi,
    output wire o_is_rr,
    output wire o_is_ri,
    output wire o_is_lw,
    output wire o_is_lb,
    output wire o_is_sw,
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
    output wire o_is_getcc
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
    wire _is_cli_op;
    wire _is_sti_op;

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
    wire _mem;

    reg _imm_pre;
    reg [11:0] _i12_pre;
    reg _irq_save;
    reg _gie;
    reg _t;

    wire _is_cli;
    wire _is_sti;
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
    assign o_imm = _imm;
    assign o_disp = _disp;

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
    assign _is_cli_op = (_op == `OP_CLI);
    assign _is_sti_op = (_op == `OP_STI);

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

    assign o_is_jal = _is_jal;
    assign o_is_addi = _is_addi;
    assign o_is_rr = _is_rr;
    assign o_is_ri = _is_ri;
    assign o_is_lw = _is_lw;
    assign o_is_lb = _is_lb;
    assign o_is_sw = _is_sw;
    assign o_is_alu = _is_alu;
    assign o_is_sub = _is_sub;
    assign o_is_xor = _is_xor;
    assign o_is_adc = _is_adc;
    assign o_is_sbc = _is_sbc;
    assign o_is_cmp = _is_cmp;
    assign o_is_sra = _is_sra;
    assign o_is_sum = _is_add | _is_sub | _is_adc | _is_sbc;
    assign o_is_log = _is_and | _is_xor;
    assign o_is_sr = _is_srl | _is_sra;
    assign o_is_getcc = _is_getcc;

/*************************************************************************************
 * 2.2 Memory and Instruction Enables
 ************************************************************************************/
    assign o_lw = i_hit & _is_lw;
    assign o_lb = i_hit & _is_lb;
    assign o_sw = i_hit & _is_sw;
    assign o_sb = i_hit & _is_sb;
    assign _mem = i_hit & (_is_lb | _is_lw | _is_sb | _is_sw);

    assign o_insn_ce = i_rst | ~(_mem & ~i_rdy);
    assign o_exec_ce = i_hit & o_insn_ce;
    assign o_valid_insn_ce = o_exec_ce & ~i_irq_take;

/*************************************************************************************
 * 2.3 Prefix Tracking
 ************************************************************************************/
    always @(posedge i_clk) begin
        if (i_rst) begin
            _imm_pre <= 1'b0;
        end else if (o_exec_ce) begin
            _imm_pre <= _is_imm;
        end
    end

    always @(posedge i_clk) begin
        if (o_exec_ce) begin
            _i12_pre <= _i12;
        end
    end

    assign o_imm_pre = _imm_pre;
    assign o_i12_pre = _i12_pre;

/*************************************************************************************
 * 2.4 Branch and Writeback Controls
 ************************************************************************************/
    assign o_rf_we = i_hit & o_insn_ce & ~i_rst & ((_is_alu & ~_is_cmp) | _is_addi | _is_lb | _is_lw | _is_jal);

    always @(*) begin
        if (i_rst) begin
            _t = 1'b0;
        end else begin
            case (_cond & 4'b1110)
                `BR_BR:   _t = 1'b1;
                `BR_BEQ:  _t = i_ccz;
                `BR_BC:   _t = i_ccc;
                `BR_BV:   _t = i_ccv;
                `BR_BLT:  _t = i_ccn ^ i_ccv;
                `BR_BLE:  _t = (i_ccn ^ i_ccv) | i_ccz;
                `BR_BLTU: _t = ~i_ccz & ~i_ccc;
                `BR_BLEU: _t = i_ccz | ~i_ccc;
                default:  _t = 1'b0;
            endcase
        end
    end

    assign o_br_taken = o_exec_ce & ~_irq_save & (_is_jal | (i_hit & _is_bx & (_cond[0] ? ~_t : _t)));

/*************************************************************************************
 * 2.5 Interrupt Controls
 ************************************************************************************/
    assign _is_cli = i_hit & o_exec_ce & _is_cli_op;
    assign _is_sti = i_hit & o_exec_ce & _is_sti_op;
    assign _interlocked_insns = _is_imm | (_is_alu & (_is_adc | _is_sbc | _is_cmp));

    always @(posedge i_clk) begin
        if (i_rst) begin
            _gie <= 1'b1;
        end else if (i_irq_take) begin
            _gie <= 1'b0;
        end else if (_is_cli) begin
            _gie <= 1'b0;
        end else if (_is_sti) begin
            _gie <= 1'b1;
        end
    end

    assign o_int_en = i_hit & _gie & ~_interlocked_insns;

    always @(posedge i_clk) begin
        _irq_save <= i_irq_take;
    end

    assign o_irq_save = _irq_save;
    assign o_iret_detected = i_hit & (i_insn == `CPU_IRET_INSN);
    assign o_restore_cc = _is_setcc;

endmodule
