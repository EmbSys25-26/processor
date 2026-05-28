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
    // Barrel shifter: shift the rd operand (i_a) right by the low 4 bits
    // of rs (i_b).  SRA preserves the sign bit (arithmetic shift); SRL
    // zero-fills (logical shift).  Matches the documented `SRA rd, rs` /
    // `SRL rd, rs` semantics — the previous single-bit shift on i_b broke
    // the runtime helpers (__mul, __divu, __modu) and the codegen's
    // IR_OP_SHRU/SHRS lowering, both of which load the shift count into a
    // register and expect the destination to be shifted by that amount.
    // Sign- or zero-extend to 32 bits before shifting so the arithmetic-
    // shift sign-fill works portably across simulators (`$signed() >>>`
    // can fail to sign-extend when the LHS is unsigned-context).
    wire [31:0] _sext_a    = {{16{i_a[`CPU_N]}}, i_a};
    wire [31:0] _zext_a    = {16'b0, i_a};
    wire [31:0] _shifted_a = i_is_sra
        ? (_sext_a >> i_b[3:0])
        : (_zext_a >> i_b[3:0]);
    assign o_sr = _shifted_a[`CPU_N:0];

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
