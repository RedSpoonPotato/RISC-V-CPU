module decode_stage #(
    parameter DATA_WIDTH = 32,
    parameter INSTR_WIDTH = 32,

) (
    input clk,
    input [INSTR_WIDTH-1:0] instr_i,
    // cntrls

    /*
        external comms
            master
                arf read
                rob r/w
            slave
                writeback stage for w for issuequeue
                commit_stage w for RT
    */

    output logic
);
    // addr for branch targets

    // internal comms
    // rename table r/w
    // issue queue w
    
    // modules
    // rename table
    // issue queue


        

endmodule

// possible optimzation: merge rename table and scoreboard

// used for knowing where to commit
// assumption: data can be in ROB or ARF
module rename_table #(
    parameter ROB_COUNT = 32
) (
    input clk,
    input rst,
    // initial write
    input logic [$clog2(ROB_COUNT)-1:0] rob_ptr_i,
    input logic [4:0] arf_ptr_i,
    input logic decode_en_i, 
    // to signal its in ROB, can have the scoreboard tell the RT
    input logic [$clog2(ROB_COUNT)-1:0] rob_ptr_sb_i,
    input logic writeback_en_i,
    // to signal its in ARF, can have the ROB tell the RT
    input logic [4:0] arf_ptr_rob_i,
    input logic [$clog2(ROB_COUNT)-1:0] rob_ptr_rob_i,
    input logic commit_en_i,
      
    output logic [$clog2(ROB_COUNT)-1:0] rob_ptr_o
);

    typedef struct packed {
        logic [$...clog2(ROB_COUNT)-1:0] rob_ptr;
        logic [DATA_WIDTH-1:0] imm;
        logic spec
        logic pending;
        logic valid;
    } rt_entry_t;

    rt_entry_t rename_table [0:31];

    // write logic
    always_ff @(posedge clk) begin
        if (rst) begin
            rename_table = '0;
        end
        else begin
            if (decode_en_i) begin
                rename_table[arf_ptr_i].rob_ptr <= rob_ptr_i;
                rename_table[arf_ptr_i].pending <= 1'b1;
                rename_table[arf_ptr_i].valid <= 1'b1;
            end
            if (writeback_en_i) begin
                for (int i = 0; i < 32; i++) begin
                    if (rename_table[arf_ptr_i].rob_ptr == rob_ptr_sb_i) begin
                        rename_table[i].pending <= 1'b0;
                    end
                end
            end
            if (commit_en_i) begin
                if (rename_table[arf_ptr_rob_i].rob_ptr == rob_ptr_rob_i) begin
                    rename_table.valid <= 1'b0;
                end
            end
        end
    end

    // read logic
    assign rob_ptr_o = rename_table[arf_ptr_i].rob_ptr;
endmodule

module issue_queue #(
    parameter DATA_WIDTH = 32,
    parameter IQ_SIZE = 16,
    parameter ROB_COUNT = 32
) (
    input clk,
    input logic [DATA_WIDTH-1:0] instr_i,
    input logic wr_en_i,
    output logic [DATA_WIDTH-1:0] instr_o
);  

    typedef struct packed {
        logic [...-1:0] op;
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

    iq_entry_t iq [0:IQ_SIZE-1];

    // Write logic
    always_ff @(posedge clk) begin
        if (wr_en_i) begin
            // Find first empty slot and write instruction
            for (int i = 0; i < IQ_SIZE; i++) begin
                if (!iq[i].valid) begin
                    iq[i].instr <= instr_i;
                    iq[i].valid <= 1'b1;
                    break;
                end
            end
        end
    end

    // Read logic (simple example: read first valid instruction)
    always_comb begin
        instr_o = '0;
        for (int i = 0; i < IQ_SIZE; i++) begin
            if (iq[i].valid) begin
                instr_o = iq[i].instr;
                break;
            end
        end
    end
endmodule

module imm_gen #(
    parameter DATA_WIDTH = 32
) (
    input [31:0] instr,
    output logic [DATA_WIDTH-1:0] immediate
);
    logic [6:0] opcode;
    assign opcode = instr[6:0];

    // Internal logic for immediate generation
    always_comb begin
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
    end

endmodule