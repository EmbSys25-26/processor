`timescale 1ns / 1ps

/*
IF stage 
Fetches insn from IM, increments PC. 
- Flushes are taken on mispredicted branches and interrupts - both require updating the PC to a non-sequential value and flushing the pipeline.
- Bubbles occur on stalls (currently flushes too, though this must be improved) - i.e. waiting for a load to complete, meaning the IF stage should not update its PC or output a valid insn.
*/

module if_stage(
    input wire i_clk,
    input wire i_rst,
    input wire i_hit,
    input wire i_stall,
    input wire i_flush,
    input wire [15:0] i_flush_pc,
    input wire [15:0] i_pc,
    input wire [15:0] i_insn,
    output wire o_insn_ce,
    output wire o_valid,
    output reg [15:0] o_pc,
    output wire [15:0] o_insn
);

/*************************************************************************************
 * SECTION 1. DECLARE WIRES / REGS
 ************************************************************************************/
    reg [15:0] _pc_d1;
    reg [15:0] _pc_d2;
    reg [1:0] _flush_bubble;

/*************************************************************************************
 * SECTION 2. IMPLEMENTATION
 ************************************************************************************/

    assign o_insn_ce = i_hit & ~i_stall;
    assign o_valid = i_hit & (_flush_bubble == 2'd0);
    assign o_insn = i_insn;

    always @(posedge i_clk) begin
        if (i_rst) begin
            _pc_d1 <= i_pc;
            _pc_d2 <= i_pc;
            o_pc <= i_pc;
            _flush_bubble <= 2'd0;
        end else if (i_flush) begin
            _pc_d1 <= i_flush_pc;
            _pc_d2 <= i_flush_pc;
            o_pc <= i_flush_pc;
            _flush_bubble <= 2'd2;
        end else begin
            if (i_hit & ~i_stall) begin
                _pc_d1 <= i_pc;
                _pc_d2 <= _pc_d1;
                o_pc <= _pc_d2;
                if (_flush_bubble != 2'd0) begin
                    _flush_bubble <= _flush_bubble - 2'd1;
                end
            end
        end
    end

endmodule
