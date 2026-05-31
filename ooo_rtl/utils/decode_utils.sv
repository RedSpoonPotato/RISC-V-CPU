package decode_pkg;

    import general_pkg::*;
    export general_pkg::*;



    // localparam DATA_WIDTH = 32;
    // localparam IQ_SIZE = 16;
    // localparam ROB_COUNT = 32;
    // localparam PRF_COUNT = 32;
    // localparam INSTR_COMPRESS_WIDTH = 17;
    // localparam MAX_EXEC_CYCLE = 4;
    // localparam IMM_COMPRESS = 20;

    // attemptng to import everything
    // import general_pkg::DATA_WIDTH;
    // import general_pkg::*;

    import instr_fetch_pkg::MAX_PC_INSTRS;
    import instr_fetch_pkg::MAX_SPEC_EXEC_INSTRS;
    import writeback_pkg::ROB_COUNT;




    typedef struct packed {
        logic [31:0] instr;
        logic instr_valid;
        logic [DATA_WIDTH-1:0] pc;
        logic bp_pred;
    } if_input_t;


    typedef struct packed {
        logic wr_en;
        logic [$clog2(PRF_COUNT)-1:0] prf_ptr;
        logic [4:0] arf_ptr;
        logic [$clog2(PRF_COUNT)-1:0] prev_prf_ptr;
    } decode_commit_pkt_t;

    // typedef struct packed {
    //     logic wr_en;
    //     logic [$clog2(PRF_COUNT)-1:0] commited_ptr;
    // } free_list_update_pkt_t;

    // typedef struct packed {
    //     logic wb_en;
    //     logic [$clog2(PRF_COUNT)-1:0] prf_ptr;
    //     logic [4:0] arf_ptr;
    // } rename_table_update_pkt_t;

    // typedef struct packed {
    //     logic prf_wr_en;
    //     logic [$clog2(PRF_COUNT)-1:0] prf_dst_ptr;
    // } issue_queue_update_pkt_t;

    // typedef struct packed {
        // logic wr_en;
        // logic [$clog2(PRF_COUNT)-1:0] prf_ptr;
        // logic [4:0] arf_ptr; // DONT SET NOW, SET IN WB STAGE
    // } rename_table_and_issue_queue_update_pkt_t;



    typedef struct packed {
        logic valid;
        logic [INSTR_COMPRESS_WIDTH-1:0] op;
        logic [$clog2(MAX_EXEC_CYCLE)-1:0] exec_dur;
        logic imm_valid;
        logic [IMM_COMPRESS-1:0] imm_compr;
        logic speculative;
        logic store;
        logic dest_valid;
        logic [$clog2(PRF_COUNT)-1:0] dest_ptr;
        logic src0_valid;
        logic src0_pending;
        logic [$clog2(PRF_COUNT)-1:0] src0_ptr;
        logic src1_valid;
        logic src1_pending;
        logic [$clog2(PRF_COUNT)-1:0] src1_ptr;
        logic [$clog2(ROB_COUNT)-1:0] rob_ptr;
        logic [$clog2(MAX_SPEC_EXEC_INSTRS):0] spec_exec_ptr;
        logic pc_instr;
        logic [$clog2(MAX_PC_INSTRS)-1:0] pc_buff_ptr;
        logic [$clog2(MEM_BUFF_SIZE):0] mem_buff_ptr;
    } iq_entry_t;
    
    typedef struct packed {
        logic valid;
        logic [INSTR_COMPRESS_WIDTH-1:0] op;
        // logic [$clog2(MAX_EXEC_CYCLE)-1:0] exec_dur; // unsure if we need to output this
        logic imm_valid;
        logic [IMM_COMPRESS-1:0] imm_compr;
        logic speculative;
        logic store;
        // logic dest_valid;
        logic [$clog2(PRF_COUNT)-1:0] dest_ptr;
        // logic src0_valid;
        logic [$clog2(PRF_COUNT)-1:0] src0_ptr;
        // logic src1_valid;
        logic [$clog2(PRF_COUNT)-1:0] src1_ptr;
        logic [$clog2(ROB_COUNT)-1:0] rob_ptr;
        logic [$clog2(MAX_SPEC_EXEC_INSTRS):0] spec_exec_ptr;
        logic pc_instr;
        logic [$clog2(MAX_PC_INSTRS)-1:0] pc_buff_ptr;
        logic [$clog2(MEM_BUFF_SIZE):0] mem_buff_ptr;
    } iq_output_t;

    // SUBJECT TO CHANGE
    // adds + 2 to normal delay, see mini_scoreboard for details
    function automatic logic [$clog2(MAX_EXEC_CYCLE)-1:0] get_exec_stage_delays_sb (
        input [INSTR_COMPRESS_WIDTH-1:0] op
    );
        if (op[6:0] == 7'b0000011 || op[6:0] == 7'b010001) begin
            return 4;
        end else begin
            return 3;
        end
    endfunction

    // SUBJECT TO CHANGE
    function automatic logic [$clog2(MAX_EXEC_CYCLE)-1:0] get_exec_stage_delays_from_instr (
        input [31:0] instr
    );
        return 3;
    endfunction

    // sets some entries to be 0, will be overwritten later
    function automatic iq_entry_t instr_to_iq_entry_partial (
        input [31:0] instr,
        input instr_valid
    );
        iq_entry_t iq_entry;
        iq_entry.valid = 1;
        iq_entry.op = grab_compr_instr(instr);
        iq_entry.exec_dur = get_exec_stage_delays_from_instr(instr);
        iq_entry.imm_valid = general_pkg::has_imm(instr[6:0]);
        iq_entry.imm_compr = extract_20b_imm(instr);
        iq_entry.speculative = general_pkg::is_speculative(instr[6:0]);
        iq_entry.store = general_pkg::is_store(instr[6:0]);
        iq_entry.dest_valid = general_pkg::has_dest(instr[6:0]);
        iq_entry.dest_ptr = 0;
        iq_entry.src0_valid = general_pkg::has_src0(instr[6:0]);
        iq_entry.src0_pending = 0;
        iq_entry.src0_ptr = 0;
        iq_entry.src1_valid = general_pkg::has_src1(instr[6:0]);
        iq_entry.src1_pending = 0;
        iq_entry.src1_ptr = 0;
        return iq_entry;
    endfunction

    // SUBJECT TO CHANGE, CAN OPTIMIZE
    // "-3" b/c we are removing some valid and pending bits
    // localparam INSTR_OUTPUT_WIDTH = $bits(iq_entry_t) - 3;
    function automatic iq_output_t entry_to_output (
        input iq_entry_t in
    );
        iq_output_t out;
        out.op = in.op;
        // out.exec_dur    = in.exec_dur;
        out.imm_valid   = in.imm_valid;
        out.imm_compr   = in.imm_compr;
        out.speculative = in.speculative;
        // out.dest_valid  = in.dest_valid;
        out.dest_ptr    = in.dest_ptr;
        // out.src0_valid  = in.src0_valid;
        out.src0_ptr    = in.src0_ptr;
        // out.src1_valid  = in.src1_valid;
        out.src1_ptr    = in.src1_ptr;
        out.rob_ptr     = in.rob_ptr;
        out.spec_exec_ptr = in.spec_exec_ptr;
        out.pc_instr    = in.pc_instr;
        out.pc_buff_ptr = in.pc_buff_ptr;
        out.mem_buff_ptr = in.mem_buff_ptr;
        return out;
    endfunction

    // could set some bits to zero based on type of instruction type
    function automatic logic [INSTR_COMPRESS_WIDTH-1:0] grab_compr_instr (
        input [31:0] full_instr
    );
        logic [6:0] funct7 = full_instr[31:25];
        logic [2:0] funct3 = full_instr[14:12];
        logic [6:0] opcode = full_instr[6:0];
        return {funct7, funct3, opcode};
    endfunction

    // disclaimer: function below has been ai generated
    function automatic logic [19:0] extract_20b_imm(input logic [31:0] instr);
    logic [6:0] opcode;
    opcode = instr[6:0];

    case (opcode)
        // ----------------------------------------------------------------
        // I-Type: 12 bits (sign-extended to 20)
        // ----------------------------------------------------------------
        7'b000_0011, 7'b110_0111, 7'b001_0011:
        begin
            extract_20b_imm = {{8{instr[31]}}, instr[31:20]};
        end

        // ----------------------------------------------------------------
        // S-Type: 12 bits (sign-extended to 20)
        // ----------------------------------------------------------------
        7'b010_0011:
        begin
            extract_20b_imm = {{8{instr[31]}}, instr[31:25], instr[11:7]};
        end

        // ----------------------------------------------------------------
        // B-Type: 13-bit value (12 encoded + 1 implicit 0, sign-extended to 20)
        // ----------------------------------------------------------------
        7'b110_0011:
        begin
            // extract_20b_imm = {{7{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
            extract_20b_imm = {{8{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
        end

        // ----------------------------------------------------------------
        // U-Type: 20 bits (Exact fit)
        // ----------------------------------------------------------------
        7'b011_0111, 7'b001_0111:
        begin
            extract_20b_imm = instr[31:12];
        end

        // ----------------------------------------------------------------
        // J-Type: 20 raw encoded bits (Excludes the implicit 0)
        // ----------------------------------------------------------------
        7'b110_1111:
        begin
            // A JAL immediate is technically a 21-bit offset. To fit it into 
            // a 20-bit signal without losing the sign bit, we omit the implicit LSB 0.
            extract_20b_imm = {instr[31], instr[19:12], instr[20], instr[30:21]};
        end

        // ----------------------------------------------------------------
        // Z-Type (CSR): 5 bits (zero-extended to 20)
        // ----------------------------------------------------------------
        7'b111_0011:
        begin
            extract_20b_imm = {15'b0, instr[19:15]};
        end

        // Default: No immediate
        default: begin
            extract_20b_imm = 20'b0;
        end
    endcase
    return extract_20b_imm;
endfunction




endpackage