module mem_stage #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
) (
    input  clk,
    input  rst,
    input  [DATA_WIDTH-1:0] addr_i,
    input  [DATA_WIDTH-1:0] data_w_i,
    input  write_en_i,
    output logic [DATA_WIDTH-1:0] data_r_o
);

    

    data_mem #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) data_mem_inst (
        .addr_r_i(addr_i),
        .data_r_o(data_r_o),
        .clk(clk),
        .rst(rst),
        .addr_w_i(addr_i),
        .data_w_i(data_w_i),
        .write_en_i(write_en_i)
    );   

endmodule

module data_mem #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH  = 32,
    parameter ENTRIES = 2 ** 20
) (
    // reading
    input addr_r_i,
    output logic data_r_o,

    input clk,
    input rst,

    // writing
    input addr_w_i,
    input data_w_i,
    input write_en_i
);
    assert($clog2(ENTRIES) <= ADDR_WIDTH);

    logic [ENTRIES-1:0] mem [ADDR_WIDTH-1:0];

    always_ff @(posedge clk) begin
        if (rst) begin
            mem <= '0;
        end else begin
            data_r_o <= mem[addr_r_i];
            if (write_en_i)
                mem[addr_w_i] <= data_w_i;
        end
    end
endmodule

