#!/bin/bash
set -e

# Note: launch with "source sim.sh"

if [ -n "${start_ran}" ]; then
    echo "already ran start.sh..."
else
    echo "running start.sh..."
    source ../start.sh
fi

echo "========================================================="
echo " Step 1: Parsing SystemVerilog Files (xvlog)"
echo "========================================================="
# -sv: Interpret files as SystemVerilog
# -L uvm: Load the pre-compiled UVM library included with Vivado
# Order matters: Compile packages first, then RTL, then the testbench files
# xvlog -sv -L uvm \
#     ./ooo_rtl/utils/*.sv \
#     ./ooo_rtl/*.sv \
#     ./verification/uvm_files/tb_top.sv
xvlog -sv -L uvm -prj sim.prj

echo "========================================================="
echo " Step 2: Elaboration (xelab)"
echo "========================================================="
# -L uvm: Link UVM library during elaboration
# -timescale: Define simulation time units
# -debug typical: Preserves line numbers and visibility for waveform dumping
# -top tb_top: Specify the top-level module
# -snapshot tb_sim: Name the output simulation snapshot
xelab -L uvm -timescale 1ns/1ps -debug typical -top tb_top -snapshot tb_sim

echo "========================================================="
echo " Step 3: Simulation (xsim)"
echo "========================================================="
# -R: Run simulation immediately
# -testplusarg: Pass the trace file path to your scoreboard's $value$plusargs check
# xsim tb_sim -R -testplusarg TRACE_FILE=../python_scripts/trace_readable.log
# xsim tb_sim -R
# launching using xsim waveform viewer instead of gtkwave for structtracing
# xsim tb_sim --gui & # 
xsim tb_sim --gui -view wcfgs/latest.wcfg --t init.tcl & # use this if you want to open a waveform

# RUN waveform.tcl

