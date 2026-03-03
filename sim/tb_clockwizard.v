`timescale 1ns / 1ps

module tb_clockwizard();

reg _clk = 1'b0, _rst;

wire _clkSystem, _clkVGA, _locked, _rst_sync;

controller dut ( 
    .i_clk (_clk),
    .i_rst (_rst),
    .o_vga_red(),
    .o_vga_green(),
    .o_vga_blue(),
    .o_hsync(),
    .o_vsync()
    );
    
always #5 _clk = ~_clk;

assign _clkSystem = dut._clkSystem;
assign _clkVGA = dut._clkVGA;
assign _locked = dut._locked;
assign _rst_sync = dut._rst_sync;
    
initial begin
    _rst <= 1'b1;
    
    repeat (10) @(posedge _clk);
     _rst <= 1'b0;
     
    // Wait until locked instead of guessing a fixed time
    @(posedge _locked);
    
    repeat (30) @(posedge _clkSystem); // observe some post-lock cycles
    $finish;
end

endmodule
