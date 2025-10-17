module id_stage #(
    parameter DATA_WIDTH = 32,
    parameter INSTR_WIDTH = 32,

) (
    input [INSTR_WIDTH-1:0] instr_i,
    // cntrls
    
    input clk,

    output logic 

);

    // register file

    // addr for branch targets

    // imm_gen

endmodule


module register_file #(
    parameter DATA_WIDTH = 32,
    parameter REG_ADDR_WIDTH = 5
) (
    // reading
    input [REG_ADDR_WIDTH-1:0] addr_r_1_i,
    input [REG_ADDR_WIDTH-1:0] addr_r_2_i,
    output logic [DATA_WIDTH-1:0] data_r_1_o,
    output logic [DATA_WIDTH-1:0] data_r_2_o,

    // writing
    input write_en_i,
    input [REG_ADDR_WIDTH-1:0] addr_w_i,
    input [DATA_WIDTH-1:0] data_w_i,

    input clk,
    input rst
);
    localparam ENTRIES = 2 ** REG_ADDR_WIDTH;

    logic [DATA_WIDTH-1:0] reg_mem [ENTRIES-1:0];

    always_ff @(posedge clk) begin : Writing
        if (rst) begin
            reg <= '0;
        end else begin
            if (write_en_i) begin
                reg_mem[addr_w_i] <= data_w_i;
            end
        end
    end

    always_ff @(posedge clk) begin : Reading
        data_r_1_o <= reg_mem[addr_r_1_i];
        data_r_2_o <= reg_mem[addr_r_2_i];
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