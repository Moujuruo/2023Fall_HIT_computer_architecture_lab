`timescale 1ns / 1ps

// Program Counter
module PCreg(
    input clk,
    input rst,
    input [31:0] PCAddr,
    output reg [31:0] PC
);
    always @(posedge clk) begin
        if (rst) begin
            PC <= 32'h00000000;
        end
        else begin
            PC <= PCAddr;
        end
    end
endmodule
