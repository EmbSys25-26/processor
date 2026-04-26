connect
targets -set -filter {name =~ "APU*"}
stop
targets -set -filter {name =~ "xc7z010*"}
fpga -f "/home/diofilfrcos/Desktop/i2s_playstop_skip_jose/processor-dev-i2s-ddr3/processor.runs/impl_1/soc.bit"
after 2000
targets -set -filter {name =~ "APU*"}
loadhw "/home/diofilfrcos/Desktop/i2s_playstop_skip_jose/processor-dev-i2s-ddr3/soc_i2s.xsa"
source "/home/diofilfrcos/Desktop/i2s_playstop_skip_jose/processor-dev-i2s-ddr3/i2s_music/ps7_init.tcl"
ps7_init
ps7_post_config
after 5000

# ── Addresses ────────────────────────────────────────────────────────────────
set DMA_BASE  0x40400000
set GPIO_BASE 0x41200000     ;# AXI GPIO (BTN2 — i_par_i[2] / pin K19)

set SONG1_ADDR 0x01000000
set SONG2_ADDR 0x02000000
set SONG3_ADDR 0x05000000
set SONG4_ADDR 0x08000000

set SONG1_FILE "/home/diofilfrcos/Desktop/i2s_playstop_skip_jose/processor-dev-i2s-ddr3/i2s_music/song1.bin"
set SONG2_FILE "/home/diofilfrcos/Desktop/i2s_playstop_skip_jose/processor-dev-i2s-ddr3/i2s_music/song2.bin"
set SONG3_FILE "/home/diofilfrcos/Desktop/i2s_playstop_skip_jose/processor-dev-i2s-ddr3/i2s_music/song3.bin"
set SONG4_FILE "/home/diofilfrcos/Desktop/i2s_playstop_skip_jose/processor-dev-i2s-ddr3/i2s_music/song4.bin"

set SONG1_LEN  [file size $SONG1_FILE]
set SONG2_LEN  [file size $SONG2_FILE]
set SONG3_LEN  [file size $SONG3_FILE]
set SONG4_LEN  [file size $SONG4_FILE]

# Song table: list of {ddr_address byte_length label}
set SONGS [list \
    [list $SONG1_ADDR $SONG1_LEN "song1"] \
    [list $SONG2_ADDR $SONG2_LEN "song2"] \
    [list $SONG3_ADDR $SONG3_LEN "song3"] \
    [list $SONG4_ADDR $SONG4_LEN "song4"] \
]
set NUM_SONGS [llength $SONGS]

# ── Load all songs into DDR ───────────────────────────────────────────────────
puts "Loading songs into DDR3..."
dow -data $SONG1_FILE $SONG1_ADDR
puts [format "  song1: %d bytes @ 0x%08X" $SONG1_LEN $SONG1_ADDR]
dow -data $SONG2_FILE $SONG2_ADDR
puts [format "  song2: %d bytes @ 0x%08X" $SONG2_LEN $SONG2_ADDR]
dow -data $SONG3_FILE $SONG3_ADDR
puts [format "  song3: %d bytes @ 0x%08X" $SONG3_LEN $SONG3_ADDR]
dow -data $SONG4_FILE $SONG4_ADDR
puts [format "  song4: %d bytes @ 0x%08X" $SONG4_LEN $SONG4_ADDR]
after 1000
puts "All songs loaded."

# ── DMA helpers ──────────────────────────────────────────────────────────────
proc dma_start {base addr len} {
    mwr [expr {$base + 0x00}] 0x00000004   ;# Reset DMA
    after 50
    mwr [expr {$base + 0x00}] 0x00000001   ;# Run
    after 10
    mwr [expr {$base + 0x18}] $addr        ;# MM2S source address
    mwr [expr {$base + 0x28}] $len         ;# Transfer length (triggers DMA)
}

proc dma_stop {base} {
    mwr [expr {$base + 0x00}] 0x00000004   ;# Reset halts the engine immediately
    after 50
}

proc dma_idle {base} {
    set sr [mrd -value [expr {$base + 0x04}]]
    return [expr {($sr & 0x02) != 0}]      ;# Bit 1 = Idle (transfer complete)
}

# ── Initial DMA status ───────────────────────────────────────────────────────
set dma_sr [mrd -value [expr {$DMA_BASE + 0x04}]]
puts [format "DMA SR initial: 0x%08X" $dma_sr]

# ── Start playback ───────────────────────────────────────────────────────────
set song_idx  0
set last_btn  0
set skip_lock 0    ;# cooldown polls remaining after a skip

set song [lindex $SONGS $song_idx]
set addr [lindex $song 0]
set len  [lindex $song 1]
set name [lindex $song 2]
puts "Playing $name ($len bytes)"
dma_start $DMA_BASE $addr $len

# ── Main poll loop ───────────────────────────────────────────────────────────
# Polls every 50 ms.  BTN2 rising edge triggers skip; 1-second cooldown
# prevents double-skip on a long press.  Song auto-advances at natural end.
puts "Waiting for codec I2C initialization..."
after 3000

puts "Ready. Press BTN2 (K19) to skip songs."

# Allow access to AXI GPIO address not yet in the loaded .xsa memory map.
# Remove this line after re-exporting hardware from Vivado (File → Export → Export Hardware).
configparams force-mem-access 1

while {1} {
    after 50

    # ── Skip-button: rising-edge detect with 1-second cooldown ──────────────
    set btn [expr {[mrd -value $GPIO_BASE] & 0x1}]

    if {$skip_lock > 0} {
        incr skip_lock -1
    } elseif {$btn && !$last_btn} {
        puts "Skip pressed — advancing song..."
        dma_stop $DMA_BASE

        set song_idx [expr {($song_idx + 1) % $NUM_SONGS}]
        set song [lindex $SONGS $song_idx]
        set addr [lindex $song 0]
        set len  [lindex $song 1]
        set name [lindex $song 2]
        puts "Playing $name ($len bytes)"
        dma_start $DMA_BASE $addr $len

        set skip_lock 20   ;# 20 * 50 ms = 1 second cooldown
    }
    set last_btn $btn

    # ── Natural end-of-song: auto-advance ────────────────────────────────────
    if {[dma_idle $DMA_BASE] && $skip_lock == 0} {
        puts "$name finished — advancing song..."
        set song_idx [expr {($song_idx + 1) % $NUM_SONGS}]
        set song [lindex $SONGS $song_idx]
        set addr [lindex $song 0]
        set len  [lindex $song 1]
        set name [lindex $song 2]
        puts "Playing $name ($len bytes)"
        dma_start $DMA_BASE $addr $len
    }
}
