connect
targets
targets -set -filter {name =~ "APU*"}
stop
targets -set -filter {name =~ "xc7z010*"}
fpga -f /home/simba/Documents/Embedded_Systems/2nd_semester/VGA_simba/processor/VGA_img/vgaIMG/vgaIMG.runs/impl_1/controller.bit
targets -set -filter {name =~ "APU*"}
source "/home/simba/Documents/Embedded_Systems/2nd_semester/VGA_simba/processor/VGA_img/vgaIMG/ps_system/ps7_init.tcl"
ps7_init
ps7_post_config
after 3000
dow -data "/home/simba/Documents/Embedded_Systems/2nd_semester/VGA_simba/processor/red.bin" 0x01000000
after 1000
mrd 0x01000000 4
dow -data "/home/simba/Documents/Embedded_Systems/2nd_semester/VGA_simba/processor/gato.bin" 0x01200000
after 1000
mrd 0x01000000 4

memmap -addr 0x43000000 -size 0x10000
set VDMA_BASE 0x43000000

proc show {addr} {
	global VDMA_BASE
	mwr [expr {$VDMA_BASE + 0x00}] 0x00000004
	after 500
	mwr [expr {$VDMA_BASE + 0x00}] 0x00000003 
	mwr [expr {$VDMA_BASE + 0x58}] 0x00000500 
	mwr [expr {$VDMA_BASE + 0x54}] 0x00000500
	mwr [expr {$VDMA_BASE + 0x5C}] $addr	 
	mwr [expr {$VDMA_BASE + 0x50}] 0x000001E0 
}

set image1 0x01000000
set image2 0x01200000

show $image1



