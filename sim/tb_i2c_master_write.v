`timescale 1ns / 1ps
`default_nettype none

module tb_i2c_master_write;

/*************************************************************************************
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/
    reg _clk = 1'b0;
    reg _rst = 1'b1;

    reg _en = 1'b0;
    reg _start = 1'b0;
    reg _rw = 1'b0;
    reg [6:0] _addr7 = 7'h00;
    reg [7:0] _len = 8'h00;
    reg [15:0] _div = 16'h0002;

    reg _tx_push = 1'b0;
    reg [7:0] _tx_push_data = 8'h00;
    reg _rx_pop = 1'b0;
    reg _rx_flush = 1'b0;

    reg _clr_done = 1'b0;
    reg _clr_ack_err = 1'b0;

    wire [7:0] _rx_data;
    wire _rx_valid;
    wire _busy;
    wire _done;
    wire _ack_err;

    tri1 _i2c_sda;
    tri1 _i2c_scl;

    wire _start_seen;
    wire _stop_seen;
    wire [7:0] _addr_byte;
    wire [7:0] _data0;
    wire [7:0] _data1;
    wire [7:0] _data2;
    wire [7:0] _data_count;

    integer _errors = 0;
    integer _timeout;

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

/*************************************************************************************
 * 2.1 DUT, slave BFM, and clock
 ************************************************************************************/
    always #5 _clk = ~_clk;

    i2c_master dut (
        .i_clk(_clk),
        .i_rst(_rst),
        .i_en(_en),
        .i_start(_start),
        .i_rw(_rw),
        .i_addr7(_addr7),
        .i_len(_len),
        .i_divider(_div),
        .i_tx_push(_tx_push),
        .i_tx_push_data(_tx_push_data),
        .i_rx_pop(_rx_pop),
        .i_rx_flush(_rx_flush),
        .i_clr_done(_clr_done),
        .i_clr_ack_err(_clr_ack_err),
        .o_rx_data(_rx_data),
        .o_rx_valid(_rx_valid),
        .o_busy(_busy),
        .o_done(_done),
        .o_ack_err(_ack_err),
        .io_i2c_sda(_i2c_sda),
        .io_i2c_scl(_i2c_scl)
    );

    i2c_slave_model slave (
        .i_rst(_rst),
        .i_ack_address(1'b1),
        .i_ack_data(1'b1),
        .i_match_en(1'b1),
        .i_addr7_match(7'h42),
        .io_sda(_i2c_sda),
        .io_scl(_i2c_scl),
        .o_start_seen(_start_seen),
        .o_stop_seen(_stop_seen),
        .o_addr_byte(_addr_byte),
        .o_data0(_data0),
        .o_data1(_data1),
        .o_data2(_data2),
        .o_data_count(_data_count)
    );

/*************************************************************************************
 * 2.2 Helpers
 ************************************************************************************/
    task push_tx(input [7:0] i_data);
        begin
            _tx_push <= 1'b1;
            _tx_push_data <= i_data;
            @(posedge _clk);
            _tx_push <= 1'b0;
            _tx_push_data <= 8'h00;
        end
    endtask

    task pulse_start;
        begin
            _start <= 1'b1;
            @(posedge _clk);
            _start <= 1'b0;
        end
    endtask

/*************************************************************************************
 * 2.3 Directed transaction checks
 ************************************************************************************/
    initial begin
        repeat (5) @(posedge _clk);
        _rst <= 1'b0;

        _en <= 1'b1;
        _rw <= 1'b0;
        _addr7 <= 7'h42;
        _len <= 8'd2;
        _div <= 16'd2;

        push_tx(8'hA5);
        push_tx(8'h5A);

        pulse_start();

        _timeout = 5000;
        while ((_timeout > 0) && !_done) begin
            @(posedge _clk);
            _timeout = _timeout - 1;
        end

        if (!_done) begin
            $display("FAIL tb_i2c_master_write: transaction timeout");
            $fatal(1);
        end

        $display("WAVE i2c capture addr=0x%02h data0=0x%02h data1=0x%02h count=%0d", _addr_byte, _data0, _data1, _data_count);

        if (_ack_err) begin
            $display("FAIL tb_i2c_master_write: unexpected ACK_ERR");
            _errors = _errors + 1;
        end
        if (_busy) begin
            $display("FAIL tb_i2c_master_write: BUSY still high at end");
            _errors = _errors + 1;
        end
        if (!_start_seen || !_stop_seen) begin
            $display("FAIL tb_i2c_master_write: START/STOP not observed start=%0b stop=%0b", _start_seen, _stop_seen);
            _errors = _errors + 1;
        end
        if (_addr_byte !== 8'h84) begin
            $display("FAIL tb_i2c_master_write: address byte mismatch 0x%02h", _addr_byte);
            _errors = _errors + 1;
        end
        if (_data_count < 8'd2) begin
            $display("FAIL tb_i2c_master_write: expected >=2 data bytes, got %0d", _data_count);
            _errors = _errors + 1;
        end
        if (_data0 !== 8'hA5 || _data1 !== 8'h5A) begin
            $display("FAIL tb_i2c_master_write: data bytes mismatch d0=0x%02h d1=0x%02h", _data0, _data1);
            _errors = _errors + 1;
        end

        if (_errors == 0) begin
            $display("PASS tb_i2c_master_write");
        end else begin
            $display("FAIL tb_i2c_master_write errors=%0d", _errors);
            $fatal(1);
        end
        $finish;
    end

endmodule
