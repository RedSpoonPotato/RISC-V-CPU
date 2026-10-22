// NOTE: check all modules with Gemini before moving on

// NOTE: ENSURE that the fifos are synthesizig to BRAMs

module req_skid_buffer
import cache_pkg::*;
(
    input clk,
    input rst,
    // fifo interface signals and state
    input empty_i,
    input [REQ_DATA_WIDTH-1:0] fifo_dout_i,
    output fifo_rd_en_o, // i think
    // cache interface
    cache_if.master master
);
    logic fwft_valid;
    logic [REQ_DATA_WIDTH-1:0] fwft_data, fifo_dout_i;
    // tracks if a read was issued to the BRAM in the *previous* clock cycle
    logic read_in_flight; 

    // we pull from the BRAM if it has data AND (the skid buffer is empty OR the cache is taking the current data)
    assign fifo_rd_en_o = !empty_i && (!fwft_valid || master.req_ready);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            read_in_flight <= 1'b0;
        end else begin
            read_in_flight <= fifo_rd_en_o;
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            fwft_valid <= 1'b0;
        end else begin
            if (read_in_flight) begin // data came in this cycle
                fwft_valid <= 1'b1; 
            end else if (master.req_ready) begin // cache consumed the data, and nothing new arrived
                fwft_valid <= 1'b0; 
            end
        end
    end

    always_ff @(posedge clk) begin
        // only latch new BRAM data if a read just finished, we actually have room to store it (or the old data is leaving this cycle)
        if (read_in_flight && (!fwft_valid || master.req_ready)) begin
            fwft_data <= fifo_dout_i;
        end
    end

    assign master.req_valid   = fwft_valid;
    assign master.wr_en       = fwft_data[REQ_DATA_WIDTH-1];
    assign master.addr        = fwft_data[REQ_DATA_WIDTH-2 -: ADDR_WIDTH];
    assign master.wr_data     = fwft_data[REQ_DATA_WIDTH-2-ADDR_WIDTH -: DATA_WIDTH];
    assign master.mem_op_info = fwft_data[0 +: MEM_OP_INFO_WIDTH];
endmodule

module req_fifo
import cache_pkg::*;
(
    input t_clk,
    input r_clk,
    input rst,
    cache_if.slave slave,
    // cache_if.master master,
    // cntrl
    input  rd_en_i,
    output empty_o,
    output [REQ_DATA_WIDTH-1:0] data_o
);
    logic [REQ_DATA_WIDTH-1:0] fifo_mem [REQ_FIFO_DEPTH-1:0];
    // transmitter signals
    logic [$clog2(REQ_FIFO_DEPTH):0] t_wr_ptr, t_rd_ptr, t_rd_ptr_unsync_gray, t_rd_ptr_sync_gray, t_rd_ptr;
    logic [$clog2(REQ_FIFO_DEPTH):0] next_t_wr_ptr, next_t_wr_ptr_gray, t_wr_ptr_gray;
    logic t_full;
    logic [REQ_DATA_WIDTH-1:0] t_entry_data;
    // receiver signals
    logic [$clog2(REQ_FIFO_DEPTH):0] r_wr_ptr, r_rd_ptr, r_wr_ptr_unsync_gray, r_wr_ptr_sync_gray, r_wr_ptr;
    logic [$clog2(REQ_FIFO_DEPTH):0] next_r_rd_ptr, next_r_rd_ptr_gray, r_rd_ptr_gray;
    logic r_empty;

    assign t_full = t_wr_ptr[$clog2(REQ_FIFO_DEPTH)] != t_rd_ptr[$clog2(REQ_FIFO_DEPTH)] 
        && t_wr_ptr[$clog2(REQ_FIFO_DEPTH)-1:0] == t_rd_ptr[$clog2(REQ_FIFO_DEPTH)-1:0];
    assign r_empty = r_wr_ptr == r_rd_ptr;

    // synchronizers (do we need another stage for it to bev considered synchronized?)
    always_ff @(posedge t_clk) begin
        if (rst) begin
            t_rd_ptr_unsync_gray <= '0;
            t_rd_ptr_sync_gray <= '0;
        end else begin
            t_rd_ptr_unsync_gray <= r_rd_ptr_gray;
            t_rd_ptr_sync_gray <= t_rd_ptr_unsync_gray;
        end
    end
    always_ff @(posedge r_clk) begin
        if (rst) begin
            r_wr_ptr_unsync_gray <= '0;
            r_wr_ptr_sync_gray <= '0;
        end else begin
            r_wr_ptr_unsync_gray <= t_wr_ptr_gray;
            r_wr_ptr_sync_gray <= r_wr_ptr_unsync_gray;
        end
    end

    // converting from gray to binary
    always_comb begin
        for (int i = $clog2(REQ_FIFO_DEPTH); i >= 0; i--) begin
            if (i == $clog2(REQ_FIFO_DEPTH)) begin
                t_rd_ptr[i] = t_rd_ptr_sync_gray[i];
                r_wr_ptr[i] = r_wr_ptr_sync_gray[i];
            end else begin
                t_rd_ptr[i] = t_rd_ptr[i+1] ^ t_rd_ptr_sync_gray[i];
                r_wr_ptr[i] = r_wr_ptr[i+1] ^ r_wr_ptr_sync_gray[i];
            end
        end
    end

    // next pointer calculations for synchronizing
    assign next_t_wr_ptr = t_wr_ptr + 1;
    assign next_t_wr_ptr_gray = next_t_wr_ptr ^ (next_t_wr_ptr >> 1);
    assign next_r_rd_ptr = r_rd_ptr + 1;
    assign next_r_rd_ptr_gray = next_r_rd_ptr ^ (next_r_rd_ptr >> 1);

    // transmitter domain
    always_ff @(posedge t_clk or posedge rst) begin
        if (rst) begin
            t_wr_ptr <= '0;
            // t_rd_ptr <= '0;
            t_wr_ptr_gray <= '0;
        end else begin
            if (!t_full && slave.req_valid) begin
                fifo_mem[t_wr_ptr[$clog2(REQ_FIFO_DEPTH)-1:0]] <= t_entry_data;
                t_wr_ptr <= next_t_wr_ptr;
                t_wr_ptr_gray <= next_t_wr_ptr_gray;
            end
        end
    end
    // receiver domain
    always_ff @(posedge r_clk or posedge rst) begin
        if (rst) begin
            // r_wr_ptr <= '0;
            r_rd_ptr <= '0;
            r_rd_ptr_gray <= '0;
        end else begin
            // if (!r_empty && master.req_ready) begin
            if (rd_en_i) begin
                data_o <= fifo_mem[r_rd_ptr[$clog2(REQ_FIFO_DEPTH)-1:0]]; // to make sync read
                r_rd_ptr <= next_r_rd_ptr;
                r_rd_ptr_gray <= next_r_rd_ptr_gray;
            end
        end
    end

    assign empty_o = r_empty;

    // fifo entry data in
    assign t_entry_data = {slave.wr_en, slave.addr, slave.wr_data, slave.mem_op_info};

    // other signals
    assign slave.req_ready = !t_full;
    // assign master.req_valid = !r_empty;
endmodule

module req_comm (
    input t_clk,
    input r_clk,
    input rst,
    cache_if.slave slave,
    cache_if.master master
);
    
    logic fifo_rd_en, fifo_empty;
    logic [REQ_DATA_WIDTH-1:0] fifo_data;
    req_fifo req_fifo_inst (
        .t_clk(t_clk),
        .r_clk(r_clk),
        .rst(rst),
        .slave(slave),
        .rd_en_i(fifo_rd_en),
        .empty_o(fifo_empty),
        .data_o(fifo_data)
    );

    req_skid_buffer skid_buffer_inst (
        .clk(r_clk),
        .rst(rst),
        .empty_i(fifo_empty),
        .fifo_dout_i(fifo_data),
        .fifo_rd_en_o(fifo_rd_en),     
        .master(master)
    );

endmodule

module resp_skid_buffer (
    input clk,
    input rst,
    input empty_i,
    input [RESP_DATA_WIDTH-1:0] fifo_dout_i,
    output fifo_rd_en_o,
    cache_if.slave slave
);
    logic fwft_valid;
    logic [RESP_DATA_WIDTH-1:0] fwft_data, fifo_dout_i;
    // tracks if a read was issued to the BRAM in the *previous* clock cycle
    logic read_in_flight; 

    // we pull from the BRAM if it has data AND (the skid buffer is empty OR the cache is taking the current data)
    assign fifo_rd_en_o = !empty_i && (!fwft_valid || slave.resp_ready);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            read_in_flight <= 1'b0;
        end else begin
            read_in_flight <= fifo_rd_en_o;
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            fwft_valid <= 1'b0;
        end else begin
            if (read_in_flight) begin // data came in this cycle
                fwft_valid <= 1'b1; 
            end else if (slave.resp_ready) begin // cache consumed the data, and nothing new arrived
                fwft_valid <= 1'b0; 
            end
        end
    end

    always_ff @(posedge clk) begin
        // only latch new BRAM data if a read just finished, we actually have room to store it (or the old data is leaving this cycle)
        if (read_in_flight && (!fwft_valid || slave.resp_ready)) begin
            fwft_data <= fifo_dout_i;
        end
    end

    assign slave.resp_valid = fwft_valid;
    assign slave.rd_data    = fwft_data[RESP_DATA_WIDTH-1:DATA_WIDTH];
    assign slave.resp_info  = fwft_data[MEM_RESP_INFO_WIDTH-1:0];
endmodule

START HERE

module resp_fifo (
    input t_clk,
    input r_clk,
    input rst,
    cache_if.master cpu_m,
    cache_if.slave cache_s
);
    logic [RESP_DATA_WIDTH-1:0] fifo_mem [RESP_FIFO_DEPTH-1:0];
    // transmitter signals
    logic [$clog2(RESP_FIFO_DEPTH):0] t_wr_ptr, t_rd_ptr;
    logic t_full;
    logic [RESP_DATA_WIDTH-1:0] t_entry_data;
    // receiver signals
    logic [$clog2(RESP_FIFO_DEPTH):0] r_wr_ptr, r_rd_ptr;
    logic r_empty;

    assign t_full = t_wr_ptr[$clog2(RESP_FIFO_DEPTH)] != t_rd_ptr[$clog2(RESP_FIFO_DEPTH)] && 
        t_wr_ptr[$clog2(RESP_FIFO_DEPTH)-1:0] == t_rd_ptr[$clog2(RESP_FIFO_DEPTH)-1:0];
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
            if (!t_full && cache_s.resp_valid) begin
                fifo_mem[t_wr_ptr[$clog2(RESP_FIFO_DEPTH)-1:0]] <= t_entry_data;
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
            if (!r_empty && cpu_m.resp_ready) begin
                r_rd_ptr <= r_rd_ptr + 1;
            end
        end
    end

    // fifo entry data in
    assign t_entry_data = {cache_s.rd_data, cache_s.mem_resp_info};
    // fifo entry data out
    assign cpu_m.rd_data = fifo_mem[r_rd_ptr[$clog2(RESP_FIFO_DEPTH)-1:0]][RESP_DATA_WIDTH-1:DATA_WIDTH];
    assign cpu_m.mem_resp_info = fifo_mem[r_rd_ptr[$clog2(RESP_FIFO_DEPTH)-1:0]][MEM_RESP_INFO_WIDTH-1:0];

    // other signals
    assign cache_s.resp_ready = !t_full;
    assign cpu_m.resp_valid = !r_empty;

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