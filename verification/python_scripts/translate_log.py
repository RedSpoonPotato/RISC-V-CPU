from utils import *

def read_trace_log_line(line: str):
    """ 
    parse the line and return a dictionary of the parsed values
    example line: (spacing may not be exact)
    core   0: 3 {pc} ({instr in hex}) {{dest_reg} {value} (e.g. x5 0x00...)}
        or {{"mem"} {dest_addr} {value}} for pure control flow instrs

    examples:
    core   0: 3 0x00001008 (0xf1402573) x10 0x00000000 (alu, lui, auipc, jal, jalr)
    core   0: 3 0x0000100c (0x0182a283) x5  0x80000000 mem 0x00001018 (load)
    core   0: 3 0x80000010 (0x00538023) mem 0x80010100 0x00 (store)
    core   0: 3 0x8000001c (0xfe62eae3) (branches, jal/jalr to x0, noops)
    """
    str_arry = line.split()
    pc = int(str_arry[3], 16)
    instr = str_arry[4][1:-1]  # remove parentheses
    instr_int = int(instr, 16)
    instr_bin_str = format(instr_int, '032b')
    instr = create_instr_from_bin(instr_bin_str)
    if (instr.type3 == "BRANCH" or (instr.type2 in {"ALU", "LUI", "AUIPC", "JAL", "JALR"}  and instr.rd == 0)):
        assert len(str_arry) == 5, f"Unexpected format for branch or noop instruction: {line}"
        return {"pc": pc, "instr": instr}
    elif instr.type3 == "LOAD":
        assert len(str_arry) == 9, f"Unexpected format for load instruction: {line}"
        dest_reg = int(str_arry[5][1:], 10)
        data = int(str_arry[6], 16)
        addr = int(str_arry[8], 16)
        return {"pc": pc, "instr": instr, "dest_reg": dest_reg, "data": data, "addr": addr}
    elif instr.type3 == "STORE":
        assert len(str_arry) == 8, f"Unexpected format for store instruction: {line}"
        addr = int(str_arry[6], 16)
        store_data = int(str_arry[7], 16)
        return {"pc": pc, "instr": instr, "addr": addr, "store_data": store_data}
    else:
        assert len(str_arry) == 7, f"Unexpected format for other instruction: {line}"
        dest_reg = int(str_arry[5][1:], 10)
        data = int(str_arry[6], 16)
        return {"pc": pc, "instr": instr, "dest_reg": dest_reg, "data": data}

def read_trace_log_file(
        rd_file_path: str, 
        wr_file_path: str, 
        commit_ignore_count: int = 0,
        max_commit_count: int = 0
    ):
    """ read the trace.log file and return a list of dictionaries of the parsed values """
    with open(rd_file_path, "r") as f:
        content = f.read()

    map_list = []
    lines = content.splitlines()
    for i, line in enumerate(lines):
        if line.startswith("core"):
            if i < commit_ignore_count:
                continue
            dict = read_trace_log_line(line)
            map_list.append(dict)
    
    with open(wr_file_path, "w") as f:
        for i in range(min(len(map_list), max_commit_count)):
            dict = map_list[i]
            instr = dict["instr"]
            f.write(hex(dict["pc"]) + ": " + instr.gen_assembly_str() + "\n")
            dest_valid = instr.type3 not in {"STORE", "BRANCH"}
            if dest_valid:
                arch_reg_addr = instr.rd
            else:
                arch_reg_addr = 0
            store_en = instr.type3 == "STORE"
            if store_en:
                store_addr = dict["addr"]
                store_data = dict["store_data"]
            else:
                store_addr = 0
                store_data = 0
            # if i == len(map_list) - 1:
            #     next_pc = dict["pc"] + 4
            # else:
            #     next_pc = map_list[i+1]["pc"]
            pc = dict["pc"]
            if "data" in dict:
                reg_data = dict["data"]
            else:
                reg_data = 0
            f.write(
                str(int(dest_valid)) + " " + 
                str(arch_reg_addr) + " " + 
                str(int(store_en)) + " " + 
                str(hex(store_addr)) + " " + 
                str(hex(store_data)) + " " + 
                str(hex(pc)) + " " + 
                str(hex(reg_data)) + 
                "\n"
            )
    
if __name__ == "__main__":
    
    if len(sys.argv) < 3:
        print("Usage: python translate_log.py <read_file_path> <write_file_path> <commit_ignore_count> <max_commit_count>")
        sys.exit(1)
    rd_file_path = sys.argv[1]
    wr_file_path = sys.argv[2]
    commit_ignore_count = int(sys.argv[3]) if len(sys.argv) > 3 else 0
    max_commit_count = int(sys.argv[4]) if len(sys.argv) > 4 else 0
    read_trace_log_file(rd_file_path, wr_file_path, commit_ignore_count, max_commit_count)
    







    
