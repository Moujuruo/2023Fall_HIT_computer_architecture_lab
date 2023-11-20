`timescale 1ns / 1ps

module branch_predictor111(
    input           clk,        //时钟信号，必须与CPU保持一致
    input           resetn,     //低有效复位信号，必须与CPU保持一致

    //供CPU第一级流水段使用的接口：
    //上一个指令地址
    input[31:0]     old_PC,
    //这周期是否需要更新PC（进行分支预测）
    input           predict_en,
    //预测出的下一个指令地址
    output[31:0]    new_PC,
    //是否被预测为执行转移的转移指令
    output          predict_jump,

    //分支预测器更新接口：
    //更新使能
    input           upd_en,
    //转移指令地址
    input[31:0]     upd_addr,
    //是否为转移指令
    input           upd_jumpinst,
    //若为转移指令，则是否转移
    input           upd_jump,
    //是否预测失败
    input           upd_predfail,
    //转移指令本身的目标地址（无论是否转移）
    input[31:0]     upd_target
);
    // BTB
    reg [31:0] predicted_PC [0:1023];
    wire [29:0] old_buffer_addr;
    wire [1:0] old_lowbits;

    wire [29:0] upd_buffer_addr;
    wire [1:0] upd_lowbits;

    assign {old_buffer_addr, old_lowbits} = old_PC;  // 用于BTB的索引, 31:2 是因为 PC 最后两位一定是 00
    assign {upd_buffer_addr, upd_lowbits} = upd_addr;
    assign new_PC = predict_jump ? predicted_PC[old_buffer_addr] : old_PC + 4;
    // BHT
    reg [1:0] bht [0:1023];

    wire [29:0] old_bht_addr;
    wire [29:0] upd_bht_addr;

    assign old_bht_addr = old_PC[31:2];
    assign upd_bht_addr = upd_addr[31:2];

    assign predict_jump = bht[old_bht_addr] >= 2'b10;

    integer i;

    always @(posedge clk) begin
        if (!resetn) begin
            for (i = 0; i < 1024; i = i + 1) begin
                bht[i] <= 2'b11;
            end            
        end else begin
            if (upd_en) begin
                if (upd_jump) begin
                    // 如果实际发生了跳转，向“强的方向”更新 BHT
                    if (bht[upd_bht_addr] != 2'b11)
                        bht[upd_bht_addr] <= bht[upd_bht_addr] + 2'b01; 
                    else
                        bht[upd_bht_addr] <= bht[upd_bht_addr];
                end else begin
                    // 如果实际没有跳转，向“弱的方向”更新 BHT
                    if (bht[upd_bht_addr] != 2'b00)
                        bht[upd_bht_addr] <= bht[upd_bht_addr] - 2'b01;
                    else
                        bht[upd_bht_addr] <= bht[upd_bht_addr];
                end
            end
        end
    end

    always @(posedge clk) begin
        if (!resetn) begin
            for (i = 0; i < 1024; i = i + 1) begin
                predicted_PC[i] <= 0;
            end
        end else begin
            if (upd_en) begin
                // 更新 BTB，这里可以不区分是跳转的地址还是 PC + 4
                predicted_PC[upd_buffer_addr] <= upd_target;
            end
        end
    end

endmodule