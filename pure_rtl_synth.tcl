# Building core module for timing and resource estimation (no other IP integration)

# run in terminal terminal: vivado -mode batch -source pure_rtl_synth.tcl

# Kria KV260 (Zynq UltraScale+ MPSoC)
set target_part "xck26-sfvc784-2LV-c"

# synthesize and get reports
set rtl_path "./ooo_rtl"
read_verilog -sv [glob $rtl_path/utils/*.sv]
read_verilog -sv [glob $rtl_path/*.sv]
synth_design -top core -part $target_part
file mkdir ./reports
report_utilization -file ./reports/synth_utilization.txt
report_timing_summary -file ./reports/synth_timing_summary.txt
report_timing -file ./reports/synth_timing_detailed.txt
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
