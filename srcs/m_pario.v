`timescale 1ns / 1ps

module pario(
    input wire i_clk,
    input wire i_rst,
    input wire i_sel,
    input wire i_we,
    input wire i_re,
    input wire [1:0] i_addr,
    input wire [15:0] i_wdata,
    output wire [15:0] o_rdata,
    output wire o_rdy,
    input wire [3:0] i_i,
    output wire [3:0] o_o,
    output wire o_int_req
);

/*************************************************************************************
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/
    reg [15:0] _rdata;
    reg [3:0] _o;
    wire _int_req;

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

/*************************************************************************************
 * 2.1 Debounce + rising-edge detect on button 3 (i_i[3] / pin Y16)
 *
 *  Counter runs while i_i[3] differs from the current stable level.
 *  When it holds for DEBOUNCE_MAX cycles (~20 ms @ 100 MHz) the stable
 *  level is committed.  o_int_req is a 1-cycle pulse on the rising edge
 *  of the debounced signal — exactly one IRQ per physical button press.
 *  Buttons 2:0 are unaffected and remain readable via the input register.
 ************************************************************************************/
    localparam DEBOUNCE_MAX = 2_000_000;  // 20 ms @ 100 MHz

    reg [20:0] _db_cnt;
    reg        _db_stable;
    reg        _db_prev;

    assign o_rdy   = i_sel;
    assign _int_req = _db_stable & ~_db_prev;

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            _db_cnt    <= 0;
            _db_stable <= 0;
            _db_prev   <= 0;
        end else begin
            _db_prev <= _db_stable;
            if (i_i[3] == _db_stable)
                _db_cnt <= 0;
            else if (_db_cnt == DEBOUNCE_MAX - 1) begin
                _db_stable <= i_i[3];
                _db_cnt    <= 0;
            end else
                _db_cnt <= _db_cnt + 1;
        end
    end

    always @(posedge i_clk) begin
        if (i_rst) begin
            _o <= 4'h0;
        end else if (i_sel && i_we) begin
            case (i_addr)
                2'b00: _o <= i_wdata[3:0];
                default: ;
            endcase
        end
    end

/*************************************************************************************
 * 2.2 Readback
 ************************************************************************************/
    always @(*) begin
        if (!i_sel || !i_re) begin
            _rdata = 16'h0000;
        end else begin
            case (i_addr)
                2'b00: _rdata = {12'h000, _o};
                2'b10: _rdata = {12'h000, i_i};
                default: _rdata = 16'h0000;
            endcase
        end
    end

    assign o_rdata = _rdata;
    assign o_o = _o;
    assign o_int_req = _int_req;

endmodule
