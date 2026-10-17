localparam REQ_DATA_WIDTH = 1 + ADDR_WIDTH + DATA_WIDTH + MEM_OP_INFO_WIDTH;
localparam REQ_FIFO_DEPTH = 16;
localparam RESP_DATA_WIDTH = DATA_WIDTH + MEM_RESP_INFO_WIDTH;
localparam RESP_FIFO_DEPTH = 16;



package cache_pkg;


    // import instr_fetch_pkg::*;

    localparam CACHE_LINES = 2 ** 6;
    localparam SET_ASSOCIATIVITY = 1;

    // block: [TAG][INDEX][BLOCK_OFFSET]
    localparam LINE_SIZE = 1024;
    localparam INDEX_WIDTH = $clog2(CACHE_LINES);
    localparam BLOCK_OFFSET = $clog2(LINE_SIZE);
    localparam TAG_WIDTH = DATA_WIDTH - INDEX_WIDTH - BLOCK_OFFSET;

    // unsure if using below


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
        logic [DATA_WIDTH-1:0] trgt;
    } trgt_buff_cache_line_t;

    typedef struct packed {
        // logic [TAG_WIDTH-1:0]   tag;
        // logic [INDEX_WIDTH-1:0] index;
        logic                   prediction;
    } bp_prediction_pkt_t;

endpackage