# Port map — Zig / Haskell → Idris2

**Zig authority:** `I:\fsot-neuron-zig`  
**Haskell twin:** Desktop `FSOT NEURON haskell` · github.com/dappalumbo91/fsot-neuron-haskell  
**Idris twin:** Desktop `FSOT NEURON idris` · github.com/dappalumbo91/fsot-neuron-idris  

Same law pin D1D38A, same genetics-as-code doctrine, same Allen product path.

| Zig | Haskell | Idris2 | Status |
|-----|---------|--------|--------|
| fixed.zig | Fsot.Fixed | Fsot.Fixed | SCALE=1e12 |
| trit.zig | Fsot.Trit | Fsot.Trit | T={-1,0,+1} |
| codon.zig | Fsot.Codon | Fsot.Codon | 64-codon + ORF |
| genotype_fixed | Fsot.Genotype | Fsot.Genotype | FI knobs |
| bio_probe_fixed | Fsot.BioProbe | Fsot.BioProbe | FI + polish |
| allen_isi_ks_product | Fsot.AllenIsiKs | Fsot.AllenIsiKs | **product** |
| main_mind subset | Fsot.Mind | Fsot.Mind | modes |

## Build (WSL recommended on this lab host)

```bash
# Idris2 + pack install once:
bash scripts/install_idris2_wsl.sh

export PATH="$HOME/.local/bin:$PATH"
cd "/mnt/c/Users/damia/Desktop/FSOT NEURON idris"
pack build fsot-neuron-idris.ipkg
# or: idris2 --build fsot-neuron-idris.ipkg
./build/exec/fsot-mind selftest
./build/exec/fsot-mind isi-ks
```

## Doctrine

1. No free-param FI tables — codon ORFs + class nudge + mutateOrf.  
2. Allen is readout (specimen polish + CSV targets).  
3. Native units: ISI ms, rate Hz, adapt abs.  
4. Zig Fixed lattice remains bare-metal authority.
