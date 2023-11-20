`timescale 1ns / 1ps

module ALU(
	input [31:0] in1, 
	input [31:0] in2, 
	input [4:0] ALUCtrl, 
	input BranchType,
	output reg [31:0] out, 
	output reg Zero
);
	// funct number for different operation
	parameter AND = 5'b00000;
	parameter OR  = 5'b00001;
	parameter ADD = 5'b00010;
	parameter SUB = 5'b00110;
	parameter SLT = 5'b00111;
	parameter NOR = 5'b01100;
	parameter XOR = 5'b01101;
	parameter SLL = 5'b10000;
	parameter MOVZ = 5'b11000;

	// set BranchType
	parameter BNE = 1'b1;
	
	// zero means whether branch is taken
	always @(*)
	begin
	    case (BranchType)
	        BNE: Zero <= in1 != in2;
	       default: Zero <= 0;
	    endcase
	end
	
	
	// different ALU operations
	always @(*)
		case (ALUCtrl)
			AND: out <= in1 & in2;
			OR: out <= in1 | in2;
			ADD: out <= in1 + in2;
			SUB: out <= in1 - in2;
            // SLT
            SLT: out <= in1 < in2 ? 1 : 0;
			NOR: out <= ~(in1 | in2);
			XOR: out <= in1 ^ in2;
			SLL: out <= (in2 << in1[4:0]);
            // MOVZ
            MOVZ: out <= in2 == 0 ? in1 : 32'h00000000;
			default: out <= 32'h00000000;
		endcase
	
endmodule