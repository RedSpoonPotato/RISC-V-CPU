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

    def get_committed_reg_file(self):
        commit_reg_file = []
        for i in range(self.num_regs):
            if self.regs[i].committed:
                commit_reg_file.append((i, self.regs[i].value))
        return commit_reg_file

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

    def read(self, addr: int) -> int:
        assert 0 <= addr < self.size, "Address out of bounds"
        return self.data[addr].read()
    
    def write(self, addr: int, value: int):
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
        
        self.addr_trgt = addr_trgt
        self.load_type = load_type
        self.funct3 = LOAD_funct3_map[self.load_type]
        self.load_width = load_width
        self.rs1 = reachable_reg
        self.imm = (addr_trgt - register_file.regs[reachable_reg].value) & 0xFFF
        self.rd = rand.randint(0, register_file.num_regs-1)
        self.opcode = get_op_code(self.type, self.type2)
        self.bits = f"{self.imm:012b}{self.rs1:05b}{self.funct3:03b}{self.rd:05b}{self.opcode:07b}"

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
        
        self.addr_trgt = addr_trgt
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
        
        self.addr_trgt = addr_trgt
        self.funct3 = 0b000
        self.rs1 = reachable_reg
        self.imm = (addr_trgt - register_file.regs[reachable_reg].value) & 0xFFF
        self.rd = rand.randint(0, register_file.num_regs-1)
        self.opcode = get_op_code(self.type, self.type2)
        self.bits = f"{self.imm:012b}{self.rs1:05b}{self.funct3:03b}{self.rd:05b}{self.opcode:07b}"

    def randomize_lui_instr(self):
        assert self.type == "U_TYPE", "Invalid instruction type"
        assert self.type2 == "LUI", "Invalid instruction type2"
        self.imm = (rand.randint(0, (2 ** 32) - 1) >> 12) << 12
        self.rd = rand.randint(0, 31)
        self.opcode = get_op_code(self.type, self.type2)
        imm_31_12 = self.imm >> 12 & 0xFFFFF
        self.bits = f"{imm_31_12:020b}{self.rd:05b}{self.opcode:07b}"

    def randomize_auipc_instr(self):
        assert self.type == "U_TYPE", "Invalid instruction type"
        assert self.type2 == "AUIPC", "Invalid instruction type2"
        self.imm = (rand.randint(0, (2 ** 32) - 1) >> 12) << 12
        self.rd = rand.randint(0, 31)
        self.opcode = get_op_code(self.type, self.type2)
        imm_31_12 = self.imm >> 12 & 0xFFFFF
        self.bits = f"{imm_31_12:020b}{self.rd:05b}{self.opcode:07b}"

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





"""
    Need to generate a sequence of instrs
    start with generating a valid instr
        valid Type (R, I, ...) or based on custom typing
        valid 

"""