GR0040/GR0041 Team Documentation (Refactor Baseline)

Last reviewed: 2026-02-04

Purpose
- This folder is a plain-text documentation baseline for the current processor implementation.
- It is written for refactor work (pipeline, compiler/toolchain growth, and new peripherals).
- It is based on: RTL in `srcs/*.v`, testbenches in `sim/*.v`, and the project TeX docs (`docs.tex`, `docs-implementation.tex`).
- If documentation disagrees with RTL, **RTL is the source of truth**. Update docs in the same PR as behavior changes.

Contents
- `architecture_and_memory.txt`
  - SoC architecture, addressing model, IVT/memory layout, MMIO regions, and interrupt flow.
- `isa_reference.txt`
  - Opcode/function map, instruction formats, branch conditions, immediate/prefix rules.
- `abi_spec.txt`
  - Complete ABI contract (register roles, stack/call conventions, ISR conventions, flags handling).
- `glossary.txt`
  - Quick definitions for key signals/terms (byte addressing, lane select, stall/flush, IRQ signals).
- `rtl_file_walkthrough.txt`
  - Walkthrough of every Verilog file (`srcs/*.v` and `sim/*.v`).
  - Each module has purpose + input/output contract + behavior summary.
- `refactor_extension_map.txt`
  - Mapping from current boundaries to planned pipeline/compiler/new-peripheral work.
- `known_inconsistencies_for_refactor.txt`
  - Current code/documentation mismatches and edge cases to fix during refactor.

Assembler-focused docs (`documentation/assembler/`)
- `assembler_reference.txt`
  - Assembler CLI, pass1/pass2 pipeline, directives, expressions, output artifacts, ISA coverage.
- `abi_inc_macro_reference.txt`
  - Macro catalog from `tools/abi.inc` with expansion intent and clobber notes.
- `isa_abi_assembler_checklist.txt`
  - Checklist mapping ISA implementation, ABI usage, and assembler support.

Recommended Read Order
1) `architecture_and_memory.txt`
2) `isa_reference.txt`
3) `abi_spec.txt`
4) `rtl_file_walkthrough.txt`
5) `documentation/assembler/assembler_reference.txt`
6) `documentation/assembler/isa_abi_assembler_checklist.txt`
7) `refactor_extension_map.txt`
8) `known_inconsistencies_for_refactor.txt`

Pipeline refactor docs live in the repo root at:
- `pipeline/`

Pre-refactor failure mode triage lives at:
- `failure_modes/`

Team collaboration guide (GitHub merge/conflicts + CI basics) lives at:
- `team_guide/`
