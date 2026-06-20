clang --target=riscv32 -march=rv32i -mabi=ilp32 -nostdlib -Wl,-Ttext=0x00000000 -o init.elf init.s
llvm-objcopy -O verilog init.elf init.hex
