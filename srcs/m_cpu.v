    `timescale 1ns / 1ps
    
    `include "constants.vh"
    
    // ============================================================
    // Top-level CPU module — 4-stage pipelined processor
    //
    // Pipeline stages: IF → ID → EX → MEM
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
        wire _c;     // Carry bit used by ADC/SBC (separate from _ccc for historical reasons)
        wire _ccz;   // Zero flag
        wire _ccn;   // Negative flag
        wire _ccc;   // Carry flag (for BX conditions)
        wire _ccv;   // Overflow flag
    
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
        wire _id_is_load;
    
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
        wire _flush_ifid;           // Flush IF/ID register (on branch taken or IRQ accept)
        wire _flush_idex;           // Flush ID/EX register (on IRQ accept)
        wire _accept_irq;           // Handshake: CPU accepts the pending interrupt this cycle
    
        wire _branch_take_commit;   // Branch is committed: valid & fired & taken
        wire _id_fire;              // ID stage "fires": instruction advances to EX this cycle
        wire _iret_event;           // IRET fires in ID this cycle
        
        
        // Data Forwarding Outputs
        
        wire _forward_a;
        wire _forward_b;
               
       
    
        // ---- ID/EX pipeline register outputs ----
        // (Mirror of ID-stage signals, registered into EX)
        wire _idex_valid;
        wire [15:0] _idex_pc;
        wire [3:0] _idex_rd;
        wire [3:0] _idex_rd_second;
        wire [3:0] _idex_rs;
        wire [15:0] _idex_rd_data;
        wire [15:0] _idex_rs_data;
        wire [15:0] _idex_imm16;
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
        wire _idex_is_load;
    
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
        wire _ex_is_load;
    
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
        wire _exmem_is_load;
    
        // ---- MEM stage outputs ----
        wire _mem_wait;             // MEM is waiting on data memory (stalls pipeline)
        wire _mem_sw;
        wire _mem_sb;
        wire _mem_lw;
        wire _mem_lb;
        wire [15:0] _mem_d_ad;
        wire [15:0] _mem_data_out;  // Store data driven onto the external bus
        wire _mem_valid;            // Instruction has completed MEM and is ready for WB
        wire [3:0] _mem_rd;
        wire _mem_rf_we;
        wire [15:0] _mem_alu_data;   // Final writeback value (load result or ALU result)

      
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
        
        //was changed to break combinational loop
        reg _iret_event_r;

        always @(posedge i_clk) begin
            if (i_rst)
                _iret_event_r <= 1'b0;
            else
                _iret_event_r <= _iret_event;
        end
        
        assign o_iret_detected = _iret_event_r;
        //assign o_iret_detected  = _iret_event;
    
        // Status outputs to the interrupt controller
        assign o_br_taken       = _branch_take_commit;
        assign o_in_irq         = _in_irq;
        // Interrupts are globally enabled only when: instruction memory has a hit,
        // GIE is set, and no IRQ-interlocked instruction is in ID.
        assign o_int_en = i_hit & _gie & ~(_id_valid & _id_irq_interlock);
    
        // Register-file write port arbitration:
        // On IRQ accept, override WB to save PC-2 (the instruction that was about to execute)
        // into register R14 (the link register / return address).
        assign _rf_we = _accept_irq | (_mem_valid & _mem_rf_we);
        assign _rf_wa = _accept_irq ? 4'hE          : _mem_rd;
        assign _rf_wd = _accept_irq ? (_pc - 16'h0002) : _mem_alu_data;
    
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
            .o_is_load(_id_is_load)
        );
    
        // Register-file read addresses come from the decoded Rd/Rs fields in ID
        assign _rf_ra = _id_rd;
        assign _rf_rb = _id_rs;
    
    /*************************************************************************************
     * 2.4 Hazard Unit
     ************************************************************************************/
        // CC-updating predicate for hazard detection: matches ex_stage's flag_we condition
        wire _idex_updates_cc;
        assign _idex_updates_cc = _idex_valid &
            (((_idex_is_rr | _idex_is_ri) & (_idex_is_sum | _idex_is_cmp)) |
              _idex_is_addi | _idex_restore_cc);

        hazard_unit u_hazard_unit (
            // Instruction in ID — what it reads and which registers
            .i_id_valid(_id_valid),
            .i_id_rd(_id_rd),
            .i_id_rs(_id_rs),
            .i_id_reads_rd(_id_reads_rd),
            .i_id_reads_rs(_id_reads_rs),
            .i_id_is_bx(_id_is_bx),
            // External events
            .i_branch_take(_branch_take_commit),
            .i_mem_wait(_mem_wait),
            .i_irq_take(_irq_take_oneshot),
            // ID/EX stage — what's pending in EX
            .i_idex_valid(_idex_valid),
            .i_idex_rd(_idex_rd_second),
            .i_idex_is_load(_idex_is_load),
            .i_idex_updates_cc(_idex_updates_cc),
            // Control outputs
            .o_stall_if(_stall_if),
            .o_stall_id(_stall_id),
            .o_stall_ex(_stall_ex),
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
            // IRQ accept: squash instruction about to enter EX or Decode hazard: insert bubble without disturbing MEM
            .i_flush(_flush_idex),   
            // Only latch instruction if it is exec-valid AND the ID stage fires
            .i_valid(_id_exec_valid & _id_fire),
            .i_pc(_id_pc),
            .i_rd(_id_rd),
            .i_rs(_id_rs),
            .i_rd_data(_id_rd_data),
            .i_rs_data(_id_rs_data),
            .i_imm16(_id_imm16),
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
            .i_is_load(_id_is_load),
            .o_valid(_idex_valid),
            .o_pc(_idex_pc),
            .o_rd(_idex_rd),
            .o_rd_second (_idex_rd_second),
            .o_rs(_idex_rs),
            .o_rd_data(_idex_rd_data),
            .o_rs_data(_idex_rs_data),
            .o_imm16(_idex_imm16),
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
            .o_is_load(_idex_is_load)
        );
    
        ex_stage u_ex_stage (
            .i_valid(_idex_valid),
            .i_pc_dbg(_idex_pc),
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
             // for the forwarding
            .i_forward_a(_forward_a),
            .i_forward_b(_forward_b),
            .i_exmem_wb_data(_exmem_wb_pre_data),
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
            .o_is_load(_ex_is_load)
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
            .i_is_load(_ex_is_load),
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
            .o_is_load(_exmem_is_load)
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
            .i_is_load(_exmem_is_load),
            .i_data_in(i_data_in),    // Load result from data memory
            .i_rdy(i_rdy),            // Data memory ready
            .i_pc_dbg(_exmem_pc),
            .o_mem_wait(_mem_wait),
            .o_sw(_mem_sw),
            .o_sb(_mem_sb),
            .o_lw(_mem_lw),
            .o_lb(_mem_lb),
            .o_d_ad(_mem_d_ad),
            .o_data_out(_mem_data_out),
            .o_valid(_mem_valid),
            .o_rd(_mem_rd),
            .o_rf_we(_mem_rf_we),
            .o_data(_mem_alu_data)
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
        
        
        /*************************************************************************************
         * 2.9 CC Register with bypass
         ************************************************************************************/
            cc_flag u_cc_flag (
                .i_clk      (i_clk),
                .i_rst      (i_rst),
                // Write port - driven by EX stage outputs
                .i_flag_we  (_ex_flag_we),
                .i_new_ccz  (_ex_new_ccz),
                .i_new_ccn  (_ex_new_ccn),
                .i_new_ccc  (_ex_new_ccc),
                .i_new_ccv  (_ex_new_ccv),
                .i_carry_we (_ex_carry_we),
                .i_new_c    (_ex_new_c),
                // Read port - with bypass, seen by ID and EX
                .o_ccz      (_ccz),
                .o_ccn      (_ccn),
                .o_ccc      (_ccc),
                .o_ccv      (_ccv),
                .o_c        (_c)
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
