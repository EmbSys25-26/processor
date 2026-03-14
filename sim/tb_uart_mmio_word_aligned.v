`timescale 1ns / 1ps
`default_nettype none

// MUST UNCOMMENT `define SIM in peripheral bus

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
        .i_rst_ext(_rst),
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
        .o_irq_vector(_irq_vector),
        .o_wdt_rst()
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
 *
 * Drive signals on negedge (blocking assignments) so they are stable at the
 * following posedge when the DUT's registered logic samples them.
 * Using NBAs (<=) here causes a one-cycle skew where the DUT sees stale values.
 ************************************************************************************/
    task mmio_write(input [15:0] i_addr, input [15:0] i_data);
        begin
            @(negedge _clk);
            _addr  = i_addr;
            _wdata = i_data;
            _sel   = 1'b1;
            _we    = 1'b1;
            _re    = 1'b0;
            @(posedge _clk);        // DUT latches write on this edge
            @(negedge _clk);
            _sel   = 1'b0;
            _we    = 1'b0;
            _addr  = 16'h0000;
            _wdata = 16'h0000;
            @(posedge _clk);        // Settle: _tx_start pulse reaches TX FSM
        end
    endtask

    task mmio_read(input [15:0] i_addr, output [15:0] o_data);
        begin
            @(negedge _clk);
            _addr  = i_addr;
            _wdata = 16'h0000;
            _sel   = 1'b1;
            _we    = 1'b0;
            _re    = 1'b1;
            @(posedge _clk);        // Combinatorial _rdata valid here
            #1;                     // Let rdata settle past posedge
            o_data = _rdata;
            @(negedge _clk);
            _sel   = 1'b0;
            _re    = 1'b0;
            _addr  = 16'h0000;
        end
    endtask

/*************************************************************************************
 * 2.3 Deterministic stimulus and UART word-alignment checks
 *
 * Address map - periph_bus routes i_addr[2:1] to uart_mmio's i_addr[1:0]:
 *
 *   i_addr   [2:1]  uart_mmio register
 *   0x8300   2'b00  SBUF   (TX write / RX read)
 *   0x8302   2'b01  STATUS (bit0 = tx_busy, bit1 = rx_pending)
 *
 * NOTE: periph_bus uses i_addr[2:1], NOT i_addr[1:0].
 * Therefore STATUS is at byte address 0x8302, not 0x8301.
 * 0x8301 maps to addr[2:1]=2'b00 = SBUF - same as 0x8300 (byte 1 of same word).
 ************************************************************************************/
    reg [15:0] _rd;
    integer _timeout;
    initial begin
        repeat (5) @(posedge _clk);
        _rst <= 1'b0;
        repeat (2) @(posedge _clk);

        // Write UART DATA at 0x8300 (SBUF) and confirm STATUS at 0x8302 reports tx_busy.
        mmio_write(16'h8300, 16'h005A);

        _timeout = 200;
        _rd = 16'h0000;
        while ((_timeout > 0) && (_rd[0] == 1'b0)) begin
            mmio_read(16'h8302, _rd);   // STATUS: addr[2:1]=2'b01
            _timeout = _timeout - 1;
        end
        if (_rd[0] !== 1'b1) begin
            $display("FAIL tb_uart_mmio_word_aligned: STATUS tx_busy bit not observed via 0x8302");
            _errors = _errors + 1;
        end

        // Confirm tx_busy eventually clears.
        _timeout = 2000;
        while ((_timeout > 0) && (_rd[0] == 1'b1)) begin
            mmio_read(16'h8302, _rd);   // STATUS
            _timeout = _timeout - 1;
        end
        if (_rd[0] !== 1'b0) begin
            $display("FAIL tb_uart_mmio_word_aligned: STATUS tx_busy bit did not clear");
            _errors = _errors + 1;
        end

        // Force rx_pending via hierarchical reference, wait one edge for
        // the combinatorial readback path to reflect the new value.
        dut.u_uart._rx_pending = 1'b1;
        @(posedge _clk); #1;
        mmio_read(16'h8302, _rd);       // STATUS
        if (_rd[1] !== 1'b1) begin
            $display("FAIL tb_uart_mmio_word_aligned: STATUS rx_pending bit not visible via 0x8302");
            _errors = _errors + 1;
        end

        // Clear rx_pending via STATUS clear-on-write at 0x8302.
        mmio_write(16'h8302, 16'h0002);
        mmio_read(16'h8302, _rd);       // STATUS
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