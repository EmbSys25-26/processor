`timescale 1ns / 1ps

module timer16(
    input wire i_clk,
    input wire i_rst,
    input wire i_sel,
    input wire i_we,
    input wire i_re,
    input wire [1:0] i_addr,
    input wire [15:0] i_wdata,
    output wire [15:0] o_rdata,
    output wire o_rdy,
    output wire o_int_req
);

/*************************************************************************************
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/
    reg [15:0] _rdata;
    reg _int_req;

    (* mark_debug = "true" *) reg _int_en;
    (* mark_debug = "true" *) reg _timer_mode;
    (* mark_debug = "true" *) wire _int_req_dbg;

    (* mark_debug = "true" *) reg [15:0] _cnt_start;
    (* mark_debug = "true" *) reg [15:0] _cnt;
    wire _tick;
    wire [16:0] _cnt_nxt;
    wire _overflow;

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

/*************************************************************************************
 * 2.1 Control and Counter
 ************************************************************************************/
    assign o_rdy = i_sel;
    assign _int_req_dbg = _int_req;

    always @(posedge i_clk) begin
        if (i_rst) begin
            _int_en <= 1'b0;
            _timer_mode <= 1'b1;
            _cnt_start <= 16'hFFF0;
        end else if (i_sel && i_we && (i_addr == 2'b00)) begin
            _int_en <= i_wdata[0];
            _timer_mode <= i_wdata[1];
        end else if (i_sel && i_we && (i_addr == 2'b10)) begin
            _cnt_start <= i_wdata;
        end
    end

    assign _tick = _timer_mode;
    assign _cnt_nxt = {1'b0, _cnt} + 17'd1;
    assign _overflow = _cnt_nxt[16];

    always @(posedge i_clk) begin
        if (i_rst) begin
            _cnt <= 16'hFFF0;
        end else if (i_sel && i_we && (i_addr == 2'b10)) begin
            _cnt <= i_wdata;
        end else if (_tick) begin
            if (_overflow) begin
                _cnt <= _cnt_start;
            end else begin
                _cnt <= _cnt_nxt[15:0];
            end
        end
    end

/*************************************************************************************
 * 2.2 Interrupt Request and Readback
 ************************************************************************************/
    always @(posedge i_clk) begin
        if (i_rst) begin
            _int_req <= 1'b0;
        end else if (i_sel && i_we && (i_addr == 2'b01)) begin
            _int_req <= 1'b0;
        end else if (_tick && _overflow && _int_en) begin
            _int_req <= 1'b1;
        end
    end

    always @(*) begin
        if (!i_sel || !i_re) begin
            _rdata = 16'h0000;
        end else begin
            case (i_addr)
                2'b00: _rdata = {14'b0, _timer_mode, _int_en};
                2'b01: _rdata = {15'b0, _int_req};
                2'b10: _rdata = _cnt_start;
                2'b11: _rdata = _cnt;
                default: _rdata = 16'h0000;
            endcase
        end
    end

    assign o_rdata = _rdata;
    assign o_int_req = _int_req;

endmodule
