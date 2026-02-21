`timescale 1ns / 1ps

module uart_rx(
    input wire i_clk,
    input wire i_rst,
    input wire i_rx_in,                 // Receive Line 
    output wire [7:0] o_data,           // Received Data
    output wire o_data_valid,           // Reception Completed -> Received Data is Valid
    output wire o_rx_out,               // Receive Echo
    output wire o_rx_busy,              // Reception Ongoing
    output wire [1:0] o_state_debug     // Current State
);

    parameter CLK_FREQ = 80_000_000;
    parameter BAUD_RATE = 115200;

/*************************************************************************************
 * SECTION 1. DECLARE/DEFINE VARIABLES
 ************************************************************************************/

/****************************************************************************
 * 1.1 DEFINE FSM STATES 
 ***************************************************************************/
    localparam [1:0] IDLE = 2'd0;
    localparam [1:0] START = 2'd1;
    localparam [1:0] RECEIVE_DATA = 2'd2;
    localparam [1:0] STOP = 2'd3;

 /****************************************************************************
 * 1.2 DECLARE VARIABLES    
 ***************************************************************************/
    localparam _bit_time = (CLK_FREQ + (BAUD_RATE / 2)) / BAUD_RATE;
    localparam _ctr_width = $clog2(_bit_time) + 1;
    localparam _half_bit = _bit_time / 2;

    reg [1:0] _state;
    reg [_ctr_width-1:0] _counter;
    reg [7:0] _shift_reg;
    reg [2:0] _bit_index;
    reg _stop_ok;

    reg _rx_sync1;
    reg _rx_sync2;
    wire _rx_s;

    reg [7:0] _data;
    reg _data_valid;
    reg _rx_out;

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

/*************************************************************************************
 * 2.1 Status and Sync
 ************************************************************************************/
    assign _rx_s = _rx_sync2;
    assign o_rx_busy = (_state != IDLE);
    assign o_state_debug = _state;

/*************************************************************************************
 * 2.2 RX FSM
 ************************************************************************************/
    always @(posedge i_clk) begin
        if (i_rst) begin
            _state <= IDLE;
            _counter <= 0;
            _rx_out <= 1'b1;
            _rx_done <= 1'b0;
            _data_valid <= 1'b0;
            _shift_reg <= 8'd0;
            _bit_index <= 3'd0;
            _data <= 8'd0;
            _stop_ok <= 1'b0;
            _rx_sync1 <= 1'b1;
            _rx_sync2 <= 1'b1;
        end else begin
            _rx_sync1 <= i_rx_in;
            _rx_sync2 <= _rx_sync1; // Reduce Metastabilty

            _data_valid <= 1'b0;

            case (_state)
                IDLE: begin
                    _rx_out <= 1'b1;
                    if (!_rx_s) begin
                        _counter <= 0;
                        _state <= START;
                        _bit_index <= 3'd0;
                        _stop_ok <= 1'b0;
                    end
                end

                START: begin
                    if (_counter == (_half_bit - 1)) begin
                        if (!_rx_s) begin
                            _rx_out <= 1'b0;
                            _counter <= 0;
                            _state <= RECEIVE_DATA;
                            _bit_index <= 3'd0;
                        end else begin
                            _rx_out <= 1'b1;
                            _counter <= 0;
                            _state <= IDLE;
                            _bit_index <= 3'd0;
                        end
                    end else begin
                        _counter <= _counter + 1'b1;
                    end
                end

                RECEIVE_DATA: begin
                    if (_counter == (_half_bit - 1)) begin
                        _shift_reg[_bit_index] <= _rx_s;
                        _rx_out <= _rx_s;
                    end

                    if (_counter == (_bit_time - 1)) begin
                        _counter <= 0;
                        if (_bit_index == 3'd7) begin
                            _state <= STOP;
                            _bit_index <= 3'd0;
                        end else begin
                            _bit_index <= _bit_index + 1'b1;
                        end
                    end else begin
                        _counter <= _counter + 1'b1;
                    end
                end

                STOP: begin
                    _rx_out <= 1'b1;
                    if (_counter == (_half_bit - 1)) begin
                        _stop_ok <= _rx_s;
                    end
                    if (_counter == (_bit_time - 1)) begin
                        _counter <= 0;
                        _state <= IDLE;
                        if (_stop_ok) begin
                            _data <= _shift_reg;
                            _data_valid <= 1'b1;
                        end
                    end else begin
                        _counter <= _counter + 1'b1;
                    end
                end

                default: begin
                    _state <= IDLE;
                end
            endcase
        end
    end

    assign o_data = _data;
    assign o_data_valid = _data_valid;
    assign o_rx_out = _rx_out;

endmodule
