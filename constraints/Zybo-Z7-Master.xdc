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
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports i_clk]
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
set_false_path -to [get_ports io_i2c_sda]

## ----------------------------------------------------------------------------
## SYSTEM RESET
## ----------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN T16 IOSTANDARD LVCMOS33} [get_ports i_rst]

## ----------------------------------------------------------------------------
## VGA MODE SWITCHES (From VGA Project)
## i_sw_1 -> P15 (SW1) | i_sw_0 -> G15 (SW0)
## ----------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN P15 IOSTANDARD LVCMOS33} [get_ports i_sw_1]
set_property -dict {PACKAGE_PIN G15 IOSTANDARD LVCMOS33} [get_ports i_sw_0]

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
set_false_path -to [get_ports {{o_vga_red[*]} {o_vga_green[*]} {o_vga_blue[*]} o_hsync o_vsync}]
set_false_path -from [get_ports {io_ps2_data io_ps2_clk i_sw_0 i_sw_1}]

create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 2048 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list clk_gen/inst/clk_out2]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 16 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {u_periph/u_vga/_axis_tdata[0]} {u_periph/u_vga/_axis_tdata[1]} {u_periph/u_vga/_axis_tdata[2]} {u_periph/u_vga/_axis_tdata[3]} {u_periph/u_vga/_axis_tdata[4]} {u_periph/u_vga/_axis_tdata[5]} {u_periph/u_vga/_axis_tdata[6]} {u_periph/u_vga/_axis_tdata[7]} {u_periph/u_vga/_axis_tdata[8]} {u_periph/u_vga/_axis_tdata[9]} {u_periph/u_vga/_axis_tdata[10]} {u_periph/u_vga/_axis_tdata[11]} {u_periph/u_vga/_axis_tdata[12]} {u_periph/u_vga/_axis_tdata[13]} {u_periph/u_vga/_axis_tdata[14]} {u_periph/u_vga/_axis_tdata[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 9 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {u_periph/u_vga/vsync_module/_lineCounter[0]} {u_periph/u_vga/vsync_module/_lineCounter[1]} {u_periph/u_vga/vsync_module/_lineCounter[2]} {u_periph/u_vga/vsync_module/_lineCounter[3]} {u_periph/u_vga/vsync_module/_lineCounter[4]} {u_periph/u_vga/vsync_module/_lineCounter[5]} {u_periph/u_vga/vsync_module/_lineCounter[6]} {u_periph/u_vga/vsync_module/_lineCounter[7]} {u_periph/u_vga/vsync_module/_lineCounter[8]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 3 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {u_periph/u_vga/vsync_module/_state[0]} {u_periph/u_vga/vsync_module/_state[1]} {u_periph/u_vga/vsync_module/_state[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 2 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {u_periph/u_vga/hsync_module/_state[0]} {u_periph/u_vga/hsync_module/_state[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 10 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {u_periph/u_vga/hsync_module/_pixelCounter[0]} {u_periph/u_vga/hsync_module/_pixelCounter[1]} {u_periph/u_vga/hsync_module/_pixelCounter[2]} {u_periph/u_vga/hsync_module/_pixelCounter[3]} {u_periph/u_vga/hsync_module/_pixelCounter[4]} {u_periph/u_vga/hsync_module/_pixelCounter[5]} {u_periph/u_vga/hsync_module/_pixelCounter[6]} {u_periph/u_vga/hsync_module/_pixelCounter[7]} {u_periph/u_vga/hsync_module/_pixelCounter[8]} {u_periph/u_vga/hsync_module/_pixelCounter[9]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 1 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list u_periph/u_vga/_axis_tlast]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 1 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list u_periph/u_vga/_axis_tready]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 1 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list u_periph/u_vga/_axis_tuser]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 1 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list u_periph/u_vga/_axis_tvalid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 1 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list u_periph/u_vga/hsync_module/_endLine]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 1 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list u_periph/u_vga/hsync_module/_hsync]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 1 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list u_periph/u_vga/vsync_module/_vsync]]
create_debug_core u_ila_1 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_1]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_1]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_1]
set_property C_DATA_DEPTH 2048 [get_debug_cores u_ila_1]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_1]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_1]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_1]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_1]
set_property port_width 1 [get_debug_ports u_ila_1/clk]
connect_debug_port u_ila_1/clk [get_nets [list clk_gen/inst/clk_out1]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe0]
set_property port_width 8 [get_debug_ports u_ila_1/probe0]
connect_debug_port u_ila_1/probe0 [get_nets [list {u_periph/u_ps2/_rxd[0]} {u_periph/u_ps2/_rxd[1]} {u_periph/u_ps2/_rxd[2]} {u_periph/u_ps2/_rxd[3]} {u_periph/u_ps2/_rxd[4]} {u_periph/u_ps2/_rxd[5]} {u_periph/u_ps2/_rxd[6]} {u_periph/u_ps2/_rxd[7]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe1]
set_property port_width 8 [get_debug_ports u_ila_1/probe1]
connect_debug_port u_ila_1/probe1 [get_nets [list {u_periph/u_ps2/u_ps2_d2h/_shift[0]} {u_periph/u_ps2/u_ps2_d2h/_shift[1]} {u_periph/u_ps2/u_ps2_d2h/_shift[2]} {u_periph/u_ps2/u_ps2_d2h/_shift[3]} {u_periph/u_ps2/u_ps2_d2h/_shift[4]} {u_periph/u_ps2/u_ps2_d2h/_shift[5]} {u_periph/u_ps2/u_ps2_d2h/_shift[6]} {u_periph/u_ps2/u_ps2_d2h/_shift[7]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe2]
set_property port_width 8 [get_debug_ports u_ila_1/probe2]
connect_debug_port u_ila_1/probe2 [get_nets [list {u_periph/u_ps2/u_ps2_d2h/o_rx_data[0]} {u_periph/u_ps2/u_ps2_d2h/o_rx_data[1]} {u_periph/u_ps2/u_ps2_d2h/o_rx_data[2]} {u_periph/u_ps2/u_ps2_d2h/o_rx_data[3]} {u_periph/u_ps2/u_ps2_d2h/o_rx_data[4]} {u_periph/u_ps2/u_ps2_d2h/o_rx_data[5]} {u_periph/u_ps2/u_ps2_d2h/o_rx_data[6]} {u_periph/u_ps2/u_ps2_d2h/o_rx_data[7]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe3]
set_property port_width 16 [get_debug_ports u_ila_1/probe3]
connect_debug_port u_ila_1/probe3 [get_nets [list {u_periph/u_ps2/_rdata[0]} {u_periph/u_ps2/_rdata[1]} {u_periph/u_ps2/_rdata[2]} {u_periph/u_ps2/_rdata[3]} {u_periph/u_ps2/_rdata[4]} {u_periph/u_ps2/_rdata[5]} {u_periph/u_ps2/_rdata[6]} {u_periph/u_ps2/_rdata[7]} {u_periph/u_ps2/_rdata[8]} {u_periph/u_ps2/_rdata[9]} {u_periph/u_ps2/_rdata[10]} {u_periph/u_ps2/_rdata[11]} {u_periph/u_ps2/_rdata[12]} {u_periph/u_ps2/_rdata[13]} {u_periph/u_ps2/_rdata[14]} {u_periph/u_ps2/_rdata[15]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe4]
set_property port_width 16 [get_debug_ports u_ila_1/probe4]
connect_debug_port u_ila_1/probe4 [get_nets [list {_cpu_do[0]} {_cpu_do[1]} {_cpu_do[2]} {_cpu_do[3]} {_cpu_do[4]} {_cpu_do[5]} {_cpu_do[6]} {_cpu_do[7]} {_cpu_do[8]} {_cpu_do[9]} {_cpu_do[10]} {_cpu_do[11]} {_cpu_do[12]} {_cpu_do[13]} {_cpu_do[14]} {_cpu_do[15]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe5]
set_property port_width 16 [get_debug_ports u_ila_1/probe5]
connect_debug_port u_ila_1/probe5 [get_nets [list {_d_ad[0]} {_d_ad[1]} {_d_ad[2]} {_d_ad[3]} {_d_ad[4]} {_d_ad[5]} {_d_ad[6]} {_d_ad[7]} {_d_ad[8]} {_d_ad[9]} {_d_ad[10]} {_d_ad[11]} {_d_ad[12]} {_d_ad[13]} {_d_ad[14]} {_d_ad[15]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe6]
set_property port_width 16 [get_debug_ports u_ila_1/probe6]
connect_debug_port u_ila_1/probe6 [get_nets [list {_PC[0]} {_PC[1]} {_PC[2]} {_PC[3]} {_PC[4]} {_PC[5]} {_PC[6]} {_PC[7]} {_PC[8]} {_PC[9]} {_PC[10]} {_PC[11]} {_PC[12]} {_PC[13]} {_PC[14]} {_PC[15]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe7]
set_property port_width 2 [get_debug_ports u_ila_1/probe7]
connect_debug_port u_ila_1/probe7 [get_nets [list {u_cpu/u_if_stage/_flush_bubble[0]} {u_cpu/u_if_stage/_flush_bubble[1]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe8]
set_property port_width 16 [get_debug_ports u_ila_1/probe8]
connect_debug_port u_ila_1/probe8 [get_nets [list {u_cpu/u_pipe_if_id/o_insn[0]} {u_cpu/u_pipe_if_id/o_insn[1]} {u_cpu/u_pipe_if_id/o_insn[2]} {u_cpu/u_pipe_if_id/o_insn[3]} {u_cpu/u_pipe_if_id/o_insn[4]} {u_cpu/u_pipe_if_id/o_insn[5]} {u_cpu/u_pipe_if_id/o_insn[6]} {u_cpu/u_pipe_if_id/o_insn[7]} {u_cpu/u_pipe_if_id/o_insn[8]} {u_cpu/u_pipe_if_id/o_insn[9]} {u_cpu/u_pipe_if_id/o_insn[10]} {u_cpu/u_pipe_if_id/o_insn[11]} {u_cpu/u_pipe_if_id/o_insn[12]} {u_cpu/u_pipe_if_id/o_insn[13]} {u_cpu/u_pipe_if_id/o_insn[14]} {u_cpu/u_pipe_if_id/o_insn[15]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe9]
set_property port_width 16 [get_debug_ports u_ila_1/probe9]
connect_debug_port u_ila_1/probe9 [get_nets [list {u_cpu/u_pipe_if_id/i_insn[0]} {u_cpu/u_pipe_if_id/i_insn[1]} {u_cpu/u_pipe_if_id/i_insn[2]} {u_cpu/u_pipe_if_id/i_insn[3]} {u_cpu/u_pipe_if_id/i_insn[4]} {u_cpu/u_pipe_if_id/i_insn[5]} {u_cpu/u_pipe_if_id/i_insn[6]} {u_cpu/u_pipe_if_id/i_insn[7]} {u_cpu/u_pipe_if_id/i_insn[8]} {u_cpu/u_pipe_if_id/i_insn[9]} {u_cpu/u_pipe_if_id/i_insn[10]} {u_cpu/u_pipe_if_id/i_insn[11]} {u_cpu/u_pipe_if_id/i_insn[12]} {u_cpu/u_pipe_if_id/i_insn[13]} {u_cpu/u_pipe_if_id/i_insn[14]} {u_cpu/u_pipe_if_id/i_insn[15]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe10]
set_property port_width 16 [get_debug_ports u_ila_1/probe10]
connect_debug_port u_ila_1/probe10 [get_nets [list {u_cpu/u_pipe_if_id/o_pc[0]} {u_cpu/u_pipe_if_id/o_pc[1]} {u_cpu/u_pipe_if_id/o_pc[2]} {u_cpu/u_pipe_if_id/o_pc[3]} {u_cpu/u_pipe_if_id/o_pc[4]} {u_cpu/u_pipe_if_id/o_pc[5]} {u_cpu/u_pipe_if_id/o_pc[6]} {u_cpu/u_pipe_if_id/o_pc[7]} {u_cpu/u_pipe_if_id/o_pc[8]} {u_cpu/u_pipe_if_id/o_pc[9]} {u_cpu/u_pipe_if_id/o_pc[10]} {u_cpu/u_pipe_if_id/o_pc[11]} {u_cpu/u_pipe_if_id/o_pc[12]} {u_cpu/u_pipe_if_id/o_pc[13]} {u_cpu/u_pipe_if_id/o_pc[14]} {u_cpu/u_pipe_if_id/o_pc[15]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe11]
set_property port_width 16 [get_debug_ports u_ila_1/probe11]
connect_debug_port u_ila_1/probe11 [get_nets [list {u_cpu/u_pipe_if_id/i_pc[0]} {u_cpu/u_pipe_if_id/i_pc[1]} {u_cpu/u_pipe_if_id/i_pc[2]} {u_cpu/u_pipe_if_id/i_pc[3]} {u_cpu/u_pipe_if_id/i_pc[4]} {u_cpu/u_pipe_if_id/i_pc[5]} {u_cpu/u_pipe_if_id/i_pc[6]} {u_cpu/u_pipe_if_id/i_pc[7]} {u_cpu/u_pipe_if_id/i_pc[8]} {u_cpu/u_pipe_if_id/i_pc[9]} {u_cpu/u_pipe_if_id/i_pc[10]} {u_cpu/u_pipe_if_id/i_pc[11]} {u_cpu/u_pipe_if_id/i_pc[12]} {u_cpu/u_pipe_if_id/i_pc[13]} {u_cpu/u_pipe_if_id/i_pc[14]} {u_cpu/u_pipe_if_id/i_pc[15]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe12]
set_property port_width 16 [get_debug_ports u_ila_1/probe12]
connect_debug_port u_ila_1/probe12 [get_nets [list {u_cpu/u_regfile/_t2[0]} {u_cpu/u_regfile/_t2[1]} {u_cpu/u_regfile/_t2[2]} {u_cpu/u_regfile/_t2[3]} {u_cpu/u_regfile/_t2[4]} {u_cpu/u_regfile/_t2[5]} {u_cpu/u_regfile/_t2[6]} {u_cpu/u_regfile/_t2[7]} {u_cpu/u_regfile/_t2[8]} {u_cpu/u_regfile/_t2[9]} {u_cpu/u_regfile/_t2[10]} {u_cpu/u_regfile/_t2[11]} {u_cpu/u_regfile/_t2[12]} {u_cpu/u_regfile/_t2[13]} {u_cpu/u_regfile/_t2[14]} {u_cpu/u_regfile/_t2[15]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe13]
set_property port_width 1 [get_debug_ports u_ila_1/probe13]
connect_debug_port u_ila_1/probe13 [get_nets [list _io_sel]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe14]
set_property port_width 1 [get_debug_ports u_ila_1/probe14]
connect_debug_port u_ila_1/probe14 [get_nets [list _io_we]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe15]
set_property port_width 1 [get_debug_ports u_ila_1/probe15]
connect_debug_port u_ila_1/probe15 [get_nets [list _sw]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe16]
set_property port_width 1 [get_debug_ports u_ila_1/probe16]
connect_debug_port u_ila_1/probe16 [get_nets [list _total_rst]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe17]
set_property port_width 1 [get_debug_ports u_ila_1/probe17]
connect_debug_port u_ila_1/probe17 [get_nets [list u_periph/u_ps2/i_re]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets i_clkk]
