package issue_queue_pkg;

    // replacing instruction with rob ptr
    typedef struct packed {
        logic [31:0] instr;
        logic []
    } rob_instr;

    localparam DATA_WIDTH = 32;
    localparam IQ_SIZE = 16;
    localparam ROB_COUNT = 32;
    localparam INSTR_COMPRESS_WIDTH = 17;

    // could optimize by diverging from diaram
    typedef struct packed {
        logic valid;
        logic [INSTR_COMPRESS_WIDTH-1:0] op;
        logic [DATA_WIDTH-1:0] imm;
        logic speculative;
        logic dest_valid;
        logic [$clog2(ROB_COUNT)-1:0] dest_ptr;
        logic src0_valid;
        logic src0_pending;
        logic [$clog2(ROB_COUNT)-1:0] src0_ptr;
        logic src1_valid;
        logic src1_pending;
        logic [$clog2(ROB_COUNT)-1:0] src1_ptr;
    } iq_entry_t;

    // SUBJECT TO CHANGE, CAN OPTIMIZE
    localparam INSTR_OUTPUT_WIDTH = $bits(iq_entry_t) - 1;

    function logic [INSTR_COMPRESS_WIDTH-1:0] grab_compr_instr (
        input [31:0] full_instr
    );
        logic [6:0] funct7 = full_instr[31:25];
        logic [2:0] funct3 = full_instr[14:12];
        logic [6:0] opcode = full_instr[6:0];
        return {funct7, funct3, opcode};
    endfunction

    function logic [19:0] grab_compr_imm (
        input [31:0] full_instr
    );

    endfunction

    import general_pkg::instruction_t;
    import general_pkg::classify_instr;

    function imm_gen #(
        parameter DATA_WIDTH = 32
    ) (
        input  logic [31:0] instruction,
        output logic [DATA_WIDTH-1:0] immediate
    );
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
        return opcode;
    endfunction




endpackage