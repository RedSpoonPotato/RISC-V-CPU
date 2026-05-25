# Define a 100 MHz clock (10ns period) tied to the 'clk' port
create_clock -period 10.000 -name sys_clk_pin [get_ports clk]



