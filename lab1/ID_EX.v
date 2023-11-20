module ID_EX(
    input clk,
    input reset,
    input flush,

	input Branch_ID,
	input RegWrite_ID,
	input RegDst_ID,
	input MemRead_ID,
	input MemWrite_ID,
	input MemtoReg_ID,
	input ALUSrc1_ID,
	input ALUSrc2_ID,
    input [4:0] ALUCtrl_ID,
    input [31:0] Data1_ID,
    input [31:0] Data2_ID,
    input [4:0] Rs_ID,
    input [4:0] Rt_ID,
    input [4:0] Rd_ID,
    input [31:0] Imm_Ext_ID,    
    input [4:0] Shamt_ID,
    input [31:0] PC_ID,
    input BranchType_ID,

    output reg Branch_EX,
    output reg RegWrite_EX,
    output reg RegDst_EX,
    output reg MemRead_EX,
    output reg MemWrite_EX,
    output reg MemtoReg_EX,
    output reg ALUSrc1_EX,
    output reg ALUSrc2_EX,
    output reg [4:0] ALUCtrl_EX,
    output reg [31:0] PC_EX,
    output reg [31:0] Data1_EX,
    output reg [31:0] Data2_EX,
    output reg [4:0] Rs_EX,
    output reg [4:0] Rt_EX,
    output reg [4:0] Rd_EX,
    output reg [31:0] Imm_Ext_EX,
    output reg [4:0] Shamt_EX,
    output reg BranchType_EX
);

    always @(posedge clk)
    begin
        if (reset)
        begin
            Branch_EX <= 0;
            RegWrite_EX <= 0;
            RegDst_EX <= 0;
            MemRead_EX <= 0;
            MemWrite_EX <= 0;
            MemtoReg_EX <= 0;
            ALUSrc1_EX <= 0;
            ALUSrc2_EX <= 0;
            ALUCtrl_EX <= 0;
            PC_EX <= 0;
            Data1_EX <= 0;
            Data2_EX <= 0;
            Rs_EX <= 0;
            Rt_EX <= 0;
            Rd_EX <= 0;
            Imm_Ext_EX <= 0;
            Shamt_EX <= 0;
            BranchType_EX <= 0;
        end
        else if (flush)
        begin
            Branch_EX <= 0;
            RegWrite_EX <= 0;
            RegDst_EX <= 0;
            MemRead_EX <= 0;
            MemWrite_EX <= 0;
            MemtoReg_EX <= 0;
            ALUSrc1_EX <= 0;
            ALUSrc2_EX <= 0;
            ALUCtrl_EX <= 0;
            PC_EX <= 0;
            Data1_EX <= 0;
            Data2_EX <= 0;
            Rs_EX <= 0;
            Rt_EX <= 0;
            Rd_EX <= 0;
            Imm_Ext_EX <= 0;
            Shamt_EX <= 0;
            BranchType_EX <= 0;
        end
        else begin
            Branch_EX <= Branch_ID;
            // RegWrite_EX <= RegWrite_ID;
            // 判断 如果是 MOVZ 指令，且 Data2_ID 不为0，在 EX 阶段不写回
            if (ALUCtrl_ID == 5'b11000 && Data2_ID != 0) begin
                RegWrite_EX <= 0;
            end
            else begin
                RegWrite_EX <= RegWrite_ID;
            end
            RegDst_EX <= RegDst_ID;
            MemRead_EX <= MemRead_ID;
            MemWrite_EX <= MemWrite_ID;
            MemtoReg_EX <= MemtoReg_ID;
            ALUSrc1_EX <= ALUSrc1_ID;
            ALUSrc2_EX <= ALUSrc2_ID;
            ALUCtrl_EX <= ALUCtrl_ID;
            PC_EX <= PC_ID;
            Data1_EX <= Data1_ID;
            Data2_EX <= Data2_ID;
            Rs_EX <= Rs_ID;
            Rt_EX <= Rt_ID;
            Rd_EX <= Rd_ID;
            Imm_Ext_EX <= Imm_Ext_ID;
            Shamt_EX <= Shamt_ID;
            BranchType_EX <= BranchType_ID;
        end
    end

endmodule