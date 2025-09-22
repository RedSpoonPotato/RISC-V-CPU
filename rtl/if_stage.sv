`timescale 1ns / 1ps

module if_stage #(
    // parameter
) (
    input clk,

);

    // mem
    /*  will eventually change due to having external memory,
        but for now, will keep it
    */

    // pc

    // brancher

endmodule

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


/* 
    For now will just do a direct-mapped implementation, thus must use same ofr btb_mem
*/
module branch_predictor #(
    parameter ADDR_WIDTH = 32,
    parameter CACHE_LINES = 2 ** 6,
    parameter SET_ASSOCIATIVITY = 1,
) (

    input [ADDR_WIDTH-1:0] pc_i,
    input brnch_taken_i,
    input write_en_i, // not sure if i need this

    input clk,
    input rst,

    output pred_o
);
    localparam INDEX_WIDTH = $clog2(CACHE_LINES);

    // assigning addr_i slices
    localparam TAG_WIDTH = ADDR_WIDTH - INDEX_WIDTH;

    logic [TAG_WIDTH-1:0] tag;
    logic [INDEX_WIDTH-1:0] index;

    localparam INDEX_MSB = ADDR_WIDTH - 1 - TAG_WIDTH;

    assign tag          = addr_i[ADDR_WIDTH-1:INDEX_MSB+1];
    assign index        = addr_i[INDEX_MSB:0];
    
    generate
        if (SET_ASSOCIATIVITY == 1) begin : DirectMapped
            // internal memory
            assert(CACHE_LINES <= INDEX_WIDTH ** 2);
            logic [1:0]             brnch_hist  [CACHE_LINES-1:0]; // this intializes to strongly not taken
            logic [TAG_WIDTH-1:0]   tag_array   [CACHE_LINES-1:0];
            logic                   valid_array [CACHE_LINES-1:0];

            always_ff @(negedge clk) begin: WritingToMem
                if (rst) begin
                    brnch_hist  <= '0;
                    tag_array   <= '0;
                    valid_array <= '0;
                end else begin
                    if (write_en_i) begin
                        if (brnch_taken_i) begin
                            if (brnch_hist[index] != 2'b11 && tag_array[index] == tag) begin
                                valid_array[index] = 1'b1;
                                brnch_hist[index] = brnch_hist[index] + 1;
                            end

                        end else if ()
                        brnch_hist[index]   <= brnch_hist[index];
                        tag_array[index]    <= tag;
                        valid_array[index]  <= 1'b1;
                    end
                end
            end

            always_comb begin : ReadingFromMem
                if (tag_array[index] == tag && valid_array[index]) begin
                    block_data_o = mem_array[index]
                    hit_o = 1'b1;
                end else begin
                    hit_o = 1'b0;
                end
            end
        end else begin : SetAssociative
            
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
    parameter SET_ASSOCIATIVITY = 1
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

    logic [TAG_WIDTH-1:0] tag;
    logic [INDEX_WIDTH-1:0] index;

    localparam INDEX_MSB = ADDR_WIDTH - 1 - TAG_WIDTH;

    assign tag          = addr_i[ADDR_WIDTH-1:INDEX_MSB+1];
    assign index        = addr_i[INDEX_MSB:0];
    
    generate
        if (SET_ASSOCIATIVITY == 1) begin : DirectMapped
            // internal memory
            assert(CACHE_LINES <= INDEX_WIDTH ** 2);
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
                if (tag_array[index] == tag && valid_array[index]) begin
                    block_data_o = mem_array[index]
                    hit_o = 1'b1;
                end else begin
                    hit_o = 1'b0;
                end
            end
        end else begin : SetAssociative
            // internal memory
            assert(CACHE_LINES <= INDEX_WIDTH ** 2);
            logic [DATA_WIDTH-1:0]  mem_array   [CACHE_LINES-1:0][SET_ASSOCIATIVITY-1:0];
            logic [TAG_WIDTH-1:0]   tag_array   [CACHE_LINES-1:0][SET_ASSOCIATIVITY-1:0];
            logic                   valid_array [CACHE_LINES-1:0][SET_ASSOCIATIVITY-1:0];

            // additional set_associative items
            localparam SET_BITS = $clog2(SET_ASSOCIATIVITY);
            logic [SET_BITS-1:0] set_ptr        [CACHE_LINES-1:0];

            always_ff @(negedge clk) begin : WritingToMem
                if (rst) begin
                    mem_array   <= '0;
                    tag_array   <= '0;
                    valid_array <= '0;
                    set_ptr     <= '0;
                end else if (write_en_i) begin
                    mem_array  [index][set_ptr] <= data_i;
                    tag_array  [index][set_ptr] <= tag;
                    valid_array[index][set_ptr] <= 1'b1;
                    set_ptr[index] <= set_ptr[index] + 1;
                end
            end

            // reading from mem
            logic [SET_ASSOCIATIVITY-1:0] hit_array;
            integer i;
            
            always_comb begin : ReadingFromMem
                for (i = 0; i < SET_ASSOCIATIVITY; i++) begin
                    hit_array[i] = (tag_array[index][i] == tag && valid_array[index][i]) ? 1'b1 : 1'b0;
                    if (hit_array[i] == 1'b1)
                        block_data_o = mem_array[index][i];
                end
                hit_o = |hit_array;
            end
        end
    endgenerate


    

endmodule


