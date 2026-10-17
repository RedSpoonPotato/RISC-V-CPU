module req_fifo
import cache_pkg::*;
(
    input t_clk,
    input r_clk,
    input rst,
    cache_if.slave cpu_s,
    cache_if.master cache_m
);
    logic [REQ_DATA_WIDTH-1:0] fifo_mem [REQ_FIFO_DEPTH-1:0];
    // transmitter signals
    logic [$clog2(REQ_FIFO_DEPTH):0] t_wr_ptr, t_rd_ptr;
    logic t_full;
    logic [REQ_DATA_WIDTH-1:0] t_entry_data;
    // receiver signals
    logic [$clog2(REQ_FIFO_DEPTH):0] r_wr_ptr, r_rd_ptr;
    logic r_empty;

    assign t_full = t_wr_ptr[$clog2(REQ_FIFO_DEPTH)] != t_rd_ptr[$clog2(REQ_FIFO_DEPTH)] && t_wr_ptr[$clog2(REQ_FIFO_DEPTH)-1:0] == t_rd_ptr[$clog2(REQ_FIFO_DEPTH)-1:0];
    assign r_empty = r_wr_ptr == r_rd_ptr;

    // synchronizers (do we need another stage for it to bev considered synchronized?)
    always_ff @(posedge t_clk) begin
        t_rd_ptr <= r_rd_ptr;
    end
    always_ff @(posedge r_clk) begin
        r_wr_ptr <= t_wr_ptr;
    end

    // transmitter domain
    always_ff @(posedge t_clk or posedge rst) begin
        if (rst) begin
            t_wr_ptr <= '0;
            t_rd_ptr <= '0;
        end else begin
            if (!t_full && cpu_s.req_valid) begin
                fifo_mem[t_wr_ptr[$clog2(REQ_FIFO_DEPTH)-1:0]] <= t_entry_data;
                t_wr_ptr <= t_wr_ptr + 1;
            end
        end
    end
    // receiver domain
    always_ff @(posedge r_clk or posedge rst) begin
        if (rst) begin
            r_wr_ptr <= '0;
            r_rd_ptr <= '0;
        end else begin
            if (!r_empty && cache_m.req_ready) begin
                r_rd_ptr <= r_rd_ptr + 1;
            end
        end
    end

    // fifo entry data in
    assign t_entry_data = {cpu_s.wr_en, cpu_s.addr, cpu_s.wr_data, cpu_s.mem_op_info};
    // fifo entry data out
    assign cache_m.wr_en = fifo_mem[r_rd_ptr[$clog2(REQ_FIFO_DEPTH)-1:0]][REQ_DATA_WIDTH-1];
    assign cache_m.addr = fifo_mem[r_rd_ptr[$clog2(REQ_FIFO_DEPTH)-1:0]][REQ_DATA_WIDTH-2 -: ADDR_WIDTH];
    assign cache_m.wr_data = fifo_mem[r_rd_ptr[$clog2(REQ_FIFO_DEPTH)-1:0]][REQ_DATA_WIDTH-2-ADDR_WIDTH -: DATA_WIDTH];
    assign cache_m.mem_op_info = fifo_mem[r_rd_ptr[$clog2(REQ_FIFO_DEPTH)-1:0]][REQ_DATA_WIDTH-2-ADDR_WIDTH-DATA_WIDTH -: MEM_OP_INFO_WIDTH];

    // other signals
    cpu_s.req_ready = !t_full;
    cache_m.req_valid = !r_empty;
endmodule


interface cache_if
import decode_pkg::*;
import general_pkg::*;
import issue_pkg::*;
import exec_mem_pkg::*;
import writeback_pkg::*;
import cache_pkg::*;
(
    input logic clk
);
    // request signals
    logic wr_en; // aka "store"
    logic [ADDR_WIDTH-1:0] addr;
    logic [DATA_WIDTH-1:0] wr_data;
    logic [MEM_OP_INFO_WIDTH-1:0] mem_op_info;
    logic req_valid;
    logic req_ready;

    // response signals
    logic [DATA_WIDTH-1:0] rd_data;
    logic [MEM_RESP_INFO_WIDTH-1:0] mem_resp_info;
    logic resp_valid;
    logic resp_ready;

    modport master (
        input clk,
        output wr_en,
        output addr,
        output wr_data,
        output mem_op_info,
        output req_valid,
        input req_ready,
        input rd_data,
        input mem_resp_info,
        input resp_valid,
        output resp_ready
    );

    modport slave (
        input clk,
        input wr_en,
        input addr,
        input wr_data,
        input mem_op_info,
        input req_valid,
        output req_ready,
        output mem_resp_info,
        output rd_data,
        output resp_valid,
        input resp_ready
    );

endinterface