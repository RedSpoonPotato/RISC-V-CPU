.section .text
    .global _start

_start:

    li x5, 0                # Start value at 0
    li x6, 256              # Stop value at 256
    # writing base data address
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

    SRA x17, x16, x10
    BEQ x11, x11, 20
    ANDI x10, x6, -123
    SLL x16, x10, x15
    SLT x6, x13, x22
    SLTIU x6, x16, 119
    OR x24, x5, x7
    OR x16, x17, x14
    SLTI x27, x16, 182
    SRAI x26, x16, 22
    SRL x29, x0, x19
    XOR x18, x16, x22
    SLTI x3, x0, 189
    SLL x13, x0, x5
    SRLI x9, x15, 3
    AUIPC x16, 7
    XOR x1, x17, x13
    XORI x25, x20, 188
    SRL x17, x17, x31
    LUI x6, 524304
    ADDI x6, x6, 256
    SW x26, 260(x6)
    SLT x17, x3, x13
    SLL x31, x17, x31
    SRA x17, x6, x17
    ANDI x26, x17, 16
    SUB x20, x20, x13
    SLTU x30, x15, x27
    ANDI x13, x22, -168
    XOR x26, x3, x19
    AUIPC x4, 0
    SRA x16, x1, x27
    ORI x12, x13, 156
    SRAI x23, x9, 31
    XOR x13, x14, x16
    ORI x4, x22, -4
    SLTU x20, x1, x17
    ADDI x14, x19, 177
    OR x18, x24, x30
    LUI x7, 1048568
    SRA x17, x25, x20
    ADD x20, x25, x24
    SRAI x23, x1, 15
    XOR x13, x10, x27
    SRLI x25, x20, 9
    AUIPC x3, 0
    ADDI x3, x3, 8
    JALR x9, 12(x3)
    SLL x11, x30, x23
    SLLI x25, x4, 31
    SLLI x30, x14, 7
    SRA x14, x0, x22
    ORI x29, x14, 31
    ORI x4, x27, -42
    SLTI x20, x27, 50
    SRL x13, x16, x7
    SLL x5, x13, x10
    SUB x0, x5, x14
    SLTI x14, x13, 33
    SRAI x16, x24, 8
    XORI x8, x19, -130
    SRA x24, x7, x10
    SLTI x17, x13, 72
    SRAI x2, x27, 4
    OR x28, x23, x5
    SW x6, 336(x18)
    LUI x8, 0
    OR x13, x19, x2
    SLTIU x2, x2, -51
    SLTU x6, x4, x20
    XORI x15, x23, 96
    SRAI x19, x23, 18
    SRAI x1, x13, 25
    SLL x9, x9, x23
    XORI x26, x5, -60
    SLTIU x19, x17, -104
    SRAI x9, x7, 22
    SRA x13, x10, x10
    AUIPC x7, 4
    SRAI x26, x28, 16
    AUIPC x24, 1048557
    BGE x8, x21, 12
    SUB x29, x14, x28
    SLT x14, x15, x23
    ANDI x6, x3, 142
    ADDI x30, x23, -144
    SRLI x8, x14, 30
    XOR x8, x20, x21
    SLTI x0, x25, 181
    AND x24, x20, x18
    AND x24, x9, x15
    LUI x26, 524304
    ADDI x26, x26, 256
    LHU x16, 0(x26)
    SLL x20, x14, x24
    SRLI x1, x3, 0
    ADDI x6, x20, -34
    XOR x31, x5, x3
    LUI x11, 13
    ADDI x8, x2, 63
    SLT x20, x13, x19
    ADD x19, x30, x22
    AND x12, x22, x22
    SLLI x24, x22, 24
    SLL x23, x1, x10
    OR x24, x25, x16
    SRL x7, x5, x28
    ORI x30, x9, -85
    AUIPC x22, 0
    ADDI x22, x22, 8
    JALR x25, 16(x22)
    ADDI x28, x1, -186
    SLT x18, x8, x7
    ADD x16, x5, x12
    SLTIU x21, x3, -85
    SRA x27, x1, x13
    SRA x11, x29, x20
    SRAI x0, x8, 15
    SLTIU x29, x31, 79
    SRA x27, x14, x0
    AUIPC x0, 19
    SRAI x25, x12, 27
    SRA x1, x7, x23
    SLTU x5, x25, x7
    SLTI x1, x16, 8
    SRLI x0, x30, 4
    ADDI x14, x20, -149
    LUI x16, 1048556
    SRL x11, x13, x4
    SLLI x11, x30, 6
    SW x23, 396(x18)
    SRAI x9, x17, 20
    AUIPC x9, 1048571
    SRLI x29, x3, 4
    ADDI x7, x24, -63
    SLTU x2, x31, x16
    LUI x1, 1048568
    ORI x7, x25, -189
    ORI x3, x27, -163
    AND x16, x7, x22
    SLTIU x20, x27, -169
    ADD x27, x21, x18
    SRAI x8, x2, 22
    ANDI x10, x25, -101
    SRLI x1, x19, 9
    SLTU x8, x28, x10
    OR x28, x13, x30
    AUIPC x23, 1048548
    AND x18, x22, x15
    SRL x9, x20, x4
    ORI x27, x18, -63
    OR x8, x11, x8
    XORI x16, x5, -116
    XOR x10, x19, x2
    LUI x24, 7
    SLTI x24, x9, -192
    LUI x5, 4
    LUI x23, 1048567
    ANDI x2, x28, 181
    SRL x31, x27, x12
    SLL x14, x22, x12
    SUB x18, x17, x17
    SLL x26, x7, x30
    ADDI x2, x17, -144
    SLTU x0, x27, x26
    SLTU x3, x13, x19
    XORI x11, x17, -131
    BGE x8, x7, 16
    SLTU x17, x9, x31
    SUB x31, x30, x9
    XORI x26, x26, 48
    OR x20, x8, x5
    SRA x20, x27, x10
    ADD x22, x5, x28
    LUI x1, 5
    SLL x21, x30, x10
    SLT x1, x18, x25
    SLTU x5, x13, x25
    SRA x12, x27, x27
    SLTI x26, x30, -146
    ADD x29, x17, x30
    SLL x8, x10, x9
    ADD x5, x31, x9
    ANDI x17, x28, -9
    LUI x10, 524304
    ADDI x10, x10, 256
    LH x0, 112(x10)
    SUB x4, x9, x11
    SRA x9, x10, x6
    ORI x28, x8, -93
    SRAI x0, x26, 24
    ANDI x8, x4, -48
    BNE x14, x3, 32
    SRA x10, x30, x20
    ADDI x18, x17, 183
    LUI x11, 1048565
    SUB x24, x12, x23
    SRA x11, x20, x30
    ADD x2, x13, x31
    SRAI x29, x7, 16
    SRL x10, x4, x26
    ADD x6, x7, x10
    SLLI x14, x13, 18
    SLL x19, x30, x30
    ADD x10, x31, x14
    SRL x15, x3, x8
    ORI x23, x6, 175
    SUB x29, x0, x18
    SLTU x17, x30, x12
    AUIPC x3, 10
    SRLI x0, x22, 14
    SLTU x7, x16, x17
    SLTI x7, x30, -106
    XOR x7, x15, x30
    SRLI x12, x3, 12
    ORI x17, x24, 34
    SUB x5, x12, x3
    XORI x3, x11, -181
    LUI x28, 524304
    ADDI x28, x28, 256
    SH x0, 1488(x28)
    SRLI x14, x1, 31
    XORI x25, x31, 94
    AUIPC x20, 4
    SRAI x17, x26, 12
    SRA x6, x8, x20
    SLLI x12, x17, 6
    AND x6, x9, x4
    XORI x24, x0, 79
    SLTIU x30, x14, -185
    SRA x14, x23, x0
    SRAI x13, x7, 21
    OR x6, x15, x24
    SLT x2, x19, x11
    SRAI x15, x22, 25
    ORI x27, x30, 183
    AND x21, x21, x5
    SRLI x19, x1, 4
    AUIPC x16, 0
    ADDI x16, x16, 8
    JALR x5, 8(x16)
    SRA x2, x29, x8
    OR x22, x23, x0
    AUIPC x23, 18
    SLT x1, x0, x28
    ADDI x29, x1, -158
    SLLI x26, x16, 12
    SLLI x23, x0, 16
    SRAI x29, x2, 10
    ORI x17, x22, 71
    SRLI x14, x3, 31
    SRL x30, x21, x29
    SRLI x17, x1, 28
    AND x19, x30, x18
    SRAI x27, x14, 29
    SRLI x27, x12, 23
    OR x13, x3, x28
    SRLI x2, x21, 6
    SRL x8, x9, x8
    SW x8, 1365(x13)
    SLT x7, x18, x23
    ORI x18, x26, 114
    XORI x20, x18, -195
    ADDI x17, x24, -37
    ANDI x26, x4, 28
    SLTIU x0, x19, 121
    SRLI x28, x24, 6
    ANDI x23, x16, 94
    OR x9, x18, x2
    SLTIU x5, x16, 74
    LUI x14, 12
    XORI x23, x15, 13
    SUB x29, x20, x7
    LUI x15, 9
    ADD x28, x9, x0
    SRL x9, x9, x15
    AUIPC x10, 1048575
    SRA x13, x28, x27
    SRAI x16, x26, 11
    JAL x21, 8
    SLTIU x15, x26, 173
    SRAI x2, x9, 6
    SLLI x18, x22, 14
    AUIPC x24, 0
    SLTI x24, x12, -173
    LUI x4, 524304
    ADDI x4, x4, 256
    LW x4, 0(x4)
    AUIPC x19, 3
    ADDI x11, x31, 61
    SRLI x30, x1, 8
    SLL x25, x23, x13
    OR x9, x14, x20
    ORI x1, x26, -77
    SLTI x15, x12, 77
    SRLI x3, x5, 19
    SLT x22, x17, x18
    LUI x0, 19
    ANDI x26, x1, -174
    SLL x28, x8, x16
    ADD x1, x29, x4
    SLL x28, x15, x17
    XORI x17, x3, 96
    SRAI x14, x6, 23
    OR x26, x6, x23
    SLLI x31, x8, 28
    JAL x15, 8
    SLTU x0, x8, x14
    LUI x30, 0
    LUI x2, 1048569
    SRAI x14, x21, 5
    AUIPC x15, 3
    SRLI x26, x23, 13
    SRLI x2, x12, 15
    ADDI x2, x4, -106
    SRLI x31, x22, 17
    LUI x11, 524304
    ADDI x11, x11, 256
    LBU x22, 123(x11)
    SRA x14, x28, x11
    LUI x28, 9
    SLLI x25, x25, 28
    SLLI x8, x16, 23
    ADDI x3, x13, -70
    SRAI x18, x13, 9
    AUIPC x19, 1048562
    SLT x29, x24, x9
    AND x10, x26, x21
    AUIPC x27, 0
    ADDI x27, x27, 8
    JALR x6, 28(x27)
    XORI x17, x17, 83
    SLLI x11, x25, 12
    SRLI x19, x21, 12
    ADDI x9, x27, 152
    SLLI x29, x22, 10
    SLL x19, x1, x3
    ADD x16, x27, x9
    SRLI x25, x12, 7
    ADDI x14, x5, -174
    SLTI x27, x22, -158
    AND x13, x7, x17
    AUIPC x4, 0
    SLTIU x10, x7, 28
    SRAI x27, x24, 14
    SRAI x14, x31, 3
    SRL x15, x11, x3
    SLTIU x25, x26, -64
    LUI x22, 1048568
    SRLI x4, x1, 15
    AUIPC x3, 1048573
    LHU x0, 176(x11)
    LUI x1, 28
    SUB x2, x3, x20
    ADDI x8, x23, -11
    ADDI x4, x29, -38
    AUIPC x16, 1048548
    
    jal x22,  exiting_step
    li x23, 0xFFFF      # Should skip
exiting_step:
    li x31, 0x80012100
    li x30, 0xFFFFFFFF
    # this notifies UVM testbench to stop execution
    sw x30, 0(x31)
