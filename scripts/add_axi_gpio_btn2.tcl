# add_axi_gpio_btn2.tcl
# Run in the Vivado TCL console with the processor project already open:
#   source scripts/add_axi_gpio_btn2.tcl
#
# What this does:
#   1. Adds axi_gpio_0 (1-bit input + interrupt)
#   2. Expands smartconnect_1 to route GP0 → AXI GPIO
#   3. Creates external port btn2_i (wired to i_par_i[2] in m_soc.v)
#   4. Routes ip2intc_irpt to PS7 IRQ_F2P[0]
#   5. Assigns base address 0x41200000

open_bd_design [get_files design_1.bd]

# ── 1. Add AXI GPIO IP ───────────────────────────────────────────────────────
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_0
set_property -dict {
    CONFIG.C_GPIO_WIDTH        {1}
    CONFIG.C_ALL_INPUTS        {1}
    CONFIG.C_INTERRUPT_PRESENT {1}
} [get_bd_cells axi_gpio_0]

# ── 2. External input port for BTN2 ─────────────────────────────────────────
create_bd_port -dir I btn2_i
connect_bd_net [get_bd_ports btn2_i] [get_bd_pins axi_gpio_0/GPIO_IO_I]

# ── 3. Expand smartconnect_1: 1M → 2M ───────────────────────────────────────
set_property CONFIG.NUM_MI {2} [get_bd_cells smartconnect_1]

# ── 4. Connect AXI GPIO AXI slave ────────────────────────────────────────────
connect_bd_intf_net \
    [get_bd_intf_pins smartconnect_1/M01_AXI] \
    [get_bd_intf_pins axi_gpio_0/S_AXI]

# ── 5. Clock and reset ────────────────────────────────────────────────────────
connect_bd_net \
    [get_bd_pins axi_gpio_0/s_axi_aclk] \
    [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net \
    [get_bd_pins axi_gpio_0/s_axi_aresetn] \
    [get_bd_pins proc_sys_reset_0/peripheral_aresetn]

# ── 6. Enable PS7 fabric interrupts and wire IRQ_F2P[0] ─────────────────────
set_property CONFIG.PCW_USE_FABRIC_INTERRUPT {1} [get_bd_cells processing_system7_0]
set_property CONFIG.PCW_IRQ_F2P_INTR         {1} [get_bd_cells processing_system7_0]
connect_bd_net \
    [get_bd_pins axi_gpio_0/ip2intc_irpt] \
    [get_bd_pins processing_system7_0/IRQ_F2P]

# ── 7. Assign and fix base address 0x41200000 / 64 KB ────────────────────────
assign_bd_address [get_bd_addr_segs {axi_gpio_0/S_AXI/Reg}]
set_property offset 0x41200000 \
    [get_bd_addr_segs {processing_system7_0/Data/SEG_axi_gpio_0_Reg}]
set_property range  64K \
    [get_bd_addr_segs {processing_system7_0/Data/SEG_axi_gpio_0_Reg}]

# ── 8. Validate and save ─────────────────────────────────────────────────────
validate_bd_design
save_bd_design

puts ""
puts "========================================================="
puts " AXI GPIO added successfully."
puts "  Base address : 0x41200000"
puts "  BTN2 port    : btn2_i  (connect to i_par_i[2] in m_soc.v)"
puts "  IRQ          : IRQ_F2P[0]"
puts ""
puts " Next steps:"
puts "  1. Generate Output Products (right-click design_1 in Sources)"
puts "  2. Generate HDL Wrapper (right-click design_1 in Sources)"
puts "  3. Run Synthesis and Implementation"
puts "  4. Export hardware (.xsa) and bitstream"
puts "========================================================="
