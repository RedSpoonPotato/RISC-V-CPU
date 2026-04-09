
module writeback_stage #(
    parameter DATA_WIDTH = 32
) (
    input clk,
    input [30] instr_30_i,
    input [14:12] instr_14_12_i,

    // cntrls
    // input alu_cntrl_i, // how many bits?

    /*
        external comms
            master
                write to SB
                write to issue queue
            slave
                decode stage r/w for rob 
                commit stage r/w for rob
                commit stage r/w for fsb
    */
);
  
    // internal comms
    // write to ROB
    // write to FSB


endmodule

module reorder_buffer 
import writeback_pkg::*;
#(

) (
    input clk,
    input rst,
    input flush_i,

    // inputting a state from decode stage
    input rob_instance_pkt_t rob_instance_pkt_i,
    
    // updating state (coming from exec_mem stage)
    input writeback_packet_t ex_mem_stage_pkt_i,

    // commiting to arch file
    


);



endmodule
