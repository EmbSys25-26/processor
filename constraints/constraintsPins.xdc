set_property PACKAGE_PIN K17 [get_ports i_clk]
set_property PACKAGE_PIN T16 [get_ports i_rst]
set_property PACKAGE_PIN P15 [get_ports {i_imgSel[1]}]
set_property PACKAGE_PIN W13 [get_ports {i_imgSel[2]}]
set_property PACKAGE_PIN G15 [get_ports {i_imgSel[0]}]
set_property PACKAGE_PIN T14 [get_ports {o_vga_green[0]}]
set_property PACKAGE_PIN T15 [get_ports {o_vga_green[1]}]
set_property PACKAGE_PIN P14 [get_ports {o_vga_green[2]}]
set_property PACKAGE_PIN R14 [get_ports {o_vga_green[3]}]
set_property PACKAGE_PIN W14 [get_ports {o_vga_blue[0]}]
set_property PACKAGE_PIN Y14 [get_ports {o_vga_blue[1]}]
set_property PACKAGE_PIN T12 [get_ports {o_vga_blue[2]}]
set_property PACKAGE_PIN U12 [get_ports {o_vga_blue[3]}]
set_property PACKAGE_PIN T10 [get_ports {o_vga_red[3]}]
set_property PACKAGE_PIN T11 [get_ports {o_vga_red[2]}]
set_property PACKAGE_PIN W15 [get_ports {o_vga_red[1]}]
set_property PACKAGE_PIN V15 [get_ports {o_vga_red[0]}]
set_property PACKAGE_PIN U14 [get_ports o_hsync]
set_property PACKAGE_PIN U15 [get_ports o_vsync]
set_property IOSTANDARD LVCMOS33 [get_ports {i_imgSel[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {i_imgSel[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {i_imgSel[0]}]
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
set_property IOSTANDARD LVCMOS33 [get_ports i_clk]
set_property IOSTANDARD LVCMOS33 [get_ports i_rst]
set_property IOSTANDARD LVCMOS33 [get_ports o_hsync]
set_property IOSTANDARD LVCMOS33 [get_ports o_vsync]

# Set False Paths for CDC signals

# imgData synchronizer (SrcImg* → _imgData_meta)
set_false_path -from [get_cells {periph_vga/_SrcImg*_reg \
                                  periph_vga/_SrcChar_reg}] \
               -to   [get_cells {periph_vga/_imgData_meta_reg*}]

# enVGA synchronizer
set_false_path -from [get_cells {periph_vga/_enVGA_reg}] \
               -to   [get_cells {periph_vga/_enVGA_meta_reg}]

# rst synchronizer        
set_false_path -from [get_cells {_rst_sync_reg*}] \
               -to   [get_cells {periph_vga/_rst_meta_reg \
                                  periph_vga/_rst_sync_vga_reg}]
                                  
# Input ports - Set No Input Delays (tell Vivado to ignore timing)                                 
set_false_path -from [get_ports {i_imgSel[*] i_rst}]

# Output ports with no external timing requirement  
set_output_delay -clock [get_clocks clk_out2_clk_wiz_0] \
                 -max 0 [get_ports {o_vga_red[*] o_vga_green[*] \
                                    o_vga_blue[*] o_hsync o_vsync}]
set_output_delay -clock [get_clocks clk_out2_clk_wiz_0] \
                 -min 0 [get_ports {o_vga_red[*] o_vga_green[*] \
                                    o_vga_blue[*] o_hsync o_vsync}]