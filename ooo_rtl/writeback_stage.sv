
module writeback_stage 
import writeback_pkg::*;
(
    input clk,
    input rst,
    input flush_i,

    // inputting a state from decode stage
    input rob_instance_pkt_t rob_instance_pkt_i,
    // updating state (coming from exec_mem stage)
    input ex_mem_stage_pkt_t ex_mem_stage_pkt_i,
    // commiting to arch file
    output commit_stage_pkt_t commit_stage_pkt_o

    // cntrls
    // input alu_cntrl_i, // how many bits?

    /*
        external comms
            master
                write to SB
                write to issue queue
            slave
                decode stage r/w for rob 
                commit stage r/w for rob
                commit stage r/w for fsb
    */
);
  
    // internal comms
    // write to ROB
    // write to FSB




endmodule

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
    output logic prf_wr_en_o,
    output logic [$clog2(PRF_COUNT)-1:0] prf_ptr_o,
    output logic [DATA_WIDTH-1:0] prf_data_o,
    // updating pending state in issue queue and rename table
    output logic iq_pending_wr_en_o,
    output logic [$clog2(PRF_COUNT)-1:0] iq_pending_prf_ptr_o,
    output logic [4:0] rt_arf_ptr_o,
    
);

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
            if (ex_mem_stage_pkt_i.instr_valid) begin
                reorder_buffer[ex_mem_stage_pkt_i.rob_ptr].state <= FINISHED;
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
        if (ex_mem_stage_pkt_i.instr_valid) begin
            prf_wr_en_o = ex_mem_stage_pkt_i.dest_valid;
            prf_ptr_o = reorder_buffer[ex_mem_stage_pkt_i.rob_ptr].phys_reg_addr;
            prf_data_o = ex_mem_stage_pkt_i.dest_data;
        end else begin
            prf_wr_en_o = 0;
            prf_ptr_o = '0;
            prf_data_o = '0;
        end
    end

    // updating pending state in issue queue
    always_comb begin
        if (ex_mem_stage_pkt_i.instr_valid && ex) begin
            iq_pending_wr_en_o = 1; 
            iq_pending_prf_ptr_o = reorder_buffer[ex_mem_stage_pkt_i.rob_ptr].phys_reg_addr;
            rt_arf_ptr_o = reorder_buffer[ex_mem_stage_pkt_i.rob_ptr].arch_reg_addr;
        end else begin
            iq_pending_wr_en_o = 0;
            iq_pending_prf_ptr_o = '0;
            rt_arf_ptr_o = '0;
        end
    end
    

endmodule
