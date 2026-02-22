`timescale 1ns / 1ps
`default_nettype none

module tb_uart_mmio_word_aligned;

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
    tri1 _i2c_sda;
    tri1 _i2c_scl;
    reg _in_irq = 1'b0;
    reg _int_en = 1'b1;
    reg _irq_ret = 1'b0;

    wire [15:0] _rdata;
    wire _rdy;
    wire [3:0] _par_o;
    wire _uart_tx;
    wire _irq_take;
    wire [15:0] _irq_vector;

    integer _errors = 0;
    integer _cycles = 0;

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

/*************************************************************************************
 * 2.1 DUT and clock
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

    always @(posedge _clk) begin
        if (!_rst) begin
            _cycles <= _cycles + 1;
        end else begin
            _cycles <= 0;
        end
    end

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
            _re <= 1'b0;
            _addr <= 16'h0000;
            _wdata <= 16'h0000;
        end
    endtask

    task mmio_read(input [15:0] i_addr, output [15:0] o_data);
        begin
            _addr <= i_addr;
            _wdata <= 16'h0000;
            _sel <= 1'b1;
            _we <= 1'b0;
            _re <= 1'b1;
            @(posedge _clk);
            o_data = _rdata;
            _sel <= 1'b0;
            _we <= 1'b0;
            _re <= 1'b0;
            _addr <= 16'h0000;
        end
    endtask

/*************************************************************************************
 * 2.3 Deterministic stimulus and UART word-alignment checks
 ************************************************************************************/
    reg [15:0] _rd;
    integer _timeout;
    initial begin
        repeat (5) @(posedge _clk);
        _rst <= 1'b0;
        repeat (2) @(posedge _clk);

        // Write UART DATA at 0x8300 and confirm STATUS at 0x8302 reports tx_busy.
        mmio_write(16'h8300, 16'h005A);

        _timeout = 200;
        _rd = 16'h0000;
        while ((_timeout > 0) && (_rd[0] == 1'b0)) begin
            mmio_read(16'h8302, _rd);
            _timeout = _timeout - 1;
        end
        if (_rd[0] !== 1'b1) begin
            $display("FAIL tb_uart_mmio_word_aligned: STATUS tx_busy bit not observed via 0x8302");
            _errors = _errors + 1;
        end

        // Confirm tx_busy eventually clears.
        _timeout = 20000;
        while ((_timeout > 0) && (_rd[0] == 1'b1)) begin
            mmio_read(16'h8302, _rd);
            _timeout = _timeout - 1;
        end
        if (_rd[0] !== 1'b0) begin
            $display("FAIL tb_uart_mmio_word_aligned: STATUS tx_busy bit did not clear");
            _errors = _errors + 1;
        end

        // Drive rx_pending and verify STATUS clear-on-write at 0x8302.
        dut.u_uart._rx_pending = 1'b1;
        mmio_read(16'h8302, _rd);
        if (_rd[1] !== 1'b1) begin
            $display("FAIL tb_uart_mmio_word_aligned: STATUS rx_pending bit not visible via 0x8302");
            _errors = _errors + 1;
        end

        mmio_write(16'h8302, 16'h0002);
        mmio_read(16'h8302, _rd);
        if (_rd[1] !== 1'b0) begin
            $display("FAIL tb_uart_mmio_word_aligned: STATUS clear-on-write failed at 0x8302");
            _errors = _errors + 1;
        end

        if (_errors == 0) begin
            $display("PASS tb_uart_mmio_word_aligned");
        end else begin
            $display("FAIL tb_uart_mmio_word_aligned errors=%0d", _errors);
            $fatal(1);
        end
        $finish;
    end

endmodule
