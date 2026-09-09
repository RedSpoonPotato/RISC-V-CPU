/*
    for now, will implement a single cycle load and store (will change later)

    // disclaimer: ai generated the ALU module b/c its boiler plate

    note: for all stages, might need to add extra inputs for information required for
        other stages

    note: need ot got back to issue_utils and account for pc_plus_4 in fetch_packet_t

    Need to edit mem stage to account for differetn sizes

    go back to funct_unit_scoreboard uprorerly desifined function, see exec_mem_utils.sv

    did we implement the different mem access sizes (byte, half word, word)

    implement store buffer in order to handle spec execution (need to send exception signal into mem stage, 
    unless store buffer is in wb stage)

*/

module execute_memory_stage 
import exec_mem_pkg::*;
import decode_pkg::*;
import writeback_pkg::*;
import instr_fetch_pkg::*;
import issue_pkg::*;
(
    input clk,
    input rst,

    input fetch_packet_t fetch_pkt_i, 
    // input logic fetch_valid_i, // might not need

    // output to writeback stage
    output ex_mem_stage_pkt_t ex_mem_stage_pkt_o,

    // output to wb stage
    output spec_exec_answr_pkt_t spec_exec_answr_o,

    // for updating pending bits in decode stage
    // output rename_table_and_issue_queue_update_pkt_t rt_iq_update_pkt_o
    input logic exception_i,

    // input logic mem_buff_wr_en_i,
    output mem_addr_pkt_t mem_addr_pkt_o,
    input store_buffer_commit_pkt_t store_buffer_commit_pkt_i,

    // not sure if should be Flipfloped
    input lsq_instantiation_pkt_t lsq_instant_pkt_i,
);

    fetch_packet_t fetch_pkt_ff;
    // logic exception_ff;
    always_ff @(posedge clk) begin
        fetch_pkt_ff <= fetch_pkt_i;
        // exception_ff <= exception_i;
        // assert (fetch_pkt_ff.valid || fetch_pkt_ff.funct_unit == NOOP) else $fatal("Invalid instruction issued to execute stage");
    end

    assert property (
        @(posedge clk) disable iff (rst || exception_i)
        (fetch_pkt_i.valid || fetch_pkt_i.funct_unit == NOOP)
    ) else $fatal("Invalid instruction issued to execute stage");

    // routing instruction
    ex_mem_scoreboard_data_t ex_mem_scoreboard_data_new, ex_mem_scoreboard_data_o;
    assign ex_mem_scoreboard_data_new = set_ex_mem_scoreboard_data(fetch_pkt_ff);

    funct_unit_scoreboard scoreboard_inst (
        .clk(clk),
        .rst(rst),
        .funct_unit_i(fetch_pkt_ff.funct_unit),
        .sb_data_pkt_i(ex_mem_scoreboard_data_new),
        // .current_funct_unit_output_o(scoreboard_curr_funct_unit_output),
        .sb_data_pkt_o(ex_mem_scoreboard_data_o),
        .exception_i(exception_i)
    );

    // alu, mem, jalr, auipc
    logic [DATA_WIDTH-1:0] result_arry [3:0];

    // alu path (1 cycle)
    logic [DATA_WIDTH-1:0] alu_result;
    logic alu_zero;
    alu_stage alu_stage_inst (
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
        .pc_i(fetch_pkt_ff.pc),
        .lsq_ptr_i(fetch_pkt_ff.lsq_ptr),
        .funct_code_i(fetch_pkt_ff.funct_code),
        .base_addr_i(fetch_pkt_ff.src0_data),
        .offset_i(fetch_pkt_ff.mem_offset_or_brnch_imm), // for now, just using imm_compr as offset, will change later
        .store_data_i(fetch_pkt_ff.src1_data), // for store instructions
        .data_o(result_arry[1]), // will connect this to writeback stage later
        .mem_addr_pkt_o(mem_addr_pkt_o),
        .store_buffer_commit_pkt_i(store_buffer_commit_pkt_i),
        .exception_i(exception_i),
        .lsq_instant_pkt_i(lsq_instant_pkt_i)
    );

    // branch path (1 cycle for now): if(rs1 == rs2) PC += imm
    logic [DATA_WIDTH-1:0] brnch_trgt;
    branch_stage branch_stage_inst (
        // .clk(clk),
        // .rst(rst),
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
    // also for jal: rd = PC+4; PC = PC + imm
    logic [DATA_WIDTH-1:0] jump_trgt;
    jalr_stage jalr_stage_inst (
        // .clk(clk),
        // .rst(rst),
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
        // .clk(clk),
        // .rst(rst),
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
        // end else if (funct_unit_one_hot_o[MEM] && !store_o) begin
        end else if (funct_unit_one_hot_o[MEM]) begin
            ex_mem_stage_pkt_o.dest_data = result_arry[1];
        end else if (funct_unit_one_hot_o[JALR]) begin
            ex_mem_stage_pkt_o.dest_data = result_arry[2];
        end else if (funct_unit_one_hot_o[AUIPC]) begin
            ex_mem_stage_pkt_o.dest_data = result_arry[3];
        end else begin
            ex_mem_stage_pkt_o.dest_data = '{default:'0};
        end
    end
        
    always_comb begin: setting_spec_exec_answr_o
        // spec_exec_answr_o.pc = fetch_pkt_ff.pc;
        spec_exec_answr_o.trgt_en = ex_mem_scoreboard_data_o.instr_valid &&
            (funct_unit_one_hot_o[JALR] || 
            funct_unit_one_hot_o[BRANCH]);
        // spec_exec_answr_o.trgt_en = funct_unit_one_hot_o[JALR] || funct_unit_one_hot_o[BRANCH];
        spec_exec_answr_o.branch_en = funct_unit_one_hot_o[BRANCH];
        if (funct_unit_one_hot_o[BRANCH]) begin
            spec_exec_answr_o.calc_pc = brnch_trgt;
        end else if (funct_unit_one_hot_o[JALR]) begin
            spec_exec_answr_o.calc_pc = jump_trgt;
        end else begin
            spec_exec_answr_o.calc_pc = '{default:'0};
        end
        spec_exec_answr_o.spec_exec_ptr = ex_mem_scoreboard_data_o.spec_exec_ptr;
    end

    // always_comb begin: setting_rt_iq_update_pkt_o
    //     rt_iq_update_pkt_o.wr_en = ex_mem_scoreboard_data_o.dest_valid;
    //     rt_iq_update_pkt_o.prf_ptr = ex_mem_scoreboard_data_o.prf_ptr;
    // end
            
endmodule

module funct_unit_scoreboard
import decode_pkg::*;
import exec_mem_pkg::*;
import issue_pkg::*;
(
    input clk,
    input rst,
    // new entry
    input EX_MEM_TYPE funct_unit_i,
    // input ex_mem_stage_pkt_t ex_mem_stage_pkt_i,
    input ex_mem_scoreboard_data_t sb_data_pkt_i,
    // outputting to iq
    // 1 extra: 1 for reg fetch stage
    // output EX_MEM_TYPE current_funct_unit_output_o,
    output ex_mem_scoreboard_data_t sb_data_pkt_o,
    // stalling or clearing
    input exception_i // same functionality as rst
);
    EX_MEM_TYPE exec_stage_slots_int [MAX_EXEC_CYCLE_DELAY-1:0];
    ex_mem_scoreboard_data_t ex_mem_scoreboard_data_slots [MAX_EXEC_CYCLE_DELAY-1:0];

    // COME BACK TO THIS FUNCTION AND SIZING, NOT PROPERLY SET YET
    logic [$clog2(MAX_EXEC_CYCLE_V2)-1:0] new_op_delay;
    
    assign new_op_delay = get_exec_stage_delays_v3(
        funct_unit_i, 
        sb_data_pkt_i.store
        );

    always_ff @(posedge clk) begin
        if (rst || exception_i) begin
            exec_stage_slots_int <= '{default: NOOP};
            ex_mem_scoreboard_data_slots <= '{default: '0};
        end else begin
            for (int i = MAX_EXEC_CYCLE_DELAY-1; i >= 0; i--) begin
                if (i == MAX_EXEC_CYCLE_DELAY-1) begin
                    exec_stage_slots_int[i] <= NOOP;
                    ex_mem_scoreboard_data_slots[i] <= '{default:'0};
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
        if (exception_i) begin
            // current_funct_unit_output_o = NOOP;
            sb_data_pkt_o = '{default: '0};
        end else if (new_op_delay == 0 && funct_unit_i != NOOP) begin: Forwarding
            // current_funct_unit_output_o = funct_unit_i;
            sb_data_pkt_o = sb_data_pkt_i;
            // assert(exec_stage_slots_int[0] == NOOP) else $fatal("Scoreboard error: new instruction issued to occupied exec stage slot");
        end else begin
            // current_funct_unit_output_o = exec_stage_slots_int[0];
            sb_data_pkt_o = ex_mem_scoreboard_data_slots[0];
        end
    end

    assert property (
        @(posedge clk)
        disable iff (rst || exception_i)
        (new_op_delay == 0 && funct_unit_i != NOOP)
        |-> (exec_stage_slots_int[0] == NOOP)
    ) else $fatal("Scoreboard error: new instruction issued to occupied exec stage slot");

endmodule


module auipc_stage
import decode_pkg::*;
import general_pkg::DATA_WIDTH;
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
            pc = '{default:'0};
            imm = '{default:'0};
        end
    end

    assign result_o = pc + imm;
endmodule

module jalr_stage
import decode_pkg::*;
import issue_pkg::*;
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
    // logic [FUNCT_COMB_WIDTH-1:0] funct_code;
    logic jump_type; // 0: jalr, 1: jal

    always_comb begin
        if (en_i) begin
            pc = pc_i;
            rs1_data = rs1_data_i;
            imm = imm_i;
            jump_type = funct_code_i[3];
        end else begin
            pc = '{default:'0};
            rs1_data = '{default:'0};
            imm = '{default:'0};
            jump_type = 1'b0;
        end
    end

    always_comb begin
        if (jump_type == 1'b1) begin: Jal
            // pc_o = rs1_data + imm;
            pc_o = pc + imm;
        end else begin: Jalr
            pc_o = rs1_data + imm;
        end
        pc_plus_4_o = pc + 4;
    end
endmodule

module branch_unit
import decode_pkg::*;
import issue_pkg::*;
(
    input logic [2:0] funct_code_i,
    input logic [DATA_WIDTH-1:0] src0_data_i,
    input logic [DATA_WIDTH-1:0] src1_data_i,
    output logic branch_taken_o
);
    localparam BEQ  = 3'b000;
    localparam BNE  = 3'b001;
    localparam BLT  = 3'b100;
    localparam BGE  = 3'b101;
    localparam BLTU = 3'b110;
    localparam BGEU = 3'b111;

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
import decode_pkg::*;
import issue_pkg::*;
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
    logic [2:0] funct_code;

    branch_unit branch_unit_inst (
        .funct_code_i(funct_code),
        .src0_data_i(src0_data),
        .src1_data_i(src1_data),
        .branch_taken_o(branch_taken_o)
    );

    assign trgt_o = pc + imm;

    always_comb begin
        if (en_i) begin
            src0_data = src0_data_i;
            src1_data = src1_data_i;
            funct_code = funct_code_i[2:0];
            imm = imm_i;
            pc = pc_i;
        end else begin
            src0_data = 0;
            src1_data = 0;
            funct_code = 0;
            imm = 0;
            pc = 0;            
        end
    end

endmodule

// NOTE: MAKE SURE, load_width_i is set to 1,2,4 
module store_buffer
import writeback_pkg::*;
import exec_mem_pkg::*;
import instr_fetch_pkg::*;
import general_pkg::*;
(
    input clk,
    input rst,
    // other
    output logic                        full_o,
    // committing
    input logic                         store_commit_en_i,
    input logic [DATA_WIDTH-1:0]        store_addr_i,
    input logic [DATA_WIDTH-1:0]        store_data_i,
    input logic [(DATA_WIDTH/8)-1:0]    store_byte_wr_en_i,
    // checking store's for load operations in lsq
    input logic [DATA_WIDTH-1:0]        load_addr_i,
    input logic [1:0]                   load_width_i,
    output logic [(DATA_WIDTH/8)-1:0]   load_byte_en_o,
    output logic [DATA_WIDTH-1:0]       load_data_o,
    // storing to cache
    // ...
);
    store_buffer_entry_t store_buff [0:STORE_BUFF_SIZE-1];
    logic [$clog2(STORE_BUFF_SIZE):0] head_ptr;
    logic [$clog2(STORE_BUFF_SIZE):0] tail_ptr;
    logic [$clog2(STORE_BUFF_SIZE)-1:0] head_ptr_lower;
    logic [$clog2(STORE_BUFF_SIZE)-1:0] tail_ptr_lower;
    assign head_ptr_lower = head_ptr[$clog2(STORE_BUFF_SIZE)-1:0];
    assign tail_ptr_lower = tail_ptr[$clog2(STORE_BUFF_SIZE)-1:0];

    assign full_o = 
        tail_ptr_lower == head_ptr_lower
         && tail_ptr[$clog2(STORE_BUFF_SIZE)] != head_ptr[$clog2(STORE_BUFF_SIZE)];

    always_ff @(posedge clk) begin
        if (rst) begin
            store_buff <= '{default:'0};
            head_ptr <= '{default:'0};
            tail_ptr <= '{default:'0};
        end else begin
            if (store_commit_en_i) begin
                store_buff.valid <= 1'b1;
                store_buff.addr <= store_addr_i;
                store_buff.data <= store_data_i;
                store_buff.byte_wr_en <= store_byte_wr_en_i;
            end
        end
    end

    logic [DATA_WIDTH-1:0] pos_diff, neg_diff;
    logic [1:0] pos_byte_offset, neg_byte_offset;
    always_comb begin
        load_byte_en_o = '0;
        load_data_o = '0;
        for (int i = STORE_BUFF_SIZE-1; i >= 0; i--) begin
            pos_diff = load_addr_i - store_buff[i].addr;
            neg_diff = store_buff[i].addr - load_addr_i;
            pos_byte_offset = pos_diff[1:0];
            neg_byte_offset = neg_diff[1:0];
            if (store_buff[i].valid && (store_buff[i].addr >= load_addr_i
                    ? neg_diff < load_width_i
                    : pos_diff < load_width_i)) begin: WithinRange
                if (load_addr_i <= store_buff[i].addr) begin
                    load_byte_en_o = load_byte_en_o | (store_buff[i].byte_wr_en << neg_byte_offset);
                    for (int j = 0; j < (DATA_WIDTH/8); j++) begin
                        if ((store_buff[i].byte_wr_en << neg_byte_offset)[j]) begin
                            load_data_o[8*j+:8] = (store_buff[i].data << (8*neg_byte_offset))[8*j+:8];
                        end
                    end
                end else begin
                    load_byte_en_o = load_byte_en_o | (store_buff[i].byte_wr_en >> pos_byte_offset);
                    for (int j = 0; j < (DATA_WIDTH/8); j++) begin
                        if ((store_buff[i].byte_wr_en >> pos_byte_offset)[j]) begin
                            load_data_o[8*j+:8] = (store_buff[i].data >> (8*pos_byte_offset))[8*j+:8];
                        end
                    end
                end
            end
        end
    end

endmodule

module load_queue
import writeback_pkg::*;
import exec_mem_pkg::*;
import instr_fetch_pkg::*;
import general_pkg::*;
(
    input clk,
    input rst,
    // updating state
    // input ex_mem_stage_pkt_t ex_mem_stage_pkt_i,
    // input spec_exec_answr_pkt_t spec_exec_answr_i,
    // input mem_addr_pkt_t mem_addr_pkt_i,
    input lq_pkt_t issue_pkt_i,
    // state
    output full_o,
    // instantiation
    // input spec_exec_buffer_instance_pkt_t spec_exec_buffer_instance_pkt_i,
    // input logic mem_buff_instance_wr_en_i,
    input lq_instantiation_pkt_t lq_instant_pkt_i,
    // comitting
    // input logic commit_en_i,
    // input logic store_commit_en_i,
    // input logic mem_commit_en_i,
    input lq_commit_pkt_t lq_commit_pkt_i,
    // output shift_reg_pkt_t spec_exec_answr_pkt_o,
    // combinational output
    // output logic load_addr_conflict_o,
    // output logic [DATA_WIDTH-1:0] pc_o,

    output lq_load_dispatch_pkt_t lq_load_dispatch_pkt_o,
    


    output mem_addr_conflict_pkt_t mem_addr_conflict_pkt_o,
    output store_buffer_commit_pkt_t store_buffer_commit_pkt_o,
    input logic exception_i,

    input wb_phys_reg_pkt_t wb_phys_reg_pkt_i,
    input commit_stage_pkt_t commit_stage_pkt_i
);

    // mem_addr_entry_t lsq [0:MAX_MEM_INSTRS-1];
    lq_entry_t lq [0:MAX_LOAD_INSTRS-1];
    logic [$clog2(MAX_LOAD_INSTRS)-1:0] head_ptr;
    logic [$clog2(MAX_LOAD_INSTRS)-1:0] tail_ptr;
    logic [$clog2(MAX_LOAD_INSTRS)-1:0] next_head_ptr;
    // logic [$clog2(MAX_LOAD_INSTRS)-1:0] head_ptr_lower;
    // logic [$clog2(MAX_LOAD_INSTRS)-1:0] tail_ptr_lower;
    // assign head_ptr_lower = head_ptr[$clog2(MAX_MEM_INSTRS)-1:0];
    // assign tail_ptr_lower = tail_ptr[$clog2(MAX_MEM_INSTRS)-1:0];

    // assign full_o = 
    //     tail_ptr_lower == head_ptr_lower
    //      && tail_ptr[$clog2(MAX_MEM_INSTRS)] != head_ptr[$clog2(MAX_MEM_INSTRS)];
    assign full_o = lq[tail_ptr].state == INVALID;

    // logic empty;
    // assign empty = tail_ptr == head_ptr;

    logic [MAX_LOAD_INSTRS-1:0] valid_arry, next_valid_arry, masked_valid_arry, mask_arry, ready_arry, masked_ready_arry;
    logic [$clog2(MAX_LOAD_INSTRS)-1:0] select_ptr;

    // common signals
    always_comb begin
        mask_arry = {MAX_LOAD_INSTRS{1'b1}} << head;
        for (int i = 0; i < MAX_LOAD_INSTRS; i++) begin
            valid_arry[i] = lq[i].state != INVALID;
            ready_arry[i] = lq[i].state == LOAD_SAFE;
        end
        masked_ready_arry = mask_arry & ready_arry;
    end

    // issuing instruction after recieving data from cache
    always_comb begin
        if (!exception_i) begin // possibly add extra conditions here!
            if (|masked_ready_arry) begin
                for (int i = MAX_LOAD_INSTRS-1; i >= 0; i--) begin
                    if (masked_ready_arry[i]) begin
                        lq_load_dispatch_pkt_o = set_lq_load_dispatch_pkt(lq[i], i);
                    end
                end
            end else if (|ready_arry) begin
                for (int i = MAX_LOAD_INSTRS-1; i >= 0; i--) begin
                    if (ready_arry[i]) begin
                        lq_load_dispatch_pkt_o = set_lq_load_dispatch_pkt(lq[i], i);
                    end
                end
            end
        end else begin
            lq_load_dispatch_pkt_o = '{default:'0};
        end
    end

    // determine next head_ptr 
    always_comb begin
        // determine next valid state of array
        next_valid_arry = valid_arry;
        if (lq_commit_pkt_i.en) begin
            next_valid_arry[lq_commit_pkt_i.ptr] = 1'b0; // Entry is leaving
        end
        if (lq_instant_pkt_i.wr_en && !full_o) begin
            next_valid_arry[tail_ptr] = 1'b1;      // Entry is arriving
        end
        // compute next head position
        masked_valid_arry = mask_arry & next_valid_arry;
        next_head_ptr = head_ptr;
        if (|masked_valid_arry) begin
            for (int i = MAX_LOAD_INSTRS-1; i >= 0; i--) begin
                if (masked_valid_arry[i]) begin
                    next_head_ptr = i;
                end
            end
        end else if (|next_valid_arry) begin
            for (int i = MAX_LOAD_INSTRS-1; i >= 0; i--) begin
                if (next_valid_arry[i]) begin
                    next_head_ptr = i;
                end
            end
        end
    end

    // buffer management
    always_ff @(posedge clk) begin
        if (rst || exception_i || mem_addr_conflict_pkt_o.en) begin
            lq <= '{state: INVALID, default:'0};
            head_ptr <= '{default:'0};
            tail_ptr <= '{default:'0};
        end else begin
            // instantiation
            if (lq_instant_pkt_i.wr_en && !full_o) begin
                // lq[head_ptr_lower].valid = 1'b1;
                lq[tail_ptr].state <= LOAD_PENDING;
                // lq[tail_ptr].dest_ptr <= lq_instant_pkt_i.dest_ptr;
                // head_ptr <= head_ptr + 1;
                // head_ptr <= next_head_ptr;
                tail_ptr <= tail_ptr + 1;
            end
            head_ptr <= next_head_ptr;
            // issued
            if (issue_pkt_i.wr_en) begin
                // if (issue_pkt_i.is_store) begin
                //     lsq[issue_pkt_i.lsq_ptr[$clog2(MAX_MEM_INSTRS)-1:0]].byte_wr_en <= issue_pkt_i.byte_wr_en;
                //     lsq[issue_pkt_i.lsq_ptr[$clog2(MAX_MEM_INSTRS)-1:0]].addr       <= issue_pkt_i.addr;
                //     lsq[issue_pkt_i.lsq_ptr[$clog2(MAX_MEM_INSTRS)-1:0]].pc         <= issue_pkt_i.pc;
                //     if (issue_pkt_i.store_data_in) begin
                //         lsq[issue_pkt_i.lsq_ptr[$clog2(MAX_MEM_INSTRS)-1:0]].state  <= STORE_DATA_IN;
                //         lsq[issue_pkt_i.lsq_ptr[$clog2(MAX_MEM_INSTRS)-1:0]].data   <= issue_pkt_i.data;
                //     end else begin
                //         lsq[issue_pkt_i.lsq_ptr[$clog2(MAX_MEM_INSTRS)-1:0]].state  <= STORE_ADDR_IN;
                //     end
                // end else begin
                lq[issue_pkt_i.lq_ptr].state      <= LOAD_ADDR_IN;
                lq[issue_pkt_i.lq_ptr].rob_ptr    <= issue_pkt_i.rob_ptr;
                lq[issue_pkt_i.lq_ptr].byte_wr_en <= issue_pkt_i.byte_wr_en;
                lq[issue_pkt_i.lq_ptr].funct_code <= issue_pkt_i.funct_code;
                lq[issue_pkt_i.lq_ptr].addr       <= issue_pkt_i.addr;
                lq[issue_pkt_i.lq_ptr].pc         <= issue_pkt_i.pc;
                lq[issue_pkt_i.lq_ptr].dest_ptr   <= issue_pkt_i.dest_ptr;
                // end
            end
            // data in
            // if (wb_phys_reg_pkt_i.wr_en) begin
            //     for (int i = 0; i < MAX_MEM_INSTRS; i++) begin
            //         if (lsq[i].state == STORE_ADDR_IN && lsq[i].src_ptr == wb_phys_reg_pkt_i.dest_ptr) begin
            //             lsq[i].state <= STORE_DATA_IN;
            //             lsq[i].data  <= wb_phys_reg_pkt_i.data;
            //         end
            //     end
            // end

            // store committed
            // if (commit_stage_pkt_i.wr_en && commit_stage_pkt_i.store) begin /// use later
            if (lq_commit_pkt_i.en) begin

                // if (lsq[i].state == STORE_DATA_IN && lsq[i].src_ptr == commit_stage_pkt_i.phys_reg_addr) begin
                // lsq[commit_stage_pkt_i.lsq_counter]; // work off this
                    // COME BACK TO THIS
                    // DISPATCH THE STORE TO THE STORE BUFFER, where it will then go to cache
                    // ALSO RESET state of entry to be INVALID
                // end
                lsq[lq_commit_pkt_i.lq_ptr].state <= INVALID;
                // lsq[]
            end
            

            // // updating state
            // if (mem_addr_pkt_i.wr_en) begin
            //     lsq[mem_addr_pkt_i.buff_ptr[$clog2(MAX_MEM_INSTRS)-1:0]].valid <= 1'b1;
            //     lsq[mem_addr_pkt_i.buff_ptr[$clog2(MAX_MEM_INSTRS)-1:0]].byte_wr_en <= mem_addr_pkt_i.vec_wr_en;
            //     lsq[mem_addr_pkt_i.buff_ptr[$clog2(MAX_MEM_INSTRS)-1:0]].is_store <= mem_addr_pkt_i.is_store;
            //     lsq[mem_addr_pkt_i.buff_ptr[$clog2(MAX_MEM_INSTRS)-1:0]].addr <= mem_addr_pkt_i.addr;
            //     lsq[mem_addr_pkt_i.buff_ptr[$clog2(MAX_MEM_INSTRS)-1:0]].pc <= mem_addr_pkt_i.pc;
            //     lsq[mem_addr_pkt_i.buff_ptr[$clog2(MAX_MEM_INSTRS)-1:0]].store_data <= mem_addr_pkt_i.store_data;
            // end
            // // committing
            // if (commit_en_i && mem_commit_en_i) begin
            //     lsq[tail_ptr_lower].valid <= 1'b0;
            //     tail_ptr <= tail_ptr + 1;
            // end

        end
    end

    assert property (
        @(posedge clk) disable iff (rst || exception_i)
        (!(issue_pkt_i.wr_en && issue_pkt_i.is_store) || lsq[issue_pkt_i.lsq_ptr[$clog2(MAX_MEM_INSTRS)-1:0]].state == STORE_PENDING)
    );

    assert property (
        @(posedge clk) disable iff (rst || exception_i)
        (!(issue_pkt_i.wr_en && !issue_pkt_i.is_store) || lsq[issue_pkt_i.lsq_ptr[$clog2(MAX_MEM_INSTRS)-1:0]].state == LOAD_PENDING)
    );

    assert property (
        @(posedge clk) disable iff (rst || exception_i)
        (!(commit_stage_pkt_i.wr_en && commit_stage_pkt_i.store) || lsq[commit_stage_pkt_i.lsq_counter].state == STORE_DATA_IN)
    );



    // determining memory conflict
    logic [MAX_MEM_INSTRS-1:0] cnflct_arry;
    logic frwd_cnflct;
    always_comb begin
        cnflct_arry = '0;
        frwd_cnflct = '0;
        if (commit_en_i && !exception_i && store_commit_en_i) begin
            for (int i = 0; i < MAX_MEM_INSTRS; i++) begin
                cnflct_arry[i] = lsq[i].valid &&
                    i != tail_ptr_lower &&
                    !lsq[i].is_store &&
                    lsq[i].addr == lsq[tail_ptr_lower].addr;
            end
            frwd_cnflct = mem_addr_pkt_i.wr_en &&
                // mem_addr_pkt_i.valid && 
                !mem_addr_pkt_i.is_store &&
                mem_addr_pkt_i.addr == lsq[tail_ptr_lower].addr &&
                lsq[tail_ptr_lower].valid;

            mem_addr_conflict_pkt_o.en = |cnflct_arry || frwd_cnflct;
        end else begin
            mem_addr_conflict_pkt_o.en = '0;
        end
        
        mem_addr_conflict_pkt_o.pc = lsq[tail_ptr_lower].pc;
    end

    // setting store pkt when commiting
    always_comb begin
        if (commit_en_i && !exception_i && store_commit_en_i) begin
            // store_buffer_commit_pkt_o.en = 1'b1;
            store_buffer_commit_pkt_o.byte_wr_en = lsq[tail_ptr_lower].byte_wr_en;
            store_buffer_commit_pkt_o.addr = lsq[tail_ptr_lower].addr;
            store_buffer_commit_pkt_o.data = lsq[tail_ptr_lower].store_data;
        end else begin
            store_buffer_commit_pkt_o = '{default:'0};
        end
    end

endmodule

// NEED TO have outside a lsq pointer and be able to check stores that come only BEORE a given load

module store_queue
import decode_pkg::*;
import general_pkg::*;
import issue_pkg::*;
import exec_mem_pkg::*;
import writeback_pkg::*;
(
    input clk,
    input rst,
    input exception_i,
    // other
    output logic full_o,
    // checking store addresses for load operations in lq
    input logic [DATA_WIDTH-1:0] load_addr_i,
    input logic [1:0] load_width_i,
    input logic [$clog2(MAX_LSQ_INSTRS)-1:0] lsq_ptr_i,
    output logic [(DATA_WIDTH/8)-1:0] load_byte_en_o,
    output logic [DATA_WIDTH-1:0] load_data_o,
    // instantiation
    input sq_instantiation_pkt_t sq_instant_pkt_i,
    // address computation, and possibly store data
    input sq_pkt_t sq_pkt_i,
    // store data
    input logic data_wr_en_i,
    input logic [DATA_WIDTH-1:0] data_i,
    input logic [$clog2(PRF_COUNT)-1:0] src_ptr_i,
    // commiting
    input sq_commit_pkt_t sq_commit_pkt_i,
    // storing to cache
    output sq_dispatch_pkt_t sq_dispatch_pkt_o
);
    sq_entry_t sq [0:MAX_STORE_INSTRS-1];
    logic [$clog2(MAX_STORE_INSTRS):0] head_ptr, tail_ptr;
    logic [$clog2(MAX_STORE_INSTRS)-1:0] head_ptr_lower, tail_ptr_lower;
    assign head_ptr_lower = head_ptr[$clog2(MAX_STORE_INSTRS)-1:0];
    assign tail_ptr_lower = tail_ptr[$clog2(MAX_STORE_INSTRS)-1:0];
    
    assign full_o = 
        tail_ptr_lower == head_ptr_lower
         && tail_ptr[$clog2(MAX_STORE_INSTRS)] != head_ptr[$clog2(MAX_STORE_INSTRS)];
    
    logic empty;
    assign empty = head_ptr == tail_ptr;
    
    // reorder buffer management
    always_ff @(posedge clk) begin
        if (rst || exception_i) begin
            // reorder_buffer <= '{default: rob_entry_t'('0)};
            sq <= '{state: INVALID, default:'0};
            head_ptr <= '{default:'0};
            tail_ptr <= '{default:'0};
        end else begin
            // instantiation
            if (sq_instant_pkt_i.en && !full_o) begin
                sq[head_ptr_lower].state <= STORE_PENDING;
                head_ptr <= head_ptr + 1;
            end
            // updating state
            if (sq_pkt_i.wr_en) begin
                sq[sq_pkt_i.sq_ptr] <= sq_set_entry_from_pkt(sq_pkt_i);
            end
            // data incoming
            if (data_wr_en_i) begin
                for (int i = 0; i < MAX_STORE_INSTRS; i++) begin
                    if (sq[i].state == STORE_ADDR_IN && sq[i].src_ptr == src_ptr_i) begin
                        sq[i].state <= STORE_DATA_IN;
                        sq[i].store_data <= data_i;
                    end
                end
            end
        end 
        // committing (UNSURE ABOUT TIMING OF THIS, when exception happens)
        if (sq_commit_pkt_i.en) begin
            sq[tail_ptr_lower].state <= STORE_COMMIT;
        end
        // sending to cache
        if (sq[tail_ptr_lower].state == STORE_COMMIT) begin
            sq[tail_ptr_lower].state <= INVALID;
            tail_ptr <= tail_ptr + 1;
        end
    end

    // might need to change this
    always_comb begin
        if (sq[tail_ptr_lower].state == STORE_COMMIT) begin
            sq_dispatch_pkt_o = get_store_data_from_sq_entry(sq[tail_ptr_lower]);
        end else begin
            sq_dispatch_pkt_o = '{default:'0};
        end
    end

    // WHAT ABOUT SITUATIONS WHERE STORE VLAUE IS NOT IN YET?

    // NEED TO ACCOUNT FOR EMPTY, EXCEPTION, and also ADDR vs DATA cases

    // checking store addresses for load operations in lq
    logic tail_ptr_diff_sign;
    logic [MAX_STORE_INSTRS-1:0] mask_arry, valid_arry, masked_valid_arry;
    logic [MAX_STORE_INSTRS-1:0] overflow_mask_arry, overflow_valid_masked_arry;
    logic overflow_condition;
    // logic [$clog2]
    logic [DATA_WIDTH-1:0] pos_diff, neg_diff;
    logic [1:0] pos_byte_offset, neg_byte_offset;
    // logic 
    always_comb begin
        tail_ptr_diff_sign = lsq_ptr_i > sq[tail_ptr_lower].lsq_ptr;
        mask_arry = {MAX_STORE_INSTRS{1'b1}} << tail_ptr_lower;
        overflow_mask_arry = {MAX_STORE_INSTRS{1'b1}} >> (MAX_STORE_INSTRS - head_ptr_lower);
        for (int i = 0; i < MAX_STORE_INSTRS; i++) begin
            valid_arry[i] = sq[i].state != INVALID && (tail_ptr_diff_sign == (lsq_ptr_i > sq[i].lsq_ptr));
        end
        masked_valid_arry = mask_arry & valid_arry;
        overflow_valid_masked_arry = overflow_mask_arry & valid_arry;

        overflow_condition = head_ptr_lower < tail_ptr_lower;
        for (int i = 0; i < MAX_STORE_INSTRS; i++) begin
            if (i >= tail_ptr_lower && sq[i].state != INVALID) begin
                overflow_condition = overflow_condition && (lsq_ptr_i > sq[i].lsq_ptr);
            end
        end

        if (|masked_valid_arry && !empty && !exception) begin
            for (int i = 0; i < MAX_STORE_INSTRS; i++) begin
                if (masked_valid_arry[i]) begin
                    // check if load address is within range of store address and width
                    pos_diff = load_addr_i - sq[i].addr;
                    neg_diff = sq[i].addr - load_addr_i;
                    pos_byte_offset = pos_diff[1:0];
                    neg_byte_offset = neg_diff[1:0];
                    if (sq[i].state == STORE_ADDR_IN && (sq[i].addr >= load_addr_i
                            ? neg_diff < load_width_i
                            : pos_diff < load_width_i)) begin: WithinRange
                        if (load_addr_i <= sq[i].addr) begin
                            load_byte_en_o = load_byte_en_o | (sq[i].byte_wr_en << neg_byte_offset);
                            for (int j = 0; j < (DATA_WIDTH/8); j++) begin
                                if ((sq[i].byte_wr_en << neg_byte_offset)[j]) begin
                                    load_data_o[8*j+:8] = (sq[i].data << (8*neg_byte_offset))[8*j+:8];
                                end
                            end
                        end else begin
                            load_byte_en_o = load_byte_en_o | (sq[i].byte_wr_en >> pos_byte_offset);
                            for (int j = 0; j < (DATA_WIDTH/8); j++) begin
                                if ((sq[i].byte_wr_en >> pos_byte_offset)[j]) begin
                                    load_data_o[8*j+:8] = (sq[i].data >> (8*pos_byte_offset))[8*j+:8];
                                end
                            end
                        end
                    end
                end
            end
            if (overflow_condition) begin
                for (int i = 0; i < MAX_STORE_INSTRS; i++) begin
                    if (overflow_valid_masked_arry[i]) begin
                        // check if load address is within range of store address and width
                        pos_diff = load_addr_i - sq[i].addr;
                        neg_diff = sq[i].addr - load_addr_i;
                        pos_byte_offset = pos_diff[1:0];
                        neg_byte_offset = neg_diff[1:0];
                        if (sq[i].state == STORE_ADDR_IN && (sq[i].addr >= load_addr_i
                                ? neg_diff < load_width_i
                                : pos_diff < load_width_i)) begin: WithinRangeOverflow
                            if (load_addr_i <= sq[i].addr) begin
                                load_byte_en_o = load_byte_en_o | (sq[i].byte_wr_en << neg_byte_offset);
                                for (int j = 0; j < (DATA_WIDTH/8); j++) begin
                                    if ((sq[i].byte_wr_en << neg_byte_offset)[j]) begin
                                        load_data_o[8*j+:8] = (sq[i].data << (8*neg_byte_offset))[8*j+:8];
                                    end
                                end
                            end else begin
                                load_byte_en_o = load_byte_en_o | (sq[i].byte_wr_en >> pos_byte_offset);
                                for (int j = 0; j < (DATA_WIDTH/8); j++) begin
                                    if ((sq[i].byte_wr_en >> pos_byte_offset)[j]) begin
                                        load_data_o[8*j+:8] = (sq[i].data >> (8*pos_byte_offset))[8*j+:8];
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end else begin
            load_byte_en_o = '0;
            load_data_o = '0;
        end
    end

endmodule



// for now doing a simple memory, 2 cycles
module mem_stage 
import decode_pkg::*;
import general_pkg::*;
import issue_pkg::*;
import exec_mem_pkg::*;
import writeback_pkg::*;
(
    input clk,
    input rst,
    input logic en_i,
    input logic store_i,
    input logic [DATA_WIDTH-1:0] pc_i,
    input logic [$clog2(MAX_MEM_INSTRS):0] lsq_ptr_i,
    input logic [FUNCT_COMB_WIDTH-1:0] funct_code_i,
    input logic [DATA_WIDTH-1:0] base_addr_i,
    input logic [DATA_WIDTH-1:0] offset_i,
    input logic [DATA_WIDTH-1:0] store_data_i,
    output logic [DATA_WIDTH-1:0] data_o,
    output mem_addr_pkt_t mem_addr_pkt_o,
    input store_buffer_commit_pkt_t store_buffer_commit_pkt_i,
    input logic exception_i,
    input lsq_instantiation_pkt_t lsq_instant_pkt_i // SEND TO LSQ
);

    logic [DATA_WIDTH-1:0] base_addr, offset, store_data, addr, pc, loaded_data;
    // for loading
    logic [FUNCT_COMB_WIDTH-1:0] funct_code_ff;
    logic load_ff;
    logic [1:0] lower_addr_bits_ff;

    assign addr = base_addr + offset;

    always_comb begin
        if (en_i) begin
            base_addr = base_addr_i;
            offset = offset_i;
            store_data = store_data_i;
            pc = pc_i;
        end else begin
            base_addr = '{default:'0};
            offset = '{default:'0};
            store_data = '{default:'0};
            pc = '{default:'0};
        end
    end

    always_comb begin
        if (exception_i || !en_i) begin
            mem_addr_pkt_o = '{default:'0};
        end else begin
            mem_addr_pkt_o.wr_en = en_i;
            // mem_addr_pkt_o.vec_wr_en = store_funct3_to_en_vector(funct_code_i[2:0], addr[1:0]);
            mem_addr_pkt_o.byte_wr_en = funct_code_i[1:0];
            mem_addr_pkt_o.buff_ptr = lsq_ptr_i;
            mem_addr_pkt_o.is_store = store_i;
            mem_addr_pkt_o.addr = addr;
            mem_addr_pkt_o.pc = pc;
            // mem_addr_pkt_o.store_data = shift_store_data(funct_code_i[2:0], addr[1:0], store_data);
            mem_addr_pkt_o.store_data = store_data;
            mem_addr_pkt_o.store_width_type = funct_code_i[1:0];
        end
    end    

    logic [DATA_WIDTH-1:0] rd_addr_adj;
    logic [DATA_WIDTH-1:0] wr_addr_adj;
    `ifdef DEBUG
        assign rd_addr_adj = addr - DATA_ADDR_OFFSET;
        assign wr_addr_adj = store_buffer_commit_pkt_i.addr - DATA_ADDR_OFFSET;
    `else
        assign rd_addr_adj = addr;
        assign wr_addr_adj = store_buffer_commit_pkt_i.addr;
    `endif

    sram_sync_read_dual_port_vari_width_write #(
    .ADDR_WIDTH(MEM_INDEX_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
    ) data_memory (
        .clk(clk),
        // .we(en_i && store_i),
        .vec_wr_en(store_buffer_commit_pkt_i.vec_wr_en),
        .rd_addr(rd_addr_adj[MEM_INDEX_WIDTH-1+2:2]),
        .wr_addr(wr_addr_adj[MEM_INDEX_WIDTH-1+2:2]),
        // .rd_addr(addr[MEM_INDEX_WIDTH-1+2:2]),
        // .wr_addr(store_buffer_commit_pkt_i.addr[MEM_INDEX_WIDTH-1+2:2]),
        .din(store_buffer_commit_pkt_i.data),
        .dout(loaded_data)
    );

    always_ff @(posedge clk) begin
        if (rst) begin
            funct_code_ff <= '0;
            load_ff <= '0;
            lower_addr_bits_ff <= '0;
        end else begin
            funct_code_ff <= funct_code_i;
            load_ff <= !store_i;
            lower_addr_bits_ff <= addr[1:0];
        end
    end

    always_comb begin
        data_o = process_loaded_data(
            loaded_data,
            funct_code_ff[2:0],
            lower_addr_bits_ff
        );
    end


endmodule

module alu 
import general_pkg::*;
(
    input  [DATA_WIDTH-1:0] a_i,
    input  [DATA_WIDTH-1:0] b_i,
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
    // Does not match {funct7[5], funct3};
    localparam LUI  = 4'b1111;

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
            SLT:  result_o = ($signed(a_i) < $signed(b_i)) ? 1 : 0;
            SLTU: result_o = (a_i < b_i) ? 1 : 0;
            LUI:  result_o = b_i;

            // will add rest of rv32m instructions later
            // default:  result_o = 3'b010;
            default: result_o = 'x;
        endcase
    end
    // The Zero flag is asserted if the result_o is all zeros.
    assign zero_o = (result_o == 0);

endmodule

module alu_stage 
import issue_pkg::*;
import general_pkg::*;
(
    input  en_i,
    input  [DATA_WIDTH-1:0] a_i,
    input  [DATA_WIDTH-1:0] b_i,
    input logic [FUNCT_COMB_WIDTH-1:0] funct_code_i,
    output logic [DATA_WIDTH-1:0] result_o,
    output logic zero_o
);

    logic [DATA_WIDTH-1:0] a, b;
    logic [FUNCT_COMB_WIDTH-1:0] alu_cntrl;

    alu alu_inst (
        .a_i(a),
        .b_i(b),
        .alu_cntrl_i(alu_cntrl), // going to assume, but unsure if we truncate
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


