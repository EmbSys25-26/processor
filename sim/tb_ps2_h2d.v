`timescale 1ns / 1ps
`default_nettype none

/*************************************************************************************
 * PS2 H2D TESTBENCH
 *  Verifies the PS/2 host-to-device transmission protocol.
 *  Instantiates the ps2_h2d DUT and a ps2_device_model that simulates
 *  a PS/2 keyboard device.
 *
 *  Tests:
 *  - 0xED: set LEDs command
 *  - 0xF4: enable scanning command
 *
 *  Checks per frame:
 *  - start bit = 0
 *  - data byte matches expected
 *  - odd parity correct
 *  - stop bit = 1
 *  - o_tx_done pulsed after transmission
 ********************************************************/
 
 
 
module tb_ps2_h2d;

/*************************************************************************************
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/
    reg _clk = 1'b0;
    reg _rst = 1'b1;

    reg       _start = 1'b0;
    reg [7:0] _data  = 8'h00;

    wire _tx_done;
    wire _tx_busy;

    // tri1 simulates open-drain pull-up resistors
    tri1 _ps2_clk;
    tri1 _ps2_data;

    wire       _frame_done;
    wire       _start_ok;
    wire       _parity_ok;
    wire       _stop_ok;
    wire [7:0] _rx_data;

    reg _tx_done_latched = 1'b0;
    integer _errors = 0;

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

/*************************************************************************************
 * 2.1 DUT, device model, and clock
 ************************************************************************************/
    always #5 _clk = ~_clk; // 100 MHz

    ps2_h2d dut (
        .i_clk        (_clk),
        .i_rst        (_rst),
        .i_start      (_start),
        .i_data       (_data),
        .i_fall_edge  (_fall_edge),
        .i_ps2_data_s (_ps2_data_s),
        .io_ps2_clk   (_ps2_clk),
        .io_ps2_data  (_ps2_data),
        .o_tx_done    (_tx_done),
        .o_tx_busy    (_tx_busy),
        .o_tx_aerr    ()
    );

    tb_ps2_device_model device (
        .i_clk       (_clk),
        .i_rst       (_rst),
        .io_ps2_clk  (_ps2_clk),
        .io_ps2_data (_ps2_data),
        .o_frame_done(_frame_done),
        .o_start_ok  (_start_ok),
        .o_parity_ok (_parity_ok),
        .o_stop_ok   (_stop_ok),
        .o_data      (_rx_data)
    );

    // 2FF sync (mirrors what mmio does)
    reg [1:0] _clk_sync;
    reg [1:0] _data_sync;
    always @(posedge _clk) begin
        _clk_sync  <= {_clk_sync[0],  _ps2_clk};
        _data_sync <= {_data_sync[0], _ps2_data};
    end
    wire _ps2_clk_s  = _clk_sync[1];
    wire _ps2_data_s = _data_sync[1];

    reg _clk_prev;
    always @(posedge _clk) _clk_prev <= _ps2_clk_s;
    wire _fall_edge = _clk_prev & ~_ps2_clk_s;

    // latch tx_done since it is a single cycle pulse
    always @(posedge _tx_done or posedge _start) begin
        if (_start) _tx_done_latched <= 1'b0;
        else        _tx_done_latched <= 1'b1;
    end

/*************************************************************************************
 * 2.2 Stimulus and checks
 ************************************************************************************/
    initial begin
        repeat (5000) @(posedge _clk);
        _rst <= 1'b0;
        repeat (50) @(posedge _clk);

        // --- Test 1: send 0xED (set LEDs command) ---
        $display("TEST 1: send 0xED");
        _data  <= 8'hED;
        _start <= 1'b1;
        @(posedge _clk);
        _start <= 1'b0;

        device.receive_frame(8'hED);
        

        if (!_tx_done_latched) begin
            $display("FAIL tb_ps2_h2d: tx_done not received test 1");
            _errors = _errors + 1;
        end else $display("TEST 1: tx_done received");

        if (!_start_ok) begin
            $display("FAIL tb_ps2_h2d: start bit error test 1");
            _errors = _errors + 1;
        end
        if (_rx_data !== 8'hED) begin
            $display("FAIL tb_ps2_h2d: data mismatch expected=0xED got=0x%02h", _rx_data);
            _errors = _errors + 1;
        end
        if (!_parity_ok) begin
            $display("FAIL tb_ps2_h2d: parity error test 1");
            _errors = _errors + 1;
        end
        if (!_stop_ok) begin
            $display("FAIL tb_ps2_h2d: stop bit error test 1");
            _errors = _errors + 1;
        end
        
        #(40000 * 8);
        // --- Test 2: send 0xF4 (enable scanning command) ---
        $display("TEST 2: send 0xF4");
        _data  <= 8'hF4;
        _start <= 1'b1;
        @(posedge _clk);
        _start <= 1'b0;

        device.receive_frame(8'hF4);

        if (!_tx_done_latched) begin
            $display("FAIL tb_ps2_h2d: tx_done not received test 2");
            _errors = _errors + 1;
        end else $display("TEST 2: tx_done received");

        if (!_start_ok) begin
            $display("FAIL tb_ps2_h2d: start bit error test 2");
            _errors = _errors + 1;
        end
        if (_rx_data !== 8'hF4) begin
            $display("FAIL tb_ps2_h2d: data mismatch expected=0xF4 got=0x%02h", _rx_data);
            _errors = _errors + 1;
        end
        if (!_parity_ok) begin
            $display("FAIL tb_ps2_h2d: parity error test 2");
            _errors = _errors + 1;
        end
        if (!_stop_ok) begin
            $display("FAIL tb_ps2_h2d: stop bit error test 2");
            _errors = _errors + 1;
        end

        repeat (10) @(posedge _clk);

        // --- Results ---
        if (_errors == 0) begin
            $display("PASS tb_ps2_h2d");
        end else begin
            $display("FAIL tb_ps2_h2d errors=%0d", _errors);
            $fatal(1);
        end
        $finish;
    end

endmodule
