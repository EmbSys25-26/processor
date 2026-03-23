transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

asim +access +r +m+font_rom  -L xil_defaultlib -L xpm -L dist_mem_gen_v8_0_17 -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.font_rom xil_defaultlib.glbl

do {font_rom.udo}

run 1000ns

endsim

quit -force
