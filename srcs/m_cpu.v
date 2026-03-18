    `timescale 1ns / 1ps
    
    `include "constants.vh"
    
    // ============================================================
    // Top-level CPU module — 5-stage pipelined processor
    //
    // Pipeline stages: IF → ID → EX → MEM → WB
    //
    // External interfaces:
    //   - Instruction memory: provides i_insn when i_hit is asserted;
    //     CE (chip-enable) is driven by o_insn_ce, address by o_i_ad.
    //   - Data memory: word/byte load/store via o_d_ad, o_lw/o_lb/o_sw/o_sb,
    //     o_data_out; result returned on i_data_in when i_rdy is asserted.
    //   - Interrupt controller: takes interrupt on i_irq_take + i_irq_vector;
    //     CPU signals acceptance state via o_in_irq / o_int_en / o_iret_detected.
    // ============================================================
    module cpu(
        input wire i_clk,
        input wire i_rst,
        input wire [15:0] i_i_ad_rst,    // Reset vector: initial PC value on reset
        output wire o_insn_ce,            // Instruction memory chip-enable
        output wire [15:0] o_i_ad,        // Instruction memory address (= current PC)
        input wire [15:0] i_insn,         // Fetched instruction word from instruction memory
        input wire i_hit,                 // Instruction memory hit: insn is valid this cycle
        output wire [15:0] o_d_ad,        // Data memory address (computed by EX stage)
        input wire i_rdy,                 // Data memory ready: load/store has completed
        output wire o_sw,                 // Data memory: store word strobe
        output wire o_sb,                 // Data memory: store byte strobe
        output wire o_lw,                 // Data memory: load word strobe
        output wire o_lb,                 // Data memory: load byte strobe
        output wire [15:0] o_data_out,    // Data to write to data memory (store path)
        input wire [15:0] i_data_in,      // Data read from data memory (load path)
        input wire i_irq_take,            // External interrupt request line (level)
        input wire [15:0] i_irq_vector,   // Interrupt handler entry-point address
        output wire o_in_irq,             // CPU is currently servicing an interrupt
        output wire o_int_en,             // Interrupts are currently enabled (GIE + no interlock)
        output wire o_iret_detected,      // IRET instruction has fired in the ID stage
        output wire o_br_taken            // A branch/jump was committed this cycle
    );
    
    /*************************************************************************************
     * SECTION 1. DECLARE WIRES / REGS
     ************************************************************************************/
        
        // ---- Global / committed architectural state ----
        reg [15:0] _pc;             // Program counter (registered; advances each non-stall cycle)
        wire [15:0] _pc_next;       // Combinational next-PC from pc_next unit
    
        // IMM pre-state: tracks whether the previous instruction was an IMM prefix,
        // which provides the upper 12 bits of a 16-bit immediate for the following insn.
        reg _imm_pre_state;         // 1 if previous fired instruction was IMM
        reg [11:0] _i12_pre_state;  // Saved upper 12-bit payload of the IMM prefix
    
        reg _gie;                   // Global Interrupt Enable flag (1 = interrupts enabled)
    
        // Condition codes (Z, N, C-flag alias, C, V) — committed at WB
        reg _c;     // Carry bit used by ADC/SBC (separate from _ccc for historical reasons)
        reg _ccz;   // Zero flag
        reg _ccn;   // Negative flag
        reg _ccc;   // Carry flag (for BX conditions)
        reg _ccv;   // Overflow flag
    
        // Interrupt nesting depth counter (saturating 2-bit, max depth = 3)
        reg [1:0] _irq_depth;      // Current nesting level
        reg [1:0] _irq_depth_n;    // Combinational next value
        reg _in_irq;               // 1 when inside at least one interrupt handler
        reg _irq_req_latched;      // Edge-detect latch: prevents re-accepting the same IRQ level
        wire _irq_take_oneshot;    // Single-cycle pulse: rising edge of i_irq_take
    
        // ---- IF stage outputs ----
        wire _if_insn_ce;           // Instruction-memory CE from IF stage
        wire _if_valid;             // IF stage has a valid instruction this cycle
        wire [15:0] _if_pc;         // PC associated with the instruction at the IF output
        wire [15:0] _if_insn;       // Instruction word at the IF output
    
        // ---- IF/ID pipeline register outputs ----
        wire _ifid_valid;
        wire [15:0] _ifid_pc;
        wire [15:0] _ifid_insn;
    
        // ---- ID stage outputs ----
        wire _id_valid;             // Instruction in ID is valid
        wire _id_exec_valid;        // Instruction should be dispatched to EX (not IMM/CLI/STI/BX pseudo-ops)
        wire [15:0] _id_pc;
        wire [3:0] _id_rd;          // Destination register field
        wire [3:0] _id_rs;          // Source register field
        wire [3:0] _id_imm;         // 4-bit immediate field
        wire [11:0] _id_i12;        // 12-bit immediate field (used by IMM prefix)
        wire [15:0] _id_rd_data;    // Register-file read data for Rd
        wire [15:0] _id_rs_data;    // Register-file read data for Rs
        wire [15:0] _id_imm16;      // Sign/zero-extended 16-bit immediate (after IMM prefix merging)
        wire [15:0] _id_branch_target; // Resolved branch target address
        wire _id_branch_take;       // Branch is being taken (combinational, before commit gate)
        wire _id_is_imm;            // This instruction is an IMM prefix
        wire _id_is_bx;             // This instruction is a conditional branch (BX)
        wire _id_is_cli;            // This instruction is CLI (clear interrupt enable)
        wire _id_is_sti;            // This instruction is STI (set interrupt enable)
        wire _id_is_iret;           // This instruction is IRET
        wire _id_irq_interlock;     // This instruction prevents IRQ acceptance (IMM/ADC/SBC/CMP)
        wire _id_rf_we;             // ID-stage register-file write-enable intent
        wire _id_lw;                // Load word
        wire _id_lb;                // Load byte
        wire _id_sw;                // Store word
        wire _id_sb;                // Store byte
        wire _id_is_jal;            // Jump-and-link
        wire _id_is_addi;           // Add-immediate
        wire _id_is_rr;             // Register-register ALU
        wire _id_is_ri;             // Register-immediate ALU
        wire _id_is_alu;            // Any ALU operation (_is_rr | _is_ri)
        wire _id_is_sub;
        wire _id_is_xor;
        wire _id_is_adc;            // Add-with-carry
        wire _id_is_sbc;            // Subtract-with-carry
        wire _id_is_cmp;            // Compare (like SUB but no writeback)
        wire _id_is_sra;            // Shift-right arithmetic
        wire _id_is_sum;            // Arithmetic sub-group: ADD/SUB/ADC/SBC
        wire _id_is_log;            // Logical sub-group: AND/XOR
        wire _id_is_sr;             // Shift sub-group: SRL/SRA
        wire _id_is_getcc;          // GETCC system instruction (reads PSW into register)
        wire _id_restore_cc;        // SETCC system instruction (restores PSW from register)
        wire _id_reads_rd;          // Instruction reads Rd as source (for hazard detection)
        wire _id_reads_rs;          // Instruction reads Rs as source
        wire _id_writes_rd;         // Instruction writes Rd (for hazard detection)
        wire _id_is_load;
        wire _id_is_store;
        wire _id_uses_cc;           // Instruction uses condition codes (e.g. BX)
        wire _id_uses_carry;        // Instruction uses carry bit (ADC/SBC)
        wire _id_updates_cc;        // Instruction will update condition codes
    
        // ---- Register file wires ----
        wire _rf_we;                // Register-file write-enable (from WB or IRQ accept)
        wire [3:0] _rf_wa;          // Write address
        wire [3:0] _rf_ra;          // Read port A address (Rd)
        wire [3:0] _rf_rb;          // Read port B address (Rs)
        wire [15:0] _rf_wd;         // Write data
        wire [15:0] _rf_rd_data;    // Read data for Rd
        wire [15:0] _rf_rs_data;    // Read data for Rs
    
        // ---- Hazard unit outputs ----
        wire _stall_if;             // Stall the IF stage (freeze PC)
        wire _stall_id;             // Stall the ID stage (freeze IF/ID register)
        wire _stall_ex;             // Stall the EX stage (freeze ID/EX and EX/MEM registers)
        wire _bubble_ex;            // Inject a NOP bubble into ID/EX (decode hazard without MEM wait)
        wire _flush_ifid;           // Flush IF/ID register (on branch taken or IRQ accept)
        wire _flush_idex;           // Flush ID/EX register (on IRQ accept)
        wire _accept_irq;           // Handshake: CPU accepts the pending interrupt this cycle
    
        wire _branch_take_commit;   // Branch is committed: valid & fired & taken
        wire _id_fire;              // ID stage "fires": instruction advances to EX this cycle
        wire _iret_event;           // IRET fires in ID this cycle
        
        
        // Data Forwarding Outputs
        
        wire [1:0] _forward_a;
        wire [1:0] _forward_b;
               
       
    
        // ---- ID/EX pipeline register outputs ----
        // (Mirror of ID-stage signals, registered into EX)
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
    
        // ---- EX stage outputs ----
        wire _ex_valid;
        wire [15:0] _ex_pc;
        wire [3:0] _ex_rd;
        wire _ex_rf_we;
        wire _ex_lw;
        wire _ex_lb;
        wire _ex_sw;
        wire _ex_sb;
        wire [15:0] _ex_d_ad;          // Computed data-memory address
        wire [15:0] _ex_store_data;    // Data to be written (store path = Rd contents)
        wire [15:0] _ex_wb_pre_data;   // ALU result to be written back (non-load path)
        wire _ex_flag_we;              // EX wants to update condition codes
        wire _ex_new_ccz;
        wire _ex_new_ccn;
        wire _ex_new_ccc;
        wire _ex_new_ccv;
        wire _ex_carry_we;             // EX wants to update carry bit
        wire _ex_new_c;
        wire _ex_updates_cc_hz;        // Hazard metadata: this instruction updates CCs
        wire _ex_updates_carry_hz;     // Hazard metadata: this instruction updates carry
        wire _ex_is_load;
        wire _ex_is_iret;
    
        // ---- EX/MEM pipeline register outputs ----
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
    
        // ---- MEM stage outputs ----
        wire _mem_wait;             // MEM is waiting on data memory (stalls pipeline)
        wire _mem_complete;         // MEM operation has completed (or no memory op)
        wire _mem_sw;
        wire _mem_sb;
        wire _mem_lw;
        wire _mem_lb;
        wire [15:0] _mem_d_ad;
        wire [15:0] _mem_data_out;  // Store data driven onto the external bus
        wire _mem_valid;            // Instruction has completed MEM and is ready for WB
        wire [3:0] _mem_rd;
        wire _mem_rf_we;
        wire [15:0] _mem_wb_data;   // Final writeback value (load result or ALU result)
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
    
        // ---- MEM/WB pipeline register outputs ----
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
    
        // ---- WB stage outputs ----
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
    
        // _id_fire: the ID stage commits an instruction this cycle.
        // Requires a valid instruction in IF/ID, no stall, and no concurrent IRQ accept.
        assign _id_fire = _ifid_valid & ~_stall_id & ~_accept_irq;
    
        // _branch_take_commit: a branch/jump is actually committed (taken and fired).
        assign _branch_take_commit = _id_branch_take & _id_fire;
    
        // One-shot IRQ edge detector: asserted only on the first cycle i_irq_take goes high,
        // preventing repeated accepts if the line stays asserted.
        assign _irq_take_oneshot = i_irq_take & ~_irq_req_latched;
    
        // IRET fires the cycle a valid IRET instruction commits in ID.
        assign _iret_event = _id_fire & _id_is_iret;
    
        // Drive instruction-memory chip-enable; also asserted during reset to pre-fetch.
        assign o_insn_ce = i_rst | _if_insn_ce;
        assign o_i_ad = _pc;                    // Instruction fetch address = current PC
    
        // Data memory interface — driven from the MEM stage
        assign o_d_ad = _mem_d_ad;
        assign o_sw   = _mem_sw;
        assign o_sb   = _mem_sb;
        assign o_lw   = _mem_lw;
        assign o_lb   = _mem_lb;
        assign o_data_out = _mem_data_out;
    
        // Status outputs to the interrupt controller
        assign o_br_taken       = _branch_take_commit;
        assign o_in_irq         = _in_irq;
        assign o_iret_detected  = _iret_event;
        // Interrupts are globally enabled only when: instruction memory has a hit,
        // GIE is set, and no IRQ-interlocked instruction is in ID.
        assign o_int_en = i_hit & _gie & ~(_id_valid & _id_irq_interlock);
    
        // Register-file write port arbitration:
        // On IRQ accept, override WB to save PC-2 (the instruction that was about to execute)
        // into register R14 (the link register / return address).
        assign _rf_we = _accept_irq | _wb_rf_we;
        assign _rf_wa = _accept_irq ? 4'hE          : _wb_wa;
        assign _rf_wd = _accept_irq ? (_pc - 16'h0002) : _wb_wd;
    
    /*************************************************************************************
     * 2.2 IF Stage + IF/ID Register
     ************************************************************************************/
        if_stage u_if_stage (
            .i_clk(i_clk),
            .i_rst(i_rst),
            .i_hit(i_hit),                                     
            .i_stall(_stall_if),                                // Stall: hold current state
            .i_flush(_branch_take_commit | _accept_irq),        // Flush on branch commit or IRQ
            .i_flush_pc(_pc_next),                              // Target PC to redirect to
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
            .i_stall(_stall_id),      // Stall: freeze IF/ID contents
            .i_flush(_flush_ifid),    // Flush: inject NOP bubble
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
    
        // 16-entry × 16-bit synchronous register file with two async read ports.
        // R0 is not architecturally hardwired to zero here — hazard unit excludes it
        // from load-use checks (see hazard_unit).
        regfile16x16 u_regfile (
            .i_clk(i_clk),
            .i_we(_rf_we),
            .i_wa(_rf_wa),
            .i_ra(_rf_ra),          // Read port A = Rd field
            .i_rb(_rf_rb),          // Read port B = Rs field
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
            .i_imm_pre_state(_imm_pre_state),    // IMM prefix pre-state from prior cycle
            .i_i12_pre_state(_i12_pre_state),    // Saved upper-12 from IMM prefix
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
    
        // Register-file read addresses come from the decoded Rd/Rs fields in ID
        assign _rf_ra = _id_rd;
        assign _rf_rb = _id_rs;
    
    /*************************************************************************************
     * 2.4 Hazard Unit
     ************************************************************************************/
        hazard_unit u_hazard_unit (
            // Instruction in ID — what it reads and which registers
            .i_id_valid(_id_valid),
            .i_id_rd(_id_rd),
            .i_id_rs(_id_rs),
            .i_id_reads_rd(_id_reads_rd),
            .i_id_reads_rs(_id_reads_rs),
            .i_id_uses_cc(_id_uses_cc),
            .i_id_uses_carry(_id_uses_carry),
            // External events
            .i_branch_take(_branch_take_commit),
            .i_mem_wait(_mem_wait),
            .i_irq_take(_irq_take_oneshot),
            // ID/EX stage — what's pending in EX
            .i_idex_valid(_idex_valid),
            .i_idex_rf_we(_idex_rf_we),
            .i_idex_rd(_idex_rd),
            .i_idex_is_load(_idex_is_load),
            .i_idex_updates_cc(_idex_updates_cc),
            .i_idex_updates_carry(_idex_valid),     // Note: intentionally uses _idex_valid as carry proxy
            // EX/MEM stage — what's pending in MEM
            .i_exmem_valid(_exmem_valid),
            .i_exmem_rf_we(_exmem_rf_we),
            .i_exmem_rd(_exmem_rd),
            .i_exmem_updates_cc(_exmem_updates_cc_hz),
            .i_exmem_updates_carry(_exmem_updates_carry_hz),
            // MEM/WB stage — what's pending in WB
            .i_memwb_valid(_memwb_valid),
            .i_memwb_rf_we(_memwb_rf_we),
            .i_memwb_rd(_memwb_rd),
            .i_memwb_updates_cc(_memwb_updates_cc_hz),
            .i_memwb_updates_carry(_memwb_updates_carry_hz),
            // Control outputs
            .o_stall_if(_stall_if),
            .o_stall_id(_stall_id),
            .o_stall_ex(_stall_ex),
            .o_bubble_ex(_bubble_ex),
            .o_flush_ifid(_flush_ifid),
            .o_flush_idex(_flush_idex),
            .o_accept_irq(_accept_irq)
        );
        
     /*************************************************************************************
     * 2.4.1  Data Forwarding
     ************************************************************************************/
      m_forwarding u_forwarding (
        .i_rdE(_idex_rd),
        .i_rsE(_idex_rs),
        .i_WriteRegM(_exmem_rd),
        .i_RegWriteM(_exmem_rf_we),
        .i_validM(_exmem_valid),
        .i_WriteRegWB(_memwb_rd),
        .i_RegWriteWB(_memwb_rf_we),
        .i_validWB(_memwb_valid),
        .o_ForwardAE(_forward_a),
        .o_ForwardBE(_forward_b)
    );
        
    
    /*************************************************************************************
     * 2.5 ID/EX Register + EX Stage
     ************************************************************************************/
        pipe_id_ex u_pipe_id_ex (
            .i_clk(i_clk),
            .i_rst(i_rst),
            .i_stall(_stall_ex),
            .i_bubble(_bubble_ex),   // Decode hazard: insert bubble without disturbing MEM
            .i_flush(_flush_idex),   // IRQ accept: squash instruction about to enter EX
            // Only latch instruction if it is exec-valid AND the ID stage fires
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
             // for the forwarding
            .i_forward_a(_forward_a),
            .i_forward_b(_forward_b),
            .i_exmem_wb_data(_exmem_wb_pre_data),
            .i_memwb_wb_data(_memwb_wb_data),
            // Current committed condition-code and carry state (read directly from registers)
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
            .i_stall(_stall_ex),      // MEM wait: freeze EX/MEM alongside ID/EX
            .i_flush(_accept_irq),    // IRQ accept: squash instruction already past EX
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
            .i_data_in(i_data_in),    // Load result from data memory
            .i_rdy(i_rdy),            // Data memory ready
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
    
        // MEM/WB never stalls or flushes in the current implementation —
        // once MEM completes (i_rdy asserted), the instruction always retires.
        pipe_mem_wb u_pipe_mem_wb (
            .i_clk(i_clk),
            .i_rst(i_rst),
            .i_stall(1'b0),     // MEM/WB is never stalled
            .i_flush(1'b0),     // MEM/WB is never flushed
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
    
        // pc_next computes the next PC combinationally each cycle.
        // Priority: reset > IRQ vector > branch target > PC+2 (sequential)
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
    
        // PC register: advances to _pc_next unless the IF stage is stalled
        always @(posedge i_clk) begin
            if (i_rst) begin
                _pc <= i_i_ad_rst;
            end else if (!_stall_if) begin
                _pc <= _pc_next;
            end
        end
    
        // IRQ one-shot latch: once _accept_irq fires, mark the IRQ as seen
        // so that a sustained i_irq_take doesn't re-trigger on the next cycle.
        // Clears when i_irq_take de-asserts.
        always @(posedge i_clk) begin
            if (i_rst) begin
                _irq_req_latched <= 1'b0;
            end else begin
                if (!i_irq_take) begin
                    _irq_req_latched <= 1'b0;        // IRQ line dropped — reset latch
                end else if (_accept_irq) begin
                    _irq_req_latched <= 1'b1;        // Mark this IRQ as accepted
                end
            end
        end
    
        // IMM pre-state, i12 pre-state, and GIE updates
        always @(posedge i_clk) begin
            if (i_rst) begin
                _imm_pre_state <= 1'b0;
                _i12_pre_state <= 12'h000;
                _gie <= 1'b1;          // Interrupts enabled by default after reset
            end else begin
                // IRQ accept clears any in-flight IMM prefix (the IRQ vector is an absolute address)
                if (_accept_irq) begin
                    _imm_pre_state <= 1'b0;
                end
    
                // GIE update: cleared by IRQ accept or CLI instruction; set by STI
                if (_accept_irq) begin
                    _gie <= 1'b0;
                end else if (_id_fire && _id_is_cli) begin
                    _gie <= 1'b0;
                end else if (_id_fire && _id_is_sti) begin
                    _gie <= 1'b1;
                end
    
                // IMM prefix tracking: record when a fired instruction is an IMM prefix,
                // and latch its 12-bit payload for use by the immediately following instruction.
                if (_id_fire) begin
                    _imm_pre_state <= _id_is_imm;
                    if (_id_is_imm) begin
                        _i12_pre_state <= _id_i12;
                    end
                end
            end
        end
    
        // Condition codes and carry committed at WB.
        // Note: the carry bit (_c) used by ADC/SBC is separate from _ccc (the branch carry flag).
        // Both are updated here from WB outputs; EX reads the committed values directly.
        always @(posedge i_clk) begin
            if (i_rst) begin
                _c <= 1'b0;
                _ccz <= 1'b0;
                _ccn <= 1'b0;
                _ccc <= 1'b0;
                _ccv <= 1'b0;
            end else begin
                // Update condition codes (Z/N/C/V) when WB has a valid flag write
                if (_wb_flag_we) begin
                    _ccz <= _wb_new_ccz;
                    _ccn <= _wb_new_ccn;
                    _ccc <= _wb_new_ccc;
                    _ccv <= _wb_new_ccv;
                end
                // Update carry bit independently (used by ADC/SBC)
                if (_wb_carry_we) begin
                    _c <= _wb_new_c;
                end
            end
        end
    
    /*************************************************************************************
     * 2.9 IRQ Depth Tracking
     ************************************************************************************/
    
        // Combinational next-depth logic:
        // - Increment on IRQ accept (entering an ISR)
        // - Decrement on IRET fire (returning from an ISR)
        // - Both simultaneously: net +1 (returning from one ISR and immediately
        //   accepting a new one — rare but handled)
        // - Saturates at 3 (2'b11) on the high end, and 0 on the low end
        always @(*) begin
            _irq_depth_n = _irq_depth;
            case ({_accept_irq, _iret_event})
                2'b10: begin    // IRQ accepted, no IRET
                    if (_irq_depth != 2'b11) begin
                        _irq_depth_n = _irq_depth + 2'd1;
                    end
                end
                2'b01: begin    // IRET fired, no new IRQ
                    if (_irq_depth != 2'b00) begin
                        _irq_depth_n = _irq_depth - 2'd1;
                    end
                end
                2'b11: begin    // Both simultaneously — still net +1
                    if (_irq_depth != 2'b11) begin
                        _irq_depth_n = _irq_depth + 2'd1;
                    end
                end
                default: ;      // 2'b00: no change
            endcase
        end
    
        // Registered depth and _in_irq flag
        always @(posedge i_clk) begin
            if (i_rst) begin
                _irq_depth <= 2'b00;
                _in_irq <= 1'b0;
            end else begin
                _irq_depth <= _irq_depth_n;
                _in_irq <= (_irq_depth_n != 2'b00);   // True whenever nesting depth > 0
            end
        end
    
    endmodule
