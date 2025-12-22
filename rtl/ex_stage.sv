

module ex_stage #(
    parameter DATA_WIDTH = 32,
    parameter INSTR_WIDTH = 32,

) (
    input clk,
    input [30] instr_30_i,
    input [14:12] instr_14_12_i,

    // cntrls
    input alu_cntrl_i, // how many bits?

);
    // integer path
    
    // floating-point path

    

endmodule

module integer_path #(
    parameter DATA_WIDTH = 32,
    parameter INSTR_WIDTH = 32
) (
    input clk,
    input [30]      instr_30_i,
    input [14:12]   instr_14_12_i,
    
    // data inputs
    input  [DATA_WIDTH-1:0] a_i,
    input  [DATA_WIDTH-1:0] b_i,

    // data outputs
    output logic [DATA_WIDTH-1:0] result_o,
    output logic zero_o,

    // control inputs

);

    // alu_cntrl_i
    logic [4:0] alu_cntrl_i;


    // alu
    integer_alu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) int_alu_inst (
        .a_i        (a_i),
        .b_i        (b_i),
        .alu_cntrl_i(alu_cntrl_i),
        .result_o   (result_o),
        .zero_o     (zero_o)
    );


    
    // multiplier/divider

endmodule



module integer_alu #(
    parameter DATA_WIDTH = 32,
) (
    input  [DATA_WIDTH-1:0] a_i,
    input  [DATA_WIDTH-1:0] b_i
    input  [4:0]  alu_cntrl_i,
    output logic [DATA_WIDTH-1:0] result_o,
    output logic zero_o
);
    // RV32I opcodes
    localparam ADD  = 5'b00000;
    localparam SLL  = 5'b00001;
    localparam SLT  = 5'b00010;
    localparam SLTU = 5'b00011;
    localparam XOR  = 5'b00100;
    localparam SRL  = 5'b00101;
    localparam OR   = 5'b00110;
    localparam AND  = 5'b00111;
    localparam SUB  = 5'b01000;
    localparam SRA  = 5'b01101;
    
    // RV32M opcodes
    localparam MUL    = 5'b10000; // lower 32 bits
    localparam MULH   = 5'b10001; // upper 32 bits
    localparam MULHSU = 5'b10010; // upper 32 bits of A * unsign(B)
    localparam MULHU  = 5'b10011; // upper 32 bits of unsign(A) * unsign(B)

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
            
            // RV32M
            MUL:    result_o =         ($signed(a_i) * $signed(b_i))[DATA_WIDTH-1:0];
            MULH:   result_o =         ($signed(a_i) * $signed(b_i))[DATA_WIDTH*2-1:DATA_WIDTH];
            MULHSU: result_o = ($signed(a_i) * $signed({1'b0, b_i}))[DATA_WIDTH*2-1:DATA_WIDTH];
            MULHU:  result_o =                           (a_i * b_i)[DATA_WIDTH*2-1:DATA_WIDTH];

            // will add rest of rv32m instructions later
            
            default:  result_o = DATA_WIDTH'b010;
        endcase
    end

    // The Zero flag is asserted if the result_o is all zeros.
    assign zero_o = (result_o == DATA_WIDTH'b0);

endmodule
