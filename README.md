# VGA Image Display — ZYBO Z7-10

Display static images on a VGA monitor using the ZYBO Z7-10 (Zynq-7010) FPGA board.  
Images are stored in DDR3 memory and streamed to the VGA output via AXI VDMA, using a custom Verilog VGA controller.

---

## System Architecture

```
DDR3 (image data)
      │
      │  AXI HP0 (64-bit, ~1 GB/s)
      ▼
AXI VDMA  ──────────────────────────────────────────────────────┐
(reads DDR3 autonomously, loops frame continuously)             │
      │                                                         │
      │  AXI4-Stream (TDATA 16-bit, TVALID, TREADY, TUSER)     │
      ▼                                                         │
m_hsync_vga.v                                                   │
(consumes pixel stream, generates HSYNC, drives RGB)            │
      │ endLine                                                  │
      ▼                                                         │
m_vsync_vga.v                                                   │
(counts lines, generates VSYNC)                                 │
      │                                                         │
      ▼                                                         │
VGA Monitor  ◄──────────────────────────────────────────────────┘
```

The **Block Design** (Vivado IP Integrator) contains:
- **Zynq PS** — provides the DDR3 controller and AXI interfaces
- **AXI VDMA** — reads the frame buffer from DDR3 and outputs a pixel stream
- **AXI SmartConnect** — routes AXI traffic between PS, VDMA and DDR3
- **Clocking Wizard** — generates 25 MHz pixel clock and 50 MHz system clock from 125 MHz board oscillator
- **Processor System Reset** — coordinates reset across all components

---

## Pixel Format

Each pixel is 16 bits packed as follows:

```
Bits [15:12]  →  Red   (4 bits)
Bits [11:8]   →  Green (4 bits)
Bits  [7:4]   →  Blue  (4 bits)
Bits  [3:0]   →  Unused (always 0)
```

---

## VGA Timing — 640×480 @ 60 Hz

| Region        | Horizontal (pixels) | Vertical (lines) |
|---------------|---------------------|------------------|
| Visible       | 640                 | 480              |
| Front Porch   | 16                  | 10               |
| Sync Pulse    | 96                  | 2                |
| Back Porch    | 48                  | 33               |
| **Total**     | **800**             | **525**          |

Pixel clock: **25.175 MHz**

---

### VDMA Register Map (base address: `0x43000000`)

| Offset | Register         | Value      | Description                        |
|--------|------------------|------------|------------------------------------|
| 0x00   | MM2S_VDMACR      | 0x00000003 | Run=1, Circular=1                  |
| 0x04   | MM2S_VDMASR      | 0x00000000 | Status — 0 = running OK            |
| 0x58   | MM2S_FRMDLY_STRIDE | 0x00000500 | Stride = 1280 bytes               |
| 0x54   | MM2S_HSIZE       | 0x00000500 | HSize = 1280 bytes                 |
| 0x5C   | MM2S_STARTADDR1  | 0x01000000 | Frame buffer start address         |
| 0x50   | MM2S_VSIZE       | 0x000001E0 | VSize = 480 — **write this last**  |

> ⚠️ Always write VSIZE (0x50) **last** — writing it triggers the DMA start.

---

## Repository Structure

```
├── sources/
│   ├── controller.v        — Top-level module, instantiates clocking wizard and m_vga_mmio
│   ├── periph_vga.v        — MMIO peripheral, instantiates block design wrapper and VGA modules
│   ├── hsync_module.v      — Horizontal sync FSM, consumes AXI4-Stream pixel data
│   ├── vsync_module.v      — Vertical sync FSM, counts endLine pulses
│   └── constants.vh        — VGA channel size definition
├── scripts/
│   ├── initialize.tcl      — XSCT script: programs FPGA, loads images, configures VDMA
│   └── image_to_bin.py     — Python script: converts PNG to raw binary pixel file
└── README.md
```

---

## Prerequisites

- Vivado 2025.1 (with Vitis/XSCT)
- ZYBO Z7-10 board connected via USB-JTAG
- Python 3 with Pillow: `pip install Pillow`
- VGA monitor connected to the ZYBO VGA port

---

## Step 1 — Convert Images to Binary

Run the Python script on your PC for each image you want to display:

```bash
python image_to_bin.py
```

The script `image_to_bin.py` converts any PNG/JPEG to a raw 16-bit binary file:

Output: a `.bin` file of exactly `640 × 480 × 2 = 614,400 bytes`.

---

## Step 2 — Generate Bitstream in Vivado

1. Open Vivado and your project
2. Run **Generate Bitstream** (Flow Navigator → Generate Bitstream)
3. Wait for completion

---

## Step 3 — Get ps7_init.tcl

`ps7_init.tcl` initialises the Zynq PS DDR3 controller. It is generated automatically by Vivado:

```
File → Export Hardware → Include Bitstream → OK
```

The file will be at:
```
<project>/ps_system/ps7_init.tcl
```

> ⚠️ This file must be regenerated every time you change the PS configuration in the block design.

---

## Step 4 — Open XSCT

XSCT (Xilinx Software Command-line Tool) is required to program the FPGA, initialise DDR3 and configure the VDMA. It is installed with Vivado/Vitis.

Open a terminal and run:

```bash
cd /home/mariana/Vivado/2025.1/Vitis/bin/
./xsct
```

You will see the XSCT prompt:
```
xsct%
```

---

## Step 5 — Run the Initialisation Script

Inside XSCT, source the initialisation script:

```tcl
source "/home/mariana/Desktop/Peripherals/initialize.tcl"
```

This script does the following automatically:

1. **Connects to the ZYBO** via JTAG
2. **Programs the FPGA** with the bitstream
3. **Initialises the PS** (DDR3 controller, clocks) via `ps7_init.tcl`
4. **Loads image 1** (`red.bin`) into DDR3 at address `0x01000000`
5. **Loads image 2** (`gato.bin`) into DDR3 at address `0x01200000`
6. **Verifies** the images were loaded by reading the first pixels
7. **Configures the VDMA** and starts displaying image 1

After the script completes, image 1 should be visible on the monitor.

---

## Step 6 — Switch Between Images

Once the script has run, switch images at any time by typing in the XSCT terminal:

```tcl
# Display image 2 (gato)
show $image2

# Display image 1 (red)
show $image1
```

The `show` procedure stops the VDMA, changes the frame buffer address, and restarts it:

```tcl
proc show {addr} {
    global VDMA_BASE
    mwr [expr {$VDMA_BASE + 0x00}] 0x00000004  ;# reset VDMA
    after 500
    mwr [expr {$VDMA_BASE + 0x00}] 0x00000003  ;# run + circular mode
    mwr [expr {$VDMA_BASE + 0x58}] 0x00000500  ;# stride = 1280 bytes
    mwr [expr {$VDMA_BASE + 0x54}] 0x00000500  ;# hsize  = 1280 bytes
    mwr [expr {$VDMA_BASE + 0x5C}] $addr        ;# frame buffer address
    after 2000
    mwr [expr {$VDMA_BASE + 0x50}] 0x000001E0  ;# vsize = 480 — starts DMA
}
```

---

## Verify VDMA is Running

After calling `show`, check the VDMA status register:

```tcl
mrd [expr {$VDMA_BASE + 0x04}]
```
