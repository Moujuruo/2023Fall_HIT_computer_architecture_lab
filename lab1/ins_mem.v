`timescale 1ns / 1ps

// Instruction Memory
module insmem(
    input [31:0] insAddr,
    output [31:0] ins
);
    reg [31:0] RAM [255:0];
    initial begin
        // $readmemh("D:/HIT/2023/CPUdesign/lab_1/lab_1.data/base_inst_data", RAM);
        $readmemh("D:/HIT/2023/CPUdesign/lab_1/lab_1.data/additional_inst_data1", RAM);
        // $readmemh("D:/HIT/2023/CPUdesign/lab_1/lab_1.data/additional_inst_data2", RAM);
    end

    assign ins = RAM[insAddr[7:2]];
endmodule
