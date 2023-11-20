`timescale 1ns / 1ps

module cpu(
    input            clk             ,  // clock, 100MHz
    input            resetn          ,  // active low

    // debug signals
    output [31:0]    debug_wb_pc     ,  // 当前正在执行指令的PC
    output           debug_wb_rf_wen ,  // 当前通用寄存器组的写使能信号
    output [4 :0]    debug_wb_rf_addr,  // 当前通用寄存器组写回的寄存器编号
    output [31:0]    debug_wb_rf_wdata  // 当前指令需要写回的数据
);

    wire [31:0] PCAddr, outputPC;
    PCreg PCreg(
        .clk(clk),
        .rst(!resetn),
        .PCAddr(PCAddr),
        .PC(outputPC)
    );

    wire [31:0] instruction;
    insmem insmem(
        .insAddr(outputPC),
        .ins(instruction)
    );

    wire [31:0] Instruction_ID, PC_ID;
    wire flush_IFID, keep_IFID;

    IF_ID IF_ID(
        .clk(clk),
        .reset(!resetn),
        .flush(flush_IFID),
        .keep(keep_IFID),
        .Instruction_IF(instruction),
        .PC_IF(outputPC),
        .Instruction_ID(Instruction_ID),
        .PC_ID(PC_ID)
    );

    wire [5:0] OpCode_ID;
    wire [4:0] Rs_ID, Rt_ID, Rd_ID;
    wire [4:0] Shamt_ID;
    wire [5:0] Funct_ID;

    assign OpCode_ID = Instruction_ID[31:26];
    assign Rs_ID = Instruction_ID[25:21];
    assign Rt_ID = Instruction_ID[20:16];
    assign Rd_ID = Instruction_ID[15:11];
    assign Shamt_ID = Instruction_ID[10:6];
    assign Funct_ID = Instruction_ID[5:0];

    wire PCSrc_ID, Branch_ID, RegWrite_ID, RegDst_ID, MemRead_ID, MemWrite_ID, MemtoReg_ID, ALUSrc1_ID, ALUSrc2_ID, Jump_ID;

    CU CU(
        .OpCode(OpCode_ID),
        .Funct(Funct_ID),
        .PCSrc(PCSrc_ID),
        .Branch(Branch_ID),
        .RegWrite(RegWrite_ID),
        .RegDst(RegDst_ID),
        .MemRead(MemRead_ID),
        .MemWrite(MemWrite_ID),
        .MemtoReg(MemtoReg_ID),
        .ALUSrc1(ALUSrc1_ID),
        .ALUSrc2(ALUSrc2_ID),
        .Jump(Jump_ID)
    );
    
    wire Branch_EX, Zero_EX;
    wire Branch_Zero_EX;

    assign Branch_Zero_EX = Branch_EX && Zero_EX;
    assign flush_IFID = Branch_Zero_EX || Jump_ID;

    wire [4:0] ALUCtrl_ID;
    wire BranchType_ID;

    ALUControl ALUControl(
        .OpCode(OpCode_ID),
        .Funct(Funct_ID),
        .ALUCtrl(ALUCtrl_ID),
        .BranchType(BranchType_ID)
    );
    
    wire [31:0] Data1_ID, Data2_ID;
    wire RegWrite_WB;
    wire [31:0] Write_Data_WB;
    wire [4:0] RegWrAddr_WB;

    regfiles regfiles(
        .clk(clk),
        .raddr1(Rs_ID),
        .raddr2(Rt_ID),
        .waddr(RegWrAddr_WB),
        .wdata(Write_Data_WB),
        .we(RegWrite_WB),
        .rdata1(Data1_ID),
        .rdata2(Data2_ID)
    );

    wire [31:0] Imm_Ext_ID;

    signext signext(
        .ins({Rd_ID, Shamt_ID, Funct_ID}),
        .sign(1),
        .ext(Imm_Ext_ID)
    );

    wire RegWrite_EX, RegDst_EX, MemRead_EX, MemWrite_EX, MemtoReg_EX, ALUSrc1_EX, ALUSrc2_EX;
    wire [4:0] ALUCtrl_EX;
    wire [31:0] Data1_EX, Data2_EX, Imm_Ext_EX, PC_EX;
    wire [4:0] Rs_EX, Rt_EX, Rd_EX;
    wire [4:0] Shamt_EX;
    wire BranchType_EX;
    wire flush_IDEX;
    
    ID_EX ID_EX(
        .clk(clk),
        .reset(!resetn),
        .flush(flush_IDEX),
        .Branch_ID(Branch_ID),
        .RegWrite_ID(RegWrite_ID),
        .RegDst_ID(RegDst_ID),
        .MemRead_ID(MemRead_ID),
        .MemWrite_ID(MemWrite_ID),
        .MemtoReg_ID(MemtoReg_ID),
        .ALUSrc1_ID(ALUSrc1_ID),
        .ALUSrc2_ID(ALUSrc2_ID),
        .ALUCtrl_ID(ALUCtrl_ID),
        .Data1_ID(Data1_ID),
        .Data2_ID(Data2_ID),
        .Rs_ID(Rs_ID),
        .Rt_ID(Rt_ID),
        .Rd_ID(Rd_ID),
        .Imm_Ext_ID(Imm_Ext_ID),
        .Shamt_ID(Shamt_ID),
        .PC_ID(PC_ID),
        .BranchType_ID(BranchType_ID),
        .RegWrite_EX(RegWrite_EX),
        .RegDst_EX(RegDst_EX),
        .MemRead_EX(MemRead_EX),
        .MemWrite_EX(MemWrite_EX),
        .MemtoReg_EX(MemtoReg_EX),
        .ALUSrc1_EX(ALUSrc1_EX),
        .ALUSrc2_EX(ALUSrc2_EX),
        .ALUCtrl_EX(ALUCtrl_EX),
        .Data1_EX(Data1_EX),
        .Data2_EX(Data2_EX),
        .Imm_Ext_EX(Imm_Ext_EX),
        .Rs_EX(Rs_EX),
        .Rt_EX(Rt_EX),
        .Rd_EX(Rd_EX),
        .Shamt_EX(Shamt_EX),
        .Branch_EX(Branch_EX),
        .BranchType_EX(BranchType_EX),
        .PC_EX(PC_EX)
    );

    wire [4:0] RegWrAddr_EX;

    assign RegWrAddr_EX = RegDst_EX == 1'b0 ? Rt_EX : Rd_EX;

    wire load_use_hazard;

    assign load_use_hazard = MemRead_EX && (Rt_EX == Rs_ID || Rt_EX == Rt_ID);

    assign keep_IFID = load_use_hazard;

    assign flush_IDEX = Branch_Zero_EX || load_use_hazard;

    wire [31:0] PC_Branch;

    assign PC_Branch = PC_EX + (Imm_Ext_EX << 2) + 4;

    wire [1:0] ALUForwarding1, ALUForwarding2;
    wire RegWrite_MEM;
    wire [4:0] RegWrAddr_MEM;

    ALUForwarding ALUForwarding(
        .Rs_EX(Rs_EX),
        .Rt_EX(Rt_EX),
        .RegWrAddr_MEM(RegWrAddr_MEM),
        .RegWrAddr_WB(RegWrAddr_WB),
        .RegWrite_MEM(RegWrite_MEM),
        .RegWrite_WB(RegWrite_WB),
        .Forwarding1(ALUForwarding1),
        .Forwarding2(ALUForwarding2)
    );

    wire [31:0] ALUin1, ALUin2;
    wire [31:0] ALUout_MEM;

    assign ALUin1 = ALUSrc1_EX ? {27'h0000000, Shamt_EX} :
        ALUForwarding1 == 2'b01 ? ALUout_MEM :
        ALUForwarding1 == 2'b10 ? Write_Data_WB : Data1_EX;

    assign ALUin2 = ALUSrc2_EX ? Imm_Ext_EX :
        ALUForwarding2 == 2'b01 ? ALUout_MEM :
        ALUForwarding2 == 2'b10 ? Write_Data_WB : Data2_EX;

    wire [31:0] ALUout_EX;

    ALU ALU(
        .in1(ALUin1),
        .in2(ALUin2),
        .ALUCtrl(ALUCtrl_EX),
        .BranchType(BranchType_EX),
        .out(ALUout_EX),
        .Zero(Zero_EX)
    );

    wire MemRead_MEM, MemWrite_MEM, MemtoReg_MEM;
    wire [31:0] PC_MEM, Data2_MEM;
    wire [4:0] Rt_MEM;

    EX_MEM EX_MEM(
        .clk(clk),
        .reset(!resetn),
        .RegWrite_EX(RegWrite_EX),
        .MemRead_EX(MemRead_EX),
        .MemWrite_EX(MemWrite_EX),
        .MemtoReg_EX(MemtoReg_EX),
        .RegWrAddr_EX(RegWrAddr_EX),
        .ALUout_EX(ALUout_EX),
        .ALUCtrl_EX(ALUCtrl_EX),
        .ALUin2(ALUin2),
        .PC_EX(PC_EX),
        .Data2_EX(Data2_EX),
        .Rt_EX(Rt_EX),
        .RegWrite_MEM(RegWrite_MEM),
        .MemRead_MEM(MemRead_MEM),
        .MemWrite_MEM(MemWrite_MEM),
        .MemtoReg_MEM(MemtoReg_MEM),
        .RegWrAddr_MEM(RegWrAddr_MEM),
        .ALUout_MEM(ALUout_MEM),
        .PC_MEM(PC_MEM),
        .Data2_MEM(Data2_MEM),
        .Rt_MEM(Rt_MEM)
    );

    wire [31:0] Read_data_MEM;
    wire [31:0] Write_Data_MEM;

    assign Write_Data_MEM = (RegWrite_WB && (Rt_MEM == RegWrAddr_WB) && (RegWrAddr_WB != 0)) ? Write_Data_WB : Data2_MEM;

    data_mem data_mem(
        .clk(clk),
        .addr(ALUout_MEM),
        .writedata(Write_Data_MEM),
        .dataEn(1),
        .WR(MemWrite_MEM),
        .rdata(Read_data_MEM)
    );

    wire MemtoReg_WB;
    // wire [4:0] RegWrAddr_WB;
    wire [31:0] ALUout_WB, PC_WB, ReadData_WB;

    MEM_WB MEM_WB(
        .clk(clk),
        .reset(!resetn),
        .RegWrite_MEM(RegWrite_MEM),
        .MemtoReg_MEM(MemtoReg_MEM),
        .RegWrAddr_MEM(RegWrAddr_MEM),
        .ALUout_MEM(ALUout_MEM),
        .PC_MEM(PC_MEM),
        .ReadData_MEM(Read_data_MEM),
        .RegWrite_WB(RegWrite_WB),
        .MemtoReg_WB(MemtoReg_WB),
        .RegWrAddr_WB(RegWrAddr_WB),
        .ALUout_WB(ALUout_WB),
        .PC_WB(PC_WB),
        .ReadData_WB(ReadData_WB)
    );
    
    assign Write_Data_WB = MemtoReg_WB ? ReadData_WB : ALUout_WB;
    
    assign PCAddr = keep_IFID ? outputPC :
        Branch_Zero_EX ? PC_Branch :
        PCSrc_ID ? {outputPC[31:28], Rs_ID, Rt_ID, Rd_ID, Shamt_ID, Funct_ID, 2'b00} :
        outputPC + 4;

    assign debug_wb_pc = PC_WB;
    assign debug_wb_rf_wen = RegWrite_WB;
    assign debug_wb_rf_addr = RegWrAddr_WB;
    assign debug_wb_rf_wdata = Write_Data_WB;

endmodule