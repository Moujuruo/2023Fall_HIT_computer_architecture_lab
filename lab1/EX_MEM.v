module EX_MEM(
    input clk,
    input reset,

    input RegWrite_EX,
    input MemRead_EX,
    input MemWrite_EX,
    input MemtoReg_EX,
    input [4:0] RegWrAddr_EX,
    input [31:0] ALUout_EX,
    input [31:0] PC_EX,
    input [31:0] Data2_EX,
    input [4:0] Rt_EX,
    input [4:0] ALUCtrl_EX,
    input [31:0] ALUin2,

    output reg RegWrite_MEM,
    output reg MemRead_MEM,
    output reg MemWrite_MEM,
    output reg MemtoReg_MEM,
    output reg [4:0] RegWrAddr_MEM,
    output reg [31:0] ALUout_MEM,
    output reg [31:0] PC_MEM,
    output reg [31:0] Data2_MEM,
    output reg [4:0] Rt_MEM
);

    always @(posedge clk)
    begin
        if (reset)
        begin
            RegWrite_MEM <= 0;
            MemRead_MEM <= 0;
            MemWrite_MEM <= 0;
            MemtoReg_MEM <= 0;
            RegWrAddr_MEM <= 0;
            ALUout_MEM <= 0;
            PC_MEM <= 0;
            Data2_MEM <= 0;
            Rt_MEM <= 0;
        end
        else begin
            // 判断如果是 MOVZ，且ALUin2为0，则RegWrite_MEM调整为1
            // 如果ALUin2不为0，则RegWrite_MEM调整为0
            if (ALUCtrl_EX == 5'b11000 && ALUin2 == 0)
                RegWrite_MEM <= 1;
            else if (ALUCtrl_EX == 5'b11000 && ALUin2 != 0)
                RegWrite_MEM <= 0;
            else
                RegWrite_MEM <= RegWrite_EX;
            MemRead_MEM <= MemRead_EX;
            MemWrite_MEM <= MemWrite_EX;
            MemtoReg_MEM <= MemtoReg_EX;            
            RegWrAddr_MEM <= RegWrAddr_EX;
            ALUout_MEM <= ALUout_EX;
            PC_MEM <= PC_EX;
            Data2_MEM <= Data2_EX;
            Rt_MEM <= Rt_EX;
        end
    end

endmodule