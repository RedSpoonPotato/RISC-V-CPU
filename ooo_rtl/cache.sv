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
    assign master.addr        = fwft_data[REQ_DATA_WIDTH-2 -: DATA_WIDTH];
    assign master.wr_data     = fwft_data[REQ_DATA_WIDTH-2-DATA_WIDTH -: DATA_WIDTH];
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

    // fifo entry data in
    assign t_entry_data = {slave.wr_en, slave.addr, slave.wr_data, slave.mem_op_info};

    // other signals
    assign slave.req_ready = !t_full;
    // assign master.req_valid = !r_empty;
    assign empty_o = r_empty;

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

module resp_fifo (
    input t_clk,
    input r_clk,
    input rst,
    cache_if.master master
    // cache_if.slave cache_s
    input  rd_en_i,
    output empty_o,
    output [RESP_DATA_WIDTH-1:0] data_o
);
    logic [RESP_DATA_WIDTH-1:0] fifo_mem [RESP_FIFO_DEPTH-1:0];
    // transmitter signals
    logic [$clog2(RESP_FIFO_DEPTH):0] t_wr_ptr, t_rd_ptr, t_rd_ptr_unsync_gray, t_rd_ptr_sync_gray, t_rd_ptr;
    logic [$clog2(RESP_FIFO_DEPTH):0] next_t_wr_ptr, next_t_wr_ptr_gray, t_wr_ptr_gray;
    logic t_full;
    logic [RESP_DATA_WIDTH-1:0] t_entry_data;
    // receiver signals
    logic [$clog2(RESP_FIFO_DEPTH):0] r_wr_ptr, r_rd_ptr, r_wr_ptr_unsync_gray, r_wr_ptr_sync_gray, r_wr_ptr;
    logic [$clog2(RESP_FIFO_DEPTH):0] next_r_rd_ptr, next_r_rd_ptr_gray, r_rd_ptr_gray;
    logic r_empty;

    assign t_full = t_wr_ptr[$clog2(RESP_FIFO_DEPTH)] != t_rd_ptr[$clog2(RESP_FIFO_DEPTH)] && 
        t_wr_ptr[$clog2(RESP_FIFO_DEPTH)-1:0] == t_rd_ptr[$clog2(RESP_FIFO_DEPTH)-1:0];
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
        for (int i = $clog2(RESP_FIFO_DEPTH); i >= 0; i--) begin
            if (i == $clog2(RESP_FIFO_DEPTH)) begin
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
            if (!t_full && master.resp_valid) begin
                fifo_mem[t_wr_ptr[$clog2(RESP_FIFO_DEPTH)-1:0]] <= t_entry_data;
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
                data_o <= fifo_mem[r_rd_ptr[$clog2(RESP_FIFO_DEPTH)-1:0]]; // to make sync read
                r_rd_ptr <= next_r_rd_ptr;
                r_rd_ptr_gray <= next_r_rd_ptr_gray;
            end
        end
    end

    // fifo entry data in
    assign t_entry_data = {master.rd_data, master.mem_resp_info};

    // other signals
    assign master.resp_ready = !t_full;
    assign empty_o = r_empty;

endmodule

module resp_comm (
    input t_clk,
    input r_clk,
    input rst,
    cache_if.slave slave,
    cache_if.master master
);

    logic fifo_rd_en, fifo_empty;
    logic [RESP_DATA_WIDTH-1:0] fifo_data;
    resp_fifo resp_fifo_inst (
        .t_clk(t_clk),
        .r_clk(r_clk),
        .rst(rst),
        .master(master),
        .rd_en_i(fifo_rd_en),
        .empty_o(fifo_empty),
        .data_o(fifo_data)
    );

    resp_skid_buffer skid_buffer_inst (
        .clk(r_clk),
        .rst(rst),
        .empty_i(fifo_empty),
        .fifo_dout_i(fifo_data),
        .fifo_rd_en_o(fifo_rd_en),     
        .slave(slave)
    );

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
    logic [DATA_WIDTH-1:0] addr;
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

interface axi4_if #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32, // Often 64 or 128 for DDR interfaces
    parameter ID_WIDTH   = 4
)(
    input logic clk,
    input logic rst_n
);
    // Write Address Channel (AW)
    logic [ID_WIDTH-1:0]   awid;
    logic [ADDR_WIDTH-1:0] awaddr;
    logic [7:0]            awlen;   // Burst length
    logic [2:0]            awsize;  // Burst size (bytes per beat)
    logic [1:0]            awburst; // Burst type
    logic                  awvalid;
    logic                  awready;

    // Write Data Channel (W)
    logic [DATA_WIDTH-1:0] wdata;
    logic [(DATA_WIDTH/8)-1:0] wstrb; // Byte enables
    logic                  wlast; // Indicates last transfer in a burst
    logic                  wvalid;
    logic                  wready;

    // Write Response Channel (B)
    logic [ID_WIDTH-1:0]   bid;
    logic [1:0]            bresp;
    logic                  bvalid;
    logic                  bready;

    // Read Address Channel (AR)
    logic [ID_WIDTH-1:0]   arid;
    logic [ADDR_WIDTH-1:0] araddr;
    logic [7:0]            arlen;
    logic [2:0]            arsize;
    logic [1:0]            arburst;
    logic                  arvalid;
    logic                  arready;

    // Read Data Channel (R)
    logic [ID_WIDTH-1:0]   rid;
    logic [DATA_WIDTH-1:0] rdata;
    logic [1:0]            rresp;
    logic                  rlast;
    logic                  rvalid;
    logic                  rready;

    modport master (
        input clk, rst_n,
        output awid, awaddr, awlen, awsize, awburst, awvalid, input awready,
        output wdata, wstrb, wlast, wvalid, input wready,
        input bid, bresp, bvalid, output bready,
        output arid, araddr, arlen, arsize, arburst, arvalid, input arready,
        input rid, rdata, rresp, rlast, rvalid, output rready
    );

    modport slave (
        input clk, rst_n,
        input awid, awaddr, awlen, awsize, awburst, awvalid, output awready,
        input wdata, wstrb, wlast, wvalid, output wready,
        output bid, bresp, bvalid, input bready,
        input arid, araddr, arlen, arsize, arburst, arvalid, output arready,
        output rid, rdata, rresp, rlast, rvalid, input rready
    );

    function automatic void set_master_defaults();
            arvalid = 1'b0;
            araddr  = '0;
            arid    = '0;
            arlen   = CACHE_LINE_BURST_LEN;
            arsize  = AXI_SIZE;
            arburst = 2'b01; // INCR
            
            rready  = 1'b0;

            awvalid = 1'b0;
            awaddr  = '0;
            awid    = '0;
            awlen   = 8'h00; // Single beat
            awsize  = AXI_SIZE;
            awburst = 2'b01; // INCR
            
            wvalid  = 1'b0;
            wdata   = '0;
            wstrb   = '0;
            wlast   = 1'b0;
            
            bready  = 1'b0;
    endfunction

endinterface

// could make this an ultra ram instead of bram
module cache_sram 
import cache_pkg::*;
(
    input  logic                        clk,
    input  logic [(DATA_WIDTH/8)-1:0]   byte_wr_en_i,
    input  logic [INDEX_WIDTH-1:0]      addr_index_i,
    input  logic [BLOCK_OFFSET-1:0]     addr_block_offset_i, // can be 0 for v2
    input  logic [DATA_WIDTH-1:0]       data_i,
    output logic [DATA_WIDTH-1:0]       data_o
);
    (* ram_style = "block" *)
    logic [LINE_WIDTH-1:0] mem [CACHE_LINES-1:0];

    logic [LINE_WIDTH-1:0] sram_out, sram_in;
    logic [(LINE_WIDTH/8)-1:0] sram_line_byte_wr_en;
    logic [BLOCK_OFFSET-1:0]     addr_block_offset_ff;
    assign sram_line_byte_wr_en = {{(LINE_WIDTH/8 - DATA_WIDTH/8){1'b0}}, byte_wr_en_i} << (addr_block_offset_i);
    assign sram_in = {{(LINE_WIDTH - DATA_WIDTH){1'b0}}, data_i} << (addr_block_offset_i*8);

    always_ff @(posedge clk) begin
        addr_block_offset_ff <= addr_block_offset_i;
        for (int i = 0; i < (LINE_WIDTH/8); i++) begin
            if (sram_line_byte_wr_en[i]) begin
                mem[addr_index_i][i*8 +: 8] <= sram_in[i*8 +: 8];
            end
        end
        sram_out <= mem[addr_index_i];
    end

    assign data_o = (sram_out >> (addr_block_offset_ff*8))[DATA_WIDTH-1:0];

endmodule


/*
    Current Cache Policy:
        - Write-back
        - Write-no-allocate
        - LRU replacement
*/

// for all the flpiflfops, need remember to determine if we need to reset them
// also need to ensure certain logic is not latching (aka set alternate case)
// DONE FORGET TO UPDATE STATE OF CACHE DATA ND CAHCE INFO FOR EVERYCASE
// DONT FORGET LRU CACHE REPLACEMENT LOGIC
// NEED TO FULLY COMBINE data response register that we return to CPU from a load in ALL CASES
module cache
import cache_pkg::*;
(
    input logic clk,
    input logic rst,
    cache_if.slave cpu_if,
    axi4_if.master axi_if
);
    // incoming cache inputs
    // logic                       incom_wr_en;
    // logic [DATA_WIDTH-1:0]      incom_data;
    // logic [2:0]                 incom_funct_code;
    // logic [MEM_RESP_INFO_WIDTH-1:0] incom_mem_resp_info;
    // incoming cache addr (sorted)
    logic [TAG_WIDTH-1:0]       incom_tag;
    logic [INDEX_WIDTH-1:0]     incom_index;
    logic [BLOCK_OFFSET-1:0] incom_block_offset;
    // detection of unaligned addresses
    logic [2:0] incom_funct_code;
    logic [$clog2(MAX_LSQ_INSTRS)-1:0] incom_lsq_ptr;
    logic [(DATA_WIDTH/8)-1:0] incom_byte_wr_en;
    logic [$clog2(EXCEPTION_COUNTER_MAX)-1:0] incom_e_counter;
    logic [$clog2(MAX_LQ_INSTRS)-1:0] incom_lq_ptr;


    logic cache_unaligned, cache_unaligned_ff;
    // registers
    logic                       store_ff;
    // logic [ADDR_WIDTH-1:0]      addr, addr_v2;
    logic [ADDR_WIDTH-1:0]      addr_v2;
    logic [DATA_WIDTH-1:0]      data;
    logic [MEM_RESP_INFO_WIDTH-1:0] mem_resp_info_ff;
    // additional signals for case of unaligned accesses
    logic [(DATA_WIDTH/8)-1:0] byte_wr_en, byte_wr_en_v2;
    // additional registers for case of unaligned accesses
    logic [(DATA_WIDTH/8)-1:0] byte_wr_en_ff_v2;
    logic [ADDR_WIDTH-1:0]      addr_ff_v2;
    logic [DATA_WIDTH-1:0]      data_ff_v2;

    // output registers
    logic [$clog2(MAX_LQ_INSTRS)-1:0] lq_ptr_ff;
    logic [$clog2(EXCEPTION_COUNTER_MAX)-1:0] e_counter_ff;
    logic [DATA_WIDTH-1:0] data_ff;

    // stage for unlaigned access case
    logic stage_2_ff;

    cache_line_state_t cache_lines [CACHE_LINES-1:0];
    cache_state_t state, next_state;
    
    assign incom_tag    = cpu_if.addr[ADDR_WIDTH-1 -: TAG_WIDTH];
    assign incom_index  = cpu_if.addr[BLOCK_OFFSET +: INDEX_WIDTH];
    assign incom_block_offset = cpu_if.addr[BLOCK_OFFSET-1:0];
    // assign incom_data = cpu_if.wdata;
    // assign incom_funct_code = cpu_if.funct_code;
    // assign incom_mem_resp_info = cpu_if.mem_resp_info;

    // state variable
    // logic v2_ff; // dont actually think we need, can use combination signaal instead

    // logic sram_wr_en;
    logic [(DATA_WIDTH/8)-1:0]   sram_byte_wr_en;
    logic [INDEX_WIDTH-1:0] sram_index;
    logic [BLOCK_OFFSET-1:0] sram_addr_block_offset;
    logic [DATA_WIDTH-1:0] sram_data_in, sram_data_out;
    data_ram cache_sram (
        .clk(clk),
        .byte_wr_en_i(sram_byte_wr_en),
        .addr_index_i(sram_index),
        .addr_block_offset_i(sram_addr_block_offset),
        .data_i(sram_data_in),
        .data_o(sram_data_out)
    );

    // logic hit_v1;
    always_comb begin
        incom_funct_code = cpu_if.mem_op_info[$clog2(MAX_LSQ_INSTRS)+2:$clog2(MAX_LSQ_INSTRS)];
        incom_byte_wr_en = cpu_if.mem_op_info[$clog2(EXCEPTION_COUNTER_MAX)+$clog2(MAX_LQ_INSTRS)+(DATA_WIDTH/8)-1:$clog2(EXCEPTION_COUNTER_MAX)+$clog2(MAX_LQ_INSTRS)];
        cache_unaligned = detect_cache_unaligned(cpu_if.addr, cpu_if.wr_en, incom_funct_code, incom_byte_wr_en);
        addr_v2 = set_aligned_addr_v2(cpu_if.addr);
        set_aligned_byte_wr_ens(incom_byte_wr_en, cpu_if.addr, cpu_if.wr_en, incom_funct_code, byte_wr_en, byte_wr_en_v2);
    end

    // logic for hit logic (direct mapped for now)
    logic [INDEX_WIDTH-1:0] cache_index_input;
    logic [TAG_WIDTH-1:0] cache_tag_input;
    logic hit_output;
    always_comb begin
        if (state == IDLE) begin
            cache_index_input   = incom_index;
            cache_tag_input     = incom_tag;
        end else begin
            cache_index_input   = index_v2_ff;
            cache_tag_input     = tag_v2_ff;
        end
        hit_output = cache_lines[cache_index_input].valid && cache_lines[cache_index_input].tag == cache_tag_input;
    end

    // logic for directing what to read the load_register into
    logic [DATA_WIDTH-1:0] data_ff;
    logic [DATA_WIDTH-1:0] dram_resp_data;
    // will exist in main always_ff block


    // AXI handshake trackers
    logic axi_aw_done_ff, next_axi_aw_done;
    logic axi_w_done_ff,  next_axi_w_done;
    // AXI read burst tracker
    logic [7:0] burst_cnt_ff; // run the ff
    always_ff @(posedge clk) begin
        if (rst) begin
            axi_aw_done_ff <= 1'b0;
            axi_w_done_ff  <= 1'b0;
            burst_cnt_ff   <= '0;
        end else begin
            axi_aw_done_ff <= next_axi_aw_done;
            axi_w_done_ff  <= next_axi_w_done;
        end
    end
    // signals for axi comms
    logic [ADDR_WIDTH-1:0] axi_addr;
    logic [DATA_WIDTH-1:0] axi_wrdata;
    always_comb begin
        axi_addr = (stage_2_ff) ? {addr_ff_v2[ADDR_WIDTH-1 : BLOCK_OFFSET], {BLOCK_OFFSET{1'b0}}} : {addr_ff[ADDR_WIDTH-1 : BLOCK_OFFSET], {BLOCK_OFFSET{1'b0}}};
        axi_wrdata = (stage_2_ff) ? data_ff_v2 : data_ff;
    end
    logic [(DATA_WIDTH/8)-1:0]  axi_byte_en;
    logic [BLOCK_OFFSET-1:0]    axi_addr_block_offset;
    logic [LINE_WIDTH-1:0]      axi_resp_block_ff; // Find a better solution, and this is very large

    axi_if.set_master_defaults();
    
    // mux every input based on whether we are in v1 or v2 sequence
    always_comb begin
        next_state = state;
        cpu_if.req_ready  = 1'b0;
        cpu_if.resp_valid = 1'b0;
        sram_index = '0;
        sram_addr_block_offset = '0;
        sram_byte_wr_en = '0;
        sram_data_in = '0;

        // IMPORTANT: Need to zero out all values in order to not latch!!!!
        case (state)
            IDLE: begin
                cpu_if.req_ready = 1'b1;
                if (cpu_if.req_valid) begin
                    if (hit_output) begin
                        sram_index = incom_index;
                        sram_addr_block_offset = incom_block_offset;
                        if (cpu_if.wr_en) begin
                            if (cache_unaligned) begin
                                sram_byte_wr_en = byte_wr_en;
                            end else begin
                                sram_byte_wr_en = incom_byte_wr_en;
                            end
                            sram_data_in = cpu_if.data;
                        end
                    end
                end
            end
            LOAD_HIT: begin
                if (cache_unaligned_ff && !stage_2_ff && hit_output) begin // just captured 1st load and we got a hit on v2
                    // set new load
                    sram_index = addr_ff_v2[BLOCK_OFFSET_WIDTH +: INDEX_WIDTH];
                    sram_addr_block_offset = '0;
                    sram_byte_wr_en = byte_wr_en_ff_v2;
                end
            end
            LOAD_MISS_INITIAL: begin
                // wait for data to come back from memory and do LRU replacement
                // write to axi interface
                axi_if.arvalid = 1'b1;
                axi_if.araddr = axi_addr;
            end
            LOAD_MISS_WAIT: begin
                // when leaving, need to have transition logic like in LOAD_HIT for possibility of v2
                axi_if.rready = 1'b1;
                if (axi_if.rvalid && axi_if.rready) begin
                    // CHECK ALL OF THIS
                    sram_index = axi_addr[BLOCK_OFFSET +: INDEX_WIDTH];
                    // calculate offset based on burst count (e.g. 0x00, 0x10, 0x20, 0x30 for 128-bit)
                    sram_addr_block_offset = burst_cnt_ff * (DATA_WIDTH/8); // is this right??
                    sram_byte_wr_en = {(DATA_WIDTH/8){1'b1}}; // write full bus width
                    sram_data_in = axi_if.rdata;
                end
            end
            STORE_MISS_INITIAL: begin
                // wait for data to be dispatched to memory for write
                // assert AWVALID if AW channel handshake isn't complete yet
                if (!axi_aw_done_ff) begin
                    axi_if.awvalid = 1'b1;
                    axi_if.awaddr  = addr_ff;
                end
                // assert WVALID if W channel handshake isn't complete yet
                if (!axi_w_done_ff) begin
                    axi_if.wvalid = 1'b1;
                    axi_if.wdata  = data_ff;
                    axi_if.wstrb  = byte_wr_en_ff;
                    axi_if.wlast  = 1'b1; // 1 beat burst
                end

                if (axi_if.awvalid && axi_if.awready) next_axi_aw_done = 1'b1;
                if (axi_if.wvalid && axi_if.wready)   next_axi_w_done  = 1'b1;

                // move to wait state when both address and data are accepted
                if (next_axi_aw_done && next_axi_w_done) begin
                    next_state = STORE_MISS_WAIT;
                end
            end
            STORE_MISS_WAIT: begin
                // wait for response of confirmation from axi
            end
            STORE_V2_SETUP: begin
                if (hit_output) begin
                    sram_index = addr_ff_v2[BLOCK_OFFSET_WIDTH +: INDEX_WIDTH];
                    sram_addr_block_offset = addr_ff_v2[0 +: BLOCK_OFFSET_WIDTH];
                    sram_byte_wr_en = byte_wr_en_ff_v2;
                    sram_data_in = data_2_ff;
                end
            end
            RESPOND: begin
                
            end

            default: begin
            end
        endcase

    end

    // ALSO DONT FORGET: for each state that is not IDLE or RESPOND, need to handle v1 and v2 cases
    // do this by creaintg muxed inputs
    // DONT FORGET: need to update state of cache when miss
    always_ff @(posedge clk) begin
        if (rst) begin
            mem_resp_info_ff <= '0;
            cache_lines <= '0;
            state <= IDLE;
            stage_2_ff <= 1'b0;
            // search for other signals in the design that need to be reset !!!
            axi_resp_block_ff <= '0;
        end else begin
            case (state) begin
                IDLE: begin
                    // cpu_if.req_ready <= 1'b1;
                    if (cpu_if.req_valid) begin
                        // grab data that counts for all cases
                        store_ff <= cpu_if.wr_en;
                        mem_resp_info_ff <= req_info_to_resp_info(cpu_if.mem_op_info);
                        byte_wr_en_ff <= byte_wr_en;
                        byte_wr_en_ff_v2 <= byte_wr_en_v2;
                        addr_ff <= cpu_if.addr;
                        addr_ff_v2 <= addr_2;
                        data_2_ff <= data_2;
                        cache_unaligned_ff <= cache_unaligned;
                        index_v2_ff <= addr_v2[INDEX_WIDTH+BLOCK_OFFSET-1:OFFSET_WIDTH];
                        tag_v2_ff <= addr_v2[DATA_WIDTH-1:INDEX_WIDTH+BLOCK_OFFSET];
                        // handle operation 1 (there will be a 2nd if original cache op is unaligned)
                        state <= next_state_from_idle(cache_unaligned, hit_output, cpu_if.wr_en);
                    end
                end
                LOAD_HIT: begin
                    if (!stage_2_ff) begin
                        data_ff <= capture_data_into_load_reg(byte_wr_en_ff, sram_data_out, data_ff);
                        state <= next_state_from_first_load(cache_unaligned, hit_v2_ff);
                        if (cache_unaligned) begin
                            stage_2_ff <= 1'b1;
                        end
                    end else begin
                        data_ff <= capture_data_into_load_reg(byte_wr_en_ff_v2, sram_data_out, data_ff);
                    end
                end
                LOAD_MISS_INITIAL: begin
                    if (axi_if.arvalid && axi_if.arready) begin
                        state <= LOAD_MISS_WAIT;
                    end
                end
                LOAD_MISS_WAIT: begin
                    // wait for data to come back from memory and do LRU replacement
                    // if (response ...) set_v1_load_data(...) begin
                    // end
                    // when leaving set stage_2_ff if needed
                    // when leaaving, need to have transitio logic like in LOAD_HIT for possibility of v2
                    // NEED TO CAPTURE THE DATA FROM AXI RESPONSE INTO THE LOAD REGISTER
                    if (axi_if.rvalid && axi_if.rready) begin
                        burst_cnt_ff <= burst_cnt_ff + 1;
                        axi_resp_block_ff[(burst_cnt_ff+1)*AXI_DATA_WIDTH-1:burst_cnt_ff*AXI_DATA_WIDTH] <= axi_if.rdata; // this is probably wrong, but roghly correct (unless we optimize)
                    
                        // re-evaluate if we need to hit stage 2 of unaligned load
                        if (axi_if.rlast) begin
                            // IMPORTANT: need to modify line to capture the data from axi_resp_block_ff using similar logic used for load_hits (unless optimize)
                            // also need to forward the last incoming data too!!
                            // data_ff <= capture_data_into_load_reg(byte_wr_en_ff, axi_if.rdata, data_ff);
                            burst_cnt_ff <= '0;
                            if (cache_unaligned_ff && !stage_2_ff) begin
                                stage_2_ff <= 1'b1;
                                state <= hit_output ? LOAD_HIT : LOAD_MISS_INITIAL;
                            end else begin
                                state <= RESPOND;
                            end
                        end
                    end

                end
                STORE_MISS_INITIAL: begin
                    // note: transition to WAIT only if the AXI is ready
                    // wait for data to be dispatched to memory for write
                    state <= STORE_MISS_WAIT;

                end
                STORE_MISS_WAIT: begin
                    // wait for data to respond from memory for write to ensure it went through
                end
                STORE_V2_SETUP: begin
                    // if (store_ff) begin
                    if (hit_output) begin
                        state <= IDLE;
                    end else begin
                        state <= STORE_MISS_INITIAL;
                    end
                    stage_2_ff <= 1'b1;
                    end
                end
                RESPOND: begin                    
                    
                end
                default: begin
                end
            endcase
        end
    end

endmodule

