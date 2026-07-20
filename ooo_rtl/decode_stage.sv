/*
    TO DO:
        rob logic
        stalling logic for all cases
            branch mispredciting
            (free list being full should count as stalling)
            iq being full should also count as sstalling
        arf restoring on the case of branch mispredict
        communicaiton between wb and decode
        what about intrusciton fetch stuff?
        make sure for the case of load, and seperately for the case of store,
            we are sending setting the outputs properly
        Need to add logic that checks new incoming instruciton into iq to make sure no strucutral
            hazards 
    
    Check every signal to make sure they are driven or beign driven

    check that logic accoutning for adde flipflops for inputs is correct 
    with internal logic of modules
    - especially with bypassing in certain modules given the timing of when the siginals reach

    do soemthing with instr_en signal

    for free_list, when allocating new locations, might not want to give out phys_reg_0, unsure will haev ot come back to

    do we flipflop exception_i
*/


// Need to handle stalling, flushing, and branch/jalr, priority (maybe one solution is restore usig rename table like exceptions

module decode_stage 
    import general_pkg::*;
    import writeback_pkg::*;
    import instr_fetch_pkg::*;
    import decode_pkg::*;
    import issue_pkg::*;
(
    input clk,
    input rst,
    
    // bad name
    input if_output_pkt_t if_input_i,

    // cntrls

    // free list
    // input free_list_update_pkt_t free_list_update_pkt_i,
    input commit_stage_pkt_t decode_commit_pkt_i, // For now, will not use flipflops
    // output logic free_list_empty_o;

    input rt_and_iq_pending_update_pkt_t rt_iq_update_pkt_i,

    // output logic
    // output logic decode_instr_valid_o,
    output iq_output_t decode_instr_o,

    // instantiating rob entry
    output rob_instance_pkt_t rob_instance_pkt_o,

    // to if stage
    output logic is_spec_instr_o,

    // to wb stage
    output spec_exec_buffer_instance_pkt_t spec_exec_buffer_instance_pkt_o,

    // to issue stage
    // output logic pc_instr
    output pc_buff_instance_pkt_t pc_buff_inst_o,

    output logic mem_buff_wr_en_o,

    input logic exception_i, // not sure if we need to flipflop this
    output logic stall_o
);

    /* input flip flops */
    if_output_pkt_t if_input_ff;

    // free_list_update_pkt_t free_list_update_pkt_ff;
    // rename_table_update_pkt_t rename_table_update_pkt_ff;
    // issue_queue_update_pkt_t issue_queue_update_pkt_ff;
    rt_and_iq_pending_update_pkt_t rt_iq_update_pkt_ff;
    // logic exception_ff;

    always_ff @(posedge clk) begin
        if_input_ff <= if_input_i;
        // free_list_update_pkt_ff <= free_list_update_pkt_i;
        // rename_table_update_pkt_ff <= rename_table_update_pkt_i;
        // issue_queue_update_pkt_ff <= issue_queue_update_pkt_i;
        rt_iq_update_pkt_ff <= rt_iq_update_pkt_i;
        // exception_ff <= exception_i;
    end

    /* free list */
    logic free_list_rd_en;
    logic [$clog2(PRF_COUNT)-1:0] free_list_free_ptr;
    logic free_list_empty;

    free_list free_list_inst
    (
        .clk(clk),
        .rst(rst),
        // notify of reaching phys register
        // .wr_en_i(decode_commit_pkt_i.wr_en && !decode_commit_pkt_i.dest_valid),
        .wr_en_i(decode_commit_pkt_i.wr_en && decode_commit_pkt_i.dest_valid),
        .prev_phys_ptr_i(decode_commit_pkt_i.prev_phys_reg_addr),
        // for commiting
        .exception_i(exception_i),
        .commited_ptr_i(decode_commit_pkt_i.phys_reg_addr),
        // reading
        .rd_en_i(free_list_rd_en),
        .free_ptr_o(free_list_free_ptr),
        // state
        .none_free_o(free_list_empty)
        // .empty_o(free_list_empty)
    );

    /* rename table */
    // intial write
    logic [$clog2(PRF_COUNT)-1:0] rename_table_prf_dest_ptr;
    logic [4:0] rename_table_arf_ptr;
    logic rename_table_decode_en;
    // reading from issue queue
    logic [4:0] rename_table_arf_src0;
    logic [4:0] rename_table_arf_src1;
    logic [$clog2(PRF_COUNT)-1:0] rename_table_prf_src0;
    logic [$clog2(PRF_COUNT)-1:0] rename_table_prf_src1;
    logic rename_table_src0_pending;
    logic rename_table_src1_pending;
    // reading from rob logic
    logic [4:0] rename_table_rob_dest_arf;
    logic [$clog2(PRF_COUNT)-1:0] rename_table_rob_dest_prf;

    rename_table_async_read rename_table_async_read_inst(
        .clk(clk),
        .rst(rst),
        // initial write
        .prf_ptr_i(rename_table_prf_dest_ptr),
        .arf_ptr_i(rename_table_arf_ptr),
        .decode_en_i(rename_table_decode_en),
        // to signal its in PRF
        .prf_ptr_sb_i(rt_iq_update_pkt_ff.prf_ptr),
        .arf_ptr_sb_i(rt_iq_update_pkt_ff.arf_ptr),
        .writeback_en_i(rt_iq_update_pkt_ff.wr_en),
        // ports for issue queue to read from 
        .arf_src0_i(rename_table_arf_src0),
        .arf_src1_i(rename_table_arf_src1),
        .prf_src0_o(rename_table_prf_src0),
        .prf_src1_o(rename_table_prf_src1),
        .src0_pending_o(rename_table_src0_pending),
        .src1_pending_o(rename_table_src1_pending),
        // ports for rob_instance_creation logic to read from
        .rob_dest_arf_i(rename_table_rob_dest_arf),
        .rob_dest_prf_o(rename_table_rob_dest_prf),
        // ports for committing
        .commit_en_i(decode_commit_pkt_i.wr_en && decode_commit_pkt_i.dest_valid),
        .commit_arf_i(decode_commit_pkt_i.arch_reg_addr),
        .commit_prf_i(decode_commit_pkt_i.phys_reg_addr),
        // ports for exception handling
        .exception_i(exception_i)
    );

    /* issue queue */
    iq_entry_t issue_queue_entry;
    iq_output_t issue_queue_instr_out;
    logic issue_queue_empty;
    logic issue_queue_full;
    logic issue_queue_all_stalled;
    logic [MAX_EXEC_CYCLE:0] issue_queue_future_exec_stage_slots;

    issue_queue issue_queue_inst (
        .clk(clk),
        .rst(rst),
        .iq_entry_i(issue_queue_entry),
        // updating state of pending bit
        // for writing from right before writeback stage into decode stage
        .prf_dst_i(rt_iq_update_pkt_ff.prf_ptr),
        .prf_wr_en_i(rt_iq_update_pkt_ff.wr_en),
        // for checking for structural hazards
        .future_exec_stage_slots_i(issue_queue_future_exec_stage_slots),      
        .instr_o(issue_queue_instr_out),
        // also other output information 
        .empty_o(issue_queue_empty),
        .full_o(issue_queue_full),
        .all_stalled_o(issue_queue_all_stalled), // when all current entries are still stalling, does also account for input "prf_dst_i"
        .exception_i(exception_i)
    );

    logic mini_scoreboard_wr_en;
    logic [INSTR_COMPRESS_WIDTH-1:0] mini_scoreboard_op;

    // case: account for when there is a faield branch rpediiton and must clear
    mini_scoreboard mini_scoreboard_inst (
        .clk(clk),
        .rst(rst),
        // new entry
        .wr_en_i(mini_scoreboard_wr_en),
        .op_i(mini_scoreboard_op),
        // outputting to iq
        // 1 extra: 1 for reg fetch stage
        .future_exec_stage_slots_o(issue_queue_future_exec_stage_slots),
        // stalling or clearing
        .exception_i(exception_i) // same functionality as rst
    );

    logic [31:0] instr_ff;
    assign instr_ff = if_input_ff.instr;

    // setting rest of rename table inputs
    always_comb begin
        rename_table_prf_dest_ptr = '{default:'0};
        rename_table_arf_ptr = '{default:'0};
        if (free_list_rd_en) begin
            rename_table_prf_dest_ptr = free_list_free_ptr;
            rename_table_arf_ptr = instr_ff[11:7];
        end
        rename_table_decode_en = free_list_rd_en;
        rename_table_arf_src0 = instr_ff[19:15];
        rename_table_arf_src1 = instr_ff[24:20];
        // for rob_logic reading from rename table
        rename_table_rob_dest_arf = instr_ff[11:7];
    end

    logic new_instr_ready; // all operands are avail
    logic iq_instr_ready;
    logic dispatch_instr;
    logic cntrl_instr; // branch or jump
    logic pc_instr;
    logic mem_instr;

    logic master_instr_valid; // NEED TO SET, should depend alos upon exception
    assign master_instr_valid = if_input_ff.instr_valid && !exception_i;

    // setting cntrl instructions
    always_comb begin

        cntrl_instr = (instr_ff[6:0] == 7'b1100011) || // Branch
                      (instr_ff[6:0] == 7'b1101111) || // JAL
                      (instr_ff[6:0] == 7'b1100111);   // JALR
        
        mem_instr = (instr_ff[6:0] == 7'b0000011) || (instr_ff[6:0] == 7'b0100011);

        // pc_instr = (cntrl_instr || 
                    // instr_ff[6:0] == 7'b0010111); // AUIPC

        pc_instr = cntrl_instr || 
            instr_ff[6:0] == 7'b0010111 || // AUIPC
            instr_ff[6:0] == 7'b0100011; // Store
        
        // free_list_rd_en = 1;
        // i think this is bad, this is really a stall condition
        // if ((free_list_empty && issue_queue_entry.dest_valid) || issue_queue_full)
            // free_list_rd_en = 0;
        free_list_rd_en = master_instr_valid && 
            issue_queue_entry.dest_valid && 
            !stall_o && 
            instr_ff[11:7] != 5'b00000;

        // determined by operands being ready
        // free list not being empty, assuming it needs it
        // new_instr_ready = 
        //     (!(has_dest(instr_ff[6:0]) && free_list_empty) ||
        //     !(has_src0(instr_ff[6:0]) && rename_table_src0_pending) ||
        //     !(has_src1(instr_ff[6:0]) && rename_table_src1_pending)) &&
        //     master_instr_valid;

        new_instr_ready = 
            !((has_dest(instr_ff[6:0]) && free_list_empty) ||
            (has_src0(instr_ff[6:0]) && rename_table_src0_pending) ||
            (has_src1(instr_ff[6:0]) && rename_table_src1_pending)) &&
            master_instr_valid;
        
        iq_instr_ready = !issue_queue_empty && !issue_queue_all_stalled && !exception_i;

        dispatch_instr = new_instr_ready || iq_instr_ready;

        // might need to modify to acocount for stalling/flushing
        mini_scoreboard_wr_en = dispatch_instr;
    end

    logic [$clog2(ROB_COUNT):0] rob_head_counter;
    logic [$clog2(MAX_SPEC_EXEC_INSTRS):0] spec_exec_counter;
    logic [$clog2(MAX_PC_INSTRS)-1:0] pc_instr_counter;
    logic [$clog2(MAX_MEM_INSTRS):0] mem_buff_counter;
    
    always_ff @(posedge clk) begin
        if (rst || exception_i) begin
            rob_head_counter <= '{default:'0};
            spec_exec_counter <= '{default:'0};
            pc_instr_counter <= '{default:'0};
            mem_buff_counter <= '{default:'0};
        end else begin
            if (master_instr_valid) begin
                rob_head_counter <= rob_head_counter + 1;
                if (cntrl_instr) begin
                    spec_exec_counter <= spec_exec_counter + 1;
                end
                if (pc_instr) begin
                    pc_instr_counter <= pc_instr_counter + 1;
                end 
                if (mem_instr) begin
                    mem_buff_counter <= mem_buff_counter + 1;
                end
            end
        end
    end

    assign stall_o = free_list_empty || issue_queue_full;

    // setting issue queue entry values
    always_comb begin
        if (master_instr_valid) begin
            issue_queue_entry = decode_pkg::instr_to_iq_entry_partial(instr_ff, master_instr_valid);
            // filling in remanining values (free list being full should count as stalling)
            // iq being full should also count as stalling
            // if stalling, comeback to this valid signal
            // issue_queue_entry.valid = !new_instr_ready || iq_instr_ready;
            issue_queue_entry.valid = (!new_instr_ready || iq_instr_ready) && master_instr_valid; // valid in this case means wr_en to iq
            // issue_queue_entry.dest_ptr = free_list_free_ptr;
            issue_queue_entry.dest_ptr = rename_table_prf_dest_ptr;
            issue_queue_entry.src0_pending = rename_table_src0_pending;
            issue_queue_entry.src0_ptr = issue_queue_entry.src0_valid ? rename_table_prf_src0 : '{default:'0};
            issue_queue_entry.src1_pending = rename_table_src1_pending;
            issue_queue_entry.src1_ptr = issue_queue_entry.src1_valid ? rename_table_prf_src1 : '{default:'0};
            issue_queue_entry.rob_ptr = rob_head_counter;
            issue_queue_entry.spec_exec_ptr = cntrl_instr ? spec_exec_counter : '{default:'0};
            issue_queue_entry.pc_instr = pc_instr;
            issue_queue_entry.pc_buff_ptr = pc_instr ? pc_instr_counter : '{default:'0};
            issue_queue_entry.mem_buff_ptr = mem_instr ? mem_buff_counter : '{default:'0};
        end else begin
            issue_queue_entry = '{default: '0};
        end
    end

    // setting decode stage output and scoreboard
    always_comb begin
        // if any sort of stalling need to probaly adjust this
        // COME BACK TO THIS
        if (iq_instr_ready) begin
            decode_instr_o = issue_queue_instr_out;
            decode_instr_o.valid = 1;
        end else if (new_instr_ready) begin
            decode_instr_o = decode_pkg::entry_to_output(issue_queue_entry);
            decode_instr_o.valid = 1;
        end else begin // stalling
            decode_instr_o = '{default:'0};
            decode_instr_o.valid = 0;
        end

        mini_scoreboard_op = decode_instr_o.op;
    end

    always_comb begin
        if (master_instr_valid) begin
            // to wb
            rob_instance_pkt_o.wr_en = 1;
            rob_instance_pkt_o.speculative = issue_queue_entry.speculative;
            rob_instance_pkt_o.store = issue_queue_entry.store;
            rob_instance_pkt_o.mem_op = mem_instr;
            rob_instance_pkt_o.dest_valid = issue_queue_entry.dest_valid;
            rob_instance_pkt_o.phys_reg_addr = issue_queue_entry.dest_ptr;
            rob_instance_pkt_o.arch_reg_addr = instr_ff[11:7];
            rob_instance_pkt_o.prev_phys_reg_addr = rename_table_rob_dest_prf; /// what about J and U types
            `ifdef DEBUG
            rob_instance_pkt_o.pc = if_input_ff.pc;
            `endif

            spec_exec_buffer_instance_pkt_o.wr_en = cntrl_instr;
            // to issue
            pc_buff_inst_o.wr_en = pc_instr;
            pc_buff_inst_o.wr_ptr = pc_instr_counter;
            pc_buff_inst_o.pc_in = if_input_ff.pc;
            // to if
            is_spec_instr_o = cntrl_instr;
            // to ex_mem
            mem_buff_wr_en_o = mem_instr;
        end else begin
            rob_instance_pkt_o = '{default:'0};
            // spec_exec_answer_buffer_pkt_o.wr_en = '0;
            spec_exec_buffer_instance_pkt_o.wr_en = '0;
            pc_buff_inst_o = '{default:'0};
            is_spec_instr_o = '0;
            mem_buff_wr_en_o = '0;
        end
    end

endmodule


// automatically outputs the next available free prf pointer
module free_list 
import decode_pkg::*;
import general_pkg::*;
(
    input clk,
    input rst,
    // commiting
    input logic wr_en_i,
    input logic [$clog2(PRF_COUNT)-1:0] prev_phys_ptr_i,
    // for exception handling
    input logic exception_i,
    input logic [$clog2(PRF_COUNT)-1:0] commited_ptr_i,
    // reading
    input logic rd_en_i,
    output logic [$clog2(PRF_COUNT)-1:0] free_ptr_o,
    // state
    output logic none_free_o
);
    logic [PRF_COUNT-2:0] free_list; // 1'b1 means free
    logic [PRF_COUNT-2:0] commit_list; // 1'b1 means committed
    logic [$clog2(PRF_COUNT)-1:0] free_ptr_int;

    // state
    assign none_free_o = ~|free_list;
    // reading
    logic found;
    always_comb begin
        free_ptr_int = PRF_COUNT-2;
        found = 0;
        for (int i = 0; i < PRF_COUNT-1; i++) begin
            if (free_list[i] == 1 && !found) begin
                free_ptr_int = i;
                found = 1;
            end
        end
        free_ptr_o = free_ptr_int + 1;
    end
    
    always_ff @(posedge clk) begin
        if (rst) begin
            free_list <= '{default:'1};
            commit_list <= '{default:'0};
        end else begin
            if (exception_i) begin
                free_list <= ~commit_list;
            end else begin
                // writing
                if (wr_en_i) begin
                    if (prev_phys_ptr_i != '0) begin
                        free_list[prev_phys_ptr_i - 1] <= 1;
                        commit_list[prev_phys_ptr_i - 1] <= 0;
                    end
                    if (commited_ptr_i != '0) begin
                        commit_list[commited_ptr_i - 1] <= 1;
                    end
                end
                // reading
                if (!none_free_o && rd_en_i) begin
                    free_list[free_ptr_int] <= 0;
                end
            end
        end
    end

    assert property (
        @(posedge clk) disable iff (rst || exception_i)
        !(rd_en_i && none_free_o)
    );

endmodule

// used for knowing where to commit: idk bout that
/* NOTE: 
    could potentially optimize the updating of the pending signal sent by scoreboard
    by bringing the scoreboard into the decode stage
*/
module rename_table_async_read 
import general_pkg::*;
import decode_pkg::*;
(
    input clk,
    input rst,
    // initial write
    input logic [$clog2(PRF_COUNT)-1:0] prf_ptr_i,
    input logic [4:0] arf_ptr_i,
    input logic decode_en_i, 
    // to signal its in PRF, can have the scoreboard tell the RT
    // note: actually prob wont be scoreboard, 
    // is instead wil berigt before writeback
    // another reason for not being sb is b/c if an interrupt happenss
    // want to have 
    input logic [$clog2(PRF_COUNT)-1:0] prf_ptr_sb_i,
    input logic [4:0] arf_ptr_sb_i,
    input logic writeback_en_i,
    // ports for issue queue to read from 
    input logic [4:0] arf_src0_i,
    input logic [4:0] arf_src1_i,
    output logic [$clog2(PRF_COUNT)-1:0] prf_src0_o,
    output logic [$clog2(PRF_COUNT)-1:0] prf_src1_o,
    output logic src0_pending_o,
    output logic src1_pending_o,
    // ports for rob_instance_creation logic to read from
    input logic [4:0] rob_dest_arf_i,
    output logic [$clog2(PRF_COUNT)-1:0] rob_dest_prf_o,
    // ports for committing
    input logic commit_en_i,
    input logic [4:0] commit_arf_i,
    input logic [$clog2(PRF_COUNT)-1:0] commit_prf_i,
    // ports for exception handling (and also brnch/trgt mispredicts)
    input logic exception_i
);
    typedef struct packed {
        logic [$clog2(PRF_COUNT)-1:0] prf_ptr;
        // logic [DATA_WIDTH-1:0] imm;
        // logic spec;
        logic pending;
        // logic valid;
    } rt_entry_t;

    typedef struct packed {
        logic [$clog2(PRF_COUNT)-1:0] prf_ptr;
        // logic valid;
    } commit_map_entry_t;

    // will synthesize to flip flops
    rt_entry_t rename_table [0:31];
    commit_map_entry_t commit_map [0:31];

    // write logic
    always_ff @(posedge clk) begin
        if (rst) begin
            rename_table = '{default:'0};
            commit_map = '{default:'0};
        end 
        else begin
            if (exception_i) begin
                // restore rename table to committed state
                for (int i = 0; i < 32; i++) begin
                    rename_table[i].prf_ptr <= commit_map[i].prf_ptr;
                    rename_table[i].pending <= 0;
                end
            end else begin
                if (writeback_en_i) begin
                    if (rename_table[arf_ptr_sb_i].prf_ptr == prf_ptr_sb_i && (arf_ptr_sb_i != arf_ptr_i || !decode_en_i)) begin
                        rename_table[arf_ptr_sb_i].pending <= 1'b0;
                    end
                end
                if (decode_en_i && arf_ptr_i != '0) begin
                    rename_table[arf_ptr_i].prf_ptr <= prf_ptr_i;
                    rename_table[arf_ptr_i].pending <= 1'b1;
                end
                // if (commit_en_i) begin
                //     commit_map[commit_arf_i] <= commit_prf_i;
                // end
            end
            // is outside the exception_i conditional b/c commit_en_i from input to decode stage is not flipflopped
            if (commit_en_i) begin
                commit_map[commit_arf_i] <= commit_prf_i;
            end
        end
    end

    assert property (
        @(posedge clk) disable iff (rst)
        !(decode_en_i && arf_ptr_i == '0 && prf_ptr_i != '0)
    );

    assert property (
        @(posedge clk) disable iff (rst)
        (rename_table[0].prf_ptr == '0 && rename_table[0].pending == 1'b0)
    );
    
    // assert property (
    //     @(posedge clk) disable iff (rst)
    //     (writeback_en_i && rename_table[arf_src0_i].prf_ptr == prf_ptr_sb_i) |-> (arf_src0_i == arf_ptr_sb_i) 
    // );

    // assert property (
    //     @(posedge clk) disable iff (rst)
    //     (writeback_en_i && rename_table[arf_src1_i].prf_ptr == prf_ptr_sb_i) |-> (arf_src1_i == arf_ptr_sb_i)
    // ) else $fatal("%h,%h,%h,%h", arf_src1_i, arf_ptr_sb_i, rename_table[arf_src1_i].prf_ptr, prf_ptr_sb_i);

    // read logic (asynchronous)
    assign prf_src0_o = rename_table[arf_src0_i].prf_ptr;
    assign prf_src1_o = rename_table[arf_src1_i].prf_ptr;
    // forwarding
    always_comb begin
        if (writeback_en_i && rename_table[arf_src0_i].prf_ptr == prf_ptr_sb_i) begin
            src0_pending_o = 1'b0;
        end else begin
            src0_pending_o = rename_table[arf_src0_i].pending;
        end

        if (writeback_en_i && rename_table[arf_src1_i].prf_ptr == prf_ptr_sb_i) begin
            src1_pending_o = 1'b0;
        end else begin
            src1_pending_o = rename_table[arf_src1_i].pending;
        end
    end
    assign rob_dest_prf_o = rename_table[rob_dest_arf_i].prf_ptr;

endmodule

// should be the module that determines which is the next instruction to be issued
module issue_queue 
    import decode_pkg::*;
    import general_pkg::*;
    (
    input clk,
    input rst,

    input iq_entry_t iq_entry_i,

    // signal from exterior

    // updating state of pending bit
    // for writing from right before writeback stage into decode stage
    input logic [$clog2(PRF_COUNT)-1:0] prf_dst_i,
    input logic prf_wr_en_i,
    // for checking for structural hazards
    // 1 extra: 1 for reg fetch stage
    input logic [MAX_EXEC_CYCLE:0] future_exec_stage_slots_i,
    // output logic [INSTR_COMPRESS_WIDTH-1:0] compr_instr_o;
    output iq_output_t instr_o,
    // also other output information 
    output logic empty_o,
    output logic full_o,
    output logic all_stalled_o, // when all current entries are still stalling, does also account for input "prf_dst_i"
    input logic exception_i
);  

    iq_entry_t iq [0:IQ_SIZE-1];

    // write logic
    logic wr_en;
    assign wr_en = iq_entry_i.valid;

    // read logic
    // also can account for forwarding from before even reaching commit stage, but would have to check conditions before
    logic [IQ_SIZE-1:0] valid_array;
    always_comb begin
        for (int i = 0; i < IQ_SIZE; i++) begin
            valid_array[i] = iq[i].valid;
        end
    end
    assign empty_o = ~(|valid_array);
    assign full_o = &valid_array;

    logic [IQ_SIZE-1:0] ready_array;
    // expensive, see if can optimize
    always_comb begin
        for (int i = 0; i < IQ_SIZE; i++) begin
            ready_array[i] = (
                (!iq[i].src0_valid || !iq[i].src0_pending || ((iq[i].src0_ptr == prf_dst_i) && prf_wr_en_i)) &&
                (!iq[i].src1_valid || !iq[i].src1_pending || ((iq[i].src1_ptr == prf_dst_i) && prf_wr_en_i)) &&
                (iq[i].valid) &&
                (future_exec_stage_slots_i[iq[i].exec_dur] == 0)
            );
        end
        all_stalled_o = ~(|ready_array);
    end

    // asynch read
    logic [IQ_SIZE-1:0] priority_ready_array;
    always_comb begin
        priority_ready_array = '{default:'0};
        instr_o = '{default:'0}; 
        if (!empty_o && !all_stalled_o) begin
            // search for highest priority "ready" entry
            for (int i = 0; i < IQ_SIZE; i++) begin
                if (ready_array[i]) begin
                    priority_ready_array[i] = 1;
                    instr_o = entry_to_output(iq[i]);
                    break;
                end
            end
        end
    end

    always_ff @(posedge clk) begin
        if (rst || exception_i) begin
            iq <= '{default:'0};
            // need to set other values
            // empty_o <= 1;
            // full_o <= 0;
            // all_stalled_o <= 0;
        end 
        else begin
            if (wr_en && !full_o) begin
                // find first empty slot and write instruction
                for (int i = 0; i < IQ_SIZE; i++) begin
                    if (!iq[i].valid) begin
                        iq[i].valid <= 1;
                        iq[i][$bits(iq_entry_t)-2:0] <= iq_entry_i[$bits(iq_entry_t)-2:0];
                        break;
                    end
                end
            end
            // updating pending state
            if (prf_wr_en_i) begin
                for (int i = 0; i < IQ_SIZE; i++) begin
                    if (iq[i].src0_valid && iq[i].src0_pending && iq[i].src0_ptr == prf_dst_i)
                        iq[i].src0_pending <= 0;
                    if (iq[i].src1_valid && iq[i].src1_pending && iq[i].src1_ptr == prf_dst_i)
                        iq[i].src1_pending <= 0;
                end
            end
            // synchronously updating validity
            if (!empty_o && !all_stalled_o) begin
                for (int i = 0; i < IQ_SIZE; i++) begin
                    if (priority_ready_array[i]) begin
                        iq[i].valid <= 0;
                    end
                end
            end
        end
    end

endmodule


module mini_scoreboard
import decode_pkg::*;
import general_pkg::*;
(
    input clk,
    input rst,
    // new entry
    input wr_en_i,
    input [INSTR_COMPRESS_WIDTH-1:0] op_i,
    // outputting to iq
    // 1 extra: 1 for reg fetch stage
    output logic [MAX_EXEC_CYCLE:0] future_exec_stage_slots_o,
    // stalling or clearing
    input exception_i
);

    // 2 extra: 1 for reg fetch stage, 1 for wb to follow design from slides
    logic [MAX_EXEC_CYCLE+1:0] exec_stage_slots_int;

    always_ff @(posedge clk) begin
        if (rst || exception_i) begin
            exec_stage_slots_int <= '{default:'0};
        end else begin
            for (int i = MAX_EXEC_CYCLE+1; i >= 0; i--) begin
                if (i == MAX_EXEC_CYCLE+1) begin
                    exec_stage_slots_int[i] <= 0;
                end else begin
                    exec_stage_slots_int[i] <= exec_stage_slots_int[i+1];
                end
            end
            if (wr_en_i) begin
                exec_stage_slots_int[get_exec_stage_delays_sb(op_i)] <= 1;
            end
        end
    end

    assign future_exec_stage_slots_o = exec_stage_slots_int[MAX_EXEC_CYCLE+1:1];

endmodule

