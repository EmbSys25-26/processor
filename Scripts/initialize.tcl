#!/usr/bin/env tclsh
# =============================================================================
# initialize.tcl — Portable Zybo Z7-10 VGA System Initialization
#
# USAGE (in Vivado xsct or Tcl Console):
#   source /path/to/initialize.tcl
#
# Place this script anywhere. It will search for:
#   *.bit          — bitstream (anywhere under the script folder, up to 4 levels)
#   ps7_init.tcl   — PS7 init (anywhere under script folder, or inside *.xsa)
#   red.bin        — image 1 (optional, next to script or one level up)
#   gato.bin       — image 2 (optional, next to script or one level up)
# =============================================================================

puts "\n╔════════════════════════════════════════════╗"
puts "║   VGA System Initialization Script         ║"
puts "║   Zybo Z7-10                               ║"
puts "╚════════════════════════════════════════════╝\n"

set script_dir [file normalize [file dirname [info script]]]
set proj_dir [file dirname $script_dir]
puts "Script directory: $script_dir\n"

# =============================================================================
# HELPER: Recursively search for first file matching pattern
# =============================================================================
proc find_file_recursive {base pattern max_depth} {
    set hits [glob -nocomplain "$base/$pattern"]
    if {[llength $hits] > 0} { return [lindex $hits 0] }
    if {$max_depth <= 0} { return "" }
    foreach dir [glob -nocomplain -type d "$base/*"] {
        set tail [file tail $dir]
        if {$tail eq ".Xil" || $tail eq ".cache" || $tail eq "tmp" || $tail eq ".git"} continue
        set result [find_file_recursive $dir $pattern [expr {$max_depth - 1}]]
        if {$result ne ""} { return $result }
    }
    return ""
}

# =============================================================================
# SECTION 1 — LOCATE FILES
# =============================================================================

# --- Bitstream ---
set bitstream_file [find_file_recursive $proj_dir "*.bit" 5]

if {$bitstream_file eq ""} {
    puts "ERROR: No .bit file found anywhere under:"
    puts "   $script_dir"
    puts ""
    puts "   Make sure implementation completed in Vivado."
    return
}
puts "Bitstream  : $bitstream_file"

# --- ps7_init.tcl: search folder first, then extract from .xsa ---
set ps7_init_file [find_file_recursive $proj_dir "ps7_init.tcl" 5]

if {$ps7_init_file eq ""} {
    set xsa_file [find_file_recursive $proj_dir "*.xsa" 4]
    if {$xsa_file ne ""} {
        puts "Found .xsa: [file tail $xsa_file] - extracting ps7_init.tcl..."
        set extract_dir "$script_dir/ps7_extracted"
        file mkdir $extract_dir
        if {[catch {exec unzip -o $xsa_file ps7_init.tcl -d $extract_dir} err]} {
            catch {exec unzip -o $xsa_file -d $extract_dir}
        }
        set ps7_init_file [find_file_recursive $extract_dir "ps7_init.tcl" 2]
    }
}

if {$ps7_init_file ne ""} {
    puts "ps7_init   : $ps7_init_file"
    set has_ps7 1
} else {
    puts "WARNING: ps7_init.tcl not found"
    set has_ps7 0
}

# --- Image files ---
proc find_bin {script_dir name} {
    foreach candidate [list \
        "$script_dir/$name" \
        "[file dirname $script_dir]/$name" \
    ] {
        if {[file exists $candidate]} { return $candidate }
    }
    return ""
}

set red_bin_file  [find_bin $script_dir "red.bin"]
set gato_bin_file [find_bin $script_dir "gato.bin"]
set has_red_bin   [expr {$red_bin_file  ne ""}]
set has_gato_bin  [expr {$gato_bin_file ne ""}]

if {$has_red_bin}  { puts "red.bin    : $red_bin_file" } \
else               { puts "WARNING: red.bin not found" }
if {$has_gato_bin} { puts "gato.bin   : $gato_bin_file" } \
else               { puts "WARNING: gato.bin not found" }

puts "\n─────────────────────────────────────────────\n"

# =============================================================================
# SECTION 2 — CONNECT AND PROGRAM FPGA
# =============================================================================

puts "Connecting to JTAG..."
connect

puts "Available targets:"
targets

puts "\nStopping ARM core..."
catch {
    targets -set -filter {name =~ "APU*"}
    stop
}

puts "Programming FPGA bitstream..."
targets -set -filter {name =~ "xc7z010*"}
if {[catch {fpga -f $bitstream_file} err]} {
    puts "ERROR programming bitstream: $err"
    return
}
puts "Bitstream programmed\n"

# =============================================================================
# SECTION 3 — PS7 INIT (DDR3, clocks, ARM)
# =============================================================================

if {!$has_ps7} {
    puts "Skipping PS7/DDR3 initialization - ps7_init.tcl not found."
    return
}

puts "Initializing PS7 (DDR3 + clocks)..."
targets -set -filter {name =~ "APU*"}

if {[catch {source $ps7_init_file} err]} {
    puts "ERROR sourcing ps7_init.tcl: $err"
    return
}
if {[catch {ps7_init} err]} {
    puts "ERROR in ps7_init: $err"
    return
}
catch {ps7_post_config}

puts "Waiting for DDR3 to stabilize (3s)..."
after 3000
puts "PS7 initialized\n"

# =============================================================================
# SECTION 4 — LOAD IMAGES INTO DDR3
# =============================================================================

proc load_bin {filepath addr} {
    set size [file size $filepath]
    puts "Loading [file tail $filepath] -> 0x[format %08X $addr] ($size bytes)..."

    set fh [open $filepath rb]
    set data [read $fh]
    close $fh

    set num_full_words [expr {$size / 4}]
    for {set i 0} {$i < $num_full_words} {incr i} {
        set chunk [string range $data [expr {$i*4}] [expr {$i*4+3}]]
        binary scan $chunk "i" w
        mwr [expr {$addr + $i*4}] [expr {$w & 0xFFFFFFFF}]
    }
    set rem [expr {$size % 4}]
    if {$rem > 0} {
        set last_word 0
        for {set b 0} {$b < $rem} {incr b} {
            set byte [scan [string index $data [expr {$num_full_words*4 + $b}]] %c]
            set last_word [expr {$last_word | ($byte << ($b*8))}]
        }
        mwr [expr {$addr + $num_full_words*4}] $last_word
    }
    puts "Done."
}

if {$has_red_bin}  { load_bin $red_bin_file  0x01000000; after 200 }
if {$has_gato_bin} { load_bin $gato_bin_file 0x01200000; after 200 }

# =============================================================================
# SECTION 5 — CONFIGURE AXI VDMA
# =============================================================================
puts "\nConfiguring AXI VDMA..."

# !! Verify this matches your Vivado Address Editor for axi_vdma_0 !!
set VDMA_BASE 0x43000000
catch {memmap -addr $VDMA_BASE -size 0x10000}

proc show {addr} {
    global VDMA_BASE
    puts "Displaying image at 0x[format %08X $addr]..."
    mwr [expr {$VDMA_BASE + 0x00}] 0x00000004 ;# Reset MM2S
    after 500
    mwr [expr {$VDMA_BASE + 0x00}] 0x00000003 ;# Start (RS=1, circular)
    mwr [expr {$VDMA_BASE + 0x58}] 0x00000500 ;# Stride
    mwr [expr {$VDMA_BASE + 0x54}] 0x00000500 ;# HSize
    mwr [expr {$VDMA_BASE + 0x5C}] $addr      ;# Frame buffer address
    mwr [expr {$VDMA_BASE + 0x50}] 0x000001E0 ;# VSize (triggers DMA)
}

set image1 0x01000000
set image2 0x01200000

# =============================================================================
# SECTION 6 — HARDWARE SWITCH POLLING LOOP (VDMA CONTROL)
# =============================================================================
puts "\n======================================================="
puts " Starting Switch Polling Loop (SW1=P15, SW0=G15)"
puts " 00: Off | 01: Image 1 | 10: Image 2 | 11: Text"
puts "======================================================="

# !! Verify this matches your Vivado Address Editor for axi_gpio_0 !!
set GPIO_BASE 0x41200000
catch {memmap -addr $GPIO_BASE -size 0x10000}
set last_sw -1

# Helper to turn off the screen by halting the VDMA stream
proc hide_image {} {
    global VDMA_BASE
    mwr [expr {$VDMA_BASE + 0x00}] 0x00000000 ;# Halt VDMA (outputs black)
}

while {1} {
    # Read the 2-bit switch array from GPIO
    if {[catch {set sw_val [mrd -value $GPIO_BASE]} err]} {
        puts "Polling stopped or connection lost."
        break
    }
    
    # Mask out just the bottom 2 bits
    set sw_val [expr {$sw_val & 0x3}]

    if {$sw_val != $last_sw} {
        switch $sw_val {
            0 {
                puts ">>> State 00: Screen OFF"
                hide_image           ;# Stop VDMA
            }
            1 {
                puts ">>> State 01: Image 1 (red.bin)"
                show $image1         ;# Point VDMA to Image 1
            }
            2 {
                puts ">>> State 10: Image 2 (gato.bin)"
                show $image2         ;# Point VDMA to Image 2
            }
            3 {
                puts ">>> State 11: Text Mode"
                # The hardware AND gate overrides the screen automatically!
                # We don't need to do anything with the VDMA here.
            }
        }
        set last_sw $sw_val
    }
    
    # Sleep 100ms to avoid locking up Vivado's UI
    after 100
}