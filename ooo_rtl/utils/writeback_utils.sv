package writeback_pkg;

    localparam IQ_SIZE = 16;
    localparam ROB_COUNT = 32;
    // localparam PRF_COUNT = 32;
    localparam INSTR_COMPRESS_WIDTH = 17;
    localparam MAX_EXEC_CYCLE = 4;
    localparam IMM_COMPRESS = 20;

    import decode_utils::PRF_COUNT;
    import utils::DATA_WIDTH;

    typedef struct packed {
        logic instr_valid;
        // logic [$clog2(MAX_EXEC_CYCLE)-1:0] exec_dur; // unsure if we need to output this
        logic speculative;
        logic store;
        logic dest_valid;
        logic [DATA_WIDTH-1:0] dest_data;
    } ex_mem_stage_pkt_t;   

    typedef enum {FREE, PENDING, FINISHED} rob_state_t;

    typedef struct packed {
        rob_state_t state;
        logic speculative;
        logic store;
        logic dest_valid;
        logic [$clog2(PRF_COUNT)-1:0] phys_reg_addr;
        logic [4:0] arch_reg_addr;
        logic [$clog2(PRF_COUNT)-1:0] prev_phys_reg_addr;
    } rob_entry_t;

    typedef struct packed {
        logic wr_en;
        logic [$clog2(PRF_COUNT)-1:0] phys_reg_addr;
        logic [4:0] arch_reg_addr;
        logic [$clog2(PRF_COUNT)-1:0] prev_phys_reg_addr;
    } rob_instance_pkt_t;
        
endpackage
