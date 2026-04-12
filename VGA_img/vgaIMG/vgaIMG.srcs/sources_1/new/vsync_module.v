`timescale 1ns / 1ps
`include "constants.vh"

module m_vsync_vga(
    input wire i_clk,
    input wire i_rst,
    input wire i_enVGA,
    input wire i_endLine,   // Pulso de 1 clock vindo do HSync ao fim de cada linha
    input  wire i_axis_tvalid,   // NOVO
    input  wire i_axis_tuser,    // NOVO
    output wire o_vsync,
    output wire [2:0] o_state_debug,
    output wire o_vactive,
    output wire o_flush         // NOVO
 );

    // Estados da FSM [cite: 123, 124]
    localparam [2:0] WAIT_SOF    = 3'd0;
    localparam [2:0] VISIBLE     = 3'd1;
    localparam [2:0] FRONT_PORCH = 3'd2;
    localparam [2:0] SYNC        = 3'd3;
    localparam [2:0] BACK_PORCH  = 3'd4;

    // Limites (Thresholds) para 640x480 @ 60Hz [cite: 125, 126]
    localparam [9:0] THRES_VISIBLE = 10'd480;
    localparam [9:0] THRES_FP      = 10'd10;
    localparam [9:0] THRES_SYNC    = 10'd2;
    localparam [9:0] THRES_BP      = 10'd33;

   (* mark_debug = "true" *) reg [2:0] _state;
   (* mark_debug = "true" *)  reg [9:0] _lineCounter;
   (* mark_debug = "true" *)  reg       _vsync;

    assign o_vsync = _vsync;
    assign o_state_debug = _state; 
    assign o_vactive = (_state == VISIBLE);
    assign o_flush = (_state == WAIT_SOF);

    always @(posedge i_clk) begin
        if (i_rst || ~i_enVGA) begin
            _state       <= WAIT_SOF; // for initial sync state
            _lineCounter <= 10'b0;
            _vsync       <= 1'b1;    // Repouso é ALTO (Negative Polarity) [cite: 130]
        end
        else begin
            // A lógica só processa quando uma linha completa termina
            
                case (_state)
                    WAIT_SOF: begin
                        _vsync <= 1'b1;
                        // leave when it see tuser = 1
                        if(i_axis_tvalid && i_axis_tuser) begin
                        _state <= VISIBLE;
                        _lineCounter <= 10'b0;
                        end
                        end
                        
                    VISIBLE: begin
                        _vsync <= 1'b1;
                        if(i_endLine) begin
                        if (_lineCounter == THRES_VISIBLE - 1) begin
                            _lineCounter <= 10'b0;
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
                            _lineCounter <= 10'b0;
                            _state       <= SYNC;
                        end else begin
                            _lineCounter <= _lineCounter + 1;
                        end
                        end
                    end

                    SYNC: begin
                        _vsync <= 1'b0; // Pulso Ativo (Baixo) [cite: 134]
                        if(i_endLine) begin 
                        if (_lineCounter == THRES_SYNC - 1) begin
                            _lineCounter <= 10'b0;
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
                            _lineCounter <= 10'b0;
                            _state       <= WAIT_SOF;
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