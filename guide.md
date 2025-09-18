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
        
    


        


