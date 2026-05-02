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
    
*/


module instr_fetch_stage 
(
    input clk,
    input rst,

    // for instantiation, unsure if needed in final design
    input logic [31:0] instr_in_i
    input logic [DATA_WIDTH-1:0] instr_addr_i,
    input logic instr_in_valid_i,
    
    // from ex_mem for branch misprediction recovery
    input logic jalr_en_i,
    input logic [DATA_WIDTH-1:0] jalr_pc_i,
    input logic branch_en_i,
    input logic branch_taken_i,

    output logic [31:0] instr_o,
    output logic instr_valid_o,
    output logic [DATA_WIDTH-1:0] pc_o


    // correct branch result (coming from ex_mem stage)
    input logic ex_write_en_i,
    input logic ex_correct_result_i,
    input logic [INSTR_WIDTH-1:0] ex_old_pc_i,

    // trgt result (non-pc+4 brnch trgt, aswell as jump targets)
    input logic decode_write_en_i,
    input logic [INSTR_WIDTH-1:0] decode_correct_trgt_i,
    input logic [INSTR_WIDTH-1:0] decode_old_pc_i
);

    assert(jalr_en_i && branch_en_i);

    // NEED TO DRIVE THIS
    logic grab_new_pc;

    // logic bp_rd_en;
    logic bp_hit_o;
    logic bp_pred_;

    branch_predictor_inst branch_predictor
    (
        .clk(clk),
        .rst(rst),
        // reading
        .rd_en_i(grab_new_pc),
        .curr_addr_i(pc_o),
        .hit_o(bp_hit_o),
        .pred_o(bp_pred_o),
        // updating state
        .write_en_i(ex_write_en_i),
        .correct_result_i(ex_correct_result_i),
        .old_pc_i(ex_old_pc_i)
    );

    // reading
    // logic rd_en_i,
    logic tb_hit;
    logic [INSTR_WIDTH-1:0] tb_predict_trgt;
    // updating state
    logic write_en_i;
    logic [INSTR_WIDTH-1:0] correct_trgt_i;
    logic [INSTR_WIDTH-1:0] old_pc_i;

    trgt_buffer_inst trgt_buffer
    (
        .clk(clk),
        .rst(rst),
        // reading
        .rd_en_i(grab_new_pc),
        .curr_addr_i(pc_o),
        .hit_o(tb_hit),
        .predict_trgt_o(tb_predict_trgt),
        // updating state
        .write_en_i(decode_write_en_i),
        .correct_trgt_i(decode_correct_trgt_i),
        .old_pc_i(decode_old_pc_i)
    );

    assign instr_mem_addr = instr_in_valid_i ? instr_addr_i : pc_o;

    sram_sync_read #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(10) // for now, hardcoding to 10 bits (1024 entries)
    ) instr_memory (
        .clk(clk),
        .we(instr_in_valid_i),
        .addr(instr_mem_addr),
        .din(instr_in_i),
        .dout(instr_o)
    );
       

    // branch prediction
    // cases: branch, jalr, and jal

    always_ff @(posedge clk) begin
        if (rst) begin
            pc_o <= '0;
            grab_new_pc <= 0;
        end else begin
            if (stall) begin // NEED TO DRIVE THIS
                pc_o <= ...;
                grab_new_pc <= 0;
            end else if (hit )
            end else if (jalr_en_i) begin
                pc_o <= jalr_pc_i;
                grab_new_pc <= 1;
            end else if (branch_en_i && branch_taken_i) begin
                pc_o <= jalr_pc_i; // for now, just reuse jalr_pc_i for branch target addr, but will likely need to change later
                grab_new_pc <= 1;
            end else begin
                pc_o <= pc_o + 4; // assuming 4 byte instructions, will need to change for compressed instrs
                grab_new_pc <= 1;
            end
        end
    end

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
                        old_hit_array_w[i]  = bp_cache[old_index][i] == old_tag && bp_cache[old_index][i].valid;
                        if (old_hit_array_w[i]) begin
                            bp_cache[old_index][i].brnch_hist <= update_state(bp_cache[old_index].brnch_hist, correct_result_i);
                            break;
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
                    // for (int i = 0; i < SET_ASSOCIATIVITY; i++) begin : Hit
                        // old_hit_array_w[i] = tb_cache[old_index][i] == old_tag && tb_cache[old_index][i].valid;
                        // if (old_hit_array_w[i]) begin
                            tb_cache[old_index][set_ptr[old_index]].valid <= 1'b1;
                            tb_cache[old_index][set_ptr[old_index]].tag <= old_tag;
                            tb_cache[old_index][set_ptr[old_index]].trgt <= correct_trgt_i;
                            set_ptr[old_index] <= set_ptr[old_index] + 1;
                        // end
                    // end
                end
            end
        end
    endgenerate

endmodule
