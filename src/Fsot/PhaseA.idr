||| Phase A stack — same order as Zig / Haskell twin.
module Fsot.PhaseA

import Fsot.Organism
import Fsot.ComposeIntel
import Fsot.IntelLoop
import Fsot.InternalThink
import Fsot.GeneticCore
import Fsot.ScalpelRate as Scalpel
import Fsot.AllenIsiKs as Isi
import System
import System.File

%default covering

failPhase : String -> IO ()
failPhase msg = do
  putStrLn msg
  putStrLn "FSOT_PHASE_A FAIL"
  exitFailure

export
runPhaseA : IO ()
runPhaseA = do
  putStrLn "=============================================="
  putStrLn " FSOT PHASE A (Idris twin = Zig Phase A)"
  putStrLn "=============================================="
  putStrLn "order: genetic -> scalpel -> organism -> compose -> intel-loop -> think -> isi-ks"

  putStrLn ""
  putStrLn "--- A0 GENETIC DNA/TRINARY/FSOT ---"
  okG <- runGeneticCore
  if not okG then failPhase "FSOT_GENETIC_CORE FAIL" else pure ()

  putStrLn ""
  putStrLn "--- A0b SCALPEL CLASS FI (Allen closed) ---"
  let sr = Scalpel.runScalpel
  Scalpel.printReport sr
  if not sr.srOk then failPhase "FSOT_SCALPEL FAIL" else pure ()

  putStrLn ""
  putStrLn "--- A1 ORGANISM ---"
  if not Fsot.Organism.selfTest
    then failPhase "FSOT_ORGANISM FAIL"
    else do
      let o0 = initOrganism
          o1 = foldl (\o, _ => tick o 0.5) o0 [1..48]
          o2 = teach o1 "one and one" "two"
          triple = ask o2 "one and one"
          ans = case triple of (_, a, _) => a
          ok = case triple of (_, _, k) => k
      putStrLn $ "ORGANISM ticks=" ++ show o1.oTick ++ " spikes=" ++ show o1.oSpikes
               ++ " ok=" ++ show ok ++ " ans=" ++ ans
      if not ok then failPhase "FSOT_ORGANISM FAIL" else putStrLn "FSOT_ORGANISM PASS"

  putStrLn ""
  putStrLn "--- A2 COMPOSE ---"
  let cr = Fsot.ComposeIntel.runComposeIntel
  Fsot.ComposeIntel.printReport cr
  if not cr.crOk then failPhase "FSOT_COMPOSE FAIL" else pure ()

  putStrLn ""
  putStrLn "--- A3 INTEL-LOOP ---"
  let lr = Fsot.IntelLoop.runIntelLoop
  Fsot.IntelLoop.printReport lr
  if not lr.lrOk then failPhase "FSOT_INTEL_LOOP FAIL" else pure ()

  putStrLn ""
  putStrLn "--- A4 THINK PROBE ---"
  let tr = Fsot.InternalThink.runThinkProbe
  Fsot.InternalThink.printReport tr
  if not tr.trOk then failPhase "FSOT_THINK FAIL" else pure ()

  putStrLn ""
  putStrLn "--- A5 ISI-KS PRODUCT ---"
  if not Isi.selfTest then failPhase "FSOT_ISI_KS SELFTEST FAIL" else pure ()
  let targets = "data/allen/allen_dist_targets.txt"
      s256 = "data/allen/allen_sample_256.txt"
      s128 = "data/allen/allen_sample_128.txt"
  Right _ <- readFile targets
    | Left _ => failPhase ("missing " ++ targets)
  r <- Isi.runIsiKsProduct targets s256 s128
  Isi.printReport r
  if not r.prOk then failPhase "FSOT_ISI_KS FAIL" else pure ()

  putStrLn ""
  putStrLn "=============================================="
  putStrLn " FSOT_PHASE_A PASS"
  putStrLn " FSOT_CONTINUOUS_ORGANISM_OK"
  putStrLn " FSOT_TWIN_PHASE_A_OK"
  putStrLn "=============================================="
