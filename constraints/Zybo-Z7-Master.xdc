set_property -dict {PACKAGE_PIN K17 IOSTANDARD LVCMOS33} [get_ports i_clk]
set_property -dict {PACKAGE_PIN G15 IOSTANDARD LVCMOS33} [get_ports i_rst]
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
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports i_clk]

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
