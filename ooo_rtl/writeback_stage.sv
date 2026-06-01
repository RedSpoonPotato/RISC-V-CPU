/*
    double check outptus for repeated signals that are redundant

    dont actually need ptr incrementing in rob b/c we keep track of rob pointers in decode stage

    might need to fliplfop some of the inputs

    need to wipe some of the rob entries in case of exception
*/

module writeback_stage
import writeback_pkg::*;
import issue_pkg::*;
import exec_mem_pkg::*;
import instr_fetch_pkg::*;
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
    // output rob_full_o,
    // writing to physical register file
    output wb_phys_reg_pkt_t wb_phys_reg_pkt_o,
    // updating pending state in issue queue and rename table
    output rt_and_iq_pending_update_pkt_t rt_iq_update_pkt_o,
    // spec exec answer buffer
    input spec_exec_buffer_instance_pkt_t spec_exec_buffer_instance_pkt_i,
    input spec_exec_answr_pkt_t spec_exec_answr_i,
    // output seab_full_o,
    // to if stage
    output shift_reg_pkt_t spec_exec_answr_pkt_o,
    
    input logic exception_i,
    output logic stall_o,
    input logic mem_buff_wr_en_i,
    input mem_addr_pkt_t mem_addr_pkt_i,
    // output logic load_addr_conflict_o
    output mem_addr_conflict_pkt_t mem_addr_conflict_pkt_o,
    output store_buffer_commit_pkt_t store_buffer_commit_pkt_o
);
    // rob_instance_pkt_t rob_instance_pkt_ff; not gonna use b/c can save on flipflops while still functional
    ex_mem_stage_pkt_t ex_mem_stage_pkt_ff;
    spec_exec_answr_pkt_t spec_exec_answr_ff;
    logic exception_ff;
    always_ff @(posedge clk) begin
        ex_mem_stage_pkt_ff <= ex_mem_stage_pkt_i;
        exception_ff <= exception_i;
        spec_exec_answr_ff <= spec_exec_answr_i;
    end

    logic rob_full, seab_full, mem_addr_full;

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
        .rob_full_o(rob_full),
        // writing to physical register file
        .wb_phys_reg_pkt_o(wb_phys_reg_pkt_o),
        // updating pending state in issue queue and rename table
        .rt_iq_update_pkt_o(rt_iq_update_pkt_o),
        .exception_i(exception_ff)
    );

    spec_exec_answer_buffer spec_exec_answer_buffer_inst (
        .clk(clk),
        .rst(rst),
        // updating state
        .spec_exec_answr_i(spec_exec_answr_ff),
        // state
        .full_o(seab_full),
        // instantiation
        .spec_exec_buffer_instance_pkt_i(spec_exec_buffer_instance_pkt_i),
        // comitting
        .commit_en_i(commit_stage_pkt_o.wr_en),
        .commit_spec_instr_en_i(commit_stage_pkt_o.speculative)
        .spec_exec_answr_pkt_o(spec_exec_answr_pkt_o),
        .exception_i(exception_ff)
    );

    mem_addr_buffer mem_addr_buffer_inst (
        .clk(clk),
        .rst(rst),
        // updating state
        .mem_addr_pkt_i(mem_addr_pkt_i),
        // state
        .full_o(mem_addr_full),
        // instantiation
        .mem_buff_instance_wr_en_i(mem_buff_instance_wr_en_i),
        // comitting
        .commit_en_i(commit_stage_pkt_o.wr_en),
        .store_commit_en_i(commit_stage_pkt_o.store),
        .mem_commit_en_i(commit_stage_pkt_o.mem_op),
        // .load_addr_conflict_o(load_addr_conflict_o),
        // .pc_o()
        .mem_addr_conflict_pkt_t(mem_addr_conflict_pkt_o),
        .store_buffer_commit_pkt_o(store_buffer_commit_pkt_o)
        .exception_i(exception_ff)
    );

    assign stall_o = rob_full && seab_full && mem_addr_full;

endmodule


module mem_addr_buffer
import writeback_pkg::*;
import exec_mem_pkg::*;
import instr_fetch_pkg::*;
(
    input clk,
    input rst,
    // updating state
    // input ex_mem_stage_pkt_t ex_mem_stage_pkt_i,
    // input spec_exec_answr_pkt_t spec_exec_answr_i,
    input mem_addr_pkt_t mem_addr_pkt_i,
    // state
    output full_o,
    // instantiation
    // input spec_exec_buffer_instance_pkt_t spec_exec_buffer_instance_pkt_i,
    input logic mem_buff_instance_wr_en_i,
    // comitting
    input logic commit_en_i,
    input logic store_commit_en_i,
    input logic mem_commit_en_i,
    // output shift_reg_pkt_t spec_exec_answr_pkt_o,
    // combinational output
    // output logic load_addr_conflict_o,
    // output logic [DATA_WIDTH-1:0] pc_o,
    output mem_addr_conflict_pkt_t mem_addr_conflict_pkt_o,
    output store_buffer_commit_pkt_t store_buffer_commit_pkt_o,
    input logic exception_i
);

    mem_addr_entry_t mem_addr_buff [0:MAX_MEM_INSTRS-1];
    logic [$clog2(MAX_MEM_INSTRS):0] head_ptr;
    logic [$clog2(MAX_MEM_INSTRS):0] tail_ptr;
    logic [$clog2(MAX_MEM_INSTRS)-1:0] head_ptr_lower;
    logic [$clog2(MAX_MEM_INSTRS)-1:0] tail_ptr_lower;
    assign head_ptr_lower = head_ptr[$clog2(MAX_MEM_INSTRS)-1:0];
    assign tail_ptr_lower = tail_ptr[$clog2(MAX_MEM_INSTRS)-1:0];

    assign full_o = 
        tail_ptr_lower == head_ptr_lower
         && tail_ptr[$clog2(MAX_MEM_INSTRS)] != head_ptr[$clog2(MAX_MEM_INSTRS)];

    // logic empty;
    // assign empty = tail_ptr == head_ptr;

    // buffer management
    always_ff @(posedge clk) begin
        if (rst || exception_i || mem_addr_conflict_pkt_o.en) begin
            mem_addr_buff <= '{default:'0};
            head_ptr <= '{default:'0};
            tail_ptr <= '{default:'0};
        end else begin
            // instantiation
            if (mem_buff_instance_wr_en_i && !full_o) begin
                // mem_addr_buff[head_ptr_lower].valid = 1'b1;
                head_ptr <= head_ptr + 1;
            end
            // updating state
            if (mem_addr_pkt_i.wr_en) begin
                mem_addr_buff[mem_addr_pkt_i.buff_ptr].valid <= 1'b1;
                mem_addr_buff[mem_addr_pkt_i.buff_ptr].is_store <= mem_addr_pkt_i.is_store;
                mem_addr_buff[mem_addr_pkt_i.buff_ptr].addr <= mem_addr_pkt_i.addr;
                mem_addr_buff[mem_addr_pkt_i.buff_ptr].pc <= mem_addr_pkt_i.pc;
                mem_addr_buff[mem_addr_pkt_i.buff_ptr].store_data <= mem_addr_pkt_i.store_data;
            end
            // committing
            if (commit_en_i && mem_commit_en_i) begin
                mem_addr_buff[tail_ptr_lower].valid <= 1'b0;
                tail_ptr <= tail_ptr + 1;
            end
        end
    end

    // determining memory conflict
    logic [MAX_MEM_INSTRS-1:0] cnflct_arry;
    logic frwd_cnflct;
    always_comb begin
        cnflct_arry = '0;
        frwd_cnflct = '0;
        if (commit_en_i && !exception_i && store_commit_en_i) begin
            for (int i = 0; i < MAX_MEM_INSTRS; i++) begin
                cnflct_arry[i] = mem_addr_buff[i].valid &&
                    i != tail_ptr_lower &&
                    !mem_addr_buff[i].is_store &&
                    mem_addr_buff[i].addr == mem_addr_buff[tail_ptr_lower].addr;
            end
            frwd_cnflct = mem_addr_pkt_i.wr_en &&
                mem_addr_pkt_i.valid && 
                !mem_addr_pkt_i.is_store &&
                mem_addr_pkt_i.addr == mem_addr_buff[tail_ptr_lower].addr &&
                mem_addr_buff[tail_ptr_lower].valid;

            mem_addr_conflict_pkt_o.en = |cnflct_arry || frwd_cnflct;
        end else begin
            mem_addr_conflict_pkt_o.en = '0;
        end
        
        mem_addr_conflict_pkt_o.pc = mem_addr_buff[tail_ptr_lower].pc;
    end

    // setting store pkt when commiting
    always_comb begin
        if (commit_en_i && !exception_i && store_commit_en_i) begin
            store_buffer_commit_pkt_o.en = 1b'1;
            store_buffer_commit_pkt_o.addr = mem_addr_buff[tail_ptr_lower].addr;
            store_buffer_commit_pkt_o.data = mem_addr_buff[tail_ptr_lower].store_data;
        end else begin
            store_buffer_commit_pkt_o = '{default:'0};
        end
    end

endmodule

module spec_exec_answer_buffer
import writeback_pkg::*;
import exec_mem_pkg::*;
import instr_fetch_pkg::*;
(
    input clk,
    input rst,
    // updating state
    // input ex_mem_stage_pkt_t ex_mem_stage_pkt_i,
    input spec_exec_answr_pkt_t spec_exec_answr_i,
    // state
    output full_o,
    // instantiation
    input spec_exec_buffer_instance_pkt_t spec_exec_buffer_instance_pkt_i,
    // comitting
    input logic commit_en_i,
    input logic commit_spec_instr_en_i,
    output shift_reg_pkt_t spec_exec_answr_pkt_o,

    input logic exception_i
);
    logic empty;
    logic forward;

    shift_reg_pkt_t sea_buff [0:MAX_SPEC_EXEC_INSTRS-1];
    logic [$clog2(MAX_SPEC_EXEC_INSTRS):0] head_ptr;
    logic [$clog2(MAX_SPEC_EXEC_INSTRS):0] tail_ptr;
    logic [$clog2(MAX_SPEC_EXEC_INSTRS)-1:0] head_ptr_lower;
    logic [$clog2(MAX_SPEC_EXEC_INSTRS)-1:0] tail_ptr_lower;
    assign head_ptr_lower = head_ptr[$clog2(MAX_SPEC_EXEC_INSTRS)-1:0];
    assign tail_ptr_lower = tail_ptr[$clog2(MAX_SPEC_EXEC_INSTRS)-1:0];

    assign full_o = 
        tail_ptr_lower == head_ptr_lower
         && tail_ptr[$clog2(MAX_SPEC_EXEC_INSTRS)] != head_ptr[$clog2(MAX_SPEC_EXEC_INSTRS)];

    assign empty = head_ptr == tail_ptr;

    // buffer management
    always_ff @(posedge clk) begin
        if (rst || exception_i) begin
            sea_buff <= '{default:'0};
            head_ptr <= '{default:'0};
            tail_ptr <= '{default:'0};
        end else begin
            // instantiation
            if (spec_exec_buffer_instance_pkt_i.wr_en && !full_o) begin
                head_ptr <= head_ptr + 1;
            end
            // updating state
            if (spec_exec_answr_i.trgt_en && !forward) begin
                sea_buff[spec_exec_answr_i.spec_exec_ptr] <= set_wb_shift_reg_pkt(spec_exec_buffer_instance_pkt_i);
            end
            // committing
            if ((commit_en_i && commit_spec_instr_en_i) || forward) begin
                tail_ptr <= tail_ptr + 1;
            end
        end
    end

    assign forward = empty && spec_exec_answr_i.trgt_en;

    // committing
    always_comb begin
        if (commit_en_i && commit_spec_instr_en_i && !exception_i) begin
            if (forward) begin: Forwarding
                // spec_exec_answr_pkt_o = spec_exec_answr_i;
                spec_exec_answr_pkt_o = set_wb_shift_reg_pkt(spec_exec_buffer_instance_pkt_i);
            end else begin
                spec_exec_answr_pkt_o = sea_buff[tail_ptr_lower];
            end
        end else begin
            spec_exec_answr_pkt_o = '{default:'0};
        end
    end

endmodule

module rob_buffer
import writeback_pkg::*;
import exec_mem_pkg::*;
import issue_pkg::*;
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
    output rt_and_iq_pending_update_pkt_t rt_iq_update_pkt_o,
    
    input logic exception_i
);

    rob_entry_t reorder_buffer [0:ROB_COUNT-1];
    logic [$clog2(ROB_COUNT):0] head_ptr;
    logic [$clog2(ROB_COUNT):0] tail_ptr;
    logic [$clog2(ROB_COUNT)-1:0] head_ptr_lower;
    logic [$clog2(ROB_COUNT)-1:0] tail_ptr_lower;
    assign head_ptr_lower = head_ptr[$clog2(ROB_COUNT)-1:0];
    assign tail_ptr_lower = tail_ptr[$clog2(ROB_COUNT)-1:0];

    assign rob_full_o = 
        tail_ptr_lower == head_ptr_lower
         && tail_ptr[$clog2(ROB_COUNT)] != head_ptr[$clog2(ROB_COUNT)];
    // assign rob_empty_o = tail_ptr == head_ptr;

    // reorder buffer management
    always_ff @(posedge clk) begin
        if (rst || exception_i) begin
            reorder_buffer <= '{default:'0};
            foreach (reorder_buffer[i]) begin
                reorder_buffer[i].state <= FREE;
            end
            head_ptr <= '{default:'0};
            tail_ptr <= '{default:'0};
        end else begin
            // instantiation
            if (rob_instance_pkt_i.wr_en && !rob_full_o) begin
                reorder_buffer[head_ptr_lower] <= rob_instantiation(rob_instance_pkt_i);
                reorder_buffer[head_ptr_lower].state <= PENDING;
                head_ptr <= head_ptr + 1;
            end
            // updating state
            if (ex_mem_stage_pkt_i.instr_valid) begin
                reorder_buffer[ex_mem_stage_pkt_i.rob_ptr].state <= FINISHED;
            end
            // committing
            if (reorder_buffer[tail_ptr_lower].state == FINISHED) begin
                reorder_buffer[tail_ptr_lower].state <= FREE;
                tail_ptr <= tail_ptr + 1;
            end
        end 
    end

    // committing
    always_comb begin
        if (reorder_buffer[tail_ptr_lower].state == FINISHED && !exception_i) begin
            commit_stage_pkt_o = set_commit_pkt(reorder_buffer[tail_ptr_lower]);
        end else begin
            commit_stage_pkt_o = '{default:'0};
            // commit_stage_pkt_o.wr_en = 0;
        end
    end

    // writing to physical register file
    always_comb begin
        if (ex_mem_stage_pkt_i.instr_valid && !exception_i) begin
            wb_phys_reg_pkt_o.wr_en = ex_mem_stage_pkt_i.dest_valid;
            wb_phys_reg_pkt_o.dest_ptr = reorder_buffer[ex_mem_stage_pkt_i.rob_ptr].phys_reg_addr;
            wb_phys_reg_pkt_o.dest_data = ex_mem_stage_pkt_i.dest_data;
        end else begin
            wb_phys_reg_pkt_o.wr_en = 0;
            wb_phys_reg_pkt_o.dest_ptr = '{default:'0};
            wb_phys_reg_pkt_o.dest_data = '{default:'0};
        end
    end

    // updating pending state in issue queue and rename table
    always_comb begin
        if (ex_mem_stage_pkt_i.instr_valid && !exception_i) begin
            rt_iq_update_pkt_o.wr_en = ex_mem_stage_pkt_i.dest_valid;
            rt_iq_update_pkt_o.prf_ptr = reorder_buffer[ex_mem_stage_pkt_i.rob_ptr].phys_reg_addr;
            rt_iq_update_pkt_o.arf_ptr = reorder_buffer[ex_mem_stage_pkt_i.rob_ptr].arch_reg_addr;
        end else begin
            rt_iq_update_pkt_o.wr_en = 0;
            rt_iq_update_pkt_o.prf_ptr = '{default:'0};
            rt_iq_update_pkt_o.arf_ptr = '{default:'0};
        end
    end

endmodule