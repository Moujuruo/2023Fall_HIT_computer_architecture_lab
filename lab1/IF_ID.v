`timescale 1ns / 1ps

module IF_ID(
    input clk,
    input reset,
    input flush,
    input keep,
    input [31:0] Instruction_IF,
    input [31:0] PC_IF,
    output reg [31:0] Instruction_ID,
    output reg [31:0] PC_ID
);

    always @(posedge clk)
    begin
        if (reset)
        begin
            Instruction_ID <= 0;
            PC_ID <= 0;
        end
        else if (flush)
        begin
            Instruction_ID <= 0;
            PC_ID <= 0;
        end
        else if (keep)
        begin
            Instruction_ID <= Instruction_ID;
            PC_ID <= PC_ID;
        end
        else begin
            Instruction_ID <= Instruction_IF;
            PC_ID <= PC_IF;
        end
    end

endmodule