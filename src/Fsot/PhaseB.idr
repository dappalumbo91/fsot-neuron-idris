||| Phase B stack — experience intelligence + stress residual (parallel twin).
module Fsot.PhaseB

import Fsot.BioLearn as Bio
import Fsot.Organism as Org
import Fsot.ComposeIntel as Compose
import System

%default covering

failPhase : String -> IO ()
failPhase msg = do
  putStrLn msg
  putStrLn "FSOT_PHASE_B FAIL"
  exitFailure

export
runPhaseB : IO ()
runPhaseB = do
  putStrLn "=============================================="
  putStrLn " FSOT PHASE B (Idris twin — experience intelligence)"
  putStrLn "=============================================="
  putStrLn "order: bio-learn -> stress residual (organism+compose)"
  putStrLn "parallel stage with Zig + Haskell"

  putStrLn ""
  putStrLn "--- B1 BIO-LEARN (experience intelligence) ---"
  let br = Bio.runBioLearn
  Bio.printReport br
  if not br.blOk then failPhase "FSOT_BIO_LEARN FAIL" else pure ()

  putStrLn ""
  putStrLn "--- B2 STRESS RESIDUAL (Phase A product floor) ---"
  if not Org.selfTest then failPhase "FSOT_ORGANISM FAIL" else pure ()
  let o0 = Org.initOrganism
      o1 = foldl (\o, _ => Org.tick o 0.5) o0 [1..24]
      o2 = Org.teach o1 "one and one" "two"
      ok = case Org.ask o2 "one and one" of (_, _, k) => k
  if not ok then failPhase "FSOT_ORGANISM FAIL" else putStrLn "FSOT_ORGANISM PASS"
  let cr = Compose.runComposeIntel
  Compose.printReport cr
  if not cr.crOk then failPhase "FSOT_COMPOSE FAIL" else pure ()
  putStrLn "FSOT_STRESS_RESIDUAL PASS"

  putStrLn ""
  putStrLn "=============================================="
  putStrLn " FSOT_PHASE_B PASS"
  putStrLn " FSOT_EXPERIENCE_INTELLIGENCE_OK"
  putStrLn " FSOT_TWIN_PHASE_B_OK"
  putStrLn "=============================================="
