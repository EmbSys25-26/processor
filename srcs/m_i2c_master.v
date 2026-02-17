`timescale 1ns / 1ps

module i2c_master(
    input wire i_clk,
    input wire i_rst,
    input wire i_en,
    input wire i_start,
    input wire i_rw,
    input wire [6:0] i_addr7,
    input wire [7:0] i_len,
    input wire [15:0] i_divider,
    input wire i_tx_push,
    input wire [7:0] i_tx_push_data,
    input wire i_rx_pop,
    input wire i_rx_flush,
    input wire i_clr_done,
    input wire i_clr_ack_err,
    output wire [7:0] o_rx_data,
    output wire o_rx_valid,
    output wire o_busy,
    output wire o_done,
    output wire o_ack_err,
    inout wire io_i2c_sda,
    inout wire io_i2c_scl
);

/*************************************************************************************
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/
    localparam [4:0] _st_idle = 5'd0;
    localparam [4:0] _st_start0 = 5'd1;
    localparam [4:0] _st_start1 = 5'd2;
    localparam [4:0] _st_start2 = 5'd3;
    localparam [4:0] _st_tx_low = 5'd4;
    localparam [4:0] _st_tx_high = 5'd5;
    localparam [4:0] _st_tx_fall = 5'd6;
    localparam [4:0] _st_ack_low = 5'd7;
    localparam [4:0] _st_ack_high = 5'd8;
    localparam [4:0] _st_ack_fall = 5'd9;
    localparam [4:0] _st_rx_low = 5'd10;
    localparam [4:0] _st_rx_high = 5'd11;
    localparam [4:0] _st_rx_fall = 5'd12;
    localparam [4:0] _st_mack_low = 5'd13;
    localparam [4:0] _st_mack_high = 5'd14;
    localparam [4:0] _st_mack_fall = 5'd15;
    localparam [4:0] _st_stop0 = 5'd16;
    localparam [4:0] _st_stop1 = 5'd17;
    localparam [4:0] _st_stop2 = 5'd18;

    reg [4:0] _state;

    reg _busy;
    reg _done;
    reg _ack_err;

    reg _sda_oe_low;
    reg _scl_oe_low;
    wire _sda_in;

    reg [15:0] _div_latched;
    reg [15:0] _div_cnt;
    reg _step_en;

    reg _rw_latched;
    reg [6:0] _addr_latched;
    reg [7:0] _len_latched;
    reg _address_phase;

    reg [7:0] _tx_byte;
    reg [7:0] _rx_shift;
    reg [2:0] _bit_idx;
    reg [7:0] _bytes_done;
    reg _send_nack;
    reg _ack_sample;

    reg [7:0] _tx_fifo [0:255];
    reg [7:0] _tx_wr_ptr;
    reg [7:0] _tx_rd_ptr;
    reg [8:0] _tx_count;

    reg [7:0] _rx_fifo [0:255];
    reg [7:0] _rx_wr_ptr;
    reg [7:0] _rx_rd_ptr;
    reg [8:0] _rx_count;

    integer _i;
    reg [7:0] _rx_byte_work;

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

/*************************************************************************************
 * 2.1 Open-Drain Line Drivers and Status Outputs
 ************************************************************************************/
    assign io_i2c_sda = _sda_oe_low ? 1'b0 : 1'bz;
    assign io_i2c_scl = _scl_oe_low ? 1'b0 : 1'bz;
    assign _sda_in = io_i2c_sda;

    assign o_rx_data = (_rx_count != 0) ? _rx_fifo[_rx_rd_ptr] : 8'h00;
    assign o_rx_valid = (_rx_count != 0);
    assign o_busy = _busy;
    assign o_done = _done;
    assign o_ack_err = _ack_err;

/*************************************************************************************
 * 2.2 Master FSM, FIFO Handling, and Transaction Control
 ************************************************************************************/
    always @(posedge i_clk) begin
        if (i_rst) begin
            _state <= _st_idle;

            _busy <= 1'b0;
            _done <= 1'b0;
            _ack_err <= 1'b0;

            _sda_oe_low <= 1'b0;
            _scl_oe_low <= 1'b0;

            _div_latched <= 16'd100;
            _div_cnt <= 16'd0;
            _step_en <= 1'b0;

            _rw_latched <= 1'b0;
            _addr_latched <= 7'd0;
            _len_latched <= 8'd0;
            _address_phase <= 1'b0;

            _tx_byte <= 8'h00;
            _rx_shift <= 8'h00;
            _bit_idx <= 3'd7;
            _bytes_done <= 8'd0;
            _send_nack <= 1'b0;
            _ack_sample <= 1'b1;

            _tx_wr_ptr <= 8'd0;
            _tx_rd_ptr <= 8'd0;
            _tx_count <= 9'd0;

            _rx_wr_ptr <= 8'd0;
            _rx_rd_ptr <= 8'd0;
            _rx_count <= 9'd0;

            for (_i = 0; _i < 256; _i = _i + 1) begin
                _tx_fifo[_i] <= 8'h00;
                _rx_fifo[_i] <= 8'h00;
            end
        end else begin
            if (i_clr_done) begin
                _done <= 1'b0;
            end
            if (i_clr_ack_err) begin
                _ack_err <= 1'b0;
            end

            if (i_tx_push && !_busy) begin
                if (_tx_count < 9'd256) begin
                    _tx_fifo[_tx_wr_ptr] <= i_tx_push_data;
                    _tx_wr_ptr <= _tx_wr_ptr + 8'd1;
                    _tx_count <= _tx_count + 9'd1;
                end else begin
                    _ack_err <= 1'b1;
                end
            end

            if (i_rx_flush && !_busy) begin
                _rx_wr_ptr <= 8'd0;
                _rx_rd_ptr <= 8'd0;
                _rx_count <= 9'd0;
            end else if (i_rx_pop && !_busy) begin
                if (_rx_count != 0) begin
                    _rx_rd_ptr <= _rx_rd_ptr + 8'd1;
                    _rx_count <= _rx_count - 9'd1;
                end
            end

            if (_busy) begin
                if (_div_cnt >= _div_latched) begin
                    _div_cnt <= 16'd0;
                    _step_en <= 1'b1;
                end else begin
                    _div_cnt <= _div_cnt + 16'd1;
                    _step_en <= 1'b0;
                end
            end else begin
                _div_cnt <= 16'd0;
                _step_en <= 1'b0;
            end

            if (!_busy) begin
                _sda_oe_low <= 1'b0;
                _scl_oe_low <= 1'b0;
                _state <= _st_idle;

                if (i_start && i_en) begin
                    _busy <= 1'b1;
                    _done <= 1'b0;

                    _rw_latched <= i_rw;
                    _addr_latched <= i_addr7;
                    _len_latched <= i_len;
                    _div_latched <= (i_divider < 16'd1) ? 16'd1 : i_divider;

                    _address_phase <= 1'b1;
                    _tx_byte <= {i_addr7, i_rw};
                    _rx_shift <= 8'h00;
                    _bit_idx <= 3'd7;
                    _bytes_done <= 8'd0;
                    _send_nack <= 1'b0;
                    _ack_sample <= 1'b1;

                    _state <= _st_start0;
                end
            end else if (_step_en) begin
                case (_state)
                    _st_start0: begin
                        _scl_oe_low <= 1'b0;
                        _sda_oe_low <= 1'b0;
                        _state <= _st_start1;
                    end

                    _st_start1: begin
                        _scl_oe_low <= 1'b0;
                        _sda_oe_low <= 1'b1;
                        _state <= _st_start2;
                    end

                    _st_start2: begin
                        _scl_oe_low <= 1'b1;
                        _sda_oe_low <= 1'b1;
                        _state <= _st_tx_low;
                    end

                    _st_tx_low: begin
                        _scl_oe_low <= 1'b1;
                        _sda_oe_low <= ~_tx_byte[_bit_idx];
                        _state <= _st_tx_high;
                    end

                    _st_tx_high: begin
                        _scl_oe_low <= 1'b0;
                        _state <= _st_tx_fall;
                    end

                    _st_tx_fall: begin
                        _scl_oe_low <= 1'b1;
                        if (_bit_idx == 3'd0) begin
                            _state <= _st_ack_low;
                        end else begin
                            _bit_idx <= _bit_idx - 3'd1;
                            _state <= _st_tx_low;
                        end
                    end

                    _st_ack_low: begin
                        _scl_oe_low <= 1'b1;
                        _sda_oe_low <= 1'b0;
                        _state <= _st_ack_high;
                    end

                    _st_ack_high: begin
                        _scl_oe_low <= 1'b0;
                        _ack_sample <= _sda_in;
                        _state <= _st_ack_fall;
                    end

                    _st_ack_fall: begin
                        _scl_oe_low <= 1'b1;

                        if (_ack_sample) begin
                            _ack_err <= 1'b1;
                            _state <= _st_stop0;
                        end else if (_address_phase) begin
                            _address_phase <= 1'b0;

                            if (_len_latched == 8'd0) begin
                                _state <= _st_stop0;
                            end else if (_rw_latched) begin
                                _rx_shift <= 8'h00;
                                _bit_idx <= 3'd7;
                                _state <= _st_rx_low;
                            end else begin
                                _bit_idx <= 3'd7;
                                if (_tx_count != 0) begin
                                    _tx_byte <= _tx_fifo[_tx_rd_ptr];
                                    _tx_rd_ptr <= _tx_rd_ptr + 8'd1;
                                    _tx_count <= _tx_count - 9'd1;
                                end else begin
                                    _tx_byte <= 8'h00;
                                    _ack_err <= 1'b1;
                                end
                                _state <= _st_tx_low;
                            end
                        end else begin
                            _bytes_done <= _bytes_done + 8'd1;

                            if ((_bytes_done + 8'd1) >= _len_latched) begin
                                _state <= _st_stop0;
                            end else begin
                                _bit_idx <= 3'd7;
                                if (_tx_count != 0) begin
                                    _tx_byte <= _tx_fifo[_tx_rd_ptr];
                                    _tx_rd_ptr <= _tx_rd_ptr + 8'd1;
                                    _tx_count <= _tx_count - 9'd1;
                                end else begin
                                    _tx_byte <= 8'h00;
                                    _ack_err <= 1'b1;
                                end
                                _state <= _st_tx_low;
                            end
                        end
                    end

                    _st_rx_low: begin
                        _scl_oe_low <= 1'b1;
                        _sda_oe_low <= 1'b0;
                        _state <= _st_rx_high;
                    end

                    _st_rx_high: begin
                        _scl_oe_low <= 1'b0;
                        _state <= _st_rx_fall;
                    end

                    _st_rx_fall: begin
                        _scl_oe_low <= 1'b1;

                        _rx_byte_work = _rx_shift;
                        _rx_byte_work[_bit_idx] = _sda_in;
                        _rx_shift <= _rx_byte_work;

                        if (_bit_idx == 3'd0) begin
                            if (_rx_count < 9'd256) begin
                                _rx_fifo[_rx_wr_ptr] <= _rx_byte_work;
                                _rx_wr_ptr <= _rx_wr_ptr + 8'd1;
                                _rx_count <= _rx_count + 9'd1;
                            end else begin
                                _ack_err <= 1'b1;
                            end

                            _bytes_done <= _bytes_done + 8'd1;
                            _send_nack <= ((_bytes_done + 8'd1) >= _len_latched);
                            _state <= _st_mack_low;
                        end else begin
                            _bit_idx <= _bit_idx - 3'd1;
                            _state <= _st_rx_low;
                        end
                    end

                    _st_mack_low: begin
                        _scl_oe_low <= 1'b1;
                        _sda_oe_low <= ~_send_nack;
                        _state <= _st_mack_high;
                    end

                    _st_mack_high: begin
                        _scl_oe_low <= 1'b0;
                        _state <= _st_mack_fall;
                    end

                    _st_mack_fall: begin
                        _scl_oe_low <= 1'b1;
                        _sda_oe_low <= 1'b0;

                        if (_send_nack) begin
                            _state <= _st_stop0;
                        end else begin
                            _rx_shift <= 8'h00;
                            _bit_idx <= 3'd7;
                            _state <= _st_rx_low;
                        end
                    end

                    _st_stop0: begin
                        _scl_oe_low <= 1'b1;
                        _sda_oe_low <= 1'b1;
                        _state <= _st_stop1;
                    end

                    _st_stop1: begin
                        _scl_oe_low <= 1'b0;
                        _sda_oe_low <= 1'b1;
                        _state <= _st_stop2;
                    end

                    _st_stop2: begin
                        _scl_oe_low <= 1'b0;
                        _sda_oe_low <= 1'b0;

                        _busy <= 1'b0;
                        _done <= 1'b1;
                        _state <= _st_idle;
                    end

                    default: begin
                        _state <= _st_idle;
                    end
                endcase
            end
        end
    end

endmodule
