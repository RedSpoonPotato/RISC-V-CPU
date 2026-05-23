#!/bin/bash
clear
echo "### Starting Compilation ###\n"


# "--lint-only" instead of "--binary to not waste time building a C++ model"
# can possily speed up by using "-j 0" to use more cores
verilator --lint-only --top core -f project.f --error-limit 6 \
    -Wno-IMPLICITSTATIC -Wno-PINMISSING -Wno-WIDTHEXPAND -Wno-WIDTHTRUNC

echo "\n### Finished Compilation ###\n"