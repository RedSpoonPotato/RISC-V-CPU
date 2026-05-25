
package instr_fetch_pkg;

    import general_pkg::*;
    export general_pkg::*;

    // localparam DATA_WIDTH = 32;
    // localparam IQ_SIZE = 16;
    // localparam ROB_COUNT = 32;
    // localparam PRF_COUNT = 32;
    // localparam INSTR_COMPRESS_WIDTH = 17;
    // localparam MAX_EXEC_CYCLE = 4;
    // localparam IMM_COMPRESS = 20;
    // localparam FUNCT_COMB_WIDTH = 4; // representing funct3 + funct7
    // localparam OUTCOME_DELAY = 3; // # of cycles until the "brnch_taken_i" result comes in  

    localparam MAX_SPEC_EXEC_INSTRS = 4; // max number of in-flight speculative (jumps and branches) instrs
    localparam MAX_AUIPC_INSTRS = 4;
    localparam MAX_PC_INSTRS = MAX_SPEC_EXEC_INSTRS + MAX_AUIPC_INSTRS; // max number of instrs that can be waiting on a pc calculation (branches, jumps, auipc)

    localparam INSTR_MEM_ENTRY_NUM = 1024;
    localparam INSTR_MEM_INDEX_WIDTH = $clog2(INSTR_MEM_ENTRY_NUM);

    typedef struct packed {
        logic wr_en;
        // logic [$clog2(MAX_SPEC_EXEC_INSTRS)-1:0] buff_ptr;
    } spec_exec_buffer_instance_pkt_t;

    // typedef struct packed {
    //     // logic [DATA_WIDTH-1:0] pc;
    //     logic trgt_en;
    //     logic [DATA_WIDTH-1:0] calc_pc;
    //     logic branch_en;
    //     logic branch_taken;
    //     logic [$clog2(MAX_SPEC_EXEC_INSTRS)-1:0] spec_exec_ptr;
    // } spec_exec_answr_pkt_t;

    // should change name b/c its not really  a packet in if shift register
    typedef struct packed {
        // logic valid;
        logic trgt_en;
        logic [DATA_WIDTH-1:0] trgt;
        // logic branch_pred_en; // prob dont need
        logic branch_pred;
        logic branch_en;
        // logic [DATA_WIDTH-1:0] pc;
    } shift_reg_pkt_t;

    typedef struct packed {
        // logic valid;
        // logic trgt_en;
        logic [DATA_WIDTH-1:0] trgt;
        // logic branch_pred_en; // prob dont need
        logic branch_pred;
        // logic branch_en;
        logic [DATA_WIDTH-1:0] pc;
    } shift_reg_pkt_2_t;

    // typedef struct packed {

    // } corrct;


    typedef struct packed {
        logic instr_valid;
        logic [31:0] instr;
        logic [DATA_WIDTH-1:0] pc;
        logic bp_pred; // dont think we need
    } if_output_pkt_t;

    typedef struct packed {
        logic valid;
        logic [31:0] instr_in;
        logic [DATA_WIDTH-1:0] instr_addr;
    } instr_fetch_ctrl_pkt_t;

endpackage

package brnch_predict_pkg;

    import instr_fetch_pkg::*;

    // branch predictor localparams
    localparam CACHE_LINES = 2 ** 6;
    localparam SET_ASSOCIATIVITY = 1;
    // localparam OUTCOME_DELAY = 2; // # of cycles until the "brnch_taken_i" result comes in    

    // 32-bit address: [TAG][INDEX][BLOCK_OFFSET]
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


    import instr_fetch_pkg::*;


    // branch predictor localparams
    localparam CACHE_LINES = 2 ** 6;
    localparam SET_ASSOCIATIVITY = 1;
    // localparam OUTCOME_DELAY = 2; // # of cycles until the "brnch_taken_i" result comes in    

    // 32-bit address: [TAG][INDEX][BLOCK_OFFSET]
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
        logic [DATA_WIDTH-1:0] trgt;
    } trgt_buff_cache_line_t;

    typedef struct packed {
        // logic [TAG_WIDTH-1:0]   tag;
        // logic [INDEX_WIDTH-1:0] index;
        logic                   prediction;
    } bp_prediction_pkt_t;

endpackage