`timescale 1ns / 1ps

module tb_vysnc_fsm();

/*************************************************************************************
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/
    reg _clk = 1'b0, _rst;
    reg _enVGA = 1'b0;
    reg _error = 1'b0;
    reg _endLine = 1'b0;
    
    wire _vsync;
    wire [1:0]_vsync_state_debug;
    
    integer _timeout;
  
  
      task pulse_endline;
        begin
            @(posedge _clk);
            _endLine <= 1'b1;
            @(posedge _clk);
            _endLine <= 1'b0;
        end
    endtask
  
/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/  
 
/*************************************************************************************
 * 2.1 DUT, clock
 ************************************************************************************/ 
     always #5 _clk = ~_clk;
     
     m_vsync_vga dut (
            .i_clk (_clk),
            .i_rst (_rst),
            .i_enVGA (_enVGA),
            .i_endLine(_endLine),
            .o_vsync(_vsync),
            .o_state_debug(_vsync_state_debug)
         );

/*************************************************************************************
 * 2.3 Validation
 ************************************************************************************/
    
    initial begin
        _rst <= 1'b1;
        _timeout = 0;
        repeat (10) @(posedge _clk);
        
        _rst <= 1'b0;
        _enVGA <= 1'b1;
        
        _timeout = 15;
        while (_timeout != 0) begin
            @(posedge _clk);
            _timeout = _timeout - 1;
        end
        
        if (!_vsync) begin
            _error <= 1'b1;
            $display ("Error: vsync shoud not be LOW");
        end
        
        _timeout = (dut.THRES_FP + dut.THRES_SYNC + dut.THRES_BP + dut.THRES_VISIBLE)*2;   
        repeat (100) pulse_endline();
        

        while (_timeout != 0) begin
            @(posedge _clk);
            _timeout = _timeout - 1;
        end

        if (!_error) 
            $display ("SUCCESS: tb_vsync_fsm");
        else 
            $display ("FAIL: tb_vsync_fsm");
            
        $finish;
    end
    
    always @(posedge _clk)
            $display("time=%0t endLine=%b line_counter=%0d",
             $time, _endLine, dut._line_counter);

endmodule