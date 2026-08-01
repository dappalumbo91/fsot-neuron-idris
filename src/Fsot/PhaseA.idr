||| Phase A stack — same order as Zig / Haskell twin.
module Fsot.PhaseA

import Fsot.Organism
import Fsot.ComposeIntel
import Fsot.IntelLoop
import Fsot.InternalThink
import Fsot.GeneticCore
import System

%default covering

export
runPhaseA : IO ()
runPhaseA = do
  putStrLn "=============================================="
  putStrLn " FSOT PHASE A (Idris twin = Zig Phase A)"
  putStrLn "=============================================="
  putStrLn "order: genetic -> organism -> compose -> intel-loop -> think"

  putStrLn ""
  putStrLn "--- A0 GENETIC DNA/TRINARY/FSOT ---"
  okG <- runGeneticCore
  if not okG
    then do
      putStrLn "FSOT_PHASE_A FAIL"
      exitFailure
    else pure ()

  putStrLn ""
  putStrLn "--- A1 ORGANISM ---"
  if not Fsot.Organism.selfTest
    then do
      putStrLn "FSOT_ORGANISM FAIL"
      exitFailure
    else do
      let o0 = initOrganism
          o1 = foldl (\o, _ => tick o 0.5) o0 [1..48]
          o2 = teach o1 "one and one" "two"
          triple = ask o2 "one and one"
          ans = case triple of (_, a, _) => a
          ok = case triple of (_, _, k) => k
      putStrLn $ "ORGANISM ticks=" ++ show o1.oTick ++ " spikes=" ++ show o1.oSpikes
               ++ " ok=" ++ show ok ++ " ans=" ++ ans
      if not ok
        then do
          putStrLn "FSOT_PHASE_A FAIL"
          exitFailure
        else putStrLn "FSOT_ORGANISM PASS"

  putStrLn ""
  putStrLn "--- A2 COMPOSE ---"
  let cr = Fsot.ComposeIntel.runComposeIntel
  Fsot.ComposeIntel.printReport cr
  if not cr.crOk then exitFailure else pure ()

  putStrLn ""
  putStrLn "--- A3 INTEL-LOOP ---"
  let lr = Fsot.IntelLoop.runIntelLoop
  Fsot.IntelLoop.printReport lr
  if not lr.lrOk then exitFailure else pure ()

  putStrLn ""
  putStrLn "--- A4 THINK PROBE ---"
  let tr = Fsot.InternalThink.runThinkProbe
  Fsot.InternalThink.printReport tr
  if not tr.trOk then exitFailure else pure ()

  putStrLn ""
  putStrLn "=============================================="
  putStrLn " FSOT_PHASE_A PASS"
  putStrLn " FSOT_CONTINUOUS_ORGANISM_OK"
  putStrLn " FSOT_TWIN_PHASE_A_OK"
  putStrLn "=============================================="
