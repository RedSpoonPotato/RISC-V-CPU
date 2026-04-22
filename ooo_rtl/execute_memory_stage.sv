/*
    for now, will implement a single cycle load and store (will change later)

    // disclaimer: ai generated the ALU module b/c its boiler plate

    note: for all stages, might need to add extra inputs for information required for
        other stages

    note: need ot got back to issue_utils and account for pc_plus_4 in fetch_packet_t

*/

module execute_memory_stage 
import issue_queue_pkg::*;
import writeback_pkg::*;
#(
    parameter DATA_WIDTH = 32
) (
    input clk,
    input rst,

    input fetch_packet_t fetch_pkt_i,
    input logic fetch_valid_i,

    // cntrls
    // input alu_cntrl_i, // how many bits?

    // output to writeback stage
        

    // output to (i guess if stage)
    output logic jalr_en,
    output logic [DATA_WIDTH-1:0] jalr_pc_plus_4,
    output logic branch_en,
    output logic branch_taken,
    
);

    NEED TO FIND A WAY TO MULTIPLEX THE OUTPUT

    // routing instruction to EX_MEM_TYPE

    // alu path (1 cycle)
    logic [DATA_WIDTH-1:0] alu_result;
    logic alu_zero;
    alu_stage alu_stage_inst (
        .clk(clk),
        .rst(rst),
        .en_i(fetch_valid_i && fetch_pkt_i.funct_unit_one_hot[ALU]),
        .a_i(fetch_pkt_i.src0_data),
        .b_i(fetch_pkt_i.src1_data),
        .funct_code_i(fetch_pkt_i.funct_code),
        .result_o(alu_result),
        .zero_o(alu_zero)
    );
    
    // mem path (atleast 2 cycles: add, then memory access)
    mem_stage mem_stage_inst (
        .clk(clk),
        .rst(rst),
        .en_i(fetch_valid_i && fetch_pkt_i.funct_unit_one_hot[MEM]),
        .store_i(fetch_pkt_i.store),
        .funct_code_i(fetch_pkt_i.funct_code),
        .base_addr_i(fetch_pkt_i.src0_data),
        .offset_i(fetch_pkt_i.store_offset), // for now, just using imm_compr as offset, will change later
        .store_data_i(fetch_pkt_i.src1_data), // for store instructions
        .load_data_o() // will connect this to writeback stage later
    );

    // branch path (1 cycle for now): if(rs1 == rs2) PC += imm

    // jalr path: rd = PC+4; PC = rs1 + imm

    // auipc path: rd = PC + (imm << 12)
            
endmodule

module auipc_stage
import issue_queue_pkg::*;
(
    input clk,
    input rst,
    input logic en_i,
    input logic [DATA_WIDTH-1:0] pc_plus_4_i,
    input logic [DATA_WIDTH-1:0] imm_i,
    output logic [DATA_WIDTH-1:0] result_o
);
    always_ff @(posedge clk) begin
        if (rst || !en_i) begin
            result_o <= 0;
        end else begin
            result_o <= pc_plus_4_i + (imm_i << 12);
        end
    end
endmodule

module jalr_stage
import issue_queue_pkg::*;
(
    input clk,
    input rst,
    input logic en_i,
    input logic [DATA_WIDTH-1:0] pc_plus_4_i,
    input logic [DATA_WIDTH-1:0] rs1_data_i,
    input logic [DATA_WIDTH-1:0] imm_i,
    output logic [DATA_WIDTH-1:0] result_o,
    output logic [DATA_WIDTH-1:0] pc_plus_4_o
);
    always_ff @(posedge clk) begin
        if (rst || !en_i) begin
            result_o <= 0;
        end else begin
            result_o <= rs1_data_i + imm_i;
            pc_plus_4_o <= pc_plus_4_i;
        end
    end
endmodule

module branch_unit 
import issue_queue_pkg::*;
(
    input logic [FUNCT_COMB_WIDTH-1:0] funct_code_i,
    input logic [DATA_WIDTH-1:0] src0_data_i,
    input logic [DATA_WIDTH-1:0] src1_data_i,
    output logic branch_taken_o
);
    localparam BEQ  = 4'b0000;
    localparam BNE  = 4'b0001;
    localparam BLT  = 4'b0100;
    localparam BGE  = 4'b0101;
    localparam BLTU = 4'b0110;
    localparam BGEU = 4'b0111;

    always_comb begin
        case (funct_code_i)
            BEQ:  branch_taken_o = (src0_data_i == src1_data_i);
            BNE:  branch_taken_o = (src0_data_i != src1_data_i);
            BLT:  branch_taken_o = ($signed(src0_data_i) < $signed(src1_data_i));
            BGE:  branch_taken_o = ($signed(src0_data_i) >= $signed(src1_data_i));
            BLTU: branch_taken_o = (src0_data_i < src1_data_i);
            BGEU: branch_taken_o = (src0_data_i >= src1_data_i);
            default: branch_taken_o = 0;
        endcase
    end
endmodule

// branch: doing comparison, trgt address is done in decode stage, or even in IF 2nd stage
module branch_stage
import issue_queue_pkg::*;
(
    input clk,
    input rst,
    input logic en_i,
    input logic [FUNCT_COMB_WIDTH-1:0] funct_code_i,
    input logic [DATA_WIDTH-1:0] src0_data_i,
    input logic [DATA_WIDTH-1:0] src1_data_i,
    output logic branch_taken_o
);

    logic [DATA_WIDTH-1:0] src0_data_ff, src1_data_ff;
    logic [FUNCT_COMB_WIDTH-1:0] funct_code_ff;

    branch_unit branch_unit_inst (
        .funct_code_i(funct_code_ff),
        .src0_data_i(src0_data_ff),
        .src1_data_i(src1_data_ff),
        .branch_taken_o(branch_taken_o)
    );

    always_ff @(posedge clk) begin
        if (rst || !en_i) begin
            src0_data_ff <= 0;
            src1_data_ff <= 0;
            funct_code_ff <= 0;
        end else begin
            src0_data_ff <= src0_data_i;
            src1_data_ff <= src1_data_i;
            funct_code_ff <= funct_code_i;
        end
    end

endmodule


// for now doing a simple memory, 2 cycles
module mem_stage 
import issue_queue_pkg::*;
import decode_pkg::*;
(
    input clk,
    input rst,
    input logic en_i,
    input logic store_i,
    input logic [FUNCT_COMB_WIDTH-1:0] funct_code_i,
    input logic [DATA_WIDTH-1:0] base_addr_i,
    input logic [DATA_WIDTH-1:0] offset_i,
    input logic [DATA_WIDTH-1:0] store_data_i,
    output logic [DATA_WIDTH-1:0] load_data_o
);

    logic [DATA_WIDTH-1:0] base_addr_ff, offset_ff, store_data_ff, addr;
    logic en_2nd_stage, store_ff;

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
            store_ff <= 0;
        end else begin
            en_2nd_stage <= en_i;
            store_ff <= store_i;
        end
    end

    sram_sync_read #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(10) // for now, hardcoding to 10 bits (1024 entries)
    ) data_memory (
        .clk(clk),
        .we(en_2nd_stage && store_ff),
        .addr(addr),
        .din(store_data_ff),
        .dout(load_data_o)
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


