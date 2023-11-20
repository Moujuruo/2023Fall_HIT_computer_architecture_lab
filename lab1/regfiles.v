`timescale 1ns / 1ps

module regfiles(
    input clk,
    input [4:0] raddr1,
    input [4:0] raddr2,
    input [4:0] waddr,
    input [31:0] wdata,
    input we,
    output reg [31:0] rdata1,
    output reg [31:0] rdata2
);
    reg [31:0] regs[31:0];
    initial begin
        // $readmemh("D:/HIT/2023/CPUdesign/lab_1/lab_1.data/base_reg_data", regs);
        // $readmemh("D:/HIT/2023/CPUdesign/lab_1/lab_1.data/additional_reg_data1", regs);
        $readmemh("D:/HIT/2023/CPUdesign/lab_1/lab_1.data/additional_reg_data2", regs);
    end

    always @(negedge clk) begin
        if (we && waddr != 0) begin
            regs[waddr] <= wdata;
        end
    end

    always @(*) begin
        if (we && waddr == raddr1) begin
            rdata1 = wdata;
        end
        else
            rdata1 = regs[raddr1];
    end

    always @(*) begin
        if (we && waddr == raddr2) begin
            rdata2 = wdata;
        end
        else
            rdata2 = regs[raddr2];
    end

endmodule