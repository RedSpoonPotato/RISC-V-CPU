/*
    double check outptus for repeated signals that are redundant

    dont actually need ptr incrementing in rob b/c we keep track of rob pointers in decode stage
*/

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
    output rob_full_o,
    // writing to physical register file
    output wb_phys_reg_pkt_t wb_phys_reg_pkt_o,
    // updating pending state in issue queue and rename table
    output rt_and_iq_pending_update_pkt_t rt_iq_update_pkt_o,

    // spec exec answer buffer
    input spec_exec_buffer_instance_pkt_t spec_exec_buffer_instance_pkt_i,
    input spec_exec_answr_pkt_t spec_exec_answr_i,
    output seab_full_o,
    // to if stage
    output shift_reg_pkt_t spec_exec_answr_pkt_o
);

    // rob_instance_pkt_t rob_instance_pkt_ff; not gonna use b/c can save on flipflops while still functional
    ex_mem_stage_pkt_t ex_mem_stage_pkt_ff;
    always_ff @(posedge clk) begin
        ex_mem_stage_pkt_ff <= ex_mem_stage_pkt_i;
    end

    rob_buffer rob_buffer_inst (
        .clk(clk),
        .rst(rst),
        // instantiation
        .rob_instance_pkt_i(rob_instance_pkt_i),
        // updating state
        .ex_mem_stage_pkt_i(ex_mem_stage_pkt_ff),
        // committing (signals below are subject to change)
        .commit_stage_pkt_o(commit_stage_pkt_o),
        // state
        .rob_full_o(rob_full_o),
        // writing to physical register file
        .wb_phys_reg_pkt_o(wb_phys_reg_pkt_o),
        // updating pending state in issue queue and rename table
        .rt_iq_update_pkt_o(rt_iq_update_pkt_o)
    );

    spec_exec_answer_buffer spec_exec_answer_buffer_inst (
        .clk(clk),
        .rst(rst),
        // updating state
        .spec_exec_answr_i(spec_exec_answr_i),
        // state
        .full_o(seab_full_o),
        // instantiation
        .spec_exec_buffer_instance_pkt_i(spec_exec_buffer_instance_pkt_i),
        // comitting
        .commit_en_i(commit_stage_pkt_o.wr_en),
        .spec_exec_answr_pkt_o(spec_exec_answr_pkt_o)
    );

endmodule

module spec_exec_answer_buffer
import writeback_pkg::*;
import exec_mem_utils_pkg::*;
(
    input clk,
    input rst,
    // updating state
    // input ex_mem_stage_pkt_t ex_mem_stage_pkt_i,
    input spec_exec_answr_pkt_t spec_exec_answr_i
    // state
    output full_o,
    // instantiation
    input spec_exec_buffer_instance_pkt_t spec_exec_buffer_instance_pkt_i,
    // comitting
    input logic commit_en_i
    output shift_reg_pkt_t spec_exec_answr_pkt_o
);

    shift_reg_pkt_t sea_buff [0:MAX_SPEC_EXEC_INSTRS-1];
    logic [$clog2(MAX_SPEC_EXEC_INSTRS):0] head_ptr;
    logic [$clog2(MAX_SPEC_EXEC_INSTRS):0] tail_ptr;

    assign full_o = 
        tail_ptr[$clog2(MAX_SPEC_EXEC_INSTRS)-1:0] == head_ptr[$clog2(MAX_SPEC_EXEC_INSTRS)-1:0]
         && tail_ptr[$clog2(MAX_SPEC_EXEC_INSTRS)] == head_ptr[$clog2(MAX_SPEC_EXEC_INSTRS)];

    // buffer management
    always_ff @(posedge clk) begin
        if (rst) begin
            sea_buff <= '0;
            head_ptr <= '0;
            tail_ptr <= '0;
        end else begin
            // instantiation
            if (spec_exec_buffer_instance_pkt_i.wr_en && !full_o) begin
                head_ptr <= head_ptr + 1;
            end
            // updating state
            if (spec_exec_answr_i.trgt_en) begin
                sea_buff[spec_exec_answr_i.spec_exec_ptr].trgt_en <= 1'b1;
                sea_buff[spec_exec_answr_i.spec_exec_ptr].trgt <= spec_exec_answr_i.calc_pc;
                sea_buff[spec_exec_answr_i.spec_exec_ptr].branch_en <= spec_exec_answr_i.branch_en;
                sea_buff[spec_exec_answr_i.spec_exec_ptr].branch_taken <= spec_exec_answr_i.branch_taken;
            end
            // committing
            if (commit_en_i) begin
                tail_ptr <= tail_ptr + 1;
            end
        end
    end

    // committing
    always_comb begin
        if (commit_en_i) begin
            spec_exec_answr_pkt_o = sea_buff[tail_ptr];
        end else begin
            spec_exec_answr_pkt_o = '0;
        end
    end

endmodule

module rob_buffer
import writeback_pkg::*;
import exec_mem_utils_pkg::*;
(
    input clk,
    input rst,
    // instantiation
    input rob_instance_pkt_t rob_instance_pkt_i,
    // updating state
    input ex_mem_stage_pkt_t ex_mem_stage_pkt_i,
    // committing (signals below are subject to change)
    output commit_stage_pkt_t commit_stage_pkt_o,
    // state
    output rob_full_o,
    // output rob_empty_o,
    // writing to physical register file
    output wb_phys_reg_pkt_t wb_phys_reg_pkt_o,
    // updating pending state in issue queue and rename table
    output rt_and_iq_pending_update_pkt_t rt_iq_update_pkt_o
);

    rob_entry_t reorder_buffer [0:ROB_COUNT-1];
    logic [$clog2(ROB_COUNT):0] head_ptr;
    logic [$clog2(ROB_COUNT):0] tail_ptr;

    assign rob_full_o = 
        tail_ptr[$clog2(ROB_COUNT)-1:0] == head_ptr[$clog2(ROB_COUNT)-1:0]
         && tail_ptr[$clog2(ROB_COUNT)] == head_ptr[$clog2(ROB_COUNT)];
    // assign rob_empty_o = tail_ptr == head_ptr;

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
            if (rob_instance_pkt_i.wr_en && !rob_full_o) begin
                reorder_buffer[head_ptr] <= rob_instantiation(rob_instance_pkt_i);
                reorder_buffer[head_ptr].state <= PENDING;
                head_ptr <= head_ptr + 1;
            end
            // updating state
            if (ex_mem_stage_pkt_i.instr_valid) begin
                reorder_buffer[ex_mem_stage_pkt_i.rob_ptr].state <= FINISHED;
            end
            // committing
            if (reorder_buffer[tail_ptr].state == FINISHED) begin
                reorder_buffer[tail_ptr].state <= FREE;
                tail_ptr <= tail_ptr + 1;
            end
        end 
    end

    // committing
    always_comb begin
        if (reorder_buffer[tail_ptr].state == FINISHED) begin
            commit_stage_pkt_o = set_commit_pkt(reorder_buffer[tail_ptr]);
        end else begin
            commit_stage_pkt_o.wr_en <= 0;
        end
    end

    // writing to physical register file
    always_comb begin
        if (ex_mem_stage_pkt_i.instr_valid) begin
            wb_phys_reg_pkt_o.wr_en = ex_mem_stage_pkt_i.dest_valid;
            wb_phys_reg_pkt_o.dest_ptr = reorder_buffer[ex_mem_stage_pkt_i.rob_ptr].phys_reg_addr;
            wb_phys_reg_pkt_o.dest_data = ex_mem_stage_pkt_i.dest_data;
        end else begin
            wb_phys_reg_pkt_o.wr_en = 0;
            wb_phys_reg_pkt_o.dest_ptr = '0;
            wb_phys_reg_pkt_o.dest_data = '0;
        end
    end

    // updating pending state in issue queue and rename table
    always_comb begin
        if (ex_mem_stage_pkt_i.instr_valid) begin
            assert(ex_mem_stage_pkt_i.instr_valid);
            rt_iq_update_pkt_o.wr_en = ex_mem_stage_pkt_i.dest_valid; 
            rt_iq_update_pkt_o.prf_ptr = reorder_buffer[ex_mem_stage_pkt_i.rob_ptr].phys_reg_addr;
            rt_iq_update_pkt_o.arf_ptr = reorder_buffer[ex_mem_stage_pkt_i.rob_ptr].arch_reg_addr;
        end else begin
            rt_iq_update_pkt_o.wr_en = 0;
            rt_iq_update_pkt_o.prf_ptr = '0;
            rt_iq_update_pkt_o.arf_ptr = '0;
        end
    end


endmodule