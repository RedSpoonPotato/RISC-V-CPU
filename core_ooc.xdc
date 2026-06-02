# Out-Of-Context Synthesis: No mapping to external package pins, thus bypassing slow IO buffers and getting 
#   a realistic timing estimation for when we setup the AXI DMA to DDR connection

# create_clock -period 3.600 -name sys_clk [get_ports clk]

create_clock -period 4.700 -name sys_clk [get_ports clk]







