#!/bin/bash
export PATH="$HOME/.local/bin:$PATH"
cd "/mnt/c/Users/damia/Desktop/FSOT NEURON idris" || exit 1
mkdir -p data/results
echo "=== SCALPEL ==="
./build/exec/fsot-mind scalpel 2>&1 | tee data/results/SCALPEL_OUT.txt
echo SCALPEL_EXIT:$?
echo "=== PHASE-A (may take several minutes for isi-ks) ==="
./build/exec/fsot-mind phase-a 2>&1 | tee data/results/PHASE_A_TOP_TO_BOTTOM.txt
echo PHASE_A_EXIT:$?
