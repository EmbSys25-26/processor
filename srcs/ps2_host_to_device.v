`timescale 1ns / 1ps

/*************************************************************************************
 * PS2 H2D MODULE (Host -> Device)
 *  Implements PS/2 transmit protocol (host to device direction).
 *  Receives fall_edge and ps2_data already filtered and synchronized from mmio.
 *
 *  CLK and DATA are open-drain (inout):
 *    drive 0   -> pulls line LOW
 *    drive 1'bz -> releases line (pull-up restores HIGH)
 ************************************************************************************/

module ps2_h2d (
    input  wire       i_clk,
    input  wire       i_rst,
    input  wire       i_start,        // pulse: CPU wrote to PS2DR
    input  wire [7:0] i_data,         // byte to send
    input  wire       i_fall_edge,    // falling edge of ps2 clk (from mmio)
    input  wire       i_ps2_data_s,   // filtered ps2 data (to read ACK)
    inout  wire       io_ps2_clk,     // PS2 clock (open-drain)
    inout  wire       io_ps2_data,    // PS2 data  (open-drain)
    output reg        o_tx_done,      // pulse: transmission complete
    output reg        o_tx_busy,      // high while transmitting
    output reg        o_tx_aerr       // pulse:ack not received 
);

/*************************************************************************************
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/

    localparam [3:0] IDLE    = 4'd0;
    localparam [3:0] INHIBIT = 4'd1;
    localparam [3:0] START   = 4'd2;
    localparam [3:0] DATA    = 4'd3;
    localparam [3:0] PARITY  = 4'd4;
    localparam [3:0] STOP    = 4'd5;
    localparam [3:0] ACK     = 4'd6;
    localparam [3:0] DONE    = 4'd7;

    reg [3:0] _state;

    // 100us inhibit counter (100MHz x 100us = 10000 cycles)
    localparam [13:0] _INHIBIT_CNT = 14'd10000;
    reg [13:0] _inh_cnt;

    // Open-drain drive regs
    reg _clk_drive;
    reg _data_drive;

    reg [7:0] _shift;//copy of byte to send
    reg [2:0] _bit_idx;//sending index
    wire      _parity;

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

/*************************************************************************************
 * 2.1 Open-drain assigns
 ************************************************************************************/
    assign io_ps2_clk  = _clk_drive;
    assign io_ps2_data = _data_drive;

/*************************************************************************************
 * 2.2 Odd parity
 ************************************************************************************/
    assign _parity = ~(^_shift);

/*************************************************************************************
 * 2.3 FSM
 ************************************************************************************/
    always @(posedge i_clk) begin
        if (i_rst) begin
            _state      <= IDLE;
            _clk_drive  <= 1'bz;
            _data_drive <= 1'bz;
            o_tx_busy   <= 1'b0;
            o_tx_done   <= 1'b0;
            _shift      <= 8'h00;
            _bit_idx    <= 3'd0;
            _inh_cnt    <= 14'd0;
        end else begin
            o_tx_done <= 1'b0;

            case (_state)

                IDLE: begin
                    _clk_drive  <= 1'bz;
                    _data_drive <= 1'bz;
                    if (i_start) begin
                        _shift    <= i_data;
                        _bit_idx  <= 3'd0;
                        _inh_cnt  <= 14'd0;
                        o_tx_busy <= 1'b1;
                        _state    <= INHIBIT;
                    end
                end

                // Pull CLK low >= 100us
                INHIBIT: begin
                    _clk_drive <= 1'b0;
                    if (_inh_cnt >= _INHIBIT_CNT) begin
                        _state <= START;
                        _clk_drive  <= 1'bz;
                    end else begin
                        _inh_cnt <= _inh_cnt + 14'd1;
                    end
                end

                // Pull DATA low (start bit), release CLK
                // Device takes control of CLK from here
                START: begin
                    if (i_fall_edge) begin
                        _data_drive <= 1'b0;
                        _state <= DATA;
                    end
                end

                // Send 8 data bits LSB first on each falling edge(device clock)
                DATA: begin
                    if (i_fall_edge) begin
                        _data_drive <= _shift[_bit_idx] ? 1'bz : 1'b0;
                        if (_bit_idx == 3'd7) begin
                            _state <= PARITY;
                        end else begin
                            _bit_idx <= _bit_idx + 3'd1;
                        end
                    end
                end

                // Send odd parity bit
                PARITY: begin
                    if (i_fall_edge) begin
                        _data_drive <= _parity ? 1'bz : 1'b0;
                        _state      <= STOP;
                    end
                end

                // Release DATA (stop bit = 1)
                STOP: begin
                    if (i_fall_edge) begin
                        _data_drive <= 1'bz;
                        _state      <= ACK;
                    end
                end

                // Wait for ACK from device
                ACK: begin
                    if (i_fall_edge) begin
                        _state <= DONE;

                    end
                end

                DONE: begin
                    o_tx_busy <= 1'b0;
                    o_tx_done <= 1'b1;
                    _state    <= IDLE;
                end

                default: _state <= IDLE;

            endcase
        end
    end

endmodule