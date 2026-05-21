package core_pkg;
    parameter int INSTR_WIDTH = 32;
    parameter int DATA_WIDTH = 32;
    parameter int INSTR_MEM_DEPTH = 1024;
    parameter int BRANCH_STALL_CYCLES = 2;
    
    import instr_fetch_pkg::instr_fetch_ctrl_pkt_t;
    import instr_fetch_pkg::if_output_pkt_t;
    import instr_fetch_pkg::shift_reg_pkt_t;
    import writeback_pkg::commit_stage_pkt_t;
    import writeback_pkg::rt_and_iq_pending_update_pkt_t;
    import issue_queue_pkg::iq_output_t;
    import writeback_pkg::rob_instance_pkt_t;
    import instr_fetch_pkg::spec_exec_buffer_instance_pkt_t;
    import issue_queue_pkg::pc_buff_instance_pkt_t;
    import issue_queue_pkg::fetch_packet_t;
    import issue_queue_pkg::wb_phys_reg_pkt_t;
    import writeback_pkg::ex_mem_stage_pkt_t;
    import exec_mem_utils_pkg::spec_exec_answr_pkt_t;

endpackage
