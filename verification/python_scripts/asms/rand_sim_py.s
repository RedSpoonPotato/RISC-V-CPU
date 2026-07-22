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

    ORI x12, x10, 127
    XOR x22, x18, x12
    XORI x8, x11, -190
    SRL x14, x16, x21
    AUIPC x23, 8192
    SLTU x18, x15, x16
    SLLI x9, x6, -24
    ORI x21, x0, -113
    AUIPC x1, 4096
    ADD x15, x21, x5
    ORI x4, x15, -183
    JAL x17, 12
    LUI x20, 69632
    SRAI x10, x7, 35
    SLTU x1, x1, x4
    ANDI x9, x14, 127
    SRLI x12, x20, 68
    SLLI x15, x23, -188
    AND x2, x13, x13
    SLTI x30, x15, 91
    LUI x13, -2147418112
    ADDI x13, x13, 256
    LW x16, 232(x13)
    OR x12, x0, x22
    XOR x9, x7, x21
    SRL x28, x31, x21
    SLTI x14, x20, -99
    SRL x5, x20, x15
    SRAI x4, x11, -35
    AND x17, x1, x14
    XOR x22, x16, x10
    SRA x9, x13, x30
    ORI x22, x23, -128
    OR x19, x15, x20
    SUB x22, x8, x6
    AUIPC x18, -45056
    ORI x27, x5, 6
    SLL x7, x17, x6
    SRL x30, x31, x17
    ADDI x12, x13, 101
    SLTU x1, x27, x0
    AND x28, x31, x12
    SLLI x24, x19, 172
    AUIPC x4, -45056
    SRL x7, x22, x31
    AND x21, x1, x13
    SLTI x8, x21, -198
    SRA x29, x11, x23
    SRA x22, x4, x13
    BGEU x8, x27, 32
    SUB x23, x29, x13
    XOR x15, x27, x0
    SRAI x20, x16, -127
    SB x10, 1742(x13)
    SRAI x1, x21, 62
    AUIPC x16, 24576
    SLL x0, x8, x16
    SLLI x30, x6, 177
    SLT x21, x21, x4
    AUIPC x7, -24576
    SLTU x14, x2, x27
    SRLI x20, x16, 60
    SLTUI x30, x12, -35
    AND x20, x21, x19
    SRLI x25, x24, -79
    ORI x21, x1, 197
    SLL x31, x9, x21
    XOR x9, x12, x27
    LUI x10, 16384
    AUIPC x13, 0
    ADDI x13, x13, 8
    JALR x1, 12(x13)
    SLTI x24, x20, 9
    SRLI x27, x28, -199
    LUI x6, -24576
    SLL x10, x27, x1
    SLTU x30, x30, x12
    SLTU x25, x28, x29
    OR x27, x28, x8
    SLTUI x15, x21, 7
    SH x12, 76(x27)
    SRLI x26, x27, 14
    AND x0, x1, x4
    ORI x12, x2, 186
    SRLI x27, x6, -69
    SUB x12, x20, x1
    SLL x2, x22, x15
    ADDI x17, x8, 150
    SRAI x21, x10, -8
    ADD x18, x13, x1
    AUIPC x13, 20480
    SRLI x1, x19, 81
    SRLI x4, x24, 72
    AUIPC x10, 0
    ADDI x10, x10, 8
    JALR x30, 28(x10)
    SRA x19, x30, x15
    ADDI x2, x18, -75
    SLLI x0, x19, -199
    SRL x28, x8, x18
    SLT x14, x18, x27
    ADDI x24, x8, -125
    LUI x18, -81920
    SLL x14, x20, x9
    SLTUI x29, x28, 178
    XOR x12, x12, x19
    SLTU x12, x4, x16
    OR x4, x23, x16
    SLLI x31, x11, 111
    SLT x10, x13, x21
    AND x2, x25, x4
    XORI x10, x2, 183
    SLTUI x19, x6, 15
    XOR x14, x10, x11
    SRL x14, x31, x19
    SW x0, 580(x28)
    LUI x31, -16384
    AND x6, x28, x19
    SLTUI x26, x20, -163
    LUI x29, 0
    XORI x21, x22, 56
    ADDI x15, x23, -30
    SRAI x13, x0, 58
    ORI x25, x18, 56
    SRA x31, x7, x5
    AUIPC x19, 0
    ADDI x19, x19, 8
    JALR x25, 40(x19)
    SLTU x9, x13, x27
    ADDI x10, x11, -22
    ANDI x15, x7, -96
    SLTUI x23, x0, 142
    SRA x14, x24, x4
    SLLI x7, x5, 4
    ADD x1, x7, x20
    AND x21, x18, x0
    AUIPC x19, 12288
    SLTI x21, x18, -164
    SLLI x25, x14, -166
    SLTI x14, x8, -72
    ANDI x30, x26, 33
    XORI x27, x13, 142
    SLTUI x15, x0, 54
    ADDI x3, x17, 193
    SLTI x16, x4, 117
    ADDI x6, x31, -38
    ANDI x2, x1, -69
    LW x25, 0(x28)
    SRL x17, x10, x9
    SUB x22, x25, x28
    ORI x8, x0, -40
    XORI x2, x30, 103
    SLTUI x24, x28, 37
    SRA x18, x29, x24
    SRA x5, x28, x1
    ANDI x8, x13, -72
    LUI x21, -16384
    SUB x10, x1, x4
    XORI x15, x5, 79
    SLTI x25, x17, -166
    SRA x21, x10, x18
    SRA x15, x14, x25
    SRA x8, x29, x14
    SRLI x24, x22, -55
    AND x0, x30, x14
    SLT x30, x26, x27
    SRAI x17, x9, -167
    ADDI x13, x26, 156
    AUIPC x7, 53248
    SUB x7, x29, x11
    OR x4, x0, x3
    BNE x6, x31, 28
    SLT x30, x29, x12
    ORI x9, x19, 76
    SRAI x29, x25, -43
    SLL x7, x26, x18
    SRL x11, x26, x30
    SLT x8, x10, x19
    SRA x5, x16, x26
    XORI x16, x15, 74
    XORI x30, x8, -87
    SRA x5, x27, x16
    OR x20, x3, x6
    SLL x14, x13, x25
    AND x19, x24, x29
    SRA x10, x20, x15
    AUIPC x27, 8192
    ORI x18, x1, -110
    SH x6, 714(x9)
    ANDI x19, x2, -163
    OR x6, x7, x5
    XOR x26, x8, x1
    SLL x12, x27, x6
    ADDI x30, x9, -124
    SLT x9, x25, x12
    SRL x14, x24, x25
    ANDI x24, x0, -163
    SRAI x13, x4, 108
    SLTI x25, x9, 165
    SLLI x11, x8, -190
    JAL x3, 12
    ORI x14, x1, 36
    SRA x3, x6, x7
    AUIPC x26, -86016
    SUB x1, x15, x22
    SLLI x31, x10, -25
    XORI x11, x11, 186
    SLTUI x21, x8, -142
    SRA x0, x0, x27
    LBU x7, 194(x28)
    SLTU x9, x10, x23
    OR x2, x22, x16
    ORI x31, x1, 33
    XORI x4, x31, 74
    LUI x28, 57344
    AUIPC x10, 24576
    XOR x5, x31, x17
    ANDI x12, x25, -183
    AUIPC x21, 40960
    SLLI x9, x28, -73
    SLTUI x28, x14, 199
    AUIPC x12, 16384
    SRLI x10, x16, 123
    ADD x31, x30, x22
    SRLI x15, x25, 76
    SRAI x28, x6, -11
    SRA x29, x13, x1
    XOR x6, x22, x6
    ANDI x9, x21, -129
    OR x9, x27, x17
    ADD x19, x11, x7
    SLTU x21, x27, x0
    SRL x19, x12, x3
    SLTI x5, x22, -66
    SLTI x11, x16, 23
    ADDI x7, x22, 60
    LUI x5, -24576
    SLTI x22, x8, 13
    SRAI x12, x5, -196
    SRAI x2, x17, -122
    AUIPC x15, 0
    ADDI x15, x15, 8
    JALR x25, 12(x15)
    ADD x1, x12, x4
    LUI x24, -8192
    XOR x5, x18, x31
    SRAI x6, x20, 163
    SRLI x0, x22, 60
    OR x1, x19, x15
    SRA x2, x23, x15
    SLL x20, x24, x17
    ADDI x20, x14, -193
    SRLI x0, x23, -132
    ADDI x31, x23, 170
    AND x12, x15, x16
    ORI x20, x29, 30
    LUI x13, 20480
    OR x30, x18, x31
    SLLI x9, x3, 49
    ADD x17, x8, x17
    SLTI x2, x15, 58
    ADD x5, x26, x3
    LUI x3, -2147418112
    ADDI x3, x3, 256
    SH x14, 1016(x3)
    SLTU x18, x19, x8
    SLT x29, x21, x18
    SRL x28, x10, x19
    AND x0, x7, x0
    XORI x9, x5, -11
    LUI x11, -16384
    SLTUI x26, x15, -58
    AUIPC x16, -20480
    SLTU x17, x6, x9
    SLTU x26, x2, x17
    ANDI x11, x11, -130
    SRA x10, x29, x14
    LUI x21, 8192
    ORI x19, x15, -43
    SLTI x3, x25, -67
    SRA x10, x4, x7
    SRLI x26, x30, -135
    SLLI x28, x30, 74
    OR x13, x24, x0
    JAL x1, 16
    ADD x18, x13, x3
    AND x11, x1, x29
    ORI x31, x20, -180
    SLL x31, x26, x1
    LUI x5, -2147418112
    ADDI x5, x5, 256
    LW x18, 20(x5)
    ANDI x5, x24, 144
    SRLI x8, x21, -86
    SUB x28, x18, x5
    ADD x28, x26, x20
    XORI x12, x22, -39
    SRL x18, x26, x30
    LUI x2, 20480
    SLTUI x28, x13, -143
    OR x22, x23, x6
    SLT x23, x4, x4
    ORI x27, x0, -86
    ADDI x7, x14, -128
    SRLI x1, x18, 101
    SLLI x14, x29, -120
    SRAI x22, x25, -57
    SLTI x19, x5, -51
    SLTUI x30, x6, 92
    SUB x10, x27, x28
    AUIPC x2, 0
    ADDI x2, x2, 8
    JALR x27, 40(x2)
    SLLI x29, x31, 35
    SRLI x0, x3, -179
    SLTU x17, x16, x20
    SRAI x1, x17, 79
    XOR x31, x25, x1
    XORI x10, x25, -82
    XOR x7, x30, x25
    ANDI x29, x28, 185
    SRAI x7, x25, -116
    SUB x26, x18, x15
    AND x28, x31, x13
    SLTU x7, x27, x4
    SLTU x26, x21, x31
    SRLI x4, x5, 35
    SUB x10, x17, x14
    OR x8, x16, x9
    ADDI x24, x24, 53
    SLTI x6, x24, 139
    SRA x17, x1, x18
    XORI x9, x8, -69
    XORI x29, x17, 47
    SUB x7, x6, x26
    LUI x15, -2147418112
    ADDI x15, x15, 256
    SB x21, 10(x15)
    ANDI x12, x5, -33
    ORI x5, x1, -181
    ADD x6, x19, x30
    XOR x18, x28, x10
    SRA x13, x12, x23
    SLT x31, x2, x17
    XOR x24, x25, x19
    OR x17, x27, x22
    XOR x17, x30, x30
    SLL x11, x25, x30
    SLLI x12, x16, -82
    ADD x18, x6, x12
    SLLI x24, x6, -15
    SLTUI x18, x1, -172
    XORI x5, x14, 150
    LUI x16, 57344
    SRAI x10, x16, 112
    SLT x8, x21, x24
    JAL x20, 4
    SUB x21, x25, x14
    OR x22, x19, x17
    LUI x18, -20480
    ADD x6, x18, x26
    SLLI x22, x23, 88
    SLLI x31, x19, 105
    ORI x3, x0, -125
    ANDI x9, x24, -176
    AND x11, x1, x0
    SRL x21, x21, x22
    SRLI x10, x1, -188
    SRA x8, x30, x24
    SLL x8, x23, x15
    ADDI x16, x18, -30
    SLTU x12, x10, x1
    SB x30, 1349(x15)
    ADD x23, x13, x31
    SRA x8, x14, x18
    AUIPC x12, 118784
    SRA x29, x15, x16
    SLTU x8, x22, x9
    SRL x10, x2, x7
    ANDI x8, x31, 141
    SLL x31, x7, x4
    ADD x19, x2, x5
    SLLI x0, x18, -177
    SLTU x17, x14, x14
    SLTU x28, x5, x16
    SRLI x26, x0, 55
    SLTUI x18, x23, 32
    SRLI x13, x8, -106
    SLLI x11, x13, -16
    ADDI x3, x8, 179
    SUB x11, x14, x0
    XOR x29, x19, x27
    SLT x30, x30, x1
    SLL x18, x25, x21
    SLL x28, x16, x28
    ANDI x2, x4, -104
    LUI x3, -69632
    ORI x26, x16, -85
    SUB x12, x13, x14
    SLLI x1, x28, 159
    XORI x7, x15, -41
    SRAI x26, x3, -149
    AND x13, x6, x29
    AUIPC x23, 0
    ADDI x23, x23, 8
    JALR x14, 32(x23)
    SLTI x1, x23, -40
    SLT x28, x6, x24
    SLLI x25, x1, 2
    SRA x8, x25, x19
    AUIPC x17, -20480
    XORI x8, x7, 86
    SRAI x24, x6, 127
    XOR x27, x24, x0
    SRL x18, x17, x27
    SLTU x0, x13, x13
    SRL x18, x16, x2
    SLLI x15, x27, 200
    ADD x0, x13, x0
    LUI x26, -2147418112
    ADDI x26, x26, 256
    LHU x16, 98(x26)
    XOR x17, x8, x7
    ANDI x17, x3, -97
    ADDI x24, x23, 116
    ADD x25, x17, x8
    XOR x15, x0, x6
    JAL x12, 40
    SLTI x0, x23, -197
    SRAI x9, x1, -17
    SLTI x5, x6, -133
    SLL x29, x5, x22
    SUB x14, x31, x11
    OR x20, x10, x19
    SLL x28, x25, x18
    SRL x6, x24, x15
    SRL x20, x10, x8
    XORI x17, x8, 63
    SRL x14, x23, x5
    SUB x3, x22, x28
    SRA x7, x16, x27
    ANDI x31, x29, 173
    ADD x26, x22, x8
    LUI x18, -2147418112
    ADDI x18, x18, 256
    SH x30, 1166(x18)
    ADD x18, x15, x0
    SLTU x21, x24, x6
    SRLI x15, x15, -88
    SLLI x27, x3, 114
    ORI x18, x25, -31
    AUIPC x5, -20480
    ADD x14, x6, x31
    ADDI x12, x12, -188
    ORI x8, x10, -63
    SRA x20, x26, x1
    ORI x6, x16, 31
    SRL x24, x2, x25
    SLLI x21, x0, 161
    ORI x21, x4, 192
    XORI x0, x20, 170
    AUIPC x29, 0
    ADDI x29, x29, 8
    JALR x15, 20(x29)
    SLT x12, x29, x9
    SUB x29, x25, x18
    SLTU x4, x17, x30
    SLTUI x11, x25, -34
    SUB x22, x5, x29
    SLTUI x18, x11, 23
    AND x10, x21, x19
    SLT x14, x30, x2
    SRLI x29, x12, -166
    SLTUI x11, x22, 174
    AND x14, x12, x26
    SRL x27, x19, x21
    LUI x29, -2147418112
    ADDI x29, x29, 256
    LW x17, 0(x29)
    OR x6, x19, x25
    SLTI x8, x8, -83
    SRLI x29, x15, -87
    SLT x10, x10, x13
    ORI x19, x24, -50
    ADD x12, x23, x12
    XOR x9, x1, x8
    SLLI x24, x25, 193
    SRAI x23, x5, -64
    SLTUI x10, x17, 193
    ANDI x21, x29, 34
    SRAI x3, x20, -43
    XORI x22, x30, 111
    AUIPC x19, -69632
    SLTUI x3, x5, -138
    SUB x22, x8, x2
    SLTUI x31, x8, -32
    XORI x19, x13, 97
    SLLI x18, x28, 52
    OR x9, x30, x1
    AUIPC x25, -28672
    SLL x8, x4, x17
    SRL x28, x14, x16
    ANDI x1, x14, -180
    LUI x14, -8192
    SLT x24, x10, x26
    ORI x24, x16, 173
    SUB x17, x22, x11
    BLT x2, x7, 12
    SLL x11, x13, x27
    AUIPC x4, 73728
    SLTU x31, x16, x4
    SRA x10, x15, x24
    SUB x17, x18, x17
    SUB x31, x14, x11
    ANDI x8, x11, -42
    SLT x8, x18, x4
    SLLI x8, x9, 70
    SRAI x21, x26, -174
    SLT x17, x6, x25
    AND x16, x15, x11
    LUI x28, -77824
    SRA x1, x14, x23
    AND x31, x9, x23
    ORI x7, x1, 59
    SLTI x17, x4, -82
    OR x28, x25, x21
    SLTU x26, x16, x25
    SLTUI x5, x26, -105
    LUI x29, 8192
    XORI x6, x24, -80
    LUI x5, -2147418112
    ADDI x5, x5, 256
    SW x29, 1528(x5)
    ORI x28, x20, 65
    XOR x29, x16, x31
    AUIPC x7, 28672
    LUI x1, -53248
    SLL x23, x29, x12
    SRLI x13, x8, 74
    XOR x11, x5, x26
    ORI x11, x26, -187
    SLTU x19, x7, x3
    ANDI x10, x8, -17
    SLTUI x29, x30, 101
    LUI x11, 8192
    JAL x3, 4
    ADDI x5, x25, 105
    SLTI x8, x31, 54
    SRLI x22, x14, 30
    AUIPC x19, -8192
    SLTI x11, x17, 15
    SLT x17, x1, x8
    LUI x16, 65536
    AUIPC x6, -69632
    SRA x28, x14, x11
    LUI x29, -2147418112
    ADDI x29, x29, 256
    SH x2, 1136(x29)
    XORI x29, x27, -43
    AUIPC x30, -16384
    SRLI x21, x8, 173
    SLLI x13, x9, -14
    AND x20, x10, x26
    ADD x9, x5, x1
    AND x23, x27, x10
    SRAI x3, x2, 114
    SLTU x22, x18, x11
    OR x9, x16, x19
    SLT x4, x24, x9
    SUB x11, x29, x24
    SLTI x19, x17, 115
    AND x4, x19, x0
    SUB x31, x6, x7
    SLL x22, x19, x22
    LUI x29, 8192
    SUB x4, x13, x25
    SLT x14, x1, x12
    JAL x15, 24
    OR x14, x16, x20
    SLT x10, x2, x20
    ADDI x15, x1, 133
    ORI x24, x17, 75
    ADDI x24, x29, -76
    LUI x4, -2147418112
    ADDI x4, x4, 256
    SB x19, 1842(x4)
    SLT x26, x8, x18
    SRLI x5, x6, -82
    XORI x21, x30, -171
    XORI x25, x15, 107
    OR x27, x22, x27
    SRLI x20, x16, 52
    OR x5, x17, x24
    SLTU x12, x12, x19
    XORI x4, x2, -41
    ADDI x6, x4, 173
    XORI x14, x29, -42
    ADDI x3, x5, -34
    ORI x6, x31, -1
    ADDI x28, x15, 153
    XOR x24, x25, x9
    SLTI x30, x9, -133
    SLTUI x30, x3, -169
    ANDI x29, x4, 99
    ANDI x6, x30, 176
    LUI x27, -28672
    AUIPC x1, 0
    ADDI x1, x1, 8
    JALR x2, 20(x1)
    SLT x6, x30, x15
    SLTUI x17, x7, -24
    AUIPC x14, 0
    SUB x9, x14, x27
    SUB x31, x17, x15
    SRLI x7, x2, -53
    SRAI x5, x5, -58
    SRAI x20, x4, -63
    ANDI x12, x7, -131
    LUI x17, -28672
    OR x6, x1, x14
    XORI x12, x25, 115
    SRAI x19, x6, 25
    XORI x29, x9, 83
    SLT x6, x9, x16
    OR x22, x26, x23
    LUI x21, -2147418112
    ADDI x21, x21, 256
    LBU x31, 145(x21)
    ADD x5, x3, x5
    SRL x1, x28, x9
    XOR x30, x18, x10
    AUIPC x31, 4096
    ORI x4, x11, -76
    LUI x12, 4096
    OR x24, x10, x18
    SLTI x24, x8, -79
    ORI x28, x12, -58
    SRL x10, x4, x6
    SLLI x1, x21, -125
    SLL x10, x9, x9
    SRL x30, x0, x18
    SUB x0, x27, x4
    SLTUI x22, x9, -150
    SLTUI x27, x27, 90
    AND x31, x12, x8
    SLT x12, x13, x18
    OR x7, x28, x22
    ADDI x15, x17, 28
    OR x6, x29, x15
    SLT x22, x28, x18
    SLTI x31, x5, -177
    BLT x6, x7, 8
    SRA x30, x9, x11
    SLL x3, x16, x21
    AND x17, x20, x22
    ORI x0, x3, -57
    LBU x16, 1531(x21)
    SLT x31, x0, x21
    SRA x31, x6, x3
    ANDI x8, x4, -41
    AND x13, x24, x19
    ADD x8, x29, x24
    SLL x2, x20, x18
    SLLI x11, x2, -145
    SRLI x30, x24, 142
    SRLI x24, x12, 173
    XORI x31, x17, -86
    ADDI x15, x9, -77
    SLLI x28, x30, -168
    SRL x28, x30, x5
    SLTUI x28, x12, 75
    SLLI x23, x14, -118
    SLLI x5, x18, -98
    SLLI x6, x27, -133
    SLTUI x7, x18, 102
    SRAI x19, x21, 157
    AUIPC x29, 0
    ADDI x29, x29, 8
    JALR x3, 12(x29)
    SRLI x11, x26, 112
    SLL x13, x21, x24
    SLT x21, x21, x6
    AND x28, x7, x14
    SUB x14, x4, x19
    LUI x7, -2147418112
    ADDI x7, x7, 256
    LHU x17, 38(x7)
    SLLI x1, x23, -161
    LUI x31, 4096
    SLTI x10, x7, 28
    XORI x19, x17, -106
    SRL x28, x16, x26
    SRA x5, x21, x12
    SLTUI x7, x11, -109
    SLLI x0, x24, -77
    AND x11, x27, x2
    AUIPC x12, 0
    SRL x8, x21, x31
    LUI x3, 20480
    XORI x16, x2, -184
    AND x16, x8, x23
    SLTU x18, x13, x22
    SLL x5, x17, x30
    ORI x3, x11, -44
    JAL x18, 8
    SUB x26, x31, x8
    ANDI x26, x22, -153
    ANDI x14, x23, 110
    LUI x10, -24576
    XOR x20, x26, x9
    SLTI x26, x22, -181
    SRL x19, x0, x6
    ADDI x8, x4, 74
    AUIPC x3, 16384
    SRAI x14, x4, 195
    ADD x28, x30, x26
    SRAI x9, x4, 43
    LUI x23, -2147418112
    ADDI x23, x23, 256
    LB x14, 232(x23)
    ADDI x21, x14, 28
    ANDI x3, x19, 10
    ANDI x0, x30, 99
    ORI x13, x23, -133
    ADD x6, x5, x29
    ORI x1, x23, 96
    SRA x23, x17, x28
    SLLI x25, x20, -99
    XOR x21, x22, x0
    ADD x0, x31, x15
    SLLI x26, x16, -59
    SLTU x14, x31, x8
    ADDI x14, x8, -185
    SRAI x2, x23, 86
    SRA x12, x5, x14
    SRA x14, x4, x9
    LUI x30, 45056
    SLTUI x1, x14, -170
    XOR x15, x3, x21
    SLT x26, x30, x7
    SUB x1, x12, x31
    SLTUI x12, x23, 48
    SRL x13, x27, x0
    BGEU x14, x9, 4
    SRLI x7, x14, 129
    XOR x29, x18, x26
    SRAI x4, x6, 64
    SRLI x23, x3, -120
    SLTU x7, x4, x0
    AUIPC x24, 12288
    LUI x10, 24576
    SRAI x1, x25, -109
    AUIPC x12, 45056
    LUI x19, -2147418112
    ADDI x19, x19, 256
    SW x6, 1444(x19)
    ORI x19, x26, -73
    SRA x23, x27, x14
    SLT x14, x1, x18
    SLT x17, x15, x15
    XORI x16, x0, 171
    SLTI x15, x25, -106
    SLTI x15, x11, -14
    AUIPC x9, -36864
    SRL x19, x30, x7
    XORI x8, x19, 54
    SLL x26, x0, x30
    ADD x16, x28, x19
    SLTU x21, x0, x22
    ADDI x6, x11, 165
    SLT x10, x24, x15
    SRA x4, x18, x20
    BEQ x4, x5, 36
    SRAI x16, x27, -49
    LUI x20, -2147418112
    ADDI x20, x20, 256
    LW x23, 84(x20)
    SLTUI x1, x13, -71
    SRAI x25, x31, 68
    SRAI x15, x15, -117
    LUI x19, -32768
    SRAI x4, x11, 153
    ANDI x29, x21, -191
    ANDI x15, x14, -153
    SLTUI x28, x22, 145
    SLTU x21, x20, x1
    ANDI x23, x11, 65
    OR x18, x31, x20
    SUB x25, x8, x19
    ORI x9, x6, -80
    SLTI x11, x16, 67
    SLTU x11, x14, x12
    AUIPC x21, -102400
    SLL x20, x4, x17
    SLTU x11, x14, x13
    SLLI x12, x16, 24
    ADDI x13, x23, -187
    SRA x24, x3, x18
    LUI x28, -118784
    SLLI x15, x6, -29
    ADDI x18, x17, -123
    ANDI x10, x24, 89
    SRAI x7, x11, -149
    SLL x6, x7, x18
    SLTI x20, x17, 85
    SRL x26, x25, x26
    XOR x23, x8, x30
    LUI x24, -98304
    OR x19, x22, x14
    JAL x18, 36
    ADDI x11, x31, 7
    SLTUI x8, x6, -92
    ADDI x9, x20, 85
    SLLI x11, x29, -51
    ADDI x7, x16, -113
    SLTUI x24, x31, 5
    AUIPC x30, 40960
    AND x19, x2, x18
    SRAI x28, x30, -121
    LUI x3, 12288
    SLT x14, x19, x14
    ANDI x20, x26, 31
    LUI x18, 57344
    SLTUI x0, x8, 32
    ANDI x4, x26, -117
    LUI x15, -2147418112
    ADDI x15, x15, 256
    SH x14, 1056(x15)
    SLTUI x16, x8, 165
    XORI x29, x15, -191
    AND x20, x5, x31
    OR x9, x4, x29
    SUB x2, x7, x22
    XOR x19, x28, x26
    OR x7, x26, x17
    SLTU x10, x23, x23
    SLLI x25, x17, 29
    ADDI x0, x18, 71
    SLT x26, x28, x16
    SLTUI x17, x7, -6
    SLT x15, x14, x4
    SLTUI x4, x10, -42
    XOR x27, x7, x14
    XORI x15, x9, -151
    OR x4, x11, x17
    SRL x3, x29, x15
    AUIPC x10, 0
    ADDI x10, x10, 8
    JALR x22, 36(x10)
    SRA x16, x12, x30
    SLTU x14, x0, x3
    SRAI x27, x25, 180
    ADD x15, x29, x23
    SRAI x1, x28, 41
    ADD x6, x27, x6
    SRA x16, x16, x15
    XOR x25, x14, x27
    OR x4, x16, x15
    LUI x18, -20480
    SRLI x10, x0, 86
    AND x12, x30, x30
    LUI x15, -2147418112
    ADDI x15, x15, 256
    SH x5, 110(x15)
    SLTU x11, x25, x1
    LUI x23, 36864
    SLT x22, x22, x11
    ORI x29, x19, -184
    SLTUI x28, x14, -165
    OR x7, x13, x18
    SRLI x5, x5, -119
    AUIPC x28, -131072
    SLL x30, x20, x26
    BLT x10, x6, 16
    OR x11, x22, x9
    LW x26, 72(x15)
    XORI x8, x7, 130
    ADDI x17, x0, -135
    SRL x10, x3, x23
    SLL x24, x24, x25
    SRA x2, x15, x29
    SUB x23, x3, x30
    SLTUI x20, x19, -163
    SRAI x16, x6, 93
    SLTU x12, x12, x0
    SRAI x31, x8, 63
    ADD x19, x20, x24
    SUB x2, x28, x16
    SRA x29, x1, x7
    ORI x14, x5, -179
    SLTUI x16, x20, -142
    SLTU x6, x4, x7
    SLLI x0, x25, -178
    ADD x20, x10, x19
    SRLI x8, x12, 74
    XOR x3, x3, x26
    SRAI x28, x6, 133
    ADDI x2, x28, 134
    SLTU x8, x15, x19
    SLTUI x12, x2, 98
    XOR x11, x12, x26
    AUIPC x31, 0
    ADDI x31, x31, 8
    JALR x0, 28(x31)
    ADD x28, x9, x30
    SUB x15, x25, x24
    AND x19, x17, x20
    SLTU x2, x12, x10
    XOR x14, x3, x13
    SRA x20, x26, x22
    LUI x12, 20480
    AND x15, x10, x10
    ORI x28, x5, 32
    AUIPC x8, -12288
    SRA x24, x11, x9
    SLTUI x31, x16, -82
    LUI x28, 24576
    SLTI x12, x21, 185
    SRL x21, x1, x5
    ADDI x25, x30, -109
    OR x19, x25, x7
    SLTU x9, x26, x12
    SRL x23, x2, x12
    ANDI x17, x29, -164
    SRA x4, x11, x31
    SRLI x26, x9, 20
    SLLI x19, x22, 102
    SRA x1, x20, x29
    SLT x31, x23, x12
    LUI x3, -2147418112
    ADDI x3, x3, 256
    SW x19, 760(x3)
    ORI x20, x23, 95
    AND x1, x19, x13
    ADD x2, x28, x2
    SLTUI x9, x19, -162
    XOR x19, x22, x23
    SRAI x5, x5, -2
    SLTI x29, x10, -74
    SRLI x7, x10, -193
    ADDI x2, x1, -143
    ANDI x20, x14, -48
    SRLI x9, x4, 118
    ADD x8, x29, x20
    XOR x6, x22, x16
    XORI x5, x27, 25
    SLLI x21, x30, -65
    SRL x28, x8, x24
    ADDI x11, x3, 168
    LUI x7, 45056
    SLT x0, x24, x1
    SUB x2, x14, x22
    AUIPC x30, 0
    SLTI x24, x29, 88
    ADDI x15, x0, 118
    SUB x9, x7, x15
    ANDI x26, x16, -169
    SLTUI x17, x12, -151
    ORI x6, x0, 70
    SRLI x1, x22, -6
    BGEU x1, x3, 24
    SLTI x31, x4, 145
    AUIPC x17, 45056
    ADDI x1, x10, 174
    SLTU x9, x24, x4
    ANDI x24, x30, -5
    AUIPC x15, 0
    XOR x29, x15, x20
    AND x12, x3, x28
    XOR x11, x26, x4
    AUIPC x22, -114688
    SLL x23, x1, x25
    SB x4, 1010(x3)
    XORI x26, x0, 118
    SLTUI x29, x24, -32
    SLTI x3, x3, -31
    SRL x24, x17, x20
    SRL x31, x31, x2
    LUI x27, 32768
    ORI x20, x28, 142
    LUI x2, -12288
    JAL x23, 40
    AND x11, x7, x13
    ADD x6, x8, x30
    XOR x28, x1, x0
    ORI x22, x30, -37
    SLTU x23, x14, x31
    AUIPC x12, 8192
    XORI x26, x8, 66
    AUIPC x7, 53248
    SLL x6, x20, x7
    SLT x19, x12, x3
    ANDI x11, x7, -165
    LUI x13, -49152
    SLT x2, x28, x29
    ORI x7, x1, 28
    SLTUI x31, x21, -44
    SLTU x20, x15, x20
    SLTU x27, x21, x23
    SLTI x17, x12, 24
    LUI x17, -2147418112
    ADDI x17, x17, 256
    LHU x3, 96(x17)
    SLTUI x25, x27, -134
    SLT x22, x4, x26
    LUI x19, 8192
    SRLI x7, x21, -194
    SRAI x13, x26, 52
    LUI x15, -8192
    SLTI x29, x20, 81
    SLLI x20, x31, -160
    SRAI x24, x20, -128
    JAL x15, 28
    SLTI x17, x18, 155
    AND x3, x13, x28
    SLTUI x13, x2, 103
    AUIPC x26, 28672
    AUIPC x2, -65536
    SRL x26, x3, x26
    AND x11, x25, x25
    SLLI x12, x18, -197
    SRA x25, x9, x19
    SUB x14, x17, x6
    SRAI x21, x10, -16
    SLL x13, x18, x26
    SW x21, 776(x17)
    SLTUI x11, x5, -42
    SLTU x8, x20, x23
    SRLI x15, x0, 46
    ORI x3, x24, 14
    SLTUI x17, x25, -199
    LUI x27, -28672
    SRLI x7, x15, 1
    ANDI x26, x26, 69
    SRA x15, x13, x23
    SRAI x28, x24, -161
    SUB x16, x29, x26
    SLLI x9, x15, 188
    ADD x18, x13, x25
    SLL x20, x23, x9
    SLT x31, x30, x10
    XORI x8, x1, 149
    SLLI x16, x7, 67
    XOR x23, x2, x8
    SLTU x24, x0, x18
    ADDI x24, x8, 198
    SLTU x10, x9, x5
    LUI x4, -16384
    OR x31, x13, x16
    XOR x23, x29, x9
    SRA x17, x5, x17
    SRAI x23, x22, 133
    SUB x22, x17, x2
    XOR x11, x15, x1
    XORI x21, x3, 105
    SLLI x16, x21, -61
    ORI x28, x23, 78
    BGEU x12, x27, 20
    SLL x13, x10, x18
    SLLI x7, x3, 13
    SLLI x1, x24, 28
    AUIPC x27, -69632
    ORI x7, x17, -82
    AND x14, x29, x27
    XOR x28, x14, x14
    SW x31, 1924(x17)
    AND x2, x1, x7
    LUI x20, -32768
    AUIPC x21, 36864
    SRL x6, x15, x7
    SLL x27, x11, x25
    ORI x13, x2, -125
    SLLI x28, x4, -73
    SLTUI x22, x29, 114
    SRL x26, x15, x23
    SRLI x13, x28, 108
    XORI x5, x22, 6
    SLT x21, x8, x30
    XOR x21, x12, x24
    XORI x16, x25, -169
    SLTI x18, x28, -114
    SRLI x7, x22, -129
    SUB x1, x24, x13
    SRA x4, x6, x23
    ANDI x19, x8, -50
    AUIPC x1, 4096
    SLLI x10, x28, 113
    SLTUI x5, x13, 162
    OR x6, x5, x29
    SUB x31, x25, x9
    SRA x0, x8, x8
    SRLI x22, x1, -104
    SLL x27, x26, x3
    SRLI x9, x5, 77
    OR x20, x30, x28
    SLTI x28, x10, -32
    SLL x5, x11, x14
    SLLI x26, x3, 8
    BNE x7, x8, 16
    SRAI x4, x28, 124
    XORI x25, x19, -35
    SRA x27, x16, x22
    SRLI x31, x6, 97
    SB x21, 243(x17)
    SRL x22, x31, x8
    SLTI x6, x20, -2
    SLL x1, x5, x11
    SLTU x6, x21, x31
    AUIPC x22, -20480
    AUIPC x19, 8192
    AND x9, x0, x2
    SRA x22, x25, x11
    SRLI x28, x16, -78
    SLT x23, x15, x0
    AUIPC x27, 45056
    ANDI x11, x24, 23
    ADD x31, x5, x12
    OR x5, x13, x5
    SRLI x11, x26, 4
    OR x16, x7, x28
    XOR x26, x11, x17
    XORI x11, x20, 131
    SLTU x20, x6, x28
    OR x26, x2, x18
    AUIPC x15, -20480
    SUB x3, x28, x10
    ANDI x1, x13, -157
    ORI x4, x30, 173
    SLLI x18, x21, 102
    SLTI x8, x14, -48
    OR x27, x11, x2
    ANDI x28, x23, -20
    JAL x20, 24
    SLT x28, x21, x19
    XORI x27, x9, -10
    AND x21, x29, x7
    AUIPC x14, -32768
    SRAI x2, x15, 197
    XORI x0, x21, 41
    SLTU x11, x30, x26
    XORI x12, x17, -192
    ANDI x14, x25, 112
    SLTU x11, x10, x1
    XORI x23, x17, -62
    ADDI x23, x14, -143
    SLTU x3, x24, x20
    SLLI x29, x29, -137
    AUIPC x22, -16384
    LW x5, 232(x17)
    SRLI x31, x20, -157
    ANDI x26, x2, -149
    ORI x2, x11, 170
    ANDI x5, x3, 113
    ADDI x20, x0, 16
    SRA x0, x30, x26
    SLL x1, x21, x27
    SLT x11, x28, x3
    SLLI x21, x28, -113
    SRA x11, x1, x19
    ANDI x8, x17, 64
    ANDI x20, x21, -62
    SRLI x25, x28, 84
    LUI x0, -65536
    SRAI x10, x16, 63
    AUIPC x20, 0
    ADDI x20, x20, 8
    JALR x14, 16(x20)
    SRL x29, x28, x7
    SRLI x28, x22, -15
    AND x10, x22, x26
    SLLI x16, x6, -32
    SLLI x20, x19, 116
    SLTUI x1, x23, 105
    OR x10, x25, x22
    AUIPC x25, -8192
    LUI x31, -45056
    SLL x22, x1, x26
    XOR x24, x20, x13
    XORI x21, x20, 151
    SLTU x8, x26, x15
    SRA x19, x5, x24
    SRAI x27, x11, -153
    ANDI x0, x20, -80
    SLLI x7, x21, 23
    SLTUI x27, x17, -178
    SLLI x9, x28, -24
    XORI x28, x4, -106
    ANDI x5, x2, -174
    SLTUI x22, x10, -199
    SH x10, 90(x17)
    SLLI x26, x9, 72
    SUB x8, x22, x24
    SRL x13, x29, x16
    SLLI x23, x22, -37
    SRAI x8, x25, -106
    SUB x16, x11, x21
    SRAI x26, x0, 100
    SLTU x20, x1, x0
    ORI x10, x26, -104
    ANDI x21, x20, 180
    SRA x20, x2, x8
    ANDI x5, x11, -124
    ORI x16, x22, 83
    SLTI x3, x25, 103
    ADD x3, x3, x27
    LUI x3, 45056
    OR x20, x22, x29
    LUI x11, 4096
    XOR x21, x26, x8
    SLL x0, x16, x15
    SRAI x23, x2, -77
    ANDI x24, x8, -190
    AND x4, x23, x9
    SUB x5, x22, x18
    SRAI x9, x30, 153
    JAL x6, 16
    OR x22, x17, x28
    ORI x24, x27, 86
    OR x1, x0, x17
    SLTUI x25, x17, -155
    AND x0, x24, x17
    SRL x11, x13, x5
    SLTUI x27, x6, 181
    ADD x30, x25, x6
    AND x30, x13, x18
    SLLI x28, x21, -15
    AUIPC x1, -24576
    XORI x17, x23, -163
    ADDI x23, x15, 193
    SLL x18, x10, x25
    AND x24, x3, x1
    AND x22, x30, x0
    SLTU x12, x30, x24
    XORI x20, x25, -115
    AUIPC x24, -16384
    LH x1, 146(x17)
    XORI x25, x22, 103
    XORI x4, x1, -12
    SLTUI x4, x19, -69
    SLTU x0, x29, x13
    SLLI x21, x30, 193
    ORI x21, x20, 192
    SUB x16, x21, x29
    OR x21, x6, x26
    SLL x20, x25, x0
    BLTU x29, x31, 24
    XOR x22, x3, x25
    SH x14, 1212(x17)
    SLTI x21, x28, -21
    XOR x10, x17, x28
    SLT x17, x0, x20
    SRAI x27, x18, -9
    XORI x22, x12, -61
    SRLI x25, x13, 26
    ANDI x0, x29, 153
    XOR x2, x26, x25
    SLTI x26, x17, -133
    ORI x3, x18, 172
    SUB x0, x13, x31
    SLL x5, x4, x29
    OR x0, x21, x22
    ANDI x13, x14, -4
    SUB x5, x10, x30
    SLL x17, x15, x26
    SRAI x31, x9, 0
    SLTI x7, x18, 30
    ANDI x28, x11, -97
    SLTUI x7, x11, 138
    SRAI x26, x8, 48
    JAL x24, 36
    ADD x21, x26, x3
    ADDI x3, x21, 25
    OR x23, x6, x1
    SLTI x3, x21, 22
    SLL x27, x18, x13
    SRL x11, x29, x19
    AND x24, x31, x17
    ORI x26, x0, -35
    XORI x21, x26, -152
    AUIPC x13, -86016
    SLT x12, x7, x17
    SRAI x24, x6, -175
    ORI x1, x12, -177
    ADDI x22, x27, -116
    LB x9, 135(x17)
    SUB x2, x5, x12
    XORI x13, x14, 125
    SLLI x1, x10, 124
    SLT x13, x12, x16
    SLTUI x4, x7, 170
    SLTU x7, x2, x29
    ORI x21, x0, -102
    SRLI x22, x14, 13
    ORI x27, x28, 114
    SLTUI x26, x22, -66
    SRLI x3, x15, 197
    SLLI x8, x23, -6
    SLTI x10, x18, 146
    BEQ x28, x11, 20
    OR x10, x17, x2
    SLLI x29, x17, -75
    SLLI x2, x27, -12
    SLTI x22, x12, -80
    SLL x28, x6, x12
    SLT x24, x0, x24
    SRL x24, x18, x22
    XOR x12, x0, x8
    AUIPC x15, -4096
    SLTU x29, x28, x11
    SRL x12, x30, x19
    SB x31, 477(x17)
    XOR x15, x3, x8
    AND x15, x20, x16
    SLTUI x29, x7, 130
    SRA x23, x5, x24
    SRLI x16, x31, 178
    SRA x8, x4, x9
    ORI x27, x14, 68
    SRA x1, x0, x29
    LUI x9, -77824
    SLTI x2, x14, 109
    SLTUI x23, x30, 80
    XOR x7, x11, x25
    SRL x21, x5, x11
    ADDI x7, x29, 156
    SLLI x23, x18, -134
    BGE x8, x17, 16
    SUB x6, x7, x16
    SLL x18, x18, x20
    SLLI x26, x19, 172
    SLTI x4, x10, 192
    SUB x0, x21, x10
    SLTU x14, x30, x14
    ADDI x24, x26, -126
    SLTUI x11, x24, -61
    SLTI x14, x29, 191
    XORI x10, x3, 168
    OR x22, x11, x1
    SLL x16, x4, x26
    SRAI x17, x26, 185
    ORI x23, x16, 142
    XOR x4, x31, x23
    SRLI x6, x18, -144
    SRLI x0, x18, -104
    ADDI x15, x10, -44
    AUIPC x12, -114688
    XOR x2, x1, x30
    XOR x7, x30, x1
    SRA x10, x16, x9
    SH x31, 202(x17)
    SRA x1, x14, x27
    AUIPC x22, 53248
    SLTI x0, x24, -73
    OR x7, x2, x12
    ADDI x1, x18, 195
    SLT x10, x24, x27
    JAL x4, 32
    SLLI x14, x27, 195
    XORI x27, x12, 76
    ADDI x23, x13, -50
    SUB x25, x28, x6
    XORI x10, x6, 149
    SRL x18, x22, x30
    OR x5, x29, x29
    ANDI x7, x25, 157
    SLLI x20, x22, 85
    SLTU x16, x29, x18
    SRA x17, x0, x26
    ORI x10, x23, -7
    AND x11, x20, x11
    SLL x7, x6, x26
    XORI x10, x8, 61
    SLT x17, x13, x12
    LW x17, 60(x17)
    SLL x23, x11, x23
    ADDI x28, x9, -95
    SLTUI x3, x30, 98
    XORI x0, x25, 44
    ADDI x31, x5, 64
    SLTU x20, x17, x18
    LUI x18, -57344
    SUB x13, x23, x21
    XORI x19, x22, 19
    SRA x8, x2, x30
    ADD x10, x22, x23
    ADDI x10, x27, -120
    SRLI x6, x9, -145
    SLL x18, x0, x11
    OR x26, x2, x3
    SLTUI x19, x0, 156
    SLLI x23, x0, 88
    XORI x2, x15, 142
    ADD x15, x20, x27
    JAL x3, 4
    AUIPC x19, -20480
    LUI x30, 8192
    SLTI x20, x0, -111
    SRLI x6, x30, -134
    AND x19, x23, x4
    ORI x7, x21, -16
    SRL x19, x18, x29
    XOR x26, x16, x2
    SUB x7, x3, x22
    SRAI x19, x22, 169
    SLL x26, x18, x26
    XORI x29, x18, 133
    LUI x6, 81920
    ADD x18, x26, x24
    ADDI x26, x7, -181
    LUI x1, -2147418112
    ADDI x1, x1, 256
    SB x10, 1123(x1)
    SLLI x27, x0, -129
    SRAI x22, x28, 119
    SLTU x10, x26, x18
    BLTU x23, x10, 24
    SLTI x4, x5, 144
    SRA x12, x24, x15
    SLT x16, x5, x24
    XOR x1, x5, x6
    SB x14, 320(x1)
    SLTI x22, x9, 106
    ANDI x18, x1, 90
    XORI x6, x5, -139
    SLTI x30, x1, -26
    SLTU x14, x31, x15
    ADD x22, x17, x12
    LUI x23, -53248
    XOR x11, x28, x18
    SRA x9, x21, x30
    ADD x10, x13, x18
    AND x9, x30, x29
    SLTUI x3, x1, -144
    SLTUI x3, x26, -126
    SLLI x21, x14, 51
    SUB x30, x14, x0
    ANDI x8, x2, 119
    LUI x27, -81920
    SLT x15, x15, x10
    BLTU x25, x24, 4
    SRA x16, x23, x27
    ANDI x17, x2, -18
    SUB x10, x9, x1
    SLL x11, x7, x12
    ADDI x27, x13, 13
    AUIPC x26, -12288
    ANDI x24, x6, -169
    SRL x3, x8, x12
    ADD x0, x29, x28
    ORI x10, x8, -54
    SRAI x18, x19, 14
    XORI x25, x29, -196
    SLLI x17, x23, -123
    LHU x8, 80(x1)
    AUIPC x4, 4096
    SLL x4, x23, x28
    SRA x0, x6, x0
    SLTI x15, x20, 156
    SLTU x14, x26, x9
    LUI x12, -53248
    AND x20, x4, x8
    ORI x16, x14, -112
    SLTI x21, x17, 78
    XOR x12, x29, x3
    SLLI x26, x4, 47
    SRLI x12, x31, 145
    XORI x7, x1, -51
    LUI x22, 28672
    ANDI x1, x22, 198
    SUB x13, x5, x1
    SLL x11, x27, x28
    SRLI x23, x2, -42
    SLTUI x3, x1, -5
    SRLI x28, x23, -60
    AUIPC x8, 0
    ADDI x8, x8, 8
    JALR x18, 40(x8)
    ORI x18, x6, -179
    XOR x13, x27, x5
    ADD x28, x8, x24
    SLTI x6, x19, -77
    SLT x29, x6, x17
    SLL x3, x16, x5
    SLTUI x0, x0, -118
    ORI x30, x8, 36
    SLTI x30, x6, -93
    SLLI x28, x28, 35
    XORI x4, x15, -68
    AUIPC x30, -28672
    XOR x22, x27, x27
    XOR x2, x19, x8
    XOR x8, x0, x15
    LUI x2, 20480
    SLTU x29, x2, x20
    AND x29, x9, x19
    SRA x12, x19, x22
    SB x26, 1575(x1)
    SLT x0, x23, x5
    AUIPC x23, 36864
    SRL x19, x30, x1
    SRA x7, x6, x29
    XORI x0, x29, -15
    SLTUI x5, x0, -70
    OR x30, x26, x19
    AUIPC x28, -12288
    SLLI x1, x9, -145
    ANDI x8, x6, 144
    ADD x16, x15, x6
    ADDI x30, x17, 143
    AND x25, x21, x5
    SRLI x27, x16, 26
    BGEU x22, x16, 36
    SUB x28, x19, x14
    SLLI x26, x13, -62
    XORI x28, x17, 83
    ADDI x23, x13, -144
    XOR x12, x14, x7
    OR x3, x3, x9
    AUIPC x18, 0
    ADDI x7, x3, 142
    SRA x11, x30, x18
    AUIPC x14, 65536
    XORI x5, x6, -70
    SRAI x4, x26, -64
    SLTI x7, x17, -35
    SLTU x26, x24, x22
    ADD x27, x16, x3
    SRAI x2, x17, 22
    ADD x26, x1, x11
    XORI x29, x14, -111
    SRA x6, x22, x22
    LH x11, 84(x1)
    SLLI x0, x20, 107
    AND x12, x18, x22
    ADDI x4, x1, -75
    SLTUI x15, x25, -126
    SRLI x20, x6, -139
    XOR x15, x2, x27
    ADD x7, x28, x24
    XOR x11, x1, x6
    SRLI x26, x4, 78
    ANDI x4, x16, -182
    SLTU x11, x5, x24
    AND x29, x6, x5
    SLLI x1, x11, 47
    SLT x10, x24, x2
    SLLI x17, x31, 6
    SLTI x16, x4, 112
    OR x25, x25, x20
    ANDI x9, x30, 145
    SLT x11, x24, x23
    OR x1, x15, x2
    ADD x1, x26, x29
    SLTU x28, x15, x6
    BGE x7, x28, 36
    XOR x14, x20, x14
    AND x15, x14, x26
    SRAI x13, x26, -191
    AUIPC x6, 36864
    SLT x14, x22, x31
    SRL x11, x0, x31
    SUB x5, x10, x27
    SLTI x0, x8, 141
    SRA x28, x10, x2
    ADD x0, x27, x3
    SLL x8, x6, x0
    LB x26, 228(x1)
    ADD x28, x5, x17
    SUB x15, x6, x21
    ADDI x3, x5, -111
    ADD x17, x2, x23
    SRAI x27, x4, 135
    SRA x5, x5, x14
    SLLI x24, x29, 149
    SLL x12, x5, x14
    AND x8, x15, x14
    ANDI x8, x16, 151
    SRA x14, x5, x19
    SRA x20, x29, x2
    ORI x26, x9, 154
    ADD x28, x18, x15
    SLTI x7, x21, -35
    ADD x31, x27, x31
    LUI x10, 0
    ADDI x26, x7, -51
    SUB x24, x22, x22
    SLTUI x14, x4, 16
    ADD x5, x10, x13
    AUIPC x31, 73728
    SLTUI x14, x20, 136
    SLL x20, x13, x15
    AUIPC x5, 0
    ADDI x5, x5, 8
    JALR x11, 40(x5)
    SUB x31, x7, x25
    SLTUI x19, x7, 105
    SLTU x7, x12, x24
    SUB x22, x31, x17
    SRL x6, x2, x5
    SLL x16, x13, x20
    ORI x6, x31, -1
    SLTU x23, x10, x30
    LUI x15, -77824
    ADD x4, x13, x20
    SRA x12, x22, x16
    LUI x10, 49152
    SLT x6, x29, x6
    XOR x30, x7, x10
    LUI x6, -69632
    ADD x29, x23, x9
    SLLI x25, x12, 12
    SUB x8, x19, x13
    SLTI x18, x23, 147
    ADDI x9, x14, -146
    SRA x21, x8, x7
    SLTI x16, x12, 15
    XORI x11, x12, -162
    XOR x30, x0, x15
    XORI x8, x20, 67
    ORI x30, x17, 183
    SLLI x26, x14, 121
    SW x29, 268(x1)
    SRA x0, x17, x7
    ADDI x18, x15, -149
    ANDI x0, x19, -4
    SRL x17, x6, x16
    SUB x26, x22, x1
    AUIPC x23, 45056
    SLT x14, x8, x18
    OR x27, x13, x21
    SLTI x21, x18, 15
    SRA x31, x3, x19
    OR x30, x15, x7
    ADDI x27, x7, 143
    SLLI x22, x16, -85
    LUI x13, 8192
    OR x22, x22, x21
    SRA x16, x16, x29
    SLT x30, x15, x17
    ADD x12, x10, x24
    ORI x7, x7, 83
    XORI x3, x0, -67
    SRLI x23, x11, 175
    SLTU x0, x9, x6
    SRAI x1, x10, 159
    SLTUI x5, x2, 43
    OR x14, x7, x18
    SLTU x23, x9, x17
    SLTUI x29, x18, -73
    BLTU x16, x27, 24
    SLT x9, x29, x11
    SLTI x2, x2, -116
    SRL x5, x11, x22
    ANDI x13, x11, -119
    SLTU x29, x7, x18
    LUI x4, 4096
    SLL x17, x31, x4
    SLTUI x13, x11, -96
    SLL x22, x6, x1
    SLT x3, x15, x0
    LUI x11, -4096
    SLTI x27, x11, -182
    LH x16, 30(x1)
    SRL x9, x28, x12
    AUIPC x9, 61440
    SLTUI x17, x22, -39
    ORI x26, x12, -38
    SRL x10, x31, x12
    OR x9, x4, x25
    ADD x4, x12, x31
    SLLI x15, x10, 32
    XOR x18, x13, x13
    SLL x25, x4, x30
    ANDI x28, x6, -135
    ADD x3, x27, x10
    SLL x19, x21, x18
    ANDI x18, x9, 143
    ANDI x6, x1, 162
    OR x27, x11, x6
    SRA x28, x31, x31
    SUB x15, x9, x28
    SRAI x8, x19, -11
    SRLI x25, x22, 136
    ADD x23, x29, x7
    SUB x19, x21, x7
    SRAI x19, x7, -109
    JAL x28, 24
    ANDI x17, x26, -147
    OR x17, x10, x31
    SRAI x21, x30, 8
    SRAI x20, x27, 168
    SUB x8, x19, x30
    SRA x12, x15, x13
    AND x4, x28, x4
    XORI x30, x24, -107
    ADD x1, x7, x2
    ANDI x9, x5, -82
    OR x2, x9, x12
    LW x0, 148(x1)
    SLLI x5, x6, -167
    XOR x28, x18, x27
    ANDI x22, x24, -64
    SLL x14, x11, x22
    XORI x10, x5, 199
    SLTU x31, x10, x12
    ANDI x15, x29, -158
    JAL x11, 36
    XOR x28, x22, x23
    SRAI x12, x12, -48
    ORI x30, x8, 110
    AUIPC x26, -20480
    SRL x8, x11, x4
    SLTI x5, x12, -168
    AUIPC x9, -77824
    ANDI x4, x17, -125
    SLTU x28, x21, x25
    ORI x15, x4, 82
    SLL x30, x9, x1
    SLT x0, x22, x19
    SRA x8, x9, x14
    ANDI x23, x29, 101
    AND x28, x26, x8
    XORI x27, x5, -25
    XORI x11, x11, -7
    ADDI x27, x4, 138
    SRA x25, x4, x11
    SH x5, 1954(x1)
    XORI x30, x20, 30
    SRL x14, x16, x9
    SRA x14, x27, x18
    SRAI x14, x16, 108
    SLTUI x17, x3, 180
    LUI x14, 24576
    SRLI x12, x11, 114
    SLTUI x20, x15, 99
    ORI x23, x14, 170
    LUI x9, 16384
    LUI x6, 69632
    XOR x30, x5, x21
    SLTI x0, x5, 24
    XORI x12, x18, 171
    SRA x15, x16, x16
    AND x8, x25, x7
    SLL x8, x3, x17
    ADDI x4, x6, -92
    XORI x24, x3, -170
    SLTI x28, x16, -115
    LUI x20, 32768
    XORI x9, x20, -28
    ADDI x14, x26, -85
    SRLI x31, x22, 191
    ADD x9, x9, x5
    AUIPC x12, 40960
    BGEU x11, x7, 8
    AND x7, x17, x25
    ADDI x31, x11, 174
    SRLI x3, x21, 44
    XORI x11, x26, -5
    SLTUI x2, x7, 162
    SLTI x30, x27, 168
    SLLI x14, x20, 174
    LUI x23, 32768
    OR x12, x22, x13
    SRAI x17, x2, 28
    SUB x29, x10, x28
    ORI x21, x27, -90
    SLL x29, x5, x25
    SRLI x2, x14, 22
    AUIPC x8, 16384
    OR x29, x11, x1
    XOR x1, x23, x13
    SRLI x25, x8, 4
    SRAI x3, x22, -124
    LB x30, 193(x1)
    AND x7, x23, x31
    AUIPC x10, 45056
    SLLI x21, x13, 175
    SLTI x29, x27, -118
    ADDI x11, x1, 56
    XORI x4, x11, 128
    SLLI x10, x30, 181
    OR x3, x13, x1
    SLTI x29, x20, 177
    ORI x5, x10, -168
    SLLI x28, x29, -170
    SLT x1, x5, x18
    AUIPC x27, -24576
    SLTU x21, x0, x12
    ADD x6, x29, x2
    SUB x7, x31, x2
    SLL x30, x12, x22
    SRA x31, x18, x4
    SLTU x1, x27, x30
    SRA x23, x19, x18
    SRAI x15, x10, -189
    SLTI x18, x7, 159
    ADD x17, x14, x19
    AUIPC x24, -8192
    ADDI x16, x16, 101
    SUB x14, x5, x8
    AUIPC x9, 0
    ADDI x9, x9, 8
    JALR x24, 20(x9)
    SLTI x30, x6, -120
    LUI x4, 69632
    XORI x6, x8, -88
    OR x31, x0, x16
    ORI x1, x31, 97
    SRA x8, x25, x21
    ORI x8, x30, -59
    SUB x15, x26, x24
    LUI x4, 65536
    ANDI x21, x12, 124
    SLL x24, x4, x4
    SW x7, 160(x1)
    SRA x11, x18, x6
    SLTU x9, x14, x26
    AUIPC x14, 32768
    SLL x24, x9, x26
    SUB x27, x7, x9
    OR x31, x19, x14
    AND x13, x8, x4
    AUIPC x22, -61440
    XOR x13, x10, x15
    SLTI x11, x13, 14
    OR x6, x18, x3
    SRLI x18, x25, -185
    ADD x24, x12, x22
    AUIPC x24, 8192
    SRLI x15, x15, -196
    ADD x8, x12, x0
    SRA x27, x21, x0
    ADD x31, x13, x4
    SLLI x1, x28, 76
    XOR x22, x4, x27
    ANDI x16, x9, 161
    XOR x8, x24, x15
    SLTI x24, x1, -54
    SLTUI x26, x8, -60
    SRLI x28, x23, 200
    XOR x1, x21, x13
    ADD x13, x3, x11
    SLLI x19, x23, 131
    SLL x16, x19, x23
    SRAI x15, x22, -166
    ANDI x7, x3, -93
    BEQ x23, x19, 32
    ANDI x13, x12, 125
    ADDI x2, x29, 80
    AND x12, x20, x20
    SLTUI x1, x1, 42
    AND x1, x11, x24
    SRLI x18, x1, 129
    SLTU x15, x29, x8
    SLTUI x25, x7, 67
    LUI x22, -57344
    SB x11, 984(x1)
    SLL x8, x20, x7
    SLLI x27, x26, 82
    SLT x18, x6, x18
    SLTI x22, x18, 199
    AND x13, x30, x19
    SLTUI x29, x31, 14
    XOR x18, x22, x23
    SUB x12, x22, x7
    ADDI x30, x12, -158
    SUB x18, x30, x10
    AUIPC x25, 20480
    SRA x4, x22, x26
    ADDI x15, x6, 45
    ADD x5, x28, x5
    ORI x15, x10, 124
    ORI x7, x16, 155
    SUB x28, x1, x13
    XOR x29, x3, x1
    SRA x20, x29, x21
    ADDI x23, x5, 164
    JAL x12, 4
    LHU x30, 56(x1)
    SRLI x11, x2, -185
    SRL x5, x22, x12
    SRAI x31, x30, 168
    SRA x26, x27, x7
    SLL x17, x22, x28
    BLTU x10, x24, 40
    OR x19, x0, x20
    SRLI x9, x15, 199
    OR x13, x25, x27
    ORI x20, x30, -4
    SLTUI x9, x23, -174
    SLT x17, x26, x27
    SRL x10, x16, x6
    AUIPC x10, 73728
    SLT x24, x11, x2
    ORI x29, x24, -191
    XOR x20, x19, x8
    SRA x12, x29, x12
    SUB x12, x27, x16
    AUIPC x13, 4096
    ADDI x29, x10, 119
    LUI x5, 94208
    SLLI x31, x6, -121
    SRA x20, x26, x21
    XORI x27, x8, -52
    SRLI x25, x11, 93
    XOR x20, x0, x13
    AND x24, x0, x31
    SUB x16, x9, x6
    XOR x9, x1, x19
    SLT x8, x10, x3
    SB x24, 202(x1)
    SLTI x21, x10, 141
    LUI x6, -118784
    AUIPC x25, 8192
    ANDI x24, x13, -122
    SLTI x5, x17, 103
    ADDI x28, x23, -160
    SRLI x6, x5, 66
    SRA x5, x0, x24
    OR x25, x8, x26
    SLTUI x0, x21, -179
    SRLI x14, x18, -68
    ADD x20, x28, x17
    SRL x19, x8, x27
    XOR x15, x27, x28
    SLTU x23, x18, x3
    ADDI x14, x27, 77
    SLL x22, x13, x11
    LUI x26, -16384
    SRLI x24, x5, -179
    SLT x9, x8, x7
    SLTI x28, x22, -183
    BLTU x16, x24, 32
    AUIPC x12, -4096
    XOR x3, x5, x19
    XOR x0, x1, x20
    SLT x0, x4, x7
    SLTI x7, x10, 124
    OR x1, x16, x9
    ANDI x0, x8, 119
    SRAI x9, x15, -62
    AND x11, x8, x3
    SLTU x18, x20, x17
    SLLI x19, x7, 85
    AND x19, x6, x16
    LUI x5, 32768
    SLTUI x3, x21, 48
    SLTUI x27, x4, -48
    LUI x12, 24576
    SLLI x2, x15, 123
    SRL x21, x28, x27
    XORI x18, x8, 49
    SLTI x17, x7, -155
    SUB x10, x14, x28
    ORI x31, x13, 113
    XOR x3, x7, x24
    SUB x3, x15, x22
    LBU x1, 200(x1)
    ANDI x5, x17, -165
    LUI x14, -65536
    SLLI x6, x21, -16
    SLLI x30, x15, -34
    XORI x15, x10, -89
    SLLI x24, x29, 158
    AUIPC x9, 12288
    SLLI x27, x5, -162
    ADD x3, x13, x11
    SRA x7, x29, x12
    SLLI x30, x30, -81
    AUIPC x1, -24576
    AUIPC x8, 49152
    JAL x22, 36
    SRL x14, x19, x5
    SUB x20, x7, x2
    SRAI x23, x5, -188
    XOR x18, x18, x11
    ADD x31, x29, x4
    SLTU x19, x8, x4
    OR x14, x5, x22
    SLTI x1, x18, -160
    ORI x9, x18, 60
    ORI x18, x25, -188
    SLTI x26, x5, -96
    ADDI x22, x19, -103
    SLLI x14, x23, -157
    SRLI x23, x28, -145
    SLLI x7, x21, -75
    SLTU x23, x28, x27
    OR x24, x25, x7
    SLLI x2, x5, -46
    SLTUI x16, x2, 51
    SLLI x3, x22, 78
    SRLI x23, x11, 134
    AND x0, x0, x9
    SRL x20, x18, x23
    LUI x27, -2147418112
    ADDI x27, x27, 256
    SH x0, 920(x27)
    SLTI x17, x29, -71
    SRL x26, x26, x5
    ADDI x5, x3, 62
    OR x30, x28, x0
    AUIPC x4, 0
    ADDI x4, x4, 8
    JALR x16, 16(x4)
    SRL x29, x11, x2
    XORI x14, x24, -49
    SUB x24, x22, x13
    AND x10, x2, x7
    SLT x30, x4, x25
    SLTUI x26, x21, -93
    AND x4, x25, x19
    ADD x24, x9, x10
    XORI x13, x30, 186
    OR x8, x18, x24
    ANDI x29, x27, 80
    AND x16, x13, x11
    ANDI x12, x20, -148
    SLTU x10, x5, x11
    SLT x0, x31, x28
    SLL x4, x4, x30
    ADD x11, x29, x10
    ANDI x3, x15, 70
    ANDI x8, x11, 79
    SLTU x28, x10, x24
    LB x29, 219(x27)
    SRL x18, x27, x28
    ANDI x7, x5, -79
    SRLI x20, x21, -150
    SRA x18, x10, x21
    SLTI x30, x22, -99
    ADDI x28, x9, -137
    ADD x29, x30, x15
    JAL x23, 36
    SRAI x2, x22, -30
    ANDI x30, x26, -7
    SLTI x31, x9, -200
    SRLI x26, x20, -77
    SUB x4, x9, x0
    SRA x4, x1, x0
    OR x16, x0, x30
    SLT x26, x27, x5
    SLL x21, x9, x25
    SRA x14, x13, x27
    ANDI x3, x9, 41
    LUI x2, -36864
    SRLI x29, x13, 199
    SRAI x12, x26, -196
    SRLI x31, x6, 89
    LW x18, 252(x27)
    SLTI x29, x4, -186
    ANDI x11, x21, -128
    SLLI x26, x0, -51
    ADDI x7, x0, -59
    ANDI x10, x10, 124
    ADD x22, x14, x5
    AND x7, x30, x3
    SRLI x4, x17, 128
    SUB x26, x5, x25
    SRAI x0, x9, -144
    ADDI x31, x10, 154
    SLTI x0, x18, -71
    SRLI x10, x1, -110
    ORI x27, x10, 128
    SLTUI x12, x28, -77
    SLL x27, x27, x23
    SRL x3, x5, x18
    SRA x29, x1, x15
    XOR x22, x19, x7
    SRA x0, x14, x13
    ADDI x22, x12, 109
    XOR x19, x11, x3
    XOR x9, x6, x23
    SRLI x13, x20, -46
    ADDI x31, x19, 117
    ADD x3, x31, x21
    JAL x22, 24
    AUIPC x17, -98304
    ADD x26, x31, x21
    AND x16, x4, x16
    SLLI x6, x7, -33
    AND x25, x1, x1
    SH x13, 1776(x27)
    XORI x11, x0, -187
    SRL x25, x13, x24
    ANDI x25, x28, 169
    OR x30, x16, x19
    ADD x6, x19, x20
    AND x25, x23, x1
    SLTUI x5, x27, 7
    LUI x25, -61440
    SLTU x7, x9, x8
    SUB x8, x4, x22
    ADDI x4, x20, -141
    SRA x28, x12, x27
    OR x3, x31, x31
    OR x15, x22, x24
    ADDI x17, x25, -145
    ORI x8, x17, 128
    LUI x26, 12288
    SLL x13, x19, x7
    SRL x15, x0, x13
    XORI x17, x27, 182
    SUB x27, x24, x16
    ADDI x18, x20, -63
    AND x7, x0, x2
    SLLI x4, x7, -186
    SRAI x28, x28, 25
    AUIPC x0, 49152
    ANDI x18, x31, 46
    SLTU x9, x29, x15
    SRAI x11, x28, 92
    JAL x11, 16
    LUI x13, -16384
    SLTI x8, x4, 129
    SRA x31, x24, x8
    SRA x31, x10, x20
    SLLI x25, x8, 12
    SRA x26, x23, x10
    SRLI x31, x5, -120
    ORI x11, x14, -113
    LUI x13, 69632
    AUIPC x1, -49152
    SRLI x12, x29, 159
    LHU x11, 8(x27)
    SLLI x6, x0, 73
    OR x5, x25, x6
    XOR x31, x22, x3
    LUI x2, 77824
    SRA x18, x17, x19
    SLL x21, x19, x17
    SLT x7, x20, x29
    SLTUI x22, x14, 84
    XORI x13, x31, 179
    OR x0, x25, x11
    AND x23, x27, x1
    SLTI x14, x8, 133
    SLTU x9, x24, x2
    ADD x17, x21, x20
    SLTU x15, x26, x14
    AUIPC x5, 36864
    SRA x29, x31, x30
    SUB x18, x23, x29
    SRLI x7, x29, 190
    AND x26, x9, x22
    SLT x1, x25, x21
    SLTI x19, x8, -178
    XOR x3, x3, x13
    AUIPC x12, 0
    ADDI x12, x12, 8
    JALR x9, 24(x12)
    ANDI x0, x8, -119
    LUI x7, -12288
    ADD x1, x20, x16
    SRL x24, x28, x1
    ANDI x27, x25, -61
    ORI x6, x31, -56
    SRA x28, x1, x19
    SRAI x11, x31, 129
    SLTUI x2, x23, 116
    SLTI x5, x22, -183
    SRAI x25, x28, 59
    SLTU x7, x0, x19
    SUB x30, x8, x27
    SRL x24, x25, x6
    SH x10, 400(x27)
    SRA x26, x28, x12
    LUI x10, 40960
    SRL x30, x20, x3
    ADDI x5, x2, 41
    XORI x19, x22, 132
    XORI x21, x8, 114
    SRL x1, x26, x13
    XOR x4, x0, x27
    SUB x22, x10, x16
    ORI x31, x19, -47
    SRAI x10, x26, 48
    ORI x11, x5, -55
    SRA x15, x11, x14
    SRA x27, x11, x29
    AUIPC x21, -4096
    SRAI x17, x31, -181
    ANDI x10, x17, -96
    SLL x6, x5, x9
    ADDI x14, x23, 28
    XOR x30, x0, x28
    SRAI x3, x18, 145
    SRL x2, x0, x4
    ADDI x0, x1, -154
    SUB x25, x15, x10
    XORI x0, x12, -113
    LUI x4, -4096
    ORI x27, x18, 184
    OR x6, x23, x7
    AND x7, x30, x21
    XORI x13, x14, -189
    XORI x11, x27, -160
    SLTU x31, x17, x30
    LUI x24, -12288
    BGE x31, x10, 4
    OR x28, x8, x29
    OR x18, x23, x30
    AND x0, x15, x4
    SLT x20, x27, x7
    LUI x4, -36864
    XORI x10, x27, -49
    SRLI x29, x0, -177
    LUI x18, -32768
    ADDI x9, x5, 153
    SH x22, 382(x27)
    SLTU x20, x19, x10
    SLTI x26, x28, -56
    SRAI x0, x6, 101
    SLL x30, x29, x15
    XORI x30, x26, -103
    ANDI x17, x0, 53
    SLL x23, x20, x29
    ORI x26, x4, -86
    OR x18, x3, x0
    ADD x13, x10, x18
    SLTUI x25, x5, -69
    SLTUI x19, x24, -166
    LUI x6, -36864
    ANDI x29, x7, 175
    XORI x22, x1, 138
    ANDI x20, x24, 14
    XOR x7, x8, x26
    BLTU x6, x16, 4
    LUI x19, -110592
    LBU x30, 26(x27)
    SRAI x29, x28, 158
    SRA x9, x26, x13
    ANDI x29, x14, -78
    SRAI x3, x3, 132
    OR x13, x16, x5
    SRA x28, x13, x3
    SLTI x25, x30, -89
    OR x30, x31, x12
    SRA x12, x16, x2
    SLTUI x3, x3, -21
    XOR x12, x28, x6
    SRL x23, x5, x30
    ORI x30, x18, -171
    AND x23, x7, x14
    XOR x18, x12, x20
    SUB x25, x8, x2
    SLTUI x21, x19, 19
    XORI x25, x9, 79
    SLTI x10, x3, 74
    LUI x0, 32768
    JAL x24, 16
    SLL x7, x29, x20
    XORI x25, x1, 50
    AND x25, x25, x7
    LHU x31, 154(x27)
    SRA x8, x2, x30
    SLT x0, x26, x8
    SRAI x14, x29, 54
    SLTI x10, x17, -142
    XORI x26, x2, 117
    SLL x16, x10, x30
    SRA x18, x17, x31
    AUIPC x13, 0
    ADDI x13, x13, 8
    JALR x3, 4(x13)
    ANDI x18, x20, 3
    LUI x2, 49152
    AUIPC x25, 16384
    LUI x25, 40960
    SLT x3, x10, x10
    SB x13, 1603(x27)
    ORI x3, x6, 53
    XORI x13, x15, 27
    SRAI x4, x21, -103
    OR x5, x10, x22
    SLTUI x9, x16, -106
    SRA x30, x8, x8
    SUB x2, x24, x21
    SLL x25, x11, x12
    ORI x30, x18, 35
    OR x2, x21, x18
    SRLI x1, x31, -198
    ADDI x30, x30, 72
    SRAI x3, x1, 50
    XORI x27, x18, 142
    OR x13, x7, x0
    SLTU x1, x26, x5
    SLTI x28, x11, 148
    SLLI x10, x2, -145
    SRAI x0, x21, -185
    ANDI x27, x21, -66
    OR x16, x1, x31
    ORI x30, x15, -26
    OR x5, x6, x29
    ANDI x0, x3, 7
    ADD x2, x7, x9
    SRL x19, x3, x19
    SRA x14, x26, x25
    ADD x29, x24, x19
    SLTU x8, x28, x6
    JAL x0, 36
    SLLI x10, x0, -138
    SRL x14, x5, x5
    ADDI x9, x16, 177
    AND x21, x18, x6
    LUI x6, -65536
    AND x8, x6, x1
    SRLI x1, x10, -123
    OR x6, x28, x8
    ORI x28, x6, 18
    ANDI x12, x1, 172
    SUB x16, x15, x25
    XOR x26, x11, x1
    SLTU x28, x8, x13
    SLTI x21, x12, 19
    SB x17, 1553(x27)
    XOR x14, x7, x17
    AUIPC x14, 0
    SLLI x13, x20, -99
    AUIPC x4, -57344
    XORI x20, x8, 94
    ANDI x1, x18, -41
    SUB x3, x1, x19
    SRLI x19, x17, 118
    XOR x10, x30, x22
    SLT x24, x5, x11
    SRAI x12, x21, 136
    XORI x1, x9, 132
    SRL x1, x1, x3
    ANDI x23, x2, -128
    SLTU x10, x20, x10
    SUB x10, x14, x3
    SLTUI x10, x12, 119
    SLTU x25, x17, x4
    JAL x18, 16
    SRL x15, x14, x15
    SUB x25, x11, x12
    SRAI x13, x9, -83
    ORI x14, x30, 152
    XORI x14, x21, -87
    SLT x8, x9, x6
    SRLI x13, x27, -147
    SUB x9, x7, x17
    SRAI x19, x9, -93
    AUIPC x26, -12288
    XORI x11, x5, 197
    SUB x1, x4, x5
    XORI x25, x8, -196
    ORI x28, x9, 31
    SH x5, 620(x27)
    AUIPC x20, -61440
    SLTU x10, x15, x31
    SLLI x31, x12, 118
    SLL x28, x22, x18
    SRLI x22, x26, 174
    LUI x5, 4096
    SRAI x19, x25, -107
    XOR x28, x8, x0
    ORI x9, x10, -4
    LUI x2, -8192
    SLL x17, x28, x9
    SUB x30, x17, x27
    BGEU x5, x13, 28
    ADD x3, x25, x5
    ANDI x8, x8, -115
    LB x23, 225(x27)
    SRAI x22, x28, 28
    SLL x3, x29, x20
    ANDI x5, x0, -104
    ADD x22, x5, x14
    SRAI x21, x3, 188
    ANDI x8, x22, -103
    SLT x1, x6, x9
    XOR x22, x20, x17
    SLTUI x21, x8, 37
    SLL x15, x26, x29
    ANDI x28, x13, 180
    SLT x2, x4, x28
    SRAI x5, x1, 64
    XOR x19, x31, x21
    XOR x15, x28, x8
    SLL x7, x29, x14
    SUB x26, x22, x9
    BNE x11, x8, 12
    ANDI x6, x11, 187
    ANDI x22, x6, -63
    OR x13, x0, x4
    SRL x23, x21, x26
    LUI x11, -45056
    SLLI x9, x20, -25
    AND x0, x30, x17
    SLTI x18, x6, 181
    SRLI x12, x25, -57
    XOR x4, x27, x17
    AND x26, x12, x8
    SLT x11, x15, x14
    SLTI x20, x7, -168
    LW x2, 52(x27)
    ADD x20, x17, x10
    SRA x24, x1, x14
    SRLI x17, x14, 191
    SRLI x0, x9, -58
    AND x20, x10, x28
    SRAI x15, x23, -16
    SRLI x26, x23, 92
    ANDI x3, x3, -39
    SLTU x17, x26, x6
    ADD x8, x6, x18
    SRAI x9, x16, -137
    SRA x19, x29, x14
    SRL x14, x20, x14
    AND x0, x14, x26
    SUB x10, x8, x27
    ANDI x2, x27, 36
    ADDI x15, x0, 146
    ANDI x22, x6, 19
    LUI x26, -36864
    SLTU x18, x14, x23
    JAL x10, 12
    SLTU x18, x30, x18
    OR x31, x14, x12
    ADDI x26, x21, 12
    SB x9, 369(x27)
    ADDI x11, x3, -177
    ADDI x17, x2, 64
    XORI x5, x3, -101
    AND x25, x12, x24
    LUI x19, 49152
    XORI x14, x21, 111
    SLTUI x21, x26, -9
    SLTI x0, x2, -81
    LUI x5, -24576
    AUIPC x23, 73728
    SLTUI x4, x22, 23
    XORI x22, x20, 30
    SLL x12, x19, x22
    OR x7, x25, x11
    SLT x2, x0, x0
    ANDI x3, x21, 64
    SLTU x18, x23, x4
    ADDI x18, x30, -43
    SLT x2, x20, x0
    AUIPC x14, -8192
    ORI x1, x15, 138
    XOR x13, x2, x25
    SLT x31, x12, x1
    SLTI x20, x29, 144
    SLT x9, x8, x3
    XOR x24, x29, x14
    LUI x13, -20480
    AUIPC x13, 0
    ADDI x13, x13, 8
    JALR x0, 36(x13)
    ANDI x5, x2, -64
    SLL x26, x16, x24
    ORI x14, x22, 111
    SRAI x19, x4, -112
    ANDI x11, x14, 69
    SRL x5, x31, x3
    ORI x10, x28, 48
    SLTUI x31, x27, -87
    SRAI x21, x29, 132
    SB x26, 359(x27)
    XOR x7, x7, x28
    ANDI x15, x21, -137
    XOR x13, x14, x12
    LUI x14, -16384
    SLT x0, x19, x19
    SUB x20, x22, x13
    AND x11, x21, x26
    ANDI x30, x11, -154
    SUB x23, x3, x9
    SRLI x9, x22, -149
    SLTU x4, x26, x14
    SLL x11, x25, x31
    XORI x31, x16, -32
    LUI x3, 86016
    ADDI x20, x13, 132
    SRA x10, x3, x2
    LUI x1, 0
    SRL x19, x15, x10
    ANDI x2, x18, 118
    SLLI x29, x2, 105
    ORI x30, x26, -66
    ANDI x0, x9, -13
    OR x19, x20, x18
    AND x21, x3, x1
    ADD x2, x22, x23
    SLTU x1, x17, x7
    SUB x29, x29, x18
    BLT x15, x10, 32
    SRL x31, x8, x28
    SRA x15, x31, x13
    SRL x7, x26, x5
    ADD x24, x1, x20
    SRAI x24, x22, 91
    ADDI x8, x2, 61
    LUI x23, -8192
    SLLI x2, x12, 52
    SRL x2, x1, x29
    AUIPC x31, 45056
    SRLI x17, x8, 91
    LUI x13, 77824
    SRL x21, x18, x3
    XOR x26, x20, x16
    SRAI x10, x22, -54
    LHU x11, 166(x27)
    SLTUI x9, x21, -188
    SRLI x25, x6, -4
    SLTI x28, x6, 110
    ORI x12, x14, 32
    XORI x2, x1, -48
    ADD x26, x25, x24
    ADD x13, x4, x22
    SLL x1, x26, x21
    AUIPC x29, -90112
    SLT x27, x23, x1
    SLT x5, x25, x17
    JAL x19, 8
    SLL x23, x3, x11
    SRA x20, x18, x19
    OR x28, x5, x23
    SUB x11, x6, x17
    SRLI x21, x5, -156
    SLTUI x18, x28, -38
    SRL x26, x15, x17
    SRA x11, x25, x28
    XOR x23, x29, x15
    SLT x27, x23, x10
    ADD x21, x23, x11
    ORI x13, x8, 127
    ADDI x19, x12, 163
    XORI x20, x14, -175
    AUIPC x20, 36864
    SLTI x0, x1, -75
    ADD x30, x27, x29
    LH x17, 234(x27)
    SLLI x7, x16, -36
    SLL x6, x2, x3
    SLT x20, x31, x28
    OR x19, x24, x9
    SLTU x23, x1, x27
    SRLI x10, x11, 55
    SLT x18, x28, x20
    SLL x17, x0, x0
    SUB x28, x8, x13
    SLTUI x25, x9, -13
    SLTI x22, x3, -76
    SRA x24, x5, x22
    SLLI x27, x25, 88
    SLL x0, x16, x26
    SRAI x1, x9, -27
    XORI x6, x12, -33
    AUIPC x17, -28672
    ADDI x27, x16, 187
    SUB x23, x2, x31
    SRLI x3, x3, -18
    ORI x8, x8, -125
    ADDI x1, x19, -182
    SUB x27, x19, x14
    SUB x21, x1, x12
    AUIPC x1, 0
    ADDI x1, x1, 8
    JALR x7, 36(x1)
    ORI x23, x23, 58
    AND x11, x22, x9
    SLTUI x23, x15, -77
    SLTI x14, x14, 21
    SRA x15, x20, x2
    ORI x1, x11, 94
    ANDI x25, x5, 94
    ANDI x18, x24, -124
    SUB x6, x24, x5
    XOR x2, x3, x25
    SLTI x28, x1, 36
    SLLI x12, x0, 136
    AND x14, x17, x7
    AND x1, x18, x29
    SLLI x8, x1, -109
    SUB x23, x29, x18
    SB x18, 116(x27)
    ORI x31, x2, 175
    ANDI x24, x3, -115
    SLTU x15, x27, x23
    SRL x27, x18, x10
    ORI x19, x4, 108
    ADDI x13, x10, -176
    AND x17, x17, x2
    SRAI x1, x30, -65
    AUIPC x10, -20480
    SRL x2, x1, x3
    AND x21, x24, x0
    SLTI x23, x11, 71
    SLTUI x15, x8, -130
    SRAI x25, x25, -152
    ORI x8, x22, -144
    SRA x22, x30, x18
    SRLI x27, x11, -109
    OR x29, x11, x22
    AND x3, x29, x22
    XORI x30, x7, 20
    SRA x5, x14, x14
    OR x5, x30, x28
    LUI x3, -73728
    SLTU x23, x4, x29
    SRLI x17, x19, -118
    SRLI x7, x10, -20
    SRL x9, x15, x5
    XORI x9, x24, -200
    XOR x25, x1, x13
    AUIPC x31, -40960
    LUI x15, 8192
    XOR x16, x8, x4
    LUI x7, 20480
    ORI x22, x17, -34
    SRA x13, x4, x16
    ADD x29, x4, x4
    ADD x31, x23, x21
    ADD x26, x6, x25
    SLTU x3, x9, x24
    ADD x15, x15, x30
    AUIPC x20, 0
    ADDI x20, x20, 8
    JALR x28, 4(x20)
    LUI x16, 24576
    ADDI x18, x2, 85
    SB x7, 899(x27)
    SLL x4, x10, x31
    XORI x28, x25, -73
    SLT x4, x20, x25
    XOR x10, x11, x12
    SRA x28, x27, x0
    SLT x24, x0, x17
    ANDI x20, x23, 106
    AUIPC x13, -32768
    SRL x23, x31, x27
    SLTUI x11, x5, -72
    LUI x17, -57344
    SUB x1, x24, x15
    SLTUI x26, x24, -114
    OR x8, x21, x23
    JAL x20, 20
    AUIPC x1, -28672
    SUB x28, x28, x13
    SUB x30, x24, x20
    AUIPC x2, 24576
    SLL x6, x11, x15
    SUB x11, x18, x13
    SLLI x19, x8, 27
    SLTUI x31, x31, 63
    XORI x16, x8, -115
    SUB x3, x8, x4
    SLT x12, x2, x14
    SRA x12, x14, x20
    ADD x20, x8, x11
    SRA x16, x16, x2
    SLTUI x16, x8, -127
    OR x9, x10, x21
    SRAI x19, x16, -85
    SUB x13, x28, x14
    XORI x5, x15, 196
    ORI x8, x9, 129
    ANDI x28, x0, 95
    SLTUI x17, x3, 129
    SRL x21, x9, x24
    LHU x29, 148(x27)
    SRLI x13, x16, -193
    ADD x17, x20, x18
    SRAI x18, x2, -189
    AND x26, x26, x28
    XOR x3, x19, x10
    XORI x16, x25, -18
    XOR x28, x22, x0
    SRA x23, x23, x2
    SLTU x21, x30, x1
    SRA x30, x11, x29
    OR x19, x10, x30
    ADDI x16, x22, -7
    OR x27, x31, x10
    SUB x30, x8, x14
    XORI x19, x2, 173
    AND x25, x30, x2
    OR x26, x10, x7
    SLT x29, x9, x13
    SRL x1, x14, x25
    XORI x31, x2, -46
    SLT x24, x12, x21
    SUB x12, x12, x7
    SRL x5, x5, x10
    SLT x28, x31, x22
    LUI x18, -61440
    LUI x8, -36864
    ADDI x29, x5, 185
    AND x29, x22, x26
    SLT x0, x6, x2
    XOR x4, x12, x23
    SRAI x12, x31, -128
    SLT x18, x27, x9
    SRLI x9, x6, -18
    ORI x11, x23, -49
    BNE x21, x5, 20
    SLTI x12, x20, -92
    SUB x16, x20, x30
    OR x16, x4, x8
    SRLI x7, x31, -70
    ORI x7, x22, 33
    SLLI x1, x2, -111
    XOR x11, x28, x18
    AUIPC x28, -28672
    SRA x16, x23, x13
    SLL x0, x22, x17
    SRLI x15, x21, -155
    XOR x31, x17, x20
    XORI x4, x0, 67
    AUIPC x9, 16384
    SB x19, 129(x27)
    LUI x27, 8192
    XORI x16, x31, 194
    SRLI x11, x7, 4
    LUI x9, -57344
    SRL x19, x4, x7
    SRA x12, x2, x31
    AND x5, x10, x13
    SRLI x10, x8, -188
    ADD x3, x13, x5
    XORI x12, x27, -128
    ORI x22, x18, 72
    BGEU x1, x23, 20
    SLT x25, x0, x22
    ADD x21, x4, x18
    SLLI x21, x5, -94
    LH x28, 232(x27)
    SRLI x1, x16, 0
    SLLI x7, x13, -105
    SRLI x15, x17, -168
    AUIPC x27, 86016
    ADD x23, x8, x15
    XORI x24, x24, 0
    ANDI x15, x31, 127
    ORI x17, x0, 2
    OR x27, x26, x24
    ADDI x0, x27, 40
    AND x7, x17, x5
    SLL x7, x15, x29
    SLTI x13, x17, -75
    SLLI x5, x18, -104
    XOR x23, x14, x24
    ADD x29, x22, x17
    SLTU x3, x30, x26
    SUB x0, x4, x9
    SLTU x24, x5, x23
    XOR x21, x18, x3
    SRA x27, x8, x8
    SRA x1, x16, x6
    BGEU x9, x2, 40
    AUIPC x13, -49152
    SLL x24, x11, x16
    SLT x30, x19, x16
    SRL x16, x6, x7
    SLLI x25, x3, -180
    ANDI x7, x1, 139
    SLT x8, x2, x8
    XORI x9, x14, 176
    SLLI x18, x18, -177
    SLLI x16, x12, -174
    SW x31, 1052(x27)
    ORI x7, x21, -134
    SLTI x1, x4, 40
    AUIPC x14, 4096
    XOR x30, x18, x3
    LUI x8, -4096
    SLL x14, x13, x29
    AUIPC x5, -16384
    SRLI x13, x23, -49
    SRLI x11, x0, -170
    SUB x23, x25, x10
    SLL x22, x7, x15
    XOR x8, x19, x17
    SUB x27, x13, x20
    AND x28, x0, x6
    SLL x3, x15, x1
    AND x21, x28, x12
    ANDI x18, x1, -70
    SRL x10, x2, x8
    ADD x9, x17, x26
    SLTU x23, x31, x5
    SLT x6, x30, x23
    AUIPC x9, 0
    ADDI x9, x9, 8
    JALR x28, 24(x9)
    SRAI x30, x12, 12
    LUI x8, 16384
    SRAI x13, x1, 40
    SRLI x15, x6, 58
    ADDI x5, x28, -6
    SW x15, 492(x27)
    SUB x25, x16, x4
    LUI x8, 61440
    XORI x9, x13, -43
    SUB x11, x6, x17
    ANDI x8, x8, 160
    ANDI x15, x26, 50
    SUB x25, x8, x7
    SRAI x11, x6, -139
    SUB x27, x5, x20
    ANDI x23, x28, -68
    SLTI x12, x26, -48
    ADDI x4, x18, 106
    XORI x0, x6, 152
    SLT x29, x19, x26
    ORI x12, x25, -172
    SRLI x3, x22, -16
    XOR x9, x10, x9
    ADDI x19, x16, 164
    SLLI x7, x29, 72
    AND x1, x4, x7
    XOR x16, x26, x6
    AUIPC x16, 0
    ADDI x16, x16, 8
    JALR x7, 40(x16)
    ADDI x8, x30, 118
    SRL x30, x2, x7
    SLTI x30, x4, 167
    ANDI x4, x15, 130
    SLL x20, x10, x20
    SRL x3, x14, x16
    SRL x22, x11, x16
    SUB x12, x21, x13
    SLL x7, x10, x18
    ANDI x16, x14, -116
    LW x2, 4(x27)
    ADDI x2, x23, -180
    SLTUI x21, x25, -93
    ADDI x17, x22, 22
    ORI x9, x18, -188
    JAL x2, 20
    SRAI x12, x0, -62
    ADDI x18, x31, -16
    SLTI x8, x0, -128
    SRL x5, x26, x19
    SLTUI x29, x7, 48
    SLTU x10, x27, x12
    OR x19, x9, x27
    ORI x23, x27, 83
    ORI x1, x3, -46
    AND x12, x1, x20
    SUB x2, x28, x20
    XOR x13, x21, x7
    XORI x10, x20, 57
    SLT x16, x8, x27
    SH x7, 2042(x27)
    SRLI x21, x27, 89
    LUI x11, 16384
    SLTI x15, x21, -116
    AND x3, x24, x24
    OR x22, x7, x8
    SRA x9, x29, x26
    LUI x13, -77824
    LUI x4, -4096
    SLLI x24, x6, -107
    SLTUI x0, x0, 23
    ANDI x30, x0, 32
    SLTU x5, x12, x3
    SRA x22, x0, x8
    XORI x28, x30, -23
    AUIPC x18, 16384
    ADD x0, x9, x18
    ANDI x6, x24, 99
    JAL x4, 4
    ANDI x2, x21, 190
    SLT x14, x7, x23
    SRAI x4, x6, 114
    LH x4, 90(x27)
    SLL x9, x5, x4
    SLLI x25, x12, 17
    ORI x10, x7, 179
    SLT x31, x30, x18
    XOR x2, x19, x6
    SLLI x11, x10, -14
    SLTUI x21, x5, 136
    SLTI x22, x17, -170
    XOR x22, x21, x23
    SLTUI x14, x23, -145
    SRA x23, x7, x11
    ADDI x10, x26, -147
    SLTI x3, x26, -199
    SLT x9, x11, x12
    ADD x0, x31, x20
    SLTI x22, x6, 45
    BGEU x2, x19, 40
    SLT x6, x10, x14
    AND x5, x0, x1
    SUB x23, x22, x20
    ANDI x23, x29, 81
    XOR x0, x12, x27
    SLTI x5, x15, 135
    SLL x2, x8, x28
    SRAI x11, x21, 134
    ORI x0, x1, -13
    SLTU x27, x1, x29
    SRLI x21, x8, 18
    SLTUI x14, x3, -99
    SLTI x5, x1, -139
    OR x18, x30, x9
    XOR x19, x10, x6
    SRAI x30, x10, -71
    ADDI x10, x13, 108
    SLLI x31, x9, 99
    XORI x18, x18, 140
    SLT x22, x15, x20
    SLTUI x27, x29, -141
    XOR x23, x9, x25
    ORI x7, x22, 150
    OR x7, x18, x19
    SW x14, 1320(x27)
    SLT x10, x1, x20
    AND x26, x18, x12
    SUB x15, x1, x16
    SRLI x29, x17, 72
    AND x1, x31, x31
    AUIPC x3, 8192
    ADD x2, x24, x8
    SLLI x16, x26, 55
    AUIPC x14, 24576
    SRL x15, x9, x11
    OR x19, x25, x24
    AUIPC x4, 4096
    SLL x27, x3, x24
    SRLI x1, x28, -46
    ADDI x6, x14, -169
    BLTU x8, x28, 36
    LUI x5, -32768
    SLL x31, x31, x27
    SLTU x9, x20, x16
    SLLI x18, x16, -103
    SUB x25, x19, x30
    SLLI x29, x7, 117
    XORI x10, x26, 52
    SRL x30, x24, x28
    SRAI x25, x30, -169
    SH x3, 1046(x27)
    SLTI x18, x6, -57
    SRLI x2, x16, 114
    OR x2, x24, x6
    SLTUI x28, x28, 13
    SRA x7, x3, x11
    ORI x26, x25, -22
    AUIPC x30, -49152
    SLTUI x8, x15, -31
    ANDI x13, x18, -194
    AUIPC x21, -4096
    SLLI x10, x26, 115
    ORI x15, x20, 158
    LUI x18, -24576
    BEQ x11, x29, 4
    SLT x12, x14, x28
    SLL x11, x4, x4
    AUIPC x2, 28672
    SRLI x17, x8, -139
    XORI x9, x23, 48
    ORI x17, x19, 64
    SLT x14, x24, x25
    LBU x9, 223(x27)
    LUI x21, -16384
    SLT x19, x14, x30
    SLTU x27, x14, x10
    SRLI x21, x12, -40
    ORI x8, x29, 52
    SUB x23, x28, x12
    XORI x25, x18, 97
    ADDI x28, x18, 182
    SRAI x1, x7, -131
    SLTUI x8, x20, -141
    SRA x9, x16, x7
    ORI x9, x9, -186
    ORI x16, x27, -108
    SRA x30, x22, x23
    SUB x10, x17, x3
    XORI x17, x0, -118
    XORI x28, x28, 60
    ORI x20, x7, 115
    XOR x2, x2, x27
    BGE x1, x26, 8
    AND x12, x16, x0
    SUB x26, x9, x1
    ANDI x23, x20, -25
    ADDI x1, x21, 160
    AUIPC x8, -90112
    SRLI x14, x19, -149
    OR x29, x27, x1
    ADDI x25, x20, -172
    ADDI x7, x13, -48
    SLTI x1, x4, -96
    SLT x17, x20, x31
    SRL x4, x30, x14
    SW x24, 504(x27)
    SLT x27, x6, x17
    XOR x11, x15, x14
    SRL x12, x25, x11
    SUB x23, x12, x11
    SLLI x20, x7, 127
    SRA x27, x3, x4
    AND x8, x2, x16
    SRA x24, x29, x13
    ANDI x9, x8, -128
    SRLI x24, x12, -48
    ANDI x26, x4, 82
    SRAI x4, x15, 46
    SLL x27, x10, x15
    SLTU x12, x2, x12
    SLT x13, x30, x18
    SRAI x3, x17, -140
    SRAI x7, x4, -113
    SLTUI x7, x17, 46
    SRA x29, x19, x26
    SLL x19, x7, x26
    SLTU x27, x11, x27
    AUIPC x19, 0
    ADDI x19, x19, 8
    JALR x9, 36(x19)
    SLLI x3, x0, 87
    LUI x6, 53248
    ADD x29, x5, x23
    SRA x4, x2, x25
    ORI x16, x26, -125
    AND x20, x15, x20
    SLL x14, x24, x16
    AND x12, x20, x14
    SRLI x30, x30, -197
    ORI x16, x31, -6
    SLL x29, x24, x17
    ADDI x24, x2, -194
    SLLI x3, x31, -72
    SW x28, 1692(x27)
    XOR x28, x1, x8
    SLL x15, x15, x4
    ANDI x3, x19, -55
    SLLI x29, x10, -193
    OR x11, x14, x20
    XORI x0, x0, -32
    ORI x3, x14, -33
    XOR x4, x16, x22
    SUB x11, x11, x20
    XORI x2, x31, -19
    SLL x11, x12, x18
    ADD x18, x13, x29
    SLTI x26, x6, 8
    SLTI x4, x20, 172
    SLTI x23, x6, -28
    SLTUI x8, x0, 148
    SLTUI x4, x18, -186
    SLL x26, x27, x12
    ORI x25, x9, -113
    ANDI x19, x27, 161
    SRA x0, x15, x9
    SLT x25, x18, x27
    SRLI x31, x5, -147
    SUB x9, x3, x30
    LUI x31, 49152
    SRL x8, x18, x17
    AUIPC x16, 28672
    SLTI x5, x25, -111
    ORI x24, x31, -130
    ADDI x28, x5, 127
    LUI x20, -61440
    ANDI x25, x17, -108
    ORI x8, x22, 94
    SLL x1, x13, x1
    BLTU x4, x29, 20
    XOR x13, x14, x6
    SLL x14, x15, x23
    SLL x0, x10, x13
    SRLI x5, x1, 112
    ANDI x4, x11, 40
    SLTU x9, x10, x8
    SLTI x30, x23, 171
    ADD x25, x10, x12
    SLL x22, x24, x16
    XOR x28, x19, x8
    ORI x8, x7, -47
    SLT x15, x17, x29
    SLTI x6, x19, 129
    ORI x20, x3, -2
    SLTU x20, x29, x11
    LW x25, 104(x27)
    LUI x8, -45056
    SLTUI x15, x3, -57
    ANDI x31, x21, 96
    XORI x19, x25, 92
    SLT x28, x24, x23
    SUB x25, x25, x23
    LUI x0, -16384
    XORI x19, x26, -143
    SRLI x21, x15, -47
    ADDI x21, x15, 54
    SLTI x6, x5, -185
    SUB x31, x23, x21
    SLL x10, x0, x19
    SRL x17, x23, x26
    AND x7, x10, x13
    AND x3, x1, x18
    LUI x24, 81920
    JAL x9, 32
    SLT x4, x30, x16
    SLTU x9, x31, x9
    SRA x31, x13, x23
    SRLI x2, x31, -98
    ANDI x19, x7, 124
    SLTU x24, x7, x31
    SLTI x10, x27, -74
    SRA x1, x7, x6
    SLL x12, x13, x18
    SLL x11, x21, x13
    XORI x23, x27, 21
    AUIPC x8, -16384
    SUB x4, x30, x20
    SRAI x19, x19, 144
    OR x23, x23, x26
    SRA x7, x28, x2
    ANDI x26, x16, -43
    LUI x12, -12288
    SUB x0, x3, x31
    SLLI x17, x9, 182
    XOR x27, x20, x20
    SLLI x19, x5, -67
    XOR x29, x3, x30
    XORI x18, x27, 169
    SUB x19, x21, x19
    SRL x30, x11, x26
    SH x23, 1816(x27)
    SLTUI x20, x21, -60
    XOR x21, x20, x11
    XORI x16, x3, 66
    OR x15, x25, x25
    SLLI x9, x26, 106
    SLT x18, x21, x30
    AND x25, x15, x4
    SRA x17, x17, x29
    SRA x15, x0, x25
    SUB x14, x11, x20
    ORI x27, x20, 143
    ADDI x23, x6, -195
    SLTU x7, x2, x15
    ORI x7, x14, 127
    SLTU x10, x8, x28
    SLL x28, x24, x26
    AND x13, x13, x16
    XORI x23, x17, 63
    SLLI x4, x30, 111
    ADDI x22, x1, -109
    ANDI x22, x15, 174
    SLTI x29, x21, -178
    ADD x25, x26, x29
    ORI x5, x25, 121
    SRLI x26, x18, -97
    BGE x23, x20, 12
    ANDI x6, x31, -78
    SLTUI x7, x1, -9
    SLLI x5, x0, 20
    AND x26, x7, x15
    SRA x22, x19, x19
    SLTI x30, x8, -131
    SUB x7, x21, x18
    SLTUI x3, x20, 171
    ADDI x5, x6, 173
    SLTI x7, x12, -56
    SRL x1, x1, x4
    SRA x13, x7, x11
    SLTUI x0, x2, 89
    XORI x7, x10, 9
    ADDI x24, x31, -145
    SUB x26, x26, x11
    AUIPC x21, 20480
    SRL x27, x16, x19
    SLTUI x6, x20, 14
    SLLI x29, x16, 181
    ADD x21, x25, x19
    ADDI x20, x30, 192
    SH x6, 1840(x27)
    OR x15, x26, x17
    ADDI x17, x19, -61
    SRLI x21, x4, -137
    ANDI x28, x1, -64
    ADD x0, x1, x24
    SRA x10, x17, x16
    XOR x10, x14, x7
    SLLI x25, x3, 110
    OR x19, x7, x7
    SLT x25, x28, x31
    AND x4, x20, x28
    SLTI x8, x13, 72
    SLTUI x30, x11, -76
    SLLI x6, x8, -192
    SLTUI x24, x22, -185
    SLLI x9, x0, 110
    SRL x1, x17, x16
    XORI x10, x0, -64
    AND x11, x11, x8
    BGEU x17, x20, 12
    ANDI x2, x3, -63
    LUI x25, 53248
    ADD x7, x12, x19
    XOR x10, x12, x20
    ADDI x30, x28, -101
    SRL x22, x18, x10
    SB x24, 1303(x27)
    SLTI x10, x30, -90
    ORI x6, x21, 151
    AUIPC x31, -4096
    SRA x19, x3, x27
    JAL x0, 4
    SRAI x9, x16, 102
    AND x22, x7, x14
    AND x1, x30, x26
    SRLI x2, x15, -99
    SRAI x24, x20, -20
    LUI x15, -61440
    SLTUI x1, x5, 184
    ORI x20, x6, -164
    ADD x31, x5, x7
    LUI x9, 32768
    SRA x23, x20, x14
    ANDI x7, x18, 19
    AND x26, x25, x24
    SLTI x17, x27, -172
    ANDI x4, x29, 27
    LUI x19, 28672
    SLTI x29, x2, -25
    AUIPC x21, 32768
    SH x3, 284(x27)
    SLTI x25, x25, 190
    AUIPC x4, -12288
    ANDI x21, x16, 153
    SLL x7, x4, x10
    ORI x23, x1, 148
    LUI x3, 86016
    ORI x31, x16, 26
    SLL x5, x23, x23
    ADD x24, x10, x1
    SLTU x24, x28, x3
    SLTI x3, x12, 85
    LUI x19, 8192
    AND x13, x6, x25
    XOR x7, x22, x25
    AND x10, x7, x11
    SLL x2, x8, x16
    XOR x1, x7, x6
    SRLI x6, x11, -6
    XORI x13, x18, -17
    SLL x27, x14, x24
    SRLI x28, x21, -30
    SLL x20, x2, x17
    ADDI x5, x16, -50
    SRAI x0, x20, -61
    SUB x1, x26, x8
    SRL x18, x30, x1
    SLLI x13, x5, 94
    AUIPC x15, -98304
    LUI x13, -32768
    AUIPC x3, -32768
    ADDI x19, x11, -24
    AUIPC x29, 0
    ADDI x29, x29, 8
    JALR x11, 8(x29)
    SLLI x2, x9, -151
    AUIPC x25, 40960
    SLTU x24, x31, x14
    LUI x14, 20480
    ADD x30, x19, x25
    OR x17, x11, x4
    ADDI x12, x18, -129
    SLTI x30, x29, 123
    SRAI x31, x14, -16
    ORI x25, x16, -54
    LB x10, 183(x27)
    SUB x26, x28, x27
    OR x15, x27, x27
    SUB x12, x30, x30
    SLTUI x29, x10, -65
    ADD x24, x27, x20
    ANDI x4, x14, 200
    SLTI x1, x19, -159
    SLTU x22, x23, x6
    OR x0, x10, x24
    OR x17, x0, x23
    ADD x22, x30, x4
    LUI x31, -73728
    ORI x4, x25, -195
    AND x3, x10, x22
    XORI x21, x12, -21
    SRLI x27, x31, 116
    AND x18, x12, x2
    SRLI x29, x26, -79
    AUIPC x25, -73728
    SUB x17, x5, x10
    SRA x15, x6, x21
    SRL x9, x10, x25
    SUB x14, x3, x24
    ANDI x31, x30, -145
    AUIPC x14, 0
    ADDI x14, x14, 8
    JALR x6, 32(x14)
    SLTU x17, x8, x23
    OR x4, x3, x25
    AUIPC x21, 40960
    ADDI x21, x16, 65
    SLT x27, x17, x14
    SRLI x22, x19, -4
    ANDI x30, x1, 104
    SRAI x18, x22, -15
    SH x27, 1710(x27)
    OR x8, x6, x6
    SLLI x23, x3, -191
    ORI x25, x30, -113
    SLLI x5, x17, 25
    SLTU x25, x28, x5
    SLL x24, x30, x22
    SRLI x7, x4, 148
    ADDI x19, x0, -34
    SLTI x7, x13, -146
    SRAI x7, x20, -179
    SUB x15, x0, x28
    SRLI x6, x8, -118
    SUB x18, x10, x2
    SLTU x24, x1, x24
    SRA x20, x11, x16
    ORI x31, x9, 140
    ORI x13, x18, -45
    SLTUI x24, x15, 41
    SLL x18, x1, x6
    AUIPC x14, 0
    ADDI x14, x14, 8
    JALR x12, 4(x14)
    XORI x7, x4, 131
    SLT x28, x16, x15
    ADD x24, x13, x5
    OR x5, x16, x9
    LHU x21, 118(x27)
    AUIPC x0, 40960
    SLLI x24, x5, 170
    SRLI x11, x8, 193
    ANDI x2, x6, 78
    OR x30, x30, x5
    ADDI x7, x23, -105
    LUI x8, -4096
    ADD x24, x17, x25
    AUIPC x15, -4096
    JAL x10, 8
    AUIPC x13, -4096
    SLL x18, x0, x9
    SRL x31, x4, x29
    AND x19, x2, x26
    LBU x15, 17(x27)
    OR x3, x9, x11
    SRAI x26, x30, 101
    SUB x4, x16, x28
    AUIPC x29, 36864
    AND x17, x19, x21
    ORI x5, x5, -191
    ANDI x1, x7, -122
    SLTU x1, x30, x20
    SRLI x2, x17, 189
    SLTU x13, x31, x8
    SLL x29, x6, x5
    LUI x15, -12288
    SUB x6, x24, x20
    SRAI x10, x26, -103
    SRL x10, x17, x3
    SLTUI x19, x23, -83
    ORI x27, x17, -105
    LUI x7, 28672
    SLTUI x18, x26, -63
    BGE x26, x23, 8
    OR x19, x16, x8
    SRLI x14, x20, -49
    SUB x26, x17, x28
    SRAI x23, x18, 127
    XORI x6, x17, -127
    SLL x0, x5, x8
    SRL x22, x28, x9
    ORI x18, x26, -27
    ADD x0, x22, x4
    SW x20, 1176(x27)
    SRA x11, x8, x6
    XORI x9, x7, 64
    SLL x10, x14, x25
    AND x27, x7, x10
    XORI x12, x30, 131
    ADDI x4, x21, 46
    ADDI x28, x27, -140
    SLTI x27, x0, 82
    AND x24, x4, x9
    SRAI x13, x31, -36
    SLL x3, x13, x14
    OR x6, x18, x5
    SLTI x21, x0, 64
    XOR x30, x22, x6
    SRLI x12, x31, -91
    SLT x5, x30, x1
    SLL x13, x1, x30
    LUI x28, -65536
    SLL x17, x25, x14
    SLLI x6, x29, -22
    SRLI x25, x12, 152
    SRA x28, x30, x18
    SLL x4, x21, x30
    SRLI x9, x8, -37
    SLT x16, x23, x1
    BEQ x18, x19, 16
    LUI x31, -49152
    SLLI x22, x12, 127
    AND x18, x15, x22
    SLTI x30, x1, -137
    SLLI x29, x28, -126
    LUI x13, -28672
    SLLI x24, x20, -145
    ANDI x1, x16, -74
    SUB x23, x13, x11
    SRAI x14, x6, 186
    AUIPC x26, 8192
    SRAI x28, x16, -87
    AND x16, x5, x12
    ADD x5, x4, x0
    AUIPC x27, -65536
    ORI x6, x31, 85
    LUI x15, 45056
    SRLI x30, x6, -79
    SRAI x27, x20, 124
    SH x2, 1990(x27)
    XOR x4, x24, x20
    SLTUI x8, x14, -46
    AUIPC x7, 8192
    ANDI x11, x9, 194
    
    jal x22,  exiting_step
    li x23, 0xFFFF      # Should skip
exiting_step:
    li x31, 0x80012100
    li x30, 0xFFFFFFFF
    # this notifies UVM testbench to stop execution
    sw x30, 0(x31)
