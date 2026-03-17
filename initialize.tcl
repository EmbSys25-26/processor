connect
targets
targets -set -filter {name =~ "APU*"}
stop
targets -set -filter {name =~ "xc7z010*"}
fpga -f /home/mariana/Desktop/Peripherals/VGA_img/vgaIMG/vgaIMG.runs/impl_1/controller.bit
targets -set -filter {name =~ "APU*"}
source "/home/mariana/Desktop/Peripherals/VGA_img/vgaIMG/ps_system/ps7_init.tcl"
ps7_init
ps7_post_config
dow -data "/home/mariana/Desktop/Peripherals/image.bin" 0x01000000
mrd 0x01000000 4

set VDMA_BASE 0x43000000
mwr [expr {$VDMA_BASE + 0x00}] 0x00000004
after 10
mwr [expr {$VDMA_BASE + 0x00}] 0x00000003
mwr [expr {$VDMA_BASE + 0x58}] 0x00000500
mwr [expr {$VDMA_BASE + 0x54}] 0x00000500
mwr [expr {$VDMA_BASE + 0x5C}] 0x01000000
mwr [expr {$VDMA_BASE + 0x50}] 0x000001E0
mrd [expr {$VDMA_BASE + 0x04}]


