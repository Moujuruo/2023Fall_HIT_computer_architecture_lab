`timescale 1ns / 1ps

module CU(
	input [5:0] OpCode,
	input [5:0] Funct,
	output wire PCSrc,
	output wire Branch,
	output wire RegWrite,
	output wire RegDst,
	output wire MemRead,
	output wire MemWrite,
	output wire MemtoReg,
	output wire ALUSrc1,
	output wire ALUSrc2,
	output wire Jump
);
	
	assign PCSrc = OpCode == 6'h02 ? 1'b1 : 1'b0; // j : 1, others : 0
	   
    assign Branch = OpCode == 6'h05; // bne : 1, others : 0
    
    assign RegWrite = (OpCode == 6'h2b || OpCode == 6'h05 || OpCode == 6'h02) ? 1'b0 : 1'b1; // sw, bne, j : 0, others : 1
        
    assign RegDst = OpCode == 6'h23 ? 1'b0 : 1'b1; // lw : 0, others : 1
            
    assign MemRead = OpCode == 6'h23; // lw : 1, others : 0
    
    assign MemWrite = OpCode == 6'h2b; // sw : 1, others : 0
    
    assign MemtoReg = OpCode == 6'h23 ? 1'b1 : 1'b0; // lw : 1, others : 0
        
    assign ALUSrc1 = OpCode == 6'h00 && Funct == 6'h00 ? 1'b1 : 1'b0; // sll : 1(shamt), others : 0
	
	assign ALUSrc2 = (OpCode == 6'h23 || OpCode == 6'h2b) ? 1'b1 : 1'b0; // lw, sw: 1(offset or imm), others : 0

	assign Jump = OpCode == 6'h02 ? 1'b1 : 1'b0; // j : 1, others : 0
		
endmodule