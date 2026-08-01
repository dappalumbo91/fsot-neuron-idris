||| Allen Cre class FI scalpel — twin of Zig scalpel_rate_fixed.
||| Genetic ORF seed + adjustToward until |rate − target| ≤ abs Hz tol.
||| Doctrine: no free FI tables; Allen rates are readout after genetic seed.
module Fsot.ScalpelRate

import Fsot.BioProbe
import Fsot.CellTypes
import Fsot.Genotype

%default covering

public export
record ClassRate where
  constructor MkClassRate
  crLabel : String
  crTargetHz : Double
  crMeasuredHz : Double
  crAbsErrHz : Double
  crTolHz : Double
  crRelErr : Double
  crClosed : Bool

public export
record ScalpelReport where
  constructor MkScalpelReport
  srOk : Bool
  srPyr : ClassRate
  srPv : ClassRate
  srSst : ClassRate
  srVip : ClassRate
  srPvFaster : Bool
  srIters : Int

tolHz : CellType -> Double
tolHz Pyr = 0.33
tolHz Pv = 1.67
tolHz Sst = 0.59
tolHz Vip = 0.70

emptyClass : CellType -> ClassRate
emptyClass ct =
  MkClassRate (classLabel ct) (allenRateHz ct) 0 1 (tolHz ct) 1 False

measureClass : CellType -> UnitParams -> Int -> ClassRate
measureClass ct p steps =
  let pr = runFIUnit p steps
      target = allenRateHz ct
      tol = tolHz ct
      m = pr.fiRateHz
      absE = abs (m - target)
      rel = if target > 1 then absE / target else 1
      closed = absE <= tol
  in MkClassRate (classLabel ct) target m absE tol rel closed

||| Adjust UnitParams toward Allen target (host Double twin of Zig adjustToward).
adjustToward : UnitParams -> Double -> Double -> Double -> UnitParams
adjustToward p measured target tol =
  if target <= 1 || measured <= 0 then p
  else
    let absE = measured - target
        big = abs absE > 5.0 * tol
    in if absE > tol
         then
           let thr = min 1.40 (p.upFireThr + (if big then 0.03 else 0.012))
               st = max 0.22 (p.upFiStim * (if big then 0.92 else 0.97))
               ref = min 180 (p.upRefSteps + (if big then 3 else 1))
           in MkUnitParams p.upDEff thr ref p.upAdaptGain p.upAdaptDecay p.upAdaptStep st
         else if absE < negate tol
           then
             let thr = max 0.72 (p.upFireThr - (if big then 0.04 else 0.015))
                 st = min 1.35 (p.upFiStim * (if big then 1.10 else 1.05))
                 ref = max 3 (p.upRefSteps - (if big then 3 else 1))
                 g = if big then max 0.008 (p.upAdaptGain * 0.9) else p.upAdaptGain
                 d = if big then max 0.05 (p.upAdaptStep * 0.85) else p.upAdaptStep
             in MkUnitParams p.upDEff thr ref g p.upAdaptDecay d st
           else p

seedParams : CellType -> UnitParams
seedParams ct = paramsFromCellType ct 0 False

fiSteps : Int
fiSteps = 1200

maxIters : Int
maxIters = 80

public export
runScalpel : ScalpelReport
runScalpel =
  let go : Int -> UnitParams -> UnitParams -> UnitParams -> UnitParams -> ScalpelReport
      go it pPyr pPv pSst pVip =
        let pyr = measureClass Pyr pPyr fiSteps
            pv = measureClass Pv pPv fiSteps
            sst = measureClass Sst pSst fiSteps
            vip = measureClass Vip pVip fiSteps
            faster = pv.crMeasuredHz > pyr.crMeasuredHz * 2.0
            allClosed = pyr.crClosed && pv.crClosed && sst.crClosed && vip.crClosed && faster
        in if allClosed || it >= maxIters
             then MkScalpelReport allClosed pyr pv sst vip faster (it + 1)
             else
               let pPyr' = if pyr.crClosed then pPyr
                            else adjustToward pPyr pyr.crMeasuredHz pyr.crTargetHz pyr.crTolHz
                   pPv' = if pv.crClosed then pPv
                          else adjustToward pPv pv.crMeasuredHz pv.crTargetHz pv.crTolHz
                   pSst' = if sst.crClosed then pSst
                           else adjustToward pSst sst.crMeasuredHz sst.crTargetHz sst.crTolHz
                   pVip' = if vip.crClosed then pVip
                           else adjustToward pVip vip.crMeasuredHz vip.crTargetHz vip.crTolHz
               in go (it + 1) pPyr' pPv' pSst' pVip'
  in go 0 (seedParams Pyr) (seedParams Pv) (seedParams Sst) (seedParams Vip)

showClassRate : ClassRate -> String
showClassRate c =
  c.crLabel
    ++ " target=" ++ show c.crTargetHz
    ++ " measured=" ++ show c.crMeasuredHz
    ++ " abs_err=" ++ show c.crAbsErrHz
    ++ " tol=" ++ show c.crTolHz
    ++ " rel_err=" ++ show c.crRelErr
    ++ " closed=" ++ show c.crClosed

public export
printReport : ScalpelReport -> IO ()
printReport r = do
  putStrLn "=== FSOT SCALPEL RATES (Allen Cre class FI - IDRIS) ==="
  putStrLn "doctrine: genetic ORF seed + adjustToward; |rate-target| Hz; PV>>Pyr; no free FI tables"
  putStrLn (showClassRate r.srPyr)
  putStrLn (showClassRate r.srPv)
  putStrLn (showClassRate r.srSst)
  putStrLn (showClassRate r.srVip)
  putStrLn $ "pv_faster_than_pyr=" ++ show r.srPvFaster ++ " iters=" ++ show r.srIters
  if r.srOk
    then do
      putStrLn "FSOT_SCALPEL_RATES PASS"
      putStrLn "FSOT_ALLEN_CLASS_RATES_CLOSED"
      putStrLn "FSOT_IDRIS_SCALPEL_OK"
    else putStrLn "FSOT_SCALPEL_RATES FAIL"

public export
selfTest : Bool
selfTest =
  let r = runScalpel
  in r.srPvFaster && r.srPyr.crMeasuredHz > 1 && r.srPv.crMeasuredHz > r.srPyr.crMeasuredHz
