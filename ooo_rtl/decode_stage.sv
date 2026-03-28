module decode_stage 
    import decode_pkg::*;
#(
    parameter DATA_WIDTH = 32,
) (
    input clk,
    input rst,
    input flush_i,
    input [31:0] instr_i,
    output error_o,
    // cntrls

    /*
        external comms
            master
                arf read
                rob r/w
            slave
                writeback stage for w for issuequeue
                commit_stage w for RT
    */

    // free list
    input free_list_wr_en_i,
    input [PRF_COUNT-1:0] free_list_commited_ptr_i, // from scoreboard
    output logic free_list_empty_o;

    // rename table
    // to signal its in PRF, can have the scoreboard tell the RT
    // actually i think it should coe frommright before 
    input logic [$clog2(PRF_COUNT)-1:0] rename_table_prf_ptr_i,
    input logic [4:0] rename_table_arf_ptr_sb_i,
    input logic rename_table_wb_en_i,

    // issue queue
    // signals for updating state
    input logic [$clog2(PRF_COUNT)-1:0] issue_queue_prf_dst_i,
    input logic issue_queue_prf_wr_en_i,
    
    // output logic
    
);
    // addr for branch targets

    // internal comms
    // rename table r/w
    // issue queue w

    /* free list */
    logic free_list_rd_en;
    logic [PRF_COUNT-1:0] free_list_free_ptr;
    // logic free_list_empty;

    free_list free_list_inst #(
        parameter PRF_COUNT
    ) (
        .clk(clk),
        .rst(rst),
        // writing
        .wr_en_i(free_list_wr_en_i),
        .commited_ptr_i(free_list_commited_ptr_i),
        // reading
        .rd_en_i(free_list_rd_en),
        .free_ptr_o(free_list_free_ptr),
        // state
        .empty_o(free_list_empty_o)
    );

    /* rename table */
    // intial write
    logic [$clog2(PRF_COUNT)-1:0] rename_table_prf_dest_ptr;
    logic [4:0] rename_table_arf_ptr;
    logic rename_table_decode_en;
    // reading
    logic [4:0] rename_table_arf_src0;
    logic [4:0] rename_table_arf_src1;
    logic [$clog2(PRF_COUNT)-1:0] rename_table_prf_src0;
    logic [$clog2(PRF_COUNT)-1:0] rename_table_prf_src1;
    logic rename_table_src0_pending;
    logic rename_table_src1_pending;

    rename_table_async_read rename_table_async_read_inst #(
        parameter PRF_COUNT = 32
    ) (
        .clk(clk),
        .rst(rst),
        // initial write
        .prf_ptr_i(rename_table_prf_dest_ptr),
        .arf_ptr_i(rename_table_arf_ptr),
        .decode_en_i(rename_table_decode_en),
        // to signal its in PRF, can have the scoreboard tell the RT
        .prf_ptr_sb_i(rename_table_prf_ptr_i),
        .arf_ptr_sb_i(rename_table_arf_ptr_sb_i),
        .writeback_en_i(rename_table_wb_en_i),
        // ports for issue queue to read from 
        .arf_src0_i(rename_table_arf_src0),
        .arf_src1_i(rename_table_arf_src1),
        .prf_src0_o(rename_table_prf_src0),
        .prf_src1_o(rename_table_prf_src1),
        .src0_pending_o(rename_table_src0_pending),
        .src1_pending_o(rename_table_src1_pending)
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
        .prf_dst_i(issue_queue_prf_dst_i),
        .prf_wr_en_i(issue_queue_prf_wr_en_i),
        // for checking for structural hazards
        .future_exec_stage_slots_i(issue_queue_future_exec_stage_slots),      
        .instr_o(issue_queue_instr_out),
        // also other output information 
        .empty_o(issue_queue_empty),
        .full_o(issue_queue_full),
        .all_stalled_o(issue_queue_all_stalled) // when all current entries are still stalling, does also account for input "prf_dst_i"
    );

    logic mini_scoreboard_wr_en;
    logic [INSTR_COMPRESS_WIDTH-1:0] mini_scoreboard_op;
    logic mini_scoreboard_clear;

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
        .clear_i(mini_scoreboard_clear), // same functionality as rst
    );

    // idk what this in reference to
    // keep track of next avail rob ptr val (increment by 1 using an adder each time we get an instruciton that writes to a register)


    logic dispatch_instr;
    logic new_instr_ready; // all operands are avail

    // setting issue queue entry values
    always_comb begin
        issue_queue_entry = issue_queue_pkg::instr_to_iq_entry_partial(instr_i);
        // filling in remanining values
        issue_queue_entry.valid = new_instr_ready && 
            (issue_queue_empty || issue_queue_all_stalled);
        issue_queue_entry.dest_ptr = free_list_free_ptr;
        issue_queue_entry.src0_pending = rename_table_src0_pending;
        issue_queue_entry.src0_ptr = rename_table_prf_src0;
        issue_queue_entry.src1_pending = rename_table_src1_pending;
        issue_queue_entry.src1_ptr = rename_table_prf_src1;
    end

    // setting cntrl instructions
    always_comb begin
        
        free_list_rd_en = 1;
        if ((free_list_empty && issue_queue_entry.dest_valid) || issue_queue_full)
            free_list_rd_en = 0;

        // determined by operands being ready
        // free list not being empty, assuming it needs it
        new_instr_ready = 
            !(has_dest(instr_i[6:0]) && free_list_empty_o) ||
            !(has_src0(instr_i[6:0]) && rename_table_src0_pending) ||
            !(has_src1(instr_i[6:0]) && rename_table_src1_pending);
        
        dispatch_instr = 
            new_instr_ready || 
            (!issue_queue_empty && !issue_queue_all_stalled);

        // might need to modify to acocount for stalling/flushing
        mini_scoreboard_wr_en = dispatch_instr;
        
        // if (!dispatch_instr) begin
        //     free_list_rd_en = 0;

        // end

    end

    // checking for errors
    always_comb begin
        if ()
    end

    /* decoding a new instruction as an input to issue queue */
    always_comb begin
        issue_queue_entry = '0;
        if (!stall) begin
            issue_queue_entry.valid = 1;
            issue_queue_entry.op = grab_compr_instr(instr);
            imm_valid = has_imm(instr[6:0]);
            imm = imm_gen(instr);
            speculative = is_speculative(instr[6:0]);
            dest_valid = has_dest(instr[6:0]);
            dest_ptr = free_list[]

        end
    end
    // op = 
    // access issue queue





    // routing an instruction


    /* 
        interms of output of decoder (actually decoding things) we need to 
        take a iq_output_t as a input

    */


    

endmodule


// automatically outputs the next available free prf pointer
module free_list #(
    parameter PRF_COUNT
) (
    input clk,
    input rst,
    // writing
    input logic wr_en_i,
    input logic [PRF_COUNT-1:0] commited_ptr_i,
    // reading
    input logic rd_en_i,
    output logic [PRF_COUNT-1:0] free_ptr_o,
    // state
    output logic empty_o
);
    logic [0:PRF_COUNT-1] free_list; // 1'b1 means free
    // state
    assign empty_o = ~|free_list;
    // writing
    always_ff @(posedge clk) begin
        if (rst) begin
            free_list <= '1;
        end else begin
            if (wr_en_i)
                free_list[commited_ptr_i] <= 1;
        end
    end
    // reading
    logic found;
    always_comb begin
        free_ptr_o = PRF_COUNT-1;
        found = 0;
        for (int i = 0; i < PRF_COUNT; i++) begin
            if (free_list[i] == 1 && !found) begin
                free_ptr_o = i;
                found = 1;
            end
        end
    end
    always_ff @(posedge clk) begin
        if (!empty_o && rd_en_i) begin
            free_list[free_ptr_o] <= 0;
        end
    end
endmodule

// used for knowing where to commit: idk bout that
/* NOTE: 
    could potentially optimize the updating of the pending signal sent by scoreboard
    by bringing the scoreboard into the decode stage
*/
module rename_table_async_read #(
    parameter PRF_COUNT = 32
) (
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
    output logic src1_pending_o
);0
    typedef struct packed {
        logic [$clog2(PRF_COUNT)-1:0] prf_ptr;
        // logic [DATA_WIDTH-1:0] imm;
        // logic spec;
        logic pending;
        // logic valid;
    } rt_entry_t;

    // will synthesize to flip flops
    rt_entry_t rename_table [0:31];

    // write logic
    always_ff @(posedge clk) begin
        if (rst) begin
            rename_table = '0;
        end 
        else begin
            if (decode_en_i) begin
                rename_table[arf_ptr_i].prf_ptr <= prf_ptr_i;
                rename_table[arf_ptr_i].pending <= 1'b1;
            end
            if (writeback_en_i) begin
                if (rename_table[arf_ptr_sb_i].prf_ptr == prf_ptr_sb_i)
                    rename_table[i].pending <= 1'b0;
            end
        end
    end
    
    // read logic (asynchronous)
    assign prf_src0_o = rename_table[arf_src0_i].rob_ptr;
    assign src0_pending_o = rename_table[arf_src0_i].pending;
    assign prf_src1_o = rename_table[arf_src1_i].rob_ptr;
    assign src1_pending_o = rename_table[arf_src1_i].pending;

endmodule

// should be the module that determines which is the next instruction to be issued
module issue_queue 
    import issue_queue_pkg::*;
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
    output iq_output_t instr_o;
    // also other output information 
    output logic empty_o,
    output logic full_o,
    output logic all_stalled_o, // when all current entries are still stalling, does also account for input "prf_dst_i"
);  

    iq_entry_t iq [0:IQ_SIZE-1];

    // write logic
    logic wr_en;
    assign wr_en = iq_entry_i.valid;
    always_ff @(posedge clk) begin
        if (rst) begin
            iq <= '0;
            // need to set other values
            empty_o <= 1;
            full_o <= 0;
            all_stalled_o <= 0;
        end 
        else begin
            if (wr_en && !full_o) begin
                // find first empty slot and write instruction
                for (int i = 0; i < IQ_SIZE; i++) begin
                    if (!iq[i].valid) begin
                        iq[i].valid <= 1;
                        iq[i][$bits(iq_entry_t)-2:0] <= iq_entry_i[$bits(iq_entry_t)-2:0];
                        // iq[i].valid <= 1;    
                        // iq[i].op <= grab_compr_instr(instr);
                        // iq[i].imm <= imm_gen(instr); // dont use
                        // iq[i].speculative <= is_speculative(instr[6:0]);
                        // iq[i].dest_valid <= is_dest(instr[6:0]);
                        // iq[i].dest_ptr <= dest_ptr;
                        // iq[i].src0_valid <= has_src0(instr[6:0]);
                        // // iq[i].pe
                        break;
                    end
                end
            end
        end
    end

    // updating pending state
    always_ff @(posedge clk) begin
        for (int i = 0; i < IQ_SIZE; i++) begin
            if (iq[i].src0_valid && iq[i].src0_pending && iq[i].src0_ptr == prf_dst_i)
                iq[i].src0_pending = 0;
            if (iq[i].src1_valid && iq[i].src1_pending && iq[i].src1_ptr == prf_dst_i)
                iq[i].src1_pending = 0;
        end
    end

    // read logic
    // also can account for forwarding from before even reaching commit stage, but would have to check conditions before
    logic [IQ_SIZE-1:0] valid_array;
    always_comb begin
        for (int i = 0; i < IQ_SIZE; i++)
            valid_array[i] = iq[i].valid;
    end
    assign empty_o = ~(|valid_array);
    assign full_o = &valid_array;

    logic [IQ_SIZE-1:0] ready_array;
    // expensive, see if can optimize
    always_comb begin
        for (int i = 0; i < IQ_SIZE; i++) begin
            ready_array[i] = (
                (!iq[i].src0_valid || !iq[i].src0_pending || iq[i].src0_ptr == prf_dst_i) &&
                (!iq[i].src1_valid || !iq[i].src1_pending || iq[i].src1_ptr == prf_dst_i) &&
                (future_exec_stage_slots_i[iq[i].exec_dur] == 0)
            );
        end
        all_stalled_o = ~(|ready_array);
    end

    // asynch read
    logic [IQ_SIZE-1:0] priority_ready_array;
    always_comb begin
        priority_ready_array = '0;
        instr_o = '0; 
        if (!empty && !all_stalled_o) begin
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
    // synchronously updating validity
    always_ff @(posedge clk) begin
        if (!empty && !all_stalled_o) begin
            for (int i = 0; i < IQ_SIZE; i++) begin
                if (priority_ready_array[i]) begin
                    iq[i].valid = 0;
                end
            end
        end
    end
endmodule


module mini_scoreboard
import issue_queue_pkg::*;
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
    input clear_i, // same functionality as rst
);

    // 2 extra: 1 for reg fetch stage, 1 for wb to follow design from slides
    logic [MAX_EXEC_CYCLE+1:0] exec_stage_slots_int;

    always_ff @(posedge clk) begin
        if (rst || clear_i) begin
            exec_stage_slots_int <= '0;
        end else begin
            for (int i = MAX_EXEC_CYCLE+1; i >= 0; i--) begin
                if (i == MAX_EXEC_CYCLE+1) begin
                    exec_stage_slots_int[i] <= 0;
                end else begin
                    exec_stage_slots_int[i] <= exec_stage_slots_int[i+1];
                end
            end
            if (wr_en_i) begin
                exec_stage_slots_int[get_exec_stage_delays(op_i)] <= 1;
            end
        end
    end

    assign exec_stage_slots_o = exec_stage_slots_int[MAX_EXEC_CYCLE+1:1];

endmodule

