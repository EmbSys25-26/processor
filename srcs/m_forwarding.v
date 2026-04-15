`timescale 1ns / 1ps

module m_forwarding (
    // Execute (EX) Stage Inputs
	input  wire [3:0] i_rdE,        // Source register 1 (Operand A)
	input  wire [3:0] i_rsE,        // Source register 2 (Operand B)
    
    // Memory (MEM) Stage Inputs
	input  wire [3:0] i_WriteRegM,  // Destination register in MEM stage
    input  wire       i_RegWriteM,  // Write Enable signal in MEM stage
	
	// Verify if the isntruction on MEM is valid
	input wire i_validM,

    // Forwarding Multiplexer Control Outputs
	output wire o_ForwardAE,  // Selector for ALU input A
	output wire o_ForwardBE   // Selector for ALU input B
);

(* keep = "true" *) assign o_ForwardAE = (i_rdE != 4'h0) && (i_rdE == i_WriteRegM) && i_RegWriteM && i_validM;
(* keep = "true" *) assign o_ForwardBE = (i_rsE != 4'h0) && (i_rsE == i_WriteRegM) && i_RegWriteM && i_validM;

endmodule