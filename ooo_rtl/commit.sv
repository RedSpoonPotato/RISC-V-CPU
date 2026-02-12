
module commit_stage #(
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
                rob r/w 
                fsb r/w
                rt r/w                
            slave
                arf r from decode stage
    */

);
    // internal comms
    // write to ARF


endmodule
