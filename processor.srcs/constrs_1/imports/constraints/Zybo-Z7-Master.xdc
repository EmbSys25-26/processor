## Zybo Z7-10 constraints

## Clock externo 125 MHz - usado APENAS pelo Clock Wizard para gerar 12.288 MHz
## O sistema (CPU, DMA, perifericos) usa o FCLK_CLK0 do Zynq PS (100 MHz)
set_property -dict { PACKAGE_PIN K17 IOSTANDARD LVCMOS33 } [get_ports { i_clk }];
create_clock -add -name sys_clk_pin -period 8.00 -waveform {0 4} [get_ports { i_clk }];

## Reset (Switch)
set_property -dict { PACKAGE_PIN G15 IOSTANDARD LVCMOS33 } [get_ports { i_rst }];

## Buttons -> i_par_i[3:0]
set_property -dict { PACKAGE_PIN K18 IOSTANDARD LVCMOS33 } [get_ports { i_par_i[0] }];
set_property -dict { PACKAGE_PIN P16 IOSTANDARD LVCMOS33 } [get_ports { i_par_i[1] }];
set_property -dict { PACKAGE_PIN K19 IOSTANDARD LVCMOS33 } [get_ports { i_par_i[2] }];
set_property -dict { PACKAGE_PIN Y16 IOSTANDARD LVCMOS33 } [get_ports { i_par_i[3] }];

## LEDs -> o_par_o[3:0]
set_property -dict { PACKAGE_PIN M14 IOSTANDARD LVCMOS33 } [get_ports { o_par_o[0] }];
set_property -dict { PACKAGE_PIN M15 IOSTANDARD LVCMOS33 } [get_ports { o_par_o[1] }];
set_property -dict { PACKAGE_PIN G14 IOSTANDARD LVCMOS33 } [get_ports { o_par_o[2] }];
set_property -dict { PACKAGE_PIN D18 IOSTANDARD LVCMOS33 } [get_ports { o_par_o[3] }];

## UART
set_property -dict { PACKAGE_PIN N15 IOSTANDARD LVCMOS33 } [get_ports { o_uart_tx }];
set_property -dict { PACKAGE_PIN L14 IOSTANDARD LVCMOS33 } [get_ports { i_uart_rx }];

## I2C (PL)
set_property -dict { PACKAGE_PIN K16 IOSTANDARD LVCMOS33 PULLUP true } [get_ports { io_i2c_sda }];
set_property -dict { PACKAGE_PIN K14 IOSTANDARD LVCMOS33 PULLUP true } [get_ports { io_i2c_scl }];

## Audio Codec SSM2603
set_property -dict { PACKAGE_PIN R19   IOSTANDARD LVCMOS33 } [get_ports { o_i2s_mclk }];
set_property -dict { PACKAGE_PIN R17   IOSTANDARD LVCMOS33 } [get_ports { o_i2s_bclk }];
set_property -dict { PACKAGE_PIN P18   IOSTANDARD LVCMOS33 } [get_ports { o_i2s_mute }];
set_property -dict { PACKAGE_PIN R18   IOSTANDARD LVCMOS33 } [get_ports { o_i2s_pbdat }];
set_property -dict { PACKAGE_PIN T19   IOSTANDARD LVCMOS33 } [get_ports { o_i2s_lrclk }];

## I2C do Codec SSM2603
set_property -dict { PACKAGE_PIN N18   IOSTANDARD LVCMOS33 } [get_ports { io_i2s_scl }];
set_property -dict { PACKAGE_PIN N17   IOSTANDARD LVCMOS33 } [get_ports { io_i2s_sda }];