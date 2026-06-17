import random as rand
from enum import Enum, auto

# General Utils
InstrType = [ "R-Type", "I-Type", "S-Type", "B-Type", "U-Type", "J-Type"]
InstrType2 = [ "ALU", "LOAD", "STORE", "BRANCH", "JAL", "JALR", "LUI", "AUIPC"]
def get_op_code(type: str, type2: str):
    opcode = "-Invalid_Opcode-"
    if (type == "R-Type"):
        opcode = 0b0110011
    elif (type == "I-Type" and type2 == "ALU"):
        opcode = 0b0010011
    elif (type2 == "LOAD"):
        opcode = 0b0000011
    elif (type2 == "STORE"):
        opcode = 0b0100011
    elif (type2 == "BRANCH"):
        opcode = 0b1100011
    elif (type2 == "JAL"):
        opcode = 0b1101111
    elif (type2 == "JALR"):
        opcode = 0b1100111
    elif (type2 == "LUI"):
        opcode = 0b0110111
    elif (type2 == "AUIPC"):
        opcode = 0b0010111
    return opcode

# ALU R-Type Utils
ALU_R_ops = ["ADD", "SUB", "XOR", "OR", "AND", "SLL", "SRL", "SRA", "SLT", "SLTU"]
ALU_R_funct3_map = {
    "ADD":  0b000,
    "SUB":  0b000,
    "XOR":  0b100,
    "OR":   0b110,
    "AND":  0b111,
    "SLL":  0b001,
    "SRL":  0b101,
    "SRA":  0b101,
    "SLT":  0b010,
    "SLTU": 0b011
}
ALU_R_funct7_map = {
    "ADD":  0b0000000,
    "SUB":  0b0100000,
    "XOR":  0b0000000,
    "OR":   0b0000000,
    "AND":  0b0000000,
    "SLL":  0b0000000,
    "SRL":  0b0000000,
    "SRA":  0b0100000,
    "SLT":  0b0000000,
    "SLTU": 0b0000000
}
def get_alu_r_op_from_bin_32(bin_32: str) -> str:
    funct3 = int(bin_32[17:20], 2)
    funct7 = int(bin_32[0:7], 2)
    if funct3 == 0b000:
        if funct7 == 0b0000000:
            return "ADD"
        elif funct7 == 0b0100000:
            return "SUB"
    elif funct3 == 0b100:
        return "XOR"
    elif funct3 == 0b110:
        return "OR"
    elif funct3 == 0b111:
        return "AND"
    elif funct3 == 0b001:
        return "SLL"
    elif funct3 == 0b101:
        if funct7 == 0b0000000:
            return "SRL"
        elif funct7 == 0b0100000:
            return "SRA"
    elif funct3 == 0b010:
        return "SLT"
    elif funct3 == 0b011:
        return "SLTU"
    raise ValueError("Invalid ALU R-type instruction")

# ALU I-Type Utils
ALU_I_ops = [ "ADDI", "XORI", "ORI", "ANDI", "SLLI", "SRLI", "SRAI", "SLTI", "SLTUI" ]
ALU_I_funct3_map = {
    "ADDI":  0b000,
    "XORI":  0b100,
    "ORI":   0b110,
    "ANDI":  0b111,
    "SLLI":  0b001,
    "SRLI":  0b101,
    "SRAI":  0b101,
    "SLTI":  0b010,
    "SLTUI": 0b011
}
def get_alu_i_op_from_bin_32(bin_32: str) -> str:
    funct3 = int(bin_32[17:20], 2)
    imm_str = bin_32[0:12]
    if funct3 == 0b000:
        return "ADDI"
    elif funct3 == 0b100:
        return "XORI"
    elif funct3 == 0b110:
        return "ORI"
    elif funct3 == 0b111:
        return "ANDI"
    elif funct3 == 0b001:
        return "SLLI"
    elif funct3 == 0b101:
        if int(imm_str[0:8], 2) == 0x00:
            return "SRLI"
        elif int(imm_str[0:8], 2) == 0x20:
            return "SRAI"
        else:
            raise ValueError("Invalid SR ALU I-type instruction")
    elif funct3 == 0b010:
        return "SLTI"
    elif funct3 == 0b011:
        return "SLTUI"
    raise ValueError("Invalid ALU I-type instruction")

# LOAD Utils 
LOAD_ops = ["LB", "LH", "LW", "LBU", "LHU"]
LOAD_funct3_map = {
    "LB":  0b000,
    "LH":  0b001,
    "LW":  0b010,
    "LBU": 0b100,
    "LHU": 0b101
}
LOAD_ops_byte_read_sizing_map = {
    "LB":  1,
    "LH":  2,
    "LW":  4,
    "LBU": 1,
    "LHU": 2
}
def get_load_op_from_bin_32(bin_32: str) -> str:
    ...


# STORE Utils
STORE_ops = ["SB", "SH", "SW"]
STORE_funct3_map = {
    "SB":  0b000,
    "SH":  0b001,
    "SW":  0b010
}
STORE_ops_byte_write_sizing_map = {
    "SB":  1,
    "SH":  2,
    "SW":  4
}

# BRANCH Utils
BRANCH_ops = ["BEQ", "BNE", "BLT", "BGE", "BLTU", "BGEU"]
BRANCH_funct3_map = {
    "BEQ":  0b000,
    "BNE":  0b001,
    "BLT":  0b100,
    "BGE":  0b101,
    "BLTU": 0b110,
    "BGEU": 0b111
}


def random_type2_on_type(instr_type: str):
    type2 = None
    match instr_type:
        case "R_TYPE":
            type2 = "ALU"
        case "I_TYPE":
            type2 = rand.choice(["ALU", "LOAD", "JALR"])
        case "S_TYPE":
            type2 = "STORE"
        case "B_TYPE":
            type2 = "BRANCH"
        case "U_TYPE":
            type2 = rand.choice(["LUI", "AUIPC"])
        case "J_TYPE":
            type2 = "JAL"
    return type2

def random_type_on_type2(type2: str):
    type = None
    match type2:
        case "ALU":
            type = rand.choice(["R_TYPE", "I_TYPE"])
        case "LOAD":
            type = "I_TYPE"
        case "STORE":
            type = "S_TYPE"
        case "BRANCH":
            type = "B_TYPE"
        case "JAL":
            type = "J_TYPE"
        case "JALR":
            type = "I_TYPE"
        case "LUI":
            type = "U_TYPE"
        case "AUIPC":
            type = "U_TYPE"
    return type

def compute_alu_r_op(op: str, rs1: int, rs2: int) -> int:
    if op == "ADD":
        return rs1 + rs2
    elif op == "SUB":
        return rs1 - rs2
    elif op == "XOR":
        return rs1 ^ rs2
    elif op == "OR":
        return rs1 | rs2
    elif op == "AND":
        return rs1 & rs2
    elif op == "SLL":
        return rs1 << (rs2 & 0x1F)
    elif op == "SRL":
        return rs1 >> (rs2 & 0x1F)
    elif op == "SRA":
        return rs1 >> (rs2 & 0x1F)
    elif op == "SLT":
        return 1 if rs1 < rs2 else 0
    elif op == "SLTU":
        return 1 if rs1 < rs2 else 0
    else:
        raise ValueError("Invalid ALU R-type operation")
    
def compute_alu_i_op(op: str, rs1: int, imm: int) -> int:
    if op == "ADDI":
        return rs1 + imm
    elif op == "SLTI":
        return 1 if rs1 < imm else 0
    elif op == "SLTUI":
        return 1 if rs1 < imm else 0
    elif op == "XORI":
        return rs1 ^ imm
    elif op == "ORI":
        return rs1 | imm
    elif op == "ANDI":
        return rs1 & imm
    elif op == "SLLI":
        return rs1 << (imm & 0x1F)
    elif op == "SRLI":
        return rs1 >> (imm & 0x1F)
    elif op == "SRAI":
        return rs1 >> (imm & 0x1F)
    else:
        raise ValueError("Invalid ALU I-type operation")

def compute_branch_op(op: str, rs1: int, rs2: int) -> bool:
    if op == "BEQ":
        return rs1 == rs2
    elif op == "BNE":
        return rs1 != rs2
    elif op == "BLT":
        return rs1 < rs2
    elif op == "BGE":
        return rs1 >= rs2
    elif op == "BLTU":
        return rs1 < rs2
    elif op == "BGEU":
        return rs1 >= rs2
    else:
        raise ValueError("Invalid branch operation")

def sign_extend_load(value: int, load_op: str, data_bitwidth: int) -> int:
    assert data_bitwidth == 32, "Data bitwidth must be 32"
    if load_op == "LB":
        msb = value & 0x80
        if msb:
            return value | 0xFFFFFF00
        else:
            return value & 0x000000FF
    elif load_op == "LH":
        msb = value & 0x8000
        if msb:
            return value | 0xFFFF0000
        else:
            return value & 0x0000FFFF
    else:
        return value

class Register:
    def __init__(self, value: int = 0):
        self.value = value
        self.committed = False

    def write(self, value: int):
        self.value = value
        self.committed = True

class Register_File:
    def __init__(self, num_regs: int = 32):
        self.regs = [Register() for _ in range(num_regs)] 
        self.num_regs = num_regs
        self.committed_regs = set()

    def commit_reg(self, reg_index: int, value: int):
        assert 0 <= reg_index < self.num_regs
        self.regs[reg_index].write(value)
        self.committed_regs.add(reg_index)

    def get_committed_reg_file(self) -> list[tuple[int, int]]:
        commit_reg_file = []
        for i in range(self.num_regs):
            if self.regs[i].committed:
                commit_reg_file.append((i, self.regs[i].value))
        return commit_reg_file

    def get_reg_value(self, reg_index: int) -> int:
        assert 0 <= reg_index < self.num_regs, "Register index out of bounds"
        assert self.regs[reg_index].committed, "Register not committed"
        return self.regs[reg_index].value

class MemoryByte:
    def __init__(self, value: int = 0):
        self.value = value
        # self.written = False

    def write(self, value: int):
        self.value = value
        # self.written = True

    def read(self) -> int:
        # assert self.written, "Memory byte not written to"
        return self.value

class Memory:
    def __init__(self, size: int = 1024):
        self.data = [MemoryByte() for _ in range(size)]
        self.size = size
        self.valid_address_ranges = []

    def read(self, addr: int, byte_size: int) -> int:
        assert 0 <= addr < self.size, "Base address out of bounds"
        assert byte_size > 0, "Byte size must be positive"
        assert addr + byte_size <= self.size, "Read range out of bounds"
        value = 0
        # little endian
        for i in range(byte_size):
            value |= (self.data[addr + i].read() << (i * 8))
        return value

    def write_byte(self, addr: int, value: int):
        assert 0 <= addr < self.size, "Address out of bounds"
        self.data[addr].write(value)
        # insert/conjoin valid address ranges
        if not self.valid_address_ranges:
            self.valid_address_ranges.append((addr, addr))
        else:
            for i, (start, end) in enumerate(self.valid_address_ranges):
                if addr < start:
                    prev_start = -2
                    prev_end = -2
                    if i > 0:
                        prev_start = self.valid_address_ranges[i-1][0]
                        prev_end   = self.valid_address_ranges[i-1][1]
                    if prev_end == addr - 1 and start == addr + 1:
                        self.valid_address_ranges.insert(
                            i-1, 
                            (prev_start, end)
                        )
                        self.valid_address_ranges.pop(i)
                        self.valid_address_ranges.pop(i+1)
                        break
                    elif prev_end == addr - 1:
                        self.valid_address_ranges.insert(
                            i-1, 
                            (prev_start, addr)
                        )
                        self.valid_address_ranges.pop(i) 
                        break
                    elif start == addr + 1:
                        self.valid_address_ranges.insert(
                            i, 
                            (addr, end)
                        )
                        self.valid_address_ranges.pop(i+1) 
                        break
                if start <= addr <= end:
                    break
                elif i == len(self.valid_address_ranges)-1:
                    if addr == end + 1:
                        self.valid_address_ranges.insert(
                            i,
                            (start, addr)
                        )
                        self.valid_address_ranges.pop(i+1)
                        break
                    else:
                        self.valid_address_ranges.insert(
                            i,
                            (addr, addr)
                        )
                        break

    # not very efficient with use of write_byte
    def write(self, addr: int, value: int, byte_size: int):
        assert 0 <= addr < self.size, "Base address out of bounds"
        assert byte_size > 0, "Byte size must be positive"
        assert addr + byte_size <= self.size, "Write range out of bounds"
        # little endian
        for i in range(byte_size):
            self.write_byte(addr + i, (value >> (i * 8)) & 0xFF)
    
    def check_addr_written(self, addr: int):
        for start, end in self.valid_address_ranges:
            if start <= addr <= end:
                return True
        return False

class Instr:
    def __init__(self, type=None, type2=None):
        self.type = None
        self.type2 = None

    def randomize_type(self):
        self.type = rand.choice(InstrType)
        self.type2 = random_type2_on_type(self.type)

    def randomize_type2(self):
        self.type2 = rand.choice(InstrType2)
        self.type = random_type_on_type2(self.type2)

    def randomize_alu_r_instr(self, commited_regs: set[int]):
        assert len(commited_regs) > 0, "No committed registers available"
        assert self.type == "R_TYPE", "Invalid instruction type"
        assert self.type2 == "ALU", "Invalid instruction type2"
        self.alu_r_op = rand.choice(ALU_R_ops)
        self.funct3 = ALU_R_funct3_map[self.alu_r_op]
        self.funct7 = ALU_R_funct7_map[self.alu_r_op]
        self.rs1 = rand.choice(list(commited_regs))
        self.rs2 = rand.choice(list(commited_regs))
        self.rd = rand.randint(0, 31)
        self.opcode = get_op_code(self.type, self.type2)
        self.bits = f"{self.funct7:07b}{self.rs2:05b}{self.rs1:05b}{self.funct3:03b}{self.rd:05b}{self.opcode:07b}"
        self.complete = True

    def randomize_alu_i_instr(self, commited_regs: set[int]):
        assert len(commited_regs) > 0, "No committed registers available"
        assert self.type == "I_TYPE", "Invalid instruction type"
        assert self.type2 == "ALU", "Invalid instruction type2"
        self.alu_i_op = rand.choice(ALU_I_ops)
        self.funct3 = ALU_I_funct3_map[self.alu_i_op]
        self.rs1 = rand.choice(list(commited_regs))
        self.imm = rand.randint(0, 2**12 - 1)
        self.rd = rand.randint(0, 31)
        self.opcode = get_op_code(self.type, self.type2)
        self.bits = f"{self.imm:012b}{self.rs1:05b}{self.funct3:03b}{self.rd:05b}{self.opcode:07b}"
        self.complete = True

    # needs to be aligned accesses
    # randomization has linear space/time complexity scaling
    # ASSUME valid_address_ranges has already been conjoined and sorted
    def randomize_load_instr(
            self, 
            register_file: Register_File,
            valid_address_ranges: list[tuple[int, int]],
            max_attempts: int
        ):
        commited_register_file = register_file.get_committed_reg_file()
        assert len(commited_register_file) > 0, "No committed registers available"
        assert len(valid_address_ranges) > 0, "No valid address ranges available"
        assert self.type == "I_TYPE", "Invalid instruction type"
        assert self.type2 == "LOAD", "Invalid instruction type2"
    
        found_valid_addr = False
        attempts = 0
        while not found_valid_addr and attempts < max_attempts:
            attempts += 1
            addr_trgt = rand.choice([addr for start, end in valid_address_ranges for addr in range(start, end + 1)])
            load_type = rand.choice(LOAD_ops)
            load_width = LOAD_ops_byte_read_sizing_map[load_type]
            # guarantee mem_alignment
            addr_trgt = addr_trgt - (addr_trgt % load_width)
            # check if entire load width is within a valid address range
            load_within_range = False
            for (start, end) in valid_address_ranges:
                if start <= addr_trgt <= end:
                    if (addr_trgt + load_width - 1) <= end:
                        load_within_range = True
                    else:
                        break
            if not load_within_range: continue
            # check if a valid register can be used as the base for the load
            reachable_reg = None
            for reg_entry in rand.sample(commited_register_file, k=len(commited_register_file)):
                diff = addr_trgt - reg_entry[1]
                imm_valid = diff >= -2048 and diff < 2048
                if imm_valid:
                    reachable_reg = reg_entry[0]
                    break
            if reachable_reg is None: continue
            found_valid_addr = True
        
        if (attempts >= max_attempts):
            raise ValueError("Failed to generate a valid load instruction after maximum attempts")
        
        # self.addr_trgt = addr_trgt
        self.load_type = load_type
        self.funct3 = LOAD_funct3_map[self.load_type]
        self.load_width = load_width
        self.rs1 = reachable_reg
        self.imm = (addr_trgt - register_file.regs[reachable_reg].value) & 0xFFF
        self.rd = rand.randint(0, register_file.num_regs-1)
        self.opcode = get_op_code(self.type, self.type2)
        self.bits = f"{self.imm:012b}{self.rs1:05b}{self.funct3:03b}{self.rd:05b}{self.opcode:07b}"
        self.complete = True

    def randomize_store_instr(
            self, 
            register_file: Register_File,
            address_range: tuple[int, int], 
            max_attempts: int
        ):
        commited_register_file = register_file.get_committed_reg_file()
        assert len(commited_register_file) > 0, "No committed registers available"
        assert self.type == "S_TYPE", "Invalid instruction type"
        assert self.type2 == "STORE", "Invalid instruction type2"
        
        found_valid_addr = False
        attempts = 0
        while not found_valid_addr and attempts < max_attempts:
            attempts += 1
            addr_trgt = rand.randint(address_range[0], address_range[1])
            store_type = rand.choice(STORE_ops)
            store_width = STORE_ops_byte_write_sizing_map[store_type]
            # guarantee mem_alignment
            addr_trgt = addr_trgt - (addr_trgt % store_width)
            # check if entire store width is within address range
            store_within_range = False
            if address_range[0] <= addr_trgt <= address_range[1]:
                if (addr_trgt + store_width - 1) <= address_range[1]:
                    store_within_range = True
            if not store_within_range: continue
            # check if a valid register can be used as the base for the store
            reachable_reg = None
            for reg_entry in rand.sample(commited_register_file, k=len(commited_register_file)):
                diff = addr_trgt - reg_entry[1]
                imm_valid = diff >= -2048 and diff < 2048
                if imm_valid:
                    reachable_reg = reg_entry[0]
                    break
            if reachable_reg is None: continue
            found_valid_addr = True
        
        if (attempts >= max_attempts):
            raise ValueError("Failed to generate a valid store instruction after maximum attempts")
        
        # self.addr_trgt = addr_trgt
        self.store_type = store_type
        self.funct3 = STORE_funct3_map[self.store_type]
        self.store_width = store_width
        self.rs1 = reachable_reg
        self.imm = (addr_trgt - register_file.regs[reachable_reg].value) & 0xFFF
        self.rs2 = rand.randint(0, register_file.num_regs-1)
        self.opcode = get_op_code(self.type, self.type2)
        imm_11_5 = (self.imm >> 5) & 0x7F
        imm_4_0 = self.imm & 0x1F
        self.bits = f"{imm_11_5:07b}{self.rs2:05b}{self.rs1:05b}{self.funct3:03b}{imm_4_0:05b}{self.opcode:07b}"
        self.complete = True

    def randomize_branch_instr(
            self, 
            register_file: Register_File, 
            instr_address_range: tuple[int, int], 
            pc: int,
            max_attempts: int
            ):
        commited_register_file = register_file.get_committed_reg_file()
        # assert len(register_file.committed_regs) > 0, "No committed registers available"
        assert len(commited_register_file) > 0, "No committed registers available"
        assert self.type == "B_TYPE", "Invalid instruction type"
        assert self.type2 == "BRANCH", "Invalid instruction type2"
        
        found_valid_addr = False
        attempts = 0
        while not found_valid_addr and attempts < max_attempts:
            attempts += 1
            addr_trgt = rand.randint(instr_address_range[0], instr_address_range[1])
            branch_addr_width = 4
            # guarantee mem_alignment
            addr_trgt = addr_trgt - (addr_trgt % branch_addr_width)
            # check if entire branch address width is within instr address range
            trgt_within_range = False
            if instr_address_range[0] <= addr_trgt <= instr_address_range[1]:
                if (addr_trgt + branch_addr_width - 1) <= instr_address_range[1]:
                    trgt_within_range = True
            if not trgt_within_range: continue
            # check if a pc can be used as the base for the branch
            reachable = False
            diff = addr_trgt - pc
            imm_valid = diff >= -4096 and diff < 4096
            if imm_valid:
                reachable = True
                break
            if not reachable: continue
            found_valid_addr = True

        self.branch_op = rand.choice(BRANCH_ops)
        self.funct3 = BRANCH_funct3_map[self.branch_op]
        self.rs1 = rand.choice(list(register_file.committed_regs))
        self.rs2 = rand.choice(list(register_file.committed_regs))
        self.imm = (addr_trgt - pc) & 0x1FFF
        self.opcode = get_op_code(self.type, self.type2)

        imm_12 = (self.imm >> 12) & 1
        imm_11 = (self.imm >> 11) & 1
        imm_10_5 = (self.imm >> 5) & 0x3F
        imm_4_1 = (self.imm >> 1) & 0xF
        self.bits = (
            f"{imm_12:01b}"
            f"{imm_10_5:06b}"
            f"{self.rs2:05b}"
            f"{self.rs1:05b}"
            f"{self.funct3:03b}"
            f"{imm_4_1:04b}"
            f"{imm_11:01b}"
            f"{self.opcode:07b}"
        )
        self.complete = True

    def randomize_jal_instr(
            self, 
            register_file: Register_File, 
            instr_address_range: tuple[int, int], 
            pc: int, 
            max_attempts: int
            ):
        assert self.type == "J_TYPE", "Invalid instruction type"
        assert self.type2 == "JAL", "Invalid instruction type2"
        
        found_valid_addr = False
        attempts = 0
        while not found_valid_addr and attempts < max_attempts:
            attempts += 1
            addr_trgt = rand.randint(instr_address_range[0], instr_address_range[1])
            jump_addr_width = 4
            # guarantee mem_alignment
            addr_trgt = addr_trgt - (addr_trgt % jump_addr_width)
            # check if entire jump address width is within instr address range
            jump_within_range = False
            if instr_address_range[0] <= addr_trgt <= instr_address_range[1]:
                if (addr_trgt + jump_addr_width - 1) <= instr_address_range[1]:
                    jump_within_range = True
            if not jump_within_range: continue
            # check if a pc can be used as the base for the jump
            reachable = False
            diff = addr_trgt - pc
            imm_valid = diff >= -1048576 and diff < 1048576
            if imm_valid:
                reachable = True
                break
            if not reachable: continue
            found_valid_addr = True

        self.rd = rand.randint(0, register_file.num_regs - 1)
        self.imm = (addr_trgt - pc) & 0x1FFFFF
        self.opcode = get_op_code(self.type, self.type2)

        imm_20 = (self.imm >> 20) & 1
        imm_19_12 = (self.imm >> 12) & 0xFF
        imm_11 = (self.imm >> 11) & 0x1
        imm_10_1 = (self.imm >> 1) & 0x3FF
        self.bits = f"{imm_20:01b}{imm_10_1:010b}{imm_11:01b}{imm_19_12:08b}{self.rd:05b}{self.opcode:07b}"
        self.complete = True

    def randomize_jalr_instr(
            self, 
            register_file: Register_File, 
            instr_address_range: tuple[int, int],
            max_attempts: int
            ):
        commited_register_file = register_file.get_committed_reg_file()
        assert len(commited_register_file) > 0, "No committed registers available"
        assert self.type == "I_TYPE", "Invalid instruction type"
        assert self.type2 == "JALR", "Invalid instruction type2"
    
        found_valid_addr = False
        attempts = 0
        while not found_valid_addr and attempts < max_attempts:
            attempts += 1
            addr_trgt = rand.choice([addr for start, end in instr_address_range for addr in range(start, end + 1)])
            jump_addr_width = 4
            # guarantee mem_alignment
            addr_trgt = addr_trgt - (addr_trgt % jump_addr_width)
            # check if entire jump address width is within a valid address range
            jump_within_range = False
            if instr_address_range[0] <= addr_trgt <= instr_address_range[1]:
                if (addr_trgt + jump_addr_width - 1) <= instr_address_range[1]:
                    jump_within_range = True
            if not jump_within_range: continue
            # check if a valid register can be used as the base for the jump
            reachable_reg = None
            for reg_entry in rand.sample(commited_register_file, k=len(commited_register_file)):
                diff = addr_trgt - reg_entry[1]
                imm_valid = diff >= -2048 and diff < 2048
                if imm_valid:
                    reachable_reg = reg_entry[0]
                    break
            if reachable_reg is None: continue
            found_valid_addr = True
        
        if (attempts >= max_attempts):
            raise ValueError("Failed to generate a valid load instruction after maximum attempts")
        
        # self.addr_trgt = addr_trgt
        self.funct3 = 0b000
        self.rs1 = reachable_reg
        self.imm = (addr_trgt - register_file.regs[reachable_reg].value) & 0xFFF
        self.rd = rand.randint(0, register_file.num_regs-1)
        self.opcode = get_op_code(self.type, self.type2)
        self.bits = f"{self.imm:012b}{self.rs1:05b}{self.funct3:03b}{self.rd:05b}{self.opcode:07b}"
        self.complete = True

    def randomize_lui_instr(self):
        assert self.type == "U_TYPE", "Invalid instruction type"
        assert self.type2 == "LUI", "Invalid instruction type2"
        self.imm = (rand.randint(0, (2 ** 32) - 1) >> 12) << 12
        self.rd = rand.randint(0, 31)
        self.opcode = get_op_code(self.type, self.type2)
        imm_31_12 = self.imm >> 12 & 0xFFFFF
        self.bits = f"{imm_31_12:020b}{self.rd:05b}{self.opcode:07b}"
        self.complete = True

    def randomize_auipc_instr(self):
        assert self.type == "U_TYPE", "Invalid instruction type"
        assert self.type2 == "AUIPC", "Invalid instruction type2"
        self.imm = (rand.randint(0, (2 ** 32) - 1) >> 12) << 12
        self.rd = rand.randint(0, 31)
        self.opcode = get_op_code(self.type, self.type2)
        imm_31_12 = self.imm >> 12 & 0xFFFFF
        self.bits = f"{imm_31_12:020b}{self.rd:05b}{self.opcode:07b}"
        self.complete = True

    def randomize(self, 
                register_file: Register_File,
                memory: Memory,
                pc: int,
                instr_address_range: tuple[int, int],
                max_attempts: int
        ):
        self.randomize_type2()
        if self.type2 == "ALU" and self.type == "R_TYPE":
            self.randomize_alu_r_instr(register_file.committed_regs)
        elif self.type2 == "ALU" and self.type == "I_TYPE":
            self.randomize_alu_i_instr(register_file.committed_regs)
        elif self.type2 == "LOAD":
            self.randomize_load_instr(register_file, memory.valid_address_ranges, max_attempts)
        elif self.type2 == "STORE":
            self.randomize_store_instr(register_file, memory.valid_address_ranges, max_attempts)
        elif self.type2 == "BRANCH":
            self.randomize_branch_instr(register_file, instr_address_range, pc, max_attempts)
        elif self.type2 == "JAL":
            self.randomize_jal_instr(register_file, instr_address_range, pc, max_attempts)
        elif self.type2 == "JALR":
            self.randomize_jalr_instr(register_file, instr_address_range, max_attempts)
        elif self.type2 == "LUI":
            self.randomize_lui_instr()
        elif self.type2 == "AUIPC":
            self.randomize_auipc_instr()

    def gen_assembly_str(self) -> str:
        instr_name = None
        operand_1 = None
        operand_2 = None
        operand_3 = None

        if self.type2 == "ALU" and self.type == "R_TYPE":
            instr_name = self.alu_r_op
            operand_1 = self.rd
            operand_2 = self.rs1
            operand_3 = self.rs2
        elif self.type2 == "ALU" and self.type == "I_TYPE":
            instr_name = self.alu_i_op
            operand_1 = self.rd
            operand_2 = self.rs1
            operand_3 = self.imm
        elif self.type2 == "LOAD":
            instr_name = self.load_type
            operand_1 = self.rd
            operand_2 = f"{self.imm}({self.rs1})"
        elif self.type2 == "STORE":
            instr_name = self.store_type
            operand_1 = self.rs2
            operand_2 = f"{self.imm}({self.rs1})"
        elif self.type2 == "BRANCH":
            instr_name = self.branch_type
            operand_1 = self.rs1
            operand_2 = self.rs2
            if hasattr(self, "label"):
                operand_3 = self.label
            else:
                operand_3 = self.imm
        elif self.type2 == "JAL":
            instr_name = "JAL"
            operand_1 = self.rd
            if hasattr(self, "label"):
                operand_2 = self.label
            else:
                operand_2 = self.imm
        elif self.type2 == "JALR":
            instr_name = "JALR"
            operand_1 = self.rd
            operand_2 = f"{self.imm}({self.rs1})"
        elif self.type2 == "LUI":
            instr_name = "LUI"
            operand_1 = self.rd
            operand_2 = f"{self.imm} (note: this is full value)"
        elif self.type2 == "AUIPC":
            instr_name = "AUIPC"
            operand_1 = self.rd
            operand_2 = f"{self.imm} (note: this is full value)"

        result = ""
        assert instr_name is not None, "Instruction name is None"
        if operand_1 is not None:
            result += f"{instr_name} {operand_1}"
        if operand_2 is not None:
            result += f", {operand_2}"
        if operand_3 is not None:
            result += f", {operand_3}"

        return result


def create_alu_r_instr(
        alu_r_op: str,
        rd: int,
        rs1: int,
        rs2: int
) -> Instr:
    instr = Instr()
    instr.type2 = "ALU"
    instr.type = "R_TYPE"
    instr.alu_r_op = alu_r_op
    instr.funct3 = ALU_R_funct3_map[alu_r_op]
    instr.funct7 = ALU_R_funct7_map[alu_r_op]
    instr.rs1 = rs1
    instr.rs2 = rs2
    instr.rd = rd
    instr.opcode = get_op_code(instr.type, instr.type2)
    instr.bits = f"{instr.funct7:07b}{instr.rs2:05b}{instr.rs1:05b}{instr.funct3:03b}{instr.rd:05b}{instr.opcode:07b}"
    instr.complete = True
    return instr

def create_alu_i_instr(
        alu_i_op: str,
        rd: int,
        rs1: int,
        imm: int
) -> Instr:
    instr = Instr()
    instr.type2 = "ALU"
    instr.type = "I_TYPE"
    instr.alu_i_op = alu_i_op
    instr.funct3 = ALU_I_funct3_map[alu_i_op]
    instr.rs1 = rs1
    instr.imm = imm
    instr.rd = rd
    instr.opcode = get_op_code(instr.type, instr.type2)
    instr.bits = f"{instr.imm:012b}{instr.rs1:05b}{instr.funct3:03b}{instr.rd:05b}{instr.opcode:07b}"
    instr.complete = True
    return instr

def create_load_instr(
        load_type: str,
        rd: int,
        rs1: int,
        imm: int
) -> Instr:
    instr = Instr()
    instr.type2 = "LOAD"
    instr.type = "I_TYPE"
    instr.load_type = load_type
    instr.funct3 = LOAD_funct3_map[load_type]
    instr.load_width = LOAD_ops_byte_read_sizing_map[load_type]
    instr.rs1 = rs1
    instr.imm = imm
    instr.rd = rd
    instr.opcode = get_op_code(instr.type, instr.type2)
    instr.bits = f"{instr.imm:012b}{instr.rs1:05b}{instr.funct3:03b}{instr.rd:05b}{instr.opcode:07b}"
    instr.complete = True
    return instr

def create_store_instr(
        store_type: str,
        rs1: int,
        rs2: int,
        imm: int
) -> Instr:
    instr = Instr()
    instr.type2 = "STORE"
    instr.type = "S_TYPE"
    instr.store_type = store_type
    instr.funct3 = STORE_funct3_map[store_type]
    instr.store_width = STORE_ops_byte_write_sizing_map[store_type]
    instr.rs1 = rs1
    instr.imm = imm
    instr.rs2 = rs2
    instr.opcode = get_op_code(instr.type, instr.type2)
    imm_11_5 = (instr.imm >> 5) & 0x7F
    imm_4_0 = instr.imm & 0x1F
    instr.bits = f"{imm_11_5:07b}{instr.rs2:05b}{instr.rs1:05b}{instr.funct3:03b}{imm_4_0:05b}{instr.opcode:07b}"
    instr.complete = True
    return instr

def create_branch_instr(
        branch_type: str,
        rs1: int,
        rs2: int,
        imm: int,
        label: str = None
) -> Instr:
    instr = Instr()
    instr.type2 = "BRANCH"
    instr.type = "B_TYPE"
    instr.branch_type = branch_type
    instr.funct3 = BRANCH_funct3_map[branch_type]
    instr.rs1 = rs1
    instr.rs2 = rs2
    instr.imm = imm
    instr.opcode = get_op_code(instr.type, instr.type2)
    imm_12 = (instr.imm >> 12) & 0x1
    imm_11 = (instr.imm >> 11) & 0x1
    imm_10_5 = (instr.imm >> 5) & 0x3F
    imm_4_1 = (instr.imm >> 1) & 0xF
    instr.bits = (
        f"{imm_12:01b}"
        f"{imm_10_5:06b}"
        f"{instr.rs2:05b}"
        f"{instr.rs1:05b}"
        f"{instr.funct3:03b}"
        f"{imm_4_1:04b}"
        f"{imm_11:01b}"
        f"{instr.opcode:07b}"
    )
    if label is not None:
        instr.label = label
    instr.complete = True
    return instr

def create_jal_instr(
        rd: int,
        imm: int,
        label: str = None
) -> Instr:
    instr = Instr()
    instr.type2 = "JAL"
    instr.type = "J_TYPE"
    instr.rd = rd
    instr.imm = imm
    instr.opcode = get_op_code(instr.type, instr.type2)
    imm_20 = (instr.imm >> 20) & 1
    imm_19_12 = (instr.imm >> 12) & 0xFF
    imm_11 = (instr.imm >> 11) & 0x1
    imm_10_1 = (instr.imm >> 1) & 0x3FF
    instr.bits = f"{imm_20:01b}{imm_10_1:010b}{imm_11:01b}{imm_19_12:08b}{instr.rd:05b}{instr.opcode:07b}"
    if label is not None:
        instr.label = label
    instr.complete = True
    return instr

def create_jalr_instr(
        rd: int,
        rs1: int,
        imm: int,
        label: str = None
) -> Instr:
    instr = Instr()
    instr.type2 = "JALR"
    instr.type = "I_TYPE"
    instr.funct3 = 0b000
    instr.rs1 = rs1
    instr.imm = imm
    instr.rd = rd
    instr.opcode = get_op_code(instr.type, instr.type2)
    instr.bits = f"{instr.imm:012b}{instr.rs1:05b}{instr.funct3:03b}{instr.rd:05b}{instr.opcode:07b}"
    if label is not None:
        instr.label = label
    instr.complete = True
    return instr

def create_lui_instr(
        rd: int,
        imm: int
) -> Instr:
    instr = Instr()
    instr.type2 = "LUI"
    instr.type = "U_TYPE"
    instr.rd = rd
    instr.imm = imm
    instr.opcode = get_op_code(instr.type, instr.type2)
    imm_31_12 = instr.imm >> 12 & 0xFFFFF
    instr.bits = f"{imm_31_12:020b}{instr.rd:05b}{instr.opcode:07b}"
    instr.complete = True
    return instr

def create_auipc_instr(
        rd: int,
        imm: int
) -> Instr:
    instr = Instr()
    instr.type2 = "AUIPC"
    instr.type = "U_TYPE"
    instr.rd = rd
    instr.imm = imm
    instr.opcode = get_op_code(instr.type, instr.type2)
    imm_31_12 = instr.imm >> 12 & 0xFFFFF
    instr.bits = f"{imm_31_12:020b}{instr.rd:05b}{instr.opcode:07b}"
    instr.complete = True
    return instr

def create_alu_r_instr_from_bin(bin_str: str) -> Instr:
    alu_r_op = 
    instr = create_alu_r_instr(0, 0, 0)
    return instr

class Program:
    def __init__(
            self,
            data_mem_size: int = 1024,
            instr_mem_size: int = 1024
        ):
        self.register_file = Register_File()
        self.memory = Memory(data_mem_size)
        self.instructions = []
        self.pc = 0
        self.instr_addr_range = (0, instr_mem_size-1)

    def gen_random_instr(self, max_attempts: int = 100) -> Instr:
        instr = Instr()
        instr.randomize_type2()
        if instr.type2 == "ALU" and instr.type == "R_TYPE":
            instr.randomize_alu_r_instr(
                self.register_file.committed_regs
            )
        elif instr.type2 == "ALU" and instr.type == "I_TYPE":
            instr.randomize_alu_i_instr(
                self.register_file.committed_regs
            )
        elif instr.type2 == "LOAD":
            instr.randomize_load_instr(
                self.register_file,
                self.memory.valid_address_ranges,
                max_attempts
            )
        elif instr.type2 == "STORE":
            instr.randomize_store_instr(
                self.register_file,
                (0, self.memory.size-1),
                max_attempts
            )
        elif instr.type2 == "BRANCH":
            instr.randomize_branch_instr(
                self.register_file,
                self.instr_addr_range,
                self.pc,
                max_attempts
            )
        elif instr.type2 == "JAL":
            instr.randomize_jal_instr(
                self.register_file,
                self.instr_addr_range,
                self.pc,
                max_attempts
            )
        elif instr.type2 == "JALR":
            instr.randomize_jalr_instr(
                self.register_file,
                self.instr_addr_range,
                max_attempts
            )
        elif instr.type2 == "LUI":
            instr.randomize_lui_instr()
        elif instr.type2 == "AUIPC":
            instr.randomize_auipc_instr()
        else:
            raise ValueError("Invalid instruction type or type2")
        
        return instr

    def register_r_op(self, instr: Instr):
        rs1_value = self.register_file.get_reg_value(instr.rs1)
        rs2_value = self.register_file.get_reg_value(instr.rs2)
        rd_value = compute_alu_r_op(instr.alu_r_op, rs1_value, rs2_value)
        self.register_file.commit_reg(instr.rd, rd_value)
        self.pc += 4
    
    def register_i_op(self, instr: Instr):
        rs1_value = self.register_file.get_reg_value(instr.rs1)
        imm_value = instr.imm
        rd_value = compute_alu_i_op(instr.alu_i_op, rs1_value, imm_value)
        self.register_file.commit_reg(instr.rd, rd_value)
        self.pc += 4

    def register_load_instr(self, instr: Instr):
        rs1_value = self.register_file.get_reg_value(instr.rs1)
        imm_value = instr.imm
        addr = rs1_value + imm_value
        data = self.memory.read(addr, self.load_width)
        data = sign_extend_load(data, self.load_type, 32)
        self.register_file.commit_reg(instr.rd, data)
        self.pc += 4

    def register_store_instr(self, instr: Instr):
        rs1_value = self.register_file.get_reg_value(instr.rs1)
        imm_value = instr.imm
        addr = rs1_value + imm_value
        data = self.register_file.get_reg_value(instr.rs2)
        self.memory.write(addr, data, self.store_width)
        self.pc += 4
    
    def register_branch_instr(self, instr: Instr):
        rs1_value = self.register_file.get_reg_value(instr.rs1)
        rs2_value = self.register_file.get_reg_value(instr.rs2)
        branch_taken = compute_branch_op(instr.branch_op, rs1_value, rs2_value)
        if branch_taken:
            self.pc += instr.imm
        else:
            self.pc += 4

    def register_jal_instr(self, instr: Instr):
        self.register_file.commit_reg(instr.rd, self.pc + 4)
        self.pc += instr.imm
    
    def register_jalr_instr(self, instr: Instr):
        self.register_file.commit_reg(instr.rd, self.pc + 4)
        self.pc = self.register_file.get_reg_value(instr.rs1) + instr.imm
    
    def register_lui_instr(self, instr: Instr):
        self.register_file.commit_reg(instr.rd, instr.imm)
        self.pc += 4

    def register_auipc_instr(self, instr: Instr):
        self.register_file.commit_reg(instr.rd, self.pc + instr.imm)
        self.pc += 4

    def register_instr(self, instr: Instr):
        if instr.type2 == "ALU" and instr.type == "R_TYPE":   self.register_r_op(instr)
        elif instr.type2 == "ALU" and instr.type == "I_TYPE": self.register_i_op(instr)
        elif instr.type2 == "LOAD":     self.register_load_instr(instr)
        elif instr.type2 == "STORE":    self.register_store_instr(instr)
        elif instr.type2 == "BRANCH":   self.register_branch_instr(instr)
        elif instr.type2 == "JAL":      self.register_jal_instr(instr)
        elif instr.type2 == "JALR":     self.register_jalr_instr(instr)
        elif instr.type2 == "LUI":      self.register_lui_instr(instr)
        elif instr.type2 == "AUIPC":    self.register_auipc_instr(instr)
        else:
            raise ValueError("Invalid instruction type or type2")
    
    def gen_rand_program_seq(self, num_instr: int, max_attempts: int):
        for _ in range(num_instr):
            instr = Instr()
            instr.randomize(
                self.register_file,
                self.memory,
                self.pc,
                self.instr_address_range,
                max_attempts
            )
            self.register_instr(instr)
            self.instructions.append(instr)


if __name__ == "__main__":
    program = Program()


