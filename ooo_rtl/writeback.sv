
module writeback_stage #(
    parameter DATA_WIDTH = 32,
    parameter INSTR_WIDTH = 32,

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
