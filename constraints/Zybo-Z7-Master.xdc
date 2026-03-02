## This file is a .xdc for the Zybo Z7-10
## Clock signal. Currently @ 50MHz. Change accordingly.
set_property -dict {PACKAGE_PIN K17 IOSTANDARD LVCMOS33} [get_ports i_clk]
create_clock -period 20.000 -name sys_clk_pin -waveform {0.000 10.000} -add [get_ports i_clkk]

## Switches
set_property -dict {PACKAGE_PIN G15 IOSTANDARD LVCMOS33} [get_ports i_rst]

## Buttons -> i_par_i[3:0]
set_property -dict {PACKAGE_PIN K18 IOSTANDARD LVCMOS33} [get_ports {i_par_i[0]}]
set_property -dict {PACKAGE_PIN P16 IOSTANDARD LVCMOS33} [get_ports {i_par_i[1]}]
set_property -dict {PACKAGE_PIN K19 IOSTANDARD LVCMOS33} [get_ports {i_par_i[2]}]
set_property -dict {PACKAGE_PIN Y16 IOSTANDARD LVCMOS33} [get_ports {i_par_i[3]}]

## LEDs -> o_par_o[3:0]
set_property -dict {PACKAGE_PIN M14 IOSTANDARD LVCMOS33} [get_ports {o_par_o[0]}]
set_property -dict {PACKAGE_PIN M15 IOSTANDARD LVCMOS33} [get_ports {o_par_o[1]}]
set_property -dict {PACKAGE_PIN G14 IOSTANDARD LVCMOS33} [get_ports {o_par_o[2]}]
set_property -dict {PACKAGE_PIN D18 IOSTANDARD LVCMOS33} [get_ports {o_par_o[3]}]

## UART (PL) on PMOD JA
set_property -dict {PACKAGE_PIN N15 IOSTANDARD LVCMOS33} [get_ports o_uart_tx]
set_property -dict {PACKAGE_PIN L14 IOSTANDARD LVCMOS33} [get_ports i_uart_rx]

## I2C (PL) on remaining PMOD JA pins (open-drain, pull-up enabled).
## NOTE: external pull-ups are still recommended for robust I2C signaling.
set_property PACKAGE_PIN K16 [get_ports io_i2c_sda]
set_property IOSTANDARD LVCMOS33 [get_ports io_i2c_sda]
set_property PULLTYPE PULLUP [get_ports io_i2c_sda]
set_property PACKAGE_PIN K14 [get_ports io_i2c_scl]
set_property IOSTANDARD LVCMOS33 [get_ports io_i2c_scl]
set_property PULLTYPE PULLUP [get_ports io_i2c_scl]

## PS2 on PMOD JC (Top Row - Pins 1 and 2)
set_property PACKAGE_PIN V15 [get_ports io_ps2_data]
set_property IOSTANDARD LVCMOS33 [get_ports io_ps2_data]
set_property PULLTYPE PULLUP [get_ports io_ps2_data]
set_property PACKAGE_PIN W15 [get_ports io_ps2_clk]
set_property IOSTANDARD LVCMOS33 [get_ports io_ps2_clk]
set_property PULLTYPE PULLUP [get_ports io_ps2_clk]



connect_debug_port u_ila_0/probe0 [get_nets [list {u_periph/u_ps2/u_ps2_d2h/_shift_0[0]} {u_periph/u_ps2/u_ps2_d2h/_shift_0[1]} {u_periph/u_ps2/u_ps2_d2h/_shift_0[2]} {u_periph/u_ps2/u_ps2_d2h/_shift_0[3]} {u_periph/u_ps2/u_ps2_d2h/_shift_0[4]} {u_periph/u_ps2/u_ps2_d2h/_shift_0[5]} {u_periph/u_ps2/u_ps2_d2h/_shift_0[6]} {u_periph/u_ps2/u_ps2_d2h/_shift_0[7]}]]









