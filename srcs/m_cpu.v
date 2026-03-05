`timescale 1ns / 1ps

`include "constants.vh"

module cpu(
    input wire i_clk,
    input wire i_rst,
    input wire [15:0] i_i_ad_rst,
    output wire o_insn_ce,
    output wire [15:0] o_i_ad,
    input wire [15:0] i_insn,
    input wire i_hit,
    output wire [15:0] o_d_ad,
    input wire i_rdy,
    output wire o_sw,
    output wire o_sb,
    output wire o_lw,
    output wire o_lb,
    output wire [15:0] o_data_out,
    input wire [15:0] i_data_in,
    input wire i_irq_take,
    input wire [15:0] i_irq_vector,
    output wire o_in_irq,
    output wire o_int_en,
    output wire o_iret_detected,
    output wire o_br_taken
);

/*************************************************************************************
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/
    
    // Global + Commited state wires 
    reg [15:0] _pc;
    wire [15:0] _pc_next;

    reg _imm_pre_state;
    reg [11:0] _i12_pre_state;
    reg _gie;

    reg _c;
    reg _ccz;
    reg _ccn;
    reg _ccc;
    reg _ccv;

    reg [1:0] _irq_depth;
    reg [1:0] _irq_depth_n;
    reg _in_irq;
    reg _irq_req_latched;
    wire _irq_take_oneshot;

    // IF stage wires
    wire _if_insn_ce;
    wire _if_valid;
    wire [15:0] _if_pc;
    wire [15:0] _if_insn;

    // IF/ID pipe register wires
    wire _ifid_valid;
    wire [15:0] _ifid_pc;
    wire [15:0] _ifid_insn;

    // ID stage wires
    wire _id_valid;
    wire _id_exec_valid;
    wire [15:0] _id_pc;
    wire [3:0] _id_rd;
    wire [3:0] _id_rs;
    wire [3:0] _id_imm;
    wire [11:0] _id_i12;
    wire [15:0] _id_rd_data;
    wire [15:0] _id_rs_data;
    wire [15:0] _id_imm16;
    wire [15:0] _id_branch_target;
    wire _id_branch_take;
    wire _id_is_imm;
    wire _id_is_bx;
    wire _id_is_cli;
    wire _id_is_sti;
    wire _id_is_iret;
    wire _id_irq_interlock;
    wire _id_rf_we;
    wire _id_lw;
    wire _id_lb;
    wire _id_sw;
    wire _id_sb;
    wire _id_is_jal;
    wire _id_is_addi;
    wire _id_is_rr;
    wire _id_is_ri;
    wire _id_is_alu;
    wire _id_is_sub;
    wire _id_is_xor;
    wire _id_is_adc;
    wire _id_is_sbc;
    wire _id_is_cmp;
    wire _id_is_sra;
    wire _id_is_sum;
    wire _id_is_log;
    wire _id_is_sr;
    wire _id_is_getcc;
    wire _id_restore_cc;
    wire _id_reads_rd;
    wire _id_reads_rs;
    wire _id_writes_rd;
    wire _id_is_load;
    wire _id_is_store;
    wire _id_uses_cc;
    wire _id_uses_carry;
    wire _id_updates_cc;

    // RF wires 
    wire _rf_we;
    wire [3:0] _rf_wa;
    wire [3:0] _rf_ra;
    wire [3:0] _rf_rb;
    wire [15:0] _rf_wd;
    wire [15:0] _rf_rd_data;
    wire [15:0] _rf_rs_data;

    // hazard unit wires + control signals 
    wire _stall_if;
    wire _stall_id;
    wire _stall_ex;
    wire _bubble_ex;
    wire _flush_ifid;
    wire _flush_idex;
    wire _accept_irq;

    wire _branch_take_commit;
    wire _id_fire;
    wire _iret_event;

    // ID/EX pipe register
    wire _idex_valid;
    wire [15:0] _idex_pc;
    wire [3:0] _idex_rd;
    wire [3:0] _idex_rs;
    wire [3:0] _idex_imm;
    wire [11:0] _idex_i12;
    wire [15:0] _idex_rd_data;
    wire [15:0] _idex_rs_data;
    wire [15:0] _idex_imm16;
    wire _idex_is_imm;
    wire _idex_is_bx;
    wire _idex_is_cli;
    wire _idex_is_sti;
    wire _idex_is_iret;
    wire _idex_irq_interlock;
    wire _idex_rf_we;
    wire _idex_lw;
    wire _idex_lb;
    wire _idex_sw;
    wire _idex_sb;
    wire _idex_is_jal;
    wire _idex_is_addi;
    wire _idex_is_rr;
    wire _idex_is_ri;
    wire _idex_is_alu;
    wire _idex_is_sub;
    wire _idex_is_xor;
    wire _idex_is_adc;
    wire _idex_is_sbc;
    wire _idex_is_cmp;
    wire _idex_is_sra;
    wire _idex_is_sum;
    wire _idex_is_log;
    wire _idex_is_sr;
    wire _idex_is_getcc;
    wire _idex_restore_cc;
    wire _idex_reads_rd;
    wire _idex_reads_rs;
    wire _idex_writes_rd;
    wire _idex_is_load;
    wire _idex_is_store;
    wire _idex_uses_cc;
    wire _idex_uses_carry;
    wire _idex_updates_cc;

    // EX stage wires
    wire _ex_valid;
    wire [15:0] _ex_pc;
    wire [3:0] _ex_rd;
    wire _ex_rf_we;
    wire _ex_lw;
    wire _ex_lb;
    wire _ex_sw;
    wire _ex_sb;
    wire [15:0] _ex_d_ad;
    wire [15:0] _ex_store_data;
    wire [15:0] _ex_wb_pre_data;
    wire _ex_flag_we;
    wire _ex_new_ccz;
    wire _ex_new_ccn;
    wire _ex_new_ccc;
    wire _ex_new_ccv;
    wire _ex_carry_we;
    wire _ex_new_c;
    wire _ex_updates_cc_hz;
    wire _ex_updates_carry_hz;
    wire _ex_is_load;
    wire _ex_is_iret;

    // EX/MEM pipe register wires
    wire _exmem_valid;
    wire [15:0] _exmem_pc;
    wire [3:0] _exmem_rd;
    wire _exmem_rf_we;
    wire _exmem_lw;
    wire _exmem_lb;
    wire _exmem_sw;
    wire _exmem_sb;
    wire [15:0] _exmem_d_ad;
    wire [15:0] _exmem_store_data;
    wire [15:0] _exmem_wb_pre_data;
    wire _exmem_flag_we;
    wire _exmem_new_ccz;
    wire _exmem_new_ccn;
    wire _exmem_new_ccc;
    wire _exmem_new_ccv;
    wire _exmem_carry_we;
    wire _exmem_new_c;
    wire _exmem_updates_cc_hz;
    wire _exmem_updates_carry_hz;
    wire _exmem_is_load;
    wire _exmem_is_iret;

    // MEM stage wires
    wire _mem_wait;
    wire _mem_complete;
    wire _mem_sw;
    wire _mem_sb;
    wire _mem_lw;
    wire _mem_lb;
    wire [15:0] _mem_d_ad;
    wire [15:0] _mem_data_out;
    wire _mem_valid;
    wire [3:0] _mem_rd;
    wire _mem_rf_we;
    wire [15:0] _mem_wb_data;
    wire _mem_flag_we;
    wire _mem_new_ccz;
    wire _mem_new_ccn;
    wire _mem_new_ccc;
    wire _mem_new_ccv;
    wire _mem_carry_we;
    wire _mem_new_c;
    wire _mem_updates_cc_hz;
    wire _mem_updates_carry_hz;
    wire _mem_is_iret;

    // MEM/WB pipe register wires 
    wire _memwb_valid;
    wire [3:0] _memwb_rd;
    wire _memwb_rf_we;
    wire [15:0] _memwb_wb_data;
    wire _memwb_flag_we;
    wire _memwb_new_ccz;
    wire _memwb_new_ccn;
    wire _memwb_new_ccc;
    wire _memwb_new_ccv;
    wire _memwb_carry_we;
    wire _memwb_new_c;
    wire _memwb_updates_cc_hz;
    wire _memwb_updates_carry_hz;
    wire _memwb_is_iret;

    // WB stage wires
    wire _wb_rf_we;
    wire [3:0] _wb_wa;
    wire [15:0] _wb_wd;
    wire _wb_flag_we;
    wire _wb_new_ccz;
    wire _wb_new_ccn;
    wire _wb_new_ccc;
    wire _wb_new_ccv;
    wire _wb_carry_we;
    wire _wb_new_c;
    wire _wb_updates_cc_hz;
    wire _wb_updates_carry_hz;
    wire _wb_iret_event;

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

/*************************************************************************************
 * 2.1 Static Assignments
 ************************************************************************************/
    assign _id_fire = _ifid_valid & ~_stall_id & ~_accept_irq;
    assign _branch_take_commit = _id_branch_take & _id_fire;
    assign _irq_take_oneshot = i_irq_take & ~_irq_req_latched;
    assign _iret_event = _id_fire & _id_is_iret;

    assign o_insn_ce = i_rst | _if_insn_ce;
    assign o_i_ad = _pc;
    assign o_d_ad = _mem_d_ad;
    assign o_sw = _mem_sw;
    assign o_sb = _mem_sb;
    assign o_lw = _mem_lw;
    assign o_lb = _mem_lb;
    assign o_data_out = _mem_data_out;
    assign o_br_taken = _branch_take_commit;
    assign o_in_irq = _in_irq;
    assign o_iret_detected = _iret_event;
    assign o_int_en = i_hit & _gie & ~(_id_valid & _id_irq_interlock);

    assign _rf_we = _accept_irq | _wb_rf_we;
    assign _rf_wa = _accept_irq ? 4'hE : _wb_wa;
    assign _rf_wd = _accept_irq ? (_pc - 16'h0002) : _wb_wd;

/*************************************************************************************
 * 2.2 IF Stage + IF/ID Register
 ************************************************************************************/
    if_stage u_if_stage (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_hit(i_hit),
        .i_stall(_stall_if),
        .i_flush(_branch_take_commit | _accept_irq),
        .i_flush_pc(_pc_next),
        .i_pc(_pc),
        .i_insn(i_insn),
        .o_insn_ce(_if_insn_ce),
        .o_valid(_if_valid),
        .o_pc(_if_pc),
        .o_insn(_if_insn)
    );

    pipe_if_id u_pipe_if_id (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_stall(_stall_id),
        .i_flush(_flush_ifid),
        .i_valid(_if_valid),
        .i_pc(_if_pc),
        .i_insn(_if_insn),
        .o_valid(_ifid_valid),
        .o_pc(_ifid_pc),
        .o_insn(_ifid_insn)
    );

/*************************************************************************************
 * 2.3 Regfile + ID Stage
 ************************************************************************************/
    regfile16x16 u_regfile (
        .i_clk(i_clk),
        .i_we(_rf_we),
        .i_wa(_rf_wa),
        .i_ra(_rf_ra),
        .i_rb(_rf_rb),
        .i_wd(_rf_wd),
        .o_ra(_rf_rd_data),
        .o_rb(_rf_rs_data)
    );

    id_stage u_id_stage (
        .i_valid(_ifid_valid),
        .i_pc(_ifid_pc),
        .i_insn(_ifid_insn),
        .i_rd_data(_rf_rd_data),
        .i_rs_data(_rf_rs_data),
        .i_imm_pre_state(_imm_pre_state),
        .i_i12_pre_state(_i12_pre_state),
        .i_ccz(_ccz),
        .i_ccn(_ccn),
        .i_ccc(_ccc),
        .i_ccv(_ccv),
        .o_valid(_id_valid),
        .o_exec_valid(_id_exec_valid),
        .o_pc(_id_pc),
        .o_rd(_id_rd),
        .o_rs(_id_rs),
        .o_imm(_id_imm),
        .o_i12(_id_i12),
        .o_rd_data(_id_rd_data),
        .o_rs_data(_id_rs_data),
        .o_imm16(_id_imm16),
        .o_branch_target(_id_branch_target),
        .o_branch_take(_id_branch_take),
        .o_is_imm(_id_is_imm),
        .o_is_bx(_id_is_bx),
        .o_is_cli(_id_is_cli),
        .o_is_sti(_id_is_sti),
        .o_is_iret(_id_is_iret),
        .o_irq_interlock(_id_irq_interlock),
        .o_rf_we(_id_rf_we),
        .o_lw(_id_lw),
        .o_lb(_id_lb),
        .o_sw(_id_sw),
        .o_sb(_id_sb),
        .o_is_jal(_id_is_jal),
        .o_is_addi(_id_is_addi),
        .o_is_rr(_id_is_rr),
        .o_is_ri(_id_is_ri),
        .o_is_alu(_id_is_alu),
        .o_is_sub(_id_is_sub),
        .o_is_xor(_id_is_xor),
        .o_is_adc(_id_is_adc),
        .o_is_sbc(_id_is_sbc),
        .o_is_cmp(_id_is_cmp),
        .o_is_sra(_id_is_sra),
        .o_is_sum(_id_is_sum),
        .o_is_log(_id_is_log),
        .o_is_sr(_id_is_sr),
        .o_is_getcc(_id_is_getcc),
        .o_restore_cc(_id_restore_cc),
        .o_reads_rd(_id_reads_rd),
        .o_reads_rs(_id_reads_rs),
        .o_writes_rd(_id_writes_rd),
        .o_is_load(_id_is_load),
        .o_is_store(_id_is_store),
        .o_uses_cc(_id_uses_cc),
        .o_uses_carry(_id_uses_carry),
        .o_updates_cc(_id_updates_cc)
    );

    assign _rf_ra = _id_rd;
    assign _rf_rb = _id_rs;

/*************************************************************************************
 * 2.4 Hazard Unit
 ************************************************************************************/
    hazard_unit u_hazard_unit (
        .i_id_valid(_id_valid),
        .i_id_rd(_id_rd),
        .i_id_rs(_id_rs),
        .i_id_reads_rd(_id_reads_rd),
        .i_id_reads_rs(_id_reads_rs),
        .i_id_uses_cc(_id_uses_cc),
        .i_id_uses_carry(_id_uses_carry),
        .i_branch_take(_branch_take_commit),
        .i_mem_wait(_mem_wait),
        .i_irq_take(_irq_take_oneshot),
        .i_idex_valid(_idex_valid),
        .i_idex_rf_we(_idex_rf_we),
        .i_idex_rd(_idex_rd),
        .i_idex_is_load(_idex_is_load),
        .i_idex_updates_cc(_idex_updates_cc),
        .i_idex_updates_carry(_idex_valid),
        .i_exmem_valid(_exmem_valid),
        .i_exmem_rf_we(_exmem_rf_we),
        .i_exmem_rd(_exmem_rd),
        .i_exmem_updates_cc(_exmem_updates_cc_hz),
        .i_exmem_updates_carry(_exmem_updates_carry_hz),
        .i_memwb_valid(_memwb_valid),
        .i_memwb_rf_we(_memwb_rf_we),
        .i_memwb_rd(_memwb_rd),
        .i_memwb_updates_cc(_memwb_updates_cc_hz),
        .i_memwb_updates_carry(_memwb_updates_carry_hz),
        .o_stall_if(_stall_if),
        .o_stall_id(_stall_id),
        .o_stall_ex(_stall_ex),
        .o_bubble_ex(_bubble_ex),
        .o_flush_ifid(_flush_ifid),
        .o_flush_idex(_flush_idex),
        .o_accept_irq(_accept_irq)
    );

/*************************************************************************************
 * 2.5 ID/EX Register + EX Stage
 ************************************************************************************/
    pipe_id_ex u_pipe_id_ex (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_stall(_stall_ex),
        .i_bubble(_bubble_ex),
        .i_flush(_flush_idex),
        .i_valid(_id_exec_valid & _id_fire),
        .i_pc(_id_pc),
        .i_rd(_id_rd),
        .i_rs(_id_rs),
        .i_imm(_id_imm),
        .i_i12(_id_i12),
        .i_rd_data(_id_rd_data),
        .i_rs_data(_id_rs_data),
        .i_imm16(_id_imm16),
        .i_is_imm(_id_is_imm),
        .i_is_bx(_id_is_bx),
        .i_is_cli(_id_is_cli),
        .i_is_sti(_id_is_sti),
        .i_is_iret(_id_is_iret),
        .i_irq_interlock(_id_irq_interlock),
        .i_rf_we(_id_rf_we),
        .i_lw(_id_lw),
        .i_lb(_id_lb),
        .i_sw(_id_sw),
        .i_sb(_id_sb),
        .i_is_jal(_id_is_jal),
        .i_is_addi(_id_is_addi),
        .i_is_rr(_id_is_rr),
        .i_is_ri(_id_is_ri),
        .i_is_alu(_id_is_alu),
        .i_is_sub(_id_is_sub),
        .i_is_xor(_id_is_xor),
        .i_is_adc(_id_is_adc),
        .i_is_sbc(_id_is_sbc),
        .i_is_cmp(_id_is_cmp),
        .i_is_sra(_id_is_sra),
        .i_is_sum(_id_is_sum),
        .i_is_log(_id_is_log),
        .i_is_sr(_id_is_sr),
        .i_is_getcc(_id_is_getcc),
        .i_restore_cc(_id_restore_cc),
        .i_reads_rd(_id_reads_rd),
        .i_reads_rs(_id_reads_rs),
        .i_writes_rd(_id_writes_rd),
        .i_is_load(_id_is_load),
        .i_is_store(_id_is_store),
        .i_uses_cc(_id_uses_cc),
        .i_uses_carry(_id_uses_carry),
        .i_updates_cc(_id_updates_cc),
        .o_valid(_idex_valid),
        .o_pc(_idex_pc),
        .o_rd(_idex_rd),
        .o_rs(_idex_rs),
        .o_imm(_idex_imm),
        .o_i12(_idex_i12),
        .o_rd_data(_idex_rd_data),
        .o_rs_data(_idex_rs_data),
        .o_imm16(_idex_imm16),
        .o_is_imm(_idex_is_imm),
        .o_is_bx(_idex_is_bx),
        .o_is_cli(_idex_is_cli),
        .o_is_sti(_idex_is_sti),
        .o_is_iret(_idex_is_iret),
        .o_irq_interlock(_idex_irq_interlock),
        .o_rf_we(_idex_rf_we),
        .o_lw(_idex_lw),
        .o_lb(_idex_lb),
        .o_sw(_idex_sw),
        .o_sb(_idex_sb),
        .o_is_jal(_idex_is_jal),
        .o_is_addi(_idex_is_addi),
        .o_is_rr(_idex_is_rr),
        .o_is_ri(_idex_is_ri),
        .o_is_alu(_idex_is_alu),
        .o_is_sub(_idex_is_sub),
        .o_is_xor(_idex_is_xor),
        .o_is_adc(_idex_is_adc),
        .o_is_sbc(_idex_is_sbc),
        .o_is_cmp(_idex_is_cmp),
        .o_is_sra(_idex_is_sra),
        .o_is_sum(_idex_is_sum),
        .o_is_log(_idex_is_log),
        .o_is_sr(_idex_is_sr),
        .o_is_getcc(_idex_is_getcc),
        .o_restore_cc(_idex_restore_cc),
        .o_reads_rd(_idex_reads_rd),
        .o_reads_rs(_idex_reads_rs),
        .o_writes_rd(_idex_writes_rd),
        .o_is_load(_idex_is_load),
        .o_is_store(_idex_is_store),
        .o_uses_cc(_idex_uses_cc),
        .o_uses_carry(_idex_uses_carry),
        .o_updates_cc(_idex_updates_cc)
    );

    ex_stage u_ex_stage (
        .i_valid(_idex_valid),
        .i_pc(_idex_pc),
        .i_rd(_idex_rd),
        .i_rd_data(_idex_rd_data),
        .i_rs_data(_idex_rs_data),
        .i_imm16(_idex_imm16),
        .i_rf_we(_idex_rf_we),
        .i_lw(_idex_lw),
        .i_lb(_idex_lb),
        .i_sw(_idex_sw),
        .i_sb(_idex_sb),
        .i_is_jal(_idex_is_jal),
        .i_is_addi(_idex_is_addi),
        .i_is_rr(_idex_is_rr),
        .i_is_ri(_idex_is_ri),
        .i_is_alu(_idex_is_alu),
        .i_is_sub(_idex_is_sub),
        .i_is_xor(_idex_is_xor),
        .i_is_adc(_idex_is_adc),
        .i_is_sbc(_idex_is_sbc),
        .i_is_cmp(_idex_is_cmp),
        .i_is_sra(_idex_is_sra),
        .i_is_sum(_idex_is_sum),
        .i_is_log(_idex_is_log),
        .i_is_sr(_idex_is_sr),
        .i_is_getcc(_idex_is_getcc),
        .i_restore_cc(_idex_restore_cc),
        .i_is_iret(_idex_is_iret),
        .i_c(_c),
        .i_ccz(_ccz),
        .i_ccn(_ccn),
        .i_ccc(_ccc),
        .i_ccv(_ccv),
        .o_valid(_ex_valid),
        .o_pc(_ex_pc),
        .o_rd(_ex_rd),
        .o_rf_we(_ex_rf_we),
        .o_lw(_ex_lw),
        .o_lb(_ex_lb),
        .o_sw(_ex_sw),
        .o_sb(_ex_sb),
        .o_d_ad(_ex_d_ad),
        .o_store_data(_ex_store_data),
        .o_wb_pre_data(_ex_wb_pre_data),
        .o_flag_we(_ex_flag_we),
        .o_new_ccz(_ex_new_ccz),
        .o_new_ccn(_ex_new_ccn),
        .o_new_ccc(_ex_new_ccc),
        .o_new_ccv(_ex_new_ccv),
        .o_carry_we(_ex_carry_we),
        .o_new_c(_ex_new_c),
        .o_updates_cc_hz(_ex_updates_cc_hz),
        .o_updates_carry_hz(_ex_updates_carry_hz),
        .o_is_load(_ex_is_load),
        .o_is_iret(_ex_is_iret)
    );

/*************************************************************************************
 * 2.6 EX/MEM Register + MEM Stage
 ************************************************************************************/
    pipe_ex_mem u_pipe_ex_mem (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_stall(_stall_ex),
        .i_flush(_accept_irq),
        .i_valid(_ex_valid),
        .i_pc(_ex_pc),
        .i_rd(_ex_rd),
        .i_rf_we(_ex_rf_we),
        .i_lw(_ex_lw),
        .i_lb(_ex_lb),
        .i_sw(_ex_sw),
        .i_sb(_ex_sb),
        .i_d_ad(_ex_d_ad),
        .i_store_data(_ex_store_data),
        .i_wb_pre_data(_ex_wb_pre_data),
        .i_flag_we(_ex_flag_we),
        .i_new_ccz(_ex_new_ccz),
        .i_new_ccn(_ex_new_ccn),
        .i_new_ccc(_ex_new_ccc),
        .i_new_ccv(_ex_new_ccv),
        .i_carry_we(_ex_carry_we),
        .i_new_c(_ex_new_c),
        .i_updates_cc_hz(_ex_updates_cc_hz),
        .i_updates_carry_hz(_ex_updates_carry_hz),
        .i_is_load(_ex_is_load),
        .i_is_iret(_ex_is_iret),
        .o_valid(_exmem_valid),
        .o_pc(_exmem_pc),
        .o_rd(_exmem_rd),
        .o_rf_we(_exmem_rf_we),
        .o_lw(_exmem_lw),
        .o_lb(_exmem_lb),
        .o_sw(_exmem_sw),
        .o_sb(_exmem_sb),
        .o_d_ad(_exmem_d_ad),
        .o_store_data(_exmem_store_data),
        .o_wb_pre_data(_exmem_wb_pre_data),
        .o_flag_we(_exmem_flag_we),
        .o_new_ccz(_exmem_new_ccz),
        .o_new_ccn(_exmem_new_ccn),
        .o_new_ccc(_exmem_new_ccc),
        .o_new_ccv(_exmem_new_ccv),
        .o_carry_we(_exmem_carry_we),
        .o_new_c(_exmem_new_c),
        .o_updates_cc_hz(_exmem_updates_cc_hz),
        .o_updates_carry_hz(_exmem_updates_carry_hz),
        .o_is_load(_exmem_is_load),
        .o_is_iret(_exmem_is_iret)
    );

    mem_stage u_mem_stage (
        .i_valid(_exmem_valid),
        .i_rd(_exmem_rd),
        .i_rf_we(_exmem_rf_we),
        .i_lw(_exmem_lw),
        .i_lb(_exmem_lb),
        .i_sw(_exmem_sw),
        .i_sb(_exmem_sb),
        .i_d_ad(_exmem_d_ad),
        .i_store_data(_exmem_store_data),
        .i_wb_pre_data(_exmem_wb_pre_data),
        .i_flag_we(_exmem_flag_we),
        .i_new_ccz(_exmem_new_ccz),
        .i_new_ccn(_exmem_new_ccn),
        .i_new_ccc(_exmem_new_ccc),
        .i_new_ccv(_exmem_new_ccv),
        .i_carry_we(_exmem_carry_we),
        .i_new_c(_exmem_new_c),
        .i_updates_cc_hz(_exmem_updates_cc_hz),
        .i_updates_carry_hz(_exmem_updates_carry_hz),
        .i_is_load(_exmem_is_load),
        .i_is_iret(_exmem_is_iret),
        .i_data_in(i_data_in),
        .i_rdy(i_rdy),
        .o_mem_wait(_mem_wait),
        .o_mem_complete(_mem_complete),
        .o_sw(_mem_sw),
        .o_sb(_mem_sb),
        .o_lw(_mem_lw),
        .o_lb(_mem_lb),
        .o_d_ad(_mem_d_ad),
        .o_data_out(_mem_data_out),
        .o_valid(_mem_valid),
        .o_rd(_mem_rd),
        .o_rf_we(_mem_rf_we),
        .o_wb_data(_mem_wb_data),
        .o_flag_we(_mem_flag_we),
        .o_new_ccz(_mem_new_ccz),
        .o_new_ccn(_mem_new_ccn),
        .o_new_ccc(_mem_new_ccc),
        .o_new_ccv(_mem_new_ccv),
        .o_carry_we(_mem_carry_we),
        .o_new_c(_mem_new_c),
        .o_updates_cc_hz(_mem_updates_cc_hz),
        .o_updates_carry_hz(_mem_updates_carry_hz),
        .o_is_iret(_mem_is_iret)
    );

/*************************************************************************************
 * 2.7 MEM/WB Register + WB Stage
 ************************************************************************************/
    pipe_mem_wb u_pipe_mem_wb (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_stall(1'b0),
        .i_flush(1'b0),
        .i_valid(_mem_valid),
        .i_rd(_mem_rd),
        .i_rf_we(_mem_rf_we),
        .i_wb_data(_mem_wb_data),
        .i_flag_we(_mem_flag_we),
        .i_new_ccz(_mem_new_ccz),
        .i_new_ccn(_mem_new_ccn),
        .i_new_ccc(_mem_new_ccc),
        .i_new_ccv(_mem_new_ccv),
        .i_carry_we(_mem_carry_we),
        .i_new_c(_mem_new_c),
        .i_updates_cc_hz(_mem_updates_cc_hz),
        .i_updates_carry_hz(_mem_updates_carry_hz),
        .i_is_iret(_mem_is_iret),
        .o_valid(_memwb_valid),
        .o_rd(_memwb_rd),
        .o_rf_we(_memwb_rf_we),
        .o_wb_data(_memwb_wb_data),
        .o_flag_we(_memwb_flag_we),
        .o_new_ccz(_memwb_new_ccz),
        .o_new_ccn(_memwb_new_ccn),
        .o_new_ccc(_memwb_new_ccc),
        .o_new_ccv(_memwb_new_ccv),
        .o_carry_we(_memwb_carry_we),
        .o_new_c(_memwb_new_c),
        .o_updates_cc_hz(_memwb_updates_cc_hz),
        .o_updates_carry_hz(_memwb_updates_carry_hz),
        .o_is_iret(_memwb_is_iret)
    );

    wb_stage u_wb_stage (
        .i_valid(_memwb_valid),
        .i_rd(_memwb_rd),
        .i_rf_we(_memwb_rf_we),
        .i_wb_data(_memwb_wb_data),
        .i_flag_we(_memwb_flag_we),
        .i_new_ccz(_memwb_new_ccz),
        .i_new_ccn(_memwb_new_ccn),
        .i_new_ccc(_memwb_new_ccc),
        .i_new_ccv(_memwb_new_ccv),
        .i_carry_we(_memwb_carry_we),
        .i_new_c(_memwb_new_c),
        .i_updates_cc_hz(_memwb_updates_cc_hz),
        .i_updates_carry_hz(_memwb_updates_carry_hz),
        .i_is_iret(_memwb_is_iret),
        .o_rf_we(_wb_rf_we),
        .o_wa(_wb_wa),
        .o_wd(_wb_wd),
        .o_flag_we(_wb_flag_we),
        .o_new_ccz(_wb_new_ccz),
        .o_new_ccn(_wb_new_ccn),
        .o_new_ccc(_wb_new_ccc),
        .o_new_ccv(_wb_new_ccv),
        .o_carry_we(_wb_carry_we),
        .o_new_c(_wb_new_c),
        .o_updates_cc_hz(_wb_updates_cc_hz),
        .o_updates_carry_hz(_wb_updates_carry_hz),
        .o_iret_event(_wb_iret_event)
    );

/*************************************************************************************
 * 2.8 PC and Global State Updates
 ************************************************************************************/
    pc_next u_pc_next (
        .i_rst(i_rst),
        .i_rst_vec(i_i_ad_rst),
        .i_pc(_pc),
        .i_hit(i_hit),
        .i_branch_take(_branch_take_commit),
        .i_branch_target(_id_branch_target),
        .i_irq_take(_accept_irq),
        .i_irq_vector(i_irq_vector),
        .o_pc_next(_pc_next)
    );

    always @(posedge i_clk) begin
        if (i_rst) begin
            _pc <= i_i_ad_rst;
        end else if (!_stall_if) begin
            _pc <= _pc_next;
        end
    end

    always @(posedge i_clk) begin
        if (i_rst) begin
            _irq_req_latched <= 1'b0;
        end else begin
            if (!i_irq_take) begin
                _irq_req_latched <= 1'b0;
            end else if (_accept_irq) begin
                _irq_req_latched <= 1'b1;
            end
        end
    end

    always @(posedge i_clk) begin
        if (i_rst) begin
            _imm_pre_state <= 1'b0;
            _i12_pre_state <= 12'h000;
            _gie <= 1'b1;
        end else begin
            if (_accept_irq) begin
                _imm_pre_state <= 1'b0;
            end

            if (_accept_irq) begin
                _gie <= 1'b0;
            end else if (_id_fire && _id_is_cli) begin
                _gie <= 1'b0;
            end else if (_id_fire && _id_is_sti) begin
                _gie <= 1'b1;
            end

            if (_id_fire) begin
                _imm_pre_state <= _id_is_imm;
                if (_id_is_imm) begin
                    _i12_pre_state <= _id_i12;
                end
            end
        end
    end

    always @(posedge i_clk) begin
        if (i_rst) begin
            _c <= 1'b0;
            _ccz <= 1'b0;
            _ccn <= 1'b0;
            _ccc <= 1'b0;
            _ccv <= 1'b0;
        end else begin
            if (_wb_flag_we) begin
                _ccz <= _wb_new_ccz;
                _ccn <= _wb_new_ccn;
                _ccc <= _wb_new_ccc;
                _ccv <= _wb_new_ccv;
            end
            if (_wb_carry_we) begin
                _c <= _wb_new_c;
            end
        end
    end

/*************************************************************************************
 * 2.9 IRQ Depth Tracking
 ************************************************************************************/
    always @(*) begin
        _irq_depth_n = _irq_depth;
        case ({_accept_irq, _iret_event})
            2'b10: begin
                if (_irq_depth != 2'b11) begin
                    _irq_depth_n = _irq_depth + 2'd1;
                end
            end
            2'b01: begin
                if (_irq_depth != 2'b00) begin
                    _irq_depth_n = _irq_depth - 2'd1;
                end
            end
            2'b11: begin
                if (_irq_depth != 2'b11) begin
                    _irq_depth_n = _irq_depth + 2'd1;
                end
            end
            default: ;
        endcase
    end

    always @(posedge i_clk) begin
        if (i_rst) begin
            _irq_depth <= 2'b00;
            _in_irq <= 1'b0;
        end else begin
            _irq_depth <= _irq_depth_n;
            _in_irq <= (_irq_depth_n != 2'b00);
        end
    end

endmodule
