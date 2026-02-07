# GR0040/GR0041 Glossary (Signals + Terms)

_Last reviewed: 2026-02-07_

### Addressing terms
- byte address: address counts bytes; word-aligned if addr[0]=0.
- word: 16-bit quantity; instruction width and default data width.
- lane select: addr[0] chooses which 8-bit lane inside a 16-bit word.
  - even addr (addr[0]=0) selects high byte [15:8]
  - odd  addr (addr[0]=1) selects low  byte [7:0]
- current datapath address form: `d_ad = (sum << 1)`, so core-generated data/MMIO accesses are even-byte-aligned.

### Core/SoC terms
- hit: instruction-valid indicator into CPU. In this SoC harness, hit = ~rst.
- insn_ce: instruction clock-enable. When low, CPU is stalled (e.g., waiting on memory/IO ready).
- exec_ce: execute enable for the current instruction (instruction boundary / not stalled).
- valid_insn_ce: exec_ce excluding the "interrupt take" cycle (used to avoid committing wrong-path state).
- rdy: ready/handshake signal into CPU for load/store completion.
- br_taken: asserted when a branch/jump is taken. SoC uses it to inject NOP into insn_q (annul fall-through).

### Immediate/prefix terms
- IMM prefix: op=0x8 instruction that supplies upper 12 bits for the next immediate-using instruction.
- imm_pre/i12_pre: control_unit state tracking whether an IMM prefix is active and what its i12 was.

### Interrupt terms
- int_en: CPU-side "interrupts may be taken now" gate (depends on gie, stalls, interlocks, IMM atomicity).
- irq_take: asserted by IRQ controller when it is taking an interrupt.
- irq_vector: target PC address for the interrupt handler entry.
- in_irq: asserted by the GR0041 wrapper when interrupt nesting depth is nonzero (or an IRQ is being taken).
- iret_detected: asserted by CPU when the canonical IRET encoding is observed (used by wrapper/controller).

### Memory/MMIO terms
- is_io: selects MMIO vs BRAM in the SoC harness (is_io = d_ad[15]).
- mem_rdy/io_rdy: ready from BRAM vs MMIO; multiplexed to CPU as rdy.
- SB/LB: byte store/load operations using lane select; with current address generation they hit the high lane for normal core accesses.
