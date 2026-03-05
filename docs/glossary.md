# Processor Glossary (Signals + Terms)

_Last reviewed: 2026-02-18_

## Addressing Terms

- byte address: address counts bytes; word-aligned when `addr[0]=0`.
- word: 16-bit quantity.
- lane select: byte-lane selection inside a 16-bit word.
  - even generated addresses (`d_ad[1]=0`) map to high byte lane
  - odd generated addresses (`d_ad[1]=1`) map to low byte lane
- current data address form: EX stage emits `d_ad = (_sum << 1)`.

## Pipeline Terms

- IF/ID/EX/MEM/WB: five pipeline stages.
- stage valid: per-stage instruction validity bit propagated through pipe regs.
- stall: hold stage/register state for one cycle.
- bubble: inject NOP-equivalent control state.
- flush: clear younger pipeline state on redirect/IRQ.
- retire: instruction reaches WB and commits architectural state.

## Hazard Terms (v1)

- load-use hazard: consumer depends on a load result not yet available.
- RAW hazard: read-after-write dependency across in-flight stages.
- CC hazard: branch/consumer needs condition codes still in-flight.
- carry hazard: ADC/SBC-style carry dependency still in-flight.
- bubble-first policy: decode hazards stall IF/ID and bubble EX; forwarding deferred.

## Control/Flow Terms

- `br_taken`: branch/jump decision committed in ID stage.
- branch annul: SoC instruction latch injects NOP on taken branch to kill fall-through.
- `pc_next`: next-PC mux output (reset/IRQ/branch/sequential).

## Interrupt Terms

- `int_en`: CPU gate allowing IRQ acceptance.
- `irq_take`: controller requests interrupt entry.
- `accept_irq`: CPU accepts interrupt at a precise boundary (`~mem_wait`).
- `irq_vector`: target handler address.
- `in_irq`: CPU nesting-depth state (`depth != 0`).
- `iret_detected`: canonical IRET instruction observed by CPU.

## Memory/Bus Terms

- `mem_wait`: MEM stage waiting for load/store completion (`i_rdy=0`).
- `mem_complete`: memory op done this cycle.
- `is_io`: MMIO select (`d_ad[15]`).
- `mem_rdy` / `io_rdy`: ready signals from memory and MMIO paths.

## Firmware/ABI Anchor Terms

- ABI anchor: end-to-end check that `s0/s1` are restored after nested interrupt flow.
- preemption anchor: check that timer1 can preempt timer0 as expected.

