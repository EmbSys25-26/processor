vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xpm
vlib questa_lib/msim/dist_mem_gen_v8_0_17
vlib questa_lib/msim/xil_defaultlib

vmap xpm questa_lib/msim/xpm
vmap dist_mem_gen_v8_0_17 questa_lib/msim/dist_mem_gen_v8_0_17
vmap xil_defaultlib questa_lib/msim/xil_defaultlib

vlog -work xpm -64 -incr -mfcu  -sv "+incdir+../../../../../../../Vivado/2025.1/data/rsb/busdef" \
"/home/mariana/Vivado/2025.1/Vivado/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"/home/mariana/Vivado/2025.1/Vivado/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -64 -93  \
"/home/mariana/Vivado/2025.1/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work dist_mem_gen_v8_0_17 -64 -incr -mfcu  "+incdir+../../../../../../../Vivado/2025.1/data/rsb/busdef" \
"../../../ipstatic/simulation/dist_mem_gen_v8_0.v" \

vlog -work xil_defaultlib -64 -incr -mfcu  "+incdir+../../../../../../../Vivado/2025.1/data/rsb/busdef" \
"../../../../VGA_cararter_display.gen/sources_1/ip/font_rom/sim/font_rom.v" \

vlog -work xil_defaultlib \
"glbl.v"

