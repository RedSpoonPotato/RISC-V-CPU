/*
    NEED TO ACCOUNT FOR:
    flushing
    stalling (maybe?)
    
*/
module issue_stage 
import decode_pkg::*;
import issue_queue_pkg::*;
#(
    parameter DATA_WIDTH = 32,
    parameter PRF_COUNT,
) (
    input clk,
    input rst,

    // input [INSTR_WIDTH-1:0] instr_i,
    input iq_output_t instr_i,
    input logic instr_valid_i,
    // external comms
    // writeback stage w for scoreboard
    /*
        external comms
            slave
                scoreboard w at writebackstage
    */
    // output 
    output fetch_packet_t fetch_o,
    output logic fetch_valid_o,
    // writeback
    input logic wb_dest_en_i,
    input logic [$clog2(PRF_COUNT)-1:0] wb_dest_ptr_i,
    input logic [DATA_WIDTH-1:0] wb_dest_data_i
);

    logic [$clog2(PRF_COUNT)-1:0] phys_reg_src0_addr;
    logic [$clog2(PRF_COUNT)-1:0] phys_reg_src1_addr;
    logic [DATA_WIDTH-1:0] phys_reg_src0_data;
    logic [DATA_WIDTH-1:0] phys_reg_src1_data;

    register_file physical_register #(
        .DATA_WIDTH(DATA_WIDTH),
        .REG_ADDR_WIDTH($clog2(PRF_COUNT))
    ) (
        .clk(clk),
        .rst(rst),
        // reading
        .addr_r_1_i(phys_reg_src0_addr),
        .addr_r_2_i(phys_reg_src1_addr),
        .data_r_1_o(phys_reg_src0_data),
        .data_r_2_o(phys_reg_src1_data),
        // writing
        .write_en_i(wb_dest_en_i),
        .addr_w_i(wb_dest_ptr_i),
        .data_w_i(wb_dest_data_i),
    );

    always_comb begin
        phys_reg_src0_addr = instr_i.src0_valid ? instr_i.src0_ptr : '0;
        phys_reg_src1_addr = instr_i.src1_valid ? instr_i.src1_ptr : '0;
    end

    always_comb begin
        // fetch_o.instr_valid = instr_i.instr_valid;
        fetch_valid_o   = instr_valid_i;
        fetch_o.op          = instr_i.op;
        fetch_o.speculative = instr_i.speculative;
        fetch_o.store       = instr_i.store;
        fetch_o.dest_valid  = instr_i.dest_valid;
        fetch_o.dest_ptr    = instr_i.dest_ptr;
        fetch_o.src0_valid  = instr_i.src0_valid;
        fetch_o.src0_data   = instr_i.phys_reg_src0_data;
        fetch_o.src1_valid  = instr_i.src1_valid;
        fetch_o.src1_data = instr_i.imm_valid ? 
            format_20b_to_datawidth(instr_i.imm_compr) : 
            phys_reg_src1_data;
    end

endmodule


module register_file #(
    parameter DATA_WIDTH = 32,
    parameter REG_ADDR_WIDTH = 5
) (
    input clk,
    input rst,
    // reading
    input [REG_ADDR_WIDTH-1:0] addr_r_1_i,
    input [REG_ADDR_WIDTH-1:0] addr_r_2_i,
    output logic [DATA_WIDTH-1:0] data_r_1_o,
    output logic [DATA_WIDTH-1:0] data_r_2_o,

    // writing
    input write_en_i,
    input [REG_ADDR_WIDTH-1:0] addr_w_i,
    input [DATA_WIDTH-1:0] data_w_i,
);
    localparam ENTRIES = 2 ** REG_ADDR_WIDTH;

    logic [DATA_WIDTH-1:0] reg_mem [ENTRIES-1:0];

    always_ff @(posedge clk) begin : Writing
        if (rst) begin
            reg_mem <= '0;
        end else begin
            if (write_en_i) begin
                reg_mem[addr_w_i] <= data_w_i;
            end
        end
    end

    always_ff @(posedge clk) begin : Reading
        data_r_1_o <= reg_mem[addr_r_1_i];
        data_r_2_o <= reg_mem[addr_r_2_i];
    end

endmodule