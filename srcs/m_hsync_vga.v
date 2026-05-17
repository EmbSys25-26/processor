`timescale 1ns / 1ps

`include "constants.vh"

   module m_hsync_vga(
        input wire i_clk,               // VGA pixel CLK
        input wire i_rst,
        input wire i_enVGA,
        input wire i_mode_switch,
        input wire [4:0] i_imgData,
        input wire i_pixel_activo,
        input wire [15:0] i_axis_tdata,  
        // Pixel: [15:12]=R [11:8]=G [7:4]=B
        input wire i_axis_tvalid,  // VDMA has pixel ready to send
        input wire i_axis_tuser,
        input wire i_axis_tlast,
        input wire i_vactive,
        input wire i_flush,
        output wire o_axis_tready,  // hsync tells VDMA to send pixel
        output wire o_endLine, 
        
        output wire [`VGA_CHANNEL_SIZE:0] o_vga_red,
        output wire [`VGA_CHANNEL_SIZE:0] o_vga_green,
        output wire [`VGA_CHANNEL_SIZE:0] o_vga_blue,
        output wire o_hsync,
        output wire [1:0] o_state_debug,
        output wire [9:0] o_pixelCounter
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
    (* mark_debug = "true" *) reg [1:0]  _state;
    (* mark_debug = "true" *) reg        _endLine;
    (* mark_debug = "true" *) reg [9:0]  _pixelCounter;
    (* mark_debug = "true" *) reg        _hsync;

    reg [`VGA_CHANNEL_SIZE:0] _vga_red;
    reg [`VGA_CHANNEL_SIZE:0] _vga_green;
    reg [`VGA_CHANNEL_SIZE:0] _vga_blue;
     
    wire _unused = |i_axis_tdata[3:0];

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/
 
/****************************************************************************
 * 2.1 STATIC ASSIGNMENTS  
 ***************************************************************************/

    wire _in_visible   = (_state == VISIBLE) && i_enVGA && ~i_rst && i_vactive;
    wire _pixel_accept = _in_visible && i_axis_tvalid;
    assign o_axis_tready = _in_visible || i_flush;
        
    assign o_endLine = _endLine;
    assign o_hsync   = _hsync;
    assign o_state_debug = _state;
    assign o_pixelCounter = _pixelCounter;

    assign o_vga_red   = i_vactive ? _vga_red   : 4'b0000;
    assign o_vga_green = i_vactive ? _vga_green : 4'b0000;
    assign o_vga_blue  = i_vactive ? _vga_blue  : 4'b0000;
            
    reg endline_raw;

    always @(posedge i_clk) begin
        // Generates the pulse exactly at the pixel 639 cycle
        endline_raw <= (_state == VISIBLE && _pixelCounter == THRES_VISIBLE - 1);

        // endLine is now aligned with tlast
        _endLine <= endline_raw;
    end
    
/****************************************************************************
 * 2.2 FSM   
 ***************************************************************************/
 always @(posedge i_clk) begin
        if (i_rst || ~i_enVGA) begin
            _state        <= FRONT_PORCH;
            _pixelCounter <= 10'b0;
            _hsync        <= 1'b1;
            //_endLine    <= 1'b0;
            _vga_red      <= 4'b0000;
            _vga_green    <= 4'b0000;
            _vga_blue     <= 4'b0000;
        end
        else begin
            //_endLine <= 1'b0;
            case (_state)

                FRONT_PORCH: begin
                    _hsync     <= 1'b1;
                    _vga_red   <= 4'b0000;
                    _vga_green <= 4'b0000;
                    _vga_blue  <= 4'b0000;

                    if (_pixelCounter < THRES_FP - 1) begin
                        _pixelCounter <= _pixelCounter + 1;
                    end else begin
                        _pixelCounter <= 10'b0;
                        _state        <= SYNC;
                    end
                end

                SYNC: begin
                    _hsync <= 1'b0;

                    if (_pixelCounter < THRES_SYNC - 1) begin
                        _pixelCounter <= _pixelCounter + 1;
                    end else begin
                        _pixelCounter <= 10'b0;
                        _state        <= BACK_PORCH;
                    end
                end

                BACK_PORCH: begin
                    _hsync <= 1'b1;

                    if (_pixelCounter < THRES_BP - 1) begin
                        _pixelCounter <= _pixelCounter + 1;
                    end else begin
                        _pixelCounter <= 10'b0;
                        _state        <= VISIBLE;
                    end
                end

                VISIBLE: begin
                    _hsync <= 1'b1;

                    // Always advance the counter
                    if (_pixelCounter == THRES_VISIBLE - 1) begin
                        _pixelCounter <= 10'b0;
                        //_endLine    <= 1'b1;
                        _state        <= FRONT_PORCH;
                        _vga_red      <= 4'b0000;
                        _vga_green    <= 4'b0000;
                        _vga_blue     <= 4'b0000;
                    end else begin
                        _pixelCounter <= _pixelCounter + 1;

                        // ---- TEXT MODE ----
                        if (i_mode_switch) begin
                                if (i_pixel_activo) begin
                                    
                                    // Foreground (Text) Color -> Controlled by bits [3:1] (R, G, B)
                                    _vga_red   <= i_imgData[3] ? 4'b1111 : 4'b0000;
                                    _vga_green <= i_imgData[2] ? 4'b1111 : 4'b0000;
                                    _vga_blue  <= i_imgData[1] ? 4'b1111 : 4'b0000;

                                end else begin
                                    // Background Color -> Controlled by bit [4] (0 = Black, 1 = White)
                                    _vga_red   <= i_imgData[4] ? 4'b1111 : 4'b0000;
                                    _vga_green <= i_imgData[4] ? 4'b1111 : 4'b0000;
                                    _vga_blue  <= i_imgData[4] ? 4'b1111 : 4'b0000;
                                end

                        // ---- IMAGE MODE ----
                        end else begin
                            if (i_axis_tvalid) begin
                
                                _vga_red   <= i_axis_tdata[15:12];
                                _vga_green <= i_axis_tdata[11:8];
                                _vga_blue  <= i_axis_tdata[7:4];
                            end else begin
                                _vga_red   <= 4'b0000;
                                _vga_green <= 4'b0000;
                                _vga_blue  <= 4'b0000;
                            end
                       end
                   end
                end
            endcase
        end
    end

endmodule