create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 1 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]

# clock
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets i_clk_IBUF_BUFG]

# probe0: r0 (zero)
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 16 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {u_cpu/u_datapath/u_regfile/_r0[0]} {u_cpu/u_datapath/u_regfile/_r0[1]} {u_cpu/u_datapath/u_regfile/_r0[2]} {u_cpu/u_datapath/u_regfile/_r0[3]} {u_cpu/u_datapath/u_regfile/_r0[4]} {u_cpu/u_datapath/u_regfile/_r0[5]} {u_cpu/u_datapath/u_regfile/_r0[6]} {u_cpu/u_datapath/u_regfile/_r0[7]} {u_cpu/u_datapath/u_regfile/_r0[8]} {u_cpu/u_datapath/u_regfile/_r0[9]} {u_cpu/u_datapath/u_regfile/_r0[10]} {u_cpu/u_datapath/u_regfile/_r0[11]} {u_cpu/u_datapath/u_regfile/_r0[12]} {u_cpu/u_datapath/u_regfile/_r0[13]} {u_cpu/u_datapath/u_regfile/_r0[14]} {u_cpu/u_datapath/u_regfile/_r0[15]}]]

# probe1: a0 / v0 (r1)
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 16 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {u_cpu/u_datapath/u_regfile/_a0[0]} {u_cpu/u_datapath/u_regfile/_a0[1]} {u_cpu/u_datapath/u_regfile/_a0[2]} {u_cpu/u_datapath/u_regfile/_a0[3]} {u_cpu/u_datapath/u_regfile/_a0[4]} {u_cpu/u_datapath/u_regfile/_a0[5]} {u_cpu/u_datapath/u_regfile/_a0[6]} {u_cpu/u_datapath/u_regfile/_a0[7]} {u_cpu/u_datapath/u_regfile/_a0[8]} {u_cpu/u_datapath/u_regfile/_a0[9]} {u_cpu/u_datapath/u_regfile/_a0[10]} {u_cpu/u_datapath/u_regfile/_a0[11]} {u_cpu/u_datapath/u_regfile/_a0[12]} {u_cpu/u_datapath/u_regfile/_a0[13]} {u_cpu/u_datapath/u_regfile/_a0[14]} {u_cpu/u_datapath/u_regfile/_a0[15]}]]

# probe2: a1 / v1 (r2)
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 16 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {u_cpu/u_datapath/u_regfile/_a1[0]} {u_cpu/u_datapath/u_regfile/_a1[1]} {u_cpu/u_datapath/u_regfile/_a1[2]} {u_cpu/u_datapath/u_regfile/_a1[3]} {u_cpu/u_datapath/u_regfile/_a1[4]} {u_cpu/u_datapath/u_regfile/_a1[5]} {u_cpu/u_datapath/u_regfile/_a1[6]} {u_cpu/u_datapath/u_regfile/_a1[7]} {u_cpu/u_datapath/u_regfile/_a1[8]} {u_cpu/u_datapath/u_regfile/_a1[9]} {u_cpu/u_datapath/u_regfile/_a1[10]} {u_cpu/u_datapath/u_regfile/_a1[11]} {u_cpu/u_datapath/u_regfile/_a1[12]} {u_cpu/u_datapath/u_regfile/_a1[13]} {u_cpu/u_datapath/u_regfile/_a1[14]} {u_cpu/u_datapath/u_regfile/_a1[15]}]]

# probe3: a2 (r3)
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 16 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {u_cpu/u_datapath/u_regfile/_a2[0]} {u_cpu/u_datapath/u_regfile/_a2[1]} {u_cpu/u_datapath/u_regfile/_a2[2]} {u_cpu/u_datapath/u_regfile/_a2[3]} {u_cpu/u_datapath/u_regfile/_a2[4]} {u_cpu/u_datapath/u_regfile/_a2[5]} {u_cpu/u_datapath/u_regfile/_a2[6]} {u_cpu/u_datapath/u_regfile/_a2[7]} {u_cpu/u_datapath/u_regfile/_a2[8]} {u_cpu/u_datapath/u_regfile/_a2[9]} {u_cpu/u_datapath/u_regfile/_a2[10]} {u_cpu/u_datapath/u_regfile/_a2[11]} {u_cpu/u_datapath/u_regfile/_a2[12]} {u_cpu/u_datapath/u_regfile/_a2[13]} {u_cpu/u_datapath/u_regfile/_a2[14]} {u_cpu/u_datapath/u_regfile/_a2[15]}]]

# probe4: t0 (r4)
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 16 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {u_cpu/u_datapath/u_regfile/_t0[0]} {u_cpu/u_datapath/u_regfile/_t0[1]} {u_cpu/u_datapath/u_regfile/_t0[2]} {u_cpu/u_datapath/u_regfile/_t0[3]} {u_cpu/u_datapath/u_regfile/_t0[4]} {u_cpu/u_datapath/u_regfile/_t0[5]} {u_cpu/u_datapath/u_regfile/_t0[6]} {u_cpu/u_datapath/u_regfile/_t0[7]} {u_cpu/u_datapath/u_regfile/_t0[8]} {u_cpu/u_datapath/u_regfile/_t0[9]} {u_cpu/u_datapath/u_regfile/_t0[10]} {u_cpu/u_datapath/u_regfile/_t0[11]} {u_cpu/u_datapath/u_regfile/_t0[12]} {u_cpu/u_datapath/u_regfile/_t0[13]} {u_cpu/u_datapath/u_regfile/_t0[14]} {u_cpu/u_datapath/u_regfile/_t0[15]}]]

# probe5: t1 (r5)
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 16 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {u_cpu/u_datapath/u_regfile/_t1[0]} {u_cpu/u_datapath/u_regfile/_t1[1]} {u_cpu/u_datapath/u_regfile/_t1[2]} {u_cpu/u_datapath/u_regfile/_t1[3]} {u_cpu/u_datapath/u_regfile/_t1[4]} {u_cpu/u_datapath/u_regfile/_t1[5]} {u_cpu/u_datapath/u_regfile/_t1[6]} {u_cpu/u_datapath/u_regfile/_t1[7]} {u_cpu/u_datapath/u_regfile/_t1[8]} {u_cpu/u_datapath/u_regfile/_t1[9]} {u_cpu/u_datapath/u_regfile/_t1[10]} {u_cpu/u_datapath/u_regfile/_t1[11]} {u_cpu/u_datapath/u_regfile/_t1[12]} {u_cpu/u_datapath/u_regfile/_t1[13]} {u_cpu/u_datapath/u_regfile/_t1[14]} {u_cpu/u_datapath/u_regfile/_t1[15]}]]

# probe6: t2 (r6)
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 16 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {u_cpu/u_datapath/u_regfile/_t2[0]} {u_cpu/u_datapath/u_regfile/_t2[1]} {u_cpu/u_datapath/u_regfile/_t2[2]} {u_cpu/u_datapath/u_regfile/_t2[3]} {u_cpu/u_datapath/u_regfile/_t2[4]} {u_cpu/u_datapath/u_regfile/_t2[5]} {u_cpu/u_datapath/u_regfile/_t2[6]} {u_cpu/u_datapath/u_regfile/_t2[7]} {u_cpu/u_datapath/u_regfile/_t2[8]} {u_cpu/u_datapath/u_regfile/_t2[9]} {u_cpu/u_datapath/u_regfile/_t2[10]} {u_cpu/u_datapath/u_regfile/_t2[11]} {u_cpu/u_datapath/u_regfile/_t2[12]} {u_cpu/u_datapath/u_regfile/_t2[13]} {u_cpu/u_datapath/u_regfile/_t2[14]} {u_cpu/u_datapath/u_regfile/_t2[15]}]]

# probe7: t3 (r7)
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 16 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {u_cpu/u_datapath/u_regfile/_t3[0]} {u_cpu/u_datapath/u_regfile/_t3[1]} {u_cpu/u_datapath/u_regfile/_t3[2]} {u_cpu/u_datapath/u_regfile/_t3[3]} {u_cpu/u_datapath/u_regfile/_t3[4]} {u_cpu/u_datapath/u_regfile/_t3[5]} {u_cpu/u_datapath/u_regfile/_t3[6]} {u_cpu/u_datapath/u_regfile/_t3[7]} {u_cpu/u_datapath/u_regfile/_t3[8]} {u_cpu/u_datapath/u_regfile/_t3[9]} {u_cpu/u_datapath/u_regfile/_t3[10]} {u_cpu/u_datapath/u_regfile/_t3[11]} {u_cpu/u_datapath/u_regfile/_t3[12]} {u_cpu/u_datapath/u_regfile/_t3[13]} {u_cpu/u_datapath/u_regfile/_t3[14]} {u_cpu/u_datapath/u_regfile/_t3[15]}]]

# probe8: s0 (r8)
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 16 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list {u_cpu/u_datapath/u_regfile/_s0[0]} {u_cpu/u_datapath/u_regfile/_s0[1]} {u_cpu/u_datapath/u_regfile/_s0[2]} {u_cpu/u_datapath/u_regfile/_s0[3]} {u_cpu/u_datapath/u_regfile/_s0[4]} {u_cpu/u_datapath/u_regfile/_s0[5]} {u_cpu/u_datapath/u_regfile/_s0[6]} {u_cpu/u_datapath/u_regfile/_s0[7]} {u_cpu/u_datapath/u_regfile/_s0[8]} {u_cpu/u_datapath/u_regfile/_s0[9]} {u_cpu/u_datapath/u_regfile/_s0[10]} {u_cpu/u_datapath/u_regfile/_s0[11]} {u_cpu/u_datapath/u_regfile/_s0[12]} {u_cpu/u_datapath/u_regfile/_s0[13]} {u_cpu/u_datapath/u_regfile/_s0[14]} {u_cpu/u_datapath/u_regfile/_s0[15]}]]

# probe9: s1 (r9)
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 16 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list {u_cpu/u_datapath/u_regfile/_s1[0]} {u_cpu/u_datapath/u_regfile/_s1[1]} {u_cpu/u_datapath/u_regfile/_s1[2]} {u_cpu/u_datapath/u_regfile/_s1[3]} {u_cpu/u_datapath/u_regfile/_s1[4]} {u_cpu/u_datapath/u_regfile/_s1[5]} {u_cpu/u_datapath/u_regfile/_s1[6]} {u_cpu/u_datapath/u_regfile/_s1[7]} {u_cpu/u_datapath/u_regfile/_s1[8]} {u_cpu/u_datapath/u_regfile/_s1[9]} {u_cpu/u_datapath/u_regfile/_s1[10]} {u_cpu/u_datapath/u_regfile/_s1[11]} {u_cpu/u_datapath/u_regfile/_s1[12]} {u_cpu/u_datapath/u_regfile/_s1[13]} {u_cpu/u_datapath/u_regfile/_s1[14]} {u_cpu/u_datapath/u_regfile/_s1[15]}]]

# probe10: s2 (r10)
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 16 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list {u_cpu/u_datapath/u_regfile/_s2[0]} {u_cpu/u_datapath/u_regfile/_s2[1]} {u_cpu/u_datapath/u_regfile/_s2[2]} {u_cpu/u_datapath/u_regfile/_s2[3]} {u_cpu/u_datapath/u_regfile/_s2[4]} {u_cpu/u_datapath/u_regfile/_s2[5]} {u_cpu/u_datapath/u_regfile/_s2[6]} {u_cpu/u_datapath/u_regfile/_s2[7]} {u_cpu/u_datapath/u_regfile/_s2[8]} {u_cpu/u_datapath/u_regfile/_s2[9]} {u_cpu/u_datapath/u_regfile/_s2[10]} {u_cpu/u_datapath/u_regfile/_s2[11]} {u_cpu/u_datapath/u_regfile/_s2[12]} {u_cpu/u_datapath/u_regfile/_s2[13]} {u_cpu/u_datapath/u_regfile/_s2[14]} {u_cpu/u_datapath/u_regfile/_s2[15]}]]

# probe11: s3 (r11)
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 16 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list {u_cpu/u_datapath/u_regfile/_s3[0]} {u_cpu/u_datapath/u_regfile/_s3[1]} {u_cpu/u_datapath/u_regfile/_s3[2]} {u_cpu/u_datapath/u_regfile/_s3[3]} {u_cpu/u_datapath/u_regfile/_s3[4]} {u_cpu/u_datapath/u_regfile/_s3[5]} {u_cpu/u_datapath/u_regfile/_s3[6]} {u_cpu/u_datapath/u_regfile/_s3[7]} {u_cpu/u_datapath/u_regfile/_s3[8]} {u_cpu/u_datapath/u_regfile/_s3[9]} {u_cpu/u_datapath/u_regfile/_s3[10]} {u_cpu/u_datapath/u_regfile/_s3[11]} {u_cpu/u_datapath/u_regfile/_s3[12]} {u_cpu/u_datapath/u_regfile/_s3[13]} {u_cpu/u_datapath/u_regfile/_s3[14]} {u_cpu/u_datapath/u_regfile/_s3[15]}]]

# probe12: fp (r12)
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
set_property port_width 16 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list {u_cpu/u_datapath/u_regfile/_fp[0]} {u_cpu/u_datapath/u_regfile/_fp[1]} {u_cpu/u_datapath/u_regfile/_fp[2]} {u_cpu/u_datapath/u_regfile/_fp[3]} {u_cpu/u_datapath/u_regfile/_fp[4]} {u_cpu/u_datapath/u_regfile/_fp[5]} {u_cpu/u_datapath/u_regfile/_fp[6]} {u_cpu/u_datapath/u_regfile/_fp[7]} {u_cpu/u_datapath/u_regfile/_fp[8]} {u_cpu/u_datapath/u_regfile/_fp[9]} {u_cpu/u_datapath/u_regfile/_fp[10]} {u_cpu/u_datapath/u_regfile/_fp[11]} {u_cpu/u_datapath/u_regfile/_fp[12]} {u_cpu/u_datapath/u_regfile/_fp[13]} {u_cpu/u_datapath/u_regfile/_fp[14]} {u_cpu/u_datapath/u_regfile/_fp[15]}]]

# probe13: sp (r13)
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe13]
set_property port_width 16 [get_debug_ports u_ila_0/probe13]
connect_debug_port u_ila_0/probe13 [get_nets [list {u_cpu/u_datapath/u_regfile/_sp[0]} {u_cpu/u_datapath/u_regfile/_sp[1]} {u_cpu/u_datapath/u_regfile/_sp[2]} {u_cpu/u_datapath/u_regfile/_sp[3]} {u_cpu/u_datapath/u_regfile/_sp[4]} {u_cpu/u_datapath/u_regfile/_sp[5]} {u_cpu/u_datapath/u_regfile/_sp[6]} {u_cpu/u_datapath/u_regfile/_sp[7]} {u_cpu/u_datapath/u_regfile/_sp[8]} {u_cpu/u_datapath/u_regfile/_sp[9]} {u_cpu/u_datapath/u_regfile/_sp[10]} {u_cpu/u_datapath/u_regfile/_sp[11]} {u_cpu/u_datapath/u_regfile/_sp[12]} {u_cpu/u_datapath/u_regfile/_sp[13]} {u_cpu/u_datapath/u_regfile/_sp[14]} {u_cpu/u_datapath/u_regfile/_sp[15]}]]

# probe14: lr (r14)
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe14]
set_property port_width 16 [get_debug_ports u_ila_0/probe14]
connect_debug_port u_ila_0/probe14 [get_nets [list {u_cpu/u_datapath/u_regfile/_lr[0]} {u_cpu/u_datapath/u_regfile/_lr[1]} {u_cpu/u_datapath/u_regfile/_lr[2]} {u_cpu/u_datapath/u_regfile/_lr[3]} {u_cpu/u_datapath/u_regfile/_lr[4]} {u_cpu/u_datapath/u_regfile/_lr[5]} {u_cpu/u_datapath/u_regfile/_lr[6]} {u_cpu/u_datapath/u_regfile/_lr[7]} {u_cpu/u_datapath/u_regfile/_lr[8]} {u_cpu/u_datapath/u_regfile/_lr[9]} {u_cpu/u_datapath/u_regfile/_lr[10]} {u_cpu/u_datapath/u_regfile/_lr[11]} {u_cpu/u_datapath/u_regfile/_lr[12]} {u_cpu/u_datapath/u_regfile/_lr[13]} {u_cpu/u_datapath/u_regfile/_lr[14]} {u_cpu/u_datapath/u_regfile/_lr[15]}]]

# probe15: gp (r15)
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe15]
set_property port_width 16 [get_debug_ports u_ila_0/probe15]
connect_debug_port u_ila_0/probe15 [get_nets [list {u_cpu/u_datapath/u_regfile/_gp[0]} {u_cpu/u_datapath/u_regfile/_gp[1]} {u_cpu/u_datapath/u_regfile/_gp[2]} {u_cpu/u_datapath/u_regfile/_gp[3]} {u_cpu/u_datapath/u_regfile/_gp[4]} {u_cpu/u_datapath/u_regfile/_gp[5]} {u_cpu/u_datapath/u_regfile/_gp[6]} {u_cpu/u_datapath/u_regfile/_gp[7]} {u_cpu/u_datapath/u_regfile/_gp[8]} {u_cpu/u_datapath/u_regfile/_gp[9]} {u_cpu/u_datapath/u_regfile/_gp[10]} {u_cpu/u_datapath/u_regfile/_gp[11]} {u_cpu/u_datapath/u_regfile/_gp[12]} {u_cpu/u_datapath/u_regfile/_gp[13]} {u_cpu/u_datapath/u_regfile/_gp[14]} {u_cpu/u_datapath/u_regfile/_gp[15]}]]

# dbg_hub settings (unchanged)
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets i_clk_IBUF_BUFG]

# extra trigger: register file write-enable
create_debug_port u_ila_0 probe
set_property PROBE_TYPE TRIGGER [get_debug_ports u_ila_0/probe16]
set_property port_width 1 [get_debug_ports u_ila_0/probe16]
connect_debug_port u_ila_0/probe16 [get_nets u_cpu/u_datapath/_rf_we_final]

# pc probe 
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe17]
set_property port_width 16 [get_debug_ports u_ila_0/probe17]
connect_debug_port u_ila_0/probe17 [get_nets [list {u_cpu/u_datapath/_pc[0]} {u_cpu/u_datapath/_pc[1]} {u_cpu/u_datapath/_pc[2]} {u_cpu/u_datapath/_pc[3]} {u_cpu/u_datapath/_pc[4]} {u_cpu/u_datapath/_pc[5]} {u_cpu/u_datapath/_pc[6]} {u_cpu/u_datapath/_pc[7]} {u_cpu/u_datapath/_pc[8]} {u_cpu/u_datapath/_pc[9]} {u_cpu/u_datapath/_pc[10]} {u_cpu/u_datapath/_pc[11]} {u_cpu/u_datapath/_pc[12]} {u_cpu/u_datapath/_pc[13]} {u_cpu/u_datapath/_pc[14]} {u_cpu/u_datapath/_pc[15]}]]

# irq take probe
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe18]
set_property port_width 1 [get_debug_ports u_ila_0/probe18]
connect_debug_port u_ila_0/probe18 [get_nets _irq_take]

# int en probe
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe19]
set_property port_width 1 [get_debug_ports u_ila_0/probe19]
connect_debug_port u_ila_0/probe19 [get_nets _int_en_cpu]

# irq vector probe
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe20]
set_property port_width 16 [get_debug_ports u_ila_0/probe20]
connect_debug_port u_ila_0/probe20 [get_nets [list {_irq_vector[0]} {_irq_vector[1]} {_irq_vector[2]} {_irq_vector[3]} {_irq_vector[4]} {_irq_vector[5]} {_irq_vector[6]} {_irq_vector[7]} {_irq_vector[8]} {_irq_vector[9]} {_irq_vector[10]} {_irq_vector[11]} {_irq_vector[12]} {_irq_vector[13]} {_irq_vector[14]} {_irq_vector[15]}]]

# timer 0 probe 
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe21]
set_property port_width 1 [get_debug_ports u_ila_0/probe21]
connect_debug_port u_ila_0/probe21 [get_nets u_periph/u_timer0/_int_req_dbg]

# timer 1 probe
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe22]
set_property port_width 1 [get_debug_ports u_ila_0/probe22]
connect_debug_port u_ila_0/probe22 [get_nets u_periph/u_timer1/_int_req_dbg]

# in_irq probe (tracks IRQ nesting context)
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe23]
set_property port_width 1 [get_debug_ports u_ila_0/probe23]
connect_debug_port u_ila_0/probe23 [get_nets _in_irq]

# irq return detect probe
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe24]
set_property port_width 1 [get_debug_ports u_ila_0/probe24]
connect_debug_port u_ila_0/probe24 [get_nets _iret_detected]

# instruction word probe (ROM fetch output)
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe25]
set_property port_width 16 [get_debug_ports u_ila_0/probe25]
connect_debug_port u_ila_0/probe25 [get_nets [list {_imem_dout[0]} {_imem_dout[1]} {_imem_dout[2]} {_imem_dout[3]} {_imem_dout[4]} {_imem_dout[5]} {_imem_dout[6]} {_imem_dout[7]} {_imem_dout[8]} {_imem_dout[9]} {_imem_dout[10]} {_imem_dout[11]} {_imem_dout[12]} {_imem_dout[13]} {_imem_dout[14]} {_imem_dout[15]}]]

# data word probe (RAM read data path)
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe26]
set_property port_width 16 [get_debug_ports u_ila_0/probe26]
connect_debug_port u_ila_0/probe26 [get_nets [list {_mem_dout[0]} {_mem_dout[1]} {_mem_dout[2]} {_mem_dout[3]} {_mem_dout[4]} {_mem_dout[5]} {_mem_dout[6]} {_mem_dout[7]} {_mem_dout[8]} {_mem_dout[9]} {_mem_dout[10]} {_mem_dout[11]} {_mem_dout[12]} {_mem_dout[13]} {_mem_dout[14]} {_mem_dout[15]}]]
