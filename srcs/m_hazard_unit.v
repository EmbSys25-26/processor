`timescale 1ns / 1ps

module hazard_unit(
    input wire i_id_valid,
    input wire [3:0] i_id_rd,
    input wire [3:0] i_id_rs,
    input wire i_id_reads_rd,
    input wire i_id_reads_rs,
    input wire i_id_uses_cc,
    input wire i_id_uses_carry,
    input wire i_branch_take,
    input wire i_mem_wait,
    input wire i_irq_take,

    input wire i_idex_valid,
    input wire i_idex_rf_we,
    input wire [3:0] i_idex_rd,
    input wire i_idex_is_load,
    input wire i_idex_updates_cc,
    input wire i_idex_updates_carry,

    input wire i_exmem_valid,
    input wire i_exmem_rf_we,
    input wire [3:0] i_exmem_rd,
    input wire i_exmem_updates_cc,
    input wire i_exmem_updates_carry,

    input wire i_memwb_valid,
    input wire i_memwb_rf_we,
    input wire [3:0] i_memwb_rd,
    input wire i_memwb_updates_cc,
    input wire i_memwb_updates_carry,

    output wire o_stall_if,
    output wire o_stall_id,
    output wire o_stall_ex,
    output wire o_bubble_ex,
    output wire o_flush_ifid,
    output wire o_flush_idex,
    output wire o_accept_irq
);

/*************************************************************************************
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/
    wire _idex_pending;
    wire _exmem_pending;
    wire _memwb_pending;
    wire _match_idex;
    wire _match_exmem;
    wire _match_memwb;
    wire _raw_hazard;
    wire _load_use_hazard;
    wire _cc_hazard;
    wire _carry_hazard;
    wire _decode_hazard;
    wire _accept_irq;

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

/*************************************************************************************
 * 2.1 Data/CC Hazard Predicates
 ************************************************************************************/
    assign _idex_pending = i_idex_valid & i_idex_rf_we & (i_idex_rd != 4'h0);
    assign _exmem_pending = i_exmem_valid & i_exmem_rf_we & (i_exmem_rd != 4'h0);
    assign _memwb_pending = i_memwb_valid & i_memwb_rf_we & (i_memwb_rd != 4'h0);

    assign _match_idex = (i_id_reads_rd & (i_id_rd == i_idex_rd)) | (i_id_reads_rs & (i_id_rs == i_idex_rd));
    assign _match_exmem = (i_id_reads_rd & (i_id_rd == i_exmem_rd)) | (i_id_reads_rs & (i_id_rs == i_exmem_rd));
    assign _match_memwb = (i_id_reads_rd & (i_id_rd == i_memwb_rd)) | (i_id_reads_rs & (i_id_rs == i_memwb_rd));

    assign _raw_hazard = i_id_valid & ((_idex_pending & _match_idex) | (_exmem_pending & _match_exmem) | (_memwb_pending & _match_memwb));
    // Ignore load-use hazards on rd=r0, since r0 is architecturally constant zero.
    assign _load_use_hazard = i_id_valid & i_idex_valid & i_idex_is_load & (i_idex_rd != 4'h0) & _match_idex;
    assign _cc_hazard = i_id_valid & i_id_uses_cc & (i_idex_updates_cc | i_exmem_updates_cc | i_memwb_updates_cc);
    assign _carry_hazard = i_id_valid & i_id_uses_carry & (i_idex_updates_carry | i_exmem_updates_carry | i_memwb_updates_carry);
    assign _decode_hazard = _raw_hazard | _load_use_hazard | _cc_hazard | _carry_hazard;

/*************************************************************************************
 * 2.2 Control Outputs
 ************************************************************************************/
    assign _accept_irq = i_irq_take & ~i_mem_wait;

    assign o_stall_if = i_mem_wait | _decode_hazard;
    assign o_stall_id = i_mem_wait | _decode_hazard;
    assign o_stall_ex = i_mem_wait;
    // During a MEM wait, EX/MEM is frozen and ID/EX must be preserved.
    // Inject bubbles only for pure decode hazards when MEM is not stalling.
    assign o_bubble_ex = _decode_hazard & ~i_mem_wait;
    assign o_flush_ifid = i_branch_take | _accept_irq;
    assign o_flush_idex = _accept_irq;
    assign o_accept_irq = _accept_irq;

endmodule
