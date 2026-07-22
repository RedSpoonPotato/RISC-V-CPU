    
    jal x22,  exiting_step
    li x23, 0xFFFF      # Should skip
exiting_step:
    li x31, 0x80012100
    li x30, 0xFFFFFFFF
    # this notifies UVM testbench to stop execution
    sw x30, 0(x31)
