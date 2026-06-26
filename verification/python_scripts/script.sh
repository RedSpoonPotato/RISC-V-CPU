#!/bin/bash
export RISCV=~/spike_install/riscv
export PATH=$PATH:$RISCV/bin


# generating elf, then trace for spike
# clang --target=riscv32 -march=rv32i -mabi=ilp32 -nostdlib -Wl,-Ttext=0x00000000 -o init.elf init.s
# riscv64-unknown-elf-objdump -d -M numeric,no-aliases init.elf > raw_code.txt # optional
# llvm-objcopy -O verilog init.elf init.hex
cd asms
cat init_p1.s \
    <(printf "\tli x7, 0x80010100       # Base memory address for data (0x80010100 to protect the mailboxes)") \
    init_p2.s \
    init_p3.s \
        > init_spike.s
cd ../
clang --target=riscv32 -march=rv32i -mabi=ilp32 -nostdlib -Wl,-T,link.ld -o elfs/init_spike.elf asms/init_spike.s
echo "--launching spike--"
spike --isa=rv32i -m0x80000000:0x10000,0x80010000:0x10000 --log-commits elfs/init_spike.elf 2> trace.log
echo "--spike finished--"

# generating elf, then bin to python script
cd asms
cat init_p1.s \
    <(printf "\tli x7, 0x80010100       # Base memory address for data (0x80010100 to protect the mailboxes)") \
    init_p2.s \
        > init_py.s
cd ../
clang --target=riscv32 -march=rv32i -mabi=ilp32 -nostdlib -Wl,-T,link.ld -o elfs/init_py.elf asms/init_py.s
llvm-objcopy -O binary elfs/init_py.elf bins/init_py.bin
