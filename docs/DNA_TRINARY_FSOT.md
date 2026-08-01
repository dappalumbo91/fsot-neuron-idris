# DNA physical function through trinary code and FSOT

**Repo:** fsot-neuron-idris  
**Authority twins:** fsot-neuron-zig · fsot-neuron-haskell  
**Stance:** Genetics is **executable structure**, not free FI tables. Biological accuracy means the pipeline respects real DNA → protein logic, then maps it into **FSOT trinary** and seed-derived law.

---

## 1. Physical DNA (what wet biology does)

| Wet layer | Function |
|-----------|----------|
| **Base** | A, C, G, T (U in RNA) — discrete chemical alphabet |
| **Complement** | A↔T, C↔G — pairing chemistry (not free symbols) |
| **Codon** | Triplet of bases → amino acid (standard genetic code) |
| **ORF** | Open reading frame: start (ATG/Met) → residues → stop |
| **Translation** | Residues carry charge, volume, aromaticity → channel / membrane phenotype |
| **Class programs** | Cortical cell types (Pyr/PV/SST/VIP) differ in ion-channel gene sets |

We do **not** invent a new genetic code. IUPAC DNA→AA is authority. Trinary is the **FSOT encoding** of that chemistry for dynamics.

---

## 2. Trinary map (PRIMARY law)

From `data/64_codon_trinary_map.txt` and Zig `codon.zig`:

```text
PRIMARY (per base):   A,G → +1    C,T → −1
SECONDARY (per base): A → +1    T → −1    G,C → 0
Codon trip:           (t0, t1, t2) ∈ {−1,+1}³   (PRIMARY)
```

Example (biologically mandatory):

```text
ATG → Met (start)
PRIMARY(ATG) = (+1, −1, +1)
```

**Physical reading:** purine (A,G) vs pyrimidine (C,T) is a real chemical partition. PRIMARY is that partition as spin for FSOT pair weights — not arbitrary labeling.

---

## 3. FSOT expression law (genotype → knobs)

Residue list from ORF decode:

```text
spin      = mean of PRIMARY trits over residues
charge    = sum of AA charges (R,H,K = +1; D,E = −1)
aromatic  = fraction F,Y,W

expression = φ^spin · exp(|q| / (π · n)) · (1 + γ · aromatic)
             clamped to [0.05, 3.0]
```

Seeds φ, π, γ, η, ψ are **shared FSOT constants** (same as Zig/Haskell) — zero free LSQ fit per Allen cell.

Phenotype (class ORF + class nudge) → FI knobs (refractory, AHP, drive) → measured ISI/rate in **native ephys units** (ms, Hz).

---

## 4. Mutation (biological diversity without free noise)

`mutateOrf` flips **purine↔purine** and **pyrimidine↔pyrimidine** only:

```text
A ↔ G    C ↔ T
```

That preserves PRIMARY trit class at each site while changing the AA path — a trinary-preserving analogue of silent/missense diversity under codon chemistry, not Gaussian scatter on FI tables.

---

## 5. What Idris adds (structure as proof)

Type-checking is a **biological hygiene layer**:

| Constraint | Biological meaning |
|------------|--------------------|
| Codon is three bases | Triplet code, not free strings |
| ORF decode in steps of 3 | Reading frame |
| Gene set = 4 programs (SCN, KCN, CACNA, LEAK) | Channel-gene spine, not open param vector |
| Finite FI steps | Physical train duration, not unbounded process |
| Nat/Int discipline on site indices | Mutation sites live inside the DNA string |

This does **not** replace wet-lab truth. It forces the **code image of DNA** to stay structurally honest.

---

## 6. Pipeline (binding)

```text
DNA string (class ORF)
  → PRIMARY trinary codon trips
  → IUPAC amino acids + charge/aromatic
  → FSOT geneExpression (φ,π,γ)
  → class phenotype nudge (Cre program)
  → phenotypeFiKnobs (FI / AHP / ref)
  → FI train → ISI ms, rate Hz (Allen readout)
```

Allen CSV is the **readout**, not a second theory. Genetics is the **source**.

---

## 7. Non-claims

- Not molecular identity with wet tissue  
- Not all-atom MD of DNA (lab only)  
- Not free generative language as cognition  

Claims require measured gates (`isi-ks`, every-cell, class rates) on the twin that prints PASS.
