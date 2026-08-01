||| Phase C stack - embodied I/O + stress residual (parallel twin).
module Fsot.PhaseC

import Fsot.BioEmbodied as Emb
import Fsot.ComposeIntel as Compose
import System

%default covering

failPhase : String -> IO ()
failPhase msg = do
  putStrLn msg
  putStrLn "FSOT_PHASE_C FAIL"
  exitFailure

export
runPhaseC : IO ()
runPhaseC = do
  putStrLn "=============================================="
  putStrLn " FSOT PHASE C (Idris twin - embodied I/O)"
  putStrLn "=============================================="
  putStrLn "order: bio-io -> bio-articulate -> bio-converse -> stress residual"
  putStrLn "parallel stage with Zig + Haskell"

  putStrLn ""
  putStrLn "--- C1 BIO-IO ---"
  let io = Emb.runBioIo
  Emb.printBioIo io
  if not io.ioOk then failPhase "FSOT_BIO_IO FAIL" else pure ()

  putStrLn ""
  putStrLn "--- C2 BIO-ARTICULATE ---"
  let ar = Emb.runArticulate
  Emb.printArticulate ar
  if not ar.arOk then failPhase "FSOT_BIO_ARTICULATE FAIL" else pure ()

  putStrLn ""
  putStrLn "--- C3 BIO-CONVERSE ---"
  let cv = Emb.runConverse
  Emb.printConverse cv
  if not cv.cvOk then failPhase "FSOT_BIO_CONVERSE FAIL" else pure ()

  putStrLn ""
  putStrLn "--- C4 STRESS RESIDUAL ---"
  let cr = Compose.runComposeIntel
  Compose.printReport cr
  if not cr.crOk then failPhase "FSOT_COMPOSE FAIL" else pure ()
  putStrLn "FSOT_STRESS_RESIDUAL PASS"

  putStrLn ""
  putStrLn "=============================================="
  putStrLn " FSOT_PHASE_C PASS"
  putStrLn " FSOT_EMBODIED_IO_OK"
  putStrLn " FSOT_TWIN_PHASE_C_OK"
  putStrLn "=============================================="
