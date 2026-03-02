`timescale 1ns / 1ps

/*************************************************************************************
 * PS2 D2H MODULE (Device -> Host)
 *  Implements PS/2 receive protocol (device to host direction).
 *  Receives fall_edge and ps2_data already filtered and synchronized from mmio.
 ************************************************************************************/

module ps2_d2h (
    input  wire       i_clk,
    input  wire       i_rst,
    input  wire       i_fall_edge,  // falling edge of PS2 CLK (from mmio)
    input  wire       i_ps2_data,   // PS2 DATA synchronized (from mmio)
    input  wire       i_rx_en,      // enable receiver (from PS2CR.EN)
    (* mark_debug = "true" *) output reg [7:0]  o_rx_data,    // received scancode byte
    output reg        o_rx_valid,   // '1' for one cycle when a valid frame is ready
    output reg        o_rx_pe,      // '1': parity error on last frame
    output reg        o_rx_err      // '1': framing error on last frame (bad stop bit)
);

/*************************************************************************************
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/

/*************************************************************************************
 * 1.1 FSM State Encoding
 ************************************************************************************/
    localparam [2:0] IDLE   = 3'd0;
    localparam [2:0] DATA   = 3'd1;
    localparam [2:0] PARITY = 3'd2;
    localparam [2:0] STOP   = 3'd3;
    localparam [2:0] DONE   = 3'd4;

    reg [2:0] _state;

/*************************************************************************************
 * 1.2 Internal Registers
 ************************************************************************************/
    (* mark_debug = "true" *) reg [7:0] _shift;       // shift register collecting incoming bits
    reg [2:0] _bit_idx;     // counts received data bits (0 to 7)
    reg       _parity_bit;  // captured parity bit from frame

/*************************************************************************************
 * 1.3 Parity Computation
 ************************************************************************************/
    // Odd parity check: XOR of all 8 data bits and parity bit must be 1
    // _parity = 1 means ERROR (received parity does not satisfy odd parity rule)
    wire _parity;
    assign _parity = ~(^{_shift, _parity_bit});

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

/*************************************************************************************
 * 2.1 FSM
 ************************************************************************************/
    always @(posedge i_clk) begin
        if (i_rst) begin
            _state      <= IDLE;
            _shift      <= 8'h00;
            _bit_idx    <= 3'd0;
            _parity_bit <= 1'b0;
            o_rx_data   <= 8'h00;
            o_rx_valid  <= 1'b0;
            o_rx_pe     <= 1'b0;
            o_rx_err    <= 1'b0;
        end else begin
            // Default: deassert valid every cycle unless explicitly set
            o_rx_valid <= 1'b0;

            case (_state)

                // IDLE: wait for start bit (falling edge with DATA = 0)
                IDLE: begin
                    _shift   <= 8'h00;
                    _bit_idx <= 3'd0;
                    if (i_rx_en && i_fall_edge && !i_ps2_data) begin
                        // Clear error flags at the start of each new frame
                        o_rx_pe  <= 1'b0;
                        o_rx_err <= 1'b0;
                        _state   <= DATA;
                    end
                end

              
                // DATA: shift in 8 data bits, LSB first
                DATA: begin
                    if (i_fall_edge) begin
                        _shift   <= {i_ps2_data, _shift[7:1]};
                        _bit_idx <= _bit_idx + 1'b1;
                        if (_bit_idx == 3'd7) begin
                            _state <= PARITY;
                        end
                    end
                end

              
                // PARITY: capture parity bit
                PARITY: begin
                    if (i_fall_edge) begin
                        _parity_bit <= i_ps2_data;
                        _state      <= STOP;
                    end
                end

                
                // STOP: verify stop bit is high
                STOP: begin
                    if (i_fall_edge) begin
                        if (i_ps2_data) begin
                            _state <= DONE;
                        end else begin
                            o_rx_err <= 1'b1;
                            _state   <= IDLE;
                        end
                    end
                end

           
                // DONE: complete frame, output data and flags to mmio
                DONE: begin
                    o_rx_valid <= 1'b1;
                    o_rx_data  <= _shift;
                    o_rx_pe    <= _parity;
                    _state     <= IDLE;
                end

                default: begin
                    _state <= IDLE;
                end

            endcase
        end
    end

endmodule
