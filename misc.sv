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

module sram_w_n #(
    parameter W = 16, 
    parameter N = 8) (
    input wire clk,
    input wire we,
    input wire [N-1:0] addr,
    input wire [W-1:0] data_in,
    output reg [W-1:0] data_out
);
    reg [W-1:0] mem [(2**N)-1:0];

    always @(posedge clk) begin
        if (we) begin
            mem[addr] <= data_in;
        end else begin
            data_out <= mem[addr];
        end
    end

endmodule