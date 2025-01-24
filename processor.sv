`timescale 1ns / 1ps

`define INSTR_WIDTH 32
`define DATA_WIDTH 32

//dwdw

module processor #(parameter WIDTH=32)( 
    // 5 stage pipeline
    input wire [WIDTH-1:0] a,
    input wire [WIDTH-1:0] b,
    input wire sel,
    output wire [WIDTH-1:0] y
   );

//    mux_2_to_1 #(.WIDTH(32)) MUX(
//        .a(a),
//        .b(b),
//        .sel(sel),
//        .y(y)
//    );
    
endmodule
