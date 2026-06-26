/*
    Question: is this ok to use commit_decode_pkt if some signals get optmized away?
*/

import core_pkg::*;
interface cpu_commit_if(input logic clk, input logic rst);
    commit_stage_pkt_t commit_decode_pkt;
    store_buffer_commit_pkt_t store_buffer_commit_pkt;
    bit [DATA_WIDTH-1:0] pc;
endinterface

import uvm_pkg::*;
`include "uvm_macros.svh"

class cpu_commit_pkt extends uvm_sequence_item;
    // commit_stage_pkt_t
    bit wr_en;
    // bit speculative;
    // bit store;
    // bit mem_op;
    bit dest_valid;
    // bit [$clog2(PRF_COUNT)-1:0] phys_reg_addr;
    bit [4:0] arch_reg_addr;
    // bit [$clog2(PRF_COUNT)-1:0] prev_phys_reg_addr;
    // store_buffer_commit_pkt_t
    bit store_en;
    bit [DATA_WIDTH-1:0] addr;
    bit [DATA_WIDTH-1:0] data;
    bit [DATA_WIDTH-1:0] pc;

    `uvm_object_utils_begin(cpu_commit_pkt)
        `uvm_field_int(wr_en, UVM_ALL_ON)
        `uvm_field_int(dest_valid, UVM_ALL_ON)
        `uvm_field_int(arch_reg_addr, UVM_ALL_ON)
        `uvm_field_int(store_en, UVM_ALL_ON)
        `uvm_field_int(addr, UVM_ALL_ON)
        `uvm_field_int(data, UVM_ALL_ON)
        `uvm_field_int(pc, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "cpu_commit_pkt");
        super.new(name);
    endfunction
endclass

class cpu_commit_monitor extends uvm_monitor;
    `uvm_component_utils(cpu_commit_monitor)
  
    virtual cpu_commit_if vif;
    uvm_analysis_port #(cpu_commit_pkt) ap;
    
    // NEED TO SETUP RISCV-DV TOHOST_ADDR
    bit [31:0] TOHOST_ADDR = 32'h8000_1000; 

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    task run_phase(uvm_phase phase);
        cpu_commit_pkt commit_pkt;        
        
        forever begin
            @(posedge vif.clk);
            if (vif.commit_decode_pkt.wr_en) begin 
                commit_pkt = cpu_commit_pkt::type_id::create("commit_pkt");
                commit_pkt.wr_en = 1;
                commit_pkt.dest_valid = vif.commit_decode_pkt.dest_valid;
                commit_pkt.arch_reg_addr = vif.commit_decode_pkt.arch_reg_addr;
                commit_pkt.store_en = vif.store_buffer_commit_pkt.en;
                commit_pkt.addr = vif.store_buffer_commit_pkt.addr;
                commit_pkt.data = vif.store_buffer_commit_pkt.data;
                commit_pkt.pc = vif.pc;
                ap.write(commit_pkt);

                // check if finished
                if (vif.store_buffer_commit_pkt.addr == TOHOST_ADDR) begin
                    if (vif.store_buffer_commit_pkt.data == 32'h1) begin
                    `uvm_info("TEST_PASS", "CPU wrote 1 to tohost. Test passed!", UVM_LOW)
                    end else begin
                    `uvm_error("TEST_FAIL", $sformatf("CPU wrote failure code %0d to tohost.", vif.wdata))
                    end
                    // Optional: Forcefully end simulation here if you aren't using objections
                    $finish;
                end
            end
        end
    endtask
endclass

class cpu_commit_agent extends uvm_agent;
    `uvm_component_utils(cpu_commit_agent)
    // Declare components
    cpu_commit_monitor monitor;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        monitor = cpu_commit_monitor::type_id::create("monitor", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction
endclass

// `uvm_analysis_imp_decl(_in)
// `uvm_analysis_imp_decl(_out)
class cpu_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(cpu_scoreboard)

  // Ports to receive data from Monitors
//   uvm_analysis_imp_in  #(cpu_instr_txn, cpu_scoreboard) in_export;
//   uvm_analysis_imp_out #(cpu_instr_txn, cpu_scoreboard) out_export;
    uvm_analysis_imp #(cpu_commit_pkt, cpu_scoreboard) commit_pkt_export;

    int file_descriptor = 0;
    int current_line_num = 0;

  // Associative array to handle pipeline delay and out-of-order completion
//   cpu_instr_txn expected_results[bit[4:0]]; 

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    // in_export  = new("in_export", this);
    // out_export = new("out_export", this);
        commit_pkt_export = new("commit_pkt_export", this);
    endfunction

  // Called when Input Monitor sees an instruction entering the pipeline
    virtual function void write(cpu_commit_pkt pkt);
        cpu_commit_pkt exp_pkt;
        // $cast(exp_txn, txn.clone());

    // REFERENCE MODEL LOGIC: Calculate expected result
    // (In a real environment, this calls a C/C++ ISS like Spike)
        // case (exp_txn.opcode)
        //     7'b0110011: exp_txn.result_data = exp_txn.rs1 + exp_txn.rs2; // Simplified ADD
        //     // ... other decodes ...
        // endcase

        // Store the expected transaction using its unique pipeline tag

            // If we have more than 1 item, we can check the previous cycle's result
        // if(tx_q.size() > 1) begin
        // exp_item = tx_q.pop_front();
        // if (item.y == (exp_item.a + exp_item.b))
        //     `uvm_info("PASS", $sformatf("Match: a=%0d b=%0d y=%0d", exp_item.a, exp_item.b, item.y), UVM_LOW)
        // else
        //     `uvm_error("FAIL", $sformatf("Mismatch! a=%0d b=%0d expected=%0d actual=%0d", exp_item.a, exp_item.b, (exp_item.a+exp_item.b), item.y))
        // end

        // plan:
        
        /*
            check spike trace
            extract pc value, possible destination register and value
            compare values and throw error if mismatch
        */

        if ($feof(file_descriptor)) begin
            `uvm_error("TRACE_ERR", $sformatf("RTL committed an instruction, but trace file is empty at line %0d", current_line_num))
            return;
        end

        string trace_line;
        int read_status;
        
        read_status = $fgets(trace_line, file_descriptor);
        current_line_num++;

        // parsed_golden_txn = parse_trace_string(trace_line);
        // if (rtl_txn.data != parsed_golden_txn.data) begin
            //   `uvm_error("MISMATCH", $sformatf("Mismatch at trace line %0d!", current_line_num))
        // end

    endfunction

    // end condition checking for errors
    virtual function void check_phase(uvm_phase phase);
        super.check_phase(phase);
        if (!$feof(file_descriptor)) begin
            `uvm_error("INCOMPLETE_TEST", 
                        $sformatf("Test ended, but trace file still has unread instructions! Stopped at line %0d.", current_line_num))
            end else begin
            `uvm_info("SCOREBOARD", "Successfully verified all lines in the trace file.", UVM_LOW)
        end    
        $fclose(file_descriptor);
    endfunction
endclass


// need to look at
class riscv_env extends uvm_env;
    `uvm_component_utils(riscv_env)
    cpu_commit_agent cpu_agent;
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uvm_config_db#(uvm_active_passive_enum)::set(this, "cpu_agent", "is_active", UVM_PASSIVE);
        // Now instantiate the agent
        cpu_agent = cpu_commit_agent::type_id::create("cpu_agent", this);
    endfunction
endclass

