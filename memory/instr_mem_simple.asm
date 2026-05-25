    .section .text
    .globl _start

_start:

    ##################################################
    # Manually initialize memory
    ##################################################

    # Base address for array
    # (choose some RAM address)
    lui     s0, 0x00010          # s0 = 0x00010000

    # array[0] = 1
    addi    t0, x0, 1
    sw      t0, 0(s0)

    # array[1] = 2
    addi    t0, x0, 2
    sw      t0, 4(s0)

    # array[2] = 3
    addi    t0, x0, 3
    sw      t0, 8(s0)

    # array[3] = 4
    addi    t0, x0, 4
    sw      t0, 12(s0)

    # array[4] = 5
    addi    t0, x0, 5
    sw      t0, 16(s0)

    ##################################################
    # Sum the array
    ##################################################

    addi    s1, x0, 0            # sum = 0
    addi    s2, x0, 0            # i = 0
    addi    s3, x0, 5            # len = 5

loop:

    beq     s2, s3, done

    # offset = i * 4
    slli    t1, s2, 2

    # addr = base + offset
    add     t2, s0, t1

    # load array[i]
    lw      t3, 0(t2)

    # sum += array[i]
    add     s1, s1, t3

    # extra ALU operations
    xor     t4, s1, t3
    and     t5, s1, t4
    or      t6, t5, t3

    # i++
    addi    s2, s2, 1

    jal     x0, loop

done:

    ##################################################
    # Store final sum to memory
    ##################################################

    sw      s1, 32(s0)

    ##################################################
    # Example function call
    ##################################################

    addi    a0, s1, 0

    jal     ra, double_value

    # returned value now in a0
    sw      a0, 36(s0)

halt:
    jal     x0, halt


######################################################
# int double_value(int x)
# returns x*2
######################################################

double_value:

    add     a0, a0, a0

    jalr    x0, 0(ra)