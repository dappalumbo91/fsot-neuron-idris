#!/bin/bash
export PATH="$HOME/.local/bin:$PATH"
cd "/mnt/c/Users/damia/Desktop/FSOT NEURON idris" || exit 1
./build/exec/fsot-mind phase-b 2>&1 | tee data/results/PHASE_B_TOP_TO_BOTTOM.txt
echo IDRIS_PB_EXIT:$?
