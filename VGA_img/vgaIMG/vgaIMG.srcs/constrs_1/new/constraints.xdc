set_property IOSTANDARD LVCMOS33 [get_ports i_clk]
set_property IOSTANDARD LVCMOS33 [get_ports i_rst]
set_property PACKAGE_PIN K17 [get_ports i_clk]
set_property PACKAGE_PIN T16 [get_ports i_rst]
set_property IOSTANDARD LVCMOS33 [get_ports o_hsync]
set_property IOSTANDARD LVCMOS33 [get_ports o_vsync]
set_property PACKAGE_PIN U14 [get_ports o_hsync]
set_property PACKAGE_PIN U15 [get_ports o_vsync]
set_property IOSTANDARD LVCMOS33 [get_ports {o_vga_blue[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_vga_blue[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_vga_blue[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_vga_blue[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_vga_green[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_vga_green[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_vga_green[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_vga_green[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_vga_red[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_vga_red[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_vga_red[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_vga_red[0]}]
set_property PACKAGE_PIN U12 [get_ports {o_vga_blue[3]}]
set_property PACKAGE_PIN T12 [get_ports {o_vga_blue[2]}]
set_property PACKAGE_PIN Y14 [get_ports {o_vga_blue[1]}]
set_property PACKAGE_PIN W14 [get_ports {o_vga_blue[0]}]
set_property PACKAGE_PIN R14 [get_ports {o_vga_green[3]}]
set_property PACKAGE_PIN P14 [get_ports {o_vga_green[2]}]
set_property PACKAGE_PIN T15 [get_ports {o_vga_green[1]}]
set_property PACKAGE_PIN T14 [get_ports {o_vga_green[0]}]
set_property PACKAGE_PIN T10 [get_ports {o_vga_red[3]}]
set_property PACKAGE_PIN T11 [get_ports {o_vga_red[2]}]
set_property PACKAGE_PIN W15 [get_ports {o_vga_red[1]}]
set_property PACKAGE_PIN V15 [get_ports {o_vga_red[0]}]

create_clock -period 8.000 -name i_clk [get_ports i_clk]

set_false_path -from [get_ports i_rst]

set_output_delay -clock clk_pixel_vga_system_clk_wiz_0_1 \
-max 0 \
[get_ports {o_vga_red[*] o_vga_green[*] o_vga_blue[*] o_hsync o_vsync}]

set_output_delay -clock clk_pixel_vga_system_clk_wiz_0_1 \
-min 0 -add_delay \
[get_ports {o_vga_red[*] o_vga_green[*] o_vga_blue[*] o_hsync o_vsync}]
                             
