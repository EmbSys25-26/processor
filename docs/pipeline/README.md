# Pipeline Documentation

_Last reviewed: 2026-04-06_

## Scope

- Source of truth is the active stage-based CPU in `srcs/m_cpu.v` and the stage/register modules it instantiates.
- Historical PDFs in this folder are useful design background, but they are not the current implementation contract.
- The active execution order is `IF -> ID -> EX -> MEM` with explicit `IF/ID`, `ID/EX`, and `EX/MEM` pipeline registers.

## Pipeline summary

| Block | Practical role in current RTL |
| --- | --- |
| IF | Presents the current PC, aligns the returned instruction with its PC, and drains two post-redirect fetch opportunities. |
| ID | Decodes the instruction, reads the register file, builds immediates, resolves BX/JAL redirects, emits hazard metadata, and decides whether the instruction enters EX. |
| EX | Applies EX/MEM forwarding, performs ALU/address work, forms store data, and produces pre-writeback and status candidates. |
| MEM | Holds memory operations until `i_rdy`, then supplies the final writeback value for EX-issued instructions. |

## Architectural effect boundaries

- `IMM`, `CLI`, `STI`, `BX`, and `IRET` take effect at the ID boundary when `_id_fire` is true.
- Instructions that enter EX complete through MEM. If they write a register, the write is sourced from MEM.
- `JAL` is split:
  - redirect target is resolved and committed in ID;
  - link value is produced later and written from MEM.

## Stage behavior

### IF stage

In the IF stage, the processor fetches the instruction associated with the current PC and keeps that instruction aligned with the PC that launched it. In a classical pipeline description, fetch should only provide the next candidate instruction and should not commit architectural state. The active design follows that model in `srcs/m_if_stage.v` by keeping a one-entry PC delay line so the outgoing `o_pc` matches the fetched instruction, and by qualifying output validity with both `i_hit` and the internal flush-bubble counter.

This stage is also where redirect draining is enforced. `i_stall` freezes the local IF state and the top-level PC register. `i_flush` loads the redirect target immediately and suppresses the next two valid fetch opportunities. If the instruction side ever stopped hitting, those two suppressed outputs would be stretched across more cycles rather than disappearing.

```verilog
assign o_valid = i_hit & (_flush_bubble == 2'd0);
assign o_insn  = (_flush_bubble == 2'd0) ? i_insn : `CPU_NOP_INSN;

always @(posedge i_clk) begin
    if (i_flush) begin
        _pc_d1 <= i_flush_pc;
        o_pc   <= i_flush_pc;
        _flush_bubble <= 2'd2;
    end else if (i_hit & ~i_stall) begin
        _pc_d1 <= i_pc;
        o_pc   <= _pc_d1;
        if (_flush_bubble != 2'd0) begin
            _flush_bubble <= _flush_bubble - 2'd1;
        end
    end
end
```

### ID stage

In the ID stage, the fetched instruction is translated into register indices, immediates, hazard metadata, and control intent. This is also where control flow is resolved in the active core, so the branch decision is made earlier than it would be in an EX-resolved pipeline. The implementation in `srcs/m_id_stage.v` combines `ctrl_unit`, `bdu`, immediate construction, and register-file read data. It also emits `o_exec_valid`, which removes `IMM`, `CLI`, `STI`, and `BX` from the EX pipeline.

This stage is where most control-side architectural effects become visible. `IMM` updates the prefix latch on `_id_fire`. `CLI` and `STI` update `_gie` on `_id_fire`. `IRET` is detected in ID and exported through `o_iret_detected`. BX and JAL control flow also resolve here. The same stage emits `o_reads_rd` and `o_reads_rs`, which the hazard unit uses for load-use detection.

```verilog
assign _imm16 = i_imm_pre_state ? {i_i12_pre_state, _imm}
                                : {_sxi11, _i_4, _imm[3:1], _i_0};

assign o_branch_take   = i_valid & (_is_jal | (_is_bx & _bdu_take));
assign o_branch_target = _is_jal ? (_imm16 + i_rs_data) : (i_pc + _sxd16);

assign o_exec_valid = i_valid & ~(_is_imm | _is_cli | _is_sti | _is_bx);
```

### EX stage

In the EX stage, the processor consumes a stable decoded bundle, chooses the correct operands, performs ALU or address-generation work, and emits the data needed by the later MEM/writeback boundary. This is also the natural place for forwarding because EX is where RAW hazards become concrete operand conflicts. `srcs/m_ex_stage.v` has one explicit forwarding source from EX/MEM. The forwarded value is `i_exmem_wb_data`, which the top-level wires to `_exmem_wb_pre_data`. That means EX can forward ALU, JAL, and GETCC-style results, but not load data.

The load case is the important exception. Load-use hazards still need a bubble because load data does not exist until MEM. `o_d_ad` is generated as `(_sum << 1)`, so address arithmetic happens in word units and the output is converted back to a byte address. Store data comes from forwarded `Rd`. The status values observed by ID are recomputed combinationally from EX outputs in `srcs/m_cpu.v`, so there is no separate clocked PSW stage in the active design.

```verilog
assign _rd_fwd = (i_forward_a == 1'b1) ? i_exmem_wb_data : i_rd_data;
assign _rs_fwd = (i_forward_b == 1'b1) ? i_exmem_wb_data : i_rs_data;

assign o_d_ad        = (_sum << 1);
assign o_store_data  = _rd_fwd;
assign o_wb_pre_data = i_is_getcc ? {11'b0, _psw_vector} : _alu_res;
```

### MEM stage

In the MEM stage, the processor presents the EX result to the external data interface, waits for completion when necessary, and produces the final value used for register-file writeback. In a four-stage pipeline like this one, MEM is also the natural place to collapse the writeback boundary. `srcs/m_mem_stage.v` turns the EX/MEM bundle into the external memory handshake, and the top-level CPU writes the register file only when `_mem_valid & _mem_rf_we` is true.

For EX-issued instructions, this is the only register-write retirement boundary. Non-memory instructions pass through MEM without waiting. Loads and stores assert the data-side strobes while valid, and `o_mem_wait` freezes IF, ID, and EX through the hazard unit until `i_rdy` is true. In `srcs/m_soc.v`, BRAM loads intentionally incur one extra ready cycle; stores do not.

```verilog
assign _is_mem_op = i_lw | i_lb | i_sw | i_sb;
assign o_mem_wait = i_valid & _is_mem_op & ~i_rdy;

assign o_valid   = i_valid & (~_is_mem_op | i_rdy);
assign o_wb_data = i_is_load ? i_data_in : i_wb_pre_data;
```

```verilog
always @(posedge i_clk) begin
    if (i_rst) begin
        _loaded <= 1'b0;
    end else if (_insn_ce) begin
        _loaded <= 1'b0;
    end else begin
        _loaded <= (_lw | _lb);
    end
end

assign _mem_rdy = ~((_lw | _lb) & ~_loaded);
```

## Interstage register behavior

| Register | Payload | Stall behavior | Flush behavior |
| --- | --- | --- | --- |
| IF/ID | `valid`, `pc`, `insn` | Frozen by `_stall_id` | Cleared on branch commit or IRQ accept |
| ID/EX | Full execute bundle | Frozen only by `_stall_ex` during `mem_wait` | Cleared on IRQ accept and on load-use bubble insertion |
| EX/MEM | Memory/writeback bundle | Frozen with ID/EX during `mem_wait` | Cleared on IRQ accept only |

### IF/ID register

The IF/ID register holds the fetch bundle stable so decode sees one instruction at a time. `srcs/m_pipe_if_id.v` captures only `valid`, `pc`, and `insn`. Reset or flush writes an invalid NOP, while stall freezes the previous contents. This is the youngest explicit pipeline latch, so it is the first structure cleared on a redirect.

```verilog
always @(posedge i_clk) begin
    if (i_rst || i_flush) begin
        o_valid <= 1'b0;
        o_pc    <= 16'h0000;
        o_insn  <= `CPU_NOP_INSN;
    end else if (!i_stall) begin
        o_valid <= i_valid;
        o_pc    <= i_pc;
        o_insn  <= i_insn;
    end
end
```

### ID/EX register

The ID/EX register snapshots the execute bundle: operands, immediate, destination, and execution/memory control bits. `srcs/m_pipe_id_ex.v` is the widest register in the design. In `srcs/m_cpu.v`, `i_valid` is driven by `_id_exec_valid & _id_fire`, so decode-only instructions never enter it.

This boundary is also where the design injects the load-use bubble. A pure load-use hazard clears ID/EX to zero while IF and ID freeze, creating a one-cycle bubble in EX without disturbing EX/MEM. During `mem_wait`, by contrast, the register is frozen rather than cleared. IRQ accept also clears it.

```verilog
pipe_id_ex u_pipe_id_ex (
    .i_stall(_stall_ex),
    .i_flush(_flush_idex),
    .i_valid(_id_exec_valid & _id_fire),
    ...
);
```

### EX/MEM register

The EX/MEM register preserves the side-effecting outputs of EX long enough for MEM and writeback to consume them. `srcs/m_pipe_ex_mem.v` captures the memory strobes, data address, store payload, pre-writeback value, destination register, and load classification.

It is frozen together with ID/EX during `mem_wait`, so the same instruction remains visible to MEM until the external transaction completes. It is flushed on IRQ accept. It is not flushed on branches, because the older EX instruction is still on the correct path when the branch resolves in ID.

```verilog
pipe_ex_mem u_pipe_ex_mem (
    .i_stall(_stall_ex),
    .i_flush(_accept_irq),
    .i_valid(_ex_valid),
    ...
);
```

## Terminology corrections

- The active core is a four-stage pipeline, not a five-stage one.
- There is no standalone WB stage in the active integration.
- There is no distinct MEM/WB forwarding path in the active integration.
- The current status path is combinational EX-to-ID feedback, not a separately clocked PSW pipeline stage.
- `JAL` is not purely an EX or MEM instruction; its redirect commits in ID while its link writeback completes later.
