`timescale 1ns / 1ps

/* 
Computes the next pc value in the IF stage. 
Increments +2 for normal sequential execution. 
Alternatives: 
- reset -> goes to reset vector 
- branch taken -> goes to branch target
- interrupt taken -> goes to interrupt vector
*/ 

module pc_next(
    input wire i_rst,
    input wire [15:0] i_rst_vec,
    input wire [15:0] i_pc,
    input wire i_hit,
    input wire i_branch_take,
    input wire [15:0] i_branch_target,
    input wire i_irq_take,
    input wire [15:0] i_irq_vector,
    output wire [15:0] o_pc_next
);

/*************************************************************************************
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/
    wire [15:0] _pc_seq;

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

    assign _pc_seq = i_pc + {14'b0, i_hit, 1'b0};

    assign o_pc_next = i_rst ? i_rst_vec :
                       (i_irq_take ? i_irq_vector :
                       (i_branch_take ? i_branch_target : _pc_seq));

endmodule