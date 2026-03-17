`timescale 1ns / 1ps

`include "constants.vh"

module m_vsync_vga(
    input wire i_clk,
    input wire i_rst,
    input wire i_enVGA,
    input wire i_endLine, 
    output wire o_vsync,
    output wire [1:0] o_state_debug
 );
 
/*************************************************************************************
 * SECTION 1. DECLARE/DEFINE VARIABLES
 ************************************************************************************/

/****************************************************************************
 * 1.1 DEFINE FSM STATES 
 ***************************************************************************/
    localparam [1:0] FRONT_PORCH = 2'b00;
    localparam [1:0] SYNC = 2'b01;
    localparam [1:0] BACK_PORCH = 2'b10;
    localparam [1:0] VISIBLE = 2'b11; 
 
/****************************************************************************
 * 1.2 DEFINE THRESHOLDS (in lines)
 ***************************************************************************/ 
    localparam [8:0] THRES_FP = 10'd10;
    localparam [8:0] THRES_SYNC = 10'd2;
    localparam [8:0] THRES_BP = 10'd33;
    localparam [8:0] THRES_VISIBLE = 10'd480;    
 
/****************************************************************************
 * 1.2 DECLARE VARIABLES    
 ***************************************************************************/
    reg [1:0] _state;
    reg [8:0] _lineCounter;
    reg _vsync;
    reg _endLine;
    
/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/
 
/****************************************************************************
 * 2.1 STATIC ASSIGNMENTS  
 ***************************************************************************/
    assign o_vsync = _vsync;
    assign o_state_debug = _state;
 
 /****************************************************************************
 * 2.2 FSM   
 ***************************************************************************/
    always @(posedge i_clk) begin
        if (i_rst || ~i_enVGA) begin
            _state <= FRONT_PORCH;
            _lineCounter <= 9'b0;
            _vsync <= 1'b1;
            _endLine <= i_endLine;
        end
        else begin
            _endLine <= i_endLine;
            
            if (i_endLine && ~_endLine) begin
                _lineCounter <= _lineCounter +1;
            end
            
            case (_state)
                FRONT_PORCH: begin
                    _vsync <= 1'b1;
                                                    
                    if (_lineCounter > THRES_FP-1) begin
                        _lineCounter <= 9'b0;
                        _state <= SYNC;
                    end
                end
                SYNC: begin
                    _vsync <= 1'b0;
                                    
                    if (_lineCounter > THRES_SYNC-1) begin
                        _lineCounter <= 9'b0;
                        _state <= BACK_PORCH;
                    end
                end
                BACK_PORCH: begin
                    _vsync <= 1'b1;
                                    
                    if (_lineCounter > THRES_BP-1) begin
                        _lineCounter <= 9'b0;
                        _state <= VISIBLE;
                    end
                end
                VISIBLE: begin
                    _vsync <= 1'b1;
                                    
                    if (_lineCounter > THRES_VISIBLE-1) begin
                        _lineCounter <= 9'b0;
                        _state <= FRONT_PORCH;
                    end
                end
            endcase 
        end
    end
    
 
endmodule
