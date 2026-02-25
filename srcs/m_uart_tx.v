`timescale 1ns / 1ps

module uart_tx(
    input wire i_clk,
    input wire i_rst,
    input wire [7:0] i_data,         // Data to Transmit
    input wire i_tx_start,           // Signal to Enable Transmission
    output wire o_tx_out,            // Tx Line
    output wire o_tx_done,           // Transmission Finished
    output wire o_tx_busy,           // Transmission Ongoing
    output wire [1:0] o_state_debug  // Current State
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
    localparam [1:0] WRITE_DATA = 2'd2;
    localparam [1:0] STOP = 2'd3;

/****************************************************************************
 * 1.2 DECLARE VARIABLES    
 ***************************************************************************/
    localparam _bit_time = (CLK_FREQ + (BAUD_RATE / 2)) / BAUD_RATE; // How many clock cycles fit in one UART bit period
    localparam _ctr_width = $clog2(_bit_time) + 1;

    reg [1:0] _state;
    reg [_ctr_width-1:0] _counter;
    reg [7:0] _shift_reg;
    reg [2:0] _bit_index;

    reg _tx_out;
    reg _tx_done;

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

/*************************************************************************************
 * 2.1 Status and Debug
 ************************************************************************************/
    assign o_tx_busy = (_state != IDLE);
    assign o_state_debug = _state;

/*************************************************************************************
 * 2.2 TX FSM
 ************************************************************************************/
    always @(posedge i_clk) begin
        if (i_rst) begin
            _state <= IDLE;
            _counter <= 0;
            _tx_out <= 1'b1;
            _tx_done <= 1'b0;
            _shift_reg <= 8'h00;
            _bit_index <= 3'd0;
        end else begin
            _tx_done <= 1'b0;

            case (_state)
                IDLE: begin
                    _tx_out <= 1'b1;
                    if (i_tx_start) begin
                        _shift_reg <= i_data;
                        _state <= START;
                        _counter <= 0;
                        _bit_index <= 3'd0;
                    end
                end

                START: begin
                    _tx_out <= 1'b0;
                    if (_counter == (_bit_time - 1)) begin
                        _counter <= 0;
                        _state <= WRITE_DATA;
                    end else begin
                        _counter <= _counter + 1'b1;
                    end
                end

                WRITE_DATA: begin
                    _tx_out <= _shift_reg[_bit_index];
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
                    _tx_out <= 1'b1;
                    if (_counter == (_bit_time - 1)) begin
                        _counter <= 0;
                        _state <= IDLE;
                        _tx_done <= 1'b1;
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

    assign o_tx_out = _tx_out;
    assign o_tx_done = _tx_done;

endmodule
