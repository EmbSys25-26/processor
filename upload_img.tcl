# Initialize PS (DDR3 controller, clocks)
# MANDATORY — without this DDR3 does not respond
source "/home/mariana/Desktop/Peripherals/VGA_img/vgaIMG/ps_system/ps7_init.tcl"
ps7_init
ps7_post_config

# Copy image into DDR3 at 0x01000000 (16 MB offset)
mrd "/home/mariana/Desktop/Peripherals/image.bin" 0x01000000
# Verify first 4 pixels — should match top-left corner of your image
mrd 0x01000000 4

# Configure VDMA — VDMA_BASE has to match the one in Address Editor
set VDMA_BASE 0x43000000

mwr [expr {$VDMA_BASE + 0x00}] 0x00000003  ;# Control: Run + Circular mode
mwr [expr {$VDMA_BASE + 0x58}] 0x00000500  ;# Stride = 1280 bytes (640 x 2)
mwr [expr {$VDMA_BASE + 0x54}] 0x00000500  ;# HSize  = 1280 bytes per line
mwr [expr {$VDMA_BASE + 0x5C}] 0x01000000  ;# Frame buffer start address
mwr [expr {$VDMA_BASE + 0x50}] 0x000001E0  ;# VSize = 480 lines — starts DMA. HAS to be last one!

# Check status: 0x00000000 = running OK, 0x00000001 = halted (error)
mrd [expr {$VDMA_BASE + 0x04}]

puts "VDMA running. Image should appear on screen."


