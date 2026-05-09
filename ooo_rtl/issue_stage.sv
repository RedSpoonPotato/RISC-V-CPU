/*
    NEED TO ACCOUNT FOR:
    flushing
    stalling (maybe?)
    jalr: need to somewhere grab the pc value

    note: for format_20b_to_datawidth, might need to add more delay to not have hold time

    need to set pc value in fetch_pkt
    
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
    // input logic instr_valid_i,
    // external comms
    // writeback stage w for scoreboard
    /*
        external comms
            slave
                scoreboard w at writebackstage
    */
    // output
    output fetch_packet_t fetch_pkt_o,
    // output logic fetch_valid_o,
    // writeback
    // input logic wb_dest_en_i,
    // input logic [$clog2(PRF_COUNT)-1:0] wb_dest_ptr_i,
    // input logic [DATA_WIDTH-1:0] wb_dest_data_i
    input wb_phys_reg_pkt_t wb_phys_reg_pkt_i,
);

    iq_output_t instr_ff;
    // wb_phys_reg_pkt_t wb_phys_reg_pkt_ff; not gonna use b/c can save on flipflops while still functional
    always_ff @(posedge clk) begin
        instr_ff <= instr_i;
        // wb_phys_reg_pkt_ff <= wb_phys_reg_pkt_i;
    end


    logic [DATA_WIDTH-1:0] phys_reg_src0_data;
    logic [DATA_WIDTH-1:0] phys_reg_src1_data;

    register_file_sync_read physical_register #(
        .DATA_WIDTH(DATA_WIDTH),
        .REG_ADDR_WIDTH($clog2(PRF_COUNT))
    ) (
        .clk(clk),
        .rst(rst),
        // reading
        .addr_r_1_i(instr_ff.src0_ptr),
        .addr_r_2_i(instr_ff.src1_ptr),
        .data_r_1_o(phys_reg_src0_data),
        .data_r_2_o(phys_reg_src1_data),
        // writing
        .write_en_i(wb_phys_reg_pkt_i.wr_en),
        .addr_w_i(wb_phys_reg_pkt_i.dest_ptr),
        .data_w_i(wb_phys_reg_pkt_i.dest_data),
    );

    // logic [DATA_WIDTH-1:0] imm;

    logic [IMM_COMPR_WIDTH-1:0] imm_compr_ff;
    logic [6:0] instr_op_ff;
    logic is_imm_ff;

    // always_ff @(posedge clk) begin
    always_comb begin
        imm_compr_ff = instr_ff.imm_compr;
        instr_op_ff = instr_ff.op[6:0];

        // fetch_pkt_o.instr_valid = instr_ff.instr_valid;
        // fetch_valid_o           <= instr_valid_i;
        fetch_pkt_o.valid           = instr_ff.valid;
        fetch_pkt_o.funct_code  = get_funct_comb(instr_ff.op);
        // fetch_pkt_o.op          = instr_ff.op;
        fetch_pkt_o.speculative = instr_ff.speculative;
        // is_store_ff <= instr_ff.store;
        is_imm_ff = instr_ff.imm_valid;
        fetch_pkt_o.store       = instr_ff.store;
        // fetch_pkt_o.dest_valid  <= instr_ff.dest_valid;
        fetch_pkt_o.dest_ptr    = instr_ff.dest_ptr;
        // fetch_pkt_o.src0_valid  <= instr_ff.src0_valid;
        // fetch_pkt_o.src1_valid  <= instr_ff.src1_valid;
        // imm <= format_20b_to_datawidth(instr_ff.imm_compr, instr_ff.op[6:0]);
        fetch_pkt_o.rob_ptr     = instr_ff.rob_ptr;
    // end

    // always_comb begin
        fetch_pkt_o.funct_unit = get_ex_mem_type(instr_op_ff, fetch_pkt_o.valid);
        fetch_pkt_o.func_unit_one_hot = get_ex_mem_type_one_hot(instr_op_ff, fetch_pkt_o.valid);
        fetch_pkt_o.src0_data = phys_reg_src0_data;
        assert ((instr_ff.imm_valid == 1 && instr_ff.store == 1) || instr_ff.store == 0);
        // fetch_pkt_o.src1_data   = phys_reg_src1_data;
        if (fetch_pkt_o.store || !is_imm_ff) begin
            fetch_pkt_o.src1_data = phys_reg_src1_data;
        end else begin
            fetch_pkt_o.src1_data = format_20b_to_datawidth(imm_compr_ff, instr_op_ff);
        end
        fetch_pkt_o.mem_offset_or_brnch_imm =  (fetch_pkt_o.funct_unit == MEM || fetch_pkt_o.funct_unit == BRANCH) ? format_20b_to_datawidth(imm_compr_ff, instr_op_ff) : '0;
    end

endmodule