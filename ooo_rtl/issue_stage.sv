module issue_stage #(
    parameter DATA_WIDTH = 32,
    parameter INSTR_WIDTH = 32,

) (
    input [INSTR_WIDTH-1:0] instr_i,
    // cntrls
    
    input clk,

    // external comms
    // writeback stage w for scoreboard

    /*
        external comms
            slave
                scoreboard w at writebackstage
    */


    output logic 

);
    // imm gen

    // internal comms
    // scoreboard r/w



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