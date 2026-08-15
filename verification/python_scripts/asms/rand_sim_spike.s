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

    SUB x18, x10, x0
    SLTIU x31, x0, 1
    XOR x11, x0, x15
    ADDI x15, x7, 44
    AND x1, x20, x10
    SLLI x13, x19, 17
    ADDI x4, x16, -114
    SRL x19, x11, x17
    AUIPC x9, 0
    ADDI x9, x9, 8
    JALR x15, 20(x9)
    LUI x19, 11
    LUI x25, 19
    SLTU x13, x17, x20
    ADD x10, x5, x9
    ORI x4, x13, 75
    SRAI x10, x6, 23
    SLT x4, x21, x5
    ORI x8, x17, 154
    AND x0, x0, x10
    SLTIU x8, x10, 157
    XORI x31, x16, -130
    ANDI x3, x7, 150
    AND x20, x18, x18
    ORI x17, x14, 85
    SRAI x23, x18, 30
    LUI x14, 10
    SRAI x31, x9, 9
    LUI x7, 524304
    ADDI x7, x7, 256
    SW x20, 1288(x7)
    XOR x19, x14, x17
    XOR x15, x10, x20
    SRL x5, x20, x11
    SRA x22, x19, x7
    SLTU x3, x10, x1
    SRLI x2, x23, 9
    AUIPC x1, 1048574
    SLTIU x25, x12, 85
    AND x23, x15, x21
    SLLI x0, x8, 23
    LUI x25, 18
    ADD x7, x7, x1
    AUIPC x3, 1048572
    ADD x1, x16, x0
    JAL x25, 4
    SLLI x1, x18, 29
    ANDI x24, x13, 188
    SLLI x23, x9, 22
    XORI x15, x15, -184
    SLTI x16, x7, -16
    LUI x6, 524304
    ADDI x6, x6, 256
    SB x17, 650(x6)
    SLLI x11, x13, 2
    ADD x2, x31, x6
    SRL x20, x20, x15
    SLL x29, x9, x19
    SLLI x22, x22, 18
    ADDI x20, x14, -182
    SRLI x13, x8, 16
    SLLI x6, x1, 22
    ADD x0, x14, x15
    OR x26, x23, x10
    XORI x9, x10, -184
    SLTI x19, x22, 175
    SRLI x14, x4, 25
    ADDI x27, x23, 106
    ORI x26, x20, 84
    XOR x0, x31, x31
    SLTI x28, x23, 191
    SLLI x9, x3, 14
    AUIPC x7, 0
    ADDI x7, x7, 8
    JALR x10, 16(x7)
    SLTU x18, x26, x31
    SLTU x3, x21, x2
    ANDI x24, x25, -17
    SUB x16, x23, x31
    XOR x10, x31, x26
    SRL x0, x13, x29
    ADDI x23, x12, -81
    SRAI x8, x14, 19
    ADDI x3, x25, -20
    ADDI x1, x6, 168
    SUB x16, x23, x22
    SLTIU x17, x14, -168
    AND x9, x4, x9
    SLTIU x5, x27, -33
    AUIPC x18, 1048565
    ADDI x18, x19, 175
    SLL x11, x22, x12
    SLTI x7, x23, -20
    AUIPC x4, 1048566
    ANDI x3, x5, -94
    ADDI x17, x4, -56
    LUI x26, 524304
    ADDI x26, x26, 256
    SW x29, 1788(x26)
    XOR x6, x22, x2
    ORI x22, x4, -83
    ANDI x3, x13, 171
    SLTIU x11, x7, 37
    ANDI x16, x5, 124
    LUI x24, 1048573
    ORI x24, x5, 183
    AND x21, x31, x26
    SLL x24, x18, x3
    SRLI x11, x9, 18
    XORI x20, x9, -117
    ORI x31, x12, 62
    SLTI x19, x14, -103
    AUIPC x17, 1048570
    SRL x5, x15, x27
    AND x31, x19, x21
    ADDI x26, x11, -124
    SLT x21, x31, x0
    ADDI x18, x18, 195
    SLT x29, x26, x7
    SLT x3, x24, x5
    SLTU x4, x5, x19
    XOR x28, x21, x2
    SLLI x1, x10, 12
    SLT x23, x7, x8
    SLTU x20, x21, x11
    BLTU x20, x3, 8
    XOR x31, x19, x11
    SLTI x25, x21, 0
    SLTU x18, x20, x24
    AUIPC x0, 0
    SRAI x4, x1, 7
    AUIPC x6, 14
    OR x10, x0, x19
    SLTIU x8, x2, -9
    SRA x28, x22, x19
    SLLI x22, x2, 29
    LUI x17, 524304
    ADDI x17, x17, 256
    LHU x11, 54(x17)
    SLTI x26, x14, 86
    ADD x4, x27, x25
    SLLI x30, x18, 25
    ORI x19, x8, -166
    SLT x22, x15, x23
    SLTI x19, x7, 198
    ANDI x6, x12, 112
    XORI x29, x10, 28
    SLT x9, x6, x1
    ANDI x9, x15, -8
    ADD x18, x1, x19
    SUB x21, x8, x13
    AND x26, x15, x9
    SLT x30, x0, x27
    SRA x31, x18, x1
    SLLI x1, x18, 30
    AND x26, x9, x20
    AND x1, x10, x15
    JAL x0, 40
    SRLI x14, x22, 8
    XORI x23, x25, -109
    SLL x31, x24, x1
    SRLI x8, x6, 17
    SLTU x27, x2, x28
    ORI x16, x27, 84
    SRA x21, x19, x0
    ANDI x4, x12, 102
    SLL x22, x4, x2
    AND x30, x28, x24
    XORI x6, x29, -17
    SRAI x9, x24, 5
    LUI x31, 15
    SRLI x24, x27, 31
    AND x16, x4, x23
    AUIPC x4, 1048564
    SUB x5, x4, x9
    LUI x31, 9
    LB x0, 166(x17)
    SRL x10, x29, x30
    SLTU x28, x22, x30
    SRA x12, x20, x21
    SLLI x27, x15, 22
    SLTI x28, x18, 77
    SRA x14, x19, x26
    SLTIU x21, x12, 15
    SRL x27, x18, x14
    BLT x2, x8, 20
    AND x26, x19, x17
    SRLI x23, x24, 10
    ADD x0, x22, x2
    SRL x24, x10, x14
    OR x24, x6, x18
    SRL x23, x2, x20
    SB x24, 182(x17)
    ORI x18, x17, -91
    XORI x25, x30, -62
    AUIPC x17, 13
    AUIPC x7, 1048570
    ORI x4, x0, 149
    SRL x22, x3, x9
    AUIPC x12, 6
    OR x26, x23, x23
    AUIPC x26, 1048560
    SRLI x27, x23, 27
    AUIPC x24, 14
    SLLI x7, x21, 3
    SRA x9, x3, x12
    ANDI x12, x13, -76
    SLLI x19, x2, 13
    SLTIU x3, x4, -150
    AUIPC x19, 0
    ADDI x19, x19, 8
    JALR x31, 12(x19)
    SRL x13, x30, x4
    SLTIU x31, x17, 181
    ORI x9, x31, -39
    XOR x11, x8, x16
    ADD x10, x27, x13
    SLTIU x24, x23, -191
    LUI x19, 16
    XORI x10, x24, 110
    XOR x30, x12, x4
    SUB x21, x26, x30
    SRLI x10, x17, 20
    LUI x1, 1048571
    ADD x2, x4, x9
    LUI x20, 1048558
    SLT x30, x6, x24
    XOR x13, x22, x6
    SLTI x1, x0, -11
    ADD x7, x27, x30
    LUI x26, 524304
    ADDI x26, x26, 256
    SB x7, 81(x26)
    SRAI x2, x14, 23
    ANDI x22, x29, 32
    XORI x2, x19, 106
    SRLI x5, x18, 4
    SLTU x10, x24, x9
    ADD x3, x30, x30
    XORI x28, x30, -9
    AND x2, x16, x13
    SRLI x30, x4, 20
    ADDI x15, x30, -10
    SLTI x2, x14, 43
    AUIPC x23, 3
    SLT x29, x23, x18
    SLTU x15, x24, x25
    XORI x16, x26, -170
    ORI x11, x29, -37
    ADDI x21, x9, -102
    SLTU x23, x1, x17
    ADDI x30, x8, 40
    SRLI x7, x11, 20
    ADDI x6, x9, 83
    ANDI x20, x20, -196
    SLTI x31, x14, 72
    SUB x15, x21, x2
    SRLI x23, x17, 21
    AUIPC x23, 0
    ADDI x23, x23, 8
    JALR x6, 20(x23)
    SUB x0, x13, x13
    OR x20, x13, x4
    AUIPC x21, 1048545
    SLLI x7, x27, 24
    XORI x12, x20, 22
    LUI x25, 13
    ANDI x31, x17, 148
    SW x11, 928(x26)
    SUB x3, x17, x19
    SLL x24, x0, x12
    XOR x31, x22, x25
    SLTI x3, x2, -71
    ADD x20, x19, x2
    LUI x25, 13
    XORI x6, x10, 161
    SLT x8, x31, x9
    SRL x16, x17, x19
    AUIPC x26, 0
    ADDI x26, x26, 8
    JALR x22, 40(x26)
    SRA x15, x15, x11
    SLT x11, x31, x29
    LUI x0, 1048563
    SLLI x12, x28, 4
    XOR x21, x8, x19
    ADDI x28, x28, -165
    SLTI x3, x4, 98
    SLTI x9, x24, 180
    ANDI x21, x18, 141
    ADDI x4, x16, -179
    SRAI x25, x30, 31
    AUIPC x2, 1048571
    SLT x23, x15, x6
    AND x5, x26, x17
    AUIPC x20, 1048565
    SRA x3, x16, x16
    SRAI x26, x19, 12
    XORI x29, x21, 194
    AND x9, x10, x16
    SLLI x21, x17, 20
    SUB x31, x12, x1
    ANDI x29, x5, 84
    XOR x23, x25, x19
    SLLI x24, x31, 22
    XOR x2, x28, x14
    SRAI x15, x8, 26
    OR x6, x28, x7
    LUI x7, 524304
    ADDI x7, x7, 256
    SB x0, 1122(x7)
    ADDI x21, x4, -161
    SRLI x25, x13, 18
    XORI x2, x27, 58
    ANDI x20, x5, -46
    ANDI x20, x11, -70
    SUB x9, x6, x26
    XORI x27, x6, 196
    ANDI x21, x7, 162
    SUB x3, x15, x3
    SRA x0, x8, x3
    SLLI x26, x18, 23
    SLTI x22, x18, -51
    ORI x31, x9, -100
    SLTI x21, x10, -82
    AND x11, x4, x18
    SRA x2, x1, x15
    SLLI x1, x8, 17
    LUI x10, 1048572
    XORI x21, x3, 111
    ADDI x21, x9, -164
    SLLI x10, x14, 24
    AUIPC x11, 2
    XOR x12, x24, x28
    XOR x29, x21, x1
    XOR x17, x7, x14
    SRAI x27, x22, 6
    SRL x20, x27, x0
    SRA x28, x10, x11
    OR x28, x23, x22
    JAL x16, 28
    AUIPC x8, 1048568
    SLT x7, x27, x26
    SLTIU x26, x2, -194
    SRA x21, x2, x29
    SRA x2, x26, x24
    SUB x3, x14, x1
    SRLI x20, x0, 20
    SLTI x25, x26, 173
    XOR x13, x1, x8
    OR x27, x31, x16
    SUB x12, x8, x2
    ORI x26, x27, 141
    AUIPC x0, 1048560
    ADD x23, x10, x17
    ORI x28, x3, -33
    AND x2, x13, x22
    SRL x1, x15, x25
    SRA x28, x21, x4
    SRAI x17, x26, 7
    SRAI x12, x10, 8
    LW x15, 0(x7)
    SRAI x28, x15, 29
    ADDI x29, x15, -56
    XORI x8, x1, 85
    SRL x31, x18, x9
    OR x31, x4, x7
    XOR x11, x12, x25
    SRLI x1, x27, 2
    XORI x25, x7, -167
    LUI x11, 1
    XORI x10, x11, 29
    XORI x12, x5, -105
    SRL x6, x22, x28
    SRLI x25, x24, 18
    SUB x9, x7, x14
    SLT x10, x3, x29
    LUI x6, 1048566
    SUB x27, x26, x25
    ANDI x2, x0, -44
    JAL x5, 36
    SLTIU x28, x4, 190
    SRAI x27, x31, 3
    AND x7, x13, x14
    SLTIU x6, x16, 52
    XORI x18, x17, 36
    LUI x20, 8
    XORI x26, x26, -110
    SRAI x15, x31, 29
    XOR x18, x30, x5
    SRL x19, x21, x12
    ORI x4, x11, 131
    XOR x3, x22, x9
    SLTI x19, x30, 64
    ANDI x19, x11, -43
    SRLI x1, x7, 25
    SRA x15, x7, x18
    SB x4, 124(x3)
    SRLI x27, x31, 25
    SRL x8, x5, x11
    SUB x22, x14, x0
    AUIPC x29, 1048565
    SLTU x3, x12, x0
    SRAI x2, x20, 31
    SLLI x11, x21, 24
    SRAI x29, x9, 18
    SLTI x3, x2, 150
    SLLI x28, x25, 13
    LUI x28, 1048570
    XORI x29, x24, 125
    SRA x23, x0, x30
    SLL x30, x13, x3
    SLTIU x27, x11, 121
    SUB x11, x29, x30
    OR x12, x30, x26
    ADD x27, x31, x27
    SLL x10, x23, x5
    SLTU x21, x2, x4
    AUIPC x8, 0
    ADDI x8, x8, 8
    JALR x9, 8(x8)
    SUB x11, x22, x22
    SLLI x30, x19, 30
    SLT x13, x28, x29
    SLT x27, x30, x26
    XORI x19, x30, 75
    XOR x29, x10, x17
    SLLI x14, x16, 9
    SLTIU x13, x7, -141
    LUI x30, 8
    SLL x18, x0, x30
    LB x28, 98(x7)
    ADD x10, x16, x21
    SLL x29, x18, x23
    AUIPC x11, 0
    ADDI x11, x11, 8
    JALR x18, 36(x11)
    ANDI x21, x28, -6
    AUIPC x10, 5
    SRAI x8, x8, 19
    SRL x14, x31, x24
    SRLI x4, x26, 26
    ADDI x10, x5, 163
    SLT x30, x9, x14
    XOR x12, x10, x14
    SLL x1, x13, x16
    SUB x25, x22, x26
    ADD x23, x30, x22
    SUB x28, x15, x24
    LH x8, 52(x7)
    SRA x16, x26, x20
    ADDI x5, x31, -46
    SRA x8, x23, x22
    SRLI x26, x28, 5
    SLTIU x27, x21, -48
    OR x29, x20, x30
    AND x2, x9, x0
    ANDI x16, x10, -198
    XOR x19, x18, x13
    AND x20, x28, x6
    SLL x0, x21, x7
    ADDI x5, x2, 39
    SUB x24, x3, x19
    SLTI x6, x27, 131
    AUIPC x15, 0
    ADDI x15, x15, 8
    JALR x10, 24(x15)
    OR x15, x2, x15
    SLLI x21, x25, 23
    ADD x1, x25, x13
    AND x8, x28, x22
    LUI x19, 1048574
    ANDI x3, x6, -174
    SLTI x22, x17, 95
    SLLI x7, x19, 31
    OR x23, x20, x27
    SRA x31, x6, x12
    LUI x27, 524304
    ADDI x27, x27, 256
    SW x20, 1424(x27)
    SRLI x28, x24, 28
    ADD x28, x30, x13
    SRL x19, x13, x5
    AND x29, x23, x25
    XOR x23, x29, x2
    AND x28, x31, x24
    SUB x6, x6, x15
    SLLI x23, x1, 20
    SUB x5, x24, x18
    SUB x22, x26, x0
    SRL x2, x3, x25
    XORI x13, x11, -167
    ORI x24, x21, 87
    SLT x21, x6, x2
    AND x18, x26, x27
    ADDI x29, x18, -107
    SLTU x27, x20, x23
    OR x12, x8, x19
    LUI x9, 1048572
    SLL x30, x4, x13
    SLTIU x31, x20, 108
    ADDI x12, x30, -132
    SLTIU x30, x27, -28
    SUB x19, x15, x8
    XORI x21, x9, 93
    SRL x18, x17, x2
    SLT x19, x21, x12
    BLT x6, x30, 24
    SUB x7, x3, x30
    LUI x24, 1048570
    SLTIU x26, x15, -186
    AND x22, x11, x8
    SLTI x22, x2, -149
    SUB x17, x6, x20
    SLTU x28, x7, x28
    ORI x22, x8, -198
    AND x7, x9, x20
    SLLI x15, x23, 5
    ORI x6, x29, 119
    SRAI x28, x23, 20
    LUI x15, 524304
    ADDI x15, x15, 256
    SB x9, 978(x15)
    ADDI x6, x14, 76
    SLTI x31, x25, 68
    SRL x15, x30, x6
    SLTIU x12, x6, -191
    ADDI x12, x1, 163
    SLT x21, x28, x23
    ANDI x29, x25, -156
    OR x4, x7, x7
    ORI x11, x27, -98
    SLT x20, x27, x9
    SRAI x3, x12, 31
    SLTIU x16, x9, 13
    SLTIU x7, x6, 22
    SUB x2, x18, x26
    XORI x13, x15, 16
    AUIPC x1, 0
    ADDI x1, x1, 8
    JALR x7, 16(x1)
    XORI x16, x29, 146
    SRLI x9, x30, 17
    ADDI x22, x9, -166
    SUB x27, x22, x13
    SRL x5, x27, x1
    SLTU x0, x29, x13
    XORI x21, x4, -163
    ADD x29, x7, x15
    ANDI x6, x17, 30
    SRLI x22, x16, 2
    XOR x27, x14, x3
    SLTI x18, x22, -131
    AUIPC x13, 1048575
    SLTIU x13, x24, 92
    ADDI x23, x10, 134
    SRA x6, x18, x16
    XOR x22, x7, x0
    SLTI x31, x18, 188
    SLTU x22, x6, x4
    SLT x28, x15, x17
    SUB x24, x18, x23
    LUI x5, 524304
    ADDI x5, x5, 256
    SB x23, 1333(x5)
    SRLI x26, x19, 15
    SRA x5, x27, x30
    SLTI x16, x2, -66
    ORI x16, x12, 113
    SRA x28, x23, x3
    OR x16, x5, x10
    SLT x16, x21, x30
    ADDI x23, x25, 198
    SLL x29, x11, x3
    SRL x2, x10, x8
    SLTI x15, x5, 47
    ORI x9, x23, 23
    SLTIU x2, x6, -106
    XORI x0, x24, -137
    SLTU x30, x21, x10
    LUI x2, 7
    ANDI x12, x11, -136
    XORI x8, x27, 58
    AUIPC x8, 5
    JAL x12, 16
    SLTIU x7, x3, 72
    XOR x4, x4, x20
    ADD x17, x11, x26
    SLLI x19, x30, 2
    SLTI x5, x21, 56
    SUB x28, x2, x14
    SLTIU x31, x13, 176
    SRA x11, x18, x13
    SLL x29, x18, x4
    AUIPC x15, 1048554
    LUI x15, 524304
    ADDI x15, x15, 256
    SB x15, 1593(x15)
    AND x19, x0, x21
    SLT x23, x6, x8
    ORI x31, x7, 173
    ORI x7, x25, -50
    ADDI x5, x11, -106
    SRAI x13, x15, 31
    SLTI x28, x25, 54
    ADDI x30, x1, -2
    ORI x4, x29, -196
    SRA x20, x2, x4
    SRL x25, x9, x22
    ANDI x19, x14, 34
    SLTU x1, x31, x5
    SLLI x19, x12, 9
    BLT x25, x10, 36
    AND x28, x7, x7
    SLL x22, x16, x6
    XORI x31, x9, 52
    SLTI x23, x3, -156
    SLLI x2, x7, 25
    SUB x29, x29, x2
    SLL x19, x26, x31
    SRAI x16, x4, 10
    AND x8, x28, x7
    SRAI x31, x13, 22
    LHU x5, 12(x15)
    SRL x4, x4, x1
    OR x8, x22, x6
    SLLI x30, x1, 7
    SLTIU x2, x9, 101
    XORI x28, x18, -73
    SRLI x17, x2, 29
    LUI x6, 11
    LUI x10, 17
    SLTU x2, x0, x14
    OR x7, x5, x17
    SLT x17, x2, x9
    LUI x12, 2
    SLTI x22, x26, -92
    SRA x12, x4, x15
    XORI x7, x31, 141
    SLL x13, x6, x15
    SRL x21, x12, x27
    ORI x14, x2, -169
    XORI x7, x31, -163
    AUIPC x18, 0
    ADDI x18, x18, 8
    JALR x16, 28(x18)
    SLT x9, x11, x0
    SLT x15, x12, x11
    SUB x20, x13, x3
    SLLI x19, x15, 16
    ADD x11, x29, x14
    SLL x23, x7, x3
    SUB x4, x29, x19
    SLTIU x9, x20, -124
    SLTU x26, x5, x1
    SRA x12, x6, x12
    ADD x27, x12, x27
    ADD x28, x30, x18
    SLTIU x8, x8, 184
    ORI x29, x3, 155
    AND x22, x4, x15
    XORI x2, x17, -54
    SLTIU x23, x20, 137
    SRAI x7, x4, 0
    LUI x23, 0
    ADDI x11, x9, 77
    LH x22, 228(x15)
    SLTI x31, x24, -151
    ORI x0, x27, -9
    ADDI x1, x10, 132
    BNE x20, x0, 8
    XORI x29, x6, 93
    SRLI x3, x7, 9
    LUI x4, 0
    ADDI x14, x29, 4
    OR x30, x5, x15
    SLT x23, x22, x26
    SLTI x16, x9, -36
    SLL x16, x5, x26
    XORI x31, x9, -1
    SUB x26, x22, x5
    XOR x2, x17, x22
    LUI x18, 1048562
    XORI x28, x3, -136
    AND x12, x20, x6
    SLLI x22, x21, 16
    SLTI x19, x13, -32
    ORI x10, x4, -25
    SW x21, 812(x15)
    AND x13, x27, x10
    AND x26, x24, x26
    ANDI x23, x27, -146
    OR x0, x26, x28
    SLLI x4, x18, 19
    OR x4, x21, x0
    SLTI x27, x24, 63
    SLTU x24, x20, x30
    SLT x4, x11, x25
    SUB x30, x16, x13
    XOR x24, x25, x4
    XORI x9, x23, -103
    SLTIU x0, x6, 119
    SLTI x12, x26, 116
    AUIPC x10, 1048562
    ADDI x26, x0, 26
    SRLI x10, x12, 3
    SRLI x22, x11, 18
    SRL x15, x28, x26
    SRL x21, x26, x19
    SRLI x29, x24, 18
    SUB x14, x15, x11
    SUB x31, x6, x3
    OR x18, x28, x25
    LUI x7, 3
    SLT x10, x29, x31
    AUIPC x11, 0
    XOR x14, x0, x17
    SUB x24, x1, x24
    SRL x12, x31, x7
    SRA x0, x21, x31
    JAL x9, 8
    SLLI x24, x27, 6
    ORI x22, x19, -110
    ADD x5, x2, x28
    ADDI x17, x14, -60
    XORI x31, x4, 41
    XOR x27, x0, x28
    SLLI x0, x21, 13
    XORI x24, x11, 93
    SLT x25, x19, x18
    OR x29, x15, x19
    ADD x15, x14, x18
    SLT x20, x8, x1
    AND x7, x30, x11
    LUI x26, 7
    SLTIU x18, x2, 101
    SLT x13, x27, x11
    XORI x1, x19, 31
    ADDI x25, x4, 127
    SRAI x24, x19, 11
    ANDI x5, x8, 51
    AUIPC x31, 1048563
    LUI x21, 524304
    ADDI x21, x21, 256
    SH x25, 662(x21)
    SRL x5, x28, x28
    SRA x22, x11, x28
    ADDI x4, x5, -36
    SRA x19, x1, x9
    ADDI x31, x2, 64
    ADDI x23, x7, -132
    AUIPC x2, 1048568
    SLTU x17, x11, x16
    ADDI x1, x4, -78
    XORI x24, x15, -138
    SRL x2, x1, x22
    SRL x5, x29, x20
    SLL x23, x18, x28
    JAL x25, 4
    ORI x2, x15, 122
    ADDI x12, x14, -16
    SRAI x20, x13, 22
    ADD x8, x9, x18
    SRLI x12, x16, 24
    LB x18, 34(x21)
    AUIPC x0, 5
    SRLI x28, x14, 16
    SLT x1, x12, x24
    SRLI x16, x10, 31
    ORI x11, x5, 133
    SLTI x22, x4, 146
    SLTI x20, x20, 15
    SLLI x17, x19, 3
    LUI x18, 1048555
    SRL x29, x9, x6
    SRLI x9, x7, 12
    SRLI x14, x28, 9
    SRLI x28, x13, 19
    SLTU x11, x29, x19
    XOR x25, x5, x19
    SRL x24, x20, x30
    SUB x20, x17, x15
    SLLI x2, x19, 3
    XOR x20, x7, x31
    SRA x17, x6, x2
    AUIPC x22, 0
    ADDI x22, x22, 8
    JALR x4, 20(x22)
    AUIPC x4, 0
    ANDI x3, x30, -164
    LUI x18, 1048557
    LUI x12, 13
    SUB x5, x9, x22
    SLTU x21, x27, x16
    SLTIU x31, x21, 30
    LUI x8, 524304
    ADDI x8, x8, 256
    LW x23, 80(x8)
    XOR x19, x14, x6
    LUI x20, 1048569
    AUIPC x23, 0
    SRA x27, x30, x29
    ORI x10, x11, 179
    SRA x3, x22, x25
    ADDI x21, x22, 103
    SLL x18, x25, x29
    SLL x17, x11, x23
    OR x6, x28, x2
    ORI x26, x19, 8
    SUB x21, x13, x5
    SRAI x23, x6, 13
    SRL x18, x5, x20
    JAL x5, 12
    ADD x19, x28, x26
    SLL x15, x28, x31
    LUI x2, 1048575
    SRA x2, x24, x26
    ORI x5, x28, 131
    SUB x4, x11, x25
    SRAI x25, x9, 19
    LH x30, 218(x8)
    SLLI x11, x31, 18
    SRAI x2, x3, 2
    SLTI x25, x10, 152
    XOR x14, x0, x10
    SRAI x31, x29, 9
    SRA x26, x23, x26
    SLTI x1, x14, 80
    SLLI x31, x22, 20
    OR x17, x17, x13
    AUIPC x2, 0
    ADDI x2, x2, 8
    JALR x19, 28(x2)
    AUIPC x8, 16
    ADD x4, x17, x27
    LUI x17, 1048565
    ADDI x13, x10, 48
    SUB x18, x20, x26
    SRL x8, x10, x19
    SRAI x18, x18, 14
    SLTI x23, x28, -144
    SLL x17, x28, x5
    ADD x10, x17, x24
    SLTIU x22, x31, -60
    SRA x29, x11, x0
    ORI x26, x4, -145
    XOR x11, x10, x19
    LB x16, 1122(x8)
    SRLI x26, x21, 13
    SRLI x26, x20, 17
    XORI x1, x7, -185
    LUI x28, 1048562
    OR x29, x13, x10
    XORI x12, x4, 15
    AND x7, x18, x3
    ADD x14, x29, x29
    XORI x12, x25, -188
    ORI x30, x5, 65
    ADD x12, x9, x16
    OR x10, x25, x9
    SLL x11, x0, x10
    SLT x21, x1, x9
    AUIPC x15, 1048573
    SRL x4, x5, x15
    SLTIU x7, x21, 196
    SLTU x14, x22, x26
    SUB x6, x6, x12
    XOR x17, x17, x18
    SRAI x14, x9, 16
    LUI x4, 1048575
    SRAI x19, x6, 23
    SLTU x4, x11, x27
    AUIPC x12, 1048568
    ORI x8, x11, -171
    SLT x30, x4, x21
    SLLI x19, x6, 8
    SRA x20, x24, x17
    SLL x8, x6, x19
    SRLI x7, x26, 1
    SLTIU x31, x22, 135
    SRL x2, x11, x2
    SRAI x26, x8, 22
    ANDI x10, x29, 110
    SLTU x17, x13, x13
    AUIPC x29, 0
    ADDI x29, x29, 8
    JALR x31, 40(x29)
    SLLI x26, x0, 27
    ANDI x22, x28, -188
    SRLI x30, x16, 17
    SLL x12, x22, x23
    SLTIU x29, x17, -174
    SRL x16, x29, x26
    SLTU x22, x31, x29
    SRL x10, x4, x14
    SLTIU x27, x13, -160
    SLTI x26, x7, 151
    SLL x3, x12, x5
    SRL x17, x26, x30
    SRL x16, x20, x10
    SLTIU x12, x30, 34
    SLTU x21, x23, x18
    SRA x2, x24, x26
    SLTIU x20, x1, -63
    SLT x23, x15, x1
    LUI x26, 524304
    ADDI x26, x26, 256
    LB x23, 90(x26)
    OR x31, x15, x22
    SRAI x9, x11, 6
    SRA x16, x31, x25
    SRA x12, x16, x6
    SLLI x10, x6, 0
    ORI x11, x25, 194
    SUB x26, x11, x25
    SLLI x31, x31, 5
    SLLI x25, x20, 20
    SLTI x28, x30, 161
    XOR x3, x2, x24
    SLT x26, x28, x13
    SRA x14, x31, x0
    ANDI x14, x5, 51
    OR x15, x27, x24
    XORI x4, x27, -15
    SLTIU x21, x16, -160
    SLT x28, x20, x17
    ORI x13, x27, 139
    SUB x16, x22, x30
    SUB x18, x29, x27
    OR x12, x15, x19
    SRLI x28, x9, 8
    ORI x2, x19, -43
    SLLI x23, x2, 7
    SUB x1, x13, x27
    ADDI x21, x30, -157
    ADDI x23, x24, 71
    JAL x29, 8
    SLLI x5, x21, 17
    OR x31, x24, x10
    ORI x0, x17, 189
    LUI x17, 1048557
    XORI x22, x5, 69
    XORI x13, x14, -61
    SRL x12, x22, x28
    SRL x27, x14, x14
    SRAI x21, x2, 26
    SLTIU x20, x2, 55
    ADDI x1, x0, 67
    SRLI x20, x22, 15
    AUIPC x7, 1048568
    SRLI x22, x23, 7
    ADD x20, x3, x1
    AUIPC x0, 1
    SLT x25, x21, x12
    LUI x18, 524304
    ADDI x18, x18, 256
    LHU x3, 150(x18)
    SRL x4, x13, x18
    SLTI x29, x22, 114
    SRL x29, x13, x29
    ADD x14, x23, x29
    SRAI x23, x25, 10
    SRAI x2, x10, 18
    XORI x14, x11, 112
    SRLI x22, x2, 14
    SLTI x9, x28, 168
    ADD x17, x12, x7
    ADDI x23, x19, 195
    AUIPC x21, 3
    OR x24, x3, x21
    OR x12, x15, x2
    SLT x10, x25, x29
    ADDI x30, x7, 33
    SRLI x11, x26, 2
    SLTU x1, x26, x27
    ORI x6, x16, 75
    XORI x20, x19, -163
    XORI x21, x9, -175
    BLTU x6, x9, 40
    XOR x15, x10, x5
    SRL x12, x20, x26
    LH x19, 82(x18)
    LUI x23, 1048566
    SRLI x16, x21, 2
    AND x7, x30, x27
    SRAI x28, x3, 15
    AUIPC x2, 1048561
    SRLI x28, x4, 23
    SRA x31, x8, x0
    ANDI x30, x7, -120
    SRAI x20, x0, 7
    ADD x13, x10, x8
    SRAI x6, x22, 27
    OR x31, x11, x5
    JAL x29, 12
    SLT x25, x6, x31
    ADDI x24, x1, -57
    LUI x24, 3
    ADD x7, x13, x29
    SLTU x10, x6, x30
    SLTU x14, x25, x13
    SLTIU x10, x11, 164
    ADD x11, x9, x31
    LB x9, 225(x18)
    LUI x3, 7
    ADD x13, x2, x4
    SLTIU x15, x20, -94
    SLLI x19, x14, 10
    ADDI x21, x29, 153
    AUIPC x5, 10
    SRL x10, x28, x12
    XOR x3, x11, x23
    SRAI x16, x4, 24
    ADD x20, x8, x12
    SLTI x7, x15, 192
    SLTU x29, x14, x3
    SRA x30, x4, x29
    SLTIU x22, x14, -64
    SRL x11, x2, x30
    ANDI x8, x24, 41
    SUB x21, x13, x7
    AND x18, x10, x22
    SRLI x8, x31, 31
    SRA x22, x2, x16
    ADD x10, x3, x5
    SLT x11, x9, x15
    SLTIU x16, x6, -152
    SLTU x17, x6, x29
    ORI x31, x8, -123
    SLTIU x31, x23, 50
    SLTI x15, x31, 85
    SLTI x3, x18, 18
    SUB x29, x31, x20
    SLTU x22, x2, x6
    AUIPC x0, 4
    SLTIU x15, x5, 198
    AUIPC x10, 0
    ADDI x10, x10, 8
    JALR x2, 4(x10)
    SLTI x10, x11, 92
    ANDI x30, x5, -60
    AUIPC x7, 27
    SRLI x21, x6, 13
    AUIPC x29, 2
    ADD x17, x3, x21
    LUI x29, 524304
    ADDI x29, x29, 256
    SH x31, 1182(x29)
    SLLI x8, x26, 18
    SLTIU x19, x3, -92
    SLTI x22, x9, 5
    ADD x27, x20, x5
    AUIPC x4, 8
    ORI x20, x2, -45
    XOR x14, x9, x16
    SLTU x17, x5, x8
    ORI x10, x17, 140
    ANDI x15, x14, 184
    ANDI x24, x28, 128
    XOR x19, x1, x31
    LUI x12, 1048565
    ADDI x10, x15, 25
    SLTI x15, x27, -162
    LUI x16, 3
    ORI x12, x13, -126
    SLT x26, x7, x9
    SLT x2, x25, x15
    XORI x4, x3, -38
    SLTIU x10, x30, 112
    AUIPC x3, 2
    SLL x31, x17, x12
    AUIPC x13, 1048573
    SLL x26, x30, x1
    SLL x2, x29, x6
    XORI x4, x10, -177
    AUIPC x29, 1048571
    XOR x10, x26, x26
    LUI x18, 1048563
    XORI x21, x29, -109
    OR x12, x27, x25
    XOR x16, x9, x12
    SRAI x10, x24, 26
    SLL x17, x22, x27
    OR x31, x19, x12
    SRAI x2, x5, 27
    XOR x2, x11, x5
    BEQ x30, x6, 32
    ANDI x16, x30, 8
    SRLI x9, x1, 9
    LUI x17, 1048571
    AUIPC x31, 1048572
    SLTU x18, x28, x14
    XOR x1, x28, x9
    SLL x20, x4, x21
    ADD x12, x14, x5
    SLTI x13, x10, 21
    ORI x31, x27, -166
    SLTU x25, x18, x27
    LUI x16, 524304
    ADDI x16, x16, 256
    LW x2, 112(x16)
    ANDI x13, x13, 45
    ADD x23, x17, x15
    SLTI x12, x18, -46
    LUI x11, 1048575
    SLLI x7, x5, 16
    SRLI x23, x10, 16
    SRAI x11, x18, 14
    ADDI x9, x7, -134
    SLTU x27, x18, x4
    XOR x13, x11, x8
    OR x13, x18, x14
    XORI x20, x1, -39
    AUIPC x28, 1048552
    SRLI x29, x8, 18
    SLTIU x16, x0, 63
    SUB x19, x3, x12
    SRAI x19, x6, 14
    LUI x25, 5
    SLTI x26, x14, 89
    LUI x20, 9
    ADD x14, x27, x22
    XOR x13, x4, x6
    SRAI x30, x24, 26
    JAL x23, 28
    SLTI x29, x16, -153
    LUI x18, 1048568
    AUIPC x9, 1048572
    XOR x23, x0, x24
    SLT x9, x12, x18
    SRLI x4, x3, 9
    XOR x5, x7, x31
    OR x17, x18, x7
    AND x0, x27, x24
    SLLI x20, x14, 31
    ORI x26, x18, -192
    ORI x3, x27, 73
    SUB x24, x9, x3
    ADD x12, x17, x14
    LUI x9, 524304
    ADDI x9, x9, 256
    SB x20, 1384(x9)
    SLT x17, x1, x9
    SLT x1, x15, x6
    ANDI x15, x31, 60
    AUIPC x25, 1048566
    ORI x10, x27, 117
    SRLI x27, x9, 18
    SLL x2, x31, x15
    SLTU x17, x24, x6
    SRLI x24, x1, 18
    BEQ x24, x27, 20
    ORI x28, x23, -114
    ANDI x3, x5, -133
    SLL x28, x4, x9
    SLTI x27, x20, -154
    ANDI x26, x4, 187
    SH x21, 932(x9)
    SRLI x8, x8, 6
    SUB x10, x26, x21
    JAL x29, 8
    SLT x25, x5, x18
    SRAI x11, x29, 30
    OR x16, x16, x13
    ANDI x8, x2, -4
    SB x9, 1754(x9)
    AND x4, x10, x23
    XORI x16, x2, -166
    XORI x23, x31, -176
    BEQ x15, x20, 12
    LUI x12, 16
    ADD x5, x20, x21
    SLTIU x27, x9, -124
    ORI x5, x9, -138
    SRLI x15, x2, 16
    XORI x16, x5, 100
    SRLI x30, x20, 20
    ADDI x7, x7, 79
    SRA x10, x6, x29
    SRLI x5, x6, 18
    ORI x22, x22, -24
    SUB x4, x0, x2
    SLLI x25, x12, 25
    AUIPC x0, 1048563
    XOR x1, x12, x31
    ADD x11, x27, x28
    AND x20, x27, x15
    SRLI x30, x22, 22
    SRAI x26, x3, 20
    SW x0, 1720(x9)
    ADD x31, x27, x12
    SLTIU x13, x24, 19
    SRAI x1, x7, 25
    SRLI x31, x21, 21
    SLL x22, x4, x28
    SLTI x8, x7, 28
    XOR x21, x10, x14
    AUIPC x2, 1048560
    OR x16, x14, x19
    SRL x6, x31, x9
    AUIPC x3, 12
    ADDI x11, x3, -32
    AUIPC x13, 0
    ADDI x13, x13, 8
    JALR x26, 24(x13)
    ADDI x18, x24, 52
    SLL x21, x29, x26
    LUI x23, 8
    SRLI x21, x26, 22
    SLL x13, x7, x25
    OR x15, x4, x7
    ADDI x31, x14, 52
    ADDI x21, x23, -156
    SRL x14, x14, x25
    SRA x11, x9, x3
    OR x18, x13, x31
    SLLI x13, x28, 24
    SLTIU x31, x17, 159
    ADDI x15, x7, 63
    SLLI x31, x25, 20
    ORI x22, x25, -94
    SRL x26, x4, x26
    ADD x3, x21, x16
    SLTU x5, x11, x28
    AUIPC x18, 6
    SRA x0, x9, x14
    SLTI x27, x16, -120
    ANDI x14, x8, 54
    ANDI x11, x3, 26
    LUI x25, 1048572
    LH x16, 1288(x9)
    SRAI x8, x6, 13
    AND x27, x22, x19
    AUIPC x25, 3
    LUI x5, 20
    SLTI x28, x16, 150
    SRAI x3, x0, 15
    ADDI x29, x12, 199
    LUI x14, 1048571
    SLT x18, x21, x7
    AND x21, x20, x20
    AUIPC x16, 0
    ADDI x16, x16, 8
    JALR x22, 8(x16)
    ADD x10, x11, x7
    OR x28, x18, x14
    LUI x23, 1048554
    AND x15, x17, x18
    SLT x0, x3, x21
    XOR x10, x4, x14
    SUB x13, x29, x25
    SLL x25, x13, x11
    XORI x0, x29, -156
    ADDI x5, x4, 131
    ANDI x6, x4, 25
    ORI x26, x20, -198
    AUIPC x5, 1048555
    SB x25, 1932(x9)
    SLTIU x24, x28, 143
    ADDI x25, x10, 39
    ADDI x10, x15, -142
    SRLI x30, x9, 20
    SLLI x20, x20, 0
    SUB x11, x8, x30
    OR x23, x25, x27
    ANDI x16, x16, -35
    SLLI x13, x30, 22
    SRAI x16, x8, 28
    SRL x27, x9, x28
    AND x14, x3, x10
    SUB x0, x2, x12
    SRL x17, x27, x30
    AUIPC x14, 1048565
    ORI x17, x10, -9
    LUI x27, 1048559
    ANDI x7, x15, 15
    SRAI x21, x1, 31
    LUI x15, 1048562
    LUI x16, 8
    XORI x17, x26, -54
    ADDI x24, x29, 139
    SRL x22, x20, x15
    SRLI x22, x22, 8
    SLL x15, x6, x21
    AND x23, x23, x4
    SRAI x19, x12, 0
    XORI x14, x15, 117
    ORI x13, x11, 168
    SLLI x17, x15, 28
    BNE x4, x5, 40
    AUIPC x7, 6
    SUB x24, x0, x1
    ADD x16, x11, x2
    OR x15, x28, x4
    LUI x19, 1
    SLT x23, x30, x31
    XOR x4, x21, x23
    SLTU x29, x17, x10
    ANDI x13, x13, -39
    AUIPC x3, 7
    AUIPC x3, 1048567
    SB x7, 204(x9)
    XOR x23, x5, x0
    SRLI x18, x7, 3
    ADDI x4, x0, -99
    SRLI x3, x14, 13
    SRL x27, x5, x27
    SRL x11, x23, x23
    AND x15, x20, x3
    SLTU x21, x13, x20
    SRAI x14, x4, 7
    XORI x30, x31, -160
    AUIPC x16, 16
    ORI x16, x5, -194
    LUI x23, 1048570
    SRA x26, x26, x3
    SLTIU x27, x23, -94
    ADD x30, x0, x1
    AND x20, x17, x20
    ADDI x23, x7, 50
    BNE x17, x1, 4
    AUIPC x17, 1
    SW x16, 932(x9)
    SRAI x16, x14, 20
    SUB x27, x20, x23
    SLTIU x0, x13, -96
    SLTI x20, x16, 197
    OR x7, x25, x2
    SRA x3, x0, x17
    SRAI x31, x19, 26
    XORI x3, x31, 181
    XOR x11, x19, x25
    SLTI x7, x18, 40
    ADDI x31, x25, 185
    SLTI x2, x15, -113
    AUIPC x9, 0
    ADDI x9, x9, 8
    JALR x12, 12(x9)
    ORI x18, x12, -3
    SLT x25, x4, x17
    SRAI x2, x10, 1
    ANDI x28, x19, 58
    ADDI x10, x8, -136
    SLLI x3, x0, 24
    SRA x9, x16, x22
    AND x0, x25, x31
    AUIPC x19, 18
    SLTI x3, x16, -169
    SUB x30, x21, x24
    OR x9, x31, x19
    SLT x12, x10, x24
    XORI x26, x30, 186
    SUB x18, x18, x23
    AND x17, x26, x10
    SRA x22, x14, x24
    SLTU x8, x21, x10
    SRL x31, x4, x0
    ADD x0, x17, x4
    LUI x4, 524304
    ADDI x4, x4, 256
    LH x17, 126(x4)
    ADD x3, x20, x12
    LUI x30, 2
    SLTU x13, x17, x15
    SLTU x2, x16, x5
    ANDI x23, x8, 102
    SRA x9, x18, x15
    AUIPC x19, 1048554
    SLTIU x10, x17, -56
    SLTU x14, x11, x28
    SRL x26, x30, x28
    AND x5, x18, x18
    SLT x15, x29, x0
    SRL x27, x15, x20
    SRL x19, x24, x26
    JAL x5, 4
    AND x27, x4, x29
    SLTI x15, x12, -149
    AUIPC x9, 3
    ANDI x31, x14, 91
    SUB x12, x21, x8
    SLLI x19, x18, 4
    SLL x15, x16, x4
    XORI x18, x16, 61
    LUI x20, 17
    SLTIU x23, x23, -98
    LH x19, 138(x4)
    ORI x7, x16, 23
    OR x11, x15, x16
    OR x9, x24, x30
    LUI x20, 1048564
    SLL x8, x31, x21
    ADDI x1, x22, 53
    SRLI x7, x22, 24
    OR x10, x22, x21
    OR x10, x18, x24
    SUB x4, x29, x6
    SRAI x17, x7, 10
    XOR x0, x14, x0
    SLTIU x15, x24, 51
    SRLI x20, x3, 0
    SLTU x28, x11, x9
    SLTU x22, x11, x16
    SLTU x24, x3, x28
    XORI x27, x22, 86
    AUIPC x14, 1
    SLL x25, x12, x13
    ADD x3, x12, x0
    SRL x20, x20, x27
    LUI x5, 1048575
    SLTIU x10, x12, 173
    SLT x17, x27, x5
    SRAI x28, x11, 28
    SLTI x9, x18, -113
    BGE x31, x20, 28
    SRL x6, x0, x29
    AUIPC x8, 1048573
    SRLI x15, x23, 13
    ADD x31, x22, x27
    SLLI x9, x29, 24
    ADDI x9, x0, 97
    AND x13, x23, x21
    ADDI x20, x16, -25
    LUI x11, 1048570
    SLL x4, x14, x1
    ADDI x15, x14, 92
    SUB x12, x19, x11
    SUB x30, x14, x1
    ADD x0, x9, x30
    SRL x29, x25, x10
    ADD x22, x10, x30
    SRL x14, x10, x25
    AUIPC x15, 14
    SRA x12, x21, x0
    SLLI x13, x12, 10
    SUB x13, x26, x20
    LUI x21, 1048563
    LUI x14, 524304
    ADDI x14, x14, 256
    SB x1, 136(x14)
    ORI x10, x25, -126
    SRAI x10, x5, 10
    ADD x17, x21, x29
    XORI x25, x6, 39
    SRLI x15, x13, 5
    LUI x17, 1048568
    SLT x20, x28, x5
    SRAI x25, x2, 0
    SLLI x2, x16, 29
    JAL x31, 28
    SRAI x12, x2, 6
    SRAI x9, x24, 10
    XOR x3, x24, x25
    SRL x13, x4, x30
    SRLI x14, x13, 19
    SRA x12, x3, x20
    SUB x15, x18, x4
    OR x18, x5, x24
    AUIPC x1, 1048560
    SLTI x1, x31, 175
    SLTIU x31, x8, 132
    SLL x23, x15, x31
    SLL x14, x4, x18
    SRLI x5, x24, 25
    SLTIU x28, x17, 64
    ADDI x13, x3, 191
    SLT x26, x18, x24
    ANDI x29, x31, 14
    SRAI x16, x30, 10
    AUIPC x7, 7
    XOR x13, x31, x27
    XOR x9, x22, x14
    LUI x3, 524304
    ADDI x3, x3, 256
    SH x11, 688(x3)
    SRAI x0, x21, 8
    AUIPC x8, 0
    ADDI x8, x8, 8
    JALR x21, 12(x8)
    ADDI x31, x0, -40
    SLTI x14, x27, 136
    AUIPC x20, 1048567
    SLLI x20, x20, 19
    ANDI x26, x12, 24
    SRAI x11, x0, 3
    SLTU x14, x16, x4
    SLLI x3, x5, 9
    XOR x16, x20, x7
    ORI x8, x26, -97
    ORI x21, x19, -85
    SLL x23, x22, x9
    OR x29, x15, x19
    SLTIU x14, x11, 124
    SLTU x29, x13, x15
    XORI x19, x6, -1
    LUI x18, 524304
    ADDI x18, x18, 256
    LHU x27, 248(x18)
    AUIPC x6, 1048560
    AUIPC x10, 1048573
    SLT x0, x18, x7
    SLT x25, x9, x9
    SLT x31, x17, x12
    SRA x13, x13, x13
    OR x18, x15, x2
    LUI x3, 3
    LUI x24, 17
    SUB x20, x4, x5
    ORI x18, x7, 167
    OR x27, x7, x31
    LUI x10, 1048556
    ANDI x5, x19, 20
    XORI x4, x20, -3
    SLL x16, x26, x31
    SRL x1, x9, x18
    LUI x1, 1048567
    ORI x1, x29, -149
    SUB x13, x19, x21
    SLT x23, x13, x13
    SRL x17, x15, x0
    XORI x3, x9, 86
    SLTU x12, x26, x16
    XOR x0, x4, x8
    XOR x2, x9, x24
    ORI x11, x7, -11
    ORI x6, x10, 172
    JAL x15, 16
    SLLI x30, x31, 31
    SUB x0, x5, x16
    ADDI x8, x6, -144
    SLTI x0, x25, -97
    ADDI x0, x14, -21
    ADD x2, x26, x10
    SRA x31, x18, x26
    XOR x1, x6, x17
    ANDI x27, x16, -187
    SLTU x29, x15, x20
    AUIPC x4, 8
    LUI x11, 4
    ORI x2, x13, -158
    LUI x3, 1
    SRL x11, x8, x28
    OR x15, x14, x20
    XORI x13, x9, 157
    AUIPC x22, 1
    OR x27, x27, x22
    LUI x31, 6
    LUI x29, 524304
    ADDI x29, x29, 256
    LW x8, 120(x29)
    SLLI x21, x23, 29
    AUIPC x22, 1048564
    OR x28, x18, x29
    ADD x1, x18, x30
    ANDI x11, x14, 117
    SRLI x8, x24, 7
    XOR x14, x10, x16
    ANDI x12, x8, -170
    SLLI x11, x19, 3
    XORI x10, x23, 107
    SLL x0, x31, x13
    XOR x19, x30, x9
    XOR x28, x27, x31
    SLLI x12, x27, 19
    LUI x8, 1048567
    SLL x15, x0, x5
    AND x4, x31, x24
    XORI x1, x2, -89
    XORI x18, x1, 54
    SLTU x13, x4, x4
    LUI x15, 1048566
    SRA x29, x8, x0
    OR x20, x29, x20
    ANDI x17, x17, 157
    BGEU x21, x28, 4
    SRA x5, x13, x18
    AND x2, x4, x5
    ADDI x1, x26, -200
    SRLI x27, x30, 21
    SLTU x18, x9, x24
    ADDI x4, x17, -52
    ADDI x8, x17, -146
    SRAI x19, x29, 19
    SUB x5, x10, x6
    SRL x12, x13, x15
    SRL x14, x12, x25
    OR x6, x15, x16
    LUI x21, 1048561
    LUI x12, 524304
    ADDI x12, x12, 256
    SH x14, 330(x12)
    SRLI x20, x12, 2
    XOR x11, x30, x14
    SLT x25, x25, x16
    SLL x14, x21, x16
    SLTU x29, x10, x12
    LUI x1, 1048570
    AND x9, x11, x6
    ADD x31, x24, x8
    SRAI x1, x12, 22
    SLTIU x7, x14, -49
    AUIPC x20, 1048563
    SRL x20, x19, x26
    SRLI x30, x12, 13
    AUIPC x17, 1048568
    SRAI x13, x22, 6
    XORI x7, x2, 70
    SRLI x13, x31, 4
    SLTIU x12, x15, 68
    AUIPC x18, 1048573
    ADDI x22, x7, -68
    XOR x14, x0, x0
    ADDI x16, x9, -78
    SRL x16, x19, x25
    LUI x21, 19
    LUI x21, 19
    SRL x27, x3, x24
    ADD x27, x24, x8
    SLTI x30, x1, -108
    ORI x28, x0, 155
    SRA x19, x29, x3
    JAL x31, 4
    SUB x2, x23, x16
    SLTU x20, x5, x20
    XOR x10, x16, x14
    ANDI x15, x0, -138
    ADDI x9, x24, -30
    OR x19, x7, x13
    SUB x1, x1, x10
    SLL x16, x0, x14
    SLT x24, x16, x13
    LUI x17, 524304
    ADDI x17, x17, 256
    SB x25, 2036(x17)
    SLTU x9, x10, x14
    SLLI x10, x24, 13
    ORI x25, x14, 20
    SRL x8, x7, x5
    SLTU x1, x16, x12
    LUI x3, 15
    SRAI x19, x4, 0
    ORI x2, x9, -8
    SLL x14, x1, x1
    SLTIU x22, x20, 66
    XORI x8, x30, 10
    SLTI x18, x22, -125
    JAL x28, 36
    ANDI x30, x24, -76
    SLT x14, x19, x1
    ADD x26, x0, x21
    XOR x11, x20, x11
    SLTIU x14, x10, -150
    SRA x12, x21, x20
    SLL x8, x2, x16
    ORI x19, x29, -33
    SRAI x28, x30, 13
    ORI x18, x12, -53
    SLL x15, x9, x30
    SRLI x18, x14, 12
    ORI x23, x30, 31
    OR x15, x19, x28
    SRAI x12, x25, 1
    ANDI x6, x27, 114
    SRLI x6, x7, 14
    SLL x10, x29, x4
    ORI x9, x23, -155
    XOR x27, x9, x2
    SLTU x19, x8, x23
    XOR x8, x1, x27
    ADD x23, x30, x26
    SH x12, 272(x17)
    OR x28, x8, x2
    LUI x17, 1048552
    SRL x1, x30, x26
    SRAI x25, x12, 16
    SRAI x12, x12, 0
    ANDI x14, x27, -32
    ADDI x29, x3, -28
    ADD x31, x16, x26
    SRLI x9, x1, 28
    SLT x8, x10, x11
    SLLI x30, x23, 31
    SLTI x21, x18, -137
    ORI x2, x21, 154
    SLLI x11, x27, 6
    XOR x30, x26, x20
    SLTI x14, x20, 12
    ANDI x27, x25, -187
    ANDI x11, x8, 131
    OR x13, x15, x2
    SUB x21, x17, x15
    AUIPC x10, 0
    ADDI x10, x10, 8
    JALR x2, 4(x10)
    SRAI x24, x30, 10
    LUI x19, 524304
    ADDI x19, x19, 256
    SH x28, 562(x19)
    XORI x26, x23, 113
    XORI x22, x10, -181
    JAL x6, 8
    SLT x30, x29, x5
    SLL x31, x20, x20
    SRL x19, x31, x2
    SLL x13, x13, x1
    SRA x30, x28, x22
    SLTI x31, x18, 30
    LUI x19, 524304
    ADDI x19, x19, 256
    LBU x30, 58(x19)
    ANDI x28, x20, 10
    ORI x22, x8, 168
    SRA x13, x23, x14
    SUB x19, x14, x4
    SLL x2, x4, x26
    
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
