`timescale 1ns / 1ps

/*
ID/EX pipeline register
Transfers decode outputs and control intents into EX.
- Flush/bubble/reset injects a full NOP control bundle (no side effects).
- Stall freezes the current ID/EX state.
- Otherwise captures all decoded operands/control/hazard metadata.
*/

module pipe_id_ex(
    input wire i_clk,
    input wire i_rst,
    input wire i_stall,
    input wire i_bubble,
    input wire i_flush,
    input wire i_valid,
    input wire [15:0] i_pc,
    input wire [3:0] i_rd,
    input wire [3:0] i_rs,
    input wire [3:0] i_imm,
    input wire [11:0] i_i12,
    input wire [15:0] i_rd_data,
    input wire [15:0] i_rs_data,
    input wire [15:0] i_imm16,
    input wire i_is_imm,
    input wire i_is_bx,
    input wire i_is_cli,
    input wire i_is_sti,
    input wire i_is_iret,
    input wire i_irq_interlock,
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
    input wire i_reads_rd,
    input wire i_reads_rs,
    input wire i_writes_rd,
    input wire i_is_load,
    input wire i_is_store,
    input wire i_uses_cc,
    input wire i_uses_carry,
    input wire i_updates_cc,
    output reg o_valid,
    output reg [15:0] o_pc,
    output reg [3:0] o_rd,
    output reg [3:0] o_rs,
    output reg [3:0] o_imm,
    output reg [11:0] o_i12,
    output reg [15:0] o_rd_data,
    output reg [15:0] o_rs_data,
    output reg [15:0] o_imm16,
    output reg o_is_imm,
    output reg o_is_bx,
    output reg o_is_cli,
    output reg o_is_sti,
    output reg o_is_iret,
    output reg o_irq_interlock,
    output reg o_rf_we,
    output reg o_lw,
    output reg o_lb,
    output reg o_sw,
    output reg o_sb,
    output reg o_is_jal,
    output reg o_is_addi,
    output reg o_is_rr,
    output reg o_is_ri,
    output reg o_is_alu,
    output reg o_is_sub,
    output reg o_is_xor,
    output reg o_is_adc,
    output reg o_is_sbc,
    output reg o_is_cmp,
    output reg o_is_sra,
    output reg o_is_sum,
    output reg o_is_log,
    output reg o_is_sr,
    output reg o_is_getcc,
    output reg o_restore_cc,
    output reg o_reads_rd,
    output reg o_reads_rs,
    output reg o_writes_rd,
    output reg o_is_load,
    output reg o_is_store,
    output reg o_uses_cc,
    output reg o_uses_carry,
    output reg o_updates_cc
);

/*************************************************************************************
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

/*************************************************************************************
 * 2.1 ID/EX Register
 ************************************************************************************/
    always @(posedge i_clk) begin
        if (i_rst || i_flush || i_bubble) begin
            o_valid <= 1'b0;
            o_pc <= 16'h0000;
            o_rd <= 4'h0;
            o_rs <= 4'h0;
            o_imm <= 4'h0;
            o_i12 <= 12'h000;
            o_rd_data <= 16'h0000;
            o_rs_data <= 16'h0000;
            o_imm16 <= 16'h0000;
            o_is_imm <= 1'b0;
            o_is_bx <= 1'b0;
            o_is_cli <= 1'b0;
            o_is_sti <= 1'b0;
            o_is_iret <= 1'b0;
            o_irq_interlock <= 1'b0;
            o_rf_we <= 1'b0;
            o_lw <= 1'b0;
            o_lb <= 1'b0;
            o_sw <= 1'b0;
            o_sb <= 1'b0;
            o_is_jal <= 1'b0;
            o_is_addi <= 1'b0;
            o_is_rr <= 1'b0;
            o_is_ri <= 1'b0;
            o_is_alu <= 1'b0;
            o_is_sub <= 1'b0;
            o_is_xor <= 1'b0;
            o_is_adc <= 1'b0;
            o_is_sbc <= 1'b0;
            o_is_cmp <= 1'b0;
            o_is_sra <= 1'b0;
            o_is_sum <= 1'b0;
            o_is_log <= 1'b0;
            o_is_sr <= 1'b0;
            o_is_getcc <= 1'b0;
            o_restore_cc <= 1'b0;
            o_reads_rd <= 1'b0;
            o_reads_rs <= 1'b0;
            o_writes_rd <= 1'b0;
            o_is_load <= 1'b0;
            o_is_store <= 1'b0;
            o_uses_cc <= 1'b0;
            o_uses_carry <= 1'b0;
            o_updates_cc <= 1'b0;
        end else if (!i_stall) begin
            o_valid <= i_valid;
            o_pc <= i_pc;
            o_rd <= i_rd;
            o_rs <= i_rs;
            o_imm <= i_imm;
            o_i12 <= i_i12;
            o_rd_data <= i_rd_data;
            o_rs_data <= i_rs_data;
            o_imm16 <= i_imm16;
            o_is_imm <= i_is_imm;
            o_is_bx <= i_is_bx;
            o_is_cli <= i_is_cli;
            o_is_sti <= i_is_sti;
            o_is_iret <= i_is_iret;
            o_irq_interlock <= i_irq_interlock;
            o_rf_we <= i_rf_we;
            o_lw <= i_lw;
            o_lb <= i_lb;
            o_sw <= i_sw;
            o_sb <= i_sb;
            o_is_jal <= i_is_jal;
            o_is_addi <= i_is_addi;
            o_is_rr <= i_is_rr;
            o_is_ri <= i_is_ri;
            o_is_alu <= i_is_alu;
            o_is_sub <= i_is_sub;
            o_is_xor <= i_is_xor;
            o_is_adc <= i_is_adc;
            o_is_sbc <= i_is_sbc;
            o_is_cmp <= i_is_cmp;
            o_is_sra <= i_is_sra;
            o_is_sum <= i_is_sum;
            o_is_log <= i_is_log;
            o_is_sr <= i_is_sr;
            o_is_getcc <= i_is_getcc;
            o_restore_cc <= i_restore_cc;
            o_reads_rd <= i_reads_rd;
            o_reads_rs <= i_reads_rs;
            o_writes_rd <= i_writes_rd;
            o_is_load <= i_is_load;
            o_is_store <= i_is_store;
            o_uses_cc <= i_uses_cc;
            o_uses_carry <= i_uses_carry;
            o_updates_cc <= i_updates_cc;
        end
    end

endmodule