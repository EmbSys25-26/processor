# Softcore SoC on Zybo Z7-10

A small 16-bit FPGA softcore “ecosystem” based on (and adapted from) Gray’s GR0040 RISC CPU design, wrapped into a SoC together with **hardware vectored interrupts**, **Harvard BRAM**, and a handful of MMIO peripherals.

This repo contains the Vivado project targeting the **Zybo Z7-10 (XC7Z010)**, plus a Python assembler and example bare-metal programs.

## Highlights

- 16-bit RISC CPU with 16 GPRs (`r0..r15`) and fixed-width 16-bit ISA
- CPU module with integrated control/datapath and interrupt-aware execution state (`in_irq`, nesting depth tracking)
- Hardware vectored interrupt controller with fixed vectors and limited nesting/preemption
- Harvard 1 KiB true dual-port BRAM with byte lanes (hi/lo) and byte enables
- MMIO peripheral bus mapped to `0x8000–0x8FFF`
- Peripherals: Timer0, Timer1 (higher priority), PARIO (4-bit), UART (RX interrupt)
- Python two-pass assembler with `.include` and macro support

## Repository layout

- `srcs/` – Verilog RTL
	- `m_soc.v` – top-level `soc` (CPU + BRAM + MMIO bus)
	- `m_cpu.v` – integrated `cpu` module (control + datapath + IRQ depth tracking)
	- `m_ctrl_unit.v` – control unit
	- `m_datapath.v` – datapath
	- `m_alu.v` – ALU helpers
	- `m_regfile16x16.v` – register file
	- `constants.vh` – shared ISA/width constants
	- `m_periph_bus.v` – MMIO decode/mux + IRQ wiring
	- `m_irq_ctrl.v` – interrupt controller
	- `m_timer16.v`, `m_timerH.v` – timers
	- `m_uart_mmio.v`, `m_uart_rx.v`, `m_uart_tx.v` – UART blocks
	- `m_bram.v` – 1 KiB hi/lo BRAM model (init from hex files)
	- `m_pario.v` – simple parallel I/O
	- `mem/` – BRAM init hex images (`mem_hi.hex`, `mem_lo.hex`)
- `sim/` – testbenches
	- `tb_Soc.v` – SoC testbench (optional UART MMIO self-test)
	- `tb_soc_refactor_regression.v` – SoC regression (IRQ/MMIO activity)
	- `tb_anchor_preemption_abi.v` – anchor checks (timer preemption + ABI preservation)
	- `tb_timer_start_reg.v` – timer start/reload register checks
	- `tb_cpu_irq_depth.v` – IRQ depth robustness checks
	- `tb_soc_byte_lane.v` – SoC byte-lane behavior checks for `LB/SB`
- `tools/` – software tools
	- `assembler.py` – assembler that emits BRAM init images
	- `abi.inc` – ABI register aliases + convenience macros
- `assembly/` – example assembly programs
	- `input.asm` – vector table + ISRs + small ABI tests
- `constraints/` – Zybo XDC constraints (and optional ILA constraints)
- `docs/` – Markdown implementation baseline + report sources

## Quickstart

### Prerequisites

- Vivado (preferrably **Vivado 2025.1**)
- Python **3.7+** for the assembler
- Board: Zybo Z7-10 (or adapt constraints for your board)

### 0) Clone the repository and import the .xpr (Xilinx Project) file
```bash
git clone https://github.com/jssilvaa/verilog-processor && cd verilog-processor/
```
Open the Vivado Design Suite™ and import the .xpr file in the project root. 
Verify the hierarchy of the project:
- In the design sources, check if the SoC module `m_soc.v` is selected as top.
- In the simulation sources, check if the testbench `tb_Soc.v` is selected as top.
If not, right-click and "Select as Project/Hierarchy root".
Any other issues, refer to the Troubleshooting section. 

### 1) Assemble a program into BRAM init hex

The BRAM model loads two byte-lane files (hi/lo). Generate them from an assembly program:

```bash
# Defaults:
#   input:  assembly/input.asm
#   output: srcs/mem/mem.hex + srcs/mem/mem_hi.hex + srcs/mem/mem_lo.hex
python3 tools/assembler.py
```

Notes:
- The assembler uses *byte addresses* in `.org`/labels, but internally tracks locations in *words* and enforces alignment.
- `.include` is resolved relative to the including file. Example: `assembly/input.asm` uses `.include "../tools/abi.inc"`.

### 2) Run simulation (Vivado xsim)

Open the project (`processor.xpr`) in Vivado and run simulation with `tb_Soc`.

Useful defines in `sim/tb_Soc.v`:
- `SIM` – uses a much faster UART baud rate for simulation
- `TB_USE_INTERNALS` – exposes internal DUT signals and prints IRQ/UART activity
- `TB_UART_MMIO_TEST` – bypasses the CPU and directly pokes UART MMIO registers

In order to define a set of properties for simulation, run the following command in the TCL prompt: 
```bash
set_property verilog_defines {SIM=1 TB_USE_INTERNALS=1} [get_filesets sources_1]
```
Change the `{SIM=1 TB_USE_INTERNALS=1}` part with the properties you want to set. 

The testbench writes a VCD: `waves_soc.vcd`.

Timing-simulation waveform presets:
- post-synthesis: `wavecfgs/coolWave.wcfg` (targets `tb_Soc_time_synth.wdb`)
- post-implementation: `wavecfgs/coolWave_impl.wcfg` (targets `tb_Soc_time_impl.wdb`)

### 3) Build bitstream & program hardware

1. Open `processor.xpr` in Vivado
2. Run synthesis + implementation
3. Generate bitstream (`.bit`)
4. Program the Zybo Z7-10 via **Hardware Manager**

If you use ILA debug, you’ll also need the generated `.ltx`.

## CI Baseline (for PRs)

This repository includes a deterministic simulation CI gate for pull requests:

- Workflow: `.github/workflows/ci-baseline.yml`
- Runner script: `scripts/ci/run_iverilog_regression.sh`

Run the same suite locally:

```bash
bash scripts/ci/run_iverilog_regression.sh
```

Detailed CI methodology and GitHub setup steps are documented in:

- `docs/ci_baseline_verification.md`

## Architecture overview

### Top-level SoC

The top-level module is `srcs/m_soc.v`:

- Instantiates integrated `cpu` module (control, datapath, IRQ depth tracking)
- Instantiates a 1 KiB dual-port BRAM (`srcs/m_bram.v`)
- Instantiates the peripheral bus (`srcs/m_periph_bus.v`)

Instruction fetch is synchronous: the BRAM instruction output is registered into an instruction latch (`insn_q`). A taken branch annuls the fall-through by injecting a NOP.

### Addressing model

- Instruction addresses are byte addresses (`PC` increments by 2 per instruction).
- Current datapath computes load/store/MMIO address as `d_ad = (sum << 1)` in `srcs/m_datapath.v`.
- BRAM is word-indexed using `addr[9:1]`; lane select uses `addr[0]`.
- For core-generated byte operations (`LB/SB`), lane selection is derived from `d_ad[1]` in SoC glue logic.
- `LB` returns zero-extended byte data from the selected lane; `SB` stores low byte `data_out[7:0]` into the selected lane.
- Software examples therefore use pre-shift constants for MMIO/data references (for example, `0x4000` in code maps to MMIO base `0x8000` after the datapath shift).
- MMIO is selected by `d_ad[15] == 1` (i.e., `0x8000–0xFFFF`), with this design using `0x8000–0x8FFF`.

### Global memory map (byte addressing)

- `0x0000–0x03FF` – 1 KiB BRAM (code + data)
- `0x0020–0x009F` – interrupt vector region (fixed entry points)
- `0x0100` – reset vector (default PC after reset)
- `0x8000–0x8FFF` – MMIO window

### MMIO decode

MMIO is decoded by `addr[11:8]` in `srcs/m_periph_bus.v`:

| Address range | Block |
|---:|---|
| `0x8000–0x80FF` | Timer0 (`timer16`) |
| `0x8100–0x81FF` | Timer1 (`timerH`, higher priority) |
| `0x8200–0x82FF` | PARIO |
| `0x8300–0x83FF` | UART MMIO |
| `0x8F00–0x8FFF` | IRQ controller regs |

### Peripheral register maps

#### Timer0 / Timer1

Timer0 base `0x8000`, Timer1 base `0x8100`:

| Address | Name | Meaning |
|---:|---|---|
| `BASE+0x0` | CR0 | `[0]=int_en`, `[1]=timer_mode` |
| `BASE+0x2` | CR1 | `[0]=int_req` (write-any clears) |
| `BASE+0x4` | CNT_INIT | start/reload counter value (R/W) |
| `BASE+0x6` | CNT | live counter value (debug read) |

Writing `CNT_INIT` also updates the running counter immediately.

#### PARIO (4-bit)

Base `0x8200`:

| Address | Meaning |
|---:|---|
| `0x8200` | write: `par_o[3:0]`, read: `par_o[3:0]` |
| `0x8202` | read: `par_i[3:0]` |

Current RTL asserts a PARIO IRQ when `par_i == 4'hF`.

#### UART MMIO

Base `0x8300`:

| Address | Name | Meaning |
|---:|---|---|
| `0x8300` | DATA | write: enqueue TX byte (if not busy); read: last RX byte (also clears `rx_pending`) |
| `0x8302` | STATUS | bit0 `tx_busy`, bit1 `rx_pending` (write with `wdata[1]=1` clears `rx_pending`) |

The UART asserts its interrupt request when RX data is pending.

#### IRQ controller regs

IRQ controller base `0x8F00`. The controller is word-indexed internally via `addr[3:1]`, which corresponds to these byte offsets:

| Address | Name | Access | Meaning |
|---:|---|---|---|
| `0x8F00` | `IRQ_PEND` | R | pending bitfield |
| `0x8F04` | `IRQ_MASK` | R/W | enable mask (1=enabled) |
| `0x8F08` | `IRQ_FORCE` | W | set pending bits (`pending |= wdata[7:0]`) |
| `0x8F0C` | `IRQ_CLEAR` | W | clear pending bits (`pending &= ~wdata[7:0]`) |

Priority is fixed (higher IRQ index wins) and a small priority stack enables limited nesting/preemption (see `DEPTH` in `srcs/m_irq_ctrl.v`).

### Interrupt vectors

The interrupt controller generates **hardware vectors**:

| Source | Vector |
|---|---:|
| Timer0 | `0x0020` |
| Timer1 | `0x0040` |
| PARIO | `0x0060` |
| UART (RX pending) | `0x0080` |

An example vector table + ISRs live in `assembly/input.asm`.

## Documentation

Primary docs are in:

- `docs/README.md`
- `docs/architecture_and_memory.md`
- `docs/isa_reference.md`
- `docs/abi_spec.md`

Legacy report sources are in:
- `docs/report/docs.tex`
- `docs/report/docs-implementation.tex`

## Practical notes / gotchas

- `srcs/m_bram.v` loads BRAM init files from `./srcs/mem/mem_hi.hex` and `./srcs/mem/mem_lo.hex`.
- `tools/assembler.py` now pads output to 512 words by default, so BRAM init warnings about short hex files are avoided.
- UART baud rate is compile-time selectable in `srcs/m_periph_bus.v`: `SIM` builds use a much faster baud for testbench convenience.

## Credits

- Original GR0040 concepts based on Gray’s “Designing a Simple FPGA-Optimized RISC CPU and System-on-a-Chip” (see references in the LaTeX docs).
