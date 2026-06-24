.section .text
    .global _start

_start:
    # ==========================================
    # 1. MEMORY INITIALIZATION (Densely Packed)
    # ==========================================
    # Writing values 0 to 255 into memory addresses 0x0 to 0xFF.
    # 
    # Register Usage for Loop:
    # x5 (t0) = loop counter / value to write
    # x6 (t1) = loop boundary (256)
    # x7 (t2) = current memory address 

    li x5, 0                # Start value at 0
    li x6, 256              # Stop value at 256
    li x7, 0x0              # Base memory address (Starts exactly at 0)

mem_init_loop:
    sb x5, 0(x7)            # Store the current byte (x5) into memory at address in x7
    addi x5, x5, 1          # Increment the value by 1
    addi x7, x7, 1          # Advance the memory pointer by exactly 1 byte
    bltu x5, x6, mem_init_loop # If value < 256, loop back

    # ==========================================
    # 2. REGISTER INITIALIZATION
    # ==========================================
    # There are 32 General Purpose Registers (GPRs). x0 is hardwired to 0.
    # The loop above initialized x5, x6, and x7. 
    # To initialize roughly half the space, we will set 12 more deterministic values.
    #
    # Uncommitted Registers left alone for your generator: 
    # x1-x4, x8-x9, x22-x31 (16 registers left completely uninitialized)

    li x10, 0x11
    li x11, 0x22
    li x12, 0x33
    li x13, 0x44
    li x14, 0x55
    li x15, 0x66
    li x16, 0x77
    li x17, 0x88
    li x18, 0x99
    li x19, 0xAA
    li x20, 0xBB
    li x21, 0xCC

    # ==========================================
    # 3. HANDOFF TO RANDOM INSTRUCTIONS
    # ==========================================
    # CPU State:
    # - Memory 0x00 to 0xFF holds values 0 to 255.
    # - x5 contains 256
    # - x6 contains 256
    # - x7 contains 256 (0x100, the next open memory address)
    # - x10 through x21 contain known hex patterns.
    # - The remaining 16 registers are uncommitted.
    
    # [Your generated random instructions begin executing here]