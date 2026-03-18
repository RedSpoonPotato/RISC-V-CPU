module decode_stage #(
    parameter DATA_WIDTH = 32,
    parameter INSTR_WIDTH = 32,

) (
    input clk,
    input [INSTR_WIDTH-1:0] instr_i,
    // cntrls

    /*
        external comms
            master
                arf read
                rob r/w
            slave
                writeback stage for w for issuequeue
                commit_stage w for RT
    */

    output logic
);
    // addr for branch targets

    // internal comms
    // rename table r/w
    // issue queue w
    
    // modules
    // rename table
    // issue queue

    // keep track of next avail rob ptr val (increment by 1 using an adder each time we get an instruciton that writes to a register)
    

endmodule

// possible optimzation: merge rename table and scoreboard

// used for knowing where to commit
// assumption: data can be in ROB or ARF
module rename_table #(
    parameter ROB_COUNT = 32
) (
    input clk,
    input rst,
    // initial write
    input logic [$clog2(ROB_COUNT)-1:0] rob_ptr_i,
    input logic [4:0] arf_ptr_i,
    input logic decode_en_i, 
    // to signal its in ROB, can have the scoreboard tell the RT
    input logic [$clog2(ROB_COUNT)-1:0] rob_ptr_sb_i,
    input logic writeback_en_i,
    // to signal its in ARF, can have the ROB tell the RT
    input logic [4:0] arf_ptr_rob_i,
    input logic [$clog2(ROB_COUNT)-1:0] rob_ptr_rob_i,
    input logic commit_en_i,
    // ports for issue queue to read from 
      
    output logic [$clog2(ROB_COUNT)-1:0] rob_ptr_o
);
    typedef struct packed {
        logic [$clog2(ROB_COUNT)-1:0] rob_ptr;
        logic [DATA_WIDTH-1:0] imm;
        logic spec;
        logic pending;
        logic valid;
    } rt_entry_t;

    rt_entry_t rename_table [0:31];

    // write logic
    always_ff @(posedge clk) begin
        if (rst) begin
            rename_table = '0;
        end 
        else begin
            if (decode_en_i) begin
                rename_table[arf_ptr_i].rob_ptr <= rob_ptr_i;
                rename_table[arf_ptr_i].pending <= 1'b1;
                rename_table[arf_ptr_i].valid <= 1'b1;
            end
            if (writeback_en_i) begin
                for (int i = 0; i < 32; i++) begin
                    if (rename_table[arf_ptr_i].rob_ptr == rob_ptr_sb_i) begin
                        rename_table[i].pending <= 1'b0;
                    end
                end
            end
            if (commit_en_i) begin
                if (rename_table[arf_ptr_rob_i].rob_ptr == rob_ptr_rob_i) begin
                    rename_table.valid <= 1'b0;
                end
            end
        end
    end

    // read logic
    assign rob_ptr_o = rename_table[arf_ptr_i].rob_ptr;
endmodule



// should be the module that determines which is the next instruction to be issued
module issue_queue 
    import issue_queue_pkg::*;
    (
    input clk,
    input rst,
    // could optmize, but would have to change the "write" functions
    input logic [31:0] instr_i,
    input logic []

    input logic wr_en_i,
    // signal from exterior

    // for writing from right before writeback stage into decode stage
    input logic [$clog2(ROB_COUNT)-1:0] rob_dst_i,
    input logic rob_wr_en_i,
    
    // output logic [INSTR_COMPRESS_WIDTH-1:0] compr_instr_o;
    output logic [INSTR_OUTPUT_WIDTH-1:0] instr_o;
    // also other output information 
    output logic empty_o,
    output logic full_o,
    output logic all_stalled_o, // when all current entries are still stalling, does also account for input "rob_dst_i"
);  

    iq_entry_t iq [0:IQ_SIZE-1];

    // write logic
    always_ff @(posedge clk) begin
        if (rst) begin
            iq <= '0;
            // need to set other values
            empty_o <= 1;
            full_o <= 0;
            all_stalled_o <= 0;
        end 
        else begin
            if (wr_en_i && ~full_o) begin
                // find first empty slot and write instruction
                for (int i = 0; i < IQ_SIZE; i++) begin
                    if (~iq[i].valid) begin
                        iq[i].valid <= 1;
                        iq[i].op <= grab_compr_instr(instr);
                        iq[i].imm <= imm_gen(instr);
                        iq[i].speculative <= is_speculative(instr[6:0]);
                        iq[i].dest_valid <= ~no_dest(instr[6:0]);
                        iq[i].dest_ptr <= instr[11:7];
                        iq[i]

                            
                        end
                        break;
                    end
                end
            end
        end
    end

    // read logic
    // also can account for forwarding from before even reaching commit stage, but would haav eot check conditions before
    logic [IQ_SIZE-1:0] valid_array;
    always_comb begin
        for (int i = 0; i < IQ_SIZE; i++)
            valid_array[i] = iq[i].valid;
    end
    assign empty_o = ~(|valid_array);
    assign full_o = &valid_array;

    logic [IQ_SIZE-1:0] ready_array;
    always_comb begin
        for (int i = 0; i < IQ_SIZE; i++) begin
            ready_array[i] = (
                (~iq[i].src0_valid | (iq[i].src0_pending & (iq[i].src0_ptr == rob_dst_i))) & 
                (~iq[i].src1_valid | (iq[i].src1_pending & (iq[i].src1_ptr == rob_dst_i)))
            );
        end
    end
    assign all_stalled_o = ~(|ready_array);

    always_ff @(posedge clk) begin

        if (~empty && ~all_stalled_o) begin
            // search for highest priority valid entry
            for (int i = 0; i < IQ_SIZE; i++) begin
                if (iq[i].valid) begin
                    // for now, we will output almost the entire entry (MAKE CHANGE LATER)

                end
            end
        end

        // probably delete this:
        instr_o = '0;
        for (int i = 0; i < IQ_SIZE; i++) begin
            // adj forr SRC!!!
            if (iq[i].pending == 1'b0) begin : grab_from_rob
                instr_o = iq[i].instr;
                // send rob ptrs to grab from rob
                rob_ptr = 
                // send dest out
                break;
            end else if (iq valid = ) begin : grab_from_arf

            end
        end
    end

endmodule

