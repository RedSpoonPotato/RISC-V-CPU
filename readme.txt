Out-of-Order 5-Stage Pipelined RISC-V CPU

Stages:
    Instruction Fetch [IF]
    Decode [D]
    Issue [I] (aka Register Fetch)
    Execute/Mem [EX_MEM] (Variable Cycle)
    Writeback [WB] (Contains commit modules aswell)

Main Features:
    Speculative Execution
    Register Renaming
    Memory Disambiguation

ISA:
    RISC-V "Bare-metal ISA" (i.e. RV32I without "ecall" and "ebreak")

Verification (In progess):
    UVM testbench 
    Python-based random instruction generator
    
Synthesis:
    Using Vivado TCL for Kria KV260 FPGA Starter Kit
