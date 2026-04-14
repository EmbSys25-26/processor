set_property SRC_FILE_INFO {cfile:/home/andre/Desktop/CPUcomVGA/processor-CPU-com-VGA/CPU-com-VGA/processor.gen/sources_1/ip/clk_wiz_0/clk_wiz_0.xdc rfile:../processor.gen/sources_1/ip/clk_wiz_0/clk_wiz_0.xdc id:1 order:EARLY scoped_inst:clk_gen/inst} [current_design]
set_property SRC_FILE_INFO {cfile:/home/andre/Desktop/CPUcomVGA/processor-CPU-com-VGA/CPU-com-VGA/constraints/Zybo-Z7-Master.xdc rfile:../constraints/Zybo-Z7-Master.xdc id:2} [current_design]
current_instance clk_gen/inst
set_property src_info {type:SCOPED_XDC file:1 line:54 export:INPUT save:INPUT read:READ} [current_design]
set_input_jitter [get_clocks -of_objects [get_ports clk_in1]] 0.080
current_instance
set_property src_info {type:XDC file:2 line:4 export:INPUT save:INPUT read:READ} [current_design]
create_clock -period 20.000 -name sys_clk_pin -waveform {0.000 10.000} -add [get_ports i_clkk]
set_property src_info {type:XDC file:2 line:43 export:INPUT save:INPUT read:READ} [current_design]
connect_debug_port u_ila_0/probe0 [get_nets [list {u_periph/u_ps2/u_ps2_d2h/_shift_0[0]} {u_periph/u_ps2/u_ps2_d2h/_shift_0[1]} {u_periph/u_ps2/u_ps2_d2h/_shift_0[2]} {u_periph/u_ps2/u_ps2_d2h/_shift_0[3]} {u_periph/u_ps2/u_ps2_d2h/_shift_0[4]} {u_periph/u_ps2/u_ps2_d2h/_shift_0[5]} {u_periph/u_ps2/u_ps2_d2h/_shift_0[6]} {u_periph/u_ps2/u_ps2_d2h/_shift_0[7]}]]
