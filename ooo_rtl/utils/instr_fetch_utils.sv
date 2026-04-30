
package brnch_predict_pkg;

    localparam DATA_WIDTH = 32;
    localparam IQ_SIZE = 16;
    // localparam ROB_COUNT = 32;
    localparam PRF_COUNT = 32;
    localparam INSTR_COMPRESS_WIDTH = 17;
    localparam MAX_EXEC_CYCLE = 4;
    localparam IMM_COMPRESS = 20;
    localparam FUNCT_COMB_WIDTH = 4; // representing funct3 + funct7
    // localparam 

    // branch predictor parameters
    parameter CACHE_LINES = 2 ** 6;
    parameter SET_ASSOCIATIVITY = 1;
    parameter OUTCOME_DELAY = 2; // # of cycles until the "brnch_taken_i" result comes in    

    // 32-bit instr: [TAG][INDEX][BLOCK_OFFSET]
    localparam INDEX_WIDTH = $clog2(CACHE_LINES);
    localparam BLOCK_OFFSET = 2; // each instr is 4 bytes
    localparam TAG_WIDTH = DATA_WIDTH - INDEX_WIDTH - BLOCK_OFFSET;

    function automatic bit branch_prediction(input logic [1:0] brnch_hist);
        branch_prediction = brnch_hist[1];
    endfunction

    // certain cases wont occur, so could optmize
    function automatic logic [1:0] update_state(input logic [1:0] brnch_state_old, input logic brnch_result);
        logic [1:0] brnch_state;
        if (brnch_result && brnch_state_old != 2'b11) begin
            brnch_state = brnch_state_old + 1;
        end
        else if (!brnch_result && brnch_state_old != 2'b00) begin
            brnch_state = brnch_state_old - 1;
        end else begin
            brnch_state = brnch_state_old;
        end
        return brnch_state;
    endfunction

    typedef struct packed {
        logic                   valid;
        logic [TAG_WIDTH-1:0]   tag;
        logic [1:0]             brnch_hist; // this intializes to strongly not taken
    } bp_cache_line_t;

    typedef struct packed {
        // logic [TAG_WIDTH-1:0]   tag;
        // logic [INDEX_WIDTH-1:0] index;
        logic                   prediction;
    } bp_prediction_pkt_t;


endpackage


package trgt_buffer_pkg;

    localparam DATA_WIDTH = 32;
    localparam IQ_SIZE = 16;
    // localparam ROB_COUNT = 32;
    localparam PRF_COUNT = 32;
    localparam INSTR_COMPRESS_WIDTH = 17;
    localparam MAX_EXEC_CYCLE = 4;
    localparam IMM_COMPRESS = 20;
    localparam FUNCT_COMB_WIDTH = 4; // representing funct3 + funct7
    // localparam 

    // branch predictor parameters
    parameter CACHE_LINES = 2 ** 6;
    parameter SET_ASSOCIATIVITY = 1;
    parameter OUTCOME_DELAY = 2; // # of cycles until the "brnch_taken_i" result comes in    

    // 32-bit instr: [TAG][INDEX][BLOCK_OFFSET]
    localparam INDEX_WIDTH = $clog2(CACHE_LINES);
    localparam BLOCK_OFFSET = 2; // each instr is 4 bytes
    localparam TAG_WIDTH = DATA_WIDTH - INDEX_WIDTH - BLOCK_OFFSET;

    function automatic bit branch_prediction(input logic [1:0] brnch_hist);
        branch_prediction = brnch_hist[1];
    endfunction

    // certain cases wont occur, so could optmize
    function automatic logic [1:0] update_state(input logic [1:0] brnch_state_old, input logic brnch_result);
        logic [1:0] brnch_state;
        if (brnch_result && brnch_state_old != 2'b11) begin
            brnch_state = brnch_state_old + 1;
        end
        else if (!brnch_result && brnch_state_old != 2'b00) begin
            brnch_state = brnch_state_old - 1;
        end else begin
            brnch_state = brnch_state_old;
        end
        return brnch_state;
    endfunction

    typedef struct packed {
        logic                   valid;
        logic [TAG_WIDTH-1:0]   tag;
        logic [INSTR_WIDTH-1:0] trgt;
    } trgt_buff_cache_line_t;

    typedef struct packed {
        // logic [TAG_WIDTH-1:0]   tag;
        // logic [INDEX_WIDTH-1:0] index;
        logic                   prediction;
    } bp_prediction_pkt_t;


endpackage