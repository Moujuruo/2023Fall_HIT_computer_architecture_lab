`timescale 1ns / 1ps
// Sign Extender
module signext(
    input [15:0] ins,
    input sign,
    output [31:0] ext
);

    // sign 为 1 为符号扩展，为 0 为无符号扩展
    assign ext = sign ? {{16{ins[15]}}, ins} : {{16{1'b0}}, ins};

endmodule
