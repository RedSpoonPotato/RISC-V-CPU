
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
