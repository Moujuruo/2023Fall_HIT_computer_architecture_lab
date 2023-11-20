module branch_predictor(
    input           clk,
    input           resetn,
    input [31:0]    old_PC,
    input           predict_en,
    output[31:0]    new_PC,
    output          predict_jump,
    input           upd_en,
    input[31:0]     upd_addr,
    input           upd_jumpinst,
    input           upd_jump,
    input           upd_predfail,
    input[31:0]     upd_target
);

    parameter HISTORY_BITS = 12;
    parameter BTB_SIZE = 64;
    parameter GLOBAL_TABLE_SIZE = 4096;

    reg [31:0] btb_target[0:BTB_SIZE-1]; // 存储跳转目标地址
    reg btb_valid[0:BTB_SIZE-1];  // 表示BTB条目是否有效
    reg [31:0] btb_pc[0:BTB_SIZE-1];  // 存储分支指令的PC
    reg [HISTORY_BITS-1:0] history[0:BTB_SIZE-1]; // 存储每个分支指令的局部跳转历史
    reg [1:0] global_table[0:GLOBAL_TABLE_SIZE-1];  // 全局分支预测表

    integer i;
    reg [5:0] index; // 用于BTB的索引
    reg [HISTORY_BITS-1:0] current_history; // 当前指令的局部历史

    always @(posedge clk) begin
        if (!resetn) begin
            // 复位时的初始化
            for (i = 0; i < BTB_SIZE; i = i + 1) begin
                btb_valid[i] <= 0;
                btb_target[i] <= 0;
                btb_pc[i] <= 0;
                history[i] <= 0;
            end
            for (i = 0; i < GLOBAL_TABLE_SIZE; i = i + 1) begin
                global_table[i] <= 2'b11; // 初始假设所有分支都会发生跳转
            end
        end else if (upd_en) begin
            // 更新逻辑
            index = upd_addr[7:2];
            if (upd_jump) begin
                 // 如果实际发生了跳转，更新BTB和历史
                btb_valid[index] <= 1;
                btb_target[index] <= upd_target;
                btb_pc[index] <= upd_addr;
                history[index] <= {history[index][HISTORY_BITS-2:0], 1'b1};
                // 更新全局表的饱和计数器
                if (global_table[history[index]] < 2'b11) begin
                    global_table[history[index]] <= global_table[history[index]] + 1;
                end
            end else if (upd_jumpinst) begin
                // 如果是一个分支指令但没有跳转，只更新历史
                history[index] <= {history[index][HISTORY_BITS-2:0], 1'b0};
                if (global_table[history[index]] > 2'b00) begin
                    global_table[history[index]] <= global_table[history[index]] - 1;
                end
            end
        end
    end

    reg [31:0] new_PC_t;
    reg predict_jump_t;

    assign new_PC = new_PC_t;
    assign predict_jump = predict_jump_t;

    // 预测逻辑
    always @(*) begin
        if (predict_en) begin
            index = old_PC[7:2];
            current_history = history[index];
            // 如果在BTB中找到了匹配的条目，并且全局表预测为跳转
            if (btb_valid[index] && btb_pc[index] == old_PC && global_table[current_history] >= 2'b10) begin
                predict_jump_t = 1;
                new_PC_t = btb_target[index];
            end else begin
                predict_jump_t = 0;
                new_PC_t = old_PC + 4;
            end
        end else begin
            predict_jump_t = 0;
            new_PC_t = old_PC;
        end
    end

endmodule