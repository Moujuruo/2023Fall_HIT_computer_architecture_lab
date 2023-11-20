`timescale 1ns / 1ps

module data_mem(
    input clk,
    input [31:0] addr,
    input [31:0] writedata,
    input dataEn,
    input WR,
    output [31:0] rdata
);

    reg [31:0] ROM [255:0];

    initial begin
        // $readmemh("D:/HIT/2023/CPUdesign/lab_1/lab_1.data/base_data_data", ROM);
        $readmemh("D:/HIT/2023/CPUdesign/lab_1/lab_1.data/additional_data_data1", ROM);
        // $readmemh("D:/HIT/2023/CPUdesign/lab_1/lab_1.data/additional_data_data2", ROM);
    end
    assign rdata = (dataEn == 1'b1 && WR == 1'b0) ? ROM[addr[7:2]] : 32'h00000000;

    always @(posedge clk) begin
        if (dataEn == 1'b1 && WR == 1'b1) begin
            ROM[addr[7:2]] <= writedata;
        end
    end

endmodule