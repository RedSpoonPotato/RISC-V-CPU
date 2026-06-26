/*
    For now, will disable "instr_fetch_ctrl_pkt_i" port for easy synthesis.
    Later, will make a higher module containing core module that also is built for axi master interface to access DDR memory on soc.

    Change addr offsets in general_utils.sv!!
*/

module core 
import core_pkg::*;
(
    input clk,
    input rst,
    // input instr_fetch_ctrl_pkt_t instr_fetch_ctrl_pkt_i
    // for getting proper synth results without moudles getting optmized away
    output commit_stage_pkt_t commit_decode_pkt 
);

    // temp, remove later when wanting to implement proper memmory acccesses, or if you decide to have it entirely made of brams
    instr_fetch_ctrl_pkt_t instr_fetch_ctrl_pkt_i;
    always_comb begin
        instr_fetch_ctrl_pkt_i = '{default: '0};
    end

    logic decode_stall;
    logic issue_stall;
    logic wb_stall;
    logic stall;
    assign stall = decode_stall && issue_stall && wb_stall;
    
    logic decode_is_spec_instr;
    if_output_pkt_t instr_fetch_output_pkt;
    shift_reg_pkt_t commit_spec_exec_answr_pkt;
    logic instr_fetch_exception;
    mem_addr_conflict_pkt_t writeback_mem_addr_conflict_pkt;
    instr_fetch_stage instr_fetch_stage_inst (
        .clk(clk),
        .rst(rst),
        .instr_fetch_ctrl_pkt_i(instr_fetch_ctrl_pkt_i),
        .is_spec_instr_i(decode_is_spec_instr),
        .if_output_pkt_o(instr_fetch_output_pkt),
        .spec_exec_answr_pkt_i(commit_spec_exec_answr_pkt),
        .exception_o(instr_fetch_exception),
        .stall_i(stall),
        .mem_addr_conflict_pkt_i(writeback_mem_addr_conflict_pkt)
    );

    // commit_stage_pkt_t commit_decode_pkt; // RESTORE LATER
    rt_and_iq_pending_update_pkt_t commit_rt_iq_update_pkt;
    iq_output_t decode_instr;
    rob_instance_pkt_t decode_rob_instance_pkt;
    spec_exec_buffer_instance_pkt_t decode_spec_exec_buffer_instance_pkt;
    pc_buff_instance_pkt_t decode_pc_buff_inst;
    logic decode_mem_buff_wr_en;
    decode_stage decode_stage_inst (
        .clk(clk),
        .rst(rst),
        .if_input_i(instr_fetch_output_pkt),
        .decode_commit_pkt_i(commit_decode_pkt), // For now(), will not use flipflops
        .rt_iq_update_pkt_i(commit_rt_iq_update_pkt),
        .decode_instr_o(decode_instr),
        .rob_instance_pkt_o(decode_rob_instance_pkt),
        .is_spec_instr_o(decode_is_spec_instr),
        .spec_exec_buffer_instance_pkt_o(decode_spec_exec_buffer_instance_pkt),
        .pc_buff_inst_o(decode_pc_buff_inst),
        .mem_buff_wr_en_o(decode_mem_buff_wr_en),
        .exception_i(instr_fetch_exception),
        .stall_o(decode_stall)
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
        .exception_i(instr_fetch_exception),
        .stall_o(issue_stall)
    );

    ex_mem_stage_pkt_t exec_mem_stage_pkt;
    spec_exec_answr_pkt_t exec_mem_spec_exec_answr;
    mem_addr_pkt_t mem_op_addr_pkt;
    store_buffer_commit_pkt_t store_buffer_commit_pkt;
    execute_memory_stage execute_memory_stage_inst (
        .clk(clk),
        .rst(rst),
        .fetch_pkt_i(issue_fetch_pkt),
        .ex_mem_stage_pkt_o(exec_mem_stage_pkt),
        .spec_exec_answr_o(exec_mem_spec_exec_answr),
        .exception_i(instr_fetch_exception),
        .mem_addr_pkt_o(mem_op_addr_pkt),
        .store_buffer_commit_pkt_i(store_buffer_commit_pkt)
    );


    writeback_stage writeback_stage_inst (
        .clk(clk),
        .rst(rst),
        .rob_instance_pkt_i(decode_rob_instance_pkt),
        .ex_mem_stage_pkt_i(exec_mem_stage_pkt),
        .commit_stage_pkt_o(commit_decode_pkt),
        .wb_phys_reg_pkt_o(writeback_phys_reg_pkt),
        .rt_iq_update_pkt_o(commit_rt_iq_update_pkt),
        .spec_exec_buffer_instance_pkt_i(decode_spec_exec_buffer_instance_pkt),
        .spec_exec_answr_i(exec_mem_spec_exec_answr),
        .spec_exec_answr_pkt_o(commit_spec_exec_answr_pkt),
        .exception_i(instr_fetch_exception),
        .stall_o(wb_stall),
        .mem_buff_wr_en_i(decode_mem_buff_wr_en),
        .mem_addr_pkt_i(mem_op_addr_pkt),
        .mem_addr_conflict_pkt_o(writeback_mem_addr_conflict_pkt),
        .store_buffer_commit_pkt_o(store_buffer_commit_pkt)
    );

endmodule