module core #(

) (
    input clk,
    input rst,
    input instr_fetch_ctrl_pkt_t instr_fetch_ctrl_pkt_i
);
    // import global_params::*;
    
    logic decode_is_spec_instr;
    if_output_pkt_t instr_fetch_output_pkt;
    shift_reg_pkt_t commit_spec_exec_answr_pkt;
    instr_fetch_stage instr_fetch_stage_inst (
        .clk(clk),
        .rst(rst),
        .instr_fetch_ctrl_pkt_i(instr_fetch_ctrl_pkt_i),
        .is_spec_instr_i(decode_is_spec_instr),
        .if_output_pkt_o(instr_fetch_output_pkt),
        .spec_exec_answr_pkt_i(commit_spec_exec_answr_pkt)
    );

    commit_stage_pkt_t commit_decode_pkt;
    rt_and_iq_pending_update_pkt_t commit_rt_iq_update_pkt;
    iq_output_t decode_instr;
    rob_instance_pkt_t decode_rob_instance_pkt;
    logic decode_is_spec_instr;
    spec_exec_buffer_instance_pkt_t decode_spec_exec_buffer_instance_pkt;
    pc_buff_instance_pkt_t decode_pc_buff_inst;
    decode_stage decode_stage_inst (
        .clk(clk),
        .rst(rst),
        .flush_i(),
        .if_input_i(instr_fetch_output_pkt),
        .error_o(),
        .decode_commit_pkt_i(commit_decode_pkt), // For now(), will not use flipflops
        .rt_iq_update_pkt_i(commit_rt_iq_update_pkt),
        .exception_i(), // not sure if we need to flipflop this
        .decode_instr_o(decode_instr),
        .rob_instance_pkt_o(decode_rob_instance_pkt),
        .is_spec_instr_o(decode_is_spec_instr),
        .spec_exec_buffer_instance_pkt_o(decode_spec_exec_buffer_instance_pkt),
        .pc_buff_inst_o(decode_pc_buff_inst)
    );

    fetch_packet_t issue_fetch_pkt;
    wb_phys_reg_pkt_t writeback_phys_reg_pkt;
    issue_stage issue_stage_inst (
        .clk(clk),
        .rst(rst),
        .instr_i(decode_instr),
        .fetch_pkt_o(issue_fetch_pkt),
        .wb_phys_reg_pkt_i(writeback_phys_reg_pkt),
        .buff_inst_i(decode_pc_buff_inst),
    );

    ex_mem_stage_pkt_t exec_mem_stage_pkt;
    spec_exec_answr_pkt_t exec_mem_spec_exec_answr;
    execute_memory_stage execute_memory_stage_inst (
        .clk(clk),
        .rst(rst),
        .fetch_pkt_i(issue_fetch_pkt),
        .ex_mem_stage_pkt_o(exec_mem_stage_pkt),
        .spec_exec_answr_o(exec_mem_spec_exec_answr)
    );

    writeback_stage writeback_stage_inst (
        .clk(clk),
        .rst(rst),
        .flush_i(),
        .rob_instance_pkt_i(decode_rob_instance_pkt),
        .ex_mem_stage_pkt_i(exec_mem_stage_pkt),
        .commit_stage_pkt_o(commit_decode_pkt),
        .rob_full_o(),
        .wb_phys_reg_pkt_o(writeback_phys_reg_pkt),
        .rt_iq_update_pkt_o(commit_rt_iq_update_pkt),
        .spec_exec_buffer_instance_pkt_i(decode_spec_exec_buffer_instance_pkt),
        .spec_exec_answr_i(exec_mem_spec_exec_answr),
        .seab_full_o(),
        .spec_exec_answr_pkt_o(commit_spec_exec_answr_pkt)
    );

endmodule