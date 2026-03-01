`timescale 1ns / 1ps

/*************************************************************************************
 * WATCHDOG TIMER MODULE (WDT)
 *  MMIO Base Address : 0x8800  (i_addr[11:8] == 4'h8)
 *  Register map:
 *    0x8800  CTRL   [2:0] = {IEN, RSTEN, WEN}      R/W
 *    0x8802  STATUS [1:0] = {RSTF, WDTIF}          R / Write-1-to-clear
 *    0x8804  RELOAD 16-bit countdown start value    R/W
 *    0x8806  KEY    0xA5A5 = kick, 0xDEAD = disable W (reads 0x0000)
 *
 *  Prescaler : 16-bit free-running ÷65536 -> tick every 655.36 µs @ 100 MHz
 *  Counter   : 16-bit down-counter; timeout when it wraps through 0
 ************************************************************************************/

module wdt (
    input  wire        i_clk,
    input  wire        i_rst,
    input  wire        i_sel,
    input  wire        i_we,
    input  wire        i_re,
    input  wire [1:0]  i_addr,
    input  wire [15:0] i_wdata,
    output wire [15:0] o_rdata,
    output wire        o_rdy,
    output wire        o_int_req,
    output wire        o_rst_req
);

/*************************************************************************************
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/

    reg [15:0] _rdata;

    // CTRL fields
    (* mark_debug = "true" *) reg _wen;
    (* mark_debug = "true" *) reg _rsten;
    (* mark_debug = "true" *) reg _ien;

    // STATUS flags (write-1-to-clear)
    (* mark_debug = "true" *) reg _wdtif;
    (* mark_debug = "true" *) reg _rstf;

    // RELOAD register
    (* mark_debug = "true" *) reg [15:0] _reload;

    // Prescaler and counter
    (* mark_debug = "true" *) reg [15:0] _presc;
    (* mark_debug = "true" *) reg [15:0] _cnt;

    // 4-cycle reset pulse counter
    (* mark_debug = "true" *) reg [2:0] _rst_pulse_cnt;

    // WEN rising-edge detection
    reg _wen_prev;

    // Combinational helpers
    wire _tick;
    wire _timeout;
    wire _key_kick;
    wire _key_stop;
    wire _wen_rise;

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

/*************************************************************************************
 * 2.1 Combinational helpers
 ************************************************************************************/

    assign o_rdy      = i_sel;

    // Tick: prescaler all-ones -> wraps next cycle -> decrement counter this cycle
    assign _tick      = _wen && (&_presc);

    // Timeout: about to tick and counter will reach zero
    assign _timeout   = _tick && (_cnt == 16'h0001);

    // KEY decoder
    assign _key_kick  = i_sel && i_we && (i_addr == 2'b11) && (i_wdata == 16'hA5A5);
    assign _key_stop  = i_sel && i_we && (i_addr == 2'b11) && (i_wdata == 16'hDEAD);

    // WEN rising edge (0->1) -> reload counter and clear prescaler
    assign _wen_rise  = _wen && !_wen_prev;

/*************************************************************************************
 * 2.2 CTRL register  (addr 2'b00)
 *     [0] WEN   [1] RSTEN   [2] IEN
 ************************************************************************************/

    always @(posedge i_clk) begin
        if (i_rst) begin
            _wen   <= 1'b0;
            _rsten <= 1'b0;
            _ien   <= 1'b0;
        end else if (i_sel && i_we && (i_addr == 2'b00)) begin
            _wen   <= i_wdata[0];
            _rsten <= i_wdata[1];
            _ien   <= i_wdata[2];
        end else if (_key_stop) begin
            _wen   <= 1'b0;
        end
    end

    // Track previous WEN for rising-edge detection
    always @(posedge i_clk) begin
        if (i_rst) _wen_prev <= 1'b0;
        else       _wen_prev <= _wen;
    end

/*************************************************************************************
 * 2.3 RELOAD register  (addr 2'b10)
 ************************************************************************************/

    always @(posedge i_clk) begin
        if (i_rst) begin
            _reload <= 16'hFFFF;
        end else if (i_sel && i_we && (i_addr == 2'b10)) begin
            _reload <= i_wdata;
        end
    end

/*************************************************************************************
 * 2.4 Prescaler
 *     Cleared on: reset / WEN rise / kick / timeout
 *     Increments every cycle while WEN=1
 ************************************************************************************/

    always @(posedge i_clk) begin
        if (i_rst) begin
            _presc <= 16'h0000;
        end else if (_key_kick || _wen_rise || _timeout) begin
            _presc <= 16'h0000;
        end else if (_wen) begin
            _presc <= _presc + 1;
        end
    end

/*************************************************************************************
 * 2.5 Down-counter
 *     Loaded from RELOAD on: reset / WEN rise / kick / timeout
 *     Decremented on each tick
 ************************************************************************************/

    always @(posedge i_clk) begin
        if (i_rst) begin
            _cnt <= 16'hFFFF;
        end else if (_key_kick || _wen_rise || _timeout) begin
            _cnt <= _reload;
        end else if (_tick) begin
            _cnt <= _cnt - 1;
        end
    end

/*************************************************************************************
 * 2.6 STATUS flags  (addr 2'b01) - write-1-to-clear
 *     [0] WDTIF : set on any timeout
 *     [1] RSTF  : set on timeout when RSTEN=1
 ************************************************************************************/

    always @(posedge i_clk) begin
        if (i_rst) begin
            _wdtif <= 1'b0;
        end else if (i_sel && i_we && (i_addr == 2'b01) && i_wdata[0]) begin
            _wdtif <= 1'b0;
        end else if (_timeout) begin
            _wdtif <= 1'b1;
        end
    end

    always @(posedge i_clk) begin
        if (i_rst) begin
            _rstf <= 1'b0;
        end else if (i_sel && i_we && (i_addr == 2'b01) && i_wdata[1]) begin
            _rstf <= 1'b0;
        end else if (_timeout && _rsten) begin
            _rstf <= 1'b1;
        end
    end

/*************************************************************************************
 * 2.7 4-cycle reset pulse (o_rst_req)
 *     On timeout + RSTEN: load pulse counter with 4
 *     o_rst_req stays high while counter > 0
 ************************************************************************************/

    always @(posedge i_clk) begin
        if (i_rst) begin
            _rst_pulse_cnt <= 3'b000;
        end else if (_timeout && _rsten) begin
            _rst_pulse_cnt <= 3'd4;
        end else if (_rst_pulse_cnt != 3'b000) begin
            _rst_pulse_cnt <= _rst_pulse_cnt - 1;
        end
    end

    assign o_rst_req = (_rst_pulse_cnt != 3'b000);

/*************************************************************************************
 * 2.8 Interrupt request
 *     Combinational: WDTIF flag gated by IEN
 ************************************************************************************/

    assign o_int_req = _wdtif && _ien;

/*************************************************************************************
 * 2.9 Read mux
 ************************************************************************************/

    always @(*) begin
        if (!i_sel || !i_re) begin
            _rdata = 16'h0000;
        end else begin
            case (i_addr)
                2'b00: _rdata = {13'b0, _ien, _rsten, _wen};
                2'b01: _rdata = {14'b0, _rstf, _wdtif};
                2'b10: _rdata = _reload;
                2'b11: _rdata = 16'h0000;   // KEY is write-only
                default: _rdata = 16'h0000;
            endcase
        end
    end

    assign o_rdata = _rdata;

endmodule
