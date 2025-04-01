Brief Guide to Processor

- Tip: after making this in SystemVerilog, try recreating in HLS to see if the performance/results are better

Features
- 5 Stage Pipelining (maybe more if needed)
- Branch Prediction
    - global and local accessing
    - BTB to
- Forwarding
    - 

Branch Delay Cases
(1) Normal:
    - Fetch Instruction, Decode Instruction, Execute, Mem, Writeback
Fetch a Branch or Jump
- "mini"-decode within the IF stage to determine if instruction is a branch or jump
    - if jump, determine target address within the IF stage
        - requires an adder // in IF stage to not have stalls
    - if branch, decide whether or not to branch
        - if yes, then is target contained within buffer?
            - if yes, no, then compute the target
                - requires an adder
