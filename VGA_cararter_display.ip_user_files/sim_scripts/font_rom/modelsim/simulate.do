onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc"  -L xil_defaultlib -L xpm -L dist_mem_gen_v8_0_17 -L unisims_ver -L unimacro_ver -L secureip -lib xil_defaultlib xil_defaultlib.font_rom xil_defaultlib.glbl

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {font_rom.udo}

run 1000ns

quit -force
