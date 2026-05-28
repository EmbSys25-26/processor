# Flashing a `.c` file into Vivado for behavioural sim

A 1-page guide for turning a hand-written `compiler/test.c` into a
running behavioural simulation in the Vivado GUI, without touching the
pipeline project's design sources.

## 0. One-time setup

Open the pipeline Vivado project, then:

1. **Settings → Project Settings → Simulation → Compilation** —
   in `xsim.compile.xvlog.more_options` paste (one line):
   ```
   -d BROM_MEM_LO_PATH=\"<absolute>/compiler/test_lo.hex\" -d BROM_MEM_HI_PATH=\"<absolute>/compiler/test_hi.hex\"
   ```
   Replace `<absolute>` with this directory's real absolute path. This
   makes the BROM init read the hex pair we'll produce in step 3,
   instead of the demo-image fallback.

2. **Add `compiler/test_tb.v` as a simulation source only.** Flow
   Navigator → Add Sources → **Add or create simulation sources** →
   Add Files → `compiler/test_tb.v`. Tick `sim_1` as the simulation
   set, leave the design source sets unchecked. This keeps the SoC
   RTL untouched.

3. **Set `test_tb` as the simulation top:** right-click the new file
   in the Sources panel → *Set as Top*.

## 1. Write the test

In this directory (`compiler/`):

```c
// test.c
int main(void) {
    int s = 0;
    for (int i = 1; i <= 10; i = i + 1) s = s + i;
    return s;          // 55 = 0x0037
}
```

`main()`'s return value lands in `a0` at the moment the CPU enters the
boot stub's `BR _halt` loop at PC 0x0110.

## 2. Build the hex pair

From this directory:

```bash
bash scripts/build_c_e2e.sh test.c --out-dir .
```

That drops `test.hex`, `test_lo.hex`, and `test_hi.hex` into
`compiler/` (the output stem defaults to the input filename without
the `.c`).  The codegen-emitted boot stub (ISR IRET vectors + reset
entry + halt loop) is included automatically.

## 3. Run behavioural simulation

In Vivado: **Flow Navigator → Run Simulation → Run Behavioral
Simulation**.

When the sim finishes you'll see in the Tcl console:

```
test_tb done  pc=0x0110  a0=0x0037
```

`pc=0x0110` confirms you reached the halt loop (main returned cleanly);
`a0` is your test's return value.

## 4. What to watch in the waveform

Useful signals to add to the wave window:

| signal                       | purpose                              |
| ---------------------------- | ------------------------------------ |
| `dut.u_cpu._pc`              | current program counter              |
| `dut.u_cpu.u_regfile._a0`    | main's return value                  |
| `dut.u_cpu.u_regfile._sp`    | stack pointer                        |
| `dut.u_cpu._ifid_insn`       | instruction in ID stage              |
| `dut.u_cpu._gie`             | global IRQ enable (codegen CLI-ed)   |

## 5. Iterating

Edit `test.c`, re-run step 2 (`bash scripts/build_c_e2e.sh ...`), then
**relaunch sim** in Vivado (Restart in the sim toolbar, then Run All).
The hex files are re-read by the BROM `$readmemh` on every `initial`
block evaluation, so no project re-build needed.

If you just want PASS/FAIL with a known expected value (no GUI),
drop the program into `compiler/exercises/` and use
`pipeline/exercises/run.sh` instead — it does the same thing in xsim
from the command line.
