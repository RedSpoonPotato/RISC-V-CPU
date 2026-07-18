/*
    NEED TO ACCOUNT FOR:
    flushing
    stalling (maybe?)
    jalr: need to somewhere grab the pc value

    note: for format_20b_to_datawidth, might need to add more delay to not have hold time

    need to set pc value in fetch_pkt

    
*/
module issue_stage 
import general_pkg::*;
import decode_pkg::*;
import issue_pkg::*;
(
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

    // from decode stage
    input pc_buff_instance_pkt_t buff_inst_i,
    // 
    // dont think i need
    // input logic [$clog2(MAX_PC_INSTRS)-1:0] rd_ptr_i
    // input logic pc_instr_i
    input logic exception_i,
    output logic stall_o
);

    iq_output_t instr_ff;
    // wb_phys_reg_pkt_t wb_phys_reg_pkt_ff; not gonna use b/c can save on flipflops while still functional
    pc_buff_instance_pkt_t buff_inst_ff;
    // logic exception_ff;
    always_ff @(posedge clk) begin
        instr_ff <= instr_i;
        buff_inst_ff <= buff_inst_i;
        // wb_phys_reg_pkt_ff <= wb_phys_reg_pkt_i;
        // exception_ff <= exception_i;
    end

    logic [DATA_WIDTH-1:0] phys_reg_src0_data;
    logic [DATA_WIDTH-1:0] phys_reg_src1_data;

    register_file_async_read #(
        .DATA_WIDTH(DATA_WIDTH),
        .REG_ADDR_WIDTH($clog2(PRF_COUNT))
    ) physical_register (
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
        .data_w_i(wb_phys_reg_pkt_i.dest_data)
    );

    logic [DATA_WIDTH-1:0] pc_out;
    pc_buffer pc_buff_inst
    (
        .clk(clk),
        .rst(rst),
        // write
        .buff_inst_i(buff_inst_ff),
        // read
        .is_pc_instr(instr_ff.pc_instr && instr_ff.valid && !exception_i),
        .rd_ptr_i(instr_ff.pc_buff_ptr),
        .pc_out_o(pc_out),
        .exception_i(exception_i),
        .full_o(stall_o)
    );


    // logic [DATA_WIDTH-1:0] imm;

    // logic [IMM_COMPR_WIDTH-1:0] imm_compr_ff;
    logic [IMM_COMPRESS-1:0] imm_compr_ff;
    logic [6:0] instr_op_ff;
    logic is_imm_ff;

    // always_ff @(posedge clk) begin
    always_comb begin
        imm_compr_ff = instr_ff.imm_compr;
        instr_op_ff = instr_ff.op[6:0];
        is_imm_ff = instr_ff.imm_valid;
        if (exception_i) begin
            fetch_pkt_o = '{funct_unit: NOOP, default: '0};
        end else begin
            fetch_pkt_o.valid           = instr_ff.valid;
            fetch_pkt_o.funct_code  = get_funct_comb(instr_ff.op);
            fetch_pkt_o.speculative = instr_ff.speculative;
            fetch_pkt_o.store       = instr_ff.store;
            fetch_pkt_o.dest_ptr    = instr_ff.dest_ptr;
            fetch_pkt_o.rob_ptr     = instr_ff.rob_ptr;
            fetch_pkt_o.spec_exec_ptr = instr_ff.spec_exec_ptr;
            fetch_pkt_o.mem_buff_ptr = instr_ff.mem_buff_ptr;
            fetch_pkt_o.pc = pc_out;
            fetch_pkt_o.funct_unit = get_ex_mem_type(instr_op_ff, fetch_pkt_o.valid);
            fetch_pkt_o.funct_unit_one_hot = get_ex_mem_type_one_hot(instr_op_ff, fetch_pkt_o.valid);
            fetch_pkt_o.src0_data = phys_reg_src0_data;
            // if (fetch_pkt_o.store || !is_imm_ff) begin
            if (fetch_pkt_o.store || !is_imm_ff || fetch_pkt_o.funct_unit == BRANCH) begin
                fetch_pkt_o.src1_data = phys_reg_src1_data;
            end else begin
                fetch_pkt_o.src1_data = format_20b_to_datawidth(imm_compr_ff, instr_op_ff);
            end
            fetch_pkt_o.mem_offset_or_brnch_imm = (fetch_pkt_o.funct_unit == MEM || fetch_pkt_o.funct_unit == BRANCH) ? format_20b_to_datawidth(imm_compr_ff, instr_op_ff) : '{default:'0};
            // assert ((instr_ff.imm_valid == 1 && instr_ff.store == 1) || instr_ff.store == 0);
        end
    end

    assert property (
        @(posedge clk) disable iff (rst || exception_i)
        ((instr_i.imm_valid == 1 && instr_i.store == 1) || instr_i.store == 0)
    );

endmodule

module pc_buffer 
import general_pkg::*;
import instr_fetch_pkg::*;
import issue_pkg::*;
(
    input clk,
    input rst,
    // write
    input pc_buff_instance_pkt_t buff_inst_i,
    // read
    input logic is_pc_instr,
    input logic [$clog2(MAX_PC_INSTRS)-1:0] rd_ptr_i,
    output logic [DATA_WIDTH-1:0] pc_out_o,
    input logic exception_i,
    output logic full_o
);
    logic [DATA_WIDTH-1:0] pc_buffer [MAX_PC_INSTRS-1:0];
    logic [$clog2(MAX_PC_INSTRS)-1:0] counter;

    always_ff @(posedge clk) begin
        if (rst || exception_i) begin
            pc_buffer <= '{default:'0};
            counter <= '0;
        end else begin
            if (buff_inst_i.wr_en) begin
                pc_buffer[buff_inst_i.wr_ptr] <= buff_inst_i.pc_in;
            end
            if (buff_inst_i.wr_en && !is_pc_instr) begin
                counter <= counter + 1;
            end else if (!buff_inst_i.wr_en && is_pc_instr) begin
                counter <= counter - 1;
            end
        end
    end
    
    assign full_o = counter == MAX_PC_INSTRS-1;

    logic empty;
    always_comb begin
        if (rd_ptr_i == buff_inst_i.wr_ptr) begin: Forwarding
            pc_out_o = buff_inst_i.pc_in;
        end else begin
            pc_out_o = pc_buffer[rd_ptr_i];
        end
        // debugging
        empty = counter == 0;
        // assert(!(empty && !buff_inst_i.wr_en && is_pc_instr));
    end

    assert property (
        @(posedge clk) disable iff (rst || exception_i)
        !(empty && !buff_inst_i.wr_en && is_pc_instr)
    );

endmodule
