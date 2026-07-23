from utils import *
import random as rand

# adjust these values as needed
data_base_addr = 0x80010100
end_addr = 0x80012100
program = Program(
    # instr_mem_space_byte_size=0x10000,
    instr_mem_space_byte_size=0x1000,
    instr_mem_base_addr=0x80000000,
    # data_mem_size=0x10000,
    data_mem_size=(end_addr - data_base_addr + 4),
    # data_mem_size=0x100, # all initialized entries in memory
    # data_mem_base_addr=0x80010000
    # data_mem_base_addr=0x80010100
    data_mem_base_addr=data_base_addr
)
rand_sub_seq_num = 100

# load initial instructions and execute them
init_instr_str_seq = grab_instrs_from_bin("bins/init_py.bin", 100)
init_instr_seq = [create_instr_from_bin(instr_str) for instr_str in init_instr_str_seq]
program.instructions.extend(init_instr_seq)
print(f"Program instruction length: {len(program.instructions)}\n")
program.exec(max_cycles=2000, debug=0)

# # remove later
# print(f"\n{program.instr_addr_range[1]:08X}")
# print("\nExiting after initalization, change later")
# sys.exit()

# delete file
with open("asms/intermediate/generated_instructions.s", "w") as f:
    f.write("\n")

print("\nNow generating and executing random instruction sequence...\n")

    
# program.exec(max_cycles=2000, debug=1)    

# NOTE: Currently, our jumps/branches only go backwards

"""
    Strategies for generating valid random sub-sequences:
    # 1: No backward branches/jumps (or only backward branches/jumps)
        - Each instruction executes only once, hence can guarantee valid loads, stores, and jalr's (allows all instructions) 
"""

max_safe_instr_count = 20
max_branch_frwd_offset = 10

safe_instr_args = {
    "max_attempts": 100, 
    # "debug": 2, # need to change something
    # "append": True,
    "frwd_instr_range_offset": 0,
    "prob_dict": safe_set,
    "imm_bounds": (-200, 200), # consider changing
    "u_imm_bounds": (-1e10, 1e10)
}

for _ in range(rand_sub_seq_num):
    # generage safe instructions
    print("\nGenerating and running safe instructions...\n")
    program.gen_rand_program_seq_and_add(
        num_instr=rand.randint(0, max_safe_instr_count), 
        **safe_instr_args
    )
    program.exec(max_cycles=2000, debug=1)

    # generate a forward control instruction (branch/jal/jalr) with a random offset, and add filler instructions if needed
    print("\nGenerating and running forward control instruction...\n")
    program.gen_and_exec_frwd_cntrl_instr(
        type3 = rand.choice(list(cntrl_set)),
        frwd_instr_frwd_offset_range = (1, max_branch_frwd_offset),
        max_attempts = 100,
        debug = 2
    )

    # generage safe instructions
    print("\nGenerating and running safe instructions...\n")
    program.gen_rand_program_seq_and_add(
        num_instr=rand.randint(0, max_safe_instr_count),
        **safe_instr_args
    )
    program.exec(max_cycles=2000, debug=1)

    # print("\nExiting after generating and executing random instruction sequence, change later\n")
    # sys.exit()

    # generate mem operation
    print("\nGenerating and running memory operation instruction...\n")
    program.gen_and_exec_mem_instr(
        type3 = rand.choice(list(mem_set)),
        max_attempts = 100,
        imm_bounds=(-2048, 2047),
        # imm_bounds=(0, 2047),
        debug = 2,
        data_addr_range=(data_base_addr, data_base_addr + 2047)
    )

    # generage safe instructions
    print("\nGenerating and running safe instructions...\n")
    program.gen_rand_program_seq_and_add(
        num_instr=rand.randint(0, max_safe_instr_count), 
        **safe_instr_args
    )
    program.exec(max_cycles=2000, debug=1)

print("\nProgram memory states:")
program.memory.print_valid_address_ranges()