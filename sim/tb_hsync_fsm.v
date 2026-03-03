`timescale 1ns / 1ps

module tb_hsync_fsm();

reg _clk = 1'b0, _rst;

reg _enVGA = 1'b0;
wire _endLine, _hsync;
wire [1:0]_hsync_state_debug;

 m_hsync_vga hsync_module (
        .i_clk (_clk),
        .i_rst (_rst),
        .i_enVGA (_enVGA),
        .o_endLine(_endLine),
        .o_vga_red(),
        .o_vga_green(),
        .o_vga_blue(),
        .o_hsync(_hsync),
        .o_state_debug(_hsync_state_debug)
     );
    
always #5 _clk = ~_clk;
    
initial begin
    _rst <= 1'b1;
    
    repeat (10) @(posedge _clk);
     _rst <= 1'b0;
     _enVGA <= 1'b1;
    
    repeat (30) @(posedge _clk); // observe some post-lock cycles
    $finish;
end

endmodule
