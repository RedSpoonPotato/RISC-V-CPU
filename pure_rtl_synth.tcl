# Building core module for timing and resource estimation (no other IP integration)

# run in terminal terminal: vivado -mode batch -source pure_rtl_synth.tcl

# Kria KV260 (Zynq UltraScale+ MPSoC)
set target_part "xck26-sfvc784-2LV-c"

# Out-Of-Context Synthesis: No mapping to external package pins, thus bypassing slow IO buffers and getting 
#   a realistic timing estimation for when we setup the AXI DMA to DDR connection
# Note: This is best case scenario (does nto account cdc, routing and placement, axi wire delay, etc), 
#   and thus when getting estimations of WNS, should realstically aim for +1.00ns

# ooc synthesize and get reports
set rtl_path "./ooo_rtl"
read_verilog -sv [glob $rtl_path/utils/*.sv]
read_verilog -sv [glob $rtl_path/*.sv]
read_xdc core_ooc.xdc
set_msg_config -id {Synth 8-7129} -limit 10000
# synth_design -top core -part $target_part
# NOTE: remove out of context flag once we implement xdc file
synth_design -top core -part $target_part -mode out_of_context
file mkdir ./reports
report_utilization -file ./reports/ooc_synth_utilization.txt
report_timing_summary -file ./reports/ooc_synth_timing_summary.txt
report_timing -file ./reports/ooc_synth_timing_detailed.txt
puts "========================================================="
puts "Synthesis Complete! Reports Generated"
puts "========================================================="

# # placement and getting report
# place_design
# report_utilization -file ./reports/place_utilization.txt
# report_timing_summary -file ./reports/place_timing_summary.txt
# report_timing -file ./reports/place_timing_detailed.txt
# puts "========================================================="
# puts "Placement Complete! Reports Generated"
# puts "========================================================="

# # routing and getting report
# route_design
# report_utilization -file ./reports/route_utilization.txt
# report_timing_summary -file ./reports/route_timing_summary.txt
# report_timing -file ./reports/route_timing_detailed.txt
# puts "========================================================="
# puts "Routing Complete! Reports Generated"
# puts "========================================================="
