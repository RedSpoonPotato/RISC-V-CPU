/*
    For now: keeping register file asynchrous for safety, but can chagne depending on design
*/
module commit_stage
import writeback_pkg::*;
(
    input clk,
    input rst,
    input flush_i,
    // committing (signals below are subject to change)
    input commit_stage_pkt_t commit_stage_pkt_i,
    // architectural register file interface
    input logic arf_wr_en_i,
    input logic [4:0] arf_ptr_i,
    input logic [DATA_WIDTH-1:0] arf_data_i,
    // updating state of freelist
    output logic freelist_wr_en_o,
    output logic [$clog2(PRF_COUNT)-1:0] freelist_prev_phys_reg_addr_o;
);

    // reading (used for restoring architectural state on mispredicted branch)
    // FILL IN LATER

    // writing to architectural register file
    logic arch_dest_en;
    logic [4:0] arch_dest_ptr;
    logic [DATA_WIDTH-1:0] arch_dest_data;

    register_file_async_read architectural_register #(
        .DATA_WIDTH(DATA_WIDTH),
        .REG_ADDR_WIDTH(5)
    ) (
        .clk(clk),
        .rst(rst),
        // reading
        .addr_r_1_i(arch_reg_src0_addr),
        .addr_r_2_i(arch_reg_src1_addr),
        .data_r_1_o(arch_reg_src0_data),
        .data_r_2_o(arch_reg_src1_data),
        // writing
        .write_en_i(arch_dest_en),
        .addr_w_i(arch_dest_ptr),
        .data_w_i(arch_dest_data),
    );

    always_comb begin
        arch_dest_en = commit_stage_pkt_i.wr_en && commit_stage_pkt_i.dest_valid;
        arch_dest_ptr = commit_stage_pkt_i.arch_reg_addr;
        arch_dest_data = '0; // FILL IN LATER
    end

endmodule