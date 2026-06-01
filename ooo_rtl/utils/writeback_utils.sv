package writeback_pkg;

    import general_pkg::*;
    export general_pkg::*;



    // localparam IQ_SIZE = 16;
    // localparam ROB_COUNT = 32;
    // localparam PRF_COUNT = 32;
    // localparam INSTR_COMPRESS_WIDTH = 17;
    // localparam MAX_EXEC_CYCLE = 4;
    // localparam IMM_COMPRESS = 20;

    typedef struct packed {
        logic wr_en;
        logic speculative;
        logic store;
        logic mem_op;
        logic dest_valid;
        logic [$clog2(PRF_COUNT)-1:0] phys_reg_addr;
        logic [4:0] arch_reg_addr;
        logic [$clog2(PRF_COUNT)-1:0] prev_phys_reg_addr;
        // logic [$clog2(ROB_COUNT)-1:0] rob_count;
    } rob_instance_pkt_t;


    typedef struct packed {
        logic instr_valid;
        // logic [$clog2(MAX_EXEC_CYCLE)-1:0] exec_dur; // unsure if we need to output this
        logic [$clog2(ROB_COUNT)-1:0] rob_ptr;
        logic dest_valid;
        logic [DATA_WIDTH-1:0] dest_data;
        // logic [4:0] arch_reg_addr; // why do i have this?
    } ex_mem_stage_pkt_t;

    typedef enum logic [$clog2(3)-1:0] {FREE, PENDING, FINISHED} rob_state_t;

    typedef struct packed {
        rob_state_t state;
        logic speculative;
        logic store;
        logic mem_op;
        logic dest_valid;
        logic [$clog2(PRF_COUNT)-1:0] phys_reg_addr;
        logic [4:0] arch_reg_addr;
        logic [$clog2(PRF_COUNT)-1:0] prev_phys_reg_addr;
        // logic [$clog2(ROB_COUNT)-1:0] rob_count;
    } rob_entry_t;

    typedef struct packed {
        logic wr_en;
        logic [$clog2(PRF_COUNT)-1:0] prf_ptr;
        logic [4:0] arf_ptr;
    } rt_and_iq_pending_update_pkt_t;

    // might not need all of these 
    typedef struct packed {
        logic wr_en;
        logic speculative;
        logic store;
        logic mem_op;
        logic dest_valid;
        logic [$clog2(PRF_COUNT)-1:0] phys_reg_addr;
        logic [4:0] arch_reg_addr;
        logic [$clog2(PRF_COUNT)-1:0] prev_phys_reg_addr;
    } commit_stage_pkt_t;

    typedef struct packed {
        logic en;
        logic [DATA_WIDTH-1:0] pc;
    } mem_addr_conflict_pkt_t;

    typedef struct packed {
        logic en;
        logic [DATA_WIDTH-1:0] addr;
        logic [DATA_WIDTH-1:0] data;
    } store_buffer_commit_pkt_t;
    
    function automatic rob_entry_t rob_instantiation (
        input rob_instance_pkt_t rob_instance_pkt_i
    );
        rob_entry_t rob_entry;
        rob_entry.speculative = rob_instance_pkt_i.speculative;
        rob_entry.store = rob_instance_pkt_i.store;
        rob_entry.mem_op = rob_instance_pkt_i.mem_op;
        rob_entry.dest_valid = rob_instance_pkt_i.dest_valid;
        rob_entry.phys_reg_addr = rob_instance_pkt_i.phys_reg_addr;
        rob_entry.arch_reg_addr = rob_instance_pkt_i.arch_reg_addr;
        rob_entry.prev_phys_reg_addr = rob_instance_pkt_i.prev_phys_reg_addr;
        return rob_entry;
    endfunction

    function automatic commit_stage_pkt_t set_commit_pkt (
        input rob_entry_t rob_entry_i
    );
        commit_stage_pkt_t commit_pkt;
        commit_pkt.wr_en = 1;
        commit_pkt.speculative = rob_entry_i.speculative;
        commit_pkt.store = rob_entry_i.store;
        commit_pkt.mem_op = rob_entry_i.mem_op;
        commit_pkt.dest_valid = rob_entry_i.dest_valid;
        commit_pkt.phys_reg_addr = rob_entry_i.phys_reg_addr;
        commit_pkt.arch_reg_addr = rob_entry_i.arch_reg_addr;
        commit_pkt.prev_phys_reg_addr = rob_entry_i.prev_phys_reg_addr;
        return commit_pkt;
    endfunction
        
    function automatic shift_reg_pkt_t set_wb_shift_reg_pkt (
        input spec_exec_answr_pkt_t spec_exec_answr_i
    );
        shift_reg_pkt_t out_pkt;
        out_pkt.trgt_en = 1'b1;
        out_pkt.trgt = spec_exec_answr_i.calc_pc;
        out_pkt.branch_en = spec_exec_answr_i.branch_en;
        out_pkt.branch_pred = spec_exec_answr_i.branch_taken;
        return out_pkt;
    endfunction

endpackage
