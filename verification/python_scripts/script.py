import random as rand
from enum import Enum, auto
import sys

def print_to_file(filename, content, append=False):
    mode = "a" if append else "w"
    with open(filename, mode, encoding="utf-8") as f:
        f.write(content)

# General Utils
InstrType = [ "R-TYPE", "I-TYPE", "S-TYPE", "B-TYPE", "U-TYPE", "J-TYPE"]
InstrType2 = [ "ALU", "LOAD", "STORE", "BRANCH", "JAL", "JALR", "LUI", "AUIPC"]
InstrType3 = ["ALU_R", "ALU_I", "LOAD", "STORE", "BRANCH", "JAL", "JALR", "LUI", "AUIPC"]
def get_op_code(type: str, type2: str):
    opcode = "-Invalid_Opcode-"
    if (type == "R-TYPE"):
        opcode = 0b0110011
    elif (type == "I-TYPE" and type2 == "ALU"):
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
def get_types_from_opcode(opcode: str) -> tuple[str, str]:
    type = "-Invalid_Type-"
    type2 = "-Invalid_Type2-"
    if opcode == 0b0110011:
        type = "R-TYPE"
        type2 = "ALU"
    elif opcode == 0b0010011:
        type = "I-TYPE"
        type2 = "ALU"
    elif opcode == 0b0000011:
        type = "I-TYPE"
        type2 = "LOAD"
    elif opcode == 0b0100011:
        type = "S-TYPE"
        type2 = "STORE"
    elif opcode == 0b1100011:
        type = "B-TYPE"
        type2 = "BRANCH"
    elif opcode == 0b1101111:
        type = "J-TYPE"
        type2 = "JAL"
    elif opcode == 0b1100111:
        type = "I-TYPE"
        type2 = "JALR"
    elif opcode == 0b0110111:
        type = "U-TYPE"
        type2 = "LUI"
    elif opcode == 0b0010111:
        type = "U-TYPE"
        type2 = "AUIPC"
    return (type, type2)

# ALU R-TYPE Utils
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

# ALU I-TYPE Utils
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
    rev_load_funct3 = {value: key for key, value in LOAD_funct3_map.items()}
    funct3 = int(bin_32[17:20], 2)
    return rev_load_funct3[funct3]

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
def get_store_op_from_bin_32(bin_32: str) -> str:
    rev_store_funct3 = {value: key for key, value in STORE_funct3_map.items()}
    funct3 = int(bin_32[17:20], 2)
    return rev_store_funct3[funct3]

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
def get_branch_op_from_bin_32(bin_32: str) -> str:
    rev_branch_funct3 = {value: key for key, value in BRANCH_funct3_map.items()}
    funct3 = int(bin_32[17:20], 2)
    return rev_branch_funct3[funct3]


def random_type2_on_type(instr_type: str):
    type2 = None
    match instr_type:
        case "R-TYPE":
            type2 = "ALU"
        case "I-TYPE":
            type2 = rand.choice(["ALU", "LOAD", "JALR"])
        case "S-TYPE":
            type2 = "STORE"
        case "B-TYPE":
            type2 = "BRANCH"
        case "U-TYPE":
            type2 = rand.choice(["LUI", "AUIPC"])
        case "J-TYPE":
            type2 = "JAL"
    return type2

def random_type_on_type2(type2: str):
    type = None
    match type2:
        case "ALU":
            type = rand.choice(["R-TYPE", "I-TYPE"])
        case "LOAD":
            type = "I-TYPE"
        case "STORE":
            type = "S-TYPE"
        case "BRANCH":
            type = "B-TYPE"
        case "JAL":
            type = "J-TYPE"
        case "JALR":
            type = "I-TYPE"
        case "LUI":
            type = "U-TYPE"
        case "AUIPC":
            type = "U-TYPE"
    return type

def random_types_on_type3(type3: str) -> tuple[str, str]:
    match type3:
        case "ALU_R":
            return ("R-TYPE", "ALU")
        case "ALU_I":
            return ("I-TYPE", "ALU")
        case "LOAD":
            return ("I-TYPE", "LOAD")
        case "STORE":
            return ("S-TYPE", "STORE")
        case "BRANCH":
            return ("B-TYPE", "BRANCH")
        case "JAL":
            return ("J-TYPE", "JAL")
        case "JALR":
            return ("I-TYPE", "JALR")
        case "LUI":
            return ("U-TYPE", "LUI")
        case "AUIPC":
            return ("U-TYPE", "AUIPC")

# used for bit-shift operations and comparison
def comp32_to_signed_int(val: int) -> int:
    val = val & 0xFFFFFFFF
    return val - 0x100000000 if (val & 0x80000000) else val

# simulates overflow for 32-bit addition
def comp32_add(a: int, b: int) -> int:
    a &= 0xFFFFFFFF
    b &= 0xFFFFFFFF
    return (a + b) & 0xFFFFFFFF

def sign_extend_12_to_32(imm: int) -> int:
    if imm & 0x800:
        return imm | 0xFFFFF000
    else:
        return imm & 0x00000FFF

def sign_extend_13_to_32(imm: int) -> int:
    if imm & 0x1000:
        # print(f"FOUND NEGATIVE 13 bit, {imm}")
        # sys.exit()
        return imm | 0xFFFFE000
    else:
        # print(f"FOUND POSITIVE 13 bit, {imm}")
        # sys.exit()
        return imm & 0x00001FFF
    

def sign_extend_21_to_32(imm: int) -> int:
    if imm & 0x100000:
        return imm | 0xFFE00000
    else:
        return imm & 0x001FFFFF

# returns simulated 32-bit value
def compute_alu_r_op(op: str, rs1: int, rs2: int) -> int:
    rs1 &= 0xFFFFFFFF
    rs2 &= 0xFFFFFFFF

    if op == "ADD":
        return comp32_add(rs1, rs2)
    elif op == "SUB":
        return (rs1 - rs2) & 0xFFFFFFFF
    elif op == "XOR":
        return (rs1 ^ rs2) & 0xFFFFFFFF
    elif op == "OR":
        return (rs1 | rs2) & 0xFFFFFFFF
    elif op == "AND":
        return (rs1 & rs2) & 0xFFFFFFFF
    elif op == "SLL":
        return (rs1 << (rs2 & 0x1F)) & 0xFFFFFFFF
    elif op == "SRL":
        return rs1 >> (rs2 & 0x1F)
    elif op == "SRA":
        return (comp32_to_signed_int(rs1) >> (rs2 & 0x1F)) & 0xFFFFFFFF
    elif op == "SLT":
        return 1 if comp32_to_signed_int(rs1) < comp32_to_signed_int(rs2) else 0
    elif op == "SLTU":
        return 1 if rs1 < rs2 else 0
    else:
        raise ValueError(f"Invalid ALU R-type operation: {op}")

# returns simulated 32-bit value
def compute_alu_i_op(op: str, rs1: int, imm_comp32: int) -> int:
    rs1 &= 0xFFFFFFFF
    imm_comp32 &= 0xFFFFFFFF
    
    if op == "ADDI":
        return comp32_add(rs1, imm_comp32)
    elif op == "SLTI":
        return 1 if comp32_to_signed_int(rs1) < comp32_to_signed_int(imm_comp32) else 0
    elif op == "SLTUI":
        return 1 if rs1 < imm_comp32 else 0
    elif op == "XORI":
        return (rs1 ^ imm_comp32) & 0xFFFFFFFF
    elif op == "ORI":
        return (rs1 | imm_comp32) & 0xFFFFFFFF
    elif op == "ANDI":
        return (rs1 & imm_comp32) & 0xFFFFFFFF
    elif op == "SLLI":
        return (rs1 << (imm_comp32 & 0x1F)) & 0xFFFFFFFF
    elif op == "SRLI":
        return rs1 >> (imm_comp32 & 0x1F)
    elif op == "SRAI":
        return (comp32_to_signed_int(rs1) >> (imm_comp32 & 0x1F)) & 0xFFFFFFFF
    else:
        raise ValueError(f"Invalid ALU I-type operation: {op}")

def compute_branch_op(op: str, rs1: int, rs2: int) -> bool:
    rs1 &= 0xFFFFFFFF
    rs2 &= 0xFFFFFFFF

    if op == "BEQ":
        return comp32_to_signed_int(rs1) == comp32_to_signed_int(rs2)
    elif op == "BNE":
        return comp32_to_signed_int(rs1) != comp32_to_signed_int(rs2)
    elif op == "BLT":
        return comp32_to_signed_int(rs1) < comp32_to_signed_int(rs2)
    elif op == "BGE":
        return comp32_to_signed_int(rs1) >= comp32_to_signed_int(rs2)
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
        # set R0 to be 0
        self.committed_regs.add(0)
        self.regs[0].write(0)

    def commit_reg(self, reg_index: int, value: int):
        assert 0 <= reg_index < self.num_regs
        if reg_index > 0:
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
        
    def print_register_state(self, cols: int = 4, rows: int = 8):
        assert cols * rows == self.num_regs, f"Not enough cells to display all registers, cols: {cols}, rows: {rows}"
        for row in range(rows):
            row_entries = []
            for col in range(cols):
                reg_idx = row * cols + col
                if reg_idx >= self.num_regs:
                    break
                reg = self.regs[reg_idx]
                commit_state = "C" if reg.committed else "U"
                value = comp32_to_signed_int(reg.value) if reg.committed else "----"
                # value = reg.value if reg.committed else "----"
                row_entries.append(
                    f"x{reg_idx:02}: {str(value):>12} [{commit_state}]"
                )
            print(" | ".join(row_entries))

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
            byte_data = self.data[addr + i].read() & 0xFF
            value |= (byte_data << (i * 8))
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
    
    def print_memory_state(self):
        print("Memory State:")
        for start, end in self.valid_address_ranges:
            for addr in range(start, end + 1):
                value = self.read(addr, 1)
                print(f"0x{addr:08X}: 0x{value:02X}")

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
    
    def randomize_type3(self, prob_dict: dict[str, float]):
        if prob_dict is None:
            choices = InstrType3
            weights = [1/len(choices) for _ in choices]
        elif isinstance(prob_dict, dict):
            choices = list(prob_dict.keys())
            weights = list(prob_dict.values())
        elif isinstance(prob_dict, set):
            choices = list(prob_dict)
            weights = [1/len(choices) for _ in choices]
        else:
            raise ValueError("Invalid prob_dict type, must be dict, set, or None")
        self.type3 = rand.choices(choices, weights=weights)[0]
        self.type, self.type2 = random_types_on_type3(self.type3)

    def randomize_alu_r_instr(self, commited_regs: set[int]):
        assert len(commited_regs) > 0, "No committed registers available"
        assert self.type == "R-TYPE", "Invalid instruction type"
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

    def randomize_alu_i_instr(self, commited_regs: set[int], imm_bounds: tuple[int, int] = (-1e10, 1e10)):
        assert len(commited_regs) > 0, "No committed registers available"
        assert self.type == "I-TYPE", "Invalid instruction type"
        assert self.type2 == "ALU", "Invalid instruction type2"
        self.alu_i_op = rand.choice(ALU_I_ops)
        self.funct3 = ALU_I_funct3_map[self.alu_i_op]
        self.rs1 = rand.choice(list(commited_regs))
        imm_lower = max(-2048, imm_bounds[0])
        imm_upper = min(2047, imm_bounds[1])
        self.imm_comp32 = rand.randint(imm_lower, imm_upper) & 0xFFFFFFFF
        self.rd = rand.randint(0, 31)
        self.opcode = get_op_code(self.type, self.type2)
        self.bits = f"{self.imm_comp32:012b}{self.rs1:05b}{self.funct3:03b}{self.rd:05b}{self.opcode:07b}"
        self.complete = True

    # needs to be aligned accesses
    # randomization has linear space/time complexity scaling
    # ASSUME valid_address_ranges has already been conjoined and sorted
    def randomize_load_instr(
            self, 
            register_file: Register_File,
            valid_address_ranges: list[tuple[int, int]],
            max_attempts: int,
            imm_bounds: tuple[int, int] = (-1e10, 1e10)
        ):
        commited_register_file = register_file.get_committed_reg_file()
        assert len(commited_register_file) > 0, "No committed registers available"
        assert len(valid_address_ranges) > 0, "No valid address ranges available"
        assert self.type == "I-TYPE", "Invalid instruction type"
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
                reg_value_signed_int = comp32_to_signed_int(reg_entry[1])
                diff = addr_trgt - reg_value_signed_int
                imm_lower = max(-2048, imm_bounds[0])
                imm_upper = min(2047, imm_bounds[1])
                imm_valid = diff >= imm_lower and diff <= imm_upper
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
        self.imm_comp32 = (addr_trgt - comp32_to_signed_int(register_file.regs[reachable_reg].value)) & 0xFFFFFFFF
        self.rd = rand.randint(0, register_file.num_regs-1)
        self.opcode = get_op_code(self.type, self.type2)
        self.bits = f"{self.imm_comp32:012b}{self.rs1:05b}{self.funct3:03b}{self.rd:05b}{self.opcode:07b}"
        self.complete = True

    def randomize_store_instr(
            self, 
            register_file: Register_File,
            address_range: tuple[int, int], 
            max_attempts: int,
            imm_bounds: tuple[int, int] = (-1e10, 1e10)
        ):
        commited_register_file = register_file.get_committed_reg_file()
        assert len(commited_register_file) > 0, "No committed registers available"
        assert self.type == "S-TYPE", "Invalid instruction type"
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
                reg_value_signed_int = comp32_to_signed_int(reg_entry[1])
                diff = addr_trgt - reg_value_signed_int
                imm_lower = max(-2048, imm_bounds[0])
                imm_upper = min(2047, imm_bounds[1])
                imm_valid = diff >= imm_lower and diff <= imm_upper
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
        self.imm_comp32 = (addr_trgt - comp32_to_signed_int(register_file.regs[reachable_reg].value)) & 0xFFFFFFFF
        #  = rand.randint(0, register_file.num_regs-1)
        self.rs2 = rand.choice(list(register_file.committed_regs))
        self.opcode = get_op_code(self.type, self.type2)
        imm_11_5 = (self.imm_comp32 >> 5) & 0x7F
        imm_4_0 = self.imm_comp32 & 0x1F
        self.bits = f"{imm_11_5:07b}{self.rs2:05b}{self.rs1:05b}{self.funct3:03b}{imm_4_0:05b}{self.opcode:07b}"
        self.complete = True

    def randomize_branch_instr(
            self, 
            register_file: Register_File, 
            instr_address_range: tuple[int, int], 
            pc: int,
            max_attempts: int,
            imm_bounds: tuple[int, int] = (-1e10, 1e10)
            ):
        commited_register_file = register_file.get_committed_reg_file()
        # assert len(register_file.committed_regs) > 0, "No committed registers available"
        assert len(commited_register_file) > 0, "No committed registers available"
        assert self.type == "B-TYPE", "Invalid instruction type"
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
            if addr_trgt == pc: continue # prevent infinite loop
            # check if a pc can be used as the base for the branch
            reachable = False
            diff = addr_trgt - pc
            imm_lower = max(-4096, imm_bounds[0])
            imm_upper = min(4094, imm_bounds[1])
            imm_valid = diff >= imm_lower and diff <= imm_upper
            if imm_valid:
                reachable = True
                break
            if not reachable: continue
            found_valid_addr = True

        self.branch_op = rand.choice(BRANCH_ops)
        self.funct3 = BRANCH_funct3_map[self.branch_op]
        self.rs1 = rand.choice(list(register_file.committed_regs))
        self.rs2 = rand.choice(list(register_file.committed_regs))
        self.imm_comp32 = (addr_trgt - pc) & 0xFFFFFFFF
        self.opcode = get_op_code(self.type, self.type2)

        imm_12 = (self.imm_comp32 >> 12) & 1
        imm_11 = (self.imm_comp32 >> 11) & 1
        imm_10_5 = (self.imm_comp32 >> 5) & 0x3F
        imm_4_1 = (self.imm_comp32 >> 1) & 0xF
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
            max_attempts: int,
            imm_bounds: tuple[int, int] = (-1e10, 1e10)
            ):
        assert self.type == "J-TYPE", "Invalid instruction type"
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
            if addr_trgt == pc: continue # prevent infinite loop
            # check if a pc can be used as the base for the jump
            reachable = False
            diff = addr_trgt - pc
            imm_lower = max(-1048576, imm_bounds[0])
            imm_upper = min(1048574, imm_bounds[1])
            imm_valid = diff >= imm_lower and diff <= imm_upper
            if imm_valid:
                reachable = True
                break
            if not reachable: continue
            found_valid_addr = True

        self.rd = rand.randint(0, register_file.num_regs - 1)
        self.imm_comp32 = (addr_trgt - pc) & 0xFFFFFFFF
        self.opcode = get_op_code(self.type, self.type2)

        imm_20 = (self.imm_comp32 >> 20) & 1
        imm_19_12 = (self.imm_comp32 >> 12) & 0xFF
        imm_11 = (self.imm_comp32 >> 11) & 0x1
        imm_10_1 = (self.imm_comp32 >> 1) & 0x3FF
        self.bits = f"{imm_20:01b}{imm_10_1:010b}{imm_11:01b}{imm_19_12:08b}{self.rd:05b}{self.opcode:07b}"
        self.complete = True

    def randomize_jalr_instr(
            self, 
            register_file: Register_File, 
            instr_address_range: tuple[int, int],
            pc: int,
            max_attempts: int,
            imm_bounds: tuple[int, int] = (-1e10, 1e10)
            ):
        commited_register_file = register_file.get_committed_reg_file()
        assert len(commited_register_file) > 0, "No committed registers available"
        assert self.type == "I-TYPE", "Invalid instruction type"
        assert self.type2 == "JALR", "Invalid instruction type2"
    
        found_valid_addr = False
        attempts = 0
        while not found_valid_addr and attempts < max_attempts:
            attempts += 1
            # addr_trgt = rand.choice([addr for start, end in instr_address_range for addr in range(start, end + 1)])
            addr_trgt = rand.randint(instr_address_range[0], instr_address_range[1])
            jump_addr_width = 4
            # guarantee mem_alignment
            addr_trgt = addr_trgt - (addr_trgt % jump_addr_width)
            # check if entire jump address width is within a valid address range
            jump_within_range = False
            if instr_address_range[0] <= addr_trgt <= instr_address_range[1]:
                if (addr_trgt + jump_addr_width - 1) <= instr_address_range[1]:
                    jump_within_range = True
            if not jump_within_range: continue
            if addr_trgt == pc: continue # prevent infinite loop
            # check if a valid register can be used as the base for the jump
            reachable_reg = None
            print(f"\nRandomizing JALR instruction, looking for reachable register for addr: {addr_trgt}")
            print(f"instr_address_range: {instr_address_range}")
            for reg_entry in rand.sample(commited_register_file, k=len(commited_register_file)):
                print(f"  Checking register {reg_entry[0]} with value {reg_entry[1]}")
                reg_value_signed_int = comp32_to_signed_int(reg_entry[1])
                diff = addr_trgt - reg_value_signed_int
                imm_lower = max(-2048, imm_bounds[0])
                imm_upper = min(2047, imm_bounds[1])
                imm_valid = diff >= imm_lower and diff <= imm_upper
                # imm_valid = diff >= -2048 and diff < 2048
                if imm_valid:
                    print(f"Found!, with diff: {diff}")
                    reachable_reg = reg_entry[0]
                    break
            if reachable_reg is None: continue
            found_valid_addr = True
        
        print(f"  Using register {reachable_reg}\n")
        # sys.exit()
        
        if (attempts >= max_attempts):
            raise ValueError("Failed to generate a valid load instruction after maximum attempts")
        
        # self.addr_trgt = addr_trgt
        self.funct3 = 0b000
        self.rs1 = reachable_reg
        self.imm_comp32 = (addr_trgt - comp32_to_signed_int(register_file.regs[reachable_reg].value)) & 0xFFFFFFFF
        self.rd = rand.randint(0, register_file.num_regs-1)
        self.opcode = get_op_code(self.type, self.type2)
        self.bits = f"{self.imm_comp32:012b}{self.rs1:05b}{self.funct3:03b}{self.rd:05b}{self.opcode:07b}"
        self.complete = True

    def randomize_lui_instr(self, imm_bounds: tuple[int, int] = (-1e10, 1e10)):
        assert self.type == "U-TYPE", "Invalid instruction type"
        assert self.type2 == "LUI", "Invalid instruction type2"
        imm_lower = max(-1 * (2 ** 31), imm_bounds[0])
        imm_upper = min((2 ** 31) - 1, imm_bounds[1])
        self.imm_comp32 = ((rand.randint(imm_lower, imm_upper) >> 12) << 12) & 0xFFFFFFFF
        self.rd = rand.randint(0, 31)
        self.opcode = get_op_code(self.type, self.type2)
        imm_31_12 = self.imm_comp32 >> 12 & 0xFFFFF
        self.bits = f"{imm_31_12:020b}{self.rd:05b}{self.opcode:07b}"
        self.complete = True

    def randomize_auipc_instr(self, imm_bounds: tuple[int, int] = (-1e10, 1e10)):
        assert self.type == "U-TYPE", "Invalid instruction type"
        assert self.type2 == "AUIPC", "Invalid instruction type2"
        # self.imm_comp32 = ((rand.randint(-1 * (2 ** 31), (2 ** 31) - 1) >> 12) << 12) & 0xFFFFFFFF
        imm_lower = max(-1 * (2 ** 31), imm_bounds[0])
        imm_upper = min((2 ** 31) - 1, imm_bounds[1])
        self.imm_comp32 = ((rand.randint(imm_lower, imm_upper) >> 12) << 12) & 0xFFFFFFFF
        self.rd = rand.randint(0, 31)
        self.opcode = get_op_code(self.type, self.type2)
        imm_31_12 = self.imm_comp32 >> 12 & 0xFFFFF
        self.bits = f"{imm_31_12:020b}{self.rd:05b}{self.opcode:07b}"
        self.complete = True

    def randomize_given_state(self, 
                register_file: Register_File,
                memory: Memory,
                pc: int,
                instr_address_range: tuple[int, int],
                max_attempts: int,
                # exclude_type3_set: set[str] = None
                prob_dict = None,
                imm_bounds: tuple[int, int] = (-1e10, 1e10)
        ):
        self.randomize_type3(prob_dict)
        if self.type3 == "ALU_R":
            self.randomize_alu_r_instr(register_file.committed_regs)
        elif self.type3 == "ALU_I":
            self.randomize_alu_i_instr(register_file.committed_regs, imm_bounds)
        elif self.type3 == "LOAD":
            self.randomize_load_instr(register_file, memory.valid_address_ranges, max_attempts, imm_bounds)
        elif self.type3 == "STORE":
            # self.randomize_store_instr(register_file, memory.valid_address_ranges, max_attempts)
            self.randomize_store_instr(register_file, (0, memory.size - 1), max_attempts, imm_bounds)
        elif self.type3 == "BRANCH":
            self.randomize_branch_instr(register_file, instr_address_range, pc, max_attempts, imm_bounds)
        elif self.type3 == "JAL":
            self.randomize_jal_instr(register_file, instr_address_range, pc, max_attempts, imm_bounds)
        elif self.type3 == "JALR":
            self.randomize_jalr_instr(register_file, instr_address_range, pc, max_attempts, imm_bounds)
        elif self.type3 == "LUI":
            self.randomize_lui_instr(imm_bounds)
        elif self.type3 == "AUIPC":
            self.randomize_auipc_instr(imm_bounds)
        else:
            raise ValueError("Invalid instruction type or type2")

    def gen_assembly_str(self) -> str:
        instr_name = None
        operand_1 = None
        operand_2 = None
        operand_3 = None

        if self.type2 == "ALU" and self.type == "R-TYPE":
            instr_name = self.alu_r_op
            operand_1 = f"x{self.rd}"
            operand_2 = f"x{self.rs1}"
            operand_3 = f"x{self.rs2}"
        elif self.type2 == "ALU" and self.type == "I-TYPE":
            instr_name = self.alu_i_op
            operand_1 = f"x{self.rd}"
            operand_2 = f"x{self.rs1}"
            operand_3 = comp32_to_signed_int(self.imm_comp32)
        elif self.type2 == "LOAD":
            instr_name = self.load_type
            operand_1 = f"x{self.rd}"
            operand_2 = f"{comp32_to_signed_int(self.imm_comp32)}(x{self.rs1})"
        elif self.type2 == "STORE":
            instr_name = self.store_type
            operand_1 = f"x{self.rs2}"
            operand_2 = f"{comp32_to_signed_int(self.imm_comp32)}(x{self.rs1})"
        elif self.type2 == "BRANCH":
            instr_name = self.branch_op
            operand_1 = f"x{self.rs1}"
            operand_2 = f"x{self.rs2}"
            if hasattr(self, "label"):
                operand_3 = self.label
            else:
                operand_3 = comp32_to_signed_int(self.imm_comp32)
        elif self.type2 == "JAL":
            instr_name = "JAL"
            operand_1 = f"x{self.rd}"
            if hasattr(self, "label"):
                operand_2 = self.label
            else:
                operand_2 = comp32_to_signed_int(self.imm_comp32)
        elif self.type2 == "JALR":
            instr_name = "JALR"
            operand_1 = f"x{self.rd}"
            operand_2 = f"{comp32_to_signed_int(self.imm_comp32)}(x{self.rs1})"
        elif self.type2 == "LUI":
            instr_name = "LUI"
            operand_1 = f"x{self.rd}"
            operand_2 = f"{comp32_to_signed_int(self.imm_comp32)} (note: this is full value)"
        elif self.type2 == "AUIPC":
            instr_name = "AUIPC"
            operand_1 = f"x{self.rd}"
            operand_2 = f"{comp32_to_signed_int(self.imm_comp32)} (note: this is full value)"

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
    instr.type = "R-TYPE"
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
        imm_comp32: int
) -> Instr:
    instr = Instr()
    instr.type2 = "ALU"
    instr.type = "I-TYPE"
    instr.alu_i_op = alu_i_op
    instr.funct3 = ALU_I_funct3_map[alu_i_op]
    instr.rs1 = rs1
    instr.imm_comp32 = imm_comp32
    instr.rd = rd
    instr.opcode = get_op_code(instr.type, instr.type2)
    instr.bits = f"{instr.imm_comp32:012b}{instr.rs1:05b}{instr.funct3:03b}{instr.rd:05b}{instr.opcode:07b}"
    instr.complete = True
    return instr

def create_load_instr(
        load_type: str,
        rd: int,
        rs1: int,
        imm_comp32: int
) -> Instr:
    instr = Instr()
    instr.type2 = "LOAD"
    instr.type = "I-TYPE"
    instr.load_type = load_type
    instr.funct3 = LOAD_funct3_map[load_type]
    instr.load_width = LOAD_ops_byte_read_sizing_map[load_type]
    instr.rs1 = rs1
    instr.imm_comp32 = imm_comp32
    instr.rd = rd
    instr.opcode = get_op_code(instr.type, instr.type2)
    instr.bits = f"{instr.imm_comp32:012b}{instr.rs1:05b}{instr.funct3:03b}{instr.rd:05b}{instr.opcode:07b}"
    instr.complete = True
    return instr

def create_store_instr(
        store_type: str,
        rs1: int,
        rs2: int,
        imm_comp32: int
) -> Instr:
    instr = Instr()
    instr.type2 = "STORE"
    instr.type = "S-TYPE"
    instr.store_type = store_type
    instr.funct3 = STORE_funct3_map[store_type]
    instr.store_width = STORE_ops_byte_write_sizing_map[store_type]
    instr.rs1 = rs1
    instr.imm_comp32 = imm_comp32
    instr.rs2 = rs2
    instr.opcode = get_op_code(instr.type, instr.type2)
    imm_11_5 = (instr.imm_comp32 >> 5) & 0x7F
    imm_4_0 = instr.imm_comp32 & 0x1F
    instr.bits = f"{imm_11_5:07b}{instr.rs2:05b}{instr.rs1:05b}{instr.funct3:03b}{imm_4_0:05b}{instr.opcode:07b}"
    instr.complete = True
    return instr

def create_branch_instr(
        branch_type: str,
        rs1: int,
        rs2: int,
        imm_comp32: int,
        label: str = None
) -> Instr:
    instr = Instr()
    instr.type2 = "BRANCH"
    instr.type = "B-TYPE"
    instr.branch_op = branch_type
    instr.funct3 = BRANCH_funct3_map[branch_type]
    instr.rs1 = rs1
    instr.rs2 = rs2
    instr.imm_comp32 = imm_comp32
    instr.opcode = get_op_code(instr.type, instr.type2)
    imm_12 = (instr.imm_comp32 >> 12) & 0x1
    imm_11 = (instr.imm_comp32 >> 11) & 0x1
    imm_10_5 = (instr.imm_comp32 >> 5) & 0x3F
    imm_4_1 = (instr.imm_comp32 >> 1) & 0xF
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
        imm_comp32: int,
        label: str = None
) -> Instr:
    instr = Instr()
    instr.type2 = "JAL"
    instr.type = "J-TYPE"
    instr.rd = rd
    instr.imm_comp32 = imm_comp32
    instr.opcode = get_op_code(instr.type, instr.type2)
    imm_20 = (instr.imm_comp32 >> 20) & 1
    imm_19_12 = (instr.imm_comp32 >> 12) & 0xFF
    imm_11 = (instr.imm_comp32 >> 11) & 0x1
    imm_10_1 = (instr.imm_comp32 >> 1) & 0x3FF
    instr.bits = f"{imm_20:01b}{imm_10_1:010b}{imm_11:01b}{imm_19_12:08b}{instr.rd:05b}{instr.opcode:07b}"
    if label is not None:
        instr.label = label
    instr.complete = True
    return instr

def create_jalr_instr(
        rd: int,
        rs1: int,
        imm_comp32: int,
        label: str = None
) -> Instr:
    instr = Instr()
    instr.type2 = "JALR"
    instr.type = "I-TYPE"
    instr.funct3 = 0b000
    instr.rs1 = rs1
    instr.imm_comp32 = imm_comp32
    instr.rd = rd
    instr.opcode = get_op_code(instr.type, instr.type2)
    instr.bits = f"{instr.imm_comp32:012b}{instr.rs1:05b}{instr.funct3:03b}{instr.rd:05b}{instr.opcode:07b}"
    if label is not None:
        instr.label = label
    instr.complete = True
    return instr

def create_lui_instr(
        rd: int,
        imm_comp32: int
) -> Instr:
    instr = Instr()
    instr.type2 = "LUI"
    instr.type = "U-TYPE"
    instr.rd = rd
    instr.imm_comp32 = imm_comp32
    instr.opcode = get_op_code(instr.type, instr.type2)
    imm_31_12 = instr.imm_comp32 >> 12 & 0xFFFFF
    instr.bits = f"{imm_31_12:020b}{instr.rd:05b}{instr.opcode:07b}"
    instr.complete = True
    return instr

def create_auipc_instr(
        rd: int,
        imm_comp32: int
) -> Instr:
    instr = Instr()
    instr.type2 = "AUIPC"
    instr.type = "U-TYPE"
    instr.rd = rd
    instr.imm_comp32 = imm_comp32
    instr.opcode = get_op_code(instr.type, instr.type2)
    imm_31_12 = instr.imm_comp32 >> 12 & 0xFFFFF
    instr.bits = f"{imm_31_12:020b}{instr.rd:05b}{instr.opcode:07b}"
    instr.complete = True
    return instr

def create_alu_r_instr_from_bin(bin_str: str) -> Instr:
    alu_r_op = get_alu_r_op_from_bin_32(bin_str)
    rd = int(bin_str[20:25], 2)
    rs1 = int(bin_str[12:17], 2)
    rs2 = int(bin_str[7:12], 2)
    instr = create_alu_r_instr(alu_r_op, rd, rs1, rs2)
    return instr

def create_alu_i_instr_from_bin(bin_str: str) -> Instr:
    alu_i_op = get_alu_i_op_from_bin_32(bin_str)
    rd = int(bin_str[20:25], 2)
    rs1 = int(bin_str[12:17], 2)
    imm = int(bin_str[0:12], 2)
    imm_comp32 = sign_extend_12_to_32(imm)
    instr = create_alu_i_instr(alu_i_op, rd, rs1, imm_comp32)
    return instr

def create_load_instr_from_bin(bin_str: str) -> Instr:
    load_op = get_load_op_from_bin_32(bin_str)
    rd = int(bin_str[20:25], 2)
    rs1 = int(bin_str[12:17], 2)
    imm = int(bin_str[0:12], 2)
    imm_comp32 = sign_extend_12_to_32(imm)
    instr = create_load_instr(load_op, rd, rs1, imm_comp32)
    return instr

def create_store_instr_from_bin(bin_str: str) -> Instr:
    store_op = get_store_op_from_bin_32(bin_str)
    rs1 = int(bin_str[12:17], 2)
    rs2 = int(bin_str[7:12], 2)
    imm_11_5_str = bin_str[0:7]
    imm_4_0_str = bin_str[20:25]
    imm = int(imm_11_5_str + imm_4_0_str, 2)
    imm_comp32 = sign_extend_12_to_32(imm)
    instr = create_store_instr(store_op, rs1, rs2, imm_comp32)
    return instr

def create_branch_instr_from_bin(bin_str: str, label:str = None) -> Instr:
    branch_op = get_branch_op_from_bin_32(bin_str)
    rs1 = int(bin_str[12:17], 2)
    rs2 = int(bin_str[7:12], 2)
    # imm = int(bin_str[0:13], 2)
    imm_12_str = bin_str[0]
    imm_10_5_str = bin_str[1:7]
    imm_4_1_str = bin_str[20:24]
    imm_11_str = bin_str[24]
    imm = int(imm_12_str + imm_11_str + imm_10_5_str + imm_4_1_str + "0", 2)
    imm_comp32 = sign_extend_13_to_32(imm)
    instr = create_branch_instr(branch_op, rs1, rs2, imm_comp32, label)
    return instr

def create_jal_instr_from_bin(bin_str: str, label:str = None) -> Instr:
    rd = int(bin_str[20:25], 2)
    # imm_str = int(bin_str[0:20], 2)
    imm_20_str = bin_str[0]
    imm_10_1_str = bin_str[1:11]
    imm_11_str = bin_str[11]
    imm_19_12_str = bin_str[12:20]
    imm = int(imm_20_str + imm_19_12_str + imm_11_str + imm_10_1_str + "0", 2)
    imm_comp32 = sign_extend_21_to_32(imm)
    instr = create_jal_instr(rd, imm_comp32, label)
    return instr

def create_jalr_instr_from_bin(bin_str: str, label:str = None) -> Instr:
    rd = int(bin_str[20:25], 2)
    rs1 = int(bin_str[12:17], 2)
    imm = int(bin_str[0:12], 2)
    imm_comp32 = sign_extend_12_to_32(imm)
    instr = create_jalr_instr(rd, rs1, imm_comp32, label)
    return instr

def create_lui_instr_from_bin(bin_str: str) -> Instr:
    rd = int(bin_str[20:25], 2)
    imm_comp32 = int(bin_str[0:20] + "0" * 12, 2) & 0xFFFFFFFF
    instr = create_lui_instr(rd, imm_comp32)
    return instr

def create_auipc_instr_from_bin(bin_str: str) -> Instr:
    rd = int(bin_str[20:25], 2) 
    imm_comp32 = int(bin_str[0:20] + "0" * 12, 2) & 0xFFFFFFFF
    instr = create_auipc_instr(rd, imm_comp32)
    return instr

def create_instr_from_bin(bin_str: str, label:str = None, debug: bool = False) -> Instr:
    if debug:
        print(f"Creating instruction from binary string: {bin_str}")
        print(f"Opcode bits: {bin_str[25:32]}")
        if label is not None:
            print(f"With label: {label}")

    opcode = int(bin_str[25:32], 2)
    type, type2 = get_types_from_opcode(opcode)
    if type2 == "ALU" and type == "R-TYPE":
        return create_alu_r_instr_from_bin(bin_str)
    elif type2 == "ALU" and type == "I-TYPE":
        return create_alu_i_instr_from_bin(bin_str)
    elif type2 == "LOAD":
        return create_load_instr_from_bin(bin_str)
    elif type2 == "STORE":
        return create_store_instr_from_bin(bin_str)
    elif type2 == "BRANCH":
        return create_branch_instr_from_bin(bin_str, label)
    elif type2 == "JAL":
        return create_jal_instr_from_bin(bin_str, label)
    elif type2 == "JALR":
        return create_jalr_instr_from_bin(bin_str, label)
    elif type2 == "LUI":
        return create_lui_instr_from_bin(bin_str)
    elif type2 == "AUIPC":
        return create_auipc_instr_from_bin(bin_str)
    else:
        raise ValueError(f"Invalid instruction binary string: {bin_str}, "
                         f"opcode_int: {opcode}, opcode_7_bit_bin: {opcode:07b}, "
                         f"type: {type}, type2: {type2}"
                         )

class Program:
    def __init__(
            self,
            data_mem_size: int = 1024,
            instr_mem_space_byte_size: int = 1024, # in bytes
            instr_mem_base_addr: int = 0
        ):
        self.register_file = Register_File()
        self.memory = Memory(data_mem_size)
        self.instructions = []
        self.pc = 0
        self.instr_addr_range = (instr_mem_base_addr, 
                                 instr_mem_base_addr + instr_mem_space_byte_size - 1)

    def get_valid_instr_addr_range(self) -> tuple[int, int]:
        return (self.instr_addr_range[0], 
                self.instr_addr_range[0] + len(self.instructions) * 4 - 1)

    def gen_random_instr_given_state(self, max_attempts: int = 100, 
                                     working_instr_range: tuple[int, int] = None,
                                    #  exclude_type3_set: set[str] = None
                                    prob_dict = None,
                                    imm_bounds: tuple[int, int] = (-1e10, 1e10)
                                     ) -> Instr:
        instr = Instr()
        if working_instr_range is None:
            working_instr_range = self.get_valid_instr_addr_range()
        instr.randomize_given_state(
            self.register_file,
            self.memory,
            self.pc,
            working_instr_range,
            max_attempts,
            prob_dict,
            imm_bounds
        )
        return instr

    def register_r_op(self, instr: Instr):
        rs1_value = self.register_file.get_reg_value(instr.rs1)
        rs2_value = self.register_file.get_reg_value(instr.rs2)
        rd_value = compute_alu_r_op(instr.alu_r_op, rs1_value, rs2_value)
        self.register_file.commit_reg(instr.rd, rd_value)
        self.pc = comp32_add(self.pc, 4)
    
    def register_i_op(self, instr: Instr):
        rs1_value = self.register_file.get_reg_value(instr.rs1)
        imm_value = instr.imm_comp32
        rd_value = compute_alu_i_op(instr.alu_i_op, rs1_value, imm_value)
        self.register_file.commit_reg(instr.rd, rd_value)
        self.pc = comp32_add(self.pc, 4)

    def register_load_instr(self, instr: Instr):
        rs1_value = self.register_file.get_reg_value(instr.rs1)
        imm_value = instr.imm_comp32
        # addr = rs1_value + imm_value
        addr = comp32_add(rs1_value, imm_value)
        data = self.memory.read(addr, instr.load_width)
        data = sign_extend_load(data, instr.load_type, 32)
        self.register_file.commit_reg(instr.rd, data)
        self.pc = comp32_add(self.pc, 4)

    def register_store_instr(self, instr: Instr):
        rs1_value = self.register_file.get_reg_value(instr.rs1)
        imm_value = instr.imm_comp32
        addr = comp32_add(rs1_value, imm_value)
        data = self.register_file.get_reg_value(instr.rs2)
        self.memory.write(addr, data, instr.store_width)
        self.pc = comp32_add(self.pc, 4)

    def register_branch_instr(self, instr: Instr):
        rs1_value = self.register_file.get_reg_value(instr.rs1)
        rs2_value = self.register_file.get_reg_value(instr.rs2)
        branch_taken = compute_branch_op(instr.branch_op, rs1_value, rs2_value)
        if branch_taken:
            self.pc = comp32_add(self.pc, instr.imm_comp32)
        else:
            self.pc = comp32_add(self.pc, 4)

    def register_jal_instr(self, instr: Instr):
        self.register_file.commit_reg(instr.rd, comp32_add(self.pc, 4))
        self.pc = comp32_add(self.pc, instr.imm_comp32)
    
    def register_jalr_instr(self, instr: Instr):
        self.register_file.commit_reg(instr.rd, comp32_add(self.pc, 4))
        self.pc = comp32_add(self.pc, instr.imm_comp32)
    
    def register_lui_instr(self, instr: Instr):
        self.register_file.commit_reg(instr.rd, instr.imm_comp32)
        self.pc = comp32_add(self.pc, 4)

    def register_auipc_instr(self, instr: Instr):
        self.register_file.commit_reg(instr.rd, comp32_add(self.pc, instr.imm_comp32))
        self.pc = comp32_add(self.pc, 4)

    def register_instr(self, instr: Instr, debug: int = 0):
        if debug >= 1:
            print(f"Executing instruction: {instr.gen_assembly_str()}")
            print(f"PC before execution: {self.pc}")
        if debug >= 2:
            print(f"Register file before execution: {self.register_file.print_register_state()}")
            print(f"Memory valid range before execution: {self.memory.valid_address_ranges}")
        if debug >= 3:
            print(f"Memory state before execution: {self.memory.print_memory_state()}")

        if instr.type2 == "ALU" and instr.type == "R-TYPE":   self.register_r_op(instr)
        elif instr.type2 == "ALU" and instr.type == "I-TYPE": self.register_i_op(instr)
        elif instr.type2 == "LOAD":     self.register_load_instr(instr)
        elif instr.type2 == "STORE":    self.register_store_instr(instr)
        elif instr.type2 == "BRANCH":   self.register_branch_instr(instr)
        elif instr.type2 == "JAL":      self.register_jal_instr(instr)
        elif instr.type2 == "JALR":     self.register_jalr_instr(instr)
        elif instr.type2 == "LUI":      self.register_lui_instr(instr)
        elif instr.type2 == "AUIPC":    self.register_auipc_instr(instr)
        else:
            raise ValueError("Invalid instruction type or type2")
    
    def grab_next_instr_index(self) -> int:
        if self.pc < self.instr_addr_range[0] or self.pc > self.instr_addr_range[1]:
            print(f"PC {self.pc} out of instruction memory range {self.instr_addr_range}, halting execution")
            return -1
        instr_index = (self.pc - self.instr_addr_range[0]) // 4
        if instr_index >= len(self.instructions):
            print(f"PC {self.pc} points to instruction index {instr_index} which is out of range of loaded instructions, halting execution")
            return -2
        return instr_index

    
    # # this wrong tehcnically because we dont really follow the pc
    # def gen_and_exec_rand_program_seq(self, num_instr: int, max_attempts: int):
    #     for _ in range(num_instr):
    #         instr = Instr()
    #         instr.randomize(
    #             self.register_file,
    #             self.memory,
    #             self.pc,
    #             self.instr_addr_range,
    #             max_attempts
    #         )
    #         self.instructions.append(instr)
    #         self.register_instr(instr)
    #         instr_index = self.grab_next_instr_index()
    #         assert instr_index >= 0, "PC out of range after executing instruction"

    def gen_rand_program_seq(self, 
                             num_instr: int, 
                             max_attempts: int, 
                             debug: int = 0, 
                             frwd_instr_range_offset: int = 0,
                             prob_dict = None,
                             imm_bounds: tuple[int, int] = (-1e10, 1e10)
                            ):
        assert (num_instr == 1 or prob_dict is not None, 
            "ENSURE num_instr > 1, cant generate unsafe (register based) accesses (load, store, jalr)")
        instr_list = []

        for instr_num in range(num_instr):
            if instr_num + frwd_instr_range_offset < num_instr:
                working_instr_range = (
                    self.get_valid_instr_addr_range()[0],
                    self.get_valid_instr_addr_range()[1] + instr_num + frwd_instr_range_offset * 4
                )
                instr = self.gen_random_instr_given_state(max_attempts, working_instr_range, prob_dict, imm_bounds)
            else:
                instr = self.gen_random_instr_given_state(max_attempts, None, prob_dict, imm_bounds)
            instr_list.append(instr)

        if debug >= 1:
            print(f"Generated random instruction sequence:")
            print_to_file("generated_instructions.txt", "Generated random instruction sequence:\n\n", append=False)
            for instr in instr_list:
                print(instr.gen_assembly_str())
                print_to_file("generated_instructions.txt", instr.gen_assembly_str() + "\n", append=True)

        self.instructions.extend(instr_list)

    def exec(self, max_cycles: int = 100, debug: int = 0):
        # for instr in self.instructions:
            # self.register_instr(instr)
        cycle = 0
        while cycle < max_cycles:
            if debug >= 2:
                print("----------------------------------------")
                print(f"Cycle {cycle}:")
            instr_index = self.grab_next_instr_index()
            if instr_index < 0:
                break
            instr = self.instructions[instr_index]
            self.register_instr(instr, debug)
            cycle += 1

        if cycle >= max_cycles:
            print(f"Reached maximum cycle count of {max_cycles}, halting execution")
        
        if debug >= 0:
            print("----------------------------------------")
            print(f"Final state after execution:")
            print(f"PC: {self.pc}")
            print(f"Register file: {self.register_file.print_register_state()}")
            print(f"Memory valid range: {self.memory.valid_address_ranges}")
            if debug >= 2:
                print(f"Memory state: {self.memory.print_memory_state()}")

        

def grab_instrs_from_bin(path: str, max_num: int) -> list[str]:
    instrs = []
    with open(path, "rb") as f:
        while len(instrs) < max_num:
            instr_bytes = f.read(4)
            if len(instr_bytes) < 4:
                break
            instr = int.from_bytes(instr_bytes, byteorder="little")
            instr_str = f"{instr:032b}"
            instrs.append(instr_str)
    if len(instrs) == max_num:
        print(f"Grabbed maximum number of instructions ({max_num}) from binary file ({path})")
    return instrs

if __name__ == "__main__":
    program = Program()

    # load initial instructions and execute them
    init_instr_str_seq = grab_instrs_from_bin("init.bin", 100)
    init_instr_seq = [create_instr_from_bin(instr_str) for instr_str in init_instr_str_seq]
    program.instructions.extend(init_instr_seq)
    print(f"Program instruction length: {len(program.instructions)}\n")
    program.exec(max_cycles=2000, debug=0)

    safe_set = set(InstrType3) - {"LOAD", "STORE", "JALR"}

    print("\nNow generating and executing random instruction sequence...\n")
    for _ in range(5):
        program.gen_rand_program_seq(
            num_instr=5, 
            max_attempts=100, 
            debug=2,
            frwd_instr_range_offset=4,
            prob_dict={"ALU_R": 0.3, "ALU_I": 0.3, "BRANCH": 0.2, "JAL": 0.1, "LUI": 0.05, "AUIPC": 0.05},
            imm_bounds=(200, 200)
            )
        print("\nNow executing the generated random instruction sequence...\n")
        program.exec(max_cycles=2000, debug=1)
        program.gen_rand_program_seq(
            num_instr=1,
            max_attempts=100,
            debug=2,
            frwd_instr_range_offset=0,
            prob_dict={"LOAD", "STORE", "JALR"},
            imm_bounds=(200, 200)

        )
        program.exec(max_cycles=2000, debug=1)
        print("\nNow executing the generated random instruction sequence...\n")

        
    program.exec(max_cycles=2000, debug=1)    

    # NOTE: Currently, our jumps/branches only go backwards







    
