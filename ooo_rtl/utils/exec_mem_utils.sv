
package exec_mem_pkg;

    import decode_pkg::*;
    import general_pkg::*;
    export general_pkg::*;
    import writeback_pkg::*;
    import issue_pkg::*;
    import instr_fetch_pkg::*;

    // localparam MEM_ENTRY_NUM = 1024;
    localparam MEM_ENTRY_NUM = 65536; // matches spike sim data mem space
    localparam MEM_INDEX_WIDTH = $clog2(MEM_ENTRY_NUM);


    //  COMEBACK AND DEFINE
    // function automatic logic [$clog2(MAX_EXEC_CYCLE_V2-1)-1:0] get_exec_stage_delays_v2 (
    //     input EX_MEM_TYPE funct_unit_i,
    // );
    //     return MAX_EXEC_CYCLE_V2-1;
    // endfunction

    // function automatic logic [$clog2(MAX_EXEC_CYCLE_DELAY)-1:0] get_exec_stage_delays_v3(
    function automatic logic [$clog2(MAX_EXEC_CYCLE_V2)-1:0] get_exec_stage_delays_v3(
        input EX_MEM_TYPE funct_unit_type,
        input logic store
    );
        case (funct_unit_type)
            ALU: return 0;
            MEM: begin
                if (store) 
                    return 0;
                else // load
                    return 1;
            end
            BRANCH: return 0;
            JALR: return 0;
            AUIPC: return 0;
            default:
                return 0; // Default to 1 cycle for unsupported types
        endcase
    endfunction

    typedef struct packed {
        // ex_mem_stage_pkt_t ex_mem_stage_pkt;
        logic instr_valid;
        logic [$clog2(ROB_COUNT)-1:0] rob_ptr;
        logic dest_valid; 
        // USE THIS AT END OF THE STAGE
        // for rename table and issue queue update
        // logic [$clog2(PRF_COUNT)-1:0] prf_ptr;
        // logic [4:0] arf_ptr;
        // for multiplexing output of stage
        logic [EX_MEM_TYPE_SIZE-1:0] funct_unit_one_hot;
        logic store;
        logic [$clog2(MAX_SPEC_EXEC_INSTRS):0] spec_exec_ptr;
    } ex_mem_scoreboard_data_t;

    typedef struct packed {
        // logic valid;
        // logic [DATA_WIDTH-1:0] pc;
        logic trgt_en;
        logic [DATA_WIDTH-1:0] calc_pc;
        logic branch_en;
        logic branch_taken;
        logic [$clog2(MAX_SPEC_EXEC_INSTRS):0] spec_exec_ptr;
    } spec_exec_answr_pkt_t;

    typedef struct packed {
        logic wr_en;
        logic [(DATA_WIDTH/4)-1:0] vec_wr_en;
        logic [$clog2(MAX_MEM_INSTRS):0] buff_ptr;
        logic is_store;
        logic [DATA_WIDTH-1:0] addr;
        logic [DATA_WIDTH-1:0] pc;
        // can technically optimize away "store_data" by resuing data_o in mem stage
        logic [DATA_WIDTH-1:0] store_data;
        logic [1:0] store_width_type;
    } mem_addr_pkt_t;

    // typedef struct packed 

    typedef struct packed {
        logic valid;
        logic is_store;
        logic [(DATA_WIDTH/4)-1:0] vec_wr_en;
        logic [DATA_WIDTH-1:0] addr;
        logic [DATA_WIDTH-1:0] pc;
        logic [DATA_WIDTH-1:0] store_data;
    } mem_addr_entry_t;

    function automatic ex_mem_scoreboard_data_t set_ex_mem_scoreboard_data (
        input fetch_packet_t fetch_pkt_i
    );
        ex_mem_scoreboard_data_t ex_mem_scoreboard_data;
        ex_mem_scoreboard_data.instr_valid = fetch_pkt_i.valid;
        ex_mem_scoreboard_data.rob_ptr = fetch_pkt_i.rob_ptr;
        ex_mem_scoreboard_data.dest_valid = fetch_pkt_i.valid && (
            fetch_pkt_i.funct_unit_one_hot[ALU] || 
            (fetch_pkt_i.funct_unit_one_hot[MEM] && !fetch_pkt_i.store) || // load
            fetch_pkt_i.funct_unit_one_hot[JALR] || 
            fetch_pkt_i.funct_unit_one_hot[AUIPC]);
        // ex_mem_scoreboard_data.prf_ptr = fetch_pkt_i.dest_ptr;
        ex_mem_scoreboard_data.funct_unit_one_hot = fetch_pkt_i.funct_unit_one_hot;
        ex_mem_scoreboard_data.store = fetch_pkt_i.store;
        ex_mem_scoreboard_data.spec_exec_ptr = fetch_pkt_i.spec_exec_ptr;

        return ex_mem_scoreboard_data;
    endfunction

    function automatic logic [(DATA_WIDTH/8)-1:0] store_funct3_to_en_vector (
        input logic [2:0] funct3,
        input logic [1:0] lower_addr_bits
    );
        case (funct3)
            3'b000: return (4'b0001) << lower_addr_bits;
            // 3'b001: return (4'b0011) << lower_addr_bits[1];
            3'b001: return (4'b0011) << (lower_addr_bits[1] * 2); // shift by 2 bits for halfword
            3'b010: return 4'b1111;
            default:
                return 4'b0000;
        endcase
    endfunction

    function automatic logic [DATA_WIDTH-1:0] shift_store_data (
        input logic [2:0] funct3,
        input logic [1:0] lower_addr_bits,
        input logic [DATA_WIDTH-1:0] store_data
    );
        case (funct3)
            3'b000: return store_data << (lower_addr_bits * 8);
            3'b001: return store_data << (lower_addr_bits[1] * 16);
            3'b010: return store_data;
            default:
                return DATA_WIDTH'(0);
        endcase
    endfunction

    function automatic logic [DATA_WIDTH-1:0] reverse_shift_store_data (
        // input logic [2:0] funct3,
        // input logic [1:0] lower_addr_bits,
        input logic [3:0] store_en_vector,
        input logic [DATA_WIDTH-1:0] store_data
    );
        int length = 0;
        int most_sig_one = -1;
        for (int i = 0; i < 4; i++) begin
            if (store_en_vector[i]) begin
                length = length + 1;
                most_sig_one = i;
            end
        end

        if (most_sig_one == -1) begin
            return DATA_WIDTH'(0);
        end

        case (length)
            1: return store_data >> (most_sig_one * 8);
            2: begin 
                if (most_sig_one == 1) begin
                    return store_data;
                end else if (most_sig_one == 3) begin
                    return store_data >> 16;
                end else begin
                    return DATA_WIDTH'(0); // Invalid case, should not happen
                end
            end
            4: return store_data;
            default:
                return DATA_WIDTH'(0);
        endcase
    endfunction

    function automatic logic reverse_shift_store_data_comparison (
        // input logic [2:0] funct3,
        // input logic [1:0] lower_addr_bits,
        input logic [3:0] store_en_vector,
        input logic [DATA_WIDTH-1:0] store_data,
        input logic [DATA_WIDTH-1:0] expected_data
    );
        int length = 0;
        int most_sig_one = -1;
        for (int i = 0; i < 4; i++) begin
            if (store_en_vector[i]) begin
                length = length + 1;
                most_sig_one = i;
            end
        end

        if (most_sig_one == -1) begin
            return 1'b0;
        end

        case (length)
            1: begin 
                return store_data[8*most_sig_one +: 8] == expected_data[7:0];
            end
            2: begin 
                if (most_sig_one == 1) begin
                    return store_data[15:0] == expected_data[15:0];
                end else if (most_sig_one == 3) begin
                    return store_data[31:16] == expected_data[15:0];
                end else begin
                    return 1'b0; // Invalid case, should not happen
                end
            end
            4: return store_data == expected_data;
            default:
                return 1'b0;
        endcase
    endfunction

    function automatic logic [DATA_WIDTH-1:0] process_loaded_data (
        input logic [DATA_WIDTH-1:0] load_data,
        input logic [2:0] funct3,
        input logic [1:0] lower_addr_bits
    );
        logic [DATA_WIDTH-1:0] shifted_data;
        logic [DATA_WIDTH-1:0] result_data;
        shifted_data = load_data >> {lower_addr_bits, 3'b000}; 
        case (funct3)
            3'b000:
                result_data = {{(DATA_WIDTH-8){shifted_data[7]}}, shifted_data[7:0]};
            3'b001:
                result_data = {{(DATA_WIDTH-16){shifted_data[15]}}, shifted_data[15:0]};
            3'b010:
                result_data = shifted_data;
            3'b100:
                result_data = {{(DATA_WIDTH-8){1'b0}}, shifted_data[7:0]};
            3'b101:
                result_data = {{(DATA_WIDTH-16){1'b0}}, shifted_data[15:0]};
            default:
                result_data = '0;
        endcase
        return result_data;
    endfunction

endpackage