# Note: launch with "source sim.sh"

if [ -n "${start_ran}" ]; then
    echo "already ran start.sh..."
else
    echo "running start.sh..."
    source start.sh
fi


mkdir logs
mkdir jous
# echo "source build.tcl" | vivado -mode tcl -log logs/test.log -journal jous/test.jou
# vivado -mode tcl -log logs/test.log -journal jous/test.jou
vivado -mode batch -source pure_rtl_synth.tcl -log logs/test.log -journal jous/test.jou
