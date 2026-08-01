||| ORF -> expression -> phenotype -> FI knobs (genetics-as-code).
module Fsot.Genotype

import Fsot.CellTypes
import Fsot.Codon
import Fsot.Seeds
import Data.String
import Data.List

%default total

public export
data GeneName = Scn | Kcn | Cacna | Leak

public export
Eq GeneName where
  Scn == Scn = True
  Kcn == Kcn = True
  Cacna == Cacna = True
  Leak == Leak = True
  _ == _ = False

public export
record GeneProgram where
  constructor MkGeneProgram
  gpName : GeneName
  gpSpin : Double
  gpExpression : Double
  gpCharge : Int
  gpAromatic : Double

public export
record Phenotype where
  constructor MkPhenotype
  phDEff : Double
  phFireThr : Double
  phRefractory : Double
  phAdaptStep : Double
  phAdaptGain : Double
  phAdaptDecay : Double
  phFiStim : Double
  phCompositeSpin : Double
  phCompositeCharge : Double

public export
record UnitParams where
  constructor MkUnitParams
  upDEff : Double
  upFireThr : Double
  upRefSteps : Int
  upAdaptGain : Double
  upAdaptDecay : Double
  upAdaptStep : Double
  upFiStim : Double

public export
clampD : Double -> Double -> Double -> Double
clampD lo hi x = max lo (min hi x)

public export
classOrf : CellType -> GeneName -> String
classOrf Pyr Scn = "ATGGCCACCAAGATCGGCAAG"
classOrf Pyr Kcn = "ATGTTCAAGGTGCCCGACTAC"
classOrf Pyr Cacna = "ATGGAGCTGATCAACGAGTAC"
classOrf Pyr Leak = "ATGAGCCTGCCCAACATCATC"
classOrf Pv Scn = "ATGGCCAAGAAGATCGGCAAG"
classOrf Pv Kcn = "ATGTTCGTGGTGCCCGACTAC"
classOrf Pv Cacna = "ATGGAGCTGGTGAACGAGTAC"
classOrf Pv Leak = "ATGAGCCTGCCCAACGTGATC"
classOrf Sst Scn = "ATGGCCACCAGGATCGGCAAG"
classOrf Sst Kcn = "ATGTTCAAGGTGCCCTACTAC"
classOrf Sst Cacna = "ATGGAGCTGATCAACGACTAC"
classOrf Sst Leak = "ATGAGCCTGCCCAACATCGTG"
classOrf Vip Scn = "ATGGCCACCAAGGTGGGCAAG"
classOrf Vip Kcn = "ATGTTCAAGGTGCCCGACATC"
classOrf Vip Cacna = "ATGGAGCTGATCAACGAGATC"
classOrf Vip Leak = "ATGAGCCTGCCCAACATCAAG"

public export
flipBase : Char -> Char
flipBase b = case toUpper b of
  'A' => 'G'; 'G' => 'A'; 'C' => 'T'; 'T' => 'C'; 'U' => 'C'; x => x
  where
    toUpper : Char -> Char
    toUpper c = if c >= 'a' && c <= 'z' then cast (cast {to=Int} c - 32) else c

||| Trinary-preserving mutateOrf (1..4 sites).
public export
mutateOrf : String -> Int -> Int -> String
mutateOrf dna unitId locus =
  let chars = unpack dna
      n = length chars
  in if n == 0 then dna
     else
       let nMut = 1 + (unitId `mod` 4)
           positions : List Int
           positions = [ (unitId * 3 + locus * 5 + m * 7) `mod` n | m <- [0 .. nMut - 1] ]
           go : Int -> Char -> Char
           go i b = if i `elem` positions then flipBase b else b
       in pack (zipWith go [0 .. n - 1] chars)

public export
buildGeneProgram : GeneName -> String -> GeneProgram
buildGeneProgram name dna =
  let res = decodeOrf dna
  in MkGeneProgram name (meanSpin res) (geneExpression res) (chargeBalance res) (aromaticFraction res)

exprOf : List GeneProgram -> GeneName -> Double
exprOf genes n =
  case [gpExpression g | g <- genes, gpName g == n] of
    (e :: _) => e
    [] => 1.0

public export
phenotypeFromGenes : List GeneProgram -> Phenotype
phenotypeFromGenes genes =
  let scn = exprOf genes Scn
      kcn = exprOf genes Kcn
      ca = exprOf genes Cacna
      leak = exprOf genes Leak
      dEff = clampD 8 20 (neuroDEff + phi * (ca - 1.0) * 0.35 + 0.05 * (leak - 1.0))
      fire = clampD 0.85 1.25 (1.05 - 0.12 * (scn - 1.0) + 0.06 * (kcn - 1.0))
      ref = clampD 4 40 (12.0 * (0.85 + 0.30 * kcn))
      adaptStep = clampD 0 8 (0.7 * (0.6 + 0.8 * ca))
      adaptGain = 0.02 * (0.7 + 0.6 * ca)
      adaptDecay = clampD 0.96 0.995 (0.988 - 0.004 * (ca - 1.0))
      fi = clampD 0.25 0.95 (0.50 * (0.85 + 0.25 * scn - 0.10 * kcn))
      sumSpinW = sum [gpSpin g * gpExpression g | g <- genes]
      sumExpr = sum [gpExpression g | g <- genes]
      sumQ = sum [cast (gpCharge g) * gpExpression g | g <- genes]
      cspin = if sumExpr == 0 then 0 else sumSpinW / sumExpr
      ccharge = sumQ / 4.0
  in MkPhenotype dEff fire ref adaptStep adaptGain adaptDecay fi cspin ccharge

public export
applyClassNudge : CellType -> Phenotype -> Phenotype
applyClassNudge Pv ph =
  { phRefractory := clampD 3 40 (ph.phRefractory * 0.38)
  , phAdaptStep := ph.phAdaptStep * 0.28
  , phAdaptGain := ph.phAdaptGain * 0.60
  , phFireThr := clampD 0.78 1.25 (ph.phFireThr - 0.08)
  , phFiStim := clampD 0.25 1.20 (ph.phFiStim * 1.42)
  } ph
applyClassNudge Sst ph =
  { phAdaptStep := clampD 0 10 (ph.phAdaptStep * 1.4)
  , phRefractory := ph.phRefractory * 1.05
  } ph
applyClassNudge Vip ph =
  { phFiStim := ph.phFiStim * 0.9
  , phDEff := clampD 8 20 (ph.phDEff + 0.3 * phi)
  } ph
applyClassNudge Pyr ph =
  { phAdaptStep := ph.phAdaptStep * 0.95
  , phAdaptGain := ph.phAdaptGain * 1.08
  } ph

geneIndex : GeneName -> Int
geneIndex Scn = 0
geneIndex Kcn = 1
geneIndex Cacna = 2
geneIndex Leak = 3

public export
buildCellTypeGenotype : Int -> CellType -> Bool -> (Phenotype, List GeneProgram)
buildCellTypeGenotype unitId ct diversity =
  let names = [Scn, Kcn, Cacna, Leak]
      genes =
        [ let base = classOrf ct name
              dna = if diversity then mutateOrf base unitId (geneIndex name) else base
              g = buildGeneProgram name dna
          in { gpExpression := clampD 0.05 3.5 g.gpExpression } g
        | name <- names
        ]
      ph0 = phenotypeFromGenes genes
      ph = applyClassNudge ct ph0
  in (ph, genes)

public export
phenotypeFiKnobs : Phenotype -> UnitParams
phenotypeFiKnobs ph =
  let allenIsi = 70.59855571638475
      allenAd = 0.051153889361673456
      refNet = ph.phRefractory
  in if refNet < 9.0
        then
          let refI = the Int (cast (clampD 3 28 (refNet * 1.05)))
              g = clampD 0.008 0.04 (ph.phAdaptGain * 0.85)
              dFs = clampD 0.05 2.5 (ph.phAdaptStep * 0.35)
              fi = clampD 0.55 1.15 (ph.phFiStim * (0.90 + 0.12 * psiCon) * (0.97 + 0.04 * etaEff))
              thr = clampD 0.78 1.10 ph.phFireThr
          in MkUnitParams ph.phDEff thr refI g ph.phAdaptDecay dFs fi
        else
          let spin = ph.phCompositeSpin
              charge = ph.phCompositeCharge
              geneScale = clampD 0.55 1.55 (refNet / 13.0)
              rLaw = allenIsi * (1.0 - 0.45 * allenAd)
              refFi0 = rLaw * 0.72 * geneScale * (0.92 + 0.05 * (phi - 1.0))
              refFi1 = refFi0 * (1.0 + 0.40 * spin + 0.12 * charge)
              refFi = clampD 25 140 refFi1
              refI = the Int (cast refFi)
              a = clampD 0 0.55 allenAd
              d0 = (2.0 * a * max 8.0 refFi) / (9.0 * (1.0 - a) + 1e-9)
              d1 = d0 * 1.85 * clampD 0.5 1.6 (ph.phAdaptStep / 0.7)
              d = clampD 0.08 10 (d1 * (1.0 + 0.35 * spin))
              g = clampD 0.022 0.09 (ph.phAdaptGain * 1.35 * (1.0 + 0.20 * abs spin))
              fi = clampD 0.30 0.95 (ph.phFiStim * (0.88 + 0.20 * psiCon) * (0.95 + 0.08 * etaEff) * (1.0 + 0.18 * spin))
          in MkUnitParams ph.phDEff ph.phFireThr refI g ph.phAdaptDecay d fi

public export
selfTest : Bool
selfTest =
  let (ph, _) = buildCellTypeGenotype 0 Pyr False
      kn = phenotypeFiKnobs ph
      (phD, _) = buildCellTypeGenotype 1 Pyr True
      knD = phenotypeFiKnobs phD
  in ph.phCompositeSpin > 0.0 && kn.upRefSteps >= 1 && knD.upRefSteps >= 1
