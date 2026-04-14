`timescale 1ns / 1ps
`default_nettype none

module tb_i2c_irq_vector;

/*************************************************************************************
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/
    reg _clk = 1'b0;
    reg _rst = 1'b1;

    reg _sel = 1'b0;
    reg _we = 1'b0;
    reg _re = 1'b0;
    reg [15:0] _addr = 16'h0000;
    reg [15:0] _wdata = 16'h0000;

    reg [3:0] _par_i = 4'h0;
    reg _uart_rx = 1'b1;
    reg _in_irq = 1'b0;
    reg _int_en = 1'b1;
    reg _irq_ret = 1'b0;

    tri1 _i2c_sda;
    tri1 _i2c_scl;

    wire [15:0] _rdata;
    wire _rdy;
    wire [3:0] _par_o;
    wire _uart_tx;
    wire _irq_take;
    wire [15:0] _irq_vector;

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

    periph_bus dut (
        .i_clk(_clk),
        .i_rst(_rst),
        .i_sel(_sel),
        .i_we(_we),
        .i_re(_re),
        .i_addr(_addr),
        .i_wdata(_wdata),
        .o_rdata(_rdata),
        .o_rdy(_rdy),
        .i_par_i(_par_i),
        .o_par_o(_par_o),
        .i_uart_rx(_uart_rx),
        .o_uart_tx(_uart_tx),
        .io_i2c_sda(_i2c_sda),
        .io_i2c_scl(_i2c_scl),
        .i_in_irq(_in_irq),
        .i_int_en(_int_en),
        .i_irq_ret(_irq_ret),
        .o_irq_take(_irq_take),
        .o_irq_vector(_irq_vector)
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
 * 2.2 MMIO helpers
 ************************************************************************************/
    task mmio_write(input [15:0] i_addr, input [15:0] i_data);
        begin
            _addr <= i_addr;
            _wdata <= i_data;
            _sel <= 1'b1;
            _we <= 1'b1;
            _re <= 1'b0;
            @(posedge _clk);
            _sel <= 1'b0;
            _we <= 1'b0;
            _addr <= 16'h0000;
            _wdata <= 16'h0000;
        end
    endtask

    task mmio_read(input [15:0] i_addr, output [15:0] o_data);
        begin
            _addr <= i_addr;
            _sel <= 1'b1;
            _we <= 1'b0;
            _re <= 1'b1;
            #1;
            o_data = _rdata;
            @(posedge _clk);
            _sel <= 1'b0;
            _re <= 1'b0;
            _addr <= 16'h0000;
        end
    endtask

/*************************************************************************************
 * 2.3 End-to-end IRQ-vector check
 ************************************************************************************/
    reg [15:0] _rd;
    initial begin
        repeat (5) @(posedge _clk);
        _rst <= 1'b0;

        // Enable only I2C IRQ source (bit4) in the VIC mask.
        mmio_write(16'h8F04, 16'h0010);

        mmio_write(16'h8404, 16'h0002); // DIV
        mmio_write(16'h8406, 16'h0084); // 7-bit addr 0x42 in [7:1]
        mmio_write(16'h8408, 16'h0001); // LEN=1
        mmio_write(16'h840A, 16'h003C); // DATA byte
        mmio_write(16'h8400, 16'h000B); // EN=1 START=1 IRQ_EN=1

        _timeout = 4000;
        while ((_timeout > 0) && !_irq_take) begin
            @(posedge _clk);
            _timeout = _timeout - 1;
        end

        if (!_irq_take) begin
            $display("FAIL tb_i2c_irq_vector: irq_take timeout");
            $fatal(1);
        end

        $display("WAVE i2c irq take vector=0x%04h addr=0x%02h data0=0x%02h", _irq_vector, _addr_byte, _data0);

        if (_irq_vector !== 16'h00A0) begin
            $display("FAIL tb_i2c_irq_vector: expected vector 0x00A0 got 0x%04h", _irq_vector);
            _errors = _errors + 1;
        end

        if (!_start_seen || !_stop_seen) begin
            $display("FAIL tb_i2c_irq_vector: missing START/STOP evidence");
            _errors = _errors + 1;
        end

        mmio_read(16'h8402, _rd);
        if (_rd[4] !== 1'b1) begin
            $display("FAIL tb_i2c_irq_vector: I2C IRQ_PEND not visible in STATUS 0x%04h", _rd);
            _errors = _errors + 1;
        end

        if (_errors == 0) begin
            $display("PASS tb_i2c_irq_vector");
        end else begin
            $display("FAIL tb_i2c_irq_vector errors=%0d", _errors);
            $fatal(1);
        end
        $finish;
    end

endmodule
