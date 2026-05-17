`timescale 1ns / 1ps

`include "constants.vh"

module m_vsync_vga(
    input wire i_clk,
    input wire i_rst,
    input wire i_enVGA,
    input wire i_mode_switch,
    input wire i_endLine,
    input  wire i_axis_tvalid,
    input  wire i_axis_tuser,
    output wire o_vsync,
    output wire [8:0] o_lineCounter, 
    output wire [2:0] o_state_debug,
    output wire o_vactive,
    output wire o_flush
 );

/*************************************************************************************
 * SECTION 1. DECLARE/DEFINE VARIABLES
 ************************************************************************************/

/****************************************************************************
 * 1.1 DEFINE FSM STATES 
 ***************************************************************************/
    localparam [2:0] WAIT_SOF    = 3'd0;
    localparam [2:0] VISIBLE     = 3'd1;
    localparam [2:0] FRONT_PORCH = 3'd2;
    localparam [2:0] SYNC        = 3'd3;
    localparam [2:0] BACK_PORCH  = 3'd4;

/****************************************************************************
 * 1.2 DEFINE THRESHOLDS (in lines)
 ***************************************************************************/ 
    localparam [9:0] THRES_VISIBLE = 10'd480;
    localparam [9:0] THRES_FP      = 10'd10;
    localparam [9:0] THRES_SYNC    = 10'd2;
    localparam [9:0] THRES_BP      = 10'd33;

/****************************************************************************
 * 1.2 DECLARE VARIABLES    
 ***************************************************************************/
    (* mark_debug = "true" *) reg [2:0] _state;
    (* mark_debug = "true" *) reg [8:0] _lineCounter;
    (* mark_debug = "true" *) reg       _vsync;
    reg _endLine_r;
    
/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/
 
/****************************************************************************
 * 2.1 STATIC ASSIGNMENTS  
 ***************************************************************************/
    assign o_vsync = _vsync;
    assign o_state_debug = _state;
    assign o_lineCounter = _lineCounter;
    assign o_vactive = (_state == VISIBLE);
    assign o_flush = (!i_mode_switch) && (_state == WAIT_SOF);
     
 /****************************************************************************
 * 2.2 FSM   
 ***************************************************************************/
 always @(posedge i_clk) begin
        if (i_rst || ~i_enVGA) begin
            _state       <= WAIT_SOF;
            _lineCounter <= 9'b0;
            _vsync       <= 1'b1;
            _endLine_r   <= 1'b0;
        end
        else begin
            _endLine_r <= i_endLine;
            case (_state)

                // ---- Only image mode uses this state ----
                // In text mode, it enters here on reset but exits immediately
                // because there is no tuser - it advances directly to VISIBLE
                WAIT_SOF: begin
       
                     _vsync <= 1'b1;
                    if (i_mode_switch) begin
                        // Text mode: no VDMA, advances directly
                        _state       <= VISIBLE;
                        _lineCounter <= 9'b0;
                    end else begin
                        // Image mode: waits for VDMA SOF
                        if (i_axis_tvalid && i_axis_tuser) begin
                            _state       <= VISIBLE;
                            _lineCounter <= 9'b0;
                        end
                    end
                end

                VISIBLE: begin
                    _vsync <= 1'b1;
                    if (i_endLine) begin
                        if (_lineCounter == THRES_VISIBLE - 1) begin
                            _lineCounter <= 9'b0;
                            _state       <= FRONT_PORCH;
                        end else begin
                            _lineCounter <= _lineCounter + 1;
                        end
                    end
                end

                FRONT_PORCH: begin
                    _vsync <= 1'b1;
                    if (i_endLine) begin
                        if (_lineCounter == THRES_FP - 1) begin
                            _lineCounter <= 9'b0;
                            _state       <= SYNC;
                        end else begin
                            _lineCounter <= _lineCounter + 1;
                        end
                    end
                end

                SYNC: begin
                    _vsync <= 1'b0;
                    if (i_endLine) begin
                        if (_lineCounter == THRES_SYNC - 1) begin
                            _lineCounter <= 9'b0;
                            _state       <= BACK_PORCH;
                        end else begin
                            _lineCounter <= _lineCounter + 1;
                        end
                    end
                end

                BACK_PORCH: begin
                    _vsync <= 1'b1;
                    if (i_endLine) begin
                        if (_lineCounter == THRES_BP - 1) begin
                            _lineCounter <= 9'b0;
                            if (i_mode_switch)
                                _state <= VISIBLE;
                            else
                                _state <= WAIT_SOF;
                        end else begin
                            _lineCounter <= _lineCounter + 1;
                        end
                    end
                end

                default: _state <= WAIT_SOF;
            endcase
        end
    end

endmodule