`timescale 1ns / 1ps
`default_nettype none

module tb_timer_start_reg;

/*************************************************************************************
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/
    reg _clk = 1'b0;
    reg _rst = 1'b1;

    reg _t16_sel = 1'b0;
    reg _t16_we = 1'b0;
    reg _t16_re = 1'b0;
    reg [1:0] _t16_addr = 2'b00;
    reg [15:0] _t16_wdata = 16'h0000;
    wire [15:0] _t16_rdata;
    wire _t16_rdy;
    wire _t16_int_req;

    reg _th_sel = 1'b0;
    reg _th_we = 1'b0;
    reg _th_re = 1'b0;
    reg [1:0] _th_addr = 2'b00;
    reg [15:0] _th_wdata = 16'h0000;
    wire [15:0] _th_rdata;
    wire _th_rdy;
    wire _th_int_req;

    integer _errors = 0;
    integer _k;

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

/*************************************************************************************
 * 2.1 DUT and clock generation
 ************************************************************************************/
    always #5 _clk = ~_clk;

    timer16 u_t16 (
        .i_clk(_clk),
        .i_rst(_rst),
        .i_sel(_t16_sel),
        .i_we(_t16_we),
        .i_re(_t16_re),
        .i_addr(_t16_addr),
        .i_wdata(_t16_wdata),
        .o_rdata(_t16_rdata),
        .o_rdy(_t16_rdy),
        .o_int_req(_t16_int_req)
    );

    timerH u_th (
        .i_clk(_clk),
        .i_rst(_rst),
        .i_sel(_th_sel),
        .i_we(_th_we),
        .i_re(_th_re),
        .i_addr(_th_addr),
        .i_wdata(_th_wdata),
        .o_rdata(_th_rdata),
        .o_rdy(_th_rdy),
        .o_int_req(_th_int_req)
    );

/*************************************************************************************
 * 2.2 Timer MMIO helpers
 ************************************************************************************/
    task t16_write(input [1:0] i_addr, input [15:0] i_data);
        begin
            _t16_sel = 1'b1;
            _t16_we = 1'b1;
            _t16_re = 1'b0;
            _t16_addr = i_addr;
            _t16_wdata = i_data;
            @(posedge _clk);
            #1;
            _t16_sel = 1'b0;
            _t16_we = 1'b0;
            _t16_addr = 2'b00;
            _t16_wdata = 16'h0000;
        end
    endtask

    task t16_read(input [1:0] i_addr, output [15:0] o_data);
        begin
            _t16_sel = 1'b1;
            _t16_we = 1'b0;
            _t16_re = 1'b1;
            _t16_addr = i_addr;
            #1;
            o_data = _t16_rdata;
            @(posedge _clk);
            _t16_sel = 1'b0;
            _t16_re = 1'b0;
            _t16_addr = 2'b00;
        end
    endtask

    task th_write(input [1:0] i_addr, input [15:0] i_data);
        begin
            _th_sel = 1'b1;
            _th_we = 1'b1;
            _th_re = 1'b0;
            _th_addr = i_addr;
            _th_wdata = i_data;
            @(posedge _clk);
            #1;
            _th_sel = 1'b0;
            _th_we = 1'b0;
            _th_addr = 2'b00;
            _th_wdata = 16'h0000;
        end
    endtask

    task th_read(input [1:0] i_addr, output [15:0] o_data);
        begin
            _th_sel = 1'b1;
            _th_we = 1'b0;
            _th_re = 1'b1;
            _th_addr = i_addr;
            #1;
            o_data = _th_rdata;
            @(posedge _clk);
            _th_sel = 1'b0;
            _th_re = 1'b0;
            _th_addr = 2'b00;
        end
    endtask

/*************************************************************************************
 * 2.3 Stimulus and checks
 ************************************************************************************/
    reg [15:0] _rd;

    initial begin
        repeat (4) @(posedge _clk);
        _rst = 1'b0;

        // Enable timer mode + interrupt for both timers.
        t16_write(2'b00, 16'h0003);
        th_write(2'b00, 16'h0003);

        // Program start counter values.
        t16_write(2'b10, 16'hFFFC);
        th_write(2'b10, 16'hFFFA);

        $display("WAVE T16 write: wdata=0x%04h cnt_start=0x%04h cnt=0x%04h", 16'hFFFC, u_t16._cnt_start, u_t16._cnt);
        $display("WAVE TH  write: wdata=0x%04h cnt_start=0x%04h cnt=0x%04h", 16'hFFFA, u_th._cnt_start, u_th._cnt);

        // Checks values directly with hierarchical references. 
        if (u_t16._cnt_start !== 16'hFFFC) begin
            $display("FAIL T16 start register mismatch");
            _errors = _errors + 1;
        end
        if (u_th._cnt_start !== 16'hFFFA) begin
            $display("FAIL TH start register mismatch");
            _errors = _errors + 1;
        end

        // Read back start register values over MMIO.
        t16_read(2'b10, _rd);
        if (_rd !== 16'hFFFC) begin
            $display("FAIL T16 read CNT_INIT expected 0xFFFC got 0x%04h", _rd);
            _errors = _errors + 1;
        end

        th_read(2'b10, _rd);
        if (_rd !== 16'hFFFA) begin
            $display("FAIL TH read CNT_INIT expected 0xFFFA got 0x%04h", _rd);
            _errors = _errors + 1;
        end

        // Waveform-style progression around overflow/reload.
        for (_k = 0; _k < 6; _k = _k + 1) begin
            @(posedge _clk);
            $display("WAVE T16 cyc=%0d cnt=0x%04h cnt_start=0x%04h int_req=%0b", _k, u_t16._cnt, u_t16._cnt_start, _t16_int_req);
            $display("WAVE TH  cyc=%0d cnt=0x%04h cnt_start=0x%04h int_req=%0b", _k, u_th._cnt, u_th._cnt_start, _th_int_req);
        end

        // Both should have overflowed and reloaded to start value.
        if (!_t16_int_req) begin
            $display("FAIL T16 int_req did not assert after overflow");
            _errors = _errors + 1;
        end
        if (!_th_int_req) begin
            $display("FAIL TH int_req did not assert after overflow");
            _errors = _errors + 1;
        end

        // Clear interrupt latch.
        t16_write(2'b01, 16'h0001);
        th_write(2'b01, 16'h0001);

        if (_t16_int_req) begin
            $display("FAIL T16 int_req did not clear");
            _errors = _errors + 1;
        end
        if (_th_int_req) begin
            $display("FAIL TH int_req did not clear");
            _errors = _errors + 1;
        end

        // Read live counters (debug location +0x06).
        t16_read(2'b11, _rd);
        $display("WAVE T16 live counter read: 0x%04h", _rd);
        th_read(2'b11, _rd);
        $display("WAVE TH  live counter read: 0x%04h", _rd);

        if (_errors == 0) begin
            $display("PASS tb_timer_start_reg");
        end else begin
            $display("FAIL tb_timer_start_reg errors=%0d", _errors);
            $fatal(1);
        end

        $finish;
    end
endmodule
