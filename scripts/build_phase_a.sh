#!/bin/bash
export PATH="$HOME/.local/bin:$PATH"
cd "/mnt/c/Users/damia/Desktop/FSOT NEURON idris" || exit 1
idris2 --build fsot-neuron-idris.ipkg 2>&1 | tee /tmp/idris_build.log | tail -100
echo EXIT:$?
