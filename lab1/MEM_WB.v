`timescale 1ns / 1ps

module MEM_WB(
    input clk,
    input reset,

    input RegWrite_MEM,
    input MemtoReg_MEM,
    input [4:0] RegWrAddr_MEM,
    input [31:0] ALUout_MEM,
    input [31:0] PC_MEM,
    input [31:0] ReadData_MEM,

    output reg RegWrite_WB,
    output reg MemtoReg_WB,
    output reg [4:0] RegWrAddr_WB,
    output reg [31:0] ALUout_WB,
    output reg [31:0] PC_WB,
    output reg [31:0] ReadData_WB
);
    always @(posedge clk)
    begin
        if (reset)
        begin
            RegWrite_WB <= 0;
            MemtoReg_WB <= 0;
            RegWrAddr_WB <= 0;
            ALUout_WB <= 0;
            PC_WB <= 0;
            ReadData_WB <= 0;
        end
        else begin
            RegWrite_WB <= RegWrite_MEM;
            MemtoReg_WB <= MemtoReg_MEM;
            RegWrAddr_WB <= RegWrAddr_MEM;
            ALUout_WB <= ALUout_MEM;
            PC_WB <= PC_MEM;
            ReadData_WB <= ReadData_MEM;
        end
    end

endmodule