`timescale 1ns / 1ps

module ALUControl(
	input [5:0] OpCode,
	input [5:0] Funct,
	output reg [4:0] ALUCtrl,
	output reg BranchType
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
	
	// set ALUFunct
	always @(*)
	begin
		case (OpCode)
			6'h00: begin
				case (Funct) // OpCode == 6'h00
					6'h00: ALUCtrl <= SLL;
					6'h20: ALUCtrl <= ADD;
					6'h21: ALUCtrl <= ADD;
					6'h22: ALUCtrl <= SUB;
					6'h23: ALUCtrl <= SUB;
					6'h24: ALUCtrl <= AND;
					6'h25: ALUCtrl <= OR;
					6'h26: ALUCtrl <= XOR;
					6'h27: ALUCtrl <= NOR;
					6'h2a: ALUCtrl <= SLT;
					// MOVZ
					6'h0a: ALUCtrl <= MOVZ;
					default: ALUCtrl <= ADD;
				endcase
			end
			6'h23: ALUCtrl <= ADD; // lw
			6'h2b: ALUCtrl <= ADD; // sw
			6'h05: ALUCtrl <= SUB; // bne
            // j
            6'h02: ALUCtrl <= ADD;
			default: ALUCtrl <= ADD; // other instructions
		endcase
	end

	parameter BNE = 1'b1;
	
	// set BranchType
	always @(*)
	begin
		case (OpCode)
			6'h05: BranchType <= BNE; // bne
			default: BranchType <= 1'b0; // other instructions
		endcase
	end
endmodule