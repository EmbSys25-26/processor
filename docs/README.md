# Documentation

_Last reviewed: 2026-02-07_

## Purpose

- This folder is the implementation-aligned documentation baseline for refactor work.
- It is based on RTL in `srcs/*.v`, testbenches in `sim/*.v`.

## Contents

- [`architecture_and_memory.md`](architecture_and_memory.md)
  - SoC architecture, addressing model, IVT/memory layout, MMIO regions, and interrupt flow.
- [`isa_reference.md`](isa_reference.md)
  - Opcode/function map, instruction formats, branch conditions, immediate/prefix rules.
- [`abi_spec.md`](abi_spec.md)
  - ABI contract (register roles, stack/call conventions, ISR conventions, flags handling).
- [`glossary.md`](glossary.md)
  - Definitions for key signals/terms.
- [`rtl_file_walkthrough.md`](rtl_file_walkthrough.md)
  - Walkthrough of Verilog files in `srcs/` and `sim/`.
- [`refactor_extension_map.md`](refactor_extension_map.md)
  - Mapping from current boundaries to planned pipeline/compiler/peripheral work.
- [`known_inconsistencies_for_refactor.md`](known_inconsistencies_for_refactor.md)
  - Active code/documentation mismatches and hotspots.
- [`references.md`](references.md)
  - Curated source set used for this baseline.

## Assembler Docs

- [`assembler/assembler_reference.md`](assembler/assembler_reference.md)
- [`assembler/abi_inc_macro_reference.md`](assembler/abi_inc_macro_reference.md)
- [`assembler/isa_abi_assembler_checklist.md`](assembler/isa_abi_assembler_checklist.md)

## Recommended Read Order

1. `architecture_and_memory.md`
2. `isa_reference.md`
3. `abi_spec.md`
4. `rtl_file_walkthrough.md`
5. `assembler/assembler_reference.md`
6. `assembler/isa_abi_assembler_checklist.md`
7. `refactor_extension_map.md`
8. `known_inconsistencies_for_refactor.md`
