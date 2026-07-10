.section .text
    .global _start

_start:

    li x5, 0                # Start value at 0
    li x6, 256              # Stop value at 256
    li x7, 0x80010100       # Base memory address for data (0x80010100 to protect the mailboxes)

mem_init_loop:
    sb x5, 0(x7)            # Store the current byte (x5) into memory at address in x7
    addi x5, x5, 1          # Increment the value by 1
    addi x7, x7, 1          # Advance the memory pointer by exactly 1 byte
    bltu x5, x6, mem_init_loop # If value < 256, loop back

    li x10, 0x11
    li x11, 0x22
    li x12, 0x33
    li x13, 0x44
    li x14, 0x55
    li x15, 0x66
    li x16, 0x77
    li x17, 0x88
    li x18, 0x99
    li x19, 0xAA
    li x20, 0xBB
    li x21, 0xCC
    li x22, 0xFFFF
    li x23, 0xF000

# exiting
lui t0, %hi(tohost)
li t1, 1
sw t1, %lo(tohost)(t0)

# Trap the CPU in a safe loop while Spike shuts down
halt_loop:
    j halt_loop

.section .data
.align 6

.global tohost
tohost: .dword 0

.global fromhost
fromhost: .dword 0
