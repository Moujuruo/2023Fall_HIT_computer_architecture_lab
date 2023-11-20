module ALUForwarding(
    input [4:0] Rs_EX,
    input [4:0] Rt_EX,
    input [4:0] RegWrAddr_MEM,
    input [4:0] RegWrAddr_WB,
    input RegWrite_MEM,
    input RegWrite_WB,
    output wire [1:0] Forwarding1,
    output wire [1:0] Forwarding2
// EX stands for ID/EX stage, MEM stands for EX/MEM stage, WB stands for MEM/WB stage
// Forwarding: 0: ID/EX pipeline registers, 1: EX/MEM pipeline registers, 2: MEM/WB pipeline registers
);

    assign Forwarding1 = (RegWrite_MEM && (Rs_EX == RegWrAddr_MEM) && (RegWrAddr_MEM != 0)) ? 2'b01 :
        (RegWrite_WB && (Rs_EX == RegWrAddr_WB) && (RegWrAddr_WB != 0)) ? 2'b10 : 2'b00;
    assign Forwarding2 = (RegWrite_MEM && (Rt_EX == RegWrAddr_MEM) && (RegWrAddr_MEM != 0)) ? 2'b01 :
        (RegWrite_WB && (Rt_EX == RegWrAddr_WB) && (RegWrAddr_WB != 0)) ? 2'b10 : 2'b00;

endmodule