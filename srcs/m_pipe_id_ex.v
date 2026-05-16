`timescale 1ns / 1ps

// ============================================================
// ID/EX pipeline register
//
// This is the largest pipeline register in the design because the
// entire decoded control bundle (operands + all classification flags)
// must flow through it into the EX stage.
//
// Three conditions clear the register to a NOP:
//   1. Reset (i_rst)
//   2. Flush (i_flush) - IRQ accept: squash instruction entering EX
//   3. Bubble (i_bubble) - decode hazard: insert a harmless NOP cycle
//      while the pipeline above stalls waiting for a hazard to clear.
//
// The distinction between flush and bubble matters to the hazard unit:
//   - During a MEM wait, stall_ex holds the register frozen (i_stall).
//   - During a pure decode hazard, bubble_ex injects a NOP into ID/EX
//     without freezing EX/MEM, allowing the downstream stages to continue.
// ============================================================
module pipe_id_ex(
    input wire i_clk,
    input wire i_rst,
    input wire i_stall,         // Freeze: hold register contents (MEM wait) or Inject NOP: decode hazard without MEM wait
    input wire i_flush,         // Squash: IRQ accept (clear to NOP)
    input wire i_valid,
    input wire [15:0] i_pc,
    input wire [3:0] i_rd,
    input wire [3:0] i_rs,
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
    input wire i_is_load,
    output reg o_valid,
    
    // Branch + BPU signals
    input wire i_is_bx,
    input wire [3:0] i_cond,
    input wire [15:0] i_branch_target,
    input wire i_pred_taken,
    input wire [15:0] i_pred_target,
    input wire [`GHR_W-1:0] i_lookup_ghr,
    
    output reg [15:0] o_pc,
    output reg [3:0] o_rd,
    output reg [3:0] o_rd_second,
    output reg [3:0] o_rs,
    output reg [15:0] o_rd_data,
    output reg [15:0] o_rs_data,
    output reg [15:0] o_imm16,
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
    output reg o_is_load,
    
    // Branch + BPU outputs
    output reg o_is_bx,
    output reg [3:0] o_cond,
    output reg [15:0] o_branch_target,
    output reg o_pred_taken,
    output reg [15:0] o_pred_target,
    output reg [`GHR_W-1:0] o_lookup_ghr
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
        if (i_rst || i_flush) begin
            // Clear to NOP: zero all control signals so EX sees a harmless bubble
            o_valid        <= 1'b0;
            o_pc           <= 16'h0000;
            o_rd           <= 4'h0;
            o_rd_second    <= 4'h0;
            o_rs           <= 4'h0;
            o_rd_data      <= 16'h0000;
            o_rs_data      <= 16'h0000;
            o_imm16        <= 16'h0000;
            o_rf_we        <= 1'b0;
            o_lw           <= 1'b0;
            o_lb           <= 1'b0;
            o_sw           <= 1'b0;
            o_sb           <= 1'b0;
            o_is_jal       <= 1'b0;
            o_is_addi      <= 1'b0;
            o_is_rr        <= 1'b0;
            o_is_ri        <= 1'b0;
            o_is_alu       <= 1'b0;
            o_is_sub       <= 1'b0;
            o_is_xor       <= 1'b0;
            o_is_adc       <= 1'b0;
            o_is_sbc       <= 1'b0;
            o_is_cmp       <= 1'b0;
            o_is_sra       <= 1'b0;
            o_is_sum       <= 1'b0;
            o_is_log       <= 1'b0;
            o_is_sr        <= 1'b0;
            o_is_getcc     <= 1'b0;
            o_restore_cc   <= 1'b0;
            o_is_load      <= 1'b0;
            
            o_is_bx         <= 1'b0;
            o_cond          <= 4'h0;
            o_branch_target <= 16'h0000;
            o_pred_taken    <= 1'b0;
            o_pred_target   <= 16'h0000;
            o_lookup_ghr    <= {`GHR_W{1'b0}};
            
        end else if (!i_stall) begin
            // Normal advance: capture the full decode bundle
            o_valid        <= i_valid;
            o_pc           <= i_pc;
            o_rd           <= i_rd;
            o_rd_second    <= i_rd;
            o_rs           <= i_rs;
            o_rd_data      <= i_rd_data;
            o_rs_data      <= i_rs_data;
            o_imm16        <= i_imm16;
            o_rf_we        <= i_rf_we;
            o_lw           <= i_lw;
            o_lb           <= i_lb;
            o_sw           <= i_sw;
            o_sb           <= i_sb;
            o_is_jal       <= i_is_jal;
            o_is_addi      <= i_is_addi;
            o_is_rr        <= i_is_rr;
            o_is_ri        <= i_is_ri;
            o_is_alu       <= i_is_alu;
            o_is_sub       <= i_is_sub;
            o_is_xor       <= i_is_xor;
            o_is_adc       <= i_is_adc;
            o_is_sbc       <= i_is_sbc;
            o_is_cmp       <= i_is_cmp;
            o_is_sra       <= i_is_sra;
            o_is_sum       <= i_is_sum;
            o_is_log       <= i_is_log;
            o_is_sr        <= i_is_sr;
            o_is_getcc     <= i_is_getcc;
            o_restore_cc   <= i_restore_cc;
            o_is_load      <= i_is_load;
            
            o_is_bx         <= i_is_bx;
            o_cond          <= i_cond;
            o_branch_target <= i_branch_target;
            o_pred_taken    <= i_pred_taken;
            o_pred_target   <= i_pred_target;
            o_lookup_ghr    <= i_lookup_ghr;
        end
        // If stalled: all outputs hold (implicit register freeze)
    end

endmodule