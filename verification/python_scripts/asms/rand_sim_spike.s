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

    ADD x1, x18, x18
    SLTIU x14, x15, -113
    LUI x17, 1048561
    OR x21, x13, x14
    LUI x17, 1048567
    SRA x14, x13, x17
    SLT x6, x14, x15
    SLTIU x31, x10, 6
    SRA x18, x10, x0
    SRL x16, x19, x17
    LUI x9, 1048573
    ORI x9, x0, 198
    SRLI x17, x11, 0
    XOR x0, x10, x21
    SRL x20, x12, x15
    SLLI x21, x17, 30
    AUIPC x0, 7
    SRAI x13, x20, 2
    BEQ x19, x20, 36
    SLTU x8, x14, x10
    AUIPC x30, 11
    AUIPC x30, 9
    SLT x1, x7, x1
    XOR x15, x18, x16
    ADDI x28, x16, 39
    XORI x19, x11, -148
    SRL x30, x13, x9
    ADDI x31, x31, 168
    OR x24, x0, x15
    SRL x16, x17, x12
    ADDI x29, x15, 98
    SLTI x8, x20, 0
    XORI x17, x11, -63
    XORI x26, x17, -180
    ORI x1, x9, 14
    SRLI x26, x5, 4
    LUI x30, 1048560
    SUB x24, x6, x0
    SUB x27, x7, x11
    LUI x4, 524304
    ADDI x4, x4, 256
    LH x6, -154(x27)
    XOR x11, x4, x29
    SRA x11, x17, x27
    SLTIU x15, x30, 134
    AUIPC x20, 22
    BNE x8, x30, 32
    SLL x3, x1, x17
    SLLI x10, x20, 26
    SLTU x6, x11, x7
    SLLI x11, x31, 12
    SLTI x9, x20, -151
    SLL x13, x31, x26
    ANDI x15, x27, -41
    SRAI x6, x15, 0
    XOR x4, x21, x11
    SRA x23, x8, x7
    SLLI x7, x30, 21
    SLTIU x13, x27, -32
    SLL x19, x14, x24
    XORI x11, x18, 3
    SRA x12, x17, x31
    SRAI x5, x27, 26
    LUI x19, 524304
    ADDI x19, x19, 256
    LBU x21, 203(x19)
    LUI x12, 1048570
    OR x28, x31, x4
    SUB x2, x14, x4
    XOR x9, x22, x24
    AUIPC x30, 1048552
    SLLI x20, x5, 28
    SLL x2, x26, x26
    ADD x7, x16, x14
    SUB x30, x20, x11
    AUIPC x3, 42
    AUIPC x13, 4
    SLTIU x20, x12, -58
    SRAI x17, x18, 6
    SRL x31, x7, x4
    SRLI x9, x24, 23
    ADDI x20, x31, 96
    LUI x7, 19
    SLL x30, x13, x27
    SLTI x2, x2, -32
    ANDI x12, x12, 153
    SLLI x10, x23, 9
    SLTIU x16, x31, -165
    XORI x6, x10, 32
    SLL x0, x23, x30
    SRAI x16, x7, 14
    SRLI x20, x29, 11
    SLLI x21, x19, 31
    ANDI x20, x5, -148
    SRLI x22, x29, 27
    AUIPC x10, 0
    ADDI x10, x10, 8
    JALR x20, 8(x10)
    SLTU x14, x5, x16
    SW x2, 1884(x19)
    SLTU x19, x3, x0
    ADD x25, x18, x0
    XORI x10, x19, -149
    SUB x23, x19, x5
    SUB x12, x6, x17
    SLTI x0, x3, 75
    ORI x6, x20, -41
    SLTI x20, x18, -148
    SLL x14, x11, x6
    SRAI x9, x28, 25
    OR x9, x6, x16
    LUI x2, 1048567
    XORI x26, x30, 147
    AUIPC x30, 1
    SRL x24, x27, x25
    SLTI x7, x18, 77
    ANDI x28, x26, -125
    SLLI x17, x20, 0
    AND x4, x15, x15
    SLT x29, x27, x7
    SUB x13, x11, x6
    AUIPC x29, 0
    ADDI x29, x29, 8
    JALR x19, 12(x29)
    ADDI x16, x19, 193
    SRA x2, x16, x17
    LUI x19, 524304
    ADDI x19, x19, 256
    SB x19, 896(x27)
    SLTU x26, x17, x19
    SLT x17, x19, x31
    SLL x15, x18, x21
    LUI x12, 1048569
    SLTIU x16, x29, -179
    ADDI x16, x9, 173
    XORI x0, x2, 104
    AUIPC x3, 2
    SLL x19, x24, x2
    SLL x28, x23, x16
    XOR x7, x11, x9
    XOR x4, x16, x0
    ORI x24, x9, -159
    SLL x24, x27, x25
    ANDI x15, x1, 32
    SLTIU x17, x9, -74
    SLT x3, x29, x31
    SRLI x21, x1, 21
    SRLI x18, x3, 27
    SRL x2, x5, x19
    SLTI x0, x30, 128
    SRLI x18, x10, 3
    SLTU x24, x22, x13
    SRAI x0, x1, 7
    ORI x12, x24, -71
    SRLI x5, x2, 24
    OR x26, x6, x13
    SLL x24, x1, x31
    SRLI x1, x15, 15
    AND x17, x7, x19
    XOR x28, x27, x18
    BEQ x8, x18, 8
    XORI x23, x24, -3
    SRLI x26, x29, 30
    SRLI x24, x30, 17
    SLTU x30, x11, x2
    SLTI x10, x20, -106
    SLTIU x26, x27, 59
    ADD x12, x18, x12
    AUIPC x6, 6
    SUB x11, x16, x25
    AND x25, x25, x22
    LUI x17, 1048561
    LUI x18, 524304
    ADDI x18, x18, 256
    LBU x15, -103(x27)
    SUB x30, x7, x28
    ADD x16, x14, x13
    ADD x17, x15, x8
    ORI x16, x24, 139
    SUB x23, x1, x2
    SLL x22, x22, x19
    SLTIU x10, x5, 26
    SRL x17, x24, x12
    SLTI x27, x21, 67
    ORI x31, x27, -25
    XORI x15, x17, -93
    XORI x17, x30, -118
    BLTU x31, x29, 20
    SUB x10, x14, x29
    SLLI x1, x14, 0
    ADD x28, x29, x10
    SLL x31, x11, x31
    XOR x9, x27, x14
    ANDI x21, x20, 33
    ADDI x1, x6, 135
    XORI x21, x18, -165
    ADDI x8, x9, 89
    XOR x6, x13, x14
    AND x25, x10, x13
    ORI x10, x13, -96
    SLL x12, x24, x24
    ADD x14, x27, x29
    SLL x5, x6, x26
    ADDI x10, x24, -80
    LBU x11, 97(x18)
    ANDI x10, x9, -22
    SRL x24, x23, x12
    ADDI x23, x9, -34
    SRA x3, x5, x14
    AUIPC x25, 1048556
    SRL x29, x17, x25
    XOR x8, x24, x4
    SLT x11, x16, x4
    AND x22, x7, x30
    LUI x27, 0
    XORI x19, x10, 138
    SLT x11, x9, x5
    ANDI x18, x30, -95
    XORI x16, x11, 173
    SRLI x29, x21, 20
    XORI x26, x28, 166
    SLTIU x13, x7, -99
    ADDI x8, x1, 184
    ORI x28, x31, 160
    SLTIU x7, x10, -24
    OR x11, x7, x22
    SRL x27, x7, x16
    SLTI x20, x19, 105
    AND x8, x12, x19
    XOR x24, x26, x21
    ADD x9, x4, x14
    SLTIU x2, x23, 190
    SLTU x10, x7, x7
    SUB x9, x12, x15
    ADDI x1, x19, 24
    SLLI x13, x20, 23
    ADDI x26, x25, -197
    SUB x16, x26, x22
    AUIPC x18, 7
    SRL x20, x3, x13
    XOR x11, x14, x4
    SLLI x31, x20, 13
    AUIPC x17, 0
    ADDI x17, x17, 8
    JALR x20, 28(x17)
    ORI x7, x22, 71
    SLT x7, x3, x6
    SLTU x11, x18, x20
    SLL x17, x11, x22
    AND x7, x14, x26
    XORI x3, x2, -151
    ANDI x20, x16, 104
    SRA x9, x25, x30
    XORI x6, x23, -17
    SLL x17, x15, x8
    ADD x5, x24, x2
    SRLI x10, x25, 29
    SRLI x4, x10, 26
    SLTIU x23, x5, -179
    SLL x27, x23, x27
    SLL x13, x4, x18
    LUI x29, 524304
    ADDI x29, x29, 256
    LH x7, 22(x29)
    SLTIU x29, x19, 99
    SLTI x29, x12, 124
    ADD x2, x4, x20
    SRL x2, x11, x7
    ADD x27, x5, x23
    SLLI x31, x4, 26
    ANDI x30, x9, 193
    SLT x17, x29, x2
    SRAI x0, x8, 28
    ORI x24, x11, 63
    SLL x27, x0, x11
    ANDI x13, x7, -173
    ADDI x23, x31, 28
    SLT x20, x24, x2
    ADD x20, x24, x1
    SLL x6, x3, x29
    SRLI x10, x12, 23
    XOR x4, x6, x2
    SLTI x4, x10, 2
    BLT x8, x17, 32
    SRAI x18, x3, 3
    AUIPC x10, 11
    SLTI x31, x10, 65
    SUB x16, x1, x7
    OR x29, x6, x28
    SLTU x14, x22, x6
    ADDI x15, x9, 41
    SRLI x25, x12, 5
    SLTI x23, x17, -45
    OR x9, x18, x10
    AUIPC x18, 1048565
    LUI x13, 1048572
    SLT x6, x30, x4
    XOR x11, x21, x16
    SLTIU x24, x6, 137
    LUI x21, 524304
    ADDI x21, x21, 256
    LBU x27, 196(x21)
    XORI x10, x22, -58
    AUIPC x17, 1048561
    XORI x15, x25, 49
    SUB x15, x16, x0
    ORI x22, x1, -60
    BEQ x26, x14, 32
    ANDI x9, x4, -48
    SRL x10, x19, x2
    AND x26, x7, x13
    OR x6, x29, x25
    SLTI x12, x11, 91
    SRA x2, x18, x26
    SLL x9, x6, x27
    SH x31, 468(x21)
    ORI x19, x21, -127
    SLLI x18, x10, 9
    ANDI x1, x9, -174
    ORI x11, x24, -147
    ADDI x23, x27, 175
    LUI x17, 6
    SUB x17, x31, x2
    SRL x1, x31, x17
    AND x18, x12, x5
    AND x28, x2, x7
    XORI x30, x16, 121
    ADDI x10, x20, 192
    SLTIU x19, x4, 18
    ADDI x1, x31, -67
    AUIPC x2, 1048572
    AND x8, x14, x12
    OR x6, x27, x16
    XOR x2, x13, x11
    AND x16, x4, x1
    ORI x16, x17, 159
    SRA x24, x6, x26
    SLTI x1, x23, -28
    SRLI x23, x8, 0
    SRLI x25, x7, 7
    SRA x29, x30, x5
    AUIPC x20, 0
    ADDI x20, x20, 8
    JALR x12, 20(x20)
    AND x1, x13, x25
    SRA x20, x6, x19
    XOR x20, x8, x19
    SRA x6, x31, x8
    AUIPC x20, 1048571
    AND x13, x11, x26
    ADDI x26, x15, 113
    ADDI x18, x18, 101
    ANDI x4, x26, 138
    LUI x1, 1048564
    SUB x4, x1, x20
    SLT x22, x20, x8
    SLTIU x15, x25, -37
    SLTI x3, x8, -3
    SUB x8, x20, x0
    SLLI x25, x14, 21
    SLT x21, x2, x19
    SLT x30, x21, x30
    SLTU x11, x22, x25
    SRLI x17, x4, 1
    SUB x24, x20, x19
    AND x21, x31, x29
    XOR x0, x17, x9
    XORI x9, x19, -184
    LUI x3, 524304
    ADDI x3, x3, 256
    SB x31, 116(x3)
    SLTI x8, x25, 38
    SLTU x5, x3, x12
    AND x1, x24, x4
    SLL x22, x20, x5
    XORI x12, x1, 88
    SRAI x13, x23, 14
    SLT x14, x2, x8
    ADD x8, x8, x31
    SRL x8, x25, x1
    SLT x28, x20, x25
    ADD x12, x29, x10
    SLT x20, x27, x23
    LUI x22, 1048563
    SRAI x17, x18, 7
    SRA x5, x12, x24
    SUB x16, x15, x2
    SLL x20, x1, x28
    SLTU x23, x23, x22
    SLLI x31, x24, 17
    SRAI x8, x17, 22
    SRAI x5, x23, 10
    BEQ x6, x14, 24
    ANDI x26, x19, -180
    SLTU x4, x16, x16
    SRAI x7, x10, 21
    XOR x1, x15, x24
    ADD x17, x10, x31
    SRL x23, x6, x19
    LUI x15, 1048565
    XORI x11, x20, -36
    ADDI x9, x22, 174
    ADDI x27, x21, -39
    SLTIU x5, x19, 169
    ADD x15, x26, x3
    SLL x10, x29, x16
    LBU x29, 142(x3)
    SLTI x12, x17, -158
    SLTU x12, x10, x15
    OR x24, x10, x9
    ANDI x16, x22, 188
    SLLI x1, x16, 15
    ADD x12, x13, x3
    SRAI x0, x4, 7
    ANDI x28, x0, -134
    OR x27, x1, x25
    XORI x25, x27, 74
    ADD x5, x1, x6
    AUIPC x25, 0
    ADDI x25, x25, 8
    JALR x14, 28(x25)
    ADDI x17, x2, -112
    XOR x1, x1, x8
    SLL x22, x29, x3
    SLTI x4, x19, 138
    SLT x16, x6, x3
    SLT x24, x16, x28
    ORI x4, x18, -176
    SLL x1, x11, x30
    AUIPC x6, 7
    LB x14, 191(x15)
    SRAI x14, x23, 16
    SLT x30, x11, x16
    SRA x31, x6, x30
    SLTU x6, x9, x17
    ADD x3, x6, x9
    LUI x19, 0
    SLTIU x25, x16, -13
    SLLI x7, x26, 26
    SLL x29, x10, x29
    SRA x12, x12, x1
    ADD x4, x0, x10
    SLTIU x20, x27, -121
    SRAI x23, x31, 30
    XORI x16, x12, 116
    SRL x19, x8, x1
    AUIPC x19, 0
    ADDI x19, x19, 8
    JALR x19, 24(x19)
    LUI x9, 7
    SUB x5, x22, x19
    SLLI x31, x20, 10
    SUB x16, x26, x18
    SLTI x13, x19, -51
    ORI x17, x11, -19
    AUIPC x18, 1048559
    XORI x1, x15, -80
    SRAI x14, x5, 5
    ANDI x12, x1, -111
    XOR x3, x24, x22
    XOR x22, x12, x3
    XORI x4, x27, -9
    SRL x24, x9, x13
    AND x10, x26, x4
    AND x31, x11, x9
    SLTIU x11, x12, -79
    SLLI x16, x9, 3
    LHU x20, 224(x15)
    SRAI x31, x15, 7
    ADD x1, x9, x20
    SLL x9, x11, x5
    SRAI x1, x28, 12
    SRAI x24, x17, 28
    AUIPC x30, 1048555
    SRA x31, x1, x5
    SRA x22, x24, x6
    LUI x3, 1048565
    SLL x15, x19, x11
    ANDI x17, x26, -113
    SRA x21, x20, x20
    AUIPC x3, 1048575
    SRA x27, x18, x29
    SLTU x25, x3, x12
    SUB x15, x0, x15
    SRLI x14, x8, 4
    SRA x6, x9, x25
    SRL x31, x6, x18
    ADD x6, x22, x23
    SRA x11, x24, x22
    XOR x16, x22, x28
    SLL x26, x30, x2
    SRA x31, x29, x12
    SLLI x30, x1, 22
    BEQ x30, x13, 28
    SLT x3, x7, x31
    SLTU x6, x18, x0
    AUIPC x5, 6
    LUI x17, 1
    SRA x23, x29, x11
    SLTIU x7, x3, -112
    ORI x7, x5, 33
    SLTU x2, x22, x21
    SLTIU x27, x27, 106
    ORI x24, x2, 79
    SLT x27, x10, x7
    LUI x24, 524304
    ADDI x24, x24, 256
    SB x8, 615(x24)
    SUB x20, x26, x7
    ORI x4, x22, -131
    SLTI x16, x7, 112
    XORI x24, x26, -70
    SLT x31, x17, x22
    SLL x21, x9, x30
    SRLI x26, x2, 31
    SUB x28, x22, x6
    ADD x3, x15, x30
    ORI x15, x3, -72
    SLTU x28, x4, x21
    SRAI x7, x17, 20
    SLT x12, x21, x9
    ADDI x22, x11, -12
    SLL x9, x31, x15
    SLLI x31, x28, 24
    XORI x18, x2, -189
    SLTU x25, x1, x2
    SLTU x1, x22, x0
    AND x19, x9, x1
    SUB x11, x9, x21
    AND x8, x22, x21
    SRL x8, x31, x20
    ADDI x25, x31, -122
    LUI x1, 1
    ADD x27, x15, x25
    SRL x2, x2, x31
    SLT x21, x19, x14
    BEQ x27, x29, 24
    OR x27, x20, x27
    XORI x12, x10, 109
    LUI x9, 524304
    ADDI x9, x9, 256
    LHU x1, 204(x9)
    AUIPC x26, 1048566
    AND x19, x18, x25
    SLTI x28, x21, 103
    SRL x11, x10, x29
    XOR x15, x25, x22
    SLTIU x29, x15, 72
    SRAI x8, x23, 2
    OR x20, x15, x10
    SLL x9, x4, x7
    SRL x28, x8, x5
    LUI x30, 1048574
    LUI x8, 1048571
    SRL x22, x0, x7
    SRAI x18, x26, 14
    OR x14, x16, x4
    SLT x31, x14, x28
    SLLI x6, x6, 9
    SRL x15, x13, x31
    SLTIU x17, x14, -68
    ADDI x24, x28, 42
    SRA x10, x4, x24
    SRLI x26, x8, 6
    SLTI x19, x15, 65
    BEQ x31, x25, 12
    ANDI x27, x17, -93
    AND x12, x23, x22
    ADDI x8, x27, 194
    SRLI x4, x24, 2
    SLT x5, x28, x20
    SRL x4, x31, x10
    ORI x21, x1, 50
    OR x1, x31, x14
    SLL x13, x31, x6
    SLLI x26, x11, 27
    SLL x23, x11, x26
    SUB x27, x10, x29
    SUB x12, x24, x11
    ANDI x3, x12, -110
    LUI x27, 524304
    ADDI x27, x27, 256
    SW x13, 1384(x27)
    AUIPC x29, 0
    ADDI x29, x29, 8
    JALR x24, 24(x29)
    SLTI x14, x16, 117
    SLL x24, x0, x27
    SUB x8, x11, x11
    ANDI x14, x6, -117
    AND x16, x28, x14
    SLL x6, x28, x5
    OR x31, x11, x27
    LBU x28, 49(x31)
    SLLI x8, x4, 9
    SRLI x13, x13, 9
    ORI x20, x12, -122
    SLLI x16, x6, 21
    ANDI x16, x27, -34
    SLT x16, x29, x9
    SLLI x3, x13, 10
    SLL x12, x15, x27
    ADDI x19, x30, 88
    SLTU x27, x20, x2
    SRLI x16, x29, 31
    SLTI x17, x31, 186
    SRL x30, x27, x12
    AUIPC x19, 16
    SRAI x29, x16, 20
    XOR x8, x31, x9
    SLLI x31, x14, 25
    ADD x0, x10, x28
    ADDI x7, x1, 126
    XOR x5, x26, x17
    AUIPC x18, 0
    ADDI x18, x18, 8
    JALR x8, 20(x18)
    SRL x16, x11, x19
    AUIPC x10, 0
    LUI x8, 1048565
    SRA x19, x17, x17
    SRL x6, x25, x7
    SRLI x5, x11, 13
    LUI x27, 1048559
    ORI x18, x17, 39
    AUIPC x26, 2
    SLTIU x7, x27, -172
    AND x27, x27, x13
    ADDI x17, x15, 157
    OR x23, x2, x13
    ANDI x4, x20, -9
    SRL x28, x9, x0
    SLLI x0, x8, 23
    OR x3, x6, x27
    ANDI x23, x13, 133
    LUI x14, 8
    SRLI x0, x25, 30
    ADDI x17, x27, -161
    LUI x20, 524304
    ADDI x20, x20, 256
    LBU x19, 221(x20)
    ADD x8, x10, x29
    ADDI x23, x1, -177
    ORI x23, x8, 10
    SLTI x7, x29, -78
    SRLI x2, x27, 1
    ADDI x29, x17, 33
    ADD x20, x3, x0
    SLT x4, x12, x2
    AND x23, x12, x23
    LUI x2, 1048574
    AUIPC x29, 0
    ADDI x29, x29, 8
    JALR x31, 4(x29)
    SLTIU x26, x24, -65
    LUI x11, 524304
    ADDI x11, x11, 256
    SH x16, 934(x11)
    ADDI x23, x25, -35
    SRL x19, x19, x6
    AUIPC x12, 1048549
    AUIPC x30, 0
    ADDI x30, x30, 8
    JALR x15, 36(x30)
    XOR x20, x31, x27
    SRLI x26, x30, 31
    SLTI x26, x22, 68
    XOR x21, x19, x3
    SLLI x5, x26, 25
    ADDI x21, x21, 19
    ADD x13, x21, x14
    SLTU x29, x5, x21
    SRA x8, x29, x28
    SRLI x26, x31, 6
    SUB x4, x30, x14
    ANDI x11, x5, 158
    SRAI x18, x12, 31
    ADD x12, x3, x3
    LUI x2, 524304
    ADDI x2, x2, 256
    SB x5, 1474(x2)
    SUB x20, x23, x26
    SLT x15, x3, x15
    AND x11, x25, x15
    AUIPC x0, 2
    XORI x21, x9, -90
    SRLI x22, x0, 31
    SRL x2, x9, x18
    ADDI x5, x24, -176
    ANDI x4, x30, 73
    ANDI x2, x3, -124
    SRL x15, x28, x29
    ORI x21, x10, 171
    LUI x11, 1048571
    ADDI x8, x24, 60
    XOR x25, x26, x15
    SRLI x27, x13, 15
    ORI x31, x23, 128
    AUIPC x1, 1048569
    SUB x3, x1, x4
    XOR x8, x10, x31
    XORI x22, x30, 165
    SLT x27, x8, x7
    ORI x10, x4, 166
    XOR x28, x16, x23
    SLT x4, x27, x10
    SLT x4, x15, x19
    XOR x19, x26, x9
    SRLI x2, x29, 13
    ADD x26, x7, x14
    SLLI x13, x2, 3
    XOR x26, x21, x20
    XORI x2, x16, -72
    OR x11, x19, x18
    AND x8, x24, x20
    SRLI x24, x26, 30
    AUIPC x30, 7
    SRL x20, x5, x8
    BLTU x4, x3, 32
    ADD x7, x3, x23
    SLL x10, x2, x13
    OR x3, x31, x22
    SLT x13, x19, x22
    SLTI x2, x7, -169
    SRL x10, x11, x3
    SRLI x16, x31, 19
    SRA x26, x21, x13
    ADDI x13, x9, 109
    OR x7, x27, x30
    SLLI x13, x8, 12
    XORI x18, x12, -130
    ANDI x27, x14, 108
    SLL x8, x0, x9
    ORI x2, x0, -190
    SLT x26, x8, x4
    LUI x19, 524304
    ADDI x19, x19, 256
    SB x31, 1950(x19)
    SRLI x28, x1, 27
    AND x9, x23, x23
    SLL x24, x21, x6
    LUI x24, 1048572
    AND x2, x14, x27
    LUI x24, 1048564
    LUI x16, 1048572
    SRA x3, x13, x6
    LUI x29, 1048575
    SRA x26, x19, x0
    SLLI x28, x8, 5
    SLTI x24, x21, -97
    BEQ x6, x2, 8
    LW x21, 76(x26)
    LUI x16, 1048571
    ANDI x12, x1, 2
    AUIPC x10, 28
    SLTIU x2, x24, 9
    LUI x13, 1048559
    SLTIU x26, x0, -85
    SRAI x14, x29, 1
    SLTI x4, x5, 138
    SLTIU x12, x1, -134
    SLTIU x19, x10, -177
    LUI x12, 9
    ADDI x21, x30, -154
    ORI x25, x13, 73
    XORI x20, x16, 70
    JAL x26, 4
    SLTI x11, x15, 192
    OR x30, x24, x30
    ADDI x24, x8, -37
    SRA x16, x14, x29
    SLLI x28, x15, 19
    XOR x29, x2, x27
    SUB x19, x20, x14
    SLTI x28, x21, 185
    SLT x24, x30, x19
    SLT x7, x16, x14
    XOR x0, x22, x5
    SLT x12, x5, x17
    SLTU x18, x13, x9
    SRLI x25, x2, 23
    SLL x2, x1, x9
    LUI x30, 524304
    ADDI x30, x30, 256
    LH x23, 98(x30)
    ANDI x14, x19, 8
    XOR x11, x2, x10
    SLT x14, x13, x31
    ANDI x27, x28, 138
    ANDI x2, x10, -33
    JAL x21, 40
    SRLI x23, x6, 24
    AND x22, x23, x28
    OR x14, x18, x29
    SRAI x1, x1, 4
    ORI x0, x10, -116
    SRL x9, x31, x25
    SRA x15, x18, x16
    LUI x26, 17
    SLLI x13, x25, 13
    ADDI x0, x6, 164
    SLTU x27, x2, x1
    XORI x14, x7, -62
    SLTU x0, x13, x1
    ANDI x9, x2, -163
    AND x20, x17, x30
    ADDI x25, x17, -156
    OR x12, x14, x3
    SLT x24, x30, x6
    SRLI x9, x7, 0
    XOR x8, x6, x9
    SB x4, 1532(x20)
    SLLI x17, x21, 18
    AUIPC x21, 1048548
    SLLI x26, x8, 31
    OR x8, x9, x4
    AUIPC x17, 1048565
    SRA x14, x1, x12
    ANDI x18, x22, 31
    SLLI x25, x4, 25
    SRAI x1, x24, 29
    AUIPC x23, 1048559
    LUI x31, 1048573
    ORI x6, x1, 112
    SLTU x27, x27, x19
    AUIPC x7, 0
    ADDI x7, x7, 8
    JALR x9, 24(x7)
    SUB x0, x6, x1
    XOR x14, x30, x4
    SLTI x6, x15, -9
    SRL x19, x13, x10
    SRL x20, x8, x7
    SLT x28, x0, x2
    SW x4, 356(x20)
    LUI x17, 1048562
    OR x25, x7, x21
    ADD x3, x19, x17
    SLTI x25, x20, 180
    SRLI x29, x29, 3
    OR x3, x8, x14
    SRLI x30, x2, 13
    ANDI x14, x14, -48
    ADD x15, x16, x15
    AND x8, x15, x18
    SUB x21, x17, x26
    OR x29, x20, x29
    XOR x23, x10, x26
    XORI x11, x23, 182
    SLT x19, x21, x4
    SLT x1, x30, x1
    SLTU x24, x8, x8
    SRA x21, x22, x4
    SLT x3, x8, x21
    ADDI x15, x15, 105
    AUIPC x24, 1048573
    OR x3, x18, x13
    SRLI x17, x24, 27
    JAL x21, 12
    OR x29, x25, x28
    OR x6, x8, x27
    ADD x4, x26, x29
    SRA x10, x10, x0
    LUI x25, 18
    SLTIU x17, x4, 180
    SRL x21, x23, x2
    SLLI x12, x24, 2
    AND x19, x20, x7
    SRL x22, x31, x25
    SRL x11, x15, x22
    LUI x3, 4
    SRAI x14, x27, 24
    XOR x4, x23, x24
    SRLI x14, x6, 23
    ANDI x10, x22, -23
    SLT x26, x10, x0
    SRLI x24, x27, 8
    SB x20, 1828(x20)
    SLTIU x28, x8, 193
    XOR x10, x8, x6
    SLTU x9, x2, x22
    SRL x31, x23, x8
    SUB x31, x23, x22
    LUI x3, 1048561
    OR x25, x6, x19
    SLLI x10, x31, 7
    ORI x8, x24, -1
    SUB x0, x24, x7
    ANDI x29, x18, -172
    XORI x29, x24, 87
    ADDI x22, x1, -11
    LUI x1, 1048573
    SRL x7, x24, x5
    OR x28, x28, x25
    SRLI x27, x12, 24
    AND x31, x20, x7
    ANDI x29, x23, -12
    XOR x3, x23, x10
    XORI x27, x12, -155
    AUIPC x30, 1048551
    OR x9, x14, x1
    LUI x24, 1048568
    OR x6, x0, x4
    ORI x1, x26, -70
    SLTI x19, x15, -159
    SRL x20, x6, x4
    SLTIU x16, x12, -200
    ORI x24, x22, 181
    XOR x2, x0, x17
    ANDI x2, x27, 189
    AUIPC x29, 0
    ADDI x29, x29, 8
    JALR x11, 32(x29)
    SRLI x11, x28, 3
    SLTIU x8, x15, 160
    ANDI x0, x17, 4
    SLL x2, x15, x24
    AUIPC x21, 13
    SRL x24, x19, x7
    SLLI x4, x15, 28
    SLL x20, x5, x8
    SLT x19, x14, x18
    SLTI x20, x24, -98
    SLLI x21, x19, 23
    SLTU x5, x18, x28
    LUI x21, 524304
    ADDI x21, x21, 256
    LHU x3, 72(x21)
    OR x31, x1, x17
    AUIPC x5, 1048572
    ORI x14, x28, 18
    AUIPC x15, 6
    XORI x11, x5, -127
    SRA x20, x14, x27
    SUB x17, x8, x26
    OR x18, x2, x17
    AND x25, x24, x3
    SRL x29, x12, x17
    AUIPC x22, 1048556
    SUB x9, x9, x17
    XORI x0, x7, 137
    SLTI x10, x28, 198
    SLT x6, x2, x14
    AND x1, x19, x9
    ADD x11, x22, x20
    XOR x29, x17, x5
    OR x20, x23, x7
    SRAI x13, x26, 19
    AUIPC x5, 1048572
    BLT x12, x28, 36
    SLLI x13, x18, 12
    AND x28, x8, x8
    SUB x6, x11, x7
    SLTI x18, x1, 58
    SLTIU x6, x20, -144
    ADD x15, x21, x26
    ORI x1, x27, 148
    SRLI x9, x20, 5
    SLL x22, x30, x0
    SRAI x5, x7, 16
    LBU x9, 189(x15)
    XOR x17, x3, x27
    SRA x0, x13, x21
    SLTIU x16, x3, -168
    SLLI x16, x6, 16
    XORI x7, x2, -115
    XORI x26, x19, 186
    ANDI x13, x5, -75
    OR x1, x31, x17
    SLT x17, x23, x9
    ADD x15, x14, x2
    SLTU x10, x20, x11
    ORI x29, x23, 199
    LUI x10, 1048560
    SLTIU x14, x12, 25
    SRL x7, x29, x28
    SUB x26, x27, x25
    AUIPC x25, 0
    ADDI x25, x25, 8
    JALR x9, 16(x25)
    SRA x10, x22, x6
    SUB x29, x21, x20
    SRA x15, x0, x17
    SLT x5, x17, x18
    ADD x4, x15, x13
    SRLI x12, x1, 14
    SRL x22, x23, x27
    ORI x23, x3, -120
    SRLI x22, x7, 12
    XORI x0, x22, -18
    XOR x8, x4, x27
    XORI x3, x14, -62
    SRAI x22, x3, 11
    SRLI x28, x9, 24
    SLL x28, x31, x6
    SH x26, 554(x21)
    SLLI x23, x2, 13
    OR x9, x7, x25
    SRA x29, x26, x4
    ADD x22, x24, x27
    SLTI x5, x5, 129
    XOR x15, x28, x4
    ADD x30, x19, x9
    AUIPC x31, 1
    SRA x13, x0, x8
    SRLI x18, x6, 31
    AND x18, x4, x6
    ADDI x3, x14, 36
    SLL x22, x20, x12
    ADDI x8, x11, 50
    SLTIU x20, x25, -76
    ADDI x30, x15, 102
    LUI x10, 1048570
    SLTU x8, x7, x13
    SUB x14, x18, x22
    SUB x16, x4, x8
    LUI x12, 1048568
    AUIPC x1, 1048554
    SUB x29, x5, x3
    XOR x31, x14, x12
    ANDI x19, x25, 46
    BEQ x29, x10, 12
    SB x0, 1012(x21)
    SRL x0, x0, x5
    OR x25, x17, x29
    ADDI x24, x16, -176
    SRAI x6, x3, 4
    SRL x29, x9, x30
    SLLI x5, x1, 19
    SLLI x2, x29, 0
    ADDI x12, x21, -143
    ADD x28, x22, x26
    SUB x21, x6, x22
    XORI x5, x27, 146
    XOR x2, x12, x12
    SRL x17, x14, x10
    ADD x19, x26, x9
    XOR x4, x24, x23
    OR x23, x8, x2
    SRL x20, x30, x18
    AUIPC x13, 6
    AUIPC x2, 0
    ADDI x2, x2, 8
    JALR x15, 40(x2)
    SLTI x23, x28, -120
    SRAI x24, x21, 30
    AND x3, x25, x21
    SRLI x2, x29, 29
    XORI x22, x29, -57
    SLLI x1, x21, 17
    XORI x22, x2, 180
    ANDI x12, x27, 198
    SLTU x5, x3, x3
    SRA x12, x17, x30
    SRAI x7, x11, 16
    AND x4, x25, x11
    SRA x21, x6, x12
    ADD x27, x12, x3
    XORI x17, x4, -179
    ADDI x4, x14, -45
    SLT x27, x29, x0
    SLTU x20, x0, x2
    AND x17, x10, x31
    SLT x8, x1, x14
    XORI x0, x10, 173
    AND x28, x26, x27
    ANDI x1, x11, -135
    SLTIU x6, x4, -185
    SRA x3, x21, x20
    SLTIU x4, x26, 200
    SH x26, 1588(x21)
    SRL x22, x8, x4
    SLTI x10, x29, -165
    AUIPC x4, 12
    SLTIU x18, x19, -198
    SLTU x15, x14, x27
    SLL x6, x20, x3
    SLLI x5, x5, 31
    SRLI x11, x6, 12
    XOR x4, x23, x9
    SLT x0, x25, x31
    SLTIU x17, x6, -70
    AND x29, x18, x9
    AUIPC x12, 0
    ADDI x12, x12, 8
    JALR x12, 12(x12)
    ORI x11, x6, -84
    SRA x27, x1, x25
    XORI x2, x10, -137
    SRA x9, x16, x30
    OR x17, x23, x5
    SLLI x6, x28, 11
    AUIPC x5, 4
    SLTIU x10, x23, -5
    SLLI x0, x15, 10
    SH x14, 1024(x21)
    SRAI x7, x24, 19
    SRAI x29, x24, 13
    SLTU x12, x23, x3
    ANDI x28, x7, -46
    SLLI x24, x9, 13
    ADD x25, x7, x13
    XOR x12, x4, x9
    AND x15, x11, x29
    SLTI x25, x19, -107
    JAL x29, 16
    ANDI x23, x18, 130
    SLTIU x21, x17, -183
    SLL x4, x30, x31
    SLT x2, x31, x5
    SRLI x27, x27, 0
    AND x25, x29, x4
    ADD x13, x27, x29
    ANDI x20, x2, 145
    AUIPC x24, 1048553
    ORI x29, x5, -72
    OR x29, x27, x6
    ORI x18, x29, -43
    SRLI x9, x2, 2
    ADD x5, x17, x22
    ORI x27, x27, -51
    ADDI x16, x5, -174
    SLLI x5, x6, 23
    SLTI x9, x31, 45
    SB x9, 1562(x21)
    AND x20, x19, x5
    XOR x11, x9, x20
    ADDI x2, x6, 5
    XORI x2, x22, 130
    ANDI x18, x27, -99
    SLL x14, x16, x2
    SLL x0, x17, x19
    AUIPC x5, 1048566
    XORI x27, x27, -40
    LUI x20, 1048567
    SRLI x20, x0, 5
    XORI x25, x0, -61
    SRAI x16, x13, 17
    SLLI x26, x0, 25
    SRAI x15, x25, 17
    AUIPC x2, 3
    LUI x19, 1048566
    LUI x3, 1048557
    SUB x11, x14, x26
    XORI x17, x4, 10
    AUIPC x30, 0
    ADDI x30, x30, 8
    JALR x25, 8(x30)
    SRA x21, x18, x24
    SLT x8, x22, x9
    SLTU x7, x11, x14
    OR x4, x23, x10
    ADDI x9, x4, 105
    ANDI x3, x4, -117
    ANDI x2, x30, 149
    ADD x18, x2, x10
    SRAI x24, x4, 3
    LUI x22, 2
    SLTIU x8, x2, 145
    SRAI x24, x19, 26
    XORI x12, x18, -33
    SLTI x5, x18, -60
    SLL x11, x11, x29
    SRL x17, x23, x31
    ADDI x28, x6, 30
    ORI x3, x13, -25
    ADDI x28, x3, -172
    ADD x10, x28, x19
    AND x14, x9, x26
    SB x9, 1019(x21)
    AND x3, x28, x15
    SUB x30, x6, x18
    LUI x6, 1048567
    ADDI x1, x28, -83
    AND x9, x29, x25
    SLTIU x3, x23, 36
    SLTI x11, x2, -180
    ORI x30, x14, -114
    AUIPC x2, 14
    ADD x5, x2, x9
    SLL x7, x20, x2
    ADD x29, x30, x22
    SRLI x22, x15, 0
    SRLI x22, x18, 11
    ADDI x0, x0, 38
    SLTIU x9, x28, -142
    LUI x15, 1048569
    ORI x0, x24, 156
    ADDI x22, x28, 130
    SLTIU x18, x29, 184
    AUIPC x17, 1048574
    LUI x29, 1048550
    OR x13, x22, x28
    SLTIU x26, x5, -28
    SRA x21, x11, x3
    BGE x4, x8, 32
    SRL x3, x26, x17
    SLTIU x17, x25, 51
    ADD x15, x29, x22
    SLTU x3, x2, x27
    SUB x4, x30, x15
    SLTIU x11, x16, -166
    SLLI x19, x28, 14
    SLTU x2, x8, x30
    SW x4, 1956(x21)
    SRA x2, x29, x27
    ADDI x31, x11, 49
    XOR x15, x17, x1
    SRLI x6, x30, 23
    OR x15, x31, x15
    ANDI x0, x29, -199
    AND x8, x6, x14
    ORI x22, x5, -193
    SLTU x20, x5, x14
    ADD x21, x20, x30
    SRL x14, x11, x25
    SRL x3, x30, x9
    SLTI x15, x24, 79
    SLT x5, x9, x17
    ADDI x9, x2, 170
    AND x27, x19, x25
    SLT x9, x0, x21
    AND x9, x13, x21
    SRA x18, x30, x8
    SLTI x7, x21, 55
    SLTU x25, x23, x24
    SLL x19, x19, x10
    AUIPC x17, 1048569
    SUB x26, x27, x22
    ADDI x19, x19, -82
    SLTI x15, x17, -17
    SUB x18, x25, x4
    XOR x10, x15, x12
    LUI x31, 3
    SLTIU x10, x19, -183
    SUB x8, x31, x29
    XOR x19, x27, x25
    ORI x29, x31, -160
    AND x1, x18, x31
    JAL x25, 36
    AND x8, x5, x17
    ADD x15, x18, x28
    ANDI x0, x8, -28
    AUIPC x3, 15
    AUIPC x13, 14
    SUB x6, x4, x20
    SLLI x18, x21, 12
    SUB x0, x26, x8
    AND x28, x28, x14
    SUB x29, x2, x11
    OR x16, x14, x1
    SRL x0, x4, x5
    SRAI x19, x10, 13
    OR x22, x7, x28
    AND x6, x31, x20
    ANDI x21, x28, 89
    SLLI x9, x5, 21
    LUI x3, 25
    SLL x5, x27, x22
    SRL x4, x20, x15
    ANDI x15, x4, 12
    SRA x0, x31, x0
    SLL x30, x27, x31
    SRA x6, x7, x14
    ORI x15, x16, -57
    SB x28, 949(x21)
    SLTU x28, x16, x25
    SLTIU x4, x2, -68
    SRL x24, x3, x24
    SRL x31, x15, x0
    XORI x30, x11, 28
    ADDI x16, x25, 125
    SLT x22, x29, x6
    AUIPC x7, 1048555
    SRLI x29, x0, 5
    SRLI x16, x1, 14
    SLLI x26, x12, 27
    ADD x30, x16, x24
    SUB x4, x7, x30
    AUIPC x24, 0
    ADDI x24, x24, 8
    JALR x15, 4(x24)
    SRL x11, x10, x29
    XORI x10, x16, 158
    SLTI x23, x23, 15
    SLTU x23, x0, x24
    SLLI x31, x29, 3
    SW x23, 2020(x21)
    ORI x12, x30, -167
    ANDI x19, x9, -52
    ANDI x28, x31, -141
    SLTIU x8, x25, -79
    XORI x7, x12, 177
    ADDI x1, x25, 117
    ORI x9, x7, -46
    SRLI x29, x26, 31
    SRLI x1, x3, 5
    ADDI x2, x26, -111
    SLL x4, x22, x3
    ANDI x23, x13, 72
    ANDI x23, x20, -70
    SRL x1, x29, x13
    SRA x20, x15, x11
    XORI x26, x11, 113
    SLLI x26, x22, 20
    OR x8, x8, x13
    XOR x17, x8, x0
    ADDI x4, x15, 188
    AUIPC x22, 1048556
    SLLI x31, x11, 6
    AUIPC x18, 3
    SLTIU x20, x15, 118
    OR x29, x13, x18
    SLTI x24, x14, -96
    SRL x0, x25, x21
    SLT x18, x11, x15
    AND x3, x7, x11
    SLLI x13, x6, 5
    AUIPC x14, 1048572
    SLTI x3, x25, 28
    OR x8, x26, x3
    SLLI x21, x6, 6
    ORI x0, x14, 32
    JAL x14, 40
    LUI x15, 15
    ORI x5, x14, -84
    SRA x25, x29, x0
    XORI x12, x15, 21
    XOR x1, x15, x19
    SLTI x1, x7, 78
    SRLI x8, x14, 24
    ADD x18, x28, x15
    AND x18, x14, x24
    SRL x9, x21, x0
    XORI x1, x12, 186
    SH x1, 1308(x21)
    SRL x23, x24, x25
    ORI x23, x21, -23
    ADD x12, x0, x24
    XOR x0, x21, x8
    SRLI x14, x17, 13
    ANDI x31, x7, 86
    LUI x19, 1
    SRAI x15, x24, 22
    AND x1, x25, x15
    SLT x29, x24, x17
    ANDI x2, x21, 91
    SRLI x14, x4, 24
    SRLI x26, x29, 22
    SLTI x7, x18, -138
    XORI x21, x3, 107
    SRL x26, x15, x22
    AND x20, x23, x28
    SRA x13, x16, x13
    OR x27, x21, x5
    SLLI x6, x22, 6
    LUI x6, 1048570
    JAL x30, 28
    ORI x14, x14, 77
    ADD x14, x6, x18
    ADD x21, x25, x30
    SRL x14, x11, x4
    OR x8, x3, x3
    SRAI x10, x10, 16
    SLTU x24, x27, x22
    OR x10, x20, x18
    ORI x12, x21, -91
    SLTI x18, x6, 10
    SLTIU x25, x21, -148
    SLLI x9, x2, 14
    SLTI x8, x4, -80
    SLTU x1, x27, x29
    SLTIU x13, x24, 45
    ORI x22, x16, -179
    XORI x9, x27, 70
    ADD x28, x21, x0
    ORI x0, x12, 48
    SLL x1, x5, x28
    SUB x3, x3, x20
    SLTIU x9, x15, -145
    ADDI x0, x7, -17
    SRA x5, x9, x13
    ANDI x4, x31, 55
    SW x21, 1476(x21)
    XORI x31, x23, -145
    ORI x14, x23, 144
    AUIPC x4, 1048569
    SRL x26, x11, x25
    SRA x19, x11, x18
    SLT x1, x9, x16
    OR x23, x23, x31
    SRA x4, x31, x2
    SLLI x26, x10, 4
    ADD x3, x1, x31
    XORI x18, x17, -23
    LUI x14, 1
    SLLI x28, x24, 4
    SLTIU x31, x26, 15
    SRA x31, x29, x30
    AND x25, x10, x3
    SRLI x2, x2, 5
    ORI x2, x10, 143
    OR x30, x17, x14
    SRA x12, x3, x11
    ORI x19, x22, 164
    SLL x12, x30, x6
    OR x24, x18, x21
    SLTU x2, x7, x27
    LUI x6, 1048566
    ORI x11, x15, -84
    XORI x31, x11, -16
    AND x22, x6, x17
    SUB x5, x12, x9
    BLTU x19, x29, 8
    ANDI x16, x20, -120
    SRA x16, x4, x7
    XORI x19, x18, -136
    SLTI x7, x23, 63
    SLTIU x9, x19, 43
    SLLI x0, x1, 31
    ADDI x28, x3, -20
    OR x18, x9, x15
    AUIPC x5, 1048563
    SRAI x14, x29, 26
    SUB x23, x8, x0
    XOR x6, x16, x23
    SLTI x9, x25, 118
    SH x6, 1764(x21)
    SLT x5, x18, x3
    SRAI x10, x12, 3
    OR x26, x28, x29
    SRAI x5, x5, 0
    SLT x11, x24, x19
    AND x19, x12, x16
    SRL x10, x7, x5
    XORI x12, x11, 23
    SRL x3, x5, x10
    AUIPC x0, 2
    SRAI x1, x20, 3
    SUB x26, x22, x25
    SRLI x19, x4, 3
    XOR x27, x26, x29
    SUB x1, x21, x5
    SRA x12, x12, x9
    SRL x23, x9, x31
    SLL x30, x2, x30
    BNE x26, x25, 16
    SLTI x14, x24, 192
    SLTU x31, x25, x17
    SLL x30, x20, x26
    ADDI x15, x30, 176
    SLTU x23, x25, x15
    SW x21, 1948(x21)
    SLLI x25, x13, 10
    SLLI x20, x28, 18
    SLTU x25, x1, x9
    SRA x31, x1, x27
    SRA x9, x29, x12
    SLTU x4, x23, x18
    SLTIU x18, x26, 153
    OR x5, x31, x30
    XOR x10, x2, x17
    SRAI x19, x22, 22
    XOR x26, x15, x17
    LUI x27, 1048570
    AUIPC x5, 1048575
    AND x17, x11, x26
    XORI x30, x25, -128
    SLTIU x11, x19, -120
    SUB x10, x14, x4
    XORI x15, x31, -157
    OR x19, x20, x27
    SRAI x9, x27, 23
    SLTI x27, x14, -192
    XORI x20, x19, -177
    JAL x28, 20
    SRA x21, x25, x26
    SLLI x27, x5, 22
    AUIPC x21, 1048570
    SUB x8, x4, x9
    SLLI x18, x11, 5
    AUIPC x20, 12
    SUB x21, x2, x29
    ANDI x11, x5, -144
    ANDI x0, x10, 77
    ADD x29, x19, x29
    SLL x6, x8, x15
    SRL x9, x20, x19
    LW x28, 0(x21)
    OR x4, x24, x1
    SRL x30, x18, x17
    ORI x0, x29, 8
    SRAI x4, x31, 4
    LUI x29, 9
    OR x25, x27, x12
    LUI x3, 41
    ADD x25, x5, x13
    XOR x29, x29, x4
    SLLI x5, x26, 21
    SLT x2, x5, x29
    SRAI x31, x31, 26
    ORI x4, x4, -49
    SRL x2, x16, x20
    AND x7, x17, x9
    AND x30, x7, x2
    AND x9, x9, x9
    SLTU x18, x15, x22
    XORI x0, x12, -160
    SLTI x11, x15, -12
    SLT x13, x9, x24
    ANDI x15, x0, 148
    ADDI x7, x25, 152
    ADD x7, x28, x31
    OR x31, x11, x28
    SLTIU x28, x17, 134
    XOR x3, x10, x17
    SRL x16, x22, x23
    XORI x21, x0, -190
    SLTU x20, x17, x7
    JAL x29, 4
    ADD x2, x23, x0
    XORI x0, x21, -92
    ORI x16, x15, 73
    SLL x7, x12, x31
    SRL x20, x31, x5
    AUIPC x12, 1
    ORI x24, x0, 93
    AND x8, x2, x29
    SH x11, 314(x21)
    SLTI x23, x31, 59
    SRAI x1, x21, 7
    SLTI x4, x14, -133
    XORI x25, x16, -90
    SLT x16, x21, x8
    SLTI x26, x31, 176
    SRL x16, x10, x12
    SLTI x30, x24, -53
    SLL x18, x3, x30
    SLTI x11, x6, 191
    SRA x7, x3, x23
    XOR x7, x1, x24
    SRAI x31, x0, 16
    LUI x22, 1048575
    SRLI x15, x27, 1
    SUB x28, x30, x22
    SRAI x12, x3, 27
    AND x22, x19, x9
    SRLI x1, x5, 7
    SUB x31, x21, x28
    SLTI x16, x9, -10
    ADD x26, x29, x24
    SUB x25, x15, x2
    ORI x11, x11, -95
    ADD x13, x3, x21
    AND x22, x15, x11
    SUB x29, x25, x14
    SRAI x27, x20, 20
    ADD x13, x20, x3
    JAL x11, 28
    XORI x8, x20, 54
    XOR x15, x12, x13
    ORI x18, x11, 155
    SLTI x24, x12, -198
    OR x13, x11, x10
    XOR x29, x3, x26
    OR x7, x3, x5
    XORI x6, x17, -170
    SRL x9, x5, x29
    SRLI x29, x23, 0
    AUIPC x21, 4
    ANDI x26, x1, 9
    SLTI x5, x22, -109
    SRA x5, x12, x4
    ADDI x26, x24, 9
    ANDI x23, x10, 149
    XOR x11, x26, x12
    SLLI x29, x30, 30
    XORI x30, x29, -16
    LUI x8, 5
    XORI x27, x12, 17
    SRL x6, x16, x26
    SLLI x28, x14, 29
    SUB x12, x0, x31
    SUB x31, x13, x19
    LB x0, 7(x21)
    SRA x17, x9, x1
    SLLI x2, x9, 27
    AUIPC x16, 10
    ANDI x28, x30, 25
    ANDI x28, x26, -74
    SLL x7, x9, x19
    OR x16, x3, x12
    SRAI x27, x10, 27
    SLTU x5, x0, x15
    XORI x2, x15, 130
    ORI x11, x21, 18
    SLTU x18, x21, x19
    AUIPC x11, 1048564
    ADDI x25, x10, 125
    SRL x28, x29, x11
    ANDI x12, x20, 2
    OR x7, x28, x31
    ADD x26, x13, x15
    LUI x30, 7
    AND x15, x4, x0
    ANDI x17, x1, -191
    SRA x4, x16, x15
    ANDI x9, x14, -151
    ANDI x26, x23, 127
    SLTI x24, x16, 18
    SLT x30, x26, x25
    SRL x4, x0, x21
    SLLI x19, x4, 24
    SLLI x7, x12, 22
    AUIPC x7, 1048574
    ADD x17, x13, x13
    SRL x12, x17, x30
    ANDI x5, x25, 109
    LUI x17, 1048570
    AUIPC x1, 0
    ADDI x1, x1, 8
    JALR x15, 32(x1)
    SUB x21, x25, x16
    LUI x10, 6
    AUIPC x12, 24
    ADD x23, x17, x23
    SLTU x14, x27, x28
    ADDI x14, x25, 65
    XORI x5, x8, -149
    SLTIU x30, x26, 46
    SLTIU x16, x26, -27
    SLTI x20, x17, 44
    SLTI x6, x28, -27
    SLL x22, x9, x28
    SLT x11, x12, x23
    XOR x16, x28, x15
    SLTI x15, x10, 105
    AND x8, x4, x0
    SRL x4, x1, x2
    SUB x22, x31, x12
    SUB x9, x6, x26
    SUB x21, x31, x25
    ADDI x17, x26, -36
    ADDI x18, x14, -22
    SRLI x28, x31, 2
    ORI x8, x9, -5
    SLT x12, x31, x15
    XORI x13, x8, -84
    SH x27, 1110(x21)
    SRA x30, x12, x22
    AND x14, x13, x21
    ADDI x1, x21, 21
    ADD x15, x7, x15
    OR x5, x22, x1
    LUI x28, 1048555
    XORI x22, x10, 77
    SRL x11, x14, x10
    SLTIU x15, x8, -77
    SRL x11, x23, x25
    SLTIU x4, x23, 22
    SLTI x6, x26, 198
    BGEU x19, x0, 28
    SRA x30, x17, x9
    SUB x5, x21, x22
    XORI x31, x4, 16
    SLTU x15, x28, x17
    SLL x0, x8, x8
    XOR x14, x0, x20
    XOR x7, x21, x27
    AND x13, x3, x21
    SLLI x21, x21, 26
    SRAI x15, x3, 3
    SRLI x28, x1, 18
    SLTI x12, x12, 153
    XORI x5, x12, -63
    LBU x23, 194(x21)
    SUB x5, x19, x0
    SLTI x16, x2, -176
    SUB x5, x10, x20
    XOR x8, x23, x9
    XORI x6, x19, 19
    AND x0, x30, x25
    XOR x28, x31, x0
    SRA x25, x18, x12
    AUIPC x30, 1048565
    SRAI x25, x16, 29
    SUB x26, x21, x15
    SLTU x24, x27, x10
    ANDI x16, x17, 12
    SUB x20, x6, x16
    SRLI x8, x15, 23
    SLTIU x4, x12, 43
    SRLI x3, x26, 26
    SLLI x29, x16, 22
    XOR x29, x14, x20
    XORI x23, x7, -45
    AUIPC x9, 1048575
    AUIPC x13, 1048570
    XORI x27, x11, -161
    SRA x31, x12, x4
    SUB x9, x18, x4
    SRL x5, x2, x16
    SRLI x12, x0, 16
    ORI x15, x5, 76
    OR x28, x27, x27
    SRA x24, x11, x23
    SLT x12, x17, x30
    OR x23, x11, x17
    OR x28, x22, x18
    SUB x11, x22, x5
    JAL x5, 28
    ANDI x9, x27, 152
    SRLI x3, x8, 0
    AND x2, x3, x5
    AUIPC x18, 1048563
    ORI x29, x23, -186
    SRLI x15, x31, 27
    SUB x29, x8, x29
    XOR x27, x2, x31
    SRA x17, x25, x24
    ADD x21, x24, x29
    SRAI x27, x20, 10
    ADD x20, x3, x0
    SRLI x23, x16, 25
    SLLI x20, x7, 9
    SLL x25, x14, x28
    SW x20, 972(x21)
    ADD x25, x4, x18
    XORI x10, x22, -89
    ADD x10, x29, x10
    SLT x31, x1, x12
    SRA x29, x8, x23
    SLTIU x13, x12, 186
    AUIPC x17, 7
    SLTIU x8, x6, 29
    SLTI x2, x26, 87
    XORI x20, x2, 169
    LUI x22, 1048566
    SLTIU x1, x19, 109
    ORI x28, x14, -51
    SRAI x24, x14, 8
    SRL x9, x26, x28
    ORI x20, x20, -178
    SLTIU x15, x28, 120
    SLLI x16, x12, 15
    ANDI x23, x4, -20
    SLTU x20, x2, x26
    XOR x24, x18, x20
    AND x31, x8, x8
    ADD x29, x24, x7
    SLL x28, x19, x31
    AUIPC x18, 0
    ADDI x18, x18, 8
    JALR x30, 20(x18)
    ANDI x9, x16, -60
    XOR x11, x17, x31
    SRAI x24, x14, 3
    SRAI x28, x22, 15
    ADDI x22, x2, -57
    OR x28, x22, x10
    AND x24, x26, x23
    ADD x3, x23, x24
    SLL x26, x27, x25
    SLL x0, x8, x0
    AUIPC x10, 1048570
    SRAI x11, x19, 10
    SW x2, 1236(x21)
    SUB x13, x4, x27
    XOR x4, x7, x12
    SRL x19, x29, x13
    ADDI x4, x26, -49
    ORI x6, x24, -83
    SRL x11, x4, x29
    SLLI x3, x23, 27
    XOR x31, x21, x0
    SLTU x22, x25, x0
    AUIPC x14, 0
    ADDI x14, x14, 8
    JALR x20, 40(x14)
    SRLI x12, x29, 20
    XORI x21, x12, -142
    SRAI x1, x31, 12
    SLLI x0, x1, 0
    SLT x7, x15, x17
    XORI x22, x21, -3
    SLTIU x25, x13, -42
    AUIPC x7, 1048571
    AUIPC x7, 4
    LUI x29, 13
    SUB x0, x29, x20
    XORI x19, x19, -58
    SRA x15, x5, x13
    ADDI x26, x12, -182
    XOR x5, x6, x27
    XORI x7, x19, 76
    AND x24, x0, x5
    LUI x18, 1048570
    AUIPC x2, 5
    SLTIU x17, x30, -149
    AND x1, x8, x30
    ADD x24, x3, x2
    SRL x31, x2, x7
    LH x31, 46(x21)
    SUB x29, x5, x12
    ADDI x14, x5, 161
    SLTIU x4, x8, 64
    ADD x8, x31, x1
    ADD x25, x0, x12
    XOR x30, x16, x24
    ADD x13, x29, x23
    SRLI x24, x18, 0
    OR x14, x21, x11
    ADD x7, x15, x19
    ADD x9, x13, x17
    AND x20, x25, x23
    LUI x24, 1048560
    SRL x5, x20, x3
    AUIPC x8, 0
    ADDI x8, x8, 8
    JALR x3, 16(x8)
    SRA x28, x1, x21
    AUIPC x17, 1048575
    XORI x20, x27, -35
    ADD x13, x19, x18
    ANDI x4, x13, 19
    SLTI x3, x19, 127
    SH x6, 24(x21)
    SLTI x14, x21, -108
    OR x0, x30, x19
    SLTU x17, x25, x1
    SLTIU x30, x30, 17
    XOR x16, x16, x2
    ADD x7, x0, x23
    SLL x9, x19, x26
    SRAI x28, x8, 5
    SLT x4, x27, x18
    AND x29, x31, x13
    LUI x7, 1048575
    AND x23, x26, x19
    LUI x26, 1048570
    AND x12, x6, x17
    SUB x17, x22, x5
    ANDI x7, x6, -43
    SRAI x7, x27, 10
    SUB x22, x23, x23
    AUIPC x6, 1048565
    BGE x17, x7, 8
    OR x3, x24, x5
    AND x13, x0, x24
    ANDI x6, x9, 151
    SRLI x20, x7, 26
    ADDI x13, x31, -67
    SLL x12, x5, x28
    XORI x21, x2, 34
    SRA x22, x9, x0
    SRLI x8, x6, 21
    SRLI x25, x1, 19
    AND x21, x12, x18
    SLLI x5, x4, 0
    OR x23, x31, x10
    SLTIU x18, x12, 32
    SLT x20, x29, x21
    SRLI x1, x9, 27
    LHU x9, 148(x21)
    SRL x0, x13, x16
    ANDI x6, x17, -146
    XORI x24, x22, 30
    SRLI x0, x23, 9
    SRLI x26, x20, 21
    LUI x30, 1048572
    SLT x28, x4, x30
    ORI x15, x29, 181
    SLTIU x2, x2, 85
    ADDI x23, x22, -13
    XOR x31, x10, x18
    LUI x2, 1048575
    XORI x23, x17, 60
    SLTIU x11, x7, -98
    AND x16, x5, x11
    ADDI x7, x19, 80
    AUIPC x21, 1048572
    JAL x22, 28
    SLTIU x13, x11, -113
    OR x3, x16, x4
    SLT x15, x21, x25
    LUI x7, 2
    SRLI x30, x3, 11
    SRAI x16, x6, 23
    SLLI x4, x15, 1
    ORI x4, x26, 17
    SB x20, 1802(x21)
    XORI x0, x27, -44
    SLTI x9, x19, 190
    ORI x28, x20, -136
    ANDI x5, x10, -28
    ADDI x26, x14, -186
    SRA x14, x27, x29
    SRL x10, x18, x13
    BGE x23, x3, 4
    SLT x4, x10, x26
    ANDI x9, x31, 40
    AUIPC x30, 20
    XOR x25, x23, x27
    LUI x6, 1048565
    SRLI x4, x8, 3
    LHU x23, 198(x21)
    XORI x2, x0, -82
    SLLI x7, x29, 31
    ADDI x15, x26, 21
    SLTI x14, x25, 131
    OR x11, x27, x9
    SLLI x23, x6, 5
    SRLI x13, x14, 11
    XOR x28, x5, x22
    BGE x7, x8, 20
    SLLI x13, x2, 19
    ORI x28, x14, -44
    SLLI x3, x25, 20
    SUB x10, x23, x8
    SLT x3, x22, x4
    SLTI x27, x21, 130
    LUI x18, 1048574
    ADD x24, x16, x26
    SRL x29, x10, x22
    SLTIU x3, x7, -196
    SLTU x22, x7, x3
    ANDI x15, x31, -108
    SLTI x14, x17, -153
    ANDI x15, x14, 4
    ADD x20, x29, x4
    ADDI x28, x26, 25
    AND x6, x30, x6
    SRLI x14, x15, 6
    ORI x21, x22, -12
    ANDI x9, x6, -42
    ADDI x13, x28, 197
    ADD x30, x26, x16
    ORI x23, x17, 46
    SLTIU x22, x5, 171
    SB x19, 1322(x21)
    SRLI x0, x10, 6
    SUB x23, x26, x0
    XORI x19, x26, -33
    SRL x29, x14, x29
    SLTI x8, x17, -162
    SLTU x29, x10, x9
    AUIPC x31, 1048566
    ADD x28, x0, x15
    OR x0, x1, x28
    ADDI x15, x1, -113
    SRAI x2, x25, 26
    ANDI x1, x14, -131
    ORI x13, x12, -44
    SLTU x4, x7, x14
    XORI x30, x15, 143
    SLT x5, x11, x27
    SUB x31, x27, x31
    ADDI x2, x9, 44
    AND x23, x0, x4
    SRLI x2, x27, 13
    LUI x12, 6
    SLT x4, x13, x12
    SLT x7, x16, x26
    SLLI x10, x16, 5
    SRAI x6, x18, 6
    XORI x15, x18, 95
    SUB x22, x20, x6
    XORI x22, x1, -186
    AUIPC x27, 0
    ADDI x27, x27, 8
    JALR x8, 32(x27)
    SRL x3, x10, x24
    XOR x2, x21, x7
    ADD x5, x14, x19
    AUIPC x29, 1048571
    SLTI x12, x22, -104
    ADD x14, x2, x17
    SLLI x16, x2, 9
    SUB x7, x9, x14
    AND x15, x25, x31
    SRL x17, x20, x23
    SLT x1, x5, x1
    AUIPC x5, 1048575
    SLT x19, x6, x26
    SLTI x21, x6, 46
    ADDI x22, x25, 101
    ADD x18, x9, x0
    AND x21, x24, x22
    ADD x19, x27, x9
    ANDI x18, x20, -134
    XOR x31, x6, x11
    LUI x4, 1048570
    SRLI x0, x14, 5
    SLTIU x15, x4, -11
    SLT x31, x11, x9
    LBU x31, 357(x21)
    SLTIU x29, x28, 16
    SLLI x14, x15, 1
    SRLI x27, x28, 20
    ADD x19, x24, x31
    ANDI x28, x0, 97
    SLTU x14, x15, x26
    SLLI x6, x11, 2
    SRA x29, x12, x30
    LUI x10, 0
    SLL x19, x3, x23
    ADDI x5, x22, -112
    ORI x21, x1, 178
    SLTI x27, x3, -36
    SRLI x11, x17, 12
    JAL x2, 28
    ORI x31, x0, 174
    ADDI x19, x18, -110
    ORI x29, x14, -115
    SRLI x27, x22, 22
    SRAI x0, x3, 11
    XOR x28, x8, x31
    SRA x7, x15, x28
    ADD x7, x24, x24
    LH x16, 134(x21)
    ADDI x3, x8, 136
    XORI x2, x22, 143
    OR x2, x5, x0
    SRA x11, x22, x23
    AND x6, x10, x29
    LUI x7, 23
    SLLI x24, x28, 30
    SLT x10, x19, x7
    SUB x24, x8, x4
    XORI x15, x22, 151
    SLTIU x22, x20, -73
    SLLI x1, x12, 5
    XORI x1, x22, -30
    SRAI x8, x21, 19
    AND x5, x0, x30
    SLTU x24, x5, x6
    SLTIU x28, x21, -179
    ANDI x10, x2, 4
    SRLI x25, x17, 27
    XOR x19, x12, x4
    SLTIU x14, x12, 38
    SLTI x14, x4, 141
    XOR x22, x19, x11
    BLT x12, x30, 24
    SLLI x31, x4, 5
    XOR x25, x0, x5
    SUB x24, x7, x21
    ADD x9, x19, x8
    SRA x2, x16, x17
    SUB x2, x24, x21
    SLT x9, x5, x18
    SLTI x12, x25, 84
    OR x28, x16, x9
    SUB x10, x11, x8
    AND x14, x11, x5
    ORI x19, x17, -137
    ADD x18, x0, x31
    SLLI x26, x21, 8
    SLL x29, x17, x29
    XOR x6, x10, x31
    SRA x12, x31, x15
    SLTU x21, x13, x31
    LUI x3, 0
    SRL x8, x28, x6
    LH x28, 48(x21)
    SLTIU x13, x10, 176
    SLL x10, x21, x20
    SLT x13, x16, x21
    ANDI x0, x6, 186
    SLT x4, x11, x27
    SRA x2, x24, x13
    XORI x9, x21, -178
    SLTU x10, x18, x1
    AUIPC x17, 1048571
    SLTI x15, x29, -6
    LUI x27, 1048574
    SRL x20, x15, x1
    SRLI x17, x11, 25
    LUI x14, 8
    SRA x23, x12, x20
    SRL x23, x30, x18
    SLTI x31, x27, 195
    SLTIU x18, x23, 172
    XOR x15, x0, x11
    AUIPC x12, 0
    ADDI x12, x12, 8
    JALR x30, 32(x12)
    SRLI x12, x3, 2
    SRLI x28, x7, 22
    SLTI x24, x30, -133
    SLTU x30, x25, x22
    SRA x13, x2, x12
    ORI x30, x29, -56
    OR x17, x23, x14
    SRLI x14, x0, 7
    XOR x7, x9, x26
    SRL x26, x0, x15
    SRL x10, x25, x14
    SRL x24, x5, x6
    SLTI x30, x25, 77
    XORI x0, x8, 138
    AND x19, x31, x3
    SH x23, 546(x21)
    SRLI x16, x1, 1
    SRLI x25, x2, 15
    SLTI x24, x1, 141
    AUIPC x5, 1
    SRA x3, x27, x14
    SRAI x24, x25, 8
    LUI x20, 1048559
    SRA x25, x30, x28
    XORI x0, x14, 39
    LUI x6, 4
    SRLI x4, x21, 18
    SRA x15, x26, x31
    LUI x6, 1
    XORI x24, x11, 66
    XOR x6, x2, x4
    SLTI x10, x14, -44
    SLTIU x28, x16, 42
    SLLI x7, x21, 4
    SRAI x4, x14, 8
    LUI x5, 29
    XOR x21, x21, x15
    SLL x2, x15, x29
    SRA x22, x4, x1
    JAL x24, 36
    SRA x7, x0, x21
    LUI x11, 12
    XOR x26, x10, x2
    SLT x28, x24, x31
    SLLI x10, x28, 8
    OR x1, x6, x8
    ADDI x12, x22, 116
    SUB x31, x6, x7
    LUI x5, 1048570
    SRLI x17, x10, 0
    XORI x4, x20, -36
    SLTI x15, x1, -190
    SUB x21, x9, x4
    ADDI x20, x3, -127
    ADDI x20, x0, 133
    SRAI x13, x2, 2
    XOR x15, x25, x6
    SUB x9, x24, x24
    SRA x5, x28, x28
    OR x1, x12, x1
    AUIPC x22, 1048568
    SRA x23, x12, x4
    OR x24, x7, x21
    SRL x26, x1, x4
    SLL x22, x1, x12
    ANDI x7, x22, -83
    LB x10, 203(x21)
    ADDI x13, x18, -94
    LUI x26, 9
    AUIPC x7, 1
    OR x0, x31, x3
    XORI x12, x22, 63
    SLTIU x4, x28, -59
    SRLI x5, x21, 7
    ORI x22, x18, 71
    SLL x11, x3, x29
    SRL x15, x23, x18
    SRAI x30, x3, 24
    AUIPC x17, 0
    ADDI x17, x17, 8
    JALR x5, 36(x17)
    SUB x6, x2, x12
    SLLI x29, x13, 13
    XOR x25, x1, x19
    AND x2, x6, x10
    XOR x19, x18, x2
    SLT x11, x10, x14
    SLTIU x8, x7, -63
    ANDI x14, x22, 88
    ADDI x18, x9, -10
    SRAI x30, x26, 10
    SRL x5, x0, x7
    SLTU x2, x29, x21
    ORI x3, x20, 21
    XORI x23, x16, -34
    LUI x0, 1048571
    LBU x1, 105(x21)
    ADD x28, x28, x18
    XOR x11, x18, x17
    XOR x13, x15, x5
    SLTU x18, x24, x28
    AUIPC x26, 10
    ANDI x28, x7, 98
    SLT x7, x23, x19
    AND x9, x7, x6
    SRLI x22, x26, 22
    XORI x9, x29, 171
    SLTIU x22, x21, -80
    ADDI x9, x20, 34
    ORI x10, x20, -19
    SRA x26, x24, x30
    SLTIU x2, x13, 23
    SRAI x21, x22, 11
    SLT x16, x3, x1
    SRLI x2, x22, 25
    SLT x25, x12, x12
    ANDI x18, x21, -106
    XOR x12, x22, x13
    SLT x21, x18, x3
    SRL x27, x17, x13
    ADD x28, x21, x29
    LUI x11, 4
    OR x6, x29, x0
    SLTI x31, x2, -165
    SLLI x18, x16, 0
    LUI x4, 22
    ADD x26, x9, x6
    LUI x1, 1048573
    XOR x15, x0, x25
    BGEU x24, x27, 16
    AUIPC x14, 6
    SLTIU x4, x28, 15
    SLTIU x18, x12, 88
    ADDI x3, x3, -8
    SRLI x18, x6, 11
    SRLI x6, x4, 19
    SRA x10, x0, x4
    ADD x26, x3, x17
    ANDI x7, x6, -1
    ANDI x8, x15, -170
    ANDI x16, x9, -37
    XOR x9, x14, x27
    AND x25, x23, x31
    ORI x22, x21, 20
    SRAI x26, x10, 19
    LW x17, 212(x21)
    ADDI x29, x18, 113
    SLLI x7, x31, 10
    ADDI x6, x31, 12
    SUB x15, x16, x26
    OR x16, x28, x28
    SLTU x31, x19, x14
    ANDI x0, x2, 158
    SLTI x27, x4, 130
    OR x6, x28, x6
    LUI x22, 3
    SRLI x14, x17, 11
    SRAI x4, x4, 6
    ORI x8, x29, -170
    OR x12, x3, x1
    SRLI x9, x24, 28
    ANDI x9, x1, -60
    ANDI x18, x5, -170
    SUB x15, x28, x19
    LUI x23, 4
    SLTIU x27, x15, -139
    SLL x25, x3, x17
    AUIPC x31, 0
    ADDI x31, x31, 8
    JALR x21, 24(x31)
    ORI x31, x21, 174
    SUB x1, x24, x21
    ORI x0, x3, -143
    SRAI x1, x20, 17
    SRLI x2, x12, 20
    ADD x15, x12, x19
    LUI x11, 2
    AND x18, x6, x20
    SRA x24, x19, x17
    SLTI x7, x7, 16
    SRLI x22, x15, 26
    ORI x24, x18, 67
    SRAI x0, x27, 1
    SRA x25, x11, x16
    ADDI x1, x27, 79
    SRL x8, x11, x13
    SLL x17, x10, x5
    XORI x11, x12, -34
    LUI x7, 1048561
    LUI x29, 524304
    ADDI x29, x29, 256
    LBU x5, 1562(x29)
    LUI x4, 21
    ADDI x21, x21, 79
    ADD x28, x31, x28
    SLTU x31, x7, x20
    SRA x22, x15, x14
    ORI x7, x20, -47
    AUIPC x13, 12
    SLTI x15, x18, -55
    SRAI x7, x20, 18
    XORI x8, x29, 83
    OR x18, x0, x23
    AUIPC x19, 0
    ADDI x19, x19, 8
    JALR x17, 20(x19)
    AUIPC x28, 1048569
    SLLI x23, x1, 25
    SRAI x14, x6, 22
    SUB x23, x6, x10
    ORI x6, x14, 33
    XOR x13, x27, x29
    SLT x29, x23, x25
    XORI x23, x14, -30
    AND x10, x10, x30
    ADDI x0, x8, -192
    SLLI x25, x9, 24
    ORI x28, x2, -148
    SLTI x11, x14, 93
    SLTI x22, x4, -79
    SRA x26, x6, x23
    SB x15, 1030(x29)
    ORI x20, x22, -77
    SLTU x7, x29, x18
    SLTU x1, x4, x30
    AUIPC x9, 5
    SRLI x17, x2, 19
    OR x17, x22, x26
    SLLI x8, x29, 6
    ADD x16, x18, x23
    SLL x2, x8, x12
    XORI x30, x10, -60
    LUI x21, 1048567
    XOR x12, x17, x9
    LUI x21, 2
    OR x25, x13, x24
    OR x9, x2, x22
    SLL x31, x20, x29
    XOR x5, x18, x18
    ADDI x22, x14, 41
    ANDI x25, x6, 165
    SLTI x25, x4, 116
    SUB x2, x28, x5
    SLTU x0, x10, x12
    SLTI x16, x14, -59
    ORI x9, x22, -46
    ADDI x17, x22, -61
    SRL x22, x30, x25
    SLTU x15, x16, x4
    SRLI x9, x2, 7
    SLTU x1, x7, x12
    XOR x23, x25, x4
    SLTIU x7, x10, 65
    BGE x31, x17, 24
    SRLI x20, x26, 3
    SLLI x14, x22, 10
    SRL x17, x23, x26
    SLTIU x24, x23, -72
    SLTU x31, x22, x13
    OR x3, x13, x18
    LUI x30, 0
    SW x30, 260(x29)
    ADDI x25, x18, 182
    SLTIU x10, x6, 160
    LUI x13, 1048574
    AUIPC x4, 1048556
    AUIPC x3, 8
    JAL x15, 28
    XORI x5, x23, -85
    ANDI x9, x3, -17
    AUIPC x27, 10
    SRAI x22, x17, 22
    AUIPC x6, 15
    SLLI x24, x27, 17
    SRAI x28, x31, 16
    SRA x4, x25, x6
    SLL x4, x9, x23
    AUIPC x9, 1048573
    SLL x23, x18, x19
    SLLI x24, x23, 0
    SUB x19, x9, x17
    SLTI x3, x4, 12
    OR x8, x22, x31
    SLL x11, x29, x22
    ORI x13, x19, 82
    XORI x16, x13, -168
    SLL x25, x15, x22
    XORI x0, x28, 69
    SRAI x3, x14, 23
    ADDI x8, x10, -47
    SW x3, 1928(x29)
    SRL x17, x31, x28
    AUIPC x26, 1048558
    ORI x19, x29, -165
    ORI x22, x5, 23
    SRLI x25, x18, 26
    ADDI x4, x1, -163
    SLLI x24, x22, 20
    SLTIU x2, x28, -143
    ORI x7, x19, -62
    SLLI x15, x18, 5
    SLT x20, x23, x20
    SLL x29, x9, x0
    SRAI x24, x7, 14
    SLT x22, x16, x13
    SRA x24, x30, x25
    SUB x10, x31, x12
    SLTI x8, x13, -12
    SRAI x12, x13, 23
    SLLI x23, x14, 13
    SRLI x14, x18, 21
    JAL x19, 20
    SLL x2, x14, x12
    AUIPC x3, 14
    SLL x8, x23, x6
    XORI x27, x25, -125
    ADD x0, x9, x19
    LUI x17, 27
    SRL x1, x18, x28
    SW x22, 1524(x29)
    XOR x4, x1, x19
    SLTIU x31, x4, 15
    ADDI x18, x22, -26
    SRA x2, x16, x4
    ORI x14, x4, 176
    SLTI x29, x21, -44
    SLTU x29, x18, x23
    SLT x27, x26, x6
    SLL x30, x29, x8
    SLTIU x31, x6, -58
    SLLI x5, x2, 19
    SRLI x4, x18, 30
    SLTI x18, x4, -190
    SRA x2, x31, x4
    SLTIU x1, x10, -45
    SLLI x12, x4, 14
    AUIPC x28, 0
    ADDI x28, x28, 8
    JALR x20, 40(x28)
    SLTIU x1, x14, 44
    SUB x6, x24, x17
    SUB x7, x12, x22
    ADDI x16, x26, 200
    ANDI x29, x8, -183
    SRA x19, x8, x9
    SLTI x31, x31, 115
    AUIPC x0, 6
    XORI x16, x2, 173
    ADD x31, x31, x2
    XORI x7, x6, 185
    ANDI x29, x20, -26
    LUI x23, 13
    SRL x14, x18, x25
    SH x7, 424(x29)
    ADD x27, x23, x8
    SLL x0, x8, x15
    OR x24, x13, x28
    SLT x20, x16, x3
    SLT x6, x19, x19
    SLTIU x25, x9, 30
    SLT x12, x14, x13
    SRLI x7, x3, 0
    SLTU x7, x20, x27
    ANDI x26, x30, -7
    SLTIU x10, x15, -148
    SUB x27, x7, x15
    SLTIU x12, x28, 18
    ANDI x6, x4, -37
    LUI x23, 1048558
    SUB x24, x6, x16
    SLTI x3, x17, -113
    AUIPC x10, 1048573
    AUIPC x4, 1048556
    ORI x8, x3, 38
    OR x15, x13, x20
    AUIPC x21, 3
    SRLI x18, x3, 23
    SRA x30, x13, x19
    SLTI x28, x1, -122
    SRLI x14, x23, 19
    AUIPC x6, 9
    AND x29, x14, x24
    AUIPC x10, 0
    ADDI x10, x10, 8
    JALR x16, 16(x10)
    ADD x11, x22, x28
    OR x14, x26, x4
    SLLI x31, x20, 4
    LUI x1, 1048567
    SLTIU x26, x14, 61
    SRL x5, x16, x1
    SRAI x25, x25, 1
    LUI x11, 9
    LUI x28, 5
    SLT x10, x23, x28
    SLTI x0, x26, 51
    OR x17, x3, x24
    ORI x17, x23, 19
    ANDI x17, x0, 31
    LBU x13, 101(x29)
    SLT x25, x27, x16
    ADD x1, x25, x24
    XORI x14, x29, -76
    XORI x20, x29, 146
    SRL x14, x3, x5
    LUI x28, 1048569
    ADD x19, x10, x0
    ADD x11, x5, x15
    XOR x15, x31, x28
    ADDI x10, x7, 89
    ADD x3, x9, x5
    AUIPC x31, 10
    SLTI x14, x31, -154
    SLT x28, x12, x13
    ANDI x19, x3, -72
    SRAI x19, x25, 30
    ADD x16, x9, x7
    ANDI x3, x17, -90
    AND x1, x6, x18
    ORI x21, x18, -138
    LUI x15, 2
    SLT x27, x22, x18
    SRL x14, x5, x3
    AUIPC x26, 1048565
    SLLI x13, x11, 8
    SLLI x27, x25, 27
    LUI x2, 1
    SLTIU x22, x14, -125
    LUI x11, 15
    XORI x19, x24, 157
    SRAI x16, x1, 29
    SRL x5, x2, x19
    AND x2, x27, x16
    BNE x31, x5, 32
    SLLI x8, x3, 17
    XORI x24, x15, 112
    AUIPC x5, 5
    ORI x11, x29, 153
    SLTI x31, x2, 128
    SRL x23, x4, x30
    ADD x14, x5, x13
    SLL x7, x7, x23
    OR x25, x2, x28
    LUI x0, 1048561
    SLTU x14, x1, x23
    ADDI x3, x20, -126
    ADDI x13, x6, -150
    SLLI x17, x19, 23
    AND x24, x18, x30
    SRL x31, x18, x26
    SRL x20, x28, x30
    SLTIU x20, x24, -179
    SRLI x30, x14, 2
    SRA x4, x13, x10
    OR x18, x21, x5
    SRA x24, x24, x20
    SRL x23, x22, x25
    SRAI x17, x14, 6
    ANDI x4, x30, -189
    LUI x9, 1048575
    SB x14, 527(x29)
    LUI x21, 1048572
    XOR x6, x12, x30
    SLL x23, x25, x9
    SLTI x31, x14, 50
    OR x24, x17, x1
    ANDI x1, x16, -81
    SLTI x15, x5, -13
    ANDI x26, x19, 147
    AUIPC x12, 4
    SLL x29, x30, x6
    SLL x23, x13, x4
    ADD x17, x6, x29
    AUIPC x6, 19
    SUB x16, x16, x7
    SRLI x12, x22, 29
    AUIPC x24, 1048559
    OR x27, x30, x19
    ORI x14, x31, 145
    SLTI x25, x26, -131
    SLT x30, x3, x12
    SLLI x1, x30, 3
    ADD x25, x27, x23
    ORI x19, x20, 154
    XOR x22, x9, x15
    SLL x28, x24, x20
    SLLI x23, x12, 27
    AUIPC x30, 0
    ADDI x30, x30, 8
    JALR x20, 36(x30)
    SLTIU x17, x20, 90
    SRLI x1, x27, 25
    OR x22, x17, x9
    XORI x5, x8, 154
    XORI x10, x26, -6
    SLT x15, x21, x0
    LUI x0, 1048569
    AUIPC x24, 1048564
    XORI x28, x26, 71
    SUB x27, x0, x24
    SLL x2, x1, x22
    LBU x31, 159(x29)
    SRL x19, x20, x3
    XOR x17, x22, x3
    SRA x12, x13, x19
    ANDI x2, x2, -179
    SRAI x28, x20, 3
    AUIPC x8, 10
    ORI x14, x27, -110
    ADD x22, x20, x19
    ADD x4, x21, x18
    OR x19, x23, x23
    LUI x9, 11
    SRA x0, x17, x29
    SUB x28, x16, x27
    ADDI x13, x8, -92
    XORI x26, x30, -125
    SRA x12, x20, x25
    AUIPC x6, 1048564
    XORI x30, x31, 31
    OR x15, x20, x5
    ANDI x1, x31, 193
    SRAI x9, x8, 0
    SRA x16, x8, x23
    ORI x27, x11, 166
    SLTIU x25, x4, 1
    SRA x25, x17, x1
    OR x21, x21, x19
    SRL x17, x15, x0
    SLTI x18, x12, 63
    ADDI x31, x8, -124
    SLTI x16, x20, 10
    SLT x1, x7, x13
    SLT x22, x23, x18
    LUI x27, 1048571
    SLTIU x16, x18, -169
    LUI x20, 24
    SLTI x30, x8, 4
    LUI x21, 8
    SRLI x23, x17, 4
    JAL x17, 32
    LUI x31, 1048573
    ADD x18, x28, x25
    ANDI x17, x24, -37
    SLTIU x26, x22, -83
    SRAI x27, x5, 0
    AUIPC x28, 1048557
    OR x27, x22, x9
    ADDI x26, x6, -77
    ADDI x6, x30, 130
    XORI x7, x17, 193
    SW x28, 216(x29)
    SRLI x22, x18, 25
    ADDI x22, x10, -118
    OR x8, x15, x7
    AUIPC x28, 2
    LUI x4, 1048561
    SLT x28, x16, x10
    AUIPC x4, 0
    ADDI x4, x4, 8
    JALR x15, 32(x4)
    ADD x14, x13, x27
    SLTIU x17, x5, -39
    SLTIU x2, x17, 75
    SLTI x2, x29, -155
    SLTI x1, x31, -156
    SUB x18, x11, x11
    XORI x2, x9, 152
    ADD x16, x13, x12
    OR x23, x29, x20
    SLTIU x17, x13, 1
    XORI x9, x23, 76
    XORI x1, x30, 84
    SRL x4, x5, x10
    SLL x6, x28, x29
    ADD x27, x6, x6
    AUIPC x6, 1048550
    SLTI x23, x2, 161
    XOR x11, x28, x22
    SH x26, 1392(x29)
    ADDI x4, x29, -112
    SLTI x11, x9, -73
    ADD x4, x26, x13
    OR x25, x25, x9
    SLL x26, x4, x8
    SRLI x26, x29, 24
    ADDI x3, x8, 15
    SLL x11, x9, x12
    LUI x18, 3
    SLL x1, x4, x22
    SRAI x7, x5, 30
    SLLI x6, x15, 28
    SUB x25, x6, x10
    AND x5, x14, x26
    ADD x24, x6, x21
    SRLI x14, x11, 30
    SRAI x12, x27, 5
    SRL x15, x1, x12
    AUIPC x11, 13
    SLT x30, x0, x26
    OR x20, x20, x23
    AND x4, x23, x13
    SLL x6, x13, x21
    SLTIU x31, x16, 19
    ADD x5, x26, x28
    OR x21, x3, x21
    JAL x1, 32
    SLLI x10, x28, 31
    SRA x6, x18, x19
    XORI x20, x1, 139
    ORI x28, x31, -123
    AND x15, x4, x7
    SRA x5, x5, x7
    ADD x14, x25, x25
    SLTU x2, x5, x23
    ADD x27, x3, x20
    AUIPC x7, 1048572
    SLTU x22, x3, x7
    XORI x17, x7, -23
    XORI x28, x23, 188
    ANDI x26, x8, -156
    SLTU x21, x15, x13
    ADDI x2, x0, 76
    SLL x1, x6, x17
    ANDI x24, x17, 144
    ADDI x23, x9, 145
    ADDI x25, x21, -55
    SLL x20, x28, x4
    AND x28, x27, x29
    SUB x6, x27, x8
    SW x12, 496(x29)
    ORI x7, x7, 183
    XOR x21, x4, x21
    SLTU x26, x7, x6
    ORI x31, x20, -133
    SLT x28, x12, x6
    LUI x20, 11
    SLTIU x3, x25, -47
    XORI x15, x2, -47
    AUIPC x25, 1048561
    SUB x13, x11, x31
    SUB x31, x27, x0
    SLLI x19, x13, 7
    JAL x15, 12
    SRAI x31, x24, 26
    XOR x10, x19, x21
    SRL x0, x10, x20
    SRLI x19, x16, 10
    SLL x3, x13, x2
    SLLI x8, x8, 11
    ADDI x30, x30, 78
    ADD x19, x8, x3
    ADD x8, x29, x21
    SLL x17, x29, x7
    ORI x2, x20, -89
    LH x17, 200(x29)
    XOR x25, x25, x21
    XOR x0, x19, x11
    AUIPC x18, 25
    SLT x0, x1, x21
    XORI x14, x30, 98
    SLLI x22, x28, 11
    SLL x0, x24, x20
    AND x2, x7, x18
    SLTI x23, x8, -167
    ADD x2, x3, x7
    AND x18, x19, x11
    OR x7, x16, x14
    OR x3, x3, x17
    ANDI x4, x19, -198
    AND x16, x15, x13
    SUB x16, x21, x0
    SLTI x30, x3, 200
    XORI x17, x0, -51
    SRLI x2, x31, 6
    AND x3, x25, x4
    SLLI x26, x7, 28
    SLTIU x31, x7, 25
    AND x13, x21, x25
    JAL x31, 32
    ORI x6, x30, -23
    SLTI x30, x31, -65
    SUB x22, x2, x13
    ORI x10, x19, 62
    SRL x16, x25, x23
    SRL x14, x14, x27
    SLT x2, x4, x21
    ANDI x1, x20, 36
    ORI x25, x22, -180
    ORI x3, x22, 89
    XOR x3, x9, x31
    SLLI x8, x23, 31
    SUB x16, x23, x29
    XOR x19, x1, x26
    SLTU x26, x11, x14
    SLTIU x2, x29, -188
    ADDI x16, x20, 194
    SLL x21, x2, x30
    XORI x10, x7, -79
    XOR x2, x1, x10
    ADDI x22, x22, -132
    SUB x25, x5, x1
    ORI x17, x24, -141
    SLLI x15, x11, 12
    SLTIU x8, x0, -38
    SRL x0, x2, x8
    LHU x11, 12(x29)
    XORI x12, x26, 139
    LUI x6, 27
    AND x29, x24, x2
    SRA x21, x2, x0
    ADD x26, x16, x29
    SLTI x19, x18, 165
    SRL x13, x12, x4
    SRLI x24, x26, 31
    AUIPC x3, 6
    SRLI x17, x0, 0
    SUB x5, x25, x5
    ADD x26, x2, x30
    ADD x28, x29, x15
    SRA x3, x19, x21
    SRLI x28, x19, 2
    SUB x10, x19, x31
    SLTU x16, x29, x28
    AUIPC x18, 1048565
    ADDI x26, x3, 15
    SRL x23, x12, x23
    SLTI x20, x30, 73
    AUIPC x5, 1048570
    SRL x12, x5, x28
    AUIPC x21, 1
    ANDI x25, x13, 198
    SLTIU x3, x8, 14
    BGEU x12, x10, 20
    AND x12, x12, x16
    SRLI x1, x5, 27
    SLL x4, x28, x9
    AND x13, x29, x2
    SLTI x20, x8, 105
    LUI x10, 1048548
    SRL x16, x18, x8
    AUIPC x26, 22
    AND x2, x16, x24
    XOR x16, x8, x24
    SLL x0, x3, x24
    SLT x9, x22, x3
    SW x28, 1872(x29)
    ORI x9, x5, 45
    SRLI x1, x20, 18
    XOR x20, x29, x3
    AND x1, x6, x18
    XOR x22, x3, x2
    SRA x9, x16, x17
    SLTIU x2, x11, 62
    SLTIU x7, x25, -136
    SRL x13, x8, x8
    SLLI x13, x23, 22
    SRAI x3, x22, 19
    ADD x27, x20, x8
    ORI x20, x30, 33
    BEQ x24, x15, 28
    SLTU x27, x23, x11
    AND x30, x5, x0
    ANDI x19, x4, -161
    SLL x26, x25, x23
    SUB x7, x24, x6
    SRA x29, x5, x6
    AND x13, x11, x27
    SRL x29, x10, x30
    SRA x1, x28, x5
    SRA x7, x20, x16
    ANDI x25, x2, -5
    SLL x21, x28, x28
    SUB x0, x29, x7
    LUI x14, 1048556
    SW x24, 1128(x29)
    SLTI x3, x14, -65
    SRL x10, x7, x9
    XOR x29, x20, x30
    XORI x22, x19, -160
    SLTI x26, x27, 191
    AND x6, x31, x22
    XOR x23, x0, x15
    XORI x25, x15, 183
    SLL x24, x13, x26
    SLT x2, x11, x24
    SRL x31, x23, x0
    SRLI x1, x17, 30
    SRAI x22, x20, 13
    SUB x6, x11, x15
    SLL x17, x24, x26
    XOR x3, x11, x30
    AND x4, x12, x5
    LUI x1, 1048565
    ADD x30, x8, x8
    XOR x26, x29, x30
    ADD x24, x24, x23
    OR x8, x10, x18
    JAL x30, 12
    SRA x27, x23, x9
    SRL x6, x8, x30
    SLL x17, x16, x6
    SLT x15, x10, x28
    SRLI x22, x31, 12
    SRAI x11, x22, 17
    SUB x5, x6, x5
    ORI x20, x25, 9
    ORI x26, x12, -67
    XORI x25, x10, -91
    LUI x17, 1048566
    SLL x25, x1, x19
    SRL x2, x1, x12
    SH x0, 722(x29)
    SLTI x22, x21, 20
    XOR x3, x7, x0
    XOR x27, x26, x23
    SLLI x28, x26, 13
    XORI x18, x15, -174
    SLTI x5, x13, -91
    SLTIU x22, x13, 58
    XORI x19, x26, 86
    ORI x9, x26, -96
    XOR x15, x5, x22
    SLL x23, x5, x11
    OR x26, x29, x30
    SLTU x23, x24, x2
    SLTIU x25, x16, 174
    SLT x9, x18, x24
    XORI x31, x13, 92
    AUIPC x13, 0
    ADDI x13, x13, 8
    JALR x10, 4(x13)
    SRAI x28, x29, 10
    SLL x10, x14, x24
    SH x23, 1136(x29)
    LUI x4, 1048564
    AND x12, x8, x21
    SLTI x7, x10, -23
    SRAI x27, x10, 11
    LUI x2, 1048559
    AUIPC x27, 1048558
    SLTU x16, x9, x21
    SRAI x1, x31, 30
    ADD x18, x8, x3
    LUI x11, 7
    SLLI x8, x15, 3
    SLTI x24, x5, 189
    SLTU x31, x19, x30
    ADDI x0, x3, 35
    BGE x29, x15, 32
    XOR x18, x2, x4
    SLTIU x2, x0, 28
    SLL x16, x14, x4
    OR x28, x6, x8
    SRLI x17, x28, 10
    LUI x27, 1048567
    AUIPC x10, 1048548
    ANDI x8, x3, -37
    SLTI x16, x28, 149
    SUB x4, x17, x31
    SRLI x3, x24, 20
    ORI x4, x9, 133
    SRA x5, x25, x27
    LHU x8, 72(x29)
    SLTU x13, x20, x4
    ANDI x31, x9, -45
    ORI x24, x13, 150
    SLTU x31, x7, x29
    SRAI x1, x4, 31
    ADDI x5, x24, -84
    SRAI x25, x29, 6
    OR x27, x8, x30
    XOR x7, x8, x2
    SRLI x15, x5, 7
    XOR x8, x11, x29
    SLTU x29, x9, x14
    AUIPC x17, 0
    ADDI x17, x17, 8
    JALR x1, 16(x17)
    AND x1, x24, x24
    XORI x28, x31, 68
    ORI x17, x14, -193
    ORI x25, x16, -111
    SRAI x10, x1, 11
    ADDI x14, x23, 190
    AND x7, x19, x29
    SLTU x15, x25, x21
    ORI x23, x28, 34
    ANDI x0, x22, 111
    LBU x3, 1236(x29)
    AUIPC x17, 18
    SRLI x24, x31, 14
    ORI x31, x12, 58
    ORI x28, x0, -4
    AUIPC x4, 1048574
    SUB x6, x29, x9
    SRLI x15, x31, 7
    SLL x13, x13, x27
    XOR x0, x12, x29
    LUI x1, 1048560
    XORI x22, x24, 58
    ORI x2, x1, 140
    XORI x26, x17, 159
    SRLI x25, x4, 29
    XOR x11, x25, x18
    AND x10, x17, x25
    ORI x20, x25, 118
    AND x26, x17, x24
    ADD x24, x26, x13
    OR x8, x12, x8
    XOR x5, x31, x2
    SLT x23, x9, x29
    BLT x31, x14, 24
    SRAI x28, x1, 13
    AND x21, x21, x10
    SLTI x31, x13, 181
    XORI x14, x30, 178
    XORI x14, x8, -134
    SLTIU x1, x21, -2
    SLTU x5, x13, x13
    SRA x26, x13, x24
    ADD x5, x4, x2
    AND x27, x27, x7
    SLT x23, x17, x22
    ANDI x17, x25, -65
    ORI x24, x15, 135
    SLTU x6, x6, x20
    ORI x11, x12, 88
    SRLI x24, x2, 6
    SLTIU x29, x28, -34
    LUI x26, 1048562
    XOR x18, x28, x15
    SLL x15, x11, x13
    LBU x17, 38(x29)
    ADD x17, x15, x23
    ADDI x20, x7, -151
    ADDI x22, x28, 132
    ORI x6, x26, 153
    SRA x30, x19, x11
    SRLI x18, x29, 25
    SLL x5, x25, x24
    ADDI x22, x30, 189
    SLL x11, x9, x10
    OR x4, x31, x9
    SLTIU x15, x12, -135
    SUB x14, x16, x26
    LUI x18, 0
    XOR x3, x25, x7
    XOR x6, x26, x9
    SLTIU x9, x23, -97
    SLTU x5, x10, x5
    SLTU x19, x26, x10
    BLTU x15, x27, 20
    SLL x31, x4, x19
    AND x3, x31, x10
    SRA x30, x11, x6
    SRL x13, x24, x0
    ORI x4, x16, 120
    ANDI x13, x3, -96
    XOR x25, x26, x18
    AUIPC x21, 1048553
    OR x0, x9, x23
    ORI x2, x9, -12
    AND x16, x1, x27
    LBU x9, 143(x29)
    SRLI x6, x14, 15
    LUI x25, 1048575
    ORI x8, x28, -197
    SLL x25, x17, x26
    ADDI x17, x1, 188
    SLLI x3, x23, 17
    ORI x23, x18, 153
    SRA x11, x30, x6
    SLTIU x20, x22, 139
    ORI x20, x29, 127
    ORI x10, x9, 158
    AUIPC x2, 1048565
    ORI x14, x28, 21
    ANDI x12, x26, -196
    SRA x17, x18, x12
    ADD x13, x26, x10
    SRAI x10, x13, 28
    OR x31, x6, x4
    SLL x29, x6, x1
    XORI x23, x8, -135
    XORI x31, x27, -9
    XORI x30, x3, -188
    SRAI x1, x19, 31
    SUB x3, x9, x25
    SLLI x14, x2, 5
    SUB x11, x0, x31
    SLT x23, x2, x20
    SUB x28, x4, x14
    SRAI x9, x23, 18
    SLTI x15, x0, 56
    BGE x27, x4, 28
    SUB x3, x16, x5
    SLTI x12, x30, -78
    XORI x1, x14, -31
    LUI x19, 5
    SLT x31, x15, x9
    SLTI x26, x8, 131
    ORI x9, x18, -185
    XORI x17, x30, 82
    SLLI x15, x25, 20
    ANDI x5, x26, -89
    AND x7, x19, x29
    ADD x18, x7, x2
    SB x5, 149(x29)
    SLL x31, x25, x20
    OR x10, x13, x23
    SRAI x8, x27, 25
    ADD x4, x14, x23
    ADD x5, x29, x18
    AUIPC x8, 1048563
    SLTI x24, x1, -37
    SLTU x28, x25, x16
    SLTIU x22, x25, 119
    SRAI x13, x18, 31
    SLL x3, x25, x27
    SRLI x3, x8, 20
    SLLI x24, x1, 5
    ADD x13, x7, x13
    SLTI x18, x9, -157
    ADD x12, x24, x1
    SLTU x23, x6, x12
    SLL x27, x23, x27
    SLL x28, x16, x14
    BLT x26, x9, 40
    SRAI x10, x13, 1
    SLTIU x29, x22, -36
    SLTU x22, x0, x2
    SUB x0, x27, x27
    LUI x9, 1048560
    SLLI x8, x12, 23
    SRAI x12, x11, 23
    SLTI x4, x22, 46
    SLTU x17, x16, x0
    XORI x1, x27, 24
    SLTI x12, x25, -106
    AUIPC x27, 1048572
    SH x10, 1942(x29)
    XORI x22, x13, 107
    SUB x7, x12, x20
    SLTI x22, x7, 120
    SLL x17, x11, x3
    ORI x31, x13, -56
    ANDI x14, x13, 35
    SRLI x1, x29, 0
    AUIPC x16, 1048575
    SRA x7, x19, x2
    SLL x20, x24, x7
    LUI x17, 2
    SLTI x0, x31, 66
    AND x14, x13, x7
    SLTU x10, x26, x31
    SUB x15, x22, x18
    SLTIU x6, x13, -184
    SLTU x4, x26, x27
    XORI x3, x25, -185
    XOR x2, x27, x6
    AUIPC x6, 0
    ADDI x6, x6, 8
    JALR x9, 12(x6)
    ADDI x18, x30, 21
    SRL x28, x30, x24
    AUIPC x9, 1048563
    XOR x25, x0, x8
    ADD x30, x12, x19
    ORI x14, x27, -150
    OR x22, x26, x20
    SLTU x12, x15, x25
    SRAI x13, x6, 26
    SW x3, 468(x29)
    OR x21, x11, x1
    AUIPC x14, 1048574
    SUB x30, x27, x13
    ANDI x0, x31, -167
    SRLI x9, x31, 14
    XORI x2, x29, 158
    SLLI x8, x21, 14
    SLL x2, x7, x0
    AUIPC x22, 18
    OR x5, x1, x15
    SRAI x15, x6, 1
    SLLI x20, x6, 30
    AND x12, x29, x16
    SRLI x24, x0, 24
    LUI x24, 1048570
    JAL x0, 36
    XOR x22, x1, x23
    SLTI x3, x20, 31
    XORI x31, x31, -111
    AND x24, x10, x29
    SRAI x29, x16, 29
    ANDI x22, x3, -101
    SLTU x24, x4, x11
    SRL x6, x7, x24
    LUI x17, 13
    ORI x13, x19, 119
    OR x24, x27, x17
    SLTI x8, x7, -16
    AND x10, x5, x17
    SRAI x15, x23, 25
    SRL x1, x6, x26
    AND x10, x24, x2
    SUB x22, x7, x11
    LUI x6, 14
    LHU x9, 22(x29)
    AND x11, x3, x0
    SLTIU x22, x15, 146
    SRAI x25, x26, 9
    SLTI x27, x5, 182
    SLTIU x31, x30, -41
    SRAI x26, x23, 28
    XOR x9, x6, x10
    ADD x29, x9, x22
    SUB x18, x29, x26
    ORI x22, x31, -37
    ORI x0, x22, -137
    OR x3, x23, x19
    AND x10, x22, x10
    SLTI x28, x7, -94
    XOR x21, x14, x14
    SRAI x0, x14, 21
    SLLI x15, x14, 13
    SRLI x16, x27, 16
    XOR x5, x24, x2
    ADD x23, x21, x14
    ORI x17, x10, -73
    SRLI x6, x19, 2
    ADD x15, x19, x0
    SLL x19, x3, x24
    SLL x15, x23, x19
    SLT x24, x10, x18
    SLT x8, x0, x7
    ORI x30, x8, 65
    SLL x0, x31, x5
    JAL x16, 36
    XOR x5, x17, x13
    ADD x15, x20, x24
    SRAI x19, x24, 19
    SRLI x9, x24, 9
    SRLI x30, x1, 15
    ADDI x14, x0, 60
    LUI x19, 20
    ORI x3, x5, 169
    ADDI x13, x14, 51
    ADD x10, x1, x26
    ORI x22, x4, -70
    XORI x8, x14, -187
    SRAI x1, x7, 19
    SLTIU x30, x24, 189
    ADD x12, x3, x1
    LUI x7, 1048557
    SLL x14, x11, x2
    AUIPC x10, 10
    ADDI x9, x13, 30
    ANDI x29, x9, 178
    ORI x25, x22, -182
    LUI x11, 31
    OR x4, x14, x31
    SLLI x15, x22, 21
    SLTU x30, x9, x11
    SRLI x23, x17, 11
    AUIPC x13, 18
    XORI x16, x10, -71
    LBU x5, 32(x29)
    SLLI x21, x12, 24
    AUIPC x25, 4
    SRL x4, x16, x7
    SLL x16, x20, x14
    LUI x8, 19
    SLTU x21, x27, x29
    SLTIU x17, x8, -143
    ORI x6, x15, 163
    SLTIU x22, x28, -62
    SRA x23, x25, x11
    SRAI x3, x21, 25
    ORI x8, x0, 108
    SLLI x23, x1, 21
    LUI x5, 8
    ANDI x16, x6, 161
    SLTI x9, x3, 34
    ORI x24, x6, -183
    SUB x12, x6, x13
    SLTIU x21, x11, -161
    OR x15, x5, x11
    SLTI x12, x17, -182
    ORI x5, x24, 140
    AND x8, x3, x29
    AUIPC x17, 0
    ADDI x17, x17, 8
    JALR x14, 12(x17)
    SLTU x23, x27, x24
    SLTIU x12, x31, 105
    SRLI x10, x1, 4
    SRLI x8, x12, 30
    SLLI x12, x15, 1
    SLTI x29, x14, 157
    ORI x28, x8, -151
    ANDI x12, x18, -91
    ORI x12, x22, 89
    SLL x8, x9, x17
    SRAI x19, x14, 16
    SLTI x3, x10, -84
    LH x23, 40(x29)
    SRL x29, x22, x6
    OR x31, x24, x2
    AUIPC x4, 27
    ADDI x11, x20, -77
    ADD x16, x13, x30
    LUI x19, 7
    OR x0, x4, x16
    SLT x29, x31, x5
    SRLI x9, x17, 31
    ADD x11, x12, x24
    SRAI x8, x6, 27
    AND x14, x21, x26
    SRA x9, x8, x8
    AUIPC x26, 21
    SLT x19, x28, x16
    SRLI x15, x16, 17
    XORI x27, x1, -62
    SLL x5, x7, x16
    XOR x14, x9, x17
    SRAI x7, x30, 15
    ORI x21, x3, 2
    SLLI x2, x19, 12
    OR x21, x1, x26
    SLT x23, x7, x4
    SLLI x20, x30, 19
    SRAI x9, x27, 5
    AUIPC x22, 1048571
    AUIPC x0, 1048565
    XORI x19, x13, -110
    SLTI x24, x25, -180
    SLTU x27, x24, x9
    AUIPC x23, 1048555
    SRL x2, x27, x8
    ORI x7, x28, -22
    XORI x0, x17, -138
    AND x12, x15, x29
    ADD x6, x9, x3
    ANDI x2, x0, -155
    BEQ x0, x3, 32
    SLTI x9, x0, -63
    ADDI x24, x4, -152
    SH x28, 1254(x29)
    XORI x11, x13, -183
    SUB x6, x11, x20
    ADDI x14, x23, 79
    SLT x2, x7, x11
    AUIPC x8, 11
    SLLI x28, x19, 15
    SLTIU x23, x2, -21
    OR x28, x10, x6
    XORI x14, x11, 153
    SLL x9, x20, x1
    SLTIU x24, x24, -52
    SRL x18, x26, x9
    AUIPC x1, 1048575
    SLTIU x2, x17, 175
    SRA x14, x30, x10
    SRA x3, x12, x12
    OR x10, x2, x17
    SLTIU x9, x11, 114
    ADDI x5, x22, -43
    XORI x9, x21, -151
    SRA x9, x28, x15
    AUIPC x15, 1
    ADDI x27, x18, -187
    SLT x26, x23, x23
    ADD x13, x0, x24
    BEQ x3, x2, 4
    SLT x14, x25, x21
    AUIPC x28, 0
    ANDI x26, x5, -56
    ADDI x23, x14, -51
    ORI x15, x12, -168
    SLLI x11, x11, 31
    LUI x8, 7
    SLLI x29, x1, 2
    SUB x12, x4, x31
    XORI x18, x31, 135
    SRLI x29, x2, 16
    ANDI x20, x4, 36
    SW x13, 1860(x29)
    SLTIU x3, x9, -162
    AUIPC x31, 1048572
    SRLI x30, x14, 4
    LUI x1, 8
    SLTU x11, x29, x6
    SRLI x28, x6, 27
    AND x1, x27, x6
    XOR x28, x27, x24
    LUI x16, 5
    SRLI x7, x22, 9
    OR x24, x30, x18
    SRLI x26, x13, 19
    SLTIU x28, x13, 120
    SRAI x30, x24, 30
    SLLI x11, x9, 14
    SLLI x22, x3, 7
    XOR x13, x9, x3
    SLTI x17, x7, 74
    SRLI x0, x5, 30
    ORI x20, x12, 191
    SLTIU x29, x13, 60
    XORI x15, x22, 80
    SLL x0, x25, x17
    SRA x31, x14, x2
    BLT x17, x21, 24
    XORI x3, x31, -55
    ADD x12, x17, x22
    SLL x24, x15, x21
    ORI x5, x5, 80
    SLLI x16, x21, 30
    SLTIU x12, x16, 119
    SLTI x27, x20, 93
    SLLI x22, x18, 24
    LUI x31, 1
    SRL x19, x14, x5
    ORI x8, x22, -97
    XORI x18, x10, -109
    SLT x23, x2, x7
    SLTIU x8, x31, 172
    SLT x26, x26, x23
    SLTIU x28, x1, -186
    SLL x16, x0, x7
    LB x13, 140(x29)
    SLTIU x10, x21, -110
    ANDI x2, x15, 55
    ADDI x12, x23, -98
    SRAI x19, x3, 29
    SLTIU x22, x13, -90
    SRAI x6, x14, 4
    SLT x25, x27, x31
    SUB x28, x25, x2
    SLT x7, x13, x18
    ADDI x29, x0, -192
    XORI x6, x0, -157
    SLTI x4, x17, -171
    SLTIU x22, x3, 156
    AUIPC x26, 17
    LUI x22, 1048559
    ADD x27, x15, x20
    SLLI x16, x31, 0
    XORI x9, x17, 61
    AND x21, x13, x5
    XORI x17, x20, 16
    ADDI x18, x4, -84
    XORI x31, x31, 99
    AUIPC x5, 1048575
    JAL x18, 24
    SRL x0, x23, x14
    ANDI x28, x23, 158
    SRAI x26, x11, 7
    ORI x15, x5, 74
    XOR x2, x2, x6
    SLT x14, x25, x25
    XORI x19, x25, 29
    OR x8, x11, x14
    ANDI x20, x13, -192
    SRLI x28, x17, 9
    ADD x1, x8, x12
    SLTIU x31, x11, 169
    ORI x30, x28, -145
    SRL x15, x7, x8
    XOR x16, x31, x2
    SLLI x20, x11, 7
    ADDI x19, x4, 172
    ADD x18, x4, x10
    SRL x7, x12, x21
    SUB x15, x12, x18
    SUB x2, x11, x15
    SLL x16, x6, x24
    SLT x29, x12, x19
    SRL x3, x26, x18
    LB x29, 1828(x29)
    SLLI x20, x2, 5
    SLLI x13, x12, 24
    LUI x20, 1048571
    ORI x19, x20, 186
    SUB x19, x16, x20
    SLT x9, x18, x4
    ANDI x8, x1, 70
    SLTU x23, x28, x30
    SLTU x17, x14, x3
    ADDI x4, x11, 183
    ADDI x29, x28, 191
    SRA x16, x23, x24
    ADD x28, x31, x3
    OR x23, x14, x11
    ADD x18, x22, x11
    ANDI x14, x17, 55
    AUIPC x11, 0
    ADDI x11, x11, 8
    JALR x28, 24(x11)
    SLLI x26, x8, 17
    SRAI x7, x8, 26
    SLTU x27, x30, x16
    SRAI x1, x20, 10
    SRLI x6, x5, 7
    SLTIU x12, x1, 158
    ORI x31, x6, 187
    SRLI x1, x23, 8
    SLTI x3, x20, 178
    SLTIU x25, x27, -163
    SLLI x26, x31, 24
    ADD x11, x3, x26
    OR x11, x18, x11
    LUI x6, 524304
    ADDI x6, x6, 256
    SH x17, 892(x6)
    OR x22, x9, x16
    AUIPC x29, 2
    AND x27, x15, x9
    XOR x4, x14, x30
    XORI x16, x20, 86
    SRA x31, x18, x15
    ADDI x14, x8, 141
    SLTIU x7, x4, -24
    SLTI x22, x19, -198
    ADD x11, x21, x30
    AND x26, x14, x23
    ANDI x9, x9, -66
    OR x27, x8, x28
    SLTI x16, x22, 123
    ORI x28, x31, 83
    XOR x14, x17, x28
    ORI x0, x29, 122
    SLLI x13, x2, 31
    LUI x21, 1048562
    ORI x26, x1, 85
    ANDI x20, x17, 127
    SLTI x18, x25, 18
    SRA x17, x28, x0
    LUI x0, 1048564
    SLTIU x18, x1, 118
    ADDI x11, x27, 194
    XOR x13, x28, x16
    OR x26, x25, x12
    XORI x30, x29, 2
    XORI x13, x5, 100
    SRLI x8, x13, 28
    BGE x12, x14, 32
    SLT x27, x1, x6
    XOR x24, x10, x15
    ADD x24, x12, x23
    SLL x15, x23, x3
    ORI x3, x29, 19
    SRLI x18, x31, 1
    ADD x9, x13, x12
    ADD x9, x23, x14
    SW x27, 1104(x6)
    SLTU x7, x5, x23
    ANDI x21, x10, -80
    OR x12, x0, x29
    SRLI x28, x31, 13
    SRA x29, x5, x6
    SRA x23, x14, x29
    XOR x31, x21, x9
    SLTIU x1, x10, 92
    SLT x30, x16, x12
    SRL x24, x20, x3
    LUI x31, 1048571
    ORI x2, x31, 49
    ANDI x22, x12, 6
    AUIPC x16, 1048574
    ADD x0, x29, x25
    ADDI x7, x18, 104
    XORI x0, x0, -28
    XORI x0, x30, -124
    AUIPC x2, 0
    ADDI x2, x2, 8
    JALR x24, 20(x2)
    SLTIU x18, x5, -142
    ADDI x7, x26, -164
    SRAI x7, x31, 25
    ANDI x10, x18, 35
    XOR x16, x17, x14
    SLTU x8, x24, x1
    SRAI x25, x17, 0
    SLL x18, x30, x5
    SLL x26, x8, x4
    ORI x0, x12, -111
    SRLI x8, x24, 5
    SRA x12, x10, x4
    SUB x19, x26, x12
    XOR x23, x7, x18
    SLLI x24, x14, 21
    AND x22, x8, x21
    XORI x0, x23, 8
    SLLI x7, x10, 4
    LUI x7, 1048557
    ADDI x0, x1, -144
    SB x16, 1983(x6)
    AUIPC x18, 1048553
    AND x25, x7, x17
    LUI x18, 1048571
    JAL x4, 36
    SUB x21, x10, x28
    ANDI x18, x2, -130
    SLTI x9, x14, 16
    SRAI x16, x26, 29
    SLL x22, x11, x25
    SUB x19, x12, x25
    AUIPC x11, 29
    AUIPC x16, 27
    OR x7, x2, x3
    LUI x11, 1048555
    SLL x20, x12, x1
    LBU x15, 972(x6)
    SRLI x24, x12, 21
    OR x3, x19, x2
    SRA x30, x0, x7
    SLT x15, x3, x28
    ADDI x16, x20, -164
    SLTIU x28, x22, -8
    SLTU x15, x9, x6
    LUI x31, 4
    SLL x4, x12, x18
    SRA x24, x4, x17
    SLLI x16, x30, 27
    ANDI x20, x20, 37
    AND x21, x1, x8
    SLTU x25, x6, x0
    OR x28, x12, x26
    XORI x22, x19, -99
    BGEU x9, x11, 40
    SRLI x2, x25, 15
    SLTI x7, x20, 153
    SRL x28, x19, x4
    OR x30, x6, x3
    SLT x31, x25, x3
    SRLI x30, x31, 2
    LUI x10, 1048568
    SUB x21, x17, x1
    SRA x31, x7, x20
    ANDI x5, x13, -128
    SLL x4, x5, x11
    SLTIU x2, x22, 190
    ADD x26, x9, x25
    LUI x26, 2
    SRAI x15, x4, 28
    AND x6, x28, x31
    SLTI x17, x15, -54
    SLTU x19, x12, x0
    AUIPC x29, 1048558
    SRA x2, x21, x21
    LH x30, 34(x6)
    AUIPC x20, 9
    XORI x28, x2, -125
    AND x7, x24, x17
    XOR x11, x11, x26
    LUI x30, 1048572
    AUIPC x26, 11
    OR x21, x15, x15
    AND x29, x1, x27
    SRA x8, x13, x2
    ADD x24, x4, x9
    BLTU x19, x9, 16
    SLL x13, x20, x29
    SRL x9, x31, x24
    OR x15, x27, x16
    SRL x31, x2, x6
    SLTU x16, x7, x10
    LBU x24, 192(x6)
    ORI x30, x22, 58
    LUI x13, 1048572
    SLT x13, x26, x14
    ANDI x0, x2, -17
    LUI x19, 1048575
    OR x21, x25, x13
    ADD x1, x8, x12
    SLLI x18, x22, 17
    XORI x15, x20, 72
    SLTU x10, x21, x27
    BLT x22, x15, 4
    ANDI x10, x17, -40
    SRA x8, x7, x7
    SRL x25, x31, x13
    SRAI x17, x11, 24
    SLTI x19, x5, -76
    OR x25, x3, x19
    SRA x25, x2, x9
    ADD x11, x15, x20
    SRLI x23, x13, 17
    SLT x16, x3, x8
    SRL x17, x29, x28
    SRLI x8, x30, 18
    AND x6, x3, x11
    SLTI x1, x30, -66
    AUIPC x5, 10
    ADDI x2, x8, -147
    LUI x2, 1048560
    ADDI x29, x8, -163
    AUIPC x12, 1048571
    SH x25, 1440(x6)
    SRAI x10, x13, 0
    SLT x13, x7, x2
    SLTU x4, x9, x7
    SRA x15, x11, x8
    LUI x11, 1048569
    XORI x16, x15, 7
    SLTU x26, x3, x1
    ADD x22, x26, x30
    SRAI x22, x13, 2
    SLTIU x28, x14, -88
    ADD x26, x8, x4
    SLT x12, x8, x20
    XORI x24, x5, 160
    
    jal x22,  exiting_step
    li x23, 0xFFFF      # Should skip
exiting_step:
    li x31, 0x80012100
    li x30, 0xFFFFFFFF
    # this notifies UVM testbench to stop execution
    sw x30, 0(x31)

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
