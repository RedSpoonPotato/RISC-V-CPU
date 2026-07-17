// package general_pkg;
package general_pkg;

    // !!! PLEASE CHANGE THESE AFTER DEBUGGING
    // localparam INSTR_ADDR_OFFSET = 32'h80000000;
    // localparam DATA_ADDR_OFFSET  = 32'h80010000;

    `ifdef DEBUG
        localparam DATA_ADDR_OFFSET  = 32'h80010100;
    `endif

    // CHECK ALL OF THEEEESE
    localparam DATA_WIDTH = 32;
    localparam IQ_SIZE = 16;
    localparam ROB_COUNT = 32;
    localparam PRF_COUNT = 32;
    localparam INSTR_COMPRESS_WIDTH = 17;
    localparam MAX_EXEC_CYCLE = 2;
    localparam IMM_COMPRESS = 20;
    localparam FUNCT_COMB_WIDTH = 4; // representing funct3 + funct7
    localparam OUTCOME_DELAY = 3; // # of cycles until the "brnch_taken_i" result comes in  
    localparam MAX_MEM_INSTRS = 32;


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


module fifo_modded #(
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
            data_array = '{default:'0};
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
            // data_o <= data_array[rd_ptr[PTR_WIDTH-2:0]];
            rd_ptr <= rd_ptr + 1;
        end
    end
    assign data_o = data_array[rd_ptr[PTR_WIDTH-2:0]];

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
    input [DATA_WIDTH-1:0] data_w_i
);
    localparam ENTRIES = 2 ** REG_ADDR_WIDTH;

    logic [DATA_WIDTH-1:0] reg_mem [ENTRIES-1:0];

    always_ff @(posedge clk) begin : Writing
        if (rst) begin
            reg_mem <= '{default:'0};
            data_r_1_o <= '{default:'0};
            data_r_2_o <= '{default:'0};
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
    input [DATA_WIDTH-1:0] data_w_i
);
    localparam ENTRIES = 2 ** REG_ADDR_WIDTH;

    logic [DATA_WIDTH-1:0] reg_mem [ENTRIES-1:0];

    always_ff @(posedge clk) begin : Writing
        if (rst) begin
            reg_mem <= '{default:'0};
        end else begin
            if (write_en_i && addr_w_i != '0) begin
                reg_mem[addr_w_i] <= data_w_i;
            end
        end
    end

    always_comb begin : Reading
        data_r_1_o = (addr_r_1_i == '0) ? '0 : reg_mem[addr_r_1_i];
        data_r_2_o = (addr_r_2_i == '0) ? '0 : reg_mem[addr_r_2_i];
    end

endmodule

module sram_sync_read_dual_port_vari_width_write #(
    parameter ADDR_WIDTH = 10,
    parameter DATA_WIDTH = 32
)(
    input  logic                        clk,
    input  logic [(DATA_WIDTH/8)-1:0]   vec_wr_en,
    input  logic [ADDR_WIDTH-1:0]       rd_addr,
    input  logic [ADDR_WIDTH-1:0]       wr_addr,
    input  logic [DATA_WIDTH-1:0]       din,
    output logic [DATA_WIDTH-1:0]       dout
);
    localparam NUM_BYTES = DATA_WIDTH / 8;

    // explicitly tell the synthesizer to use Block RAM
    (* ram_style = "block" *) logic [DATA_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1];

    always_ff @(posedge clk) begin
        // Write operation with byte lane enables
        for (int i = 0; i < NUM_BYTES; i++) begin
            if (vec_wr_en[i]) begin
                mem[wr_addr][i*8 +: 8] <= din[i*8 +: 8];
            end
        end
        dout <= mem[rd_addr]; 
    end
endmodule

module sram_sync_read_dual_port #(
    parameter ADDR_WIDTH = 10,  // depth = 2^ADDR_WIDTH
    parameter DATA_WIDTH = 32
)(
    input  logic                     clk,
    input  logic                     we,
    input  logic [ADDR_WIDTH-1:0]    rd_addr,
    input  logic [ADDR_WIDTH-1:0]    wr_addr,
    input  logic [DATA_WIDTH-1:0]    din,
    output logic [DATA_WIDTH-1:0]    dout
);
    logic [DATA_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1];
    always_ff @(posedge clk) begin
        if (we) begin
            mem[wr_addr] <= din;
        end
        dout <= mem[rd_addr]; // synchronous read
    end
endmodule

module sram_sync_read #(
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

module sram_async_read #(
    parameter ADDR_WIDTH = 10,  // depth = 2^ADDR_WIDTH
    parameter DATA_WIDTH = 32,
    parameter INIT_FILE = ""
)(
    input  logic                     clk,
    input  logic                     we,        // write enable
    input  logic [ADDR_WIDTH-1:0]    addr,
    input  logic [DATA_WIDTH-1:0]    din,
    output logic [DATA_WIDTH-1:0]    dout
);
    // Memory array
    logic [DATA_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1];

    initial begin
        if (INIT_FILE != "") begin
            $readmemh(INIT_FILE, mem);
        end
    end

    always_ff @(posedge clk) begin
        if (we) begin
            mem[addr] <= din;
        end
    end
    
    assign dout = mem[addr];

endmodule