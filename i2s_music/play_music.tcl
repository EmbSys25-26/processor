connect
targets -set -filter {name =~ "APU*"}
stop
targets -set -filter {name =~ "xc7z010*"}
fpga -f "/home/josesilvaa/processor/processor.runs/impl_1/soc.bit"
after 2000
targets -set -filter {name =~ "APU*"}
loadhw "/home/josesilvaa/processor/soc_i2s.xsa"
source "/home/josesilvaa/processor/i2s_music/ps7_init.tcl"
ps7_init
ps7_post_config
after 5000
set DMA_BASE   0x40400000
set MUSIC_ADDR 0x01000000
set MUSIC_FILE "/home/josesilvaa/processor/i2s_music/song1.bin"
set dma_sr [mrd -value [expr {$DMA_BASE + 0x04}]]
puts [format "DMA SR initial: 0x%08X" $dma_sr]
puts "Loading music..."
dow -data $MUSIC_FILE $MUSIC_ADDR
set MUSIC_LENGTH [file size $MUSIC_FILE]
puts "Size: $MUSIC_LENGTH bytes"
after 500
puts "Waiting for codec I2C initialization..."
after 3000
puts "Configuring DMA..."
mwr [expr {$DMA_BASE + 0x00}] 0x00000004
after 500
mwr [expr {$DMA_BASE + 0x00}] 0x00000001
after 200
mwr [expr {$DMA_BASE + 0x18}] $MUSIC_ADDR
mwr [expr {$DMA_BASE + 0x28}] $MUSIC_LENGTH
after 2000
set dma_sr [mrd -value [expr {$DMA_BASE + 0x04}]]
puts [format "DMA SR final: 0x%08X" $dma_sr]
if       {($dma_sr & 0x08) != 0} { puts "ERROR: DMAIntErr"
} elseif {($dma_sr & 0x01) != 0} { puts "ERROR: DMA Halted"
} elseif {($dma_sr & 0x02) != 0} { puts "Transfer complete!"
} else                            { puts "OK: Playing audio!" }
