`timescale 1ns / 1ps
`default_nettype none

module tb_Soc;
    reg _clk = 1'b0;
    reg _rst = 1'b1;

    reg [3:0] _par_i = 4'h0;
    wire [3:0] _par_o;

    reg _uart_rx = 1'b1;
    wire _uart_tx;

    soc dut (
        .i_clk(_clk),
        .i_rst(_rst),
        .i_par_i(_par_i),
        .o_par_o(_par_o),
        .i_uart_rx(_uart_rx),
        .o_uart_tx(_uart_tx)
    );

    always #5 _clk = ~_clk;

    task wait_clocks(input integer i_n);
        repeat (i_n) @(posedge _clk);
    endtask

    localparam integer _clk_period_ns = 10;
    localparam integer _clk_freq = 100_000_000;
`ifdef SIM
    localparam integer _baud_rate = 2_000_000;
`else
    localparam integer _baud_rate = 115200;
`endif
    localparam integer _bit_cycles = (_clk_freq + (_baud_rate / 2)) / _baud_rate;
    localparam integer _bit_time_ns = _bit_cycles * _clk_period_ns;

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

`ifdef TB_UART_MMIO_TEST
    reg [15:0] _mmio_rd;
    reg [7:0] _mmio_expect;

    task periph_write(input [1:0] i_a, input [15:0] i_d);
        begin
            force dut.u_periph.i_addr = 16'h8300 | {14'b0, i_a};
            force dut.u_periph.i_wdata = i_d;
            force dut.u_periph.i_sel = 1'b1;
            force dut.u_periph.i_we = 1'b1;
            force dut.u_periph.i_re = 1'b0;
            @(posedge _clk);
            release dut.u_periph.i_sel;
            release dut.u_periph.i_we;
            release dut.u_periph.i_re;
            release dut.u_periph.i_addr;
            release dut.u_periph.i_wdata;
        end
    endtask

    task periph_read(input [1:0] i_a, output [15:0] o_d);
        begin
            force dut.u_periph.i_addr = 16'h8300 | {14'b0, i_a};
            force dut.u_periph.i_wdata = 16'h0000;
            force dut.u_periph.i_sel = 1'b1;
            force dut.u_periph.i_we = 1'b0;
            force dut.u_periph.i_re = 1'b1;
            @(posedge _clk);
            o_d = dut.u_periph.o_rdata;
            release dut.u_periph.i_sel;
            release dut.u_periph.i_we;
            release dut.u_periph.i_re;
            release dut.u_periph.i_addr;
            release dut.u_periph.i_wdata;
        end
    endtask
`endif

`ifdef TB_USE_INTERNALS
    wire [15:0] _i_ad = dut._i_ad;
    wire [15:0] _d_ad = dut._d_ad;
    wire _io_sel = dut._io_sel;
    wire _io_we = dut._io_we;
    wire _io_re = dut._io_re;
    wire _irq_take = dut._irq_take;
    wire [15:0] _irq_vector = dut._irq_vector;
    wire _in_irq = dut._in_irq;
    wire _uart_irq = dut.u_periph.u_uart.o_irq_req;
    wire _uart_rx_pending = dut.u_periph.u_uart._rx_pending;
    wire [7:0] _uart_rx_data = dut.u_periph.u_uart._rx_data;
    wire _uart_tx_busy = dut.u_periph.u_uart._tx_busy;
`endif

    integer _cycles = 0;
    integer _max_cycles = 3000;
    always @(posedge _clk) begin
        if (!_rst) begin
            _cycles <= _cycles + 1;
        end
    end

    initial begin
        if (!$value$plusargs("max-cycles=%d", _max_cycles)) begin
            _max_cycles = 3000;
        end
        wait (_rst == 1'b0);
        wait (_cycles >= _max_cycles);
        $display("TB timeout/guard reached at cycles=%0d", _cycles);
        $finish;
    end

    initial begin
        wait_clocks(5);
        _rst = 1'b0;

        wait_clocks(10);
        wait_clocks(40);
    end

    integer _b;
    initial begin
        if ($value$plusargs("UART_BYTE=%h", _b)) begin
            wait_clocks(20);
            uart_send_byte(_b[7:0]);
        end
    end

`ifdef TB_UART_MMIO_TEST
    initial begin
        wait_clocks(10);
        _rst = 1'b0;
        wait_clocks(10);

        _mmio_expect = 8'hA5;
        uart_send_byte(_mmio_expect);
        wait_clocks(2);
        wait (dut.u_periph.u_uart.o_irq_req == 1'b1);

        periph_read(2'b01, _mmio_rd);
        if (_mmio_rd[1] !== 1'b1) begin
            $display("UART MMIO RX pending not set as expected");
        end

        periph_read(2'b00, _mmio_rd);
        if (_mmio_rd[7:0] !== _mmio_expect) begin
            $display("UART MMIO RX mismatch got 0x%02h expected 0x%02h", _mmio_rd[7:0], _mmio_expect);
        end

        periph_write(2'b00, 16'h005A);
        periph_read(2'b01, _mmio_rd);
        if (_mmio_rd[0] !== 1'b1) begin
            $display("UART MMIO TX busy not set after write");
        end

        wait (dut.u_periph.u_uart._tx_busy == 1'b0);
        $display("UART MMIO test done");
    end
`endif

`ifdef TB_USE_INTERNALS
    reg _uart_irq_d;
    reg _irq_take_d;
    always @(posedge _clk) begin
        if (_rst) begin
            _uart_irq_d <= 1'b0;
            _irq_take_d <= 1'b0;
        end else begin
            _uart_irq_d <= _uart_irq;
            _irq_take_d <= _irq_take;
            if (_uart_irq && !_uart_irq_d) begin
                $display("UART IRQ set  t=%0t  rx_data=0x%02h  rx_pending=%0b", $time, _uart_rx_data, _uart_rx_pending);
            end
            if (_irq_take && !_irq_take_d) begin
                $display("IRQ take      t=%0t  vector=0x%04h  in_irq=%0b", $time, _irq_vector, _in_irq);
            end
        end
    end
`endif

    initial begin
`ifdef TB_USE_INTERNALS
        $display("time   cycles  rst  i_ad   d_ad   io_sel io_we io_re  irq_take vector  uart_irq rx_pend tx_busy par_o");
        $monitor("%0t %6d   %0b   0x%04h 0x%04h   %0b     %0b   %0b   %0b    0x%04h   %0b      %0b      %0b     0x%1h",
                 $time, _cycles, _rst, _i_ad, _d_ad, _io_sel, _io_we, _io_re, _irq_take, _irq_vector, _uart_irq, _uart_rx_pending, _uart_tx_busy, _par_o);
`else
        $display("time   cycles  rst  par_o");
        $monitor("%0t %6d   %0b   0x%1h", $time, _cycles, _rst, _par_o);
`endif
    end

    initial begin
        $dumpfile("waves_soc.vcd");
        $dumpvars(0, tb_Soc);
    end
endmodule
