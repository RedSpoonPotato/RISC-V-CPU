/*
    Need to make sure we send the potential correct trgt address/prediciton back to this stage

    Edge case:
        what if we speculate on the same pc address multiple times without having the oldest prediction result come back?

            // makign assumption write_en_i "1" iff entry in prev_addrs is valid

    Check: branch predictor v2 requires old tag and index value i.e. we need a lot of registers 

    assume will send base pc values down pipeline stage, and will route back

    Q: since tgrt buff and branch rpedictor behave differently when it comes to instatiating new entyries, will these
    work ok together?

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
);

    assert(jalr_en_i && branch_en_i);

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
        end else if (jalr_en_i) begin
            pc_o <= jalr_pc_i;
        end else if (branch_en_i && branch_taken_i) begin
            pc_o <= jalr_pc_i; // for now, just reuse jalr_pc_i for branch target addr, but will likely need to change later
        end else begin
            pc_o <= pc_o + 4; // assuming 4 byte instructions, will need to change for compressed instrs
        end
    end



endmodule


module branch_predictor_v2
import brnch_predict_pkg::*;
(
    input clk,
    input rst,
    // reading
    input logic rd_en_i,
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
            assign miss_condition = !(bp_cache[curr_index].valid && bp_cache[curr_index].tag == curr_tag && rd_en_i);

            always_ff @(posedge clk) begin : MakingAPredictionWrite
                if (rst) begin
                    bp_cache <= '0;
                end else if (miss_condition) begin: No_hit
                    // instantiation
                    bp_cache[curr_index].valid <= 1'b1;
                    bp_cache[curr_index].tag <= curr_tag;
                    bp_cache[curr_index].brnch_hist <= 2'b00;
                end 
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
                curr_miss_condition = !(|curr_hit_array_w) || !rd_en_i;
            end

            always_ff @(posedge clk) begin : MakingAPredictionWrite
                if (rst) begin
                    bp_cache <= '0;
                    set_ptr <= '0;
                end else if (curr_miss_condition) begin: No_hit
                    // instantiation
                    bp_cache[curr_index][set_ptr[curr_index]].valid <= 1'b1;
                    bp_cache[curr_index][set_ptr[curr_index]].tag <= curr_tag;
                    bp_cache[curr_index][set_ptr[curr_index]].brnch_hist <= 2'b00;
                    set_ptr[curr_index] <= set_ptr[curr_index] + 1;
                end 
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
    input logic rd_en_i,
    input logic [DATA_WIDTH-1:0] curr_addr_i,
    output logic hit_o,
    output logic [INSTR_WIDTH-1:0] predict_trgt_o
    // updating state
    input logic write_en_i,
    input logic [INSTR_WIDTH-1:0] correct_trgt_i
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
            logic miss_condition = !(tb_cache[curr_index].valid && tb_cache[curr_index].tag == curr_tag && rd_en_i);

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
                curr_miss_condition = !(|curr_hit_array_w) || !rd_en_i;
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
                            set_ptr[curr_index] <= set_ptr[curr_index] + 1;
                        // end
                    // end
                end
            end
        end
    endgenerate

endmodule



module branch_predictor #(
    parameter ADDR_WIDTH = 32,
    parameter CACHE_LINES = 2 ** 6,
    parameter SET_ASSOCIATIVITY = 1,
    parameter OUTCOME_DELAY = 2 // # of cycles until the "brnch_taken_i" result comes in
) (

    input [ADDR_WIDTH-1:0] addr_i,
    input brnch_taken_i,
    input write_en_i, // not sure if i need this

    input clk,
    input rst,

    output logic hit_o,
    output logic pred_o
);
    localparam INDEX_WIDTH = $clog2(CACHE_LINES);
    localparam TAG_WIDTH = ADDR_WIDTH - INDEX_WIDTH;
    localparam INDEX_MSB = ADDR_WIDTH - 1 - TAG_WIDTH;

    // for reading the current address in the IF stage
    logic [TAG_WIDTH-1:0] curr_tag;
    logic [INDEX_WIDTH-1:0] curr_index;
    assign curr_tag   = addr_i[ADDR_WIDTH-1:INDEX_MSB+1];
    assign curr_index = addr_i[INDEX_MSB:0];

    // for storing addresses to later be written into memory
    logic [INSTR_WIDTH-1:0] prev_addr [OUTCOME_DELAY-1:0];
    logic [TAG_WIDTH-1:0] tag;
    logic [INDEX_WIDTH-1:0] index;
    assign tag   = prev_addr[OUTCOME_DELAY-1][ADDR_WIDTH-1:INDEX_MSB+1];
    assign index = prev_addr[OUTCOME_DELAY][INDEX_MSB:0];

    assert(CACHE_LINES <= INDEX_WIDTH ** 2);

    always_ff @(negedge clk) begin : ShiftRegister
        prev_addr[0] <= addr_i;
        for (int i = 1; i < OUTCOME_DELAY; i++) begin
            prev_addr[i] <= prev_addr[i-1];
        end
    end

    function automatic bit branch_prediction(input logic [1:0] brnch_hist);
        branch_prediction = brnch_hist[1];
    endfunction

    // certain cases wont occur, so could optmize
    function automatic sat_add(input logic [1:0] brnch_hist_slot, brnch_result);
        if (brnch_taken_i && brnch_hist[index] != 2'b11)
            sat_add = brnch_hist_slot + 1;
        else if (!brnch_taken_i && brnch_hist[index] != 2'b00)
            sat_add = brnch_hist_slot - 1;
    endfunction
    
    generate
        if (SET_ASSOCIATIVITY == 1) begin : DirectMapped
            // internal memory
            logic [1:0]             brnch_hist  [CACHE_LINES-1:0]; // this intializes to strongly not taken
            logic [TAG_WIDTH-1:0]   tag_array   [CACHE_LINES-1:0];
            logic                   valid_array [CACHE_LINES-1:0];

            always_ff @(negedge clk) begin: WritingToMem
                if (rst) begin
                    brnch_hist  <= '0;
                    tag_array   <= '0;
                    valid_array <= '0;
                end else if (write_en_i) begin
                    if (tag_array[index] != tag) begin : New_tag
                        tag_array[index] <= tag;
                        valid_array[index] <= 1'b1;
                    end
                    brnch_hist[index] <= sat_add(brnch_hist[index], brnch_taken_i);
                end
            end

            always_comb begin : ReadingFromMem
                if (!valid_array[index] || tag_array[index] != curr_tag)
                    hit_o = 1'b0;
                else begin
                    hit_o = 1'b1;
                    pred_o = branch_prediction(brnch_hist[index]);
                end
            end
        end else begin : SetAssociative
            // internal memory
            logic [1:0]             brnch_hist  [CACHE_LINES-1:0][SET_ASSOCIATIVITY-1:0]; // this intializes to strongly not taken
            logic [TAG_WIDTH-1:0]   tag_array   [CACHE_LINES-1:0][SET_ASSOCIATIVITY-1:0];
            logic                   valid_array [CACHE_LINES-1:0][SET_ASSOCIATIVITY-1:0];

            // additional set_associative items
            localparam SET_BITS = $clog2(SET_ASSOCIATIVITY);
            logic [SET_BITS-1:0] set_ptr [CACHE_LINES-1:0];

            always_ff @(negedge clk) begin: WritingToMem
                if (rst) begin
                    brnch_hist  <= '0;
                    tag_array   <= '0;
                    valid_array <= '0;
                    set_ptr     <= '0;
                end else if (write_en_i) begin
                    logic [SET_ASSOCIATIVITY-1:0] hit_array_w;
                    for (int i = 0; i < SET_ASSOCIATIVITY; i++) begin : Hit
                        hit_array_w[i] = (tag_array[index][i] == tag && valid_array[index][i]) ? 1'b1 : 1'b0;
                        if (hit_array_w[i]) begin
                            brnch_hist[index][i] <= sat_add(brnch_hist[index][i], brnch_taken_i);
                        end
                    end
                    if (|hit_array_w == 1'b0) begin : No_hit
                        brnch_hist  [index][set_ptr[index]] <= sat_add(brnch_hist[index][set_ptr[index]], brnch_taken_i);
                        tag_array   [index][set_ptr[index]] <= tag;
                        valid_array [index][set_ptr[index]] <= 1'b1;
                        set_ptr[index] <= set_ptr[index] + 1;
                    end
                end
            end

            always_comb begin : ReadingFromMem
                logic [SET_ASSOCIATIVITY-1:0] hit_array_r;
                for (int i = 0; i < SET_ASSOCIATIVITY; i++) begin : Hit
                    hit_array_r[i] = (valid_array[curr_index][i] && tag_array[curr_index][i] == curr_tag) ? 
                        1'b1 : 1'b0;
                    if (hit_array_r[i] == 1'b1) begin
                        pred_o = branch_prediction(brnch_hist[curr_index][i]);
                    end
                end
                hit_o = |hit_array_r;
            end
        end
        endgenerate
    

endmodule

// /*
//     gets instr_mem_addr, checks
//         using direct mapped mem that returns a hit signal
//     if hit, outputs a hit signal (indicates is a branch instr) and returns 
    
// */
// module branch_trgt_buff #(

// ) (

// )
// endmodule

// written to on negative edge
// data_width input works only on single size (DATA_WIDTH)
module btb_mem #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter CACHE_LINES = 2 ** 6,
    parameter SET_ASSOCIATIVITY = 1,
    parameter OUTCOME_DELAY = 2 // # of cycles until the "brnch_taken_i" result comes in
) (
    input [ADDR_WIDTH-1:0] addr_i,
    input [DATA_WIDTH-1:0] data_i,
    input write_en_i,

    input clk,
    input rst,
    
    output logic [DATA_WIDTH-1:0] block_data_o,
    output logic hit_o
);
    localparam INDEX_WIDTH = $clog2(CACHE_LINES);

    // assigning addr_i slices
    localparam TAG_WIDTH = ADDR_WIDTH - INDEX_WIDTH;
    localparam INDEX_MSB = ADDR_WIDTH - 1 - TAG_WIDTH;

    // for reading the current address in the IF stage
    logic [TAG_WIDTH-1:0] curr_tag;
    logic [INDEX_WIDTH-1:0] curr_index;
    assign curr_tag          = addr_i[ADDR_WIDTH-1:INDEX_MSB+1];
    assign curr_index        = addr_i[INDEX_MSB:0];

    // for storing addresses to later be written into memory
    logic [INSTR_WIDTH-1:0] prev_addr [OUTCOME_DELAY-1:0];
    logic [TAG_WIDTH-1:0] tag;
    logic [INDEX_WIDTH-1:0] index;
    assign tag          = prev_addr[OUTCOME_DELAY-1][ADDR_WIDTH-1:INDEX_MSB+1];
    assign index        = prev_addr[OUTCOME_DELAY][INDEX_MSB:0];

    assert(CACHE_LINES <= INDEX_WIDTH ** 2);

    always_ff @(negedge clk) begin : ShiftRegister
        prev_addr[0] <= addr_i;
        for (int i = 1; i < OUTCOME_DELAY; i++) begin
            prev_addr[i] <= prev_addr[i-1];
        end
    end
    
    generate
        if (SET_ASSOCIATIVITY == 1) begin : DirectMapped
            // internal memory
            logic [DATA_WIDTH-1:0]  mem_array   [CACHE_LINES-1:0];
            logic [TAG_WIDTH-1:0]   tag_array   [CACHE_LINES-1:0];
            logic                   valid_array [CACHE_LINES-1:0];

            always_ff @(negedge clk) begin: WritingToMem
                if (rst) begin
                    mem_array <= '0;
                    tag_array <= '0;
                    valid_array <= '0;
                end else begin
                    if (write_en_i) begin
                        mem_array[index] <= data_i;
                        tag_array[index] <= tag;
                        valid_array[index] <= 1'b1;
                    end
                end
            end

            always_comb begin : ReadingFromMem
                if (tag_array[index] == curr_tag && valid_array[index]) begin
                    block_data_o = mem_array[index];
                    hit_o = 1'b1;
                end else begin
                    hit_o = 1'b0;
                end
            end
        end else begin : SetAssociative
            // internal memory
            logic [DATA_WIDTH-1:0]  mem_array   [CACHE_LINES-1:0][SET_ASSOCIATIVITY-1:0];
            logic [TAG_WIDTH-1:0]   tag_array   [CACHE_LINES-1:0][SET_ASSOCIATIVITY-1:0];
            logic                   valid_array [CACHE_LINES-1:0][SET_ASSOCIATIVITY-1:0];

            // additional set_associative items
            localparam SET_BITS = $clog2(SET_ASSOCIATIVITY);
            logic [SET_BITS-1:0] set_ptr [CACHE_LINES-1:0];

            always_ff @(negedge clk) begin : WritingToMem
                if (rst) begin
                    mem_array   <= '0;
                    tag_array   <= '0;
                    valid_array <= '0;
                    set_ptr     <= '0;
                end else if (write_en_i) begin
                    logic [SET_ASSOCIATIVITY-1:0] hit_array_w;
                    for (int i = 0; i < SET_ASSOCIATIVITY; i++) begin
                        hit_array_w[i] = (tag_array[index][i] == tag && valid_array[index][i]) ? 1'b1 : 1'b0;
                        if (hit_array_w[i] == 1'b1) begin
                            mem_array[index][i] <= data_i;
                            tag_array[index][i] <= tag;
                        end
                    end
                    if (|hit_array_w == 1'b0) begin
                        mem_array  [index][set_ptr] <= data_i;
                        tag_array  [index][set_ptr] <= tag;
                        valid_array[index][set_ptr] <= 1'b1;
                        set_ptr[index] <= set_ptr[index] + 1;
                    end
                end
            end

            // reading from mem
            always_comb begin : ReadingFromMem
                logic [SET_ASSOCIATIVITY-1:0] hit_array_r;
                for (int i = 0; i < SET_ASSOCIATIVITY; i++) begin
                    hit_array_r[i] = (tag_array[curr_index][i] == tag && valid_array[curr_index][i]) ? 1'b1 : 1'b0;
                    if (hit_array_r[i] == 1'b1)
                        block_data_o = mem_array[curr_index][i];
                end
                hit_o = |hit_array_r;
            end
        end
    endgenerate   
endmodule