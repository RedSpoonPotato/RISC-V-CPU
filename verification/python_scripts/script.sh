#!/bin/bash
export RISCV=~/spike_install/riscv
export PATH=$PATH:$RISCV/bin

set -e

# generating elf, then trace for spike
# clang --target=riscv32 -march=rv32i -mabi=ilp32 -nostdlib -Wl,-Ttext=0x00000000 -o init.elf init.s
# riscv64-unknown-elf-objdump -d -M numeric,no-aliases init.elf > raw_code.txt # optional
# llvm-objcopy -O verilog init.elf init.hex
cd asms/intermediate
cat init_p1.s \
    <(printf "\tli x7, 0x80010100       # Base memory address for data (0x80010100 to protect the mailboxes)") \
    init_p2.s \
    generated_instructions.s \
    finish_uvm.s \
    finish_spike.s \
        > ../rand_sim_spike.s
cd ../..
clang --target=riscv32 -march=rv32i -mabi=ilp32 -nostdlib -Wl,-T,link.ld -ferror-limit=10 -o elfs/rand_sim_spike.elf asms/rand_sim_spike.s
echo "--launching spike--"
spike --isa=rv32i -m0x80000000:0x10000,0x80010000:0x10000 --log-commits elfs/rand_sim_spike.elf 2> trace.log
echo "--spike finished--"

# translating trace.log to readable format for UVM testbench
python3 translate_log.py trace.log trace_readable.log 5 1200

# generating elf, then bin to python script
cd asms/intermediate
cat init_p1.s \
    <(printf "\tli x7, 0x80010100       # Base memory address for data (0x80010100 to protect the mailboxes)") \
    init_p2.s \
    generated_instructions.s \
    finish_uvm.s \
        > ../rand_sim_py.s
cd ../..
clang --target=riscv32 -march=rv32i -mabi=ilp32 -nostdlib -Wl,-T,link.ld -ferror-limit=10 -o elfs/rand_sim_py.elf asms/rand_sim_py.s
llvm-objcopy -O binary elfs/rand_sim_py.elf bins/rand_sim_py.bin

# convert program to rtl-readable
# adding -j to get rid of .data or .bss sections in the output binary
llvm-objcopy -O binary -j .text elfs/rand_sim_spike.elf bins/rand_sim_spike.bin
hexdump -v -e '1/4 "%08x\n"' bins/rand_sim_spike.bin > rtl_hexs/rand_sim_spike.hex
