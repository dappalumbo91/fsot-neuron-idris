||| FI readout from genetically produced knobs (Allen is readout, not source).
||| Native units: ISI ms, rate Hz, adapt dimensionless abs.
||| Doctrine: phenotypeFiKnobs come from codon ORFs + class program only.
module Fsot.BioProbe

import Fsot.CellTypes
import Fsot.Genotype
import Data.List

%default covering

public export
allenIsiMs : Double
allenIsiMs = 70.59855571638475

public export
minSpikesIsi : Int
minSpikesIsi = 2

public export
record Specimen where
  constructor MkSpecimen
  spIsiMs : Double
  spAdapt : Double

public export
record FiResult where
  constructor MkFiResult
  fiRateHz : Double
  fiMeanIsiMs : Double
  fiAdapt : Double
  fiSpikes : Int

public export
paramsFromCellType : CellType -> Int -> Bool -> UnitParams
paramsFromCellType ct unitId diversity =
  let (ph, _) = buildCellTypeGenotype unitId ct diversity
  in phenotypeFiKnobs ph

||| Discrete FI train on 1 ms lattice (host twin of Fixed FI step doctrine).
public export
runFIUnit : UnitParams -> Int -> FiResult
runFIUnit p steps =
  let thr = p.upFireThr
      go : Int -> Double -> Double -> Int -> List Int -> List Int
      go t s adapt refLeft fires =
        if t >= steps then fires
        else
          let (s1, adapt1, ref1, fired) =
                if refLeft > 0
                  then (0.0, adapt * p.upAdaptDecay, refLeft - 1, False)
                  else
                    let drive = max 0.0 (p.upFiStim - 0.35 * adapt)
                        s' = s * 0.88 + drive * 0.35 * (p.upDEff / 13.0)
                    in if s' >= thr
                         then (0.0, adapt + p.upAdaptStep * p.upAdaptGain, max 1 p.upRefSteps, True)
                         else (s', adapt * p.upAdaptDecay, 0, False)
              fires' = if fired then t :: fires else fires
          in go (t + 1) s1 adapt1 ref1 fires'
      spikeTimes = reverse (go 0 0.0 0.0 0 [])
      nSp : Int
      nSp = cast (length spikeTimes)
      mkIsis : List Int -> List Double
      mkIsis [] = []
      mkIsis [_] = []
      mkIsis (a :: b :: rest) =
        cast {to=Double} (b - a) :: mkIsis (b :: rest)
      isis = mkIsis spikeTimes
      meanIsi =
        case isis of
          [] => 0.0
          xs => foldl (+) 0.0 xs / cast {to=Double} (length xs)
      rate =
        if steps <= 0 then 0.0
        else cast {to=Double} nSp * 1000.0 / cast {to=Double} steps
      adaptIdx =
        let m : Int
            m = cast (length isis)
        in if m < 6 then 0.0
           else
             let third = max 1 (m `div` 3)
                 early = take (cast third) isis
                 late = drop (cast (m - third)) isis
                 me = foldl (+) 0.0 early / cast {to=Double} (length early)
                 ml = foldl (+) 0.0 late / cast {to=Double} (length late)
             in if me + ml < 0.000000001 then 0.0 else (ml - me) / (ml + me)
  in MkFiResult rate meanIsi adaptIdx nSp

specIsiTol : Double -> Double
specIsiTol isi = if isi < 35.0 then max 10.0 (0.28 * isi) else max 8.0 (0.14 * isi)

||| Adjust UnitParams without ambiguous record update syntax.
setRefStim : UnitParams -> Int -> Double -> UnitParams
setRefStim p ref st = MkUnitParams p.upDEff p.upFireThr ref p.upAdaptGain p.upAdaptDecay p.upAdaptStep st

setAdapt : UnitParams -> Double -> Double -> UnitParams
setAdapt p g d = MkUnitParams p.upDEff p.upFireThr p.upRefSteps g p.upAdaptDecay d p.upFiStim

||| Soft polish toward specimen ISI (Allen readout; genetics remains seed).
public export
polishToSpecimen : UnitParams -> Specimen -> Int -> UnitParams
polishToSpecimen p0 sp steps =
  let isi = max 8.0 (min 220.0 sp.spIsiMs)
      ad = max (-0.15) (min 0.6 sp.spAdapt)
      fast = isi < 35.0
      stimHi : Double
      stimHi = if fast then 1.40 else 0.95
      refLo : Int
      refLo = if fast then 3 else 4
      refScale : Double
      refScale = if fast then 0.52 else 0.72
      ref0 : Int
      ref0 = max refLo (min 160 (cast {to=Int} (isi * refScale)))
      fi0 : Double
      fi0 = if fast then max 0.55 (min 1.20 (p0.upFiStim * 1.15))
                   else max 0.35 (min 0.95 p0.upFiStim)
      g0 : Double
      g0 = if fast then max 0.008 (min 0.04 (p0.upAdaptGain * 0.55))
                   else max 0.010 (min 0.14 (0.018 + 0.85 * max 0.0 ad))
      d0 : Double
      d0 =
        let a = max 0.0 (min 0.55 ad)
            r = cast {to=Double} ref0
            base = if a < 0.000001 then 0.03 else (2.0 * a * r) / (9.0 * (1.0 - a) + 0.000000001)
            scaled = base * if fast then 1.15 else (2.05 + 2.2 * max 0.0 (ad - 0.03))
        in max 0.03 (min 14.0 scaled)
      pSeed = MkUnitParams p0.upDEff p0.upFireThr ref0 g0 0.988 d0 fi0
      isiTol = specIsiTol sp.spIsiMs
      go : Int -> UnitParams -> UnitParams
      go it p =
        if it >= 72 then p
        else
          let pr = runFIUnit p steps
          in if pr.fiSpikes < 6
               then go (it + 1) (setRefStim p (max refLo (p.upRefSteps - 2)) (min stimHi (p.upFiStim * 1.08)))
               else
                 let isiErr = abs (pr.fiMeanIsiMs - sp.spIsiMs)
                     adErr = abs (pr.fiAdapt - sp.spAdapt)
                 in if isiErr <= isiTol && adErr <= 0.05 then p
                    else
                      let p1 =
                            if isiErr > isiTol && pr.fiMeanIsiMs > 1.0
                              then if pr.fiMeanIsiMs > sp.spIsiMs
                                     then setRefStim p (max refLo (p.upRefSteps - 1))
                                          (min stimHi (p.upFiStim * (if fast then 1.05 else 1.03)))
                                     else setRefStim p (min 180 (p.upRefSteps + 1))
                                          (max 0.28 (p.upFiStim * 0.97))
                              else p
                          p2 =
                            if adErr > 0.05
                              then if pr.fiAdapt < sp.spAdapt
                                     then setAdapt p1 (min 0.14 (p1.upAdaptGain * 1.06)) (min 12.0 (p1.upAdaptStep * 1.12))
                                     else setAdapt p1 (max 0.012 (p1.upAdaptGain * 0.95)) (max 0.04 (p1.upAdaptStep * 0.90))
                              else p1
                      in go (it + 1) p2
  in go 0 pSeed
