`timescale 1ns / 1ps

`include "constants.vh"

/*
Branch Decision Unit (BDU)
Takes the condition code and current CC values, outputs whether a branch should be taken or not
Preserves original semantics of the single-cycle processor.
*/

module bdu(
    input wire [3:0] i_cond,
    input wire i_ccz,
    input wire i_ccn,
    input wire i_ccc,
    input wire i_ccv,
    output wire o_take
);

/*************************************************************************************
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/
    reg _t;

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

    always @(*) begin
        case (i_cond & 4'b1110)
            `BR_BR:   _t = 1'b1;
            `BR_BEQ:  _t = i_ccz;
            `BR_BC:   _t = i_ccc;
            `BR_BV:   _t = i_ccv;
            `BR_BLT:  _t = i_ccn ^ i_ccv;
            `BR_BLE:  _t = (i_ccn ^ i_ccv) | i_ccz;
            `BR_BLTU: _t = ~i_ccz & ~i_ccc;
            `BR_BLEU: _t = i_ccz | ~i_ccc;
            default:  _t = 1'b0;
        endcase
    end

    assign o_take = i_cond[0] ? ~_t : _t; // invert condition for odd cond values (e.g. from BEQ to BNE, BC to BNC, etc.)

endmodule
