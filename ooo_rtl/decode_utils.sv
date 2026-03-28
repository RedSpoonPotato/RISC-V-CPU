package issue_queue_pkg;

    // localparam DATA_WIDTH = 32;
    localparam IQ_SIZE = 16;
    // localparam ROB_COUNT = 32;
    localparam PRF_COUNT = 32;
    localparam INSTR_COMPRESS_WIDTH = 17;
    localparam MAX_EXEC_CYCLE = 4;
    localparam IMM_COMPRESS = 20;


    typedef struct packed {
        logic valid;
        logic [INSTR_COMPRESS_WIDTH-1:0] op;
        logic [$clog2(MAX_EXEC_CYCLE)-1:0] exec_dur;
        logic imm_valid;
        logic [IMM_COMPRESS-1:0] imm_compr;
        logic speculative;
        logic dest_valid;
        logic [$clog2(PRF_COUNT)-1:0] dest_ptr;
        logic src0_valid;
        logic src0_pending;
        logic [$clog2(PRF_COUNT)-1:0] src0_ptr;
        logic src1_valid;
        logic src1_pending;
        logic [$clog2(PRF_COUNT)-1:0] src1_ptr;
    } iq_entry_t;
    
    typedef struct packed {
        logic [INSTR_COMPRESS_WIDTH-1:0] op;
        logic [$clog2(MAX_EXEC_CYCLE)-1:0] exec_dur;
        logic imm_valid;
        logic [IMM_COMPRESS-1:0] imm_compr;
        logic speculative;
        logic dest_valid;
        logic [$clog2(PRF_COUNT)-1:0] dest_ptr;
        logic src0_valid;
        logic [$clog2(PRF_COUNT)-1:0] src0_ptr;
        logic src1_valid;
        logic [$clog2(PRF_COUNT)-1:0] src1_ptr;
    } iq_output_t;

    // SUBJECT TO CHANGE, CAN OPTIMIZE
    // "-3" b/c we are removing some valid and pending bits
    // localparam INSTR_OUTPUT_WIDTH = $bits(iq_entry_t) - 3;
    function automatic iq_output_t entry_to_output (
        input iq_entry_t in
    );
        iq_output_t out;
        out.op = in.op;
        out.exec_dur    = in.exec_dur;
        out.imm_valid   = in.imm_valid;
        out.imm_compr   = in.imm_compr;
        out.speculative = in.speculative;
        out.dest_valid  = in.dest_valid;
        out.dest_ptr    = in.dest_ptr;
        out.src0_valid  = in.src0_valid;
        out.src0_ptr    = in.src0_ptr;
        out.src1_valid  = in.src1_valid;
        out.src1_ptr    = in.src1_ptr;
        return out;
    endfunction

    function automatic logic [INSTR_COMPRESS_WIDTH-1:0] grab_compr_instr (
        input [31:0] full_instr
    );
        logic [6:0] funct7 = full_instr[31:25];
        logic [2:0] funct3 = full_instr[14:12];
        logic [6:0] opcode = full_instr[6:0];
        return {funct7, funct3, opcode};
    endfunction

    // function automatic logic [19:0] grab_compr_imm (
    //     input [31:0] full_instr
    // );

    // endfunction

    import general_pkg::instruction_t;
    import general_pkg::classify_instr;

    // UNSURE IF THIS CORRECT
    function automatic imm_gen_32 (
        input  logic [31:0] instruction,
    );
        logic [6:0] opcode;
        assign opcode = instruciton[6:0];
        // Internal logic for immediate generation
        case (opcode)
            // I-type (ADDI, SLTI, JALR, LW, etc.)
            7'b0010011, 7'b0000011, 7'b1100111: begin
                immediate = {{20{instruction[31]}}, instruction[31:20]};
            end
            // S-type (SW, SB, etc.)
            7'b0100011: begin
                immediate = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            end
            // B-type (BEQ, BNE, etc.)
            7'b1100011: begin
                immediate = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            end
            // U-type (LUI, AUIPC)
            7'b0110111, 7'b0010111: begin
                immediate = {instruction[31:12], 12'b0};
            end
            // J-type (JAL)
            7'b1101111: begin
                immediate = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
            end
            // R-type
            default: begin
                immediate = 32'b0;
            end
        endcase
        return immediate;
    endfunction




endpackage