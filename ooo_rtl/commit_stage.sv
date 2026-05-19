/*
    For now: keeping register file asynchrous for safety, but can chagne depending on design


    Actually: Don't need arf, instead just have rename table keep additional field of commited mappings, and in case of exception or misporedict,
    get flush instrs in rob behind it, restore rename table, free specualtive phys regs

    currently doing nothinf wiht reest of commit_stage_pkt other members

*/
module commit_stage
import writeback_pkg::*;
(
    input clk,
    input rst,
    input flush_i,
    // committing (signals below are subject to change)
    input commit_stage_pkt_t commit_stage_pkt_i,
    // updating commit state of freelist and rename table
    output decode_commit_pkt_t decode_commit_pkt_o
);

    always_ff @(posedge clk) begin
        if (rst) begin
            decode_commit_pkt_o <= '0;
        // end else if (flush_i) begin
        //     decode_commit_pkt_o <= '0;
        end else begin
            decode_commit_pkt_o.wr_en <= commit_stage_pkt_i.dest_valid;
            decode_commit_pkt_o.prf_ptr <= commit_stage_pkt_i.phys_reg_addr;
            decode_commit_pkt_o.arf_ptr <= commit_stage_pkt_i.arch_reg_addr;
            decode_commit_pkt_o.prev_prf_ptr <= commit_stage_pkt_i.prev_phys_reg_addr;
        end
    end

endmodule