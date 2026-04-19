/*
    for now, will implement a single cycle load and store (will change later)

    // disclaimer: ai generated the ALU module b/c its boiler plate

*/

module execute_memory_stage 
import issue_queue_pkg::*;
#(
    parameter DATA_WIDTH = 32
) (
    input clk,
    input rst,

    input fetch_packet_t fetch_pkt_i,
    input logic fetch_valid_i,

    // cntrls
    // input alu_cntrl_i, // how many bits?


);

    // routing instruction to EX_MEM_TYPE


    // integer path (1 cycle)

    // load path (atleast 2 cycles: add, then load)

    // store path (atleast 2 cycles: add, then load)

    
endmodule

// for now doing a simple memory, 2 cycles
module mem_stage 
import issue_queue_pkg::*;
import decode_pkg::*;
(
    input clk,
    input rst,
    input logic en_i,
    input logic [FUNCT_COMB_WIDTH-1:0] funct_code_i,
    input logic [DATA_WIDTH-1:0] base_addr_i,
    input logic [DATA_WIDTH-1:0] offset_i,
    input logic [DATA_WIDTH-1:0] store_data_i,
    output logic [DATA_WIDTH-1:0] load_data_o
);

    logic [DATA_WIDTH-1:0] base_addr_ff, offset_ff, store_data_ff, addr;
    logic en_2nd_stage;

    assign addr = base_addr_ff + offset_ff;

    always_ff @(posedge clk) begin
        if (rst || !en_i) begin
            base_addr_ff <= 0;
            offset_ff <= 0;
            store_data_ff <= 0;
        end else begin
            base_addr_ff <= base_addr_i;
            offset_ff <= offset_i;
            store_data_ff <= store_data_i;
        end
        if (rst) begin
            en_2nd_stage <= 0;
        end else begin
            en_2nd_stage <= en_i;
        end
    end

    sram #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(10) // for now, hardcoding to 10 bits (1024 entries)
    ) data_memory (
        .clk(clk),
        .rst(rst),
        .en_i(en_2nd_stage),
        .addr_i(addr),
        .data_i(store_data_ff),
        .data_o(load_data_o)
    );
endmodule

module alu #(
    parameter DATA_WIDTH = 32,
) (
    input  [DATA_WIDTH-1:0] a_i,
    input  [DATA_WIDTH-1:0] b_i
    input  [3:0]  alu_cntrl_i,
    output logic [DATA_WIDTH-1:0] result_o,
    output logic zero_o
);
    // RV32I opcodes
    localparam ADD  = 4'b0000;
    localparam SUB  = 4'b1000;
    localparam XOR  = 4'b0100;
    localparam OR   = 4'b0110;
    localparam AND  = 4'b0111;
    localparam SLL  = 4'b0001;
    localparam SRL  = 4'b0101;
    localparam SRA  = 4'b1101;
    localparam SLT  = 4'b0010;
    localparam SLTU = 4'b0011;

    always_comb begin
        case (alu_cntrl_i)
            // RV32I
            ADD:  result_o = a_i + b_i;
            SUB:  result_o = a_i - b_i;
            AND:  result_o = a_i & b_i;
            OR:   result_o = a_i | b_i;
            XOR:  result_o = a_i ^ b_i;
            SLL:  result_o = a_i << b_i[4:0];
            SRL:  result_o = a_i >> b_i[4:0];
            SRA:  result_o = $signed(a_i) >>> b_i[4:0];
            SLT:  result_o = ($signed(a_i) < $signed(b_i)) ? DATA_WIDTH'd1 : DATA_WIDTH'd0;
            SLTU: result_o = (a_i < b_i) ? DATA_WIDTH'd1 : DATA_WIDTH'd0;

            // will add rest of rv32m instructions later
            default:  result_o = DATA_WIDTH'b010;
        endcase
    end
    // The Zero flag is asserted if the result_o is all zeros.
    assign zero_o = (result_o == DATA_WIDTH'b0);

endmodule

module alu_stage #(
    parameter DATA_WIDTH = 32,
) (
    input  clk,
    input  rst,
    input  en_i,
    input  [DATA_WIDTH-1:0] a_i,
    input  [DATA_WIDTH-1:0] b_i,
    input logic [FUNCT_COMB_WIDTH-1:0] funct_code_i,
    output logic [DATA_WIDTH-1:0] result_o,
    output logic zero_o
);

    logic [DATA_WIDTH-1:0] a, b;
    logic [4:0] alu_cntrl;

    alu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) alu_inst (
        .a_i(a),
        .b_i(b),
        .alu_cntrl_i(alu_cntrl),
        .result_o(result_o),
        .zero_o(zero_o)
    );

    always_ff @(posedge clk) begin
        if (rst || !en_i) begin
            a <= 0;
            b <= 0;
            alu_cntrl <= 0;
            result_o <= 0;
            zero_o <= 0;
        end else begin
            a <= a_i;
            b <= b_i;
            alu_cntrl <= funct_code_i;
        end
    end
endmodule


