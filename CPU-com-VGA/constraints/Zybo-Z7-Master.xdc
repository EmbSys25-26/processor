## ----------------------------------------------------------------------------
## CLOCK & RESET
## ----------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN K17 IOSTANDARD LVCMOS33} [get_ports i_clk]
create_clock -period 8.000 -name i_clk [get_ports i_clk]

set_property -dict {PACKAGE_PIN T16 IOSTANDARD LVCMOS33} [get_ports i_rst]
set_false_path -from [get_ports i_rst]

## ----------------------------------------------------------------------------
## SWITCHES & BUTTONS
## ----------------------------------------------------------------------------

##SWITCHES -> i_sw[1:0] (P15 = SW1, G15 = SW0)

set_property -dict {PACKAGE_PIN P15 IOSTANDARD LVCMOS33} [get_ports {i_sw_1}]
set_property -dict {PACKAGE_PIN G15 IOSTANDARD LVCMOS33} [get_ports {i_sw_0}]

## Buttons -> i_par_i[3:0]
set_property -dict {PACKAGE_PIN K18 IOSTANDARD LVCMOS33} [get_ports {i_par_i[0]}]
set_property -dict {PACKAGE_PIN P16 IOSTANDARD LVCMOS33} [get_ports {i_par_i[1]}]
set_property -dict {PACKAGE_PIN K19 IOSTANDARD LVCMOS33} [get_ports {i_par_i[2]}]
set_property -dict {PACKAGE_PIN Y16 IOSTANDARD LVCMOS33} [get_ports {i_par_i[3]}]

## ----------------------------------------------------------------------------
## LEDS -> o_par_o[3:0]
## ----------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN M14 IOSTANDARD LVCMOS33} [get_ports {o_par_o[0]}]
set_property -dict {PACKAGE_PIN M15 IOSTANDARD LVCMOS33} [get_ports {o_par_o[1]}]
set_property -dict {PACKAGE_PIN G14 IOSTANDARD LVCMOS33} [get_ports {o_par_o[2]}]
set_property -dict {PACKAGE_PIN D18 IOSTANDARD LVCMOS33} [get_ports {o_par_o[3]}]

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

## VGA Timing (Ajusta o nome do clock se necessário)
#set_output_delay -clock [get_clocks -of_objects [get_pins clk_wiz_0/clk_out1]] -max 0.000 [get_ports {{o_vga_red[*]} {o_vga_green[*]} {o_vga_blue[*]} o_hsync o_vsync}]
#set_output_delay -clock [get_clocks -of_objects [get_pins clk_wiz_0/clk_out1]] -min -add_delay 0.000 [get_ports {{o_vga_red[*]} {o_vga_green[*]} {o_vga_blue[*]} o_hsync o_vsync}]

## ----------------------------------------------------------------------------
## PERIPHERALS (UART, PS2 & I2C)
## ----------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN N15 IOSTANDARD LVCMOS33} [get_ports o_uart_tx]
set_property -dict {PACKAGE_PIN L14 IOSTANDARD LVCMOS33} [get_ports i_uart_rx]

set_property PACKAGE_PIN V12 [get_ports io_ps2_data]
set_property IOSTANDARD LVCMOS33 [get_ports io_ps2_data]
set_property PULLTYPE PULLUP [get_ports io_ps2_data]
set_property PACKAGE_PIN W16 [get_ports io_ps2_clk]
set_property IOSTANDARD LVCMOS33 [get_ports io_ps2_clk]
set_property PULLTYPE PULLUP [get_ports io_ps2_clk]

set_property PACKAGE_PIN K16 [get_ports io_i2c_sda]
set_property IOSTANDARD LVCMOS33 [get_ports io_i2c_sda]
set_property PULLTYPE PULLUP [get_ports io_i2c_sda]
set_property PACKAGE_PIN K14 [get_ports io_i2c_scl]
set_property IOSTANDARD LVCMOS33 [get_ports io_i2c_scl]
set_property PULLTYPE PULLUP [get_ports io_i2c_scl]

# CPU ILA - clocked by system clock (clk_gen output1 = 50MHz)

# PC - program counter

# Current instruction

# Data address bus

# IRQ signals








create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list _clkVGA]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 9 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {u_periph/u_vga/_lineCounter[0]} {u_periph/u_vga/_lineCounter[1]} {u_periph/u_vga/_lineCounter[2]} {u_periph/u_vga/_lineCounter[3]} {u_periph/u_vga/_lineCounter[4]} {u_periph/u_vga/_lineCounter[5]} {u_periph/u_vga/_lineCounter[6]} {u_periph/u_vga/_lineCounter[7]} {u_periph/u_vga/_lineCounter[8]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 16 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {u_periph/u_vga/_axis_tdata[0]} {u_periph/u_vga/_axis_tdata[1]} {u_periph/u_vga/_axis_tdata[2]} {u_periph/u_vga/_axis_tdata[3]} {u_periph/u_vga/_axis_tdata[4]} {u_periph/u_vga/_axis_tdata[5]} {u_periph/u_vga/_axis_tdata[6]} {u_periph/u_vga/_axis_tdata[7]} {u_periph/u_vga/_axis_tdata[8]} {u_periph/u_vga/_axis_tdata[9]} {u_periph/u_vga/_axis_tdata[10]} {u_periph/u_vga/_axis_tdata[11]} {u_periph/u_vga/_axis_tdata[12]} {u_periph/u_vga/_axis_tdata[13]} {u_periph/u_vga/_axis_tdata[14]} {u_periph/u_vga/_axis_tdata[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 10 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {u_periph/u_vga/_pixelCounter[0]} {u_periph/u_vga/_pixelCounter[1]} {u_periph/u_vga/_pixelCounter[2]} {u_periph/u_vga/_pixelCounter[3]} {u_periph/u_vga/_pixelCounter[4]} {u_periph/u_vga/_pixelCounter[5]} {u_periph/u_vga/_pixelCounter[6]} {u_periph/u_vga/_pixelCounter[7]} {u_periph/u_vga/_pixelCounter[8]} {u_periph/u_vga/_pixelCounter[9]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 3 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {u_periph/u_vga/vsync_module/_state[0]} {u_periph/u_vga/vsync_module/_state[1]} {u_periph/u_vga/vsync_module/_state[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 2 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {u_periph/u_vga/hsync_module/_state[0]} {u_periph/u_vga/hsync_module/_state[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 1 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list u_periph/u_vga/_endLine]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 1 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list u_periph/u_vga/hsync_module/_hsync_i_1_n_0]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 1 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list u_periph/u_vga/vsync_module/_vsync_i_1_n_0]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 1 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list u_periph/u_vga/_axis_tlast]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 1 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list u_periph/u_vga/_axis_tready]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 1 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list u_periph/u_vga/_axis_tuser]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 1 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list u_periph/u_vga/_axis_tvalid]]
create_debug_core u_ila_1 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_1]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_1]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_1]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_1]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_1]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_1]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_1]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_1]
set_property port_width 1 [get_debug_ports u_ila_1/clk]
connect_debug_port u_ila_1/clk [get_nets [list clk_gen/inst/clk_out1]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe0]
set_property port_width 16 [get_debug_ports u_ila_1/probe0]
connect_debug_port u_ila_1/probe0 [get_nets [list {_PC[0]} {_PC[1]} {_PC[2]} {_PC[3]} {_PC[4]} {_PC[5]} {_PC[6]} {_PC[7]} {_PC[8]} {_PC[9]} {_PC[10]} {_PC[11]} {_PC[12]} {_PC[13]} {_PC[14]} {_PC[15]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe1]
set_property port_width 16 [get_debug_ports u_ila_1/probe1]
connect_debug_port u_ila_1/probe1 [get_nets [list {_insn_q[0]} {_insn_q[1]} {_insn_q[2]} {_insn_q[3]} {_insn_q[4]} {_insn_q[5]} {_insn_q[6]} {_insn_q[7]} {_insn_q[8]} {_insn_q[9]} {_insn_q[10]} {_insn_q[11]} {_insn_q[12]} {_insn_q[13]} {_insn_q[14]} {_insn_q[15]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe2]
set_property port_width 16 [get_debug_ports u_ila_1/probe2]
connect_debug_port u_ila_1/probe2 [get_nets [list {_d_ad[0]} {_d_ad[1]} {_d_ad[2]} {_d_ad[3]} {_d_ad[4]} {_d_ad[5]} {_d_ad[6]} {_d_ad[7]} {_d_ad[8]} {_d_ad[9]} {_d_ad[10]} {_d_ad[11]} {_d_ad[12]} {_d_ad[13]} {_d_ad[14]} {_d_ad[15]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe3]
set_property port_width 16 [get_debug_ports u_ila_1/probe3]
connect_debug_port u_ila_1/probe3 [get_nets [list {_irq_vector[0]} {_irq_vector[1]} {_irq_vector[2]} {_irq_vector[3]} {_irq_vector[4]} {_irq_vector[5]} {_irq_vector[6]} {_irq_vector[7]} {_irq_vector[8]} {_irq_vector[9]} {_irq_vector[10]} {_irq_vector[11]} {_irq_vector[12]} {_irq_vector[13]} {_irq_vector[14]} {_irq_vector[15]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe4]
set_property port_width 1 [get_debug_ports u_ila_1/probe4]
connect_debug_port u_ila_1/probe4 [get_nets [list _irq_take]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe5]
set_property port_width 1 [get_debug_ports u_ila_1/probe5]
connect_debug_port u_ila_1/probe5 [get_nets [list _in_irq]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe6]
set_property port_width 1 [get_debug_ports u_ila_1/probe6]
connect_debug_port u_ila_1/probe6 [get_nets [list _insn_ce]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe7]
set_property port_width 1 [get_debug_ports u_ila_1/probe7]
connect_debug_port u_ila_1/probe7 [get_nets [list _io_sel]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe8]
set_property port_width 1 [get_debug_ports u_ila_1/probe8]
connect_debug_port u_ila_1/probe8 [get_nets [list _io_we]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe9]
set_property port_width 1 [get_debug_ports u_ila_1/probe9]
connect_debug_port u_ila_1/probe9 [get_nets [list _int_en_cpu]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk_gen/inst/clk_out1]
