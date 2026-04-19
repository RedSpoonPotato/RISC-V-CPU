// package general_pkg;
package decode_pkg;


    localparam PRF_COUNT = 32;
    localparam DATA_WIDTH = 32;

    typedef enum logic [$clog2(6)-1:0] {R_TYPE, I_TYPE, S_TYPE, B_TYPE, U_TYPE, J_TYPE} instruction_t;

    function automatic instruction_t classify_instr (
        input [6:0] opcode
    );
    case (opcode)
        // R-Type: Register-register arithmetic/logic
        7'b0110011: return R_TYPE; // OP (ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU)
        // I-Type: Immediate arithmetic, loads, JALR, ECALL/EBREAK
        7'b0010011: return I_TYPE; // OP-IMM (ADDI, ANDI, ORI, XORI, SLTI, SLTIU, SLLI, SRLI, SRAI)
        7'b0000011: return I_TYPE; // LOAD   (LB, LH, LW, LBU, LHU)
        7'b1100111: return I_TYPE; // JALR
        7'b1110011: return I_TYPE; // SYSTEM (ECALL, EBREAK, CSR*)
        7'b0001111: return I_TYPE; // FENCE
        // S-Type: Stores
        7'b0100011: return S_TYPE; // STORE  (SB, SH, SW)
        // B-Type: Branches
        7'b1100011: return B_TYPE; // BRANCH (BEQ, BNE, BLT, BGE, BLTU, BGEU)
        // U-Type: Upper immediate
        7'b0110111: return U_TYPE; // LUI
        7'b0010111: return U_TYPE; // AUIPC
        // J-Type: Jump
        7'b1101111: return J_TYPE; // JAL
        default:    return R_TYPE; // fallback
    endcase
    endfunction

    function automatic logic is_speculative (
        input [6:0] opcode
    );
        instruction_t instr;
        instr = classify_instr(opcode);
        return instr == B_TYPE || instr == J_TYPE;
    endfunction

    function automatic logic is_store (
        input [6:0] opcode
    );
        instruction_t instr;
        instr = classify_instr(opcode);
        return instr == S_TYPE;
    endfunction

    function automatic logic has_dest (
        input [6:0] opcode
    );        
        instruction_t instr;
        instr = classify_instr(opcode);
        return !(instr == S_TYPE || instr == B_TYPE);
    endfunction

    function automatic logic has_src0 (
        input [6:0] opcode
    );
        instruction_t instr;
        instr = classify_instr(opcode);
        return !(instr == U_TYPE || instr == J_TYPE);
    endfunction

    function automatic logic has_src1 (
        input [6:0] opcode
    );
        instruction_t instr;
        instr = classify_instr(opcode);
        return instr == R_TYPE || instr == S_TYPE || instr == B_TYPE;
    endfunction

    function automatic logic has_imm (
        input [6:0] opcode
    );
        instruction_t instr;
        instr = classify_instr(opcode);
        return instr != R_TYPE;
    endfunction

endpackage


module fifo #(
    parameter DEPTH = 8,
    parameter DATA_WIDTH = 32,
    parameter type T = logic [DATA_WIDTH-1:0]
) (
    input clk,
    input rst,
    input [DATA_WIDTH-1:0] data_i,
    input rd_en_i,
    input wr_en_i,

    output logic [DATA_WIDTH-1:0] data_o,
    output logic full_o,
    output logic empty_o
);
    localparam PTR_WIDTH = $clog2(DEPTH) + 1;

    logic [DATA_WIDTH-1:0] data_array [DEPTH-1:0];
    logic [PTR_WIDTH-1:0] wr_ptr;
    logic [PTR_WIDTH-1:0] rd_ptr;

    // full and empty
    assign empty_o = (wr_ptr == rd_ptr);
    assign full_o = (wr_ptr[PTR_WIDTH-2:0] == rd_ptr[PTR_WIDTH-2:0]) && 
        (wr_ptr[PTR_WIDTH-1] != rd_ptr[PTR_WIDTH-1]);

    // writing
    always_ff @(posedge clk) begin
        if (rst) begin
            data_array = '0;
            wr_ptr = 0;
        end else if (wr_en_i) begin
            data_array[wr_ptr[PTR_WIDTH-2:0]] <= data_i;
            wr_ptr <= wr_ptr + 1;
        end
    end

    // reading
    always_ff @(posedge clk) begin
        if (rst) begin
            rd_ptr = 0;
        end else if (rd_en_i && ~empty_o) begin
            data_o <= data_array[rd_ptr[PTR_WIDTH-2:0]];
            rd_ptr <= rd_ptr + 1;
        end
    end

endmodule

module register_file_sync_read #(
    parameter DATA_WIDTH = 32,
    parameter REG_ADDR_WIDTH = 5
) (
    input clk,
    input rst,
    // reading
    input [REG_ADDR_WIDTH-1:0] addr_r_1_i,
    input [REG_ADDR_WIDTH-1:0] addr_r_2_i,
    output logic [DATA_WIDTH-1:0] data_r_1_o,
    output logic [DATA_WIDTH-1:0] data_r_2_o,

    // writing
    input write_en_i,
    input [REG_ADDR_WIDTH-1:0] addr_w_i,
    input [DATA_WIDTH-1:0] data_w_i,
);
    localparam ENTRIES = 2 ** REG_ADDR_WIDTH;

    logic [DATA_WIDTH-1:0] reg_mem [ENTRIES-1:0];

    always_ff @(posedge clk) begin : Writing
        if (rst) begin
            reg_mem <= '0;
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

module register_file_async_read #(
    parameter DATA_WIDTH = 32,
    parameter REG_ADDR_WIDTH = 5
) (
    input clk,
    input rst,
    // reading
    input [REG_ADDR_WIDTH-1:0] addr_r_1_i,
    input [REG_ADDR_WIDTH-1:0] addr_r_2_i,
    output logic [DATA_WIDTH-1:0] data_r_1_o,
    output logic [DATA_WIDTH-1:0] data_r_2_o,

    // writing
    input write_en_i,
    input [REG_ADDR_WIDTH-1:0] addr_w_i,
    input [DATA_WIDTH-1:0] data_w_i,
);
    localparam ENTRIES = 2 ** REG_ADDR_WIDTH;

    logic [DATA_WIDTH-1:0] reg_mem [ENTRIES-1:0];

    always_ff @(posedge clk) begin : Writing
        if (rst) begin
            reg_mem <= '0;
        end else begin
            if (write_en_i) begin
                reg_mem[addr_w_i] <= data_w_i;
            end
        end
    end

    always_comb begin : Reading
        data_r_1_o = reg_mem[addr_r_1_i];
        data_r_2_o = reg_mem[addr_r_2_i];
    end

endmodule


// ai-generated
module sram #(
    parameter ADDR_WIDTH = 10,  // depth = 2^ADDR_WIDTH
    parameter DATA_WIDTH = 32
)(
    input  logic                     clk,
    input  logic                     we,        // write enable
    input  logic [ADDR_WIDTH-1:0]    addr,
    input  logic [DATA_WIDTH-1:0]    din,
    output logic [DATA_WIDTH-1:0]    dout
);
    // Memory array
    logic [DATA_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1];

    always_ff @(posedge clk) begin
        if (we) begin
            mem[addr] <= din;
        end
        dout <= mem[addr]; // synchronous read
    end

endmodule