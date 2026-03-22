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
	output reg o_ForwardAE,  // Selector for ALU input A
	output reg o_ForwardBE   // Selector for ALU input B
);

    always @(*) begin
        // -------------------------------------------------------------------------
		// FORWARDING FOR OPERAND A (rdE)
        // -------------------------------------------------------------------------
        
        // Priority 1: EX/MEM Hazard (The most recent data)
        // If MEM stage is writing to our source register (and it is not r0)
		if ((i_rdE != 4'h0) && (i_rdE == i_WriteRegM) && i_RegWriteM && i_validM) begin
            o_ForwardAE = 1'b1;
        end
        // Normal Case: No hazards, use the value directly from the Register File
        else begin
            o_ForwardAE = 1'b0; 
        end

        // -------------------------------------------------------------------------
		// FORWARDING FOR OPERAND B (rsE)
        // -------------------------------------------------------------------------
        
        // Priority 1: EX/MEM Hazard
		if ((i_rsE != 4'h0) && (i_rsE == i_WriteRegM) && i_RegWriteM && i_validM) begin
            o_ForwardBE = 1'b1;
        end
        // Normal Case: No hazards
        else begin
            o_ForwardBE = 1'b0;
        end
    end

endmodule