# FSOT NEURON Idris

**Fluid Spacetime Omni-Theory (FSOT) neural mind — full-capability Idris2 twin** of the Zig domain engine (and Haskell sibling).

**Doctrine:** full capable copy of Zig — not a single-gate demo. See [`docs/FULL_CAPABILITY_PARITY.md`](docs/FULL_CAPABILITY_PARITY.md).

| | |
|--|--|
| **Zig authority** | [fsot-neuron-zig](https://github.com/dappalumbo91/fsot-neuron-zig) |
| **Haskell twin** | [fsot-neuron-haskell](https://github.com/dappalumbo91/fsot-neuron-haskell) |
| **This repo** | Desktop · `FSOT NEURON idris` |
| **Language** | [Idris 2](https://www.idris-lang.org/) (dependent types) |
| **Law pin** | D1D38A · same genetics-as-code / Allen readout doctrine |

Not a second theory. Same fold, same codon spine, same ISI KS product path — expressed in a language built for **correctness** and proofs.

## Why Idris

You have not written Idris before; that is fine. Idris 2 is a pure functional language with **dependent types** (types can depend on values). For FSOT this is useful later for stating “every cell closed” or KS bounds as type-level properties. v0.1 is a faithful runtime twin first.

## Layout

```text
FSOT NEURON idris/
  fsot-neuron-idris.ipkg
  src/Main.idr
  src/Fsot/{Fixed,Trit,Seeds,Codon,CellTypes,Genotype,BioProbe,AllenIsiKs,Mind}.idr
  data/allen/          # Allen CSV samples (from Zig/Haskell)
  docs/PORT_FROM_ZIG.md
  scripts/install_idris2_wsl.sh
```

## Prerequisites (this lab)

Install once inside **WSL2 Ubuntu** (pack + Idris2 bootstrap needs Linux tools + Chez Scheme):

```powershell
# from Windows:
wsl -e bash "/mnt/c/Users/damia/Desktop/FSOT NEURON idris/scripts/install_idris2_wsl.sh"
```

That installs:

- Chez Scheme (scheme)
- Idris 2 (via pack)
- `pack` package manager → `~/.local/bin`

## Build & run

```bash
# inside WSL:
export PATH="$HOME/.local/bin:$PATH"
cd "/mnt/c/Users/damia/Desktop/FSOT NEURON idris"

idris2 --build fsot-neuron-idris.ipkg
# or: pack build fsot-neuron-idris.ipkg

./build/exec/fsot-mind selftest
./build/exec/fsot-mind genetic
./build/exec/fsot-mind scalpel
./build/exec/fsot-mind isi-ks
```

### Modes (v0.1)

| Mode | Meaning |
|------|---------|
| `selftest` | Codon + genotype + KS self tests |
| `genetic` | Class ORF → FI smoke |
| `scalpel` | PV ≫ Pyr rate order |
| `isi-ks` | Full ISI distribution KS product |

## Product claim (target / measured when green)

```text
FSOT_ALLEN_ISI_KS_PRODUCT PASS
FSOT_IDRIS_ISI_KS_OK
```

Cross-check:

```powershell
# Zig
I:\fsot-neuron-zig\zig-out\bin\fsot_mind.exe isi-ks
# Haskell
cd "$env:USERPROFILE\Desktop\FSOT NEURON haskell"; cabal run fsot-mind -- isi-ks
```

## Port status

See [`docs/PORT_FROM_ZIG.md`](docs/PORT_FROM_ZIG.md).  
v0.1 = genetics spine + FI + ISI KS product.  
Next: tighten proofs / Fixed lattice, more organism modes.

## License

Apache-2.0
