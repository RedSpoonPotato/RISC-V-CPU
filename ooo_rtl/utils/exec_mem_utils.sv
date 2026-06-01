
package exec_mem_pkg;

    import decode_pkg::*;
    import general_pkg::*;
    export general_pkg::*;
    import writeback_pkg::*;
    import issue_pkg::*;
    import instr_fetch_pkg::*;

    localparam MEM_ENTRY_NUM = 1024;
    localparam MEM_INDEX_WIDTH = $clog2(MEM_ENTRY_NUM);


    //  COMEBACK AND DEFINE
    // function automatic logic [$clog2(MAX_EXEC_CYCLE_V2-1)-1:0] get_exec_stage_delays_v2 (
    //     input EX_MEM_TYPE funct_unit_i,
    // );
    //     return MAX_EXEC_CYCLE_V2-1;
    // endfunction

    // function automatic logic [$clog2(MAX_EXEC_CYCLE_DELAY)-1:0] get_exec_stage_delays_v3(
    function automatic logic [$clog2(MAX_EXEC_CYCLE_V2)-1:0] get_exec_stage_delays_v3(
        input EX_MEM_TYPE funct_unit_type
    );
        case (funct_unit_type)
            ALU: return 0;
            MEM: return 1;
            BRANCH: return 0;
            JALR: return 0;
            AUIPC: return 0;
            default:
                return 0; // Default to 1 cycle for unsupported types
        endcase
    endfunction

    typedef struct packed {
        // ex_mem_stage_pkt_t ex_mem_stage_pkt;
        logic instr_valid;
        logic [$clog2(ROB_COUNT)-1:0] rob_ptr;
        logic dest_valid; 
        // USE THIS AT END OF THE STAGE
        // for rename table and issue queue update
        // logic [$clog2(PRF_COUNT)-1:0] prf_ptr;
        // logic [4:0] arf_ptr;
        // for multiplexing output of stage
        logic [EX_MEM_TYPE_SIZE-1:0] funct_unit_one_hot;
        logic store;
        logic [$clog2(MAX_SPEC_EXEC_INSTRS):0] spec_exec_ptr;
    } ex_mem_scoreboard_data_t;

    typedef struct packed {
        // logic valid;
        // logic [DATA_WIDTH-1:0] pc;
        logic trgt_en;
        logic [DATA_WIDTH-1:0] calc_pc;
        logic branch_en;
        logic branch_taken;
        logic [$clog2(MAX_SPEC_EXEC_INSTRS):0] spec_exec_ptr;
    } spec_exec_answr_pkt_t;

    typedef struct packed {
        logic wr_en;
        logic [$clog2(MAX_MEM_INSTRS)-1:0] buff_ptr;
        logic is_store;
        logic [DATA_WIDTH-1:0] addr;
        logic [DATA_WIDTH-1:0] pc;
        // can technically optimize away "store_data" by resuing data_o in mem stage
        logic [DATA_WIDTH-1:0] store_data;
    } mem_addr_pkt_t;

    // typedef struct packed 

    typedef struct packed {
        logic valid;
        logic is_store;
        logic [DATA_WIDTH-1:0] addr;
        logic [DATA_WIDTH-1:0] pc;
        logic [DATA_WIDTH-1:0] store_data;
    } mem_addr_entry_t;

    function automatic ex_mem_scoreboard_data_t set_ex_mem_scoreboard_data (
        input fetch_packet_t fetch_pkt_i
    );
        ex_mem_scoreboard_data_t ex_mem_scoreboard_data;
        ex_mem_scoreboard_data.instr_valid = fetch_pkt_i.valid;
        ex_mem_scoreboard_data.rob_ptr = fetch_pkt_i.rob_ptr;
        ex_mem_scoreboard_data.dest_valid = fetch_pkt_i.valid && (
            fetch_pkt_i.funct_unit_one_hot[ALU] || 
            (fetch_pkt_i.funct_unit_one_hot[MEM] && !fetch_pkt_i.store) || // load
            fetch_pkt_i.funct_unit_one_hot[JALR] || 
            fetch_pkt_i.funct_unit_one_hot[AUIPC]);
        // ex_mem_scoreboard_data.prf_ptr = fetch_pkt_i.dest_ptr;
        ex_mem_scoreboard_data.funct_unit_one_hot = fetch_pkt_i.funct_unit_one_hot;
        ex_mem_scoreboard_data.store = fetch_pkt_i.store;
        ex_mem_scoreboard_data.spec_exec_ptr = fetch_pkt_i.spec_exec_ptr;

        return ex_mem_scoreboard_data;
    endfunction


endpackage