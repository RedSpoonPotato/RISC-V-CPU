#!/bin/bash

echo "### Starting Compilation ###\n"


# "--lint-only" instead of "--binary to not waste time building a C++ model"
# can possily speed up by using "-j 0" to use more cores
verilator --lint-only --top core -f project.f

echo "### Finished Compilation ###\n"