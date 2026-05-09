
module writeback_stage
import writeback_pkg::*;
(
    input clk,
    input rst,
    input flush_i,
    // instantiation
    input rob_instance_pkt_t rob_instance_pkt_i,
    // updating state
    input ex_mem_stage_pkt_t ex_mem_stage_pkt_i,
    // committing (signals below are subject to change)
    output commit_stage_pkt_t commit_stage_pkt_o,
    // state
    output full_o,
    output empty_o,
    // writing to physical register file
    output wb_phys_reg_pkt_t wb_phys_reg_pkt_o,
    // updating pending state in issue queue and rename table
    output rename_table_and_issue_queue_update_pkt_t rt_iq_update_pkt_o
);

    // rob_instance_pkt_t rob_instance_pkt_ff; not gonna use b/c can save on flipflops while still functional
    ex_mem_stage_pkt_t ex_mem_stage_pkt_ff;
    always_ff @(posedge clk) begin
        ex_mem_stage_pkt_ff <= ex_mem_stage_pkt_i;
    end

    rob_entry_t reorder_buffer [0:ROB_COUNT-1];
    logic [$clog2(ROB_COUNT):0] head_ptr;
    logic [$clog2(ROB_COUNT):0] tail_ptr;

    assign full_o = 
        tail_ptr[$clog2(ROB_COUNT)-1:0] == head_ptr[$clog2(ROB_COUNT)-1:0]
         && tail_ptr[$clog2(ROB_COUNT)] == head_ptr[$clog2(ROB_COUNT)];
    assign empty_o = tail_ptr == head_ptr;

    // reorder buffer management
    always_ff @(posedge clk) begin
        if (rst) begin
            reorder_buffer <= '0;
            foreach (reorder_buffer[i]) begin
                reorder_buffer[i].state <= FREE;
            end 
            head_ptr <= '0;
            tail_ptr <= '0;
        end else begin
            // instantiation
            if (rob_instance_pkt_i.wr_en && !full_o) begin
                reorder_buffer[head_ptr] <= rob_instantiation(rob_instance_pkt_i);
                reorder_buffer[head_ptr].state <= PENDING;
                head_ptr <= head_ptr + 1;
            end
            // updating state
            if (ex_mem_stage_pkt_ff.instr_valid) begin
                reorder_buffer[ex_mem_stage_pkt_ff.rob_ptr].state <= FINISHED;
            end
            // committing
            if (reorder_buffer[tail_ptr].state == FINISHED) begin
                commit_stage_pkt_o <= set_commit_pkt(reorder_buffer[tail_ptr]);
                reorder_buffer[tail_ptr].state <= FREE;
                tail_ptr <= tail_ptr + 1;
            end else begin
                commit_stage_pkt_o.wr_en <= 0;
            end
        end 
    end

    // writing to physical register file
    always_comb begin
        if (ex_mem_stage_pkt_ff.instr_valid) begin
            wb_phys_reg_pkt_o.wr_en = ex_mem_stage_pkt_ff.dest_valid;
            wb_phys_reg_pkt_o.dest_ptr = reorder_buffer[ex_mem_stage_pkt_ff.rob_ptr].phys_reg_addr;
            wb_phys_reg_pkt_o.dest_data = ex_mem_stage_pkt_ff.dest_data;
        end else begin
            wb_phys_reg_pkt_o.wr_en = 0;
            wb_phys_reg_pkt_o.dest_ptr = '0;
            wb_phys_reg_pkt_o.dest_data = '0;
        end
    end

    // updating pending state in issue queue and rename table
    always_comb begin
        if (ex_mem_stage_pkt_ff.instr_valid) begin
            assert(ex_mem_stage_pkt_ff.instr_valid);
            rt_iq_update_pkt_o.wr_en = ex_mem_stage_pkt_ff.dest_valid; 
            rt_iq_update_pkt_o.prf_ptr = reorder_buffer[ex_mem_stage_pkt_ff.rob_ptr].phys_reg_addr;
            rt_iq_update_pkt_o.arf_ptr = reorder_buffer[ex_mem_stage_pkt_ff.rob_ptr].arch_reg_addr;
        end else begin
            rt_iq_update_pkt_o.wr_en = 0;
            rt_iq_update_pkt_o.prf_ptr = '0;
            rt_iq_update_pkt_o.arf_ptr = '0;
        end
    end
    

endmodule
