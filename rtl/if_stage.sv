`timescale 1ns / 1ps

module if_stage #(
    parameter DATA_WIDTH = 32,
    parameter INSTR_WIDTH = 32,
) (
    input [INSTR_WIDTH-1:0] pc_trgt_i,
    ///cntrl
    

    input clk,

    output logic [INSTR_WIDTH-1:0] instr_o,
    output logic [DATA_WIDTH-1:0] pc_o

);

    // pc

    // mem

    // brancher

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
                        brnch_hist  [index][set_ptr] <= sat_add(brnch_hist[index][set_ptr], brnch_taken_i);
                        tag_array   [index][set_ptr] <= tag;
                        valid_array [index][set_ptr] <= 1'b1;
                        set_ptr <= set_ptr + 1;
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
                    block_data_o = mem_array[index]
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


module instr_mem_sync_unit #(
    parameter INSTR_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter LINES = 2 ** 20
) (
    input [ADDR_WIDTH-1:0] pc_i,
    input [DATA_WIDTH-1:0] data_i,
    input read_en_i,
    input write_en_i,

    input clk,
    input rst,

    
);



endmodule


// unsure if will use
module branch_unit #(
    parameter INSTR_WIDTH,
    parameter
    parameter BUFF_ADDR_WIDTH = 4
) (
    input br_res_i,
    input instr_addr_i,
    
    input trgt_i,

    output logic hit_o,
    output logic br_o,
    output logic trgt_o,
);
    // branch_pred #(

    // ) branch_pred_inst;

    // branch_trgt_buff #(

    // ) branch_trgt_buff_inst;


    // branch_pred
    // branch_trgt_buff
    // 
    
endmodule


module instr_mem #(
    parameter INSTR_WIDTH = 32,
    parameter ADDR_WIDTH  = 32,
    parameter ENTRIES = 2 ** 20
) (
    // reading
    input addr_r_i,
    output logic instr_r_o,

    input clk,
    input rst,

    // writing
    input addr_w_i,
    input instr_w_i,
    input write_en_i
);
    assert($clog2(ENTRIES) <= ADDR_WIDTH);

    logic [ENTRIES-1:0] mem [ADDR_WIDTH-1:0];

    always_ff @(posedge clk) begin
        if (rst) begin
            mem <= '0;
        end else begin
            instr_r_o <= mem[addr_r_i];
            if (write_en_i)
                mem[addr_w_i] <= instr_w_i;
        end
    end
endmodule


