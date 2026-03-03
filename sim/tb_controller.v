`timescale 1ns / 1ps

module tb_controller();

/*************************************************************************************
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/
    reg _clk = 1'b0, _rst=1'b1;
    reg [2:0] _imgSel = 3'b0;
    wire _vga_red, _vga_green, _vga_blue, _hsync, _vsync;
    
    integer _timeout;
    
/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/  
 
/*************************************************************************************
 * 2.1 DUT, clock
 ************************************************************************************/ 
    
 always #5 _clk = ~_clk;
 
 controller dut(
    .i_clk(_clk),
    .i_rst(_rst),
    .i_imgSel(_imgSel),       
    .o_vga_red(_vga_red),
    .o_vga_green(_vga_green),
    .o_vga_blue(_vga_blue),
    .o_hsync(_hsync),
    .o_vsync(_vsync) 
  );
 
/*************************************************************************************
 * 2.3 Validation
 ************************************************************************************/
 
 initial begin
    repeat (10) @(posedge _clk);
    _rst <= 1'b0;
    @(posedge dut._clkSystem);
    @(posedge dut._clkVGA);
    
    _imgSel <= 3'b1; // Blue
    
    _timeout = 4500000;
    
    while (_timeout > 0) begin
        @(posedge _clk)
        _timeout <= _timeout -1;
    end
    
    $finish;
 end
 
 
endmodule
