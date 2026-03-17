vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xilinx_vip
vlib questa_lib/msim/xpm
vlib questa_lib/msim/axi_infrastructure_v1_1_0
vlib questa_lib/msim/axi_vip_v1_1_21
vlib questa_lib/msim/processing_system7_vip_v1_0_23
vlib questa_lib/msim/xil_defaultlib
vlib questa_lib/msim/fifo_generator_v13_2_13
vlib questa_lib/msim/axi_datamover_v5_1_37
vlib questa_lib/msim/axi_vdma_v6_3_23
vlib questa_lib/msim/xlconstant_v1_1_10
vlib questa_lib/msim/proc_sys_reset_v5_0_17
vlib questa_lib/msim/smartconnect_v1_0
vlib questa_lib/msim/axi_register_slice_v2_1_35

vmap xilinx_vip questa_lib/msim/xilinx_vip
vmap xpm questa_lib/msim/xpm
vmap axi_infrastructure_v1_1_0 questa_lib/msim/axi_infrastructure_v1_1_0
vmap axi_vip_v1_1_21 questa_lib/msim/axi_vip_v1_1_21
vmap processing_system7_vip_v1_0_23 questa_lib/msim/processing_system7_vip_v1_0_23
vmap xil_defaultlib questa_lib/msim/xil_defaultlib
vmap fifo_generator_v13_2_13 questa_lib/msim/fifo_generator_v13_2_13
vmap axi_datamover_v5_1_37 questa_lib/msim/axi_datamover_v5_1_37
vmap axi_vdma_v6_3_23 questa_lib/msim/axi_vdma_v6_3_23
vmap xlconstant_v1_1_10 questa_lib/msim/xlconstant_v1_1_10
vmap proc_sys_reset_v5_0_17 questa_lib/msim/proc_sys_reset_v5_0_17
vmap smartconnect_v1_0 questa_lib/msim/smartconnect_v1_0
vmap axi_register_slice_v2_1_35 questa_lib/msim/axi_register_slice_v2_1_35

vlog -work xilinx_vip -64 -incr -mfcu  -sv -L axi_vip_v1_1_21 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_23 -L xilinx_vip "+incdir+/home/mariana/Vivado/2025.1/Vivado/data/xilinx_vip/include" \
"/home/mariana/Vivado/2025.1/Vivado/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
"/home/mariana/Vivado/2025.1/Vivado/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
"/home/mariana/Vivado/2025.1/Vivado/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
"/home/mariana/Vivado/2025.1/Vivado/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
"/home/mariana/Vivado/2025.1/Vivado/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
"/home/mariana/Vivado/2025.1/Vivado/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
"/home/mariana/Vivado/2025.1/Vivado/data/xilinx_vip/hdl/axi_vip_if.sv" \
"/home/mariana/Vivado/2025.1/Vivado/data/xilinx_vip/hdl/clk_vip_if.sv" \
"/home/mariana/Vivado/2025.1/Vivado/data/xilinx_vip/hdl/rst_vip_if.sv" \

vlog -work xpm -64 -incr -mfcu  -sv -L axi_vip_v1_1_21 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_23 -L xilinx_vip "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/ec67/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/6cfa/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/5fb3/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a8e4/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a9be" "+incdir+../../../../../../../../Vivado/2025.1/data/rsb/busdef" "+incdir+/home/mariana/Vivado/2025.1/Vivado/data/xilinx_vip/include" \
"/home/mariana/Vivado/2025.1/Vivado/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"/home/mariana/Vivado/2025.1/Vivado/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
"/home/mariana/Vivado/2025.1/Vivado/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -64 -93  \
"/home/mariana/Vivado/2025.1/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work axi_infrastructure_v1_1_0 -64 -incr -mfcu  "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/ec67/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/6cfa/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/5fb3/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a8e4/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a9be" "+incdir+../../../../../../../../Vivado/2025.1/data/rsb/busdef" "+incdir+/home/mariana/Vivado/2025.1/Vivado/data/xilinx_vip/include" \
"../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/ec67/hdl/axi_infrastructure_v1_1_vl_rfs.v" \

vlog -work axi_vip_v1_1_21 -64 -incr -mfcu  -sv -L axi_vip_v1_1_21 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_23 -L xilinx_vip "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/ec67/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/6cfa/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/5fb3/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a8e4/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a9be" "+incdir+../../../../../../../../Vivado/2025.1/data/rsb/busdef" "+incdir+/home/mariana/Vivado/2025.1/Vivado/data/xilinx_vip/include" \
"../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/f16f/hdl/axi_vip_v1_1_vl_rfs.sv" \

vlog -work processing_system7_vip_v1_0_23 -64 -incr -mfcu  -sv -L axi_vip_v1_1_21 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_23 -L xilinx_vip "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/ec67/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/6cfa/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/5fb3/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a8e4/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a9be" "+incdir+../../../../../../../../Vivado/2025.1/data/rsb/busdef" "+incdir+/home/mariana/Vivado/2025.1/Vivado/data/xilinx_vip/include" \
"../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/6cfa/hdl/processing_system7_vip_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib -64 -incr -mfcu  "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/ec67/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/6cfa/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/5fb3/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a8e4/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a9be" "+incdir+../../../../../../../../Vivado/2025.1/data/rsb/busdef" "+incdir+/home/mariana/Vivado/2025.1/Vivado/data/xilinx_vip/include" \
"../../../bd/vga_system/ip/vga_system_processing_system7_0_0/sim/vga_system_processing_system7_0_0.v" \

vlog -work fifo_generator_v13_2_13 -64 -incr -mfcu  "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/ec67/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/6cfa/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/5fb3/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a8e4/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a9be" "+incdir+../../../../../../../../Vivado/2025.1/data/rsb/busdef" "+incdir+/home/mariana/Vivado/2025.1/Vivado/data/xilinx_vip/include" \
"../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/dc46/simulation/fifo_generator_vlog_beh.v" \

vcom -work fifo_generator_v13_2_13 -64 -93  \
"../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/dc46/hdl/fifo_generator_v13_2_rfs.vhd" \

vlog -work fifo_generator_v13_2_13 -64 -incr -mfcu  "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/ec67/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/6cfa/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/5fb3/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a8e4/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a9be" "+incdir+../../../../../../../../Vivado/2025.1/data/rsb/busdef" "+incdir+/home/mariana/Vivado/2025.1/Vivado/data/xilinx_vip/include" \
"../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/dc46/hdl/fifo_generator_v13_2_rfs.v" \

vcom -work axi_datamover_v5_1_37 -64 -93  \
"../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/d44a/hdl/axi_datamover_v5_1_vh_rfs.vhd" \

vlog -work axi_vdma_v6_3_23 -64 -incr -mfcu  "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/ec67/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/6cfa/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/5fb3/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a8e4/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a9be" "+incdir+../../../../../../../../Vivado/2025.1/data/rsb/busdef" "+incdir+/home/mariana/Vivado/2025.1/Vivado/data/xilinx_vip/include" \
"../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/5fb3/hdl/axi_vdma_v6_3_rfs.v" \

vcom -work axi_vdma_v6_3_23 -64 -93  \
"../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/5fb3/hdl/axi_vdma_v6_3_rfs.vhd" \

vcom -work xil_defaultlib -64 -93  \
"../../../bd/vga_system/ip/vga_system_axi_vdma_0_0/sim/vga_system_axi_vdma_0_0.vhd" \

vlog -work xlconstant_v1_1_10 -64 -incr -mfcu  "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/ec67/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/6cfa/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/5fb3/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a8e4/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a9be" "+incdir+../../../../../../../../Vivado/2025.1/data/rsb/busdef" "+incdir+/home/mariana/Vivado/2025.1/Vivado/data/xilinx_vip/include" \
"../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a165/hdl/xlconstant_v1_1_vl_rfs.v" \

vlog -work xil_defaultlib -64 -incr -mfcu  "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/ec67/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/6cfa/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/5fb3/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a8e4/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a9be" "+incdir+../../../../../../../../Vivado/2025.1/data/rsb/busdef" "+incdir+/home/mariana/Vivado/2025.1/Vivado/data/xilinx_vip/include" \
"../../../bd/vga_system/ip/vga_system_axi_smc_0/bd_0/ip/ip_0/sim/bd_654d_one_0.v" \

vcom -work proc_sys_reset_v5_0_17 -64 -93  \
"../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/9438/hdl/proc_sys_reset_v5_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -64 -93  \
"../../../bd/vga_system/ip/vga_system_axi_smc_0/bd_0/ip/ip_1/sim/bd_654d_psr_aclk_0.vhd" \

vlog -work smartconnect_v1_0 -64 -incr -mfcu  -sv -L axi_vip_v1_1_21 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_23 -L xilinx_vip "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/ec67/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/6cfa/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/5fb3/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a8e4/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a9be" "+incdir+../../../../../../../../Vivado/2025.1/data/rsb/busdef" "+incdir+/home/mariana/Vivado/2025.1/Vivado/data/xilinx_vip/include" \
"../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/f0b6/hdl/sc_util_v1_0_vl_rfs.sv" \
"../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/d800/hdl/sc_mmu_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib -64 -incr -mfcu  -sv -L axi_vip_v1_1_21 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_23 -L xilinx_vip "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/ec67/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/6cfa/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/5fb3/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a8e4/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a9be" "+incdir+../../../../../../../../Vivado/2025.1/data/rsb/busdef" "+incdir+/home/mariana/Vivado/2025.1/Vivado/data/xilinx_vip/include" \
"../../../bd/vga_system/ip/vga_system_axi_smc_0/bd_0/ip/ip_2/sim/bd_654d_s00mmu_0.sv" \

vlog -work smartconnect_v1_0 -64 -incr -mfcu  -sv -L axi_vip_v1_1_21 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_23 -L xilinx_vip "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/ec67/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/6cfa/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/5fb3/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a8e4/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a9be" "+incdir+../../../../../../../../Vivado/2025.1/data/rsb/busdef" "+incdir+/home/mariana/Vivado/2025.1/Vivado/data/xilinx_vip/include" \
"../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/2da8/hdl/sc_transaction_regulator_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib -64 -incr -mfcu  -sv -L axi_vip_v1_1_21 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_23 -L xilinx_vip "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/ec67/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/6cfa/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/5fb3/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a8e4/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a9be" "+incdir+../../../../../../../../Vivado/2025.1/data/rsb/busdef" "+incdir+/home/mariana/Vivado/2025.1/Vivado/data/xilinx_vip/include" \
"../../../bd/vga_system/ip/vga_system_axi_smc_0/bd_0/ip/ip_3/sim/bd_654d_s00tr_0.sv" \

vlog -work smartconnect_v1_0 -64 -incr -mfcu  -sv -L axi_vip_v1_1_21 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_23 -L xilinx_vip "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/ec67/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/6cfa/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/5fb3/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a8e4/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a9be" "+incdir+../../../../../../../../Vivado/2025.1/data/rsb/busdef" "+incdir+/home/mariana/Vivado/2025.1/Vivado/data/xilinx_vip/include" \
"../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/dce3/hdl/sc_si_converter_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib -64 -incr -mfcu  -sv -L axi_vip_v1_1_21 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_23 -L xilinx_vip "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/ec67/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/6cfa/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/5fb3/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a8e4/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a9be" "+incdir+../../../../../../../../Vivado/2025.1/data/rsb/busdef" "+incdir+/home/mariana/Vivado/2025.1/Vivado/data/xilinx_vip/include" \
"../../../bd/vga_system/ip/vga_system_axi_smc_0/bd_0/ip/ip_4/sim/bd_654d_s00sic_0.sv" \

vlog -work smartconnect_v1_0 -64 -incr -mfcu  -sv -L axi_vip_v1_1_21 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_23 -L xilinx_vip "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/ec67/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/6cfa/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/5fb3/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a8e4/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a9be" "+incdir+../../../../../../../../Vivado/2025.1/data/rsb/busdef" "+incdir+/home/mariana/Vivado/2025.1/Vivado/data/xilinx_vip/include" \
"../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/cef3/hdl/sc_axi2sc_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib -64 -incr -mfcu  -sv -L axi_vip_v1_1_21 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_23 -L xilinx_vip "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/ec67/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/6cfa/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/5fb3/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a8e4/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a9be" "+incdir+../../../../../../../../Vivado/2025.1/data/rsb/busdef" "+incdir+/home/mariana/Vivado/2025.1/Vivado/data/xilinx_vip/include" \
"../../../bd/vga_system/ip/vga_system_axi_smc_0/bd_0/ip/ip_5/sim/bd_654d_s00a2s_0.sv" \

vlog -work smartconnect_v1_0 -64 -incr -mfcu  -sv -L axi_vip_v1_1_21 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_23 -L xilinx_vip "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/ec67/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/6cfa/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/5fb3/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a8e4/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a9be" "+incdir+../../../../../../../../Vivado/2025.1/data/rsb/busdef" "+incdir+/home/mariana/Vivado/2025.1/Vivado/data/xilinx_vip/include" \
"../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a8e4/hdl/sc_node_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib -64 -incr -mfcu  -sv -L axi_vip_v1_1_21 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_23 -L xilinx_vip "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/ec67/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/6cfa/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/5fb3/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a8e4/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a9be" "+incdir+../../../../../../../../Vivado/2025.1/data/rsb/busdef" "+incdir+/home/mariana/Vivado/2025.1/Vivado/data/xilinx_vip/include" \
"../../../bd/vga_system/ip/vga_system_axi_smc_0/bd_0/ip/ip_6/sim/bd_654d_sarn_0.sv" \
"../../../bd/vga_system/ip/vga_system_axi_smc_0/bd_0/ip/ip_7/sim/bd_654d_srn_0.sv" \
"../../../bd/vga_system/ip/vga_system_axi_smc_0/bd_0/ip/ip_8/sim/bd_654d_sawn_0.sv" \
"../../../bd/vga_system/ip/vga_system_axi_smc_0/bd_0/ip/ip_9/sim/bd_654d_swn_0.sv" \
"../../../bd/vga_system/ip/vga_system_axi_smc_0/bd_0/ip/ip_10/sim/bd_654d_sbn_0.sv" \

vlog -work smartconnect_v1_0 -64 -incr -mfcu  -sv -L axi_vip_v1_1_21 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_23 -L xilinx_vip "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/ec67/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/6cfa/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/5fb3/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a8e4/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a9be" "+incdir+../../../../../../../../Vivado/2025.1/data/rsb/busdef" "+incdir+/home/mariana/Vivado/2025.1/Vivado/data/xilinx_vip/include" \
"../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/7f4f/hdl/sc_sc2axi_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib -64 -incr -mfcu  -sv -L axi_vip_v1_1_21 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_23 -L xilinx_vip "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/ec67/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/6cfa/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/5fb3/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a8e4/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a9be" "+incdir+../../../../../../../../Vivado/2025.1/data/rsb/busdef" "+incdir+/home/mariana/Vivado/2025.1/Vivado/data/xilinx_vip/include" \
"../../../bd/vga_system/ip/vga_system_axi_smc_0/bd_0/ip/ip_11/sim/bd_654d_m00s2a_0.sv" \

vlog -work smartconnect_v1_0 -64 -incr -mfcu  -sv -L axi_vip_v1_1_21 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_23 -L xilinx_vip "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/ec67/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/6cfa/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/5fb3/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a8e4/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a9be" "+incdir+../../../../../../../../Vivado/2025.1/data/rsb/busdef" "+incdir+/home/mariana/Vivado/2025.1/Vivado/data/xilinx_vip/include" \
"../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/0133/hdl/sc_exit_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib -64 -incr -mfcu  -sv -L axi_vip_v1_1_21 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_23 -L xilinx_vip "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/ec67/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/6cfa/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/5fb3/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a8e4/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a9be" "+incdir+../../../../../../../../Vivado/2025.1/data/rsb/busdef" "+incdir+/home/mariana/Vivado/2025.1/Vivado/data/xilinx_vip/include" \
"../../../bd/vga_system/ip/vga_system_axi_smc_0/bd_0/ip/ip_12/sim/bd_654d_m00e_0.sv" \

vlog -work xil_defaultlib -64 -incr -mfcu  "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/ec67/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/6cfa/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/5fb3/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a8e4/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a9be" "+incdir+../../../../../../../../Vivado/2025.1/data/rsb/busdef" "+incdir+/home/mariana/Vivado/2025.1/Vivado/data/xilinx_vip/include" \
"../../../bd/vga_system/ip/vga_system_axi_smc_0/bd_0/sim/bd_654d.v" \

vlog -work smartconnect_v1_0 -64 -incr -mfcu  -sv -L axi_vip_v1_1_21 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_23 -L xilinx_vip "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/ec67/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/6cfa/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/5fb3/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a8e4/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a9be" "+incdir+../../../../../../../../Vivado/2025.1/data/rsb/busdef" "+incdir+/home/mariana/Vivado/2025.1/Vivado/data/xilinx_vip/include" \
"../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/3718/hdl/sc_switchboard_v1_0_vl_rfs.sv" \

vlog -work axi_register_slice_v2_1_35 -64 -incr -mfcu  "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/ec67/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/6cfa/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/5fb3/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a8e4/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a9be" "+incdir+../../../../../../../../Vivado/2025.1/data/rsb/busdef" "+incdir+/home/mariana/Vivado/2025.1/Vivado/data/xilinx_vip/include" \
"../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/c5b7/hdl/axi_register_slice_v2_1_vl_rfs.v" \

vlog -work xil_defaultlib -64 -incr -mfcu  -sv -L axi_vip_v1_1_21 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_23 -L xilinx_vip "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/ec67/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/6cfa/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/5fb3/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a8e4/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a9be" "+incdir+../../../../../../../../Vivado/2025.1/data/rsb/busdef" "+incdir+/home/mariana/Vivado/2025.1/Vivado/data/xilinx_vip/include" \
"../../../bd/vga_system/ip/vga_system_axi_smc_0/sim/vga_system_axi_smc_0.sv" \

vcom -work xil_defaultlib -64 -93  \
"../../../bd/vga_system/ip/vga_system_rst_ps7_0_50M_0/sim/vga_system_rst_ps7_0_50M_0.vhd" \

vlog -work xil_defaultlib -64 -incr -mfcu  "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/ec67/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/6cfa/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/5fb3/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a8e4/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a9be" "+incdir+../../../../../../../../Vivado/2025.1/data/rsb/busdef" "+incdir+/home/mariana/Vivado/2025.1/Vivado/data/xilinx_vip/include" \
"../../../bd/vga_system/ip/vga_system_clk_wiz_0_1/vga_system_clk_wiz_0_1_clk_wiz.v" \
"../../../bd/vga_system/ip/vga_system_clk_wiz_0_1/vga_system_clk_wiz_0_1.v" \
"../../../bd/vga_system/ip/vga_system_smartconnect_0_0/bd_0/ip/ip_0/sim/bd_ead3_one_0.v" \

vcom -work xil_defaultlib -64 -93  \
"../../../bd/vga_system/ip/vga_system_smartconnect_0_0/bd_0/ip/ip_1/sim/bd_ead3_psr_aclk_0.vhd" \

vlog -work xil_defaultlib -64 -incr -mfcu  -sv -L axi_vip_v1_1_21 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_23 -L xilinx_vip "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/ec67/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/6cfa/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/5fb3/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a8e4/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a9be" "+incdir+../../../../../../../../Vivado/2025.1/data/rsb/busdef" "+incdir+/home/mariana/Vivado/2025.1/Vivado/data/xilinx_vip/include" \
"../../../bd/vga_system/ip/vga_system_smartconnect_0_0/bd_0/ip/ip_2/sim/bd_ead3_s00mmu_0.sv" \
"../../../bd/vga_system/ip/vga_system_smartconnect_0_0/bd_0/ip/ip_3/sim/bd_ead3_s00tr_0.sv" \
"../../../bd/vga_system/ip/vga_system_smartconnect_0_0/bd_0/ip/ip_4/sim/bd_ead3_s00sic_0.sv" \
"../../../bd/vga_system/ip/vga_system_smartconnect_0_0/bd_0/ip/ip_5/sim/bd_ead3_s00a2s_0.sv" \
"../../../bd/vga_system/ip/vga_system_smartconnect_0_0/bd_0/ip/ip_6/sim/bd_ead3_sarn_0.sv" \
"../../../bd/vga_system/ip/vga_system_smartconnect_0_0/bd_0/ip/ip_7/sim/bd_ead3_srn_0.sv" \
"../../../bd/vga_system/ip/vga_system_smartconnect_0_0/bd_0/ip/ip_8/sim/bd_ead3_m00s2a_0.sv" \
"../../../bd/vga_system/ip/vga_system_smartconnect_0_0/bd_0/ip/ip_9/sim/bd_ead3_m00e_0.sv" \

vlog -work xil_defaultlib -64 -incr -mfcu  "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/ec67/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/6cfa/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/5fb3/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a8e4/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a9be" "+incdir+../../../../../../../../Vivado/2025.1/data/rsb/busdef" "+incdir+/home/mariana/Vivado/2025.1/Vivado/data/xilinx_vip/include" \
"../../../bd/vga_system/ip/vga_system_smartconnect_0_0/bd_0/sim/bd_ead3.v" \

vlog -work xil_defaultlib -64 -incr -mfcu  -sv -L axi_vip_v1_1_21 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_23 -L xilinx_vip "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/ec67/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/6cfa/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/5fb3/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a8e4/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a9be" "+incdir+../../../../../../../../Vivado/2025.1/data/rsb/busdef" "+incdir+/home/mariana/Vivado/2025.1/Vivado/data/xilinx_vip/include" \
"../../../bd/vga_system/ip/vga_system_smartconnect_0_0/sim/vga_system_smartconnect_0_0.sv" \

vlog -work xil_defaultlib -64 -incr -mfcu  "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/ec67/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/6cfa/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/5fb3/hdl" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/f0b6/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a8e4/hdl/verilog" "+incdir+../../../../vgaIMG.gen/sources_1/bd/vga_system/ipshared/a9be" "+incdir+../../../../../../../../Vivado/2025.1/data/rsb/busdef" "+incdir+/home/mariana/Vivado/2025.1/Vivado/data/xilinx_vip/include" \
"../../../bd/vga_system/sim/vga_system.v" \

vlog -work xil_defaultlib \
"glbl.v"

