/*
    Need to make sure we send the potential correct trgt address/prediciton back to this stage

    Edge case:
        what if we speculate on the same pc address multiple times without having the oldest prediction result come back?

            // makign assumption write_en_i "1" iff entry in prev_addrs is valid

    Check: branch predictor v2 requires old tag and index value i.e. we need a lot of registers 

    assume will send base pc values down pipeline stage, and will route back

    Q: since tgrt buff and branch rpedictor behave differently when it comes to instatiating new entyries, will these
    work ok together?
    A: I tihnk yes, but make set associativity for trgt buffer to be larger if you choose to not go direct mapped

    need to set rd_en signals for bp and tb


    dont forget stalling from certain modules being full (liek in the deocde stage)

    if we detect too many branches/jumps happening at same time, stall if stage. idk what stage this construct wil be,
    im thinking decode stage

    will import correct results form wb stage, and dont send predicted result to wb stage, do comparison here

    remove temporary for initilization for bram/distrbuted ram implemenetation and do proerp initalization

    when to have instr_o.valid not be valid?
*/

module instr_fetch_stage 
import instr_fetch_pkg::*;
import writeback_pkg::mem_addr_conflict_pkt_t;
(
    input clk,
    input rst,

    // for instantiation, unsure if needed in final design
    input instr_fetch_ctrl_pkt_t instr_fetch_ctrl_pkt_i,
    
    // from ex_mem for branch misprediction recovery
    // input spec_exec_answr_pkt_t spec_exec_answr_pkt_i,

    input logic is_spec_instr_i, // from decode stage
    
    // input logic spec_exec_commit_rd_en_i, // from wb stage
    // output shift_reg_pkt_t shift_reg_pkt_o, // to wb stage

    output if_output_pkt_t if_output_pkt_o,

    input shift_reg_pkt_t spec_exec_answr_pkt_i,

    output logic exception_o,
    input logic stall_i,
    // input logic load_addr_conflict_i,
    // input logic [DATA_WIDTH-1:0] mem_buff_pc_i
    input mem_addr_conflict_pkt_t mem_addr_conflict_pkt_i
);

    // shift_reg_pkt_t spec_exec_answr_pkt_ff;
    // always_ff @(posedge clk) begin
    //     spec_exec_answr_pkt_ff <= spec_exec_answr_pkt_i;
    //     // assert(spec_exec_answr_pkt_ff.jalr_en && spec_exec_answr_pkt_ff.branch_en);
    // end

    logic [DATA_WIDTH-1:0] pc;
    assign if_output_pkt_o.pc = pc;

    logic crrct_trgt_en;
    assign crrct_trgt_en = spec_exec_answr_pkt_i.trgt_en || spec_exec_answr_pkt_i.branch_en;

    // logic grab_new_pc;

    // logic bp_rd_en;
    logic bp_hit;
    logic bp_pred;

    branch_predictor branch_predictor_inst
    (
        .clk(clk),
        .rst(rst),
        // reading
        // .rd_en_i(grab_new_pc),
        .curr_addr_i(pc),
        .hit_o(bp_hit),
        .pred_o(bp_pred),
        // updating state
        .write_en_i(spec_exec_answr_pkt_i.branch_en),
        .correct_result_i(spec_exec_answr_pkt_i.branch_pred),
        // .old_pc_i(spec_exec_answr_pkt_i.old_pc)
        .old_pc_i(shift_reg_pkt_2.pc)
    );

    // reading
    // logic rd_en_i,
    logic tb_hit;
    logic [DATA_WIDTH-1:0] tb_predict_trgt;
    trgt_buffer trgt_buffer_inst
    (
        .clk(clk),
        .rst(rst),
        // reading
        // .rd_en_i(grab_new_pc),
        .curr_addr_i(pc),
        .hit_o(tb_hit),
        .predict_trgt_o(tb_predict_trgt),
        // updating state
        .write_en_i(crrct_trgt_en),
        .correct_trgt_i(spec_exec_answr_pkt_i.trgt),
        // .old_pc_i(spec_exec_answr_pkt_i.old_pc)
        .old_pc_i(shift_reg_pkt_2.pc)
    );

    logic [DATA_WIDTH-1:0] instr_mem_addr;
    assign instr_mem_addr = instr_fetch_ctrl_pkt_i.valid ? instr_fetch_ctrl_pkt_i.instr_addr : pc;
    logic [DATA_WIDTH-1:0] instr_mem_addr_adj;
    assign instr_mem_addr_adj = instr_mem_addr - INSTR_ADDR_OFFSET;

    // synthesizes to distrbuted ram
    sram_async_read #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(INSTR_MEM_INDEX_WIDTH), // for now, hardcoding to 10 bits (1024 entries)
        .INIT_FILE(INSTR_MEM_FILE) // temporary for initilization for bram/distrbuted ram implemenetation
    ) instr_memory (
        .clk(clk),
        .we(instr_fetch_ctrl_pkt_i.valid),
        // .addr(instr_mem_addr[DATA_WIDTH-1:2]),
        .addr(instr_mem_addr_adj[DATA_WIDTH-1:2]),
        .din(instr_fetch_ctrl_pkt_i.instr_in),
        .dout(if_output_pkt_o.instr)
    );

    // logic shft_reg_brnch_mispredict;
    // logic shft_reg_trgt_mispredict;
    shift_reg_pkt_2_t shift_reg_pkt_2;
    logic trgt_shift_buff_full;
    trgt_shift_register trgt_shift_register_inst
    (
        .clk(clk),
        .rst(rst),
        // making predictions
        .predict_trgt_i(tb_predict_trgt),
        .brnch_pred_i(bp_pred),
        .old_pc_i(pc),
        // outputs
        .is_spec_instr_i(is_spec_instr_i),
        .rd_en_i(spec_exec_answr_pkt_i.trgt_en),
        // .old_pc_o(shift_reg_old_pc)
        .shift_reg_pkt_2_o(shift_reg_pkt_2),
        .full_o(trgt_shift_buff_full)
    );

    // calculated 
    logic branch_mispredict;
    logic trgt_mispredict;
    logic jump_mispredict;
    logic exception_internal;
    always_comb begin
        branch_mispredict = 0;
        trgt_mispredict = 0;
        if (spec_exec_answr_pkt_i.branch_en) begin: Jump
            branch_mispredict = shift_reg_pkt_2.branch_pred != spec_exec_answr_pkt_i.branch_pred;
        end
        if (spec_exec_answr_pkt_i.trgt_en) begin: Branch
            trgt_mispredict = shift_reg_pkt_2.trgt != spec_exec_answr_pkt_i.trgt;
        end
        jump_mispredict = trgt_mispredict && ~branch_mispredict;
    end

    assign exception_internal = jump_mispredict || branch_mispredict || mem_addr_conflict_pkt_i.en;

    // branch prediction
    // cases: branch, jalr, and jal

    // unsure if supposed to be register, but for now yes i guess
    // logic instr_valid;
    logic master_stall;
    assign master_stall = stall_i || trgt_shift_buff_full;
    // assign instr_valid  !master_stall;
    assign if_output_pkt_o.instr_valid = !master_stall;

    always_ff @(posedge clk) begin
        if (rst) begin
            // pc <= '{default:'0};
            pc <= INSTR_ADDR_OFFSET;
            // instr_valid <= 1'b0;
            exception_o <= '0;
        end else begin
            exception_o <= exception_internal;
            // instr_valid <= 1'b1;
            // if (stall) begin // NEED TO DRIVE THIS
                // pc <= pc;
                // set instr to not be valid?
                // instr_valid <= 1'b0;
            // end else if (trgt_mispredict && ~branch_mispredict) begin: JumpMispredict
            if (jump_mispredict) begin: JumpMispredict
                pc <= spec_exec_answr_pkt_i.trgt;
            end else if (branch_mispredict) begin: BranchMispredict
                pc <= (spec_exec_answr_pkt_i.branch_pred) ? 
                    spec_exec_answr_pkt_i.trgt : 
                    shift_reg_pkt_2.pc + 4;
            end else if (mem_addr_conflict_pkt_i.en) begin: MemoryAddrConflict
                pc <= mem_addr_conflict_pkt_i.pc;
            end else if (stall_i) begin: Stall
                pc <= pc;
                // instr_valid <= 1'b0;
            end else if (tb_hit && bp_hit && bp_pred) begin: SpecBranch
                pc <= tb_predict_trgt;
            end else if (tb_hit && !bp_hit) begin: SpecJump
                pc <= tb_predict_trgt;
            end else begin: NoSpec
                pc <= pc + 4; // assuming 4 byte instructions, will need to change for compressed instrs
            end
        end
    end

endmodule

module trgt_shift_register
import instr_fetch_pkg::*;
import general_pkg::DATA_WIDTH;

(
    input logic clk,
    input logic rst,
    // making predictions
    input logic [DATA_WIDTH-1:0] predict_trgt_i,
    input logic brnch_pred_i,
    input logic [DATA_WIDTH-1:0] old_pc_i,
    // input spec_exec_answr_pkt_t spec_exec_answr_pkt_i,
    // outputs
    // output logic brnch_mispredict_o,
    // output logic trgt_mispredict_o,
    input logic is_spec_instr_i, // comes 1 cycle later from decode stage
    input logic rd_en_i,
    output shift_reg_pkt_2_t shift_reg_pkt_2_o,
    output logic full_o
);
    shift_reg_pkt_2_t predicted_trgt_and_pred_pkt, predicted_trgt_and_pred_pkt_ff;
    always_comb begin
        predicted_trgt_and_pred_pkt.trgt = predict_trgt_i;
        predicted_trgt_and_pred_pkt.branch_pred = brnch_pred_i;
        predicted_trgt_and_pred_pkt.pc = old_pc_i;
    end

    // WHY DID I MAKE THIS INTO A FLIPFLOP?

    always_ff @(posedge clk) begin
        if (rst) begin
            predicted_trgt_and_pred_pkt_ff <= '{default:'0};
        end else begin
            predicted_trgt_and_pred_pkt_ff <= predicted_trgt_and_pred_pkt;
        end
    end

    fifo_modded #(
        .DEPTH(MAX_SPEC_EXEC_INSTRS),
        .DATA_WIDTH($bits(shift_reg_pkt_2_t)),
        .T(shift_reg_pkt_2_t)
    ) shift_reg_fifo (
        .clk(clk),
        .rst(rst),
        .data_i(predicted_trgt_and_pred_pkt_ff),
        .rd_en_i(rd_en_i),
        .wr_en_i(is_spec_instr_i),
        .data_o(shift_reg_pkt_2_o),
        .full_o(full_o)
    );

    // shift_reg_pkt_t shift_reg [OUTCOME_DELAY-1:0];
    // always @(posedge clk) begin
    //     if (rst) begin
    //         shift_reg <= '{default:'0};
    //     end else begin
    //         shift_reg[0].trgt <= predict_trgt_i;
    //         shift_reg[0].branch_pred <= brnch_pred_i;
    //         for (int i = 1; i < OUTCOME_DELAY; i++) begin
    //             shift_reg[i] <= shift_reg[i-1];
    //         end
    //     end
    // end

    // always_comb begin
    //     if (spec_exec_answr_pkt_i.branch_en) begin
    //         brnch_mispredict_o = shift_reg[OUTCOME_DELAY-1].branch_pred != spec_exec_answr_pkt_i.branch_taken;
    //     end else begin
    //         brnch_mispredict_o = 1'b0;
    //     end
    //     if (spec_exec_answr_pkt_i.trgt_en) begin
    //         trgt_mispredict_o = spec_exec_answr_pkt_i.calc_pc != shift_reg[OUTCOME_DELAY-1].trgt;
    //     end else begin
    //         trgt_mispredict_o = 1'b0;
    //     end
    // end

    // assign shift_reg_pkt_o = shift_reg[OUTCOME_DELAY-1];

    /* 
        take in predicted trgt, or a miss (set to null), and then after N cycles, check input from ex stage and if miss, 
        replace pc value with calculated trgt, and also update trgt predictor

        for brnch_predictor:
        take in prediciton, after N cycles, and after N cycles, check input from ex stage and if miss, 
        replace pc value with calculated trgt, and also update trgt predictor
    */

endmodule

module branch_predictor
import brnch_predict_pkg::*;
import general_pkg::DATA_WIDTH;
(
    input clk,
    input rst,
    // reading
    // input logic rd_en_i,
    input logic [DATA_WIDTH-1:0] curr_addr_i,
    output logic hit_o,
    output logic pred_o,
    // updating state
    input logic write_en_i,
    input logic correct_result_i,
    input logic [DATA_WIDTH-1:0] old_pc_i
);
    // 32-bit address: [TAG][INDEX][BLOCK_OFFSET]
    logic [TAG_WIDTH-1:0] curr_tag;
    logic [INDEX_WIDTH-1:0] curr_index;
    assign curr_tag = curr_addr_i[DATA_WIDTH-1:DATA_WIDTH-TAG_WIDTH];
    assign curr_index = curr_addr_i[DATA_WIDTH-TAG_WIDTH-1:BLOCK_OFFSET];
    
    generate
        if (SET_ASSOCIATIVITY == 1) begin : DirectMapped
            // internal memory
            bp_cache_line_t bp_cache [CACHE_LINES-1:0];

            logic miss_condition;
            // assign miss_condition = !(bp_cache[curr_index].valid && bp_cache[curr_index].tag == curr_tag && rd_en_i);
            assign miss_condition = !(bp_cache[curr_index].valid && (bp_cache[curr_index].tag == curr_tag));

            always_comb begin : MakingAPredictionRead
                if (miss_condition) begin
                    // output
                    hit_o = 1'b0;
                    pred_o = 1'b0; // default to pc + 4
                end else begin
                    hit_o = 1'b1;
                    pred_o = branch_prediction(bp_cache[curr_index].brnch_hist);
                end
            end

            // makign assumption write_en_i "1" iff entry in prev_predict_pkts is valid
            always_ff @(posedge clk) begin : CheckingAPrediction
                if (rst) begin
                    bp_cache <= '{default:'0};
                end else if (write_en_i) begin
                    automatic logic [TAG_WIDTH-1:0] old_tag = old_pc_i[DATA_WIDTH-1:DATA_WIDTH-TAG_WIDTH];
                    automatic logic [INDEX_WIDTH-1:0] old_index = old_pc_i[DATA_WIDTH-TAG_WIDTH-1:BLOCK_OFFSET];
                    if (bp_cache[old_index].tag == old_tag && bp_cache[old_index].valid) begin: Hit
                        bp_cache[old_index].brnch_hist <= update_state(bp_cache[old_index].brnch_hist, correct_result_i);
                    end else begin: NoHit
                        // instantiation
                        bp_cache[old_index].valid <= 1'b1;
                        bp_cache[old_index].tag <= old_tag;
                        bp_cache[old_index].brnch_hist <= 2'b00;
                    end
                end
            end

        end else begin : SetAssociative
            bp_cache_line_t bp_cache [CACHE_LINES-1:0][SET_ASSOCIATIVITY-1:0];
            logic [$clog2(SET_ASSOCIATIVITY)-1:0] set_ptr [CACHE_LINES-1:0]; // points to next spot to be replaced for each cache line

            logic curr_miss_condition;
            logic [SET_ASSOCIATIVITY-1:0] curr_hit_array_w;
            always_comb begin
                for (int i = 0; i < SET_ASSOCIATIVITY; i++) begin : Hit
                    curr_hit_array_w[i] = (bp_cache[curr_index][i] == curr_tag) && bp_cache[curr_index][i].valid;
                end
                // curr_miss_condition = !(|curr_hit_array_w) || !rd_en_i;
                curr_miss_condition = !(|curr_hit_array_w);
            end
            
            always_comb begin : MakingAPredictionRead
                if (curr_miss_condition) begin
                    // output
                    hit_o = 1'b0;
                    pred_o = 1'b0; // default to pc + 4
                end else begin
                    hit_o = 1'b1;
                    pred_o = branch_prediction(bp_cache[curr_index][set_ptr[curr_index]].brnch_hist);
                end
            end

            // making assumption write_en_i "1" iff entry in prev_predict_pkts is valid
            always_ff @(posedge clk) begin : CheckingAPrediction
                if (rst) begin
                    bp_cache <= '{default:'0};
                    set_ptr <= '{default:'0};
                end else if (write_en_i) begin
                    automatic logic [TAG_WIDTH-1:0] old_tag = old_pc_i[DATA_WIDTH-1:DATA_WIDTH-TAG_WIDTH];
                    automatic logic [INDEX_WIDTH-1:0] old_index = old_pc_i[DATA_WIDTH-TAG_WIDTH-1:BLOCK_OFFSET];
                    logic [SET_ASSOCIATIVITY-1:0] old_hit_array_w;
                    for (int i = 0; i < SET_ASSOCIATIVITY; i++) begin : Hit
                        old_hit_array_w[i] = bp_cache[old_index][i].tag == old_tag && bp_cache[old_index][i].valid;
                        if (old_hit_array_w[i]) begin
                            bp_cache[old_index][i].brnch_hist <= update_state(bp_cache[old_index][i].brnch_hist, correct_result_i);
                        end
                    end
                    if (!(|old_hit_array_w)) begin: NoHit
                        bp_cache[old_index][set_ptr[old_index]].valid <= 1'b1;
                        bp_cache[old_index][set_ptr[old_index]].tag <= old_tag;
                        bp_cache[old_index][set_ptr[old_index]].brnch_hist <= 2'b00;
                        set_ptr[old_index] <= set_ptr[old_index] + 1;
                    end
                end
            end
        end
    endgenerate
endmodule

// works for both branch (alt trgt's, not pc+4) and jumping
module trgt_buffer
import trgt_buffer_pkg::*;
import general_pkg::DATA_WIDTH;
(
    input clk,
    input rst,
    // reading
    // input logic rd_en_i,
    input logic [DATA_WIDTH-1:0] curr_addr_i,
    output logic hit_o,
    output logic [DATA_WIDTH-1:0] predict_trgt_o,
    // updating state
    input logic write_en_i,
    input logic [DATA_WIDTH-1:0] correct_trgt_i,
    input logic [DATA_WIDTH-1:0] old_pc_i
);
    // 32-bit address: [TAG][INDEX][BLOCK_OFFSET]

    logic [TAG_WIDTH-1:0] curr_tag;
    logic [INDEX_WIDTH-1:0] curr_index;
    assign curr_tag = curr_addr_i[DATA_WIDTH-1:DATA_WIDTH-TAG_WIDTH];
    assign curr_index = curr_addr_i[DATA_WIDTH-TAG_WIDTH-1:BLOCK_OFFSET];
    
    generate
        if (SET_ASSOCIATIVITY == 1) begin : DirectMapped
            // internal memory
            trgt_buff_cache_line_t tb_cache [CACHE_LINES-1:0];

            // valid
            // logic miss_condition = !(tb_cache[curr_index].valid && tb_cache[curr_index].tag == curr_tag && rd_en_i);
            logic miss_condition;
            assign miss_condition = !(tb_cache[curr_index].valid && tb_cache[curr_index].tag == curr_tag);
            
            always_comb begin : MakingAPredictionRead
                if (miss_condition) begin
                    // output
                    hit_o = 1'b0;
                    predict_trgt_o = '{default:'0}; // default to pc + 4
                end else begin
                    hit_o = 1'b1;
                    predict_trgt_o = tb_cache[curr_index].trgt;
                end
            end

            // making assumption write_en_i "1" iff entry in prev_predict_pkts is valid
            always_ff @(posedge clk) begin : CheckingAPrediction
                if (rst) begin
                    tb_cache <= '{default:'0};
                end else if (write_en_i) begin
                    automatic logic [TAG_WIDTH-1:0] old_tag = old_pc_i[DATA_WIDTH-1:DATA_WIDTH-TAG_WIDTH];
                    automatic logic [INDEX_WIDTH-1:0] old_index = old_pc_i[DATA_WIDTH-TAG_WIDTH-1:BLOCK_OFFSET];
                    // if (tb_cache[old_index].tag == old_tag && tb_cache[old_index].valid) begin:
                        tb_cache[old_index].valid <= 1'b1;
                        tb_cache[old_index].tag <= old_tag;
                        tb_cache[old_index].trgt <= correct_trgt_i;
                    // end
                end
            end

        end else begin : SetAssociative
            trgt_buff_cache_line_t tb_cache [CACHE_LINES-1:0][SET_ASSOCIATIVITY-1:0];
            logic [$clog2(SET_ASSOCIATIVITY)-1:0] set_ptr [CACHE_LINES-1:0]; // points to next spot to be replaced for each cache line

            logic curr_miss_condition;
            logic [SET_ASSOCIATIVITY-1:0] curr_hit_array_w;
            logic [$clog2(SET_ASSOCIATIVITY)-1:0] curr_hit_ptr;
            always_comb begin
                curr_hit_ptr = '{default:'0};
                for (int i = 0; i < SET_ASSOCIATIVITY; i++) begin : Hit
                    curr_hit_array_w[i] = tb_cache[curr_index][i] == curr_tag && tb_cache[curr_index][i].valid;
                    if (curr_hit_array_w[i]) begin
                        curr_hit_ptr = i;
                    end
                end
                // curr_miss_condition = !(|curr_hit_array_w) || !rd_en_i;
                curr_miss_condition = !(|curr_hit_array_w);
            end
            
            always_comb begin : MakingAPredictionRead
                if (curr_miss_condition) begin
                    // output
                    hit_o = 1'b0;
                    predict_trgt_o = '{default:'0}; // default to pc + 4
                end else begin
                    hit_o = 1'b1;
                    predict_trgt_o = tb_cache[curr_index][curr_hit_ptr].trgt;
                end
            end

            // making assumption write_en_i "1" iff entry in prev_predict_pkts is valid
            always_ff @(posedge clk) begin : CheckingAPrediction
                if (rst) begin
                    tb_cache <= '{default:'0};
                    set_ptr <= '{default:'0};
                end else if (write_en_i) begin
                    automatic logic [TAG_WIDTH-1:0] old_tag = old_pc_i[DATA_WIDTH-1:DATA_WIDTH-TAG_WIDTH];
                    automatic logic [INDEX_WIDTH-1:0] old_index = old_pc_i[DATA_WIDTH-TAG_WIDTH-1:BLOCK_OFFSET];
                    logic [SET_ASSOCIATIVITY-1:0] old_hit_array_w;
                    for (int i = 0; i < SET_ASSOCIATIVITY; i++) begin : Hit
                        old_hit_array_w[i] = tb_cache[old_index][i] == old_tag && tb_cache[old_index][i].valid;
                        if (old_hit_array_w[i]) begin
                            tb_cache[old_index][set_ptr[old_index]].valid <= 1'b1;
                            tb_cache[old_index][set_ptr[old_index]].tag <= old_tag;
                            tb_cache[old_index][set_ptr[old_index]].trgt <= correct_trgt_i;
                            set_ptr[old_index] <= set_ptr[old_index] + 1;
                        end
                    end
                end
            end
        end
    endgenerate

endmodule
