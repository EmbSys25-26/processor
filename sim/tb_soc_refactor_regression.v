`timescale 1ns / 1ps
`default_nettype none

module tb_soc_refactor_regression;

/*************************************************************************************
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/
    reg _clk = 1'b0;
    reg _rst = 1'b1;
    reg [3:0] _par_i = 4'h0;
    reg _uart_rx = 1'b1;

    wire [3:0] _par_o;
    wire _uart_tx;

    integer _cycles = 0;
    integer _errors = 0;

    reg _seen_irq_take = 1'b0;
    reg _seen_in_irq = 1'b0;
    reg _seen_io = 1'b0;
    reg _seen_io_write = 1'b0;
    reg _seen_uart_pending = 1'b0;
    reg _seen_pario_change = 1'b0;

    localparam integer _clk_period_ns = 10;
    localparam integer _clk_freq = 100_000_000;
    localparam integer _baud_rate = 2_000_000;
    localparam integer _bit_cycles = (_clk_freq + (_baud_rate / 2)) / _baud_rate;
    localparam integer _bit_time_ns = _bit_cycles * _clk_period_ns;
    localparam integer _max_cycles = 6000;

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

/*************************************************************************************
 * 2.1 DUT and clock generation
 ************************************************************************************/
    always #5 _clk = ~_clk;

    soc dut (
        .i_clk(_clk),
        .i_rst(_rst),
        .i_par_i(_par_i),
        .o_par_o(_par_o),
        .i_uart_rx(_uart_rx),
        .o_uart_tx(_uart_tx)
    );

/*************************************************************************************
 * 2.2 UART stimulus helper
 ************************************************************************************/
    task uart_send_byte(input [7:0] i_b);
        integer _k;
        begin
            _uart_rx = 1'b0;
            #(_bit_time_ns);
            for (_k = 0; _k < 8; _k = _k + 1) begin
                _uart_rx = i_b[_k];
                #(_bit_time_ns);
            end
            _uart_rx = 1'b1;
            #(_bit_time_ns);
        end
    endtask

/*************************************************************************************
 * 2.3 Runtime monitors and pass/fail gate
 ************************************************************************************/
    always @(posedge _clk) begin
        if (!_rst) begin
            _cycles <= _cycles + 1;

            if (dut._irq_take) _seen_irq_take <= 1'b1;
            if (dut._in_irq) _seen_in_irq <= 1'b1;
            if (dut._io_sel) _seen_io <= 1'b1;
            if (dut._io_we) _seen_io_write <= 1'b1;
            if (dut.u_periph.u_uart._rx_pending) _seen_uart_pending <= 1'b1;
            if (_par_o != 4'h0) _seen_pario_change <= 1'b1;

            if (_cycles >= _max_cycles) begin
                if (!_seen_irq_take) begin
                    $display("FAIL soc_regression: no irq_take observed");
                    _errors = _errors + 1;
                end
                if (!_seen_in_irq) begin
                    $display("FAIL soc_regression: no in_irq observed");
                    _errors = _errors + 1;
                end
                if (!_seen_io) begin
                    $display("FAIL soc_regression: no MMIO select observed");
                    _errors = _errors + 1;
                end
                if (!_seen_io_write) begin
                    $display("FAIL soc_regression: no MMIO write observed");
                    _errors = _errors + 1;
                end
                if (!_seen_uart_pending) begin
                    $display("FAIL soc_regression: no UART pending observed");
                    _errors = _errors + 1;
                end
                if (!_seen_pario_change) begin
                    $display("WARN soc_regression: PARIO output never changed");
                end

                if (_errors == 0) begin
                    $display("PASS tb_soc_refactor_regression");
                end else begin
                    $display("FAIL tb_soc_refactor_regression errors=%0d", _errors);
                    $fatal(1);
                end
                $finish;
            end
        end
    end

/*************************************************************************************
 * 2.4 Stimulus sequence
 ************************************************************************************/
    initial begin
        repeat (5) @(posedge _clk);
        _rst = 1'b0;

        repeat (40) @(posedge _clk);
        uart_send_byte(8'hA5);
    end
endmodule
