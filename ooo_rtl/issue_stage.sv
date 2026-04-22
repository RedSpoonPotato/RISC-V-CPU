/*
    NEED TO ACCOUNT FOR:
    flushing
    stalling (maybe?)
    jalr: need to somewhere grab the pc value

    note: for format_20b_to_datawidth, might need to add more delay to not have hold time
    
*/
module issue_stage 
import decode_pkg::*;
import issue_queue_pkg::*;
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
    output fetch_packet_t fetch_pkt_o,
    output logic fetch_valid_o,
    // writeback
    input logic wb_dest_en_i,
    input logic [$clog2(PRF_COUNT)-1:0] wb_dest_ptr_i,
    input logic [DATA_WIDTH-1:0] wb_dest_data_i
);

    logic [DATA_WIDTH-1:0] phys_reg_src0_data;
    logic [DATA_WIDTH-1:0] phys_reg_src1_data;

    register_file_sync_read physical_register #(
        .DATA_WIDTH(DATA_WIDTH),
        .REG_ADDR_WIDTH($clog2(PRF_COUNT))
    ) (
        .clk(clk),
        .rst(rst),
        // reading
        .addr_r_1_i(instr_i.src0_ptr),
        .addr_r_2_i(instr_i.src1_ptr),
        .data_r_1_o(phys_reg_src0_data),
        .data_r_2_o(phys_reg_src1_data),
        // writing
        .write_en_i(wb_dest_en_i),
        .addr_w_i(wb_dest_ptr_i),
        .data_w_i(wb_dest_data_i),
    );

    // logic [DATA_WIDTH-1:0] imm;

    logic [IMM_COMPR_WIDTH-1:0] imm_compr_ff;
    logic [6:0] instr_op_ff;
    logic is_imm_ff;

    always_ff @(posedge clk) begin
        imm_compr_ff <= instr_i.imm_compr;
        instr_op_ff <= instr_i.op[6:0];

        // fetch_pkt_o.instr_valid = instr_i.instr_valid;
        fetch_valid_o           <= instr_valid_i;
        // fetch_pkt_o.func_unit_one_hot <= get_ex_mem_type_one_hot(instr_op_ff);
        fetch_pkt_o.funct_code  <= get_funct_comb(instr_i.op);
        // fetch_pkt_o.op          = instr_i.op;
        fetch_pkt_o.speculative <= instr_i.speculative;
        // is_store_ff <= instr_i.store;
        is_imm_ff <= instr_i.imm_valid;
        fetch_pkt_o.store       <= instr_i.store;
        // fetch_pkt_o.dest_valid  <= instr_i.dest_valid;
        fetch_pkt_o.dest_ptr    <= instr_i.dest_ptr;
        // fetch_pkt_o.src0_valid  <= instr_i.src0_valid;
        // fetch_pkt_o.src1_valid  <= instr_i.src1_valid;
        // imm <= format_20b_to_datawidth(instr_i.imm_compr, instr_i.op[6:0]);
        fetch_pkt_o.rob_ptr     <= instr_i.rob_ptr;
    end

    always_comb begin
        fetch_pkt_o.func_unit_one_hot = get_ex_mem_type_one_hot(instr_op_ff);
        fetch_pkt_o.src0_data   = phys_reg_src0_data;
        assert ((instr_i.imm_valid == 1 && instr_i.store == 1) || instr_i.store == 0);
        // fetch_pkt_o.src1_data   = phys_reg_src1_data;
        if (fetch_pkt_o.store || !is_imm_ff) begin
            fetch_pkt_o.src1_data = phys_reg_src1_data;
        end else begin
            fetch_pkt_o.src1_data = format_20b_to_datawidth(imm_compr_ff, instr_op_ff);
        end
        fetch_pkt_o.store_offset =  (fetch_pkt_o.store) ? format_20b_to_datawidth(imm_compr_ff, instr_op_ff) : 0;
    end

endmodule