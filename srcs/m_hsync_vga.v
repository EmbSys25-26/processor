`timescale 1ns / 1ps

`include "constants.vh"

module m_hsync_vga(
    input wire i_clk,               // VGA pixel CLK
    input wire i_rst,
    input wire i_enVGA,
    input wire [4:0] i_imgData,
    output wire o_endLine, 
    output wire [`VGA_CHANNEL_SIZE:0] o_vga_red,
    output wire [`VGA_CHANNEL_SIZE:0] o_vga_green,
    output wire [`VGA_CHANNEL_SIZE:0] o_vga_blue,
    output wire o_hsync,
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
 * 1.2 DEFINE THRESHOLDS (in pixel CLK units)
 ***************************************************************************/ 
    localparam [9:0] THRES_FP = 10'd16;
    localparam [9:0] THRES_SYNC = 10'd96;
    localparam [9:0] THRES_BP = 10'd48;
    localparam [9:0] THRES_VISIBLE = 10'd640;    
 
/****************************************************************************
 * 1.2 DECLARE VARIABLES    
 ***************************************************************************/
    reg [1:0] _state;
    reg _endLine;
    reg [9:0] _pixelCounter;
    reg _hsync;
    wire _enter;
    
    reg [`VGA_CHANNEL_SIZE:0] _vga_red;
    reg [`VGA_CHANNEL_SIZE:0] _vga_green;
    reg [`VGA_CHANNEL_SIZE:0] _vga_blue;
    
/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/
 
/****************************************************************************
 * 2.1 STATIC ASSIGNMENTS  
 ***************************************************************************/
    assign o_endLine = _endLine;
    assign o_hsync = _hsync;
    assign o_state_debug = _state;
    
    assign o_vga_red = _vga_red;
    assign o_vga_green = _vga_green;
    assign o_vga_blue = _vga_blue;
     
/****************************************************************************
 * 2.2 FSM   
 ***************************************************************************/
 always @(posedge i_clk) begin
    if (i_rst || ~i_enVGA) begin
        _state <= FRONT_PORCH;
        _endLine <= 1'b0;
        _pixelCounter <= 10'b0;
        _hsync <= 1'b1;
        _endLine <= 1'b0;
        _vga_red <= 4'b0000;
        _vga_green <= 4'b0000;
        _vga_blue <= 4'b0000;
    end
    else begin
        case (_state)
            FRONT_PORCH: begin
                _hsync <= 1'b1;
                _endLine <= 1'b0;
                                
                if (_pixelCounter < THRES_FP-1) begin
                    _pixelCounter <= _pixelCounter +1;
                end else begin
                    _pixelCounter <= 10'b0;
                    _state <= SYNC;
                end
            end
            SYNC: begin
                _hsync <= 1'b0;
                                
                if (_pixelCounter < THRES_SYNC-1) begin
                    _pixelCounter <= _pixelCounter +1;
                end else begin
                    _pixelCounter <= 10'b0;
                    _state <= BACK_PORCH;
                end
            end
            BACK_PORCH: begin
                _hsync <= 1'b1;
                                
                if (_pixelCounter < THRES_BP-1) begin
                    _pixelCounter <= _pixelCounter +1;
                end else begin
                    _pixelCounter <= 10'b0;
                    _state <= VISIBLE;
                end
            end
            VISIBLE: begin
                _hsync <= 1'b1;
                                
                if (_pixelCounter < THRES_VISIBLE-1) begin
                    _pixelCounter <= _pixelCounter +1;
                    
                    casex (i_imgData[4:0]) 
                        5'bxx1xx:  begin
                            _vga_red <= 4'b1111;
                            _vga_green <= 4'b0000;
                            _vga_blue <= 4'b0000;
                        end
                        5'bxxx1x: begin
                            _vga_red <= 4'b0000;
                            _vga_green <= 4'b1111;
                            _vga_blue <= 4'b0000;
                        end
                        5'bxxxx1: begin
                            _vga_red <= 4'b0000;
                            _vga_green <= 4'b0000;
                            _vga_blue <= 4'b1111;
                        end
                        default: begin
                            _vga_red <= 4'b0000;
                            _vga_green <= 4'b0000;
                            _vga_blue <= 4'b0000;
                        end           
                   endcase 
                end else begin
                    _pixelCounter <= 10'b0;
                    _endLine <= 1'b1;
                    _state <= FRONT_PORCH;
                    _vga_red <= 4'b0000;
                    _vga_green <= 4'b0000;
                    _vga_blue <= 4'b0000;
                end
            end
            
            
        endcase 
    end    
 end 

endmodule
