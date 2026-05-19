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
*/


module instr_fetch_stage 
(
    input clk,
    input rst,

    // for instantiation, unsure if needed in final design
    input instr_fetch_ctrl_pkt_t instr_fetch_ctrl_pkt_i,
    
    // from ex_mem for branch misprediction recovery
    input spec_exec_answr_pkt_t spec_exec_answr_pkt_i,

    input logic is_spec_instr_i, // from decode stage
    
    // input logic spec_exec_commit_rd_en_i, // from wb stage
    // output shift_reg_pkt_t shift_reg_pkt_o, // to wb stage

    output if_output_pkt_t if_output_pkt_o,
);

    spec_exec_answr_pkt_t spec_exec_answr_pkt_ff;
    always_ff @(posedge clk) begin
        spec_exec_answr_pkt_ff <= spec_exec_answr_pkt_i;
    end

    assert(spec_exec_answr_pkt_ff.jalr_en && spec_exec_answr_pkt_ff.branch_en);

    logic crrct_trgt_en;
    assign crrct_trgt_en = spec_exec_answr_pkt_ff.jalr_en || spec_exec_answr_pkt_ff.branch_en;


    // logic grab_new_pc;

    // logic bp_rd_en;
    logic bp_hit;
    // logic bp_pred_o;

    branch_predictor branch_predictor_inst
    (
        .clk(clk),
        .rst(rst),
        // reading
        // .rd_en_i(grab_new_pc),
        .curr_addr_i(if_output_pkt_o.pc),
        .hit_o(bp_hit),
        .pred_o(if_output_pkt_o.bp_pred),
        // updating state
        .write_en_i(spec_exec_answr_pkt_ff.branch_en),
        .correct_result_i(spec_exec_answr_pkt_ff.branch_taken),
        .old_pc_i(spec_exec_answr_pkt_ff.old_pc)
    );

    // reading
    // logic rd_en_i,
    logic tb_hit;
    logic [INSTR_WIDTH-1:0] tb_predict_trgt;
    trgt_buffer trgt_buffer_inst
    (
        .clk(clk),
        .rst(rst),
        // reading
        // .rd_en_i(grab_new_pc),
        .curr_addr_i(if_output_pkt_o.pc),
        .hit_o(tb_hit),
        .predict_trgt_o(tb_predict_trgt),
        // updating state
        .write_en_i(crrct_trgt_en),
        .correct_trgt_i(spec_exec_answr_pkt_ff.calc_pc),
        .old_pc_i(spec_exec_answr_pkt_ff.old_pc)
    );

    assign instr_mem_addr = instr_fetch_ctrl_pkt_i.valid ? instr_fetch_ctrl_pkt_i.instr_addr : if_output_pkt_o.pc;

    sram_sync_read #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(10) // for now, hardcoding to 10 bits (1024 entries)
    ) instr_memory (
        .clk(clk),
        .we(instr_fetch_ctrl_pkt_i.valid),
        .addr(instr_mem_addr),
        .din(instr_fetch_ctrl_pkt_i.instr_in),
        .dout(if_output_pkt_o.instr)
    );

    // logic shft_reg_brnch_mispredict;
    // logic shft_reg_trgt_mispredict;
    trgt_shift_register trgt_shift_register_inst
    (
        .clk(clk),
        .rst(rst),
        // making predictions
        .predict_trgt_i(tb_predict_trgt),
        .brnch_pred_i(if_output_pkt_o.bp_pred),
        // outputs
        .is_spec_instr_i(is_spec_instr_i),
        .rd_en_i(spec_exec_commit_rd_en_i),
        // .old_pc_o(shift_reg_old_pc)
        .shift_reg_pkt_o(shift_reg_pkt_o)
    );
       



    // branch prediction
    // cases: branch, jalr, and jal

    always_ff @(posedge clk) begin
        if (rst) begin
            if_output_pkt_o.pc <= '0;
            // grab_new_pc <= 0;
        end else begin
            // grab_new_pc <= 1;
            if (stall) begin // NEED TO DRIVE THIS
                if_output_pkt_o.pc <= if_output_pkt_o.pc;
                // grab_new_pc <= 0;
            end else if (shft_reg_brnch_mispredict || shft_reg_trgt_mispredict) begin: Mispredict
                if_output_pkt_o.pc <= spec_exec_answr_pkt_ff.calc_pc;
            end else if (tb_hit && bp_hit && if_output_pkt_o.bp_pred) begin: SpecBranch
                if_output_pkt_o.pc <= tb_predict_trgt;
            end else if (tb_hit && !bp_hit) begin: SpecJump
                if_output_pkt_o.pc <= tb_predict_trgt;
            end else begin: NoSpec
                if_output_pkt_o.pc <= if_output_pkt_o.pc + 4; // assuming 4 byte instructions, will need to change for compressed instrs
            end
        end
    end

endmodule

module trgt_shift_register
import instr_fetch_pkg::*;
(
    input logic clk,
    input logic rst,
    // making predictions
    input logic [DATA_WIDTH-1:0] predict_trgt_i,
    input logic brnch_pred_i,
    // input spec_exec_answr_pkt_t spec_exec_answr_pkt_i,
    // outputs
    // output logic brnch_mispredict_o,
    // output logic trgt_mispredict_o,
    input logic is_spec_instr_i, // comes 1 cycle later from decode stage
    input logic rd_en_i,
    output shift_reg_pkt_t shift_reg_pkt_o
);
    shift_reg_pkt_t predicted_trgt_and_pred_pkt, predicted_trgt_and_pred_pkt_ff;
    always_comb begin
        predicted_trgt_and_pred_pkt.trgt = predict_trgt_i;
        predicted_trgt_and_pred_pkt.branch_pred = brnch_pred_i;
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            predicted_trgt_and_pred_pkt_ff <= '0;
        end else begin
            predicted_trgt_and_pred_pkt_ff <= predicted_trgt_and_pred_pkt;
        end
    end

    fifo_modded #(
        .DEPTH(MAX_SPEC_EXEC_INSTRS),
        .DATA_WIDTH($bits(shift_reg_pkt_t)),
        .T(shift_reg_pkt_t)
    ) shift_reg_fifo (
        .clk(clk),
        .rst(rst),
        .rd_en_i(rd_en_i),
        .wr_en_i(is_spec_instr_i),
        .data_i(predicted_trgt_and_pred_pkt_ff),
        .data_o(shift_reg_pkt_o)
    );

    // shift_reg_pkt_t shift_reg [OUTCOME_DELAY-1:0];
    // always @(posedge clk) begin
    //     if (rst) begin
    //         shift_reg <= '0;
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
(
    input clk,
    input rst,
    // reading
    // input logic rd_en_i,
    input logic [DATA_WIDTH-1:0] curr_addr_i,
    output logic hit_o,
    output logic pred_o
    // updating state
    input logic write_en_i,
    input logic correct_result_i
    input logic [INSTR_WIDTH-1:0] old_pc_i,
);
    // 32-bit instr: [TAG][INDEX][BLOCK_OFFSET]

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
            assign miss_condition = !(bp_cache[curr_index].valid && bp_cache[curr_index].tag == curr_tag);

            always_ff @(posedge clk) begin : MakingAPredictionWrite
                if (rst) begin
                    bp_cache <= '0;
                end 
                else if (miss_condition) begin: No_hit
                //     // instantiation
                //     bp_cache[curr_index].valid <= 1'b1;
                //     bp_cache[curr_index].tag <= curr_tag;
                //     bp_cache[curr_index].brnch_hist <= 2'b00;
                // end 
            end
            
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
                if (write_en_i && !rst) begin
                    logic [TAG_WIDTH-1:0] old_tag = old_pc_i[DATA_WIDTH-1:DATA_WIDTH-TAG_WIDTH];
                    logic [INDEX_WIDTH-1:0] old_index = old_pc_i[DATA_WIDTH-TAG_WIDTH-1:BLOCK_OFFSET];
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
                    curr_hit_array_w[i] = bp_cache[curr_index][i] == curr_tag && bp_cache[curr_index][i].valid;
                end
                // curr_miss_condition = !(|curr_hit_array_w) || !rd_en_i;
                curr_miss_condition = !(|curr_hit_array_w);
            end

            always_ff @(posedge clk) begin : MakingAPredictionWrite
                if (rst) begin
                    bp_cache <= '0;
                    set_ptr <= '0;
                end 
                // else if (curr_miss_condition) begin: No_hit
                //     // instantiation
                //     bp_cache[curr_index][set_ptr[curr_index]].valid <= 1'b1;
                //     bp_cache[curr_index][set_ptr[curr_index]].tag <= curr_tag;
                //     bp_cache[curr_index][set_ptr[curr_index]].brnch_hist <= 2'b00;
                //     set_ptr[curr_index] <= set_ptr[curr_index] + 1;
                // end 
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
                if (write_en_i && !rst) begin
                    logic [TAG_WIDTH-1:0] old_tag = old_pc_i[DATA_WIDTH-1:DATA_WIDTH-TAG_WIDTH];
                    logic [INDEX_WIDTH-1:0] old_index = old_pc_i[DATA_WIDTH-TAG_WIDTH-1:BLOCK_OFFSET];
                    logic [SET_ASSOCIATIVITY-1:0] old_hit_array_w;
                    for (int i = 0; i < SET_ASSOCIATIVITY; i++) begin : Hit
                        old_hit_array_w[i] = bp_cache[old_index][i].tag == old_tag && bp_cache[old_index][i].valid;
                        if (old_hit_array_w[i]) begin
                            bp_cache[old_index][i].brnch_hist <= update_state(bp_cache[old_index].brnch_hist, correct_result_i);
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
(
    input clk,
    input rst,
    // reading
    // input logic rd_en_i,
    input logic [DATA_WIDTH-1:0] curr_addr_i,
    output logic hit_o,
    output logic [INSTR_WIDTH-1:0] predict_trgt_o
    // updating state
    input logic write_en_i,
    input logic [INSTR_WIDTH-1:0] correct_trgt_i,
    input logic [INSTR_WIDTH-1:0] old_pc_i,
);
    // 32-bit instr: [TAG][INDEX][BLOCK_OFFSET]

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
            logic miss_condition = !(tb_cache[curr_index].valid && tb_cache[curr_index].tag == curr_tag);

            always_ff @(posedge clk) begin : MakingAPredictionWrite
                if (rst) begin
                    tb_cache <= '0;
                end
            end
            
            always_comb begin : MakingAPredictionRead
                if (miss_condition) begin
                    // output
                    hit_o = 1'b0;
                    predict_trgt_o = '0; // default to pc + 4
                end else begin
                    hit_o = 1'b1;
                    predict_trgt_o = tb_cache[curr_index].trgt;
                end
            end

            // making assumption write_en_i "1" iff entry in prev_predict_pkts is valid
            always_ff @(posedge clk) begin : CheckingAPrediction
                if (write_en_i && !rst) begin
                    logic [TAG_WIDTH-1:0] old_tag = old_pc_i[DATA_WIDTH-1:DATA_WIDTH-TAG_WIDTH];
                    logic [INDEX_WIDTH-1:0] old_index = old_pc_i[DATA_WIDTH-TAG_WIDTH-1:BLOCK_OFFSET];
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
                curr_hit_ptr = '0;
                for (int i = 0; i < SET_ASSOCIATIVITY; i++) begin : Hit
                    curr_hit_array_w[i] = tb_cache[curr_index][i] == curr_tag && tb_cache[curr_index][i].valid;
                    if (curr_hit_array_w[i]) begin
                        curr_hit_ptr = i;
                    end
                end
                // curr_miss_condition = !(|curr_hit_array_w) || !rd_en_i;
                curr_miss_condition = !(|curr_hit_array_w);
            end

            always_ff @(posedge clk) begin : MakingAPredictionWrite
                if (rst) begin
                    tb_cache <= '0;
                    set_ptr <= '0;
                end
            end
            
            always_comb begin : MakingAPredictionRead
                if (curr_miss_condition) begin
                    // output
                    hit_o = 1'b0;
                    pred_trgt_o = '0; // default to pc + 4
                end else begin
                    hit_o = 1'b1;
                    pred_trgt_o = tb_cache[curr_index][curr_hit_ptr].trgt;
                end
            end

            // making assumption write_en_i "1" iff entry in prev_predict_pkts is valid
            always_ff @(posedge clk) begin : CheckingAPrediction
                if (write_en_i && !rst) begin
                    logic [TAG_WIDTH-1:0] old_tag = old_pc_i[DATA_WIDTH-1:DATA_WIDTH-TAG_WIDTH];
                    logic [INDEX_WIDTH-1:0] old_index = old_pc_i[DATA_WIDTH-TAG_WIDTH-1:BLOCK_OFFSET];
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
