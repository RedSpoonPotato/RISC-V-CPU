.section .text
.globl _start

_start:

    ##################################################
    # RAM base address
    ##################################################

    lui     s0, 0x00010              # s0 = 0x10000

    ##################################################
    # Initialize linked-list style memory
    #
    # mem[0x10000] = 0x10004
    # mem[0x10004] = 0x10008
    # mem[0x10008] = 0x1000C
    # mem[0x1000C] = 123
    #
    # This creates a chain of dependent loads.
    ##################################################

    addi    t0, s0, 4
    sw      t0, 0(s0)

    addi    t0, s0, 8
    sw      t0, 4(s0)

    addi    t0, s0, 12
    sw      t0, 8(s0)

    addi    t0, x0, 123
    sw      t0, 12(s0)


    ##################################################
    # Start pointer chain
    #
    # Every load depends on previous load result.
    #
    # Since loads take 2 cycles:
    # - these serialize
    # - issue queue fills with waiting instructions
    ##################################################

    addi    t1, s0, 0                # t1 = 0x10000

    lw      t1, 0(t1)                # -> 0x10004
    lw      t1, 0(t1)                # -> 0x10008
    lw      t1, 0(t1)                # -> 0x1000C
    lw      t1, 0(t1)                # -> 123

    ##################################################
    # Independent instruction stream
    #
    # OoO core should execute these while
    # dependent loads are stalled/waiting.
    ##################################################

    addi    s1, x0, 5
    addi    s2, x0, 7
    addi    s3, x0, 9
    addi    s4, x0, 11

    add     s5, s1, s2
    sub     s6, s4, s3
    xor     s7, s5, s6

    and     t2, s7, s5
    or      t3, t2, s6
    slli    t4, t3, 2

    add     t5, t4, s1
    xor     t6, t5, s2

    ##################################################
    # Dependent chain finally resolves here
    ##################################################

    add     a0, t1, t6

    ##################################################
    # Store result
    ##################################################

    sw      a0, 16(s0)

halt:
    jal     x0, halt