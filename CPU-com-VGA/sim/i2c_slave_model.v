`timescale 1ns / 1ps
`default_nettype none

module i2c_slave_model(
    input wire i_rst,
    input wire i_ack_address,
    input wire i_ack_data,
    input wire i_match_en,
    input wire [6:0] i_addr7_match,
    inout wire io_sda,
    inout wire io_scl,
    output reg o_start_seen,
    output reg o_stop_seen,
    output reg [7:0] o_addr_byte,
    output reg [7:0] o_data0,
    output reg [7:0] o_data1,
    output reg [7:0] o_data2,
    output reg [7:0] o_data_count
);

/*************************************************************************************
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/
    reg _active;
    reg _ack_phase;
    reg _first_byte;
    reg _rw_dir;
    reg _ack_drive;
    reg _should_ack;

    reg [2:0] _bit_count;
    reg [7:0] _shift;
    reg [7:0] _byte_work;

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

/*************************************************************************************
 * 2.1 Open-Drain ACK Driver
 ************************************************************************************/
    assign io_sda = _ack_drive ? 1'b0 : 1'bz;

/*************************************************************************************
 * 2.2 Start/Stop Detection
 ************************************************************************************/
    always @(negedge io_sda or posedge i_rst) begin
        if (i_rst) begin
            _active <= 1'b0;
            _ack_phase <= 1'b0;
            _first_byte <= 1'b1;
            _rw_dir <= 1'b0;
            _ack_drive <= 1'b0;
            _should_ack <= 1'b0;
            _bit_count <= 3'd0;
            _shift <= 8'h00;
            o_start_seen <= 1'b0;
            o_stop_seen <= 1'b0;
            o_addr_byte <= 8'h00;
            o_data0 <= 8'h00;
            o_data1 <= 8'h00;
            o_data2 <= 8'h00;
            o_data_count <= 8'h00;
        end else if (io_scl === 1'b1) begin
            _active <= 1'b1;
            _ack_phase <= 1'b0;
            _first_byte <= 1'b1;
            _rw_dir <= 1'b0;
            _ack_drive <= 1'b0;
            _should_ack <= 1'b0;
            _bit_count <= 3'd0;
            _shift <= 8'h00;
            o_start_seen <= 1'b1;
            o_stop_seen <= 1'b0;
            o_data_count <= 8'h00;
        end
    end

    always @(posedge io_sda or posedge i_rst) begin
        if (i_rst) begin
            o_stop_seen <= 1'b0;
            _active <= 1'b0;
            _ack_phase <= 1'b0;
            _ack_drive <= 1'b0;
        end else if (io_scl === 1'b1) begin
            o_stop_seen <= 1'b1;
            _active <= 1'b0;
            _ack_phase <= 1'b0;
            _ack_drive <= 1'b0;
        end
    end

/*************************************************************************************
 * 2.3 Byte Capture and ACK Scheduling
 ************************************************************************************/
    always @(posedge io_scl or posedge i_rst) begin
        if (i_rst) begin
            _bit_count <= 3'd0;
            _shift <= 8'h00;
            _ack_phase <= 1'b0;
            _should_ack <= 1'b0;
        end else if (_active) begin
            if (_ack_phase) begin
                _ack_phase <= 1'b0;
                _bit_count <= 3'd0;
                _shift <= 8'h00;
            end else begin
                _byte_work = {_shift[6:0], io_sda};
                _shift <= _byte_work;

                if (_bit_count == 3'd7) begin
                    if (_first_byte) begin
                        o_addr_byte <= _byte_work;
                        _rw_dir <= _byte_work[0];
                        _first_byte <= 1'b0;
                        _should_ack <= i_ack_address && (!i_match_en || (_byte_work[7:1] == i_addr7_match));
                    end else begin
                        if (!_rw_dir) begin
                            if (o_data_count == 8'd0) begin
                                o_data0 <= _byte_work;
                            end else if (o_data_count == 8'd1) begin
                                o_data1 <= _byte_work;
                            end else if (o_data_count == 8'd2) begin
                                o_data2 <= _byte_work;
                            end
                            o_data_count <= o_data_count + 8'd1;
                        end
                        _should_ack <= i_ack_data;
                    end

                    _ack_phase <= 1'b1;
                    _bit_count <= 3'd0;
                end else begin
                    _bit_count <= _bit_count + 3'd1;
                end
            end
        end
    end

/*************************************************************************************
 * 2.4 ACK Drive Timing (9th bit)
 ************************************************************************************/
    always @(negedge io_scl or posedge i_rst) begin
        if (i_rst) begin
            _ack_drive <= 1'b0;
        end else if (_active && _ack_phase) begin
            _ack_drive <= _should_ack;
        end else begin
            _ack_drive <= 1'b0;
        end
    end

endmodule
