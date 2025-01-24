`timescale 1ns / 1ps

module InstructionMem #(
    parameter DATA_WIDTH = global_params::DATA_WIDTH,
    parameter INSTR_WIDTH = global_params::INSTR_WIDTH,
    parameter DEPTH = global_params::INSTR_MEM_DEPTH
) (
    input [DATA_WIDTH-1:0] pc,
    output reg [INSTR_WIDTH-1:0] instr
);
    // can implement caching later aswell combined instr/data mem
    reg [INSTR_WIDTH-1:0] ram [0:DEPTH-1];
    always @(*) begin
        instr <= ram[pc];
    end
endmodule

module DirectMappedMemory #(
    parameter INPUT_WIDTH,
    parameter DEPTH,
    parameter OUTPUT_WIDTH,
) (
    input [INPUT_WIDTH-1:0] read_in,
    input write_en,
    input [INPUT_WIDTH-1:0] write_in,
    input [OUTPUT_WIDTH-1:0 ]write_out,
    output reg [OUTPUT_WIDTH-1:0] out,
    output reg hit 
);
    assert(INPUT_WIDTH >= DEPTH) else $error("DirectMappedMemory Error: INPUT_WIDTH < DEPTH");
    // assert($clog2(DEPTH) = )
    reg [OUTPUT_WIDTH + INPUT_WIDTH - DEPTH - 1:0] ram [0:DEPTH-1];
    // layout: {DEPTH: [INPUT-DEPTH][OUTPUT]}
    localparam INPUT_MSB = OUTPUT_WIDTH + INPUT_WIDTH - DEPTH - 1;
    localparam INPUT_LSB = OUTPUT_WIDTH;
    localparam OUTPUT_MSB = OUTPUT_WIDTH - 1;
    localparam OUTPUT_LSB = 0;

    always @(write_en) begin
        ram[write_in[DEPTH-1:0]][INPUT_MSB:INPUT_LSB] = write_in[INPUT_MSB:INPUT_LSB];
        ram[write_in[DEPTH-1:0]][OUTPUT_MSB:OUTPUT_LSB] = write_out;
    end

    always @(read_in) begin
        if (ram[read_in[DEPTH-1:0]][INPUT_MSB:INPUT_LSB] == read_in[INPUT_MSB:INPUT_LSB]) begin
            hit = true;
            out = ram[read_in[DEPTH-1:0]][OUTPUT_MSB:OUTPUT_LSB];
        end else begin
            hit = false;
        end
    end
endmodule

module BranchTargetBuffer #(
    parameter DATA_WIDTH = global_params::DATA_WIDTH,
    parameter DEPTH = global_params::BTB_DEPTH,
    parameter STALL_CYCLES = global_params::BRANCH_STALL_CYCLES
) (
    input [DATA_WIDTH-1:0] pc,
    input write_btb,
    input [DATA_WIDTH-1:0] trgt_in,
    output reg [DATA_WIDTH-1:0] trgt_out
    output wire hit;
);

    reg [INSTR_WIDTH-1:0] pc_shift_reg [0:STALL_CYCLES];

    // shift stored pc vals
    assert(STALL_CYCLES > 0) else $error("BRANCH STALL CYCLES not greater than 0");
    always @(pc) begin
        integer i;
        for (i = STALL_CYCLES-1; i > 0; i = i - 1) begin
            pc_shift_reg[i] <= pc_shift_reg[i-1];
        end
        pc_shift_reg[0] = pc;
    end

    DirectMappedMemory #(.INPUT_WIDTH(DATA_WIDTH), .DEPTH(DEPTH), .OUTPUT_WIDTH(DATA_WIDTH)) btb_cache (
        .read_in(pc),
        .write_en(write_btb),
        .write_in(pc_shift_reg[STALL_CYCLES]),
        .write_out(trgt_in),
        .out(trgt_out),
        .hit(hit)
    );
endmodule

module Brancher #(
    parameter INSTR_WIDTH = global_params::INSTR_WIDTH,
    parameter DATA_WIDTH = global_params::DATA_WIDTH,
    parameter BTB_DEPTH = global_params::BTB_DEPTH,
    parameter STALL_CYCLES = global_params::BRANCH_STALL_CYCLES
) (
    input [DATA_WIDTH-1:0] pc,
    // for updating
    input update, 
    input branch_result,
    input [DATA_WIDTH-1:0] trgt_in,
    //
    output reg [DATA_WIDTH-1:0] trgt_out
);

    reg 

    assert(INSTR_WIDTH == 32) else $error("Brancher Error: INSTR != 32");
    wire index = pc[BTB_DEPTH+1:2];
    wire valid = 


endmodule



module IF #(
    parameter DATA_WIDTH = global_params::DATA_WIDTH,
    parameter INSTR_WIDTH = global_params::INSTR_WIDTH
) (
    input clk,
    input pc_write,
    // other input control signals
    // ...
    input [DATA_WIDTH-1:0] brnch_trgt,
    //
    output reg instr_addr,
    output reg instr,
    output reg cntrl, // unsure how many bits

    wire [DATA_WIDTH-1:0] pc,
    wire [DATA_WIDTH-1:0] pc_plus_4
);

    wire [DATA_WIDTH-1:0] mux_pc;
    wire [INSTR_WIDTH-1:0] instr_wire;


    mux_2_to_1 #(DATA_WIDTH) mux(
        .a(pc_plus_4),
        .b(brnch_trgt),
        .sel(brnch),
        .y(mux_pc)
    );

    // always @(posedge clk) begin
    //     if (branch)
    // end


    // branch logic

    InstructionMem #(DATA_WIDTH, INSTR_WIDTH, INSTR_MEM_DEPTH) instr_mem(
        .pc(pc),
        .instr(instr_wire)
    );


    flipflop #(DATA_WIDTH) ff(
        .d(mux_pc),
        .clk(clk),
        .q(pc)
    );

endmodule