localparam REQ_DATA_WIDTH = 1 + ADDR_WIDTH + DATA_WIDTH + MEM_OP_INFO_WIDTH;
localparam REQ_FIFO_DEPTH = 16;
localparam RESP_DATA_WIDTH = DATA_WIDTH + MEM_RESP_INFO_WIDTH;
localparam RESP_FIFO_DEPTH = 16;



package cache_pkg;


    // import instr_fetch_pkg::*;

    localparam CACHE_LINES = 2 ** 6;
    localparam SET_ASSOCIATIVITY = 1;

    // block: [TAG][INDEX][BLOCK_OFFSET]
    localparam LINE_WIDTH = 1024;
    localparam INDEX_WIDTH = $clog2(CACHE_LINES);
    localparam BLOCK_OFFSET = $clog2(LINE_WIDTH);
    localparam TAG_WIDTH = DATA_WIDTH - INDEX_WIDTH - BLOCK_OFFSET;

    localparam [2:0] AXI_SIZE = $clog2(DATA_WIDTH/8); 
    localparam [7:0] CACHE_LINE_BURST_LEN = ( (1 << BLOCK_OFFSET) / (DATA_WIDTH/8) ) - 1;

    typedef struct packed {
        logic                  valid;
        logic [TAG_WIDTH-1:0]  tag;
        logic                  dirty;
    } cache_line_state_t;

    typedef enum {
        IDLE,
        LOAD_HIT, 
        LOAD_MISS_INITIAL, 
        LOAD_MISS_WAIT,
        STORE_MISS_INITIAL,
        STORE_MISS_WAIT,
        STORE_V2_SETUP,
        RESPOND
        // LOAD_HIT, LOAD_MISS,
        // STORE_HIT, STORE_MISS,
        // V2_SETUP,
        // LOAD_HIT_V2, LOAD_MISS_V2, 
        // STORE_HIT_V2, STORE_MISS_V2,
        // RESPOND
    } cache_state_t;

endpackage

function automatic logic [MEM_RESP_INFO_WIDTH-1:0] req_info_to_resp_info(
    input logic [MEM_OP_INFO_WIDTH-1:0] req_info
);
    logic [MEM_RESP_INFO_WIDTH-1:0] resp_info;
    resp_info = req_info[MEM_RESP_INFO_WIDTH-1:0];
    return resp_info;
endfunction

// this is a problme if pattern is not recognized
// could make this generic with adders, but nto going to for timing reasons
function automatic logic [$clog2(DATA_WIDTH/8)-1:0] detect_mem_size(
    input logic [2:0] funct_code,
    input logic store_en,
    input logic [(DATA_WIDTH/8)-1:0] byte_vec_en
);
    if (store_en) begin
        case (funct_code)
            3'b000: return 0;
            3'b001: return 1;
            3'b010: return 3;
            default: return 0;
        endcase
    end else begin
        case (byte_vec_en) 
            4'b0001: return 0;
            4'b0011: return 1;
            4'b1111: return 3;
            default: return 0;
        endcase
    end
    
endfunction

function automatic logic detect_cache_unaligned(
    input logic [ADDR_WIDTH-1:0] addr,
    input logic store_en,
    input logic [2:0] funct_code,
    input logic [DATA_WIDTH/8-1:0] byte_vec_en
);
    logic [$clog2(DATA_WIDTH/8)-1:0] mem_op_size;
    mem_op_size = detect_mem_size(funct_code, store_en, byte_vec_en);
    // detect if the memory operation crosses the cache block boundary
    logic [BLOCK_OFFSET:0] final_addr_sum;
    final_addr_sum = {1'b0, addr[BLOCK_OFFSET-1:0]} + mem_op_size;
    return final_addr_sum[BLOCK_OFFSET];
endfunction

function automatic logic [ADDR_WIDTH-1:0] set_aligned_addr_v2(
    input   logic [ADDR_WIDTH-1:0] base_addr,
);
    logic [ADDR_WIDTH-1:0] addr_2;
    addr_2 = base_addr + (1 << BLOCK_OFFSET);
    addr_2 = {addr_2[ADDR_WIDTH-1:BLOCK_OFFSET], {BLOCK_OFFSET{1'b0}}};
    return addr_2;
endfunction

function automatic void set_aligned_byte_wr_ens(
    input   logic [(DATA_WIDTH/8)-1:0]  base_byte_wr_en,
    input   logic [ADDR_WIDTH-1:0]      base_addr,
    input   logic                       store,
    input   logic [2:0]                 funct_code,
    output  logic [(DATA_WIDTH/8)-1:0]  byte_wr_en_1,
    output  logic [(DATA_WIDTH/8)-1:0]  byte_wr_en_2
);
    logic [$clog2(DATA_WIDTH/8)-1:0] mem_op_size;
    mem_op_size = detect_mem_size(funct_code, store, base_byte_wr_en);
    logic [(DATA_WIDTH/8)-1:0] shift_amt_v2, rev_shift_amt_v1;
    shift_amt_v2 = (base_addr[BLOCK_OFFSET-1:0] + mem_op_size)[(DATA_WIDTH/8)-1:0];
    rev_shift_amt_v1 = ((DATA_WIDTH/8) - shift_amt_v2)[(DATA_WIDTH/8)-1:0];
    byte_wr_en_1 = (base_byte_wr_en >> rev_shift_amt_v1) << rev_shift_amt_v1;
    byte_wr_en_2 = (base_byte_wr_en << shift_amt_v2) >> shift_amt_v2;
endfunction

function automatic void set_aligned_data(
    input   logic [(DATA_WIDTH/8)-1:0]  base_byte_wr_en,
    input   logic [ADDR_WIDTH-1:0]      base_addr,
    input   logic                       store,
    input   logic [2:0]                 funct_code,
    output  logic [DATA_WIDTH-1:0]      data_1,
    output  logic [DATA_WIDTH-1:0]      data_2
);
 
endfunction

function automatic logic [DATA_WIDTH-1:0] set_v1_load_data(
    input   logic [(DATA_WIDTH/8)-1:0]  byte_wr_en_v1,
    input   logic [DATA_WIDTH-1:0]      data_v1,
    input   logic [DATA_WIDTH-1:0]      data_in,
);
    logic [DATA_WIDTH-1:0] data_o;
endfunction

function automatic void set_v2_load_data(
    input   logic [(DATA_WIDTH/8)-1:0]  byte_wr_en_v2,
    input   logic [DATA_WIDTH-1:0]      data_v2,
    input   logic [DATA_WIDTH-1:0]      data_in,
    input   logic [ADDR_WIDTH-1:0]      addr, // used to knwo how much to shift
    output  logic [DATA_WIDTH-1:0]      data_o
);

endfunction

function automatic cache_state_t check_v2_seq(
    input   logic                       cache_unaligned,
    input   logic                       hit_v2,
    input   logic                       store
);
    cache_state_t next_state;
    if (!cache_unaligned) begin
        if (store) begin
            next_state = IDLE;
        end else begin
            next_state = RESPOND;
        end
    end else begin
        if (hit_v2) begin
            if (store) begin
                next_state = STORE_V2_SETUP;
            end else begin
                next_state = LOAD_HIT;
            end
        end else begin
            if (store) begin
                next_state = STORE_MISS_V2;
            end else begin
                next_state = LOAD_MISS_V2;
            end
        end
    end
    return next_state;
endfunction


function automatic cache_state_t next_state_from_idle(
    input   logic                       cache_unaligned,
    input   logic                       hit_v1,
    input   logic                       store
);
    cache_state_t next_state;
    if (!hit_v1) begin
        return store ? STORE_MISS_INITIAL : LOAD_MISS_INITIAL;
    end else begin
        if (!store) return LOAD_HIT;
        if (cache_unaligned) begin
            return STORE_V2_SETUP;
        end else begin
            return IDLE;
        end
    end
endfunction


function automatic cache_state_t next_state_from_first_load(
    input   logic                       cache_unaligned,
    input   logic                       hit_v2
);
    cache_state_t next_state;
    if (!cache_unaligned) begin
        next_state = RESPOND;
    end else begin
        if (hit_v2) begin
            next_state = LOAD_HIT;
        end else begin
            next_state = LOAD_MISS_INITIAL;
        end
    end
    return next_state;
endfunction

function automatic logic [DATA_WIDTH-1:0] capture_data_into_load_reg(
    input   logic [(DATA_WIDTH/8)-1:0]  byte_wr_en_v1,
    input   logic [DATA_WIDTH-1:0]      data_v1,
    input   logic [DATA_WIDTH-1:0]      data_in
);
    logic [DATA_WIDTH-1:0] data_o;
    for (int i = 0; i < DATA_WIDTH/8; i++) begin
        if (byte_wr_en_v1[i]) begin
            data_o[i*8 +: 8] = data_in[i*8 +: 8];
        end else begin
            data_o[i*8 +: 8] = data_v1[i*8 +: 8];
        end
    end
    return data_o;
endfunction
