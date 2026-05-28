# Behavioural simulation of compiled C exercises

This directory drives full-SoC xsim simulation of the C programs under
`compiler/exercises/`.  Each program is compiled, linked with the C
runtime, assembled to a BROM hex pair, loaded into the SoC, and run
until `main()` returns — the testbench then asserts the return value
in `a0` matches the documented expected value.

## Quick start

```bash
# (one-time) source Vivado so xsim is on PATH
source /tools/Xilinx/2025.1/Vivado/settings64.sh

# build + simulate every exercise
./run.sh

# run a single exercise
./run.sh solE013

# wipe build artefacts and xsim scratch
./run.sh --clean
```

Output is one line per exercise (PASS / FAIL / TIMEOUT) with the cycle
count and final `a0`, followed by a totals line.  Build artefacts land
in `$EXERCISES_BUILD` (default `/tmp/exercises_build`).

## Files

| file           | purpose                                              |
| -------------- | ---------------------------------------------------- |
| `tb_c_e2e.v`   | generic execution testbench, parameterised via Verilog `+define`s for the hex paths, expected value, and test name |
| `srcs.prj`     | xvlog project file: every SoC RTL module + this testbench, all with paths relative to this dir |
| `run.sh`       | bash driver: iterates the manifest, builds each program via `compiler/scripts/build_c_e2e.sh`, elaborates with per-test defines, runs xsim, classifies PASS/FAIL |

## How the test detects "main returned"

`compiler/CodeGen/codegen.c` emits a fixed boot section at the head of
every program:

```
.org 0x0100
_start:
    CLI
    NOP                     ; CLI hazard guard
    LI(sp, 0x01FE)          ; top of BRAM (word-index)
    NOP                     ; LI consumer hazard guard
    CALL(main)
    NOP                     ; CALL delay slot
_halt:
    BR _halt
```

`CALL(main)` sets `lr = 0x0110` (the address of `_halt`).  When `main`
returns it lands in the `BR _halt` self-loop.  The testbench watches
for `pc == 0x0110` to be stable across 8 consecutive cycles, snapshots
`a0`, and compares against `EXPECT_A0`.

## Toolchain dependencies

| tool      | source                                          |
| --------- | ----------------------------------------------- |
| `xvlog`/`xelab`/`xsim` | Vivado 2025.1 (source `settings64.sh`) |
| `m4`, `awk` | OS package                                    |
| `compiler/compiler`     | built from this repo's compiler/ tree |
| `compiler/assembler/assembler` | built from this repo's assembler/ tree |
