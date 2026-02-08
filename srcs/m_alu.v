`timescale 1ns / 1ps

`include "constants.vh"

module alu(
    input wire i_is_add,
    input wire [`CPU_N:0] i_a,
    input wire [`CPU_N:0] i_b,
    input wire i_ci,
    input wire i_is_xor,
    input wire i_is_sra,
    output wire [`CPU_N:0] o_sum,
    output wire [`CPU_N:0] o_log,
    output wire [`CPU_N:0] o_sr,
    output wire o_co,
    output wire o_x
);

/*************************************************************************************
 * Arithmetic Unit
 ************************************************************************************/
    addsub u_addsub (
        .i_add(i_is_add),
        .i_ci(i_ci),
        .i_a(i_a),
        .i_b(i_b),
        .o_sum(o_sum),
        .o_x(o_x),
        .o_co(o_co)
    );

/*************************************************************************************
 * Logic and Shift Units
 ************************************************************************************/
    assign o_log = i_is_xor ? (i_a ^ i_b) : (i_a & i_b);
    assign o_sr = {i_is_sra ? i_b[`CPU_N] : 1'b0, i_b[`CPU_N:1]};

endmodule

module addsub(
    input wire i_add,
    input wire i_ci,
    input wire [`CPU_N:0] i_a,
    input wire [`CPU_N:0] i_b,
    output wire [`CPU_N:0] o_sum,
    output wire o_x,
    output wire o_co
);

/*************************************************************************************
 * Add/Sub Primitive
 ************************************************************************************/
    assign {o_co, o_sum, o_x} = i_add ? ({i_a, i_ci} + {i_b, 1'b1}) : ({i_a, i_ci} - {i_b, 1'b1});

endmodule
