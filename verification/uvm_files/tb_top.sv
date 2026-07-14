/*
    Question: is this ok to use commit_decode_pkt if some signals get optmized away?
*/

import core_pkg::*;
interface cpu_commit_if(input logic clk, input logic rst);
    commit_stage_pkt_t commit_decode_pkt;
    store_buffer_commit_pkt_t store_buffer_commit_pkt;
    bit [DATA_WIDTH-1:0] pc;
    bit [DATA_WIDTH-1:0] reg_data;
endinterface

import uvm_pkg::*;
`include "uvm_macros.svh"

class cpu_commit_pkt extends uvm_sequence_item;
    bit wr_en;
    bit dest_valid;
    bit [4:0] arch_reg_addr;
    bit [(DATA_WIDTH/8)-1:0] store_en;
    bit [DATA_WIDTH-1:0] store_addr;
    bit [DATA_WIDTH-1:0] store_data;
    bit [DATA_WIDTH-1:0] next_pc;
    bit [DATA_WIDTH-1:0] reg_data;

    `uvm_object_utils_begin(cpu_commit_pkt)
        `uvm_field_int(wr_en, UVM_ALL_ON)
        `uvm_field_int(dest_valid, UVM_ALL_ON)
        `uvm_field_int(arch_reg_addr, UVM_ALL_ON)
        `uvm_field_int(store_en, UVM_ALL_ON)
        `uvm_field_int(store_addr, UVM_ALL_ON)
        `uvm_field_int(store_data, UVM_ALL_ON)
        `uvm_field_int(next_pc, UVM_ALL_ON)
        `uvm_field_int(reg_data, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "cpu_commit_pkt");
        super.new(name);
    endfunction
endclass

class cpu_commit_monitor extends uvm_monitor;
    `uvm_component_utils(cpu_commit_monitor)
  
    virtual cpu_commit_if vif;
    uvm_analysis_port #(cpu_commit_pkt) ap;
    
    bit [31:0] TOHOST_ADDR = 32'h80012100; 

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual cpu_commit_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NOVIF", {"Virtual interface must be set for: ", get_full_name(), ".vif"})
        end
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
                commit_pkt.store_en = vif.store_buffer_commit_pkt.vec_wr_en;
                commit_pkt.store_addr = vif.store_buffer_commit_pkt.addr;
                commit_pkt.store_data = vif.store_buffer_commit_pkt.data;
                commit_pkt.next_pc = vif.pc;
                commit_pkt.reg_data = vif.reg_data;
                ap.write(commit_pkt);

                // check if finished
                if (vif.store_buffer_commit_pkt.addr == TOHOST_ADDR) begin
                    if (vif.store_buffer_commit_pkt.data == 32'hFFFF_FFFF) begin
                    `uvm_info("TEST_PASS", "CPU wrote 0xFFFF_FFFF to tohost. Test passed!", UVM_LOW)
                    end else begin
                    `uvm_fatal("TEST_FAIL", $sformatf("CPU wrote failure code %0d to tohost.", vif.store_buffer_commit_pkt.data))
                    end
                    // Optional: Forcefully end simulation here if you aren't using objections
                    uvm_top.stop_request();
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

class cpu_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(cpu_scoreboard)
    uvm_analysis_imp #(cpu_commit_pkt, cpu_scoreboard) commit_pkt_export;

    int file_h = 0;
    int current_line_num = 0;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    // in_export  = new("in_export", this);
    // out_export = new("out_export", this);
        commit_pkt_export = new("commit_pkt_export", this);
        file_h = $fopen("python_scripts/trace_readable.log", "r");
        if (file_h == 0) begin
            `uvm_fatal("FILE_ERR", "Failed to open file")
        end
    endfunction

    // Called when Input Monitor sees an instruction entering the pipeline
    virtual function void write(cpu_commit_pkt pkt);
        cpu_commit_pkt exp_pkt;
        string trace_line;
        int parsing_code;
        if (!pkt.wr_en) begin
            return;
        end
        if ($feof(file_h)) begin
            `uvm_fatal("TRACE_ERR", $sformatf("RTL committed an instruction, but trace file is empty at line %0d", current_line_num))
            return;
        end
        exp_pkt = cpu_commit_pkt::type_id::create("exp_pkt");
        void'($fgets(trace_line, file_h)); // skip every other line
        void'($fgets(trace_line, file_h));
        current_line_num += 2;
        exp_pkt.wr_en = 1;
        // {dest_valid} {register address} {store_en} {store_addr} {store_data} {next_pc} 
        parsing_code = $sscanf(
            trace_line,
            "%d %d %d 0x%h 0x%h 0x%h 0x%h",
            exp_pkt.dest_valid,
            exp_pkt.arch_reg_addr,
            exp_pkt.store_en,
            exp_pkt.store_addr,
            exp_pkt.store_data,
            exp_pkt.next_pc,
            exp_pkt.reg_data
        );
        if (parsing_code != 7) begin
            `uvm_fatal("TRACE_ERR", $sformatf("Failed to parse trace line at line %0d: %s", current_line_num, trace_line))
            return;
        end
        if (!exp_pkt.compare(pkt)) begin
            `uvm_fatal("MISMATCH", $sformatf("Mismatch at line %0d!", current_line_num))
            `uvm_fatal("MISMATCH", $sformatf("Expected: %p | Actual: %p", exp_pkt, pkt));
        end else begin
            `uvm_info("MATCH", $sformatf("Match at line %0d!", current_line_num), UVM_LOW)
        end
    endfunction

    // end condition checking for any remaining instructions in the trace file (Not supposed to finish all of them)
    virtual function void check_phase(uvm_phase phase);
        super.check_phase(phase);
        if (!$feof(file_h)) begin
            `uvm_info("SCOREBOARD", 
                        $sformatf("Test ended, but trace file still has unread instructions! Stopped at line %0d.", current_line_num),
                        UVM_LOW)
            end else begin
            `uvm_info("SCOREBOARD", "Successfully verified all lines in the trace file.", UVM_LOW)
        end    
        $fclose(file_h);
    endfunction
endclass

class riscv_env extends uvm_env;
    `uvm_component_utils(riscv_env)
    cpu_commit_agent cpu_agent;
    cpu_scoreboard scoreboard;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uvm_config_db#(uvm_active_passive_enum)::set(this, "cpu_agent", "is_active", UVM_PASSIVE);
        cpu_agent = cpu_commit_agent::type_id::create("cpu_agent", this);
        scoreboard = cpu_scoreboard::type_id::create("cpu_scoreboard", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        cpu_agent.monitor.ap.connect(scoreboard.commit_pkt_export); 
    endfunction

endclass

class riscv_base_test extends uvm_test;
    `uvm_component_utils(riscv_base_test)

    riscv_env env;

    function new(string name = "riscv_base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = riscv_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        // failsafe timeout in case the CPU hangs and never writes to tohost
        // #1000000
        // #100000
        #1000
        `uvm_fatal("TIMEOUT", "Simulation timed out waiting for tohost write!")
        phase.drop_objection(this);
    endtask
endclass

// Make sure to import your packages and UVM macros
import uvm_pkg::*;
`include "uvm_macros.svh"
import core_pkg::*; // Assuming this contains commit_stage_pkt_t, etc.

module tb_top;

    // 1. Clock and Reset Generation
    logic clk;
    logic rst;

    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end

    initial begin
        rst = 1;
        #20;
        rst = 0;
    end

    cpu_commit_if commit_if(.clk(clk), .rst(rst));

    core dut (
        .clk(clk),
        .rst(rst),
        .commit_decode_pkt(commit_if.commit_decode_pkt)
    );
    assign commit_if.store_buffer_commit_pkt = dut.store_buffer_commit_pkt;
    assign commit_if.pc = dut.instr_fetch_stage_inst.pc;
    assign commit_if.reg_data = dut.issue_stage_inst.physical_register.reg_mem[commit_if.commit_decode_pkt.phys_reg_addr];

    initial begin
        // Push the virtual interface into the UVM configuration database.
        // The path "*" makes it available globally, which is fine for a simple testbench.
        // It matches the 'vif' string you retrieve in the monitor's build_phase.
        uvm_config_db#(virtual cpu_commit_if)::set(null, "*", "vif", commit_if);

        run_test("riscv_base_test");
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_top);
    end

endmodule