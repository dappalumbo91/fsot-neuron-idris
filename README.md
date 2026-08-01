# FSOT NEURON Idris

**Fluid Spacetime Omni-Theory (FSOT) neural mind — Idris 2 host twin of the Zig domain engine.**

Not a second theory. Same law, same DNA→trinary→FSOT genetics, same Phase A product function, measured to the **same accuracy gates** as Zig and Haskell.

Idris adds a **type-checked structure layer** over genetic programs (biological hygiene as machine-checked form).

---

## Language twins network (linking system)

| Role | Language | Repository |
|------|----------|------------|
| **Authority** | Zig | [fsot-neuron-zig](https://github.com/dappalumbo91/fsot-neuron-zig) |
| **Host twin** | Haskell | [fsot-neuron-haskell](https://github.com/dappalumbo91/fsot-neuron-haskell) |
| **This twin** | Idris 2 | [fsot-neuron-idris](https://github.com/dappalumbo91/fsot-neuron-idris) |

```text
         FSOT pin D1D38A  ·  DNA/codon → trinary → FI  ·  Allen ms/Hz
                              |
              +---------------+---------------+
              |               |               |
           [Zig]          [Haskell]        [Idris]
         Fixed+QEMU       Phase A+KS      this repo
              |               |               |
              +--- same function · same accuracy ---+
```

**Full linking system (read this first):**  
[`docs/LANGUAGE_TWINS_NETWORK.md`](docs/LANGUAGE_TWINS_NETWORK.md)

**DNA physical function via trinary + FSOT:**  
[`docs/DNA_TRINARY_FSOT.md`](docs/DNA_TRINARY_FSOT.md)

**Phase A parity across languages:**  
[`docs/PHASE_A_PARITY.md`](docs/PHASE_A_PARITY.md)

### Cross-language boot (same gates)

| Gate | Zig | Haskell | This repo (Idris) |
|------|-----|---------|-------------------|
| DNA / codon / class FI | genetic / fixed | genetic / isi-ks | **`genetic`** |
| Continuous organism | organism | organism | **`organism`** |
| Compose | compose | compose | **`compose`** |
| Intel-loop | intel-loop | intel-loop | **`intel-loop`** |
| Think probe | think | think | **`think`** |
| **Phase A suite** | compose+loop+think+… | **`phase-a`** | **`phase-a`** |

---

## Measured accuracy (lab boot)

```text
./build/exec/fsot-mind phase-a

FSOT_GENETIC_CORE PASS       ATG=Met PRIMARY=[+1,-1,+1]  PV>>Pyr
FSOT_ORGANISM PASS
FSOT_COMPOSE_INTEL PASS      claim_rate=1.0
FSOT_INTEL_LOOP PASS         claim_pre=post=1.0
FSOT_INTERNAL_THINK PASS     continuous organism
FSOT_PHASE_A PASS
FSOT_TWIN_PHASE_A_OK
```

Zig Fixed SCALE=1e12 remains **bit-authority**. This twin proves **functional / scientific equivalence** on Phase A, with type-checked genetic structure.

---

## Prerequisites (WSL2 Ubuntu)

```powershell
# one-time toolchain
wsl -e bash -c "bash /mnt/c/Users/damia/Desktop/FSOT\ NEURON\ idris/scripts/install_idris2_wsl.sh"
# or use already-installed: Idris 2 0.8.0 + pack under ~/.local/bin
```

## Build & run

```bash
# inside WSL
export PATH="$HOME/.local/bin:$PATH"
cd "/mnt/c/Users/damia/Desktop/FSOT NEURON idris"
# or: git clone https://github.com/dappalumbo91/fsot-neuron-idris.git

idris2 --build fsot-neuron-idris.ipkg
./build/exec/fsot-mind phase-a     # full Phase A (recommended)
./build/exec/fsot-mind think       # continuous organism think probe
./build/exec/fsot-mind genetic     # DNA → trinary → FSOT FI
./build/exec/fsot-mind selftest
./build/exec/fsot-mind parity
```

### High-signal modes

| Mode | What it tests |
|------|----------------|
| `phase-a` | Genetic + organism + compose + intel-loop + think |
| `genetic` | Physical DNA · PRIMARY trinary · class FI · PV≫Pyr |
| `think` | Continuous organism think probe |
| `intel-loop` | Train → sleep → prove |
| `compose` | Answer-dependent multi-hop |
| `organism` | Continuous tick + episodic memory |
| `codon` | ATG = Met · PRIMARY = [+1,−1,+1] |

## Layout

```text
src/Fsot/   Trit, Codon, Genotype, BioProbe, GeneticCore,
            Neuron, Memory, Organism, IntelLoop, ComposeIntel,
            InternalThink, PhaseA, Mind, …
data/allen/ Allen samples (shared with Zig/Haskell)
docs/       LANGUAGE_TWINS_NETWORK · DNA_TRINARY_FSOT · PHASE_A_PARITY
```

## Why Idris in the network

| Layer | Role |
|-------|------|
| Runtime twin | Same Phase A gates as Zig/Haskell |
| Type layer | Codon/ORF/gene programs must type-check — structure proof of DNA→trinary pipeline |

See [`docs/DNA_TRINARY_FSOT.md`](docs/DNA_TRINARY_FSOT.md).

## Related FSOT GitHub

| Repo | Role |
|------|------|
| [FSOT-2.1-Lean](https://github.com/dappalumbo91/FSOT-2.1-Lean) | Law / Lean |
| [FSOT-2.1-Neural](https://github.com/dappalumbo91/FSOT-2.1-Neural) | Wet-lab / banks |

## License

Apache-2.0
