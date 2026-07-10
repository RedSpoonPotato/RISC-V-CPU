from utils import *

program = Program(
    instr_mem_space_byte_size=0x10000,
    instr_mem_base_addr=0x80000000,
    data_mem_size=0x10000,
    data_mem_base_addr=0x80010000
)

# load initial instructions and execute them
init_instr_str_seq = grab_instrs_from_bin("bins/init_py.bin", 100)
init_instr_seq = [create_instr_from_bin(instr_str) for instr_str in init_instr_str_seq]
program.instructions.extend(init_instr_seq)
print(f"Program instruction length: {len(program.instructions)}\n")
program.exec(max_cycles=2000, debug=0)

# remove later
print("\nExiting after initalization, change later")
sys.exit()

safe_set = set(InstrType3) - {"LOAD", "STORE", "JALR"}

# delete file
with open("generated_instructions.txt", "w") as f:
    f.write("")

print("\nNow generating and executing random instruction sequence...\n")
for _ in range(1):
    program.gen_rand_program_seq(
        num_instr=50, 
        max_attempts=100, 
        debug=2,
        append=True,
        frwd_instr_range_offset=4,
        prob_dict={"ALU_R": 0.3, "ALU_I": 0.5, "BRANCH": 0, "JAL": 0, "LUI": 0.05, "AUIPC": 0.05},
        imm_bounds=(-200, 200)
        )
    print("\nNow executing the generated random instruction sequence...\n")
    program.exec(max_cycles=2000, debug=1)
    program.gen_rand_program_seq(
        num_instr=1,
        max_attempts=100,
        debug=2,
        frwd_instr_range_offset=0,
        prob_dict={"LOAD", "STORE", "JALR"},
        imm_bounds=(-200, 200)
    )
    # program.exec(max_cycles=2000, debug=1)
    # print("\nNow executing the generated random instruction sequence...\n")

    
# program.exec(max_cycles=2000, debug=1)    

# NOTE: Currently, our jumps/branches only go backwards

