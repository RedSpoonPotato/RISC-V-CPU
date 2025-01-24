`timescale 1ns / 1ps

module mux_2_to_1 #(parameter WIDTH=32)(
    input [WIDTH-1:0] a, 
    input [WIDTH-1:0] b, 
    input sel,
    output [WIDTH-1:0] y
);
    assign y = sel ? b : a;
endmodule

module flipflop #(parameter WIDTH=32) (
    input [WIDTH-1:0] d,
    input clk,
    output reg [WIDTH-1:0] q
);
    always_ff @(posedge clk) begin
        q <= d;
    end    
endmodule

module flipflop_async_rst #(parameter WIDTH=32) (
    input [WIDTH-1:0] d,
    input clk,
    input rst,
    output reg [WIDTH-1:0] q
);
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            q <= 0;
        else 
            q <= d;
    end  
endmodule

