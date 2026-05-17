set_property -dict {PACKAGE_PIN K17 IOSTANDARD LVCMOS33} [get_ports i_clk]
set_property -dict {PACKAGE_PIN K18 IOSTANDARD LVCMOS33} [get_ports {i_par_i[0]}]
set_property -dict {PACKAGE_PIN P16 IOSTANDARD LVCMOS33} [get_ports {i_par_i[1]}]
set_property -dict {PACKAGE_PIN K19 IOSTANDARD LVCMOS33} [get_ports {i_par_i[2]}]
set_property -dict {PACKAGE_PIN Y16 IOSTANDARD LVCMOS33} [get_ports {i_par_i[3]}]
set_property -dict {PACKAGE_PIN M14 IOSTANDARD LVCMOS33} [get_ports {o_par_o[0]}]
set_property -dict {PACKAGE_PIN M15 IOSTANDARD LVCMOS33} [get_ports {o_par_o[1]}]
set_property -dict {PACKAGE_PIN G14 IOSTANDARD LVCMOS33} [get_ports {o_par_o[2]}]
set_property -dict {PACKAGE_PIN D18 IOSTANDARD LVCMOS33} [get_ports {o_par_o[3]}]
set_property -dict {PACKAGE_PIN N15 IOSTANDARD LVCMOS33} [get_ports o_uart_tx]
set_property -dict {PACKAGE_PIN L14 IOSTANDARD LVCMOS33} [get_ports i_uart_rx]
## This file is a .xdc for the Zybo Z7-10
## Clock signal options:
## 50 MHz:
#create_clock -period 20.000 -name sys_clk_pin -waveform {0.000 10.000} -add [get_ports i_clk]
## 100 MHz:
##create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports i_clk]
## 107 MHZ
##create_clock -period 9.346 -name sys_clk_pin -waveform {0.000 4.673} -add [get_ports i_clk]
## 108 MHZ
##create_clock -period 9.259 -name sys_clk_pin -waveform {0.000 4.630} -add [get_ports i_clk]
## 109 MHZ
##create_clock -period 9.174 -name sys_clk_pin -waveform {0.000 4.587} -add [get_ports i_clk]

## Switches

## Buttons -> i_par_i[3:0]

## LEDs -> o_par_o[3:0]

## UART (PL) on PMOD JA

## I2C (PL) on remaining PMOD JA pins (open-drain, pull-up enabled).
## NOTE: external pull-ups are still recommended for robust I2C signaling.
set_property PACKAGE_PIN K16 [get_ports io_i2c_sda]
set_property IOSTANDARD LVCMOS33 [get_ports io_i2c_sda]
set_property PULLTYPE PULLUP [get_ports io_i2c_sda]
set_property PACKAGE_PIN K14 [get_ports io_i2c_scl]
set_property IOSTANDARD LVCMOS33 [get_ports io_i2c_scl]
set_property PULLTYPE PULLUP [get_ports io_i2c_scl]

set_false_path -to  [get_ports {i_par_i[*]}]
set_false_path -to  [get_ports i_uart_rx]
set_false_path -to  [get_ports i_rst]
set_false_path -to [get_ports io_i2c_sda]
set_false_path -to [get_ports {o_par_o[*]}]
set_false_path -to [get_ports o_uart_tx]
set_false_path -to [get_ports io_i2c_scl]
set_false_path -to  [get_ports io_i2c_sda]

## ----------------------------------------------------------------------------
## SYSTEM RESET
## ----------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN T16 IOSTANDARD LVCMOS33} [get_ports i_rst]

## ----------------------------------------------------------------------------
## VGA MODE SWITCHES (From VGA Project)
## i_sw_1 -> P15 (SW1) | i_sw_0 -> G15 (SW0)
## ----------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN P15 IOSTANDARD LVCMOS33} [get_ports {i_sw_1}]
set_property -dict {PACKAGE_PIN G15 IOSTANDARD LVCMOS33} [get_ports {i_sw_0}]

## ----------------------------------------------------------------------------
## VGA OUTPUT (PMOD Standard / Custom Mapping)
## ----------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN U14 IOSTANDARD LVCMOS33} [get_ports o_hsync]
set_property -dict {PACKAGE_PIN U15 IOSTANDARD LVCMOS33} [get_ports o_vsync]

set_property -dict {PACKAGE_PIN T10 IOSTANDARD LVCMOS33} [get_ports {o_vga_red[3]}]
set_property -dict {PACKAGE_PIN T11 IOSTANDARD LVCMOS33} [get_ports {o_vga_red[2]}]
set_property -dict {PACKAGE_PIN W15 IOSTANDARD LVCMOS33} [get_ports {o_vga_red[1]}]
set_property -dict {PACKAGE_PIN V15 IOSTANDARD LVCMOS33} [get_ports {o_vga_red[0]}]

set_property -dict {PACKAGE_PIN R14 IOSTANDARD LVCMOS33} [get_ports {o_vga_green[3]}]
set_property -dict {PACKAGE_PIN P14 IOSTANDARD LVCMOS33} [get_ports {o_vga_green[2]}]
set_property -dict {PACKAGE_PIN T15 IOSTANDARD LVCMOS33} [get_ports {o_vga_green[1]}]
set_property -dict {PACKAGE_PIN T14 IOSTANDARD LVCMOS33} [get_ports {o_vga_green[0]}]

set_property -dict {PACKAGE_PIN U12 IOSTANDARD LVCMOS33} [get_ports {o_vga_blue[3]}]
set_property -dict {PACKAGE_PIN T12 IOSTANDARD LVCMOS33} [get_ports {o_vga_blue[2]}]
set_property -dict {PACKAGE_PIN Y14 IOSTANDARD LVCMOS33} [get_ports {o_vga_blue[1]}]
set_property -dict {PACKAGE_PIN W14 IOSTANDARD LVCMOS33} [get_ports {o_vga_blue[0]}]

## ----------------------------------------------------------------------------
## PS/2 KEYBOARD
## ----------------------------------------------------------------------------
set_property PACKAGE_PIN V12 [get_ports io_ps2_data]
set_property IOSTANDARD LVCMOS33 [get_ports io_ps2_data]
set_property PULLTYPE PULLUP [get_ports io_ps2_data]

set_property PACKAGE_PIN W16 [get_ports io_ps2_clk]
set_property IOSTANDARD LVCMOS33 [get_ports io_ps2_clk]
set_property PULLTYPE PULLUP [get_ports io_ps2_clk]

## ----------------------------------------------------------------------------
## TIMING EXCEPTIONS FOR ASYNC I/O
## ----------------------------------------------------------------------------
set_false_path -to [get_ports {o_vga_red[*] o_vga_green[*] o_vga_blue[*] o_hsync o_vsync}]
set_false_path -from [get_ports {io_ps2_data io_ps2_clk i_sw_0 i_sw_1}]
