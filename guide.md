#### build basic risc-v CPU
instruction types:
    Normal
        ALU
        ALU-Imm
    Stalling
        load
        store
        branch (based on register value(s))
        jump
        jump and link
Special Cases:

    RAW:
    #1:
        add r4 r1 r2
        add r5 r3 r4
    #2:
        lw r4 #(4)
        add r5 r3 r4
    Solution: have forwarding on 
        EX (actually start of MEM) back to EX
        MEM (actually start of WB) back to EX

    Jumping:
        Solution: put an adder in ID stage to compute relative addr
    Jal:
        Solution: put an additional adder in the ID stage, or send the PC + 4 from the IF
        - prefer the 2nd

    Branching:
        Determined at EX stage, sent back at MEM stage
        
###########################

 (could be false)assumption: branch predictor and btb have same non transient entries

Setup: additonal adder in ID stage, conditionals determined in EX stage

1: 	btb empty, branch decision history empty
fetch instr, query btb/query branch_pred, see no hit, thus cant make a prediction
id stage: determine its branching, compute branch_trgt_addr using adder 

2: 	
        
###############################

ID stage: relevant instruction cases

reference:
https://www.cs.sfu.ca/~ashriram/Courses/CS295/assets/notebooks/RISCV/RISCV_CARD.pdf


