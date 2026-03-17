transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

asim +access +r +m+vga_system  -L xil_defaultlib -L xilinx_vip -L xpm -L axi_infrastructure_v1_1_0 -L axi_vip_v1_1_21 -L processing_system7_vip_v1_0_23 -L fifo_generator_v13_2_13 -L axi_datamover_v5_1_37 -L axi_vdma_v6_3_23 -L xlconstant_v1_1_10 -L proc_sys_reset_v5_0_17 -L smartconnect_v1_0 -L axi_register_slice_v2_1_35 -L xilinx_vip -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.vga_system xil_defaultlib.glbl

do {vga_system.udo}

run 1000ns

endsim

quit -force
