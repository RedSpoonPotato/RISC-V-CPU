module issue_stage 
// import decode_pkg::*;
import issue_queue_pkg::*;
import decode_pkg::*;
#(
        parameter DATA_WIDTH = 32,
    parameter PRF_COUNT,
) (
    input clk,
    input rst,

    // input [INSTR_WIDTH-1:0] instr_i,
    input iq_output_t instr_i,
    input logic instr_valid_i,
    // external comms
    // writeback stage w for scoreboard
    /*
        external comms
            slave
                scoreboard w at writebackstage
    */
    // output 
    output fetch_packet_t fetch_o,
    output logic fetch_out_valid_o,
    // writeback
    input logic wb_dest_en_i,
    input logic [$clog2(PRF_COUNT)-1:0] wb_dest_ptr_i,
    input logic [DATA_WIDTH-1:0] wb_dest_data_i
);



endmodule