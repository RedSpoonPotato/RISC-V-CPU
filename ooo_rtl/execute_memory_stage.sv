/*
    for now, will implement a single cycle load and store (will change later)

    // disclaimer: ai generated the ALU module b/c its boiler plate

    note: for all stages, might need to add extra inputs for information required for
        other stages

    note: need ot got back to issue_utils and account for pc_plus_4 in fetch_packet_t

    Need to edit mem stage to account for differetn sizes
*/

module execute_memory_stage 
import exec_mem_utils_pkg::*;
import issue_queue_pkg::*;
import writeback_pkg::*;
import instr_fetch_pkg::*;
#(
    parameter DATA_WIDTH = 32
) (
    input clk,
    input rst,

    input fetch_packet_t fetch_pkt_i, 
    // input logic fetch_valid_i, // might not need

    // output to writeback stage
    output ex_mem_stage_pkt_t ex_mem_stage_pkt_o,

    // output to IF stage
    output spec_exec_answr_pkt_t spec_exec_answr_o;

    // for updating pending bits in decode stage
    output rename_table_and_issue_queue_update_pkt_t rt_iq_update_pkt_o
);

    fetch_packet_t fetch_pkt_ff;
    always_ff @(posedge clk) begin
        fetch_pkt_ff <= fetch_pkt_i;
    end
    
    assert (fetch_pkt_ff.valid || fetch_pkt_ff.funct_unit == NOOP) else $fatal("Invalid instruction issued to execute stage");

    // routing instruction
    EX_MEM_TYPE scoreboard_curr_funct_unit_output;
    EX_MEM_TYPE scoreboard_clear; // NEED TO SET

    ex_mem_scoreboard_data_t ex_mem_scoreboard_data_new, ex_mem_scoreboard_data_o;
    assign ex_mem_scoreboard_data_new = set_ex_mem_scoreboard_data(fetch_pkt_ff);

    funct_unit_scoreboard scoreboard_inst (
        .clk(clk),
        .rst(rst),
        .funct_unit_i(fetch_pkt_ff.funct_unit),
        .sb_data_pkt_i(ex_mem_scoreboard_data_new),
        .current_funct_unit_output_o(scoreboard_curr_funct_unit_output),
        .sb_data_pkt_o(ex_mem_scoreboard_data_o),
        .clear_i(scoreboard_clear) // will connect this later
    );

    // alu, mem, jalr, auipc
    logic [DATA_WIDTH-1:0] result_arry [3:0];

    // alu path (1 cycle)
    logic [DATA_WIDTH-1:0] alu_result;
    logic alu_zero;
    alu_stage alu_stage_inst (
        .clk(clk),
        .rst(rst),
        .en_i(fetch_pkt_ff.funct_unit_one_hot[ALU]),
        .a_i(fetch_pkt_ff.src0_data),
        .b_i(fetch_pkt_ff.src1_data),
        .funct_code_i(fetch_pkt_ff.funct_code),
        .result_o(result_arry[0]),
        .zero_o(alu_zero)
    );
    
    // mem path (atleast 2 cycles: add, then memory access)
    // logic [DATA_WIDTH-1:0] mem_load_data;
    mem_stage mem_stage_inst (
        .clk(clk),
        .rst(rst),
        .en_i(fetch_pkt_ff.funct_unit_one_hot[MEM]),
        .store_i(fetch_pkt_ff.store),
        .funct_code_i(fetch_pkt_ff.funct_code),
        .base_addr_i(fetch_pkt_ff.src0_data),
        .offset_i(fetch_pkt_ff.mem_offset_or_brnch_imm), // for now, just using imm_compr as offset, will change later
        .store_data_i(fetch_pkt_ff.src1_data), // for store instructions
        .load_data_o(result_arry[1]) // will connect this to writeback stage later
    );


    // branch path (1 cycle for now): if(rs1 == rs2) PC += imm
    logic [DATA_WIDTH-1:0] brnch_trgt;
    branch_stage branch_stage_inst (
        .clk(clk),
        .rst(rst),
        .en_i(fetch_pkt_ff.funct_unit_one_hot[BRANCH]),
        .funct_code_i(fetch_pkt_ff.funct_code),
        .src0_data_i(fetch_pkt_ff.src0_data),
        .src1_data_i(fetch_pkt_ff.src1_data),
        .pc_i(fetch_pkt_ff.pc),
        .imm_i(fetch_pkt_ff.mem_offset_or_brnch_imm),
        .branch_taken_o(spec_exec_answr_o.branch_taken),
        .trgt_o(brnch_trgt)
    );

    // jalr path: rd = PC+4; PC = rs1 + imm
    logic [DATA_WIDTH-1:0] jump_trgt;
    jalr_stage jalr_stage_inst (
        .clk(clk),
        .rst(rst),
        .en_i(fetch_pkt_ff.funct_unit_one_hot[JALR]),
        .funct_code_i(fetch_pkt_ff.funct_code),
        .pc_i(fetch_pkt_ff.pc),
        .rs1_data_i(fetch_pkt_ff.src0_data),
        .imm_i(fetch_pkt_ff.src1_data),
        .pc_o(jump_trgt), // will connect this to writeback stage later
        .pc_plus_4_o(result_arry[2])
    );

    // auipc path: rd = PC + (imm << 12)
    // logic [DATA_WIDTH-1:0] auipc_result;
    auipc_stage auipc_stage_inst (
        .clk(clk),
        .rst(rst),
        .en_i(fetch_pkt_ff.funct_unit_one_hot[AUIPC]),
        .pc_i(fetch_pkt_ff.pc),
        .imm_i(fetch_pkt_ff.src1_data), // for now, just using imm_compr as imm, will change later
        .result_o(result_arry[3]) // will connect this to writeback stage later
    );

    logic [EX_MEM_TYPE_SIZE-1:0] funct_unit_one_hot_o;
    logic store_o;

    always_comb begin: intermediate_signals
        funct_unit_one_hot_o = ex_mem_scoreboard_data_o.funct_unit_one_hot;
        store_o = ex_mem_scoreboard_data_o.store;
    end

    always_comb begin: setting_ex_mem_stage_pkt_o
        ex_mem_stage_pkt_o.instr_valid = ex_mem_scoreboard_data_o.instr_valid;
        ex_mem_stage_pkt_o.rob_ptr = ex_mem_scoreboard_data_o.rob_ptr;
        ex_mem_stage_pkt_o.dest_valid = ex_mem_scoreboard_data_o.dest_valid;
        if (funct_unit_one_hot_o[ALU]) begin
            ex_mem_stage_pkt_o.dest_data = result_arry[0];
        end else if (funct_unit_one_hot_o[MEM] && !store_o) begin
            ex_mem_stage_pkt_o.dest_data = result_arry[1];
        end else if (funct_unit_one_hot_o[JALR]) begin
            ex_mem_stage_pkt_o.dest_data = result_arry[2];
        end else if (funct_unit_one_hot_o[AUIPC]) begin
            ex_mem_stage_pkt_o.dest_data = result_arry[3];
        end else begin
            ex_mem_stage_pkt_o.dest_data = '0;
        end
    end
        
    always_comb begin: setting_spec_exec_answr_o
        spec_exec_answr_o.trgt_en = funct_unit_one_hot_o[JALR] || funct_unit_one_hot_o[BRANCH];
        spec_exec_answr_o.branch_en = funct_unit_one_hot_o[BRANCH];
        if (funct_unit_one_hot_o[BRANCH]) begin
            spec_exec_answr_o.calc_pc = brnch_trgt;
        end else if (funct_unit_one_hot_o[JALR]) begin
            spec_exec_answr_o.calc_pc = jump_trgt;
        end else begin
            spec_exec_answr_o.calc_pc = '0;
        end
    end

    always_comb begin: setting_rt_iq_update_pkt_o
        rt_iq_update_pkt_o.wr_en = ex_mem_scoreboard_data_o.dest_valid;
        rt_iq_update_pkt_o.prf_ptr = ex_mem_scoreboard_data_o.prf_ptr;
    end
            
endmodule

module funct_unit_scoreboard
import issue_queue_pkg::*;
import exec_mem_utils_pkg::*;
(
    input clk,
    input rst,
    // new entry
    input EX_MEM_TYPE funct_unit_i,
    // input ex_mem_stage_pkt_t ex_mem_stage_pkt_i,
    input ex_mem_scoreboard_data_t sb_data_pkt_i,
    // outputting to iq
    // 1 extra: 1 for reg fetch stage
    output EX_MEM_TYPE current_funct_unit_output_o,
    output ex_mem_scoreboard_data_t sb_data_pkt_o,
    // stalling or clearing
    input clear_i, // same functionality as rst
);
    EX_MEM_TYPE exec_stage_slots_int [MAX_EXEC_CYCLE_V2-2:0];
    ex_mem_scoreboard_data_t ex_mem_scoreboard_data_slots [MAX_EXEC_CYCLE_V2-2:0];

    logic [] new_op_delay = get_exec_stage_delays_v2(funct_unit_i);

    always_ff @(posedge clk) begin
        if (rst || clear_i) begin
            exec_stage_slots_int <= '{default: NOOP};
            ex_mem_scoreboard_data_slots <= '{default: '0};
        end else begin
            for (int i = MAX_EXEC_CYCLE_V2-2; i >= 0; i--) begin
                if (i == MAX_EXEC_CYCLE_V2-2) begin
                    exec_stage_slots_int[i] <= NOOP;
                    ex_mem_scoreboard_data_slots[i] <= '0;
                end else begin
                    exec_stage_slots_int[i] <= exec_stage_slots_int[i+1];
                    ex_mem_scoreboard_data_slots[i] <= ex_mem_scoreboard_data_slots[i+1];
                end
            end
            if (funct_unit_i != NOOP && new_op_delay > 0) begin // not for ALU which has delay of 1 (new_op_delay == 0)
                // should actually be get_exe_stage_delays.. minus 1
                exec_stage_slots_int[new_op_delay-1] <= funct_unit_i;
                ex_mem_scoreboard_data_slots[new_op_delay-1] <= sb_data_pkt_i;
            end
        end
    end

    always_comb begin
        if (new_op_delay == 0 && funct_unit_i != NOOP) begin
            current_funct_unit_output_o = funct_unit_i;
            sb_data_pkt_o = sb_data_pkt_i;
            assert(exec_stage_slots_int[0] == NOOP) else $fatal("Scoreboard error: new instruction issued to occupied exec stage slot");
        end else begin
            current_funct_unit_output_o = exec_stage_slots_int[0];
            sb_data_pkt_o = ex_mem_scoreboard_data_slots[0];
        end
        
    end

endmodule


module auipc_stage
import issue_queue_pkg::*;
(
    input logic en_i,
    input logic [DATA_WIDTH-1:0] pc_i,
    input logic [DATA_WIDTH-1:0] imm_i,
    output logic [DATA_WIDTH-1:0] result_o
);
    logic [DATA_WIDTH-1:0] pc;
    logic [DATA_WIDTH-1:0] imm;

    always_comb begin
        if (en_i) begin
            pc = pc_i;
            imm = imm_i;
        end else begin
            pc = '0;
            imm = '0;
        end
    end

    assign result_o = pc + (imm << 12);
endmodule

module jalr_stage
import issue_queue_pkg::*;
(
    input logic en_i,
    input logic [DATA_WIDTH-1:0] pc_i,
    input logic [FUNCT_COMB_WIDTH-1:0] funct_code_i,
    input logic [DATA_WIDTH-1:0] rs1_data_i,
    input logic [DATA_WIDTH-1:0] imm_i,
    output logic [DATA_WIDTH-1:0] pc_o,
    output logic [DATA_WIDTH-1:0] pc_plus_4_o
);

    logic [DATA_WIDTH-1:0] pc;
    logic [DATA_WIDTH-1:0] rs1_data;
    logic [DATA_WIDTH-1:0] imm;
    kogic [FUNCT_COMB_WIDTH-1:0] funct_code;

    always_comb begin
        if (en_i) begin
            pc = pc_i;
            rs1_data = rs1_data_i;
            imm = imm_i;
            funct_code = funct_code_i;
        end else begin
            pc = '0;
            rs1_data = '0;
            imm = '0;
            funct_code = '0;
        end
    end

    always_comb begin
        if (funct_code[3] == 1'b1) begin: Jal
            pc_o = rs1_data + imm;
        end else begin: Jalr
            pc_o = pc + imm;
        end
        pc_plus_4_o = pc + 4;
    end
endmodule

module branch_unit
import issue_queue_pkg::*;
(
    input logic [FUNCT_COMB_WIDTH-1:0] funct_code_i,
    input logic [DATA_WIDTH-1:0] src0_data_i,
    input logic [DATA_WIDTH-1:0] src1_data_i,
    output logic branch_taken_o
);
    localparam BEQ  = 4'b0000;
    localparam BNE  = 4'b0001;
    localparam BLT  = 4'b0100;
    localparam BGE  = 4'b0101;
    localparam BLTU = 4'b0110;
    localparam BGEU = 4'b0111;

    always_comb begin
        case (funct_code_i)
            BEQ:  branch_taken_o = (src0_data_i == src1_data_i);
            BNE:  branch_taken_o = (src0_data_i != src1_data_i);
            BLT:  branch_taken_o = ($signed(src0_data_i) < $signed(src1_data_i));
            BGE:  branch_taken_o = ($signed(src0_data_i) >= $signed(src1_data_i));
            BLTU: branch_taken_o = (src0_data_i < src1_data_i);
            BGEU: branch_taken_o = (src0_data_i >= src1_data_i);
            default: branch_taken_o = 0;
        endcase
    end
endmodule

// branch: doing comparison, trgt address is done in decode stage, or even in IF 2nd stage
module branch_stage
import issue_queue_pkg::*;
(
    input logic en_i,
    input logic [FUNCT_COMB_WIDTH-1:0] funct_code_i,
    input logic [DATA_WIDTH-1:0] src0_data_i,
    input logic [DATA_WIDTH-1:0] src1_data_i,
    input logic [DATA_WIDTH-1:0] pc_i,
    input logic [DATA_WIDTH-1:0] imm_i,
    output logic branch_taken_o,
    output logic [DATA_WIDTH-1:0] trgt_o
);

    logic [DATA_WIDTH-1:0] src0_data, src1_data, imm, pc;
    logic [FUNCT_COMB_WIDTH-1:0] funct_code;

    branch_unit branch_unit_inst (
        .funct_code_i(funct_code),
        .src0_data_i(src0_data),
        .src1_data_i(src1_data),
        .branch_taken_o(branch_taken_o)
    );

    assign trgt_o = pc + imm;

    always_comb begin
        if (en_i) begin
            src0_data <= src0_data_i;
            src1_data <= src1_data_i;
            funct_code <= funct_code_i;
            imm <= imm_i;
            pc <= pc_i;
        end else begin
            src0_data <= 0;
            src1_data <= 0;
            funct_code <= 0;
            imm <= 0;
            pc <= 0;            
        end
    end

endmodule


// for now doing a simple memory, 2 cycles
module mem_stage 
import issue_queue_pkg::*;
import decode_pkg::*;
(
    input clk,
    // input rst,
    input logic en_i,
    input logic store_i,
    input logic [FUNCT_COMB_WIDTH-1:0] funct_code_i,
    input logic [DATA_WIDTH-1:0] base_addr_i,
    input logic [DATA_WIDTH-1:0] offset_i,
    input logic [DATA_WIDTH-1:0] store_data_i,
    output logic [DATA_WIDTH-1:0] load_data_o
);

    logic [DATA_WIDTH-1:0] base_addr, offset, store_data, addr;

    assign addr = base_addr + offset;

    always_comb begin
        if (en_i) begin
            base_addr = base_addr_i;
            offset = offset_i;
            store_data = store_data_i;
        end else begin
            base_addr = '0;
            offset = '0;
            store_data = '0;
        end
    end

    sram_sync_read #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(10) // for now, hardcoding to 10 bits (1024 entries)
    ) data_memory (
        .clk(clk),
        .we(en_i && store_i),
        .addr(addr),
        .din(store_data),
        .dout(load_data_o)
    );
endmodule

module alu #(
    parameter DATA_WIDTH = 32,
) (
    input  [DATA_WIDTH-1:0] a_i,
    input  [DATA_WIDTH-1:0] b_i
    input  [3:0]  alu_cntrl_i,
    output logic [DATA_WIDTH-1:0] result_o,
    output logic zero_o
);
    // RV32I opcodes
    localparam ADD  = 4'b0000;
    localparam SUB  = 4'b1000;
    localparam XOR  = 4'b0100;
    localparam OR   = 4'b0110;
    localparam AND  = 4'b0111;
    localparam SLL  = 4'b0001;
    localparam SRL  = 4'b0101;
    localparam SRA  = 4'b1101;
    localparam SLT  = 4'b0010;
    localparam SLTU = 4'b0011;

    always_comb begin
        case (alu_cntrl_i)
            // RV32I
            ADD:  result_o = a_i + b_i;
            SUB:  result_o = a_i - b_i;
            AND:  result_o = a_i & b_i;
            OR:   result_o = a_i | b_i;
            XOR:  result_o = a_i ^ b_i;
            SLL:  result_o = a_i << b_i[4:0];
            SRL:  result_o = a_i >> b_i[4:0];
            SRA:  result_o = $signed(a_i) >>> b_i[4:0];
            SLT:  result_o = ($signed(a_i) < $signed(b_i)) ? DATA_WIDTH'd1 : DATA_WIDTH'd0;
            SLTU: result_o = (a_i < b_i) ? DATA_WIDTH'd1 : DATA_WIDTH'd0;

            // will add rest of rv32m instructions later
            default:  result_o = DATA_WIDTH'b010;
        endcase
    end
    // The Zero flag is asserted if the result_o is all zeros.
    assign zero_o = (result_o == DATA_WIDTH'b0);

endmodule

module alu_stage #(
    parameter DATA_WIDTH = 32,
) (
    input  en_i,
    input  [DATA_WIDTH-1:0] a_i,
    input  [DATA_WIDTH-1:0] b_i,
    input logic [FUNCT_COMB_WIDTH-1:0] funct_code_i,
    output logic [DATA_WIDTH-1:0] result_o,
    output logic zero_o
);

    // logic [DATA_WIDTH-1:0] a, b;
    // logic [4:0] alu_cntrl;

    alu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) alu_inst (
        .a_i(a),
        .b_i(b),
        .alu_cntrl_i(alu_cntrl),
        .result_o(result_o),
        .zero_o(zero_o)
    );

    // always_ff @(posedge clk) begin
    //     if (rst || !en_i) begin
    //         a <= 0;
    //         b <= 0;
    //         alu_cntrl <= 0;
    //     end else begin
    //         a <= a_i;
    //         b <= b_i;
    //         alu_cntrl <= funct_code_i;
    //     end
    // end
    always_comb begin
        if (en_i) begin
            a = a_i;
            b = b_i;
            alu_cntrl = funct_code_i;
        end else begin
            a = 0;
            b = 0;
            alu_cntrl = 0;
        end
    end

endmodule


