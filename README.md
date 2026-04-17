# Softcore SoC on Zybo Z7-10

[![CI](https://github.com/EmbSys25-26/processor/actions/workflows/ci-baseline.yml/badge.svg?branch=main)](https://github.com/EmbSys25-26/processor/actions/workflows/ci-baseline.yml)

A small 16-bit FPGA softcore “ecosystem” based on (and adapted from) Gray’s GR0040 RISC CPU design, wrapped into a SoC together with **hardware vectored interrupts**, **true Harvard ROM/RAM split**, and a handful of MMIO peripherals.

This repo contains the Vivado project targeting the **Zybo Z7-10 (XC7Z010)**, plus a Python assembler and example bare-metal programs.

## XSCT Terminal Script

- Make sure to change the paths on the processor/i2s_music/play_music.tcl script
