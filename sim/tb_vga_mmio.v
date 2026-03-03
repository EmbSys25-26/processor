`timescale 1ns / 1ps

module tb_vga_mmio();

/*************************************************************************************
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/
    reg _clk = 1'b0;
    reg _rst = 1'b1;
    
    reg _sel = 1'b0;
    reg _we = 1'b0;
    reg _re = 1'b0;
    reg _addr = 1'b0;
    reg [15:0] _wdata = 16'h0000;

    wire [15:0] _rdata;
    wire _rdy;
    
    wire _hsync, _vsync;
        
    integer _errors = 0;
    integer _timeout;
 
 /*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

/*************************************************************************************
 * 2.1 DUT and clock generation
 ************************************************************************************/
   always #5 _clk = ~_clk;
   
   m_vga_mmio dut(
   .i_clkSystem(_clk),
   .i_clkVGA(_clk),
   .i_rst(_rst),
   .i_sel(_sel),
   .i_we(_we),            
   .i_re(_re),         
   .i_addr(_addr),         
   .i_wdata(_wdata),
   .o_rdata(_rdata),
   .o_rdy(_rdy),
   .o_vga_red(),
   .o_vga_green(),
   .o_vga_blue(),
   .o_hsync(_hsync),
   .o_vsync(_vsync)   
);
   
/*************************************************************************************
 * 2.2 MMIO helpers
 ************************************************************************************/
  task mmio_write(input i_addr, input [15:0] i_data);
        begin
            _addr <= i_addr;
            _wdata <= i_data;
            _sel <= 1'b1;
            _we <= 1'b1;
            _re <= 1'b0;
            @(posedge _clk);
            _sel <= 1'b0;
            _we <= 1'b0;
            _addr <= 1'b0;
            _wdata <= 16'h0000;
        end
    endtask

    task mmio_read(input i_addr, output [15:0] o_data);
        begin
            _addr <= i_addr;
            _sel <= 1'b1;
            _we <= 1'b0;
            _re <= 1'b1;
            #1;
            o_data = _rdata;
            @(posedge _clk);
            _sel <= 1'b0;
            _re <= 1'b0;
            _addr <= 1'b0;
        end
    endtask

/*************************************************************************************
 * 2.3 Stimulus and checks
 ************************************************************************************/
 
     reg [15:0] _rd;
     initial begin
        repeat (5) @(posedge _clk);
            _rst <= 1'b0;
        
        mmio_read(1'b0, _rd);
        if (_rd[0] !== 1'b0) begin
                $display("FAIL tb_i2c_mmio_regs: CNTRL reset mismatch 0x%04h", _rd);
                _errors = _errors + 1;
        end
        
        mmio_write(1'b0, 16'h0001);   // ENABLE VGA START  
        mmio_read(1'b0, _rd);
        if (_rd !== 16'h0001) begin
                $display("FAIL tb_i2c_mmio_regs: CNTRL readback mismatch 0x%04h", _rd);
                _errors = _errors + 1;
        end
        
        mmio_write(1'b1, 16'h0001);   // ENABLE SRC IMAGE 0 (blue) 
        mmio_read(1'b1, _rd);
        if (_rd !== 16'h0001) begin
                $display("FAIL tb_i2c_mmio_regs: VGASEL readback mismatch 0x%04h", _rd);
                _errors = _errors + 1;
        end
        
        _timeout = 16;
        while (_timeout != 0) begin
                @(posedge _clk);
                _timeout = _timeout - 1;
        end 
       
        if (_hsync) begin
            _errors = _errors + 1;
            $display ("Error: hsync shoud not be LOW");
        end 
         
        if (_errors == 0) begin
            $display("PASS tb_i2c_mmio_regs");
        end else begin
            $display("FAIL tb_i2c_mmio_regs errors=%0d", _errors);
            $fatal(1);
        end
        $finish;
     
     end
endmodule
