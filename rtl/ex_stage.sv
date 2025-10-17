

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

    // cntrls
    input alu_cntrl_i, // how many bits?
);
    // imm_gen
    // alu
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

    // multiplication
    logic [DATA_WIDTH*2-1:0] mul_result_unsigned;
    logic [DATA_WIDTH*2-1:0] mul_result_signed_unsigned;
    logic signed [DATA_WIDTH*2-1:0] mul_result_signed;

    assign mul_result_unsigned = a_i * b_i;
    assign mul_result_signed = $signed(a_i) * $signed(b_i);
    assign mul_result_signed_unsigned = $signed(a_i) * b_i;

    // The core ALU logic is combinational
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
            MUL:    result_o = mul_result_unsigned[DATA_WIDTH-1:0];
            MULH:   result_o = mul_result_signed[DATA_WIDTH*2-1:DATA_WIDTH];
            MULHU:  result_o = mul_result_unsigned[DATA_WIDTH*2-1:DATA_WIDTH];
            MULHSU: result_o = mul_result_signed_unsigned[DATA_WIDTH*2-1:DATA_WIDTH];
            
            default:  result_o = DATA_WIDTH'b010;
        endcase
    end

    // The Zero flag is asserted if the result_o is all zeros.
    assign zero_o = (result_o == DATA_WIDTH'b0);
endmodule

// // multi_cycle_divider.sv
// // A 33-cycle sequential divider for the RISC-V M-extension.
// module multi_cycle_divider (
//     input  logic        clk,
//     input  logic        rst_n,
    
//     // Control signals
//     input  logic        start,      // Start the division
    
//     // Data inputs
//     input  logic [31:0] dividend,   // Operand A
//     input  logic [31:0] divisor,    // Operand B
//     input  logic [1:0]  op_type,    // 00:DIV, 01:DIVU, 10:REM, 11:REMU
    
//     // Outputs
//     output logic [31:0] result,     // Quotient or Remainder
//     output logic        ready       // High when result is valid
// );

//     // Operation type mapping
//     localparam OP_DIV  = 2'b00;
//     localparam OP_DIVU = 2'b01;
//     localparam OP_REM  = 2'b10;
//     localparam OP_REMU = 2'b11;

//     // FSM states
//     typedef enum {IDLE, PREPARE, CALCULATE, FINISH} state_t;
//     state_t current_state, next_state;

//     // Internal registers
//     logic [63:0] remainder_q; // [63:32] is remainder, [31:0] is quotient
//     logic [31:0] divisor_abs;
//     logic [5:0]  count;
//     logic        dividend_sign;
//     logic        divisor_sign;

//     // Combinational logic for state transitions and calculations
//     always_comb begin
//         next_state = current_state;
//         ready = 1'b0;
        
//         case (current_state)
//             IDLE: begin
//                 if (start) begin
//                     next_state = PREPARE;
//                 end
//             end
            
//             PREPARE: begin
//                 next_state = CALCULATE;
//             end
            
//             CALCULATE: begin
//                 if (count == 32) begin
//                     next_state = FINISH;
//                 end else begin
//                     next_state = CALCULATE;
//                 end
//             end
            
//             FINISH: begin
//                 ready = 1'b1;
//                 next_state = IDLE;
//             end
//         endcase
//     end

//     // Sequential logic (state registers and data path)
//     always_ff @(posedge clk or negedge rst_n) begin
//         if (!rst_n) begin
//             current_state <= IDLE;
//             count <= 0;
//             result <= 0;
//         end else begin
//             current_state <= next_state;
            
//             case (current_state)
//                 IDLE: begin
//                     if (start) begin
//                         count <= 0;
//                     end
//                 end
                
//                 PREPARE: begin
//                     // Handle signs for DIV and REM
//                     dividend_sign = (op_type == OP_DIV || op_type == OP_REM) && dividend[31];
//                     divisor_sign  = (op_type == OP_DIV || op_type == OP_REM) && divisor[31];

//                     // Use absolute values for calculation
//                     remainder_q[31:0] <= dividend_sign ? -dividend : dividend;
//                     divisor_abs <= divisor_sign ? -divisor : divisor;
//                     remainder_q[63:32] <= 32'b0;
//                 end
                
//                 CALCULATE: begin
//                     // Shift remainder left and bring in next bit of quotient
//                     remainder_q <= {remainder_q[62:0], 1'b0};
//                     count <= count + 1;
                    
//                     // If Remainder >= Divisor, subtract and set quotient bit
//                     if ({1'b0, remainder_q[63:32]} >= {1'b0, divisor_abs}) begin
//                         remainder_q[63:32] <= remainder_q[63:32] - divisor_abs;
//                         remainder_q[0] <= 1'b1;
//                     end
//                 end
                
//                 FINISH: begin
//                     // Handle corner cases and finalize result
//                     logic [31:0] quotient = remainder_q[31:0];
//                     logic [31:0] rem = remainder_q[63:32];

//                     if (divisor == 0) begin
//                         // Division by zero
//                         result <= (op_type == OP_DIVU || op_type == OP_REMU) ? 32'hFFFFFFFF : 32'hFFFFFFFF;
//                         if(op_type == OP_REMU) result <= dividend;
//                     } else begin
//                         case (op_type)
//                             OP_DIV: result <= (dividend_sign ^ divisor_sign) ? -quotient : quotient;
//                             OP_DIVU: result <= quotient;
//                             OP_REM: result <= dividend_sign ? -rem : rem;
//                             OP_REMU: result <= rem;
//                         endcase
//                     end
//                 end
//             endcase
//         end
//     end

// endmodule


