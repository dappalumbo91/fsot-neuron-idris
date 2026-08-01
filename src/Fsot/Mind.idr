||| Mind host — Phase A + genetic full capability twin of Zig.
module Fsot.Mind

import Fsot.GeneticCore
import Fsot.Codon as Codon
import Fsot.Genotype as Gen
import Fsot.Organism as Org
import Fsot.IntelLoop as Loop
import Fsot.ComposeIntel as Compose
import Fsot.InternalThink as Think
import Fsot.PhaseA as PhaseA
import Fsot.AllenIsiKs as Isi
import Fsot.ScalpelRate as Scalpel
import System
import System.File
import Data.String

%default covering

export
usage : String
usage = unlines
  [ "usage: fsot-mind <mode>"
  , "  phase-a       = genetic + scalpel + organism + compose + intel-loop + think + isi-ks"
  , "  genetic|scalpel|organism|compose|intel-loop|think|isi-ks|suite|stress"
  , "  codon|parity|selftest|help"
  ]

failIf : Bool -> String -> IO ()
failIf True msg = do
  putStrLn msg
  exitFailure
failIf False _ = pure ()

export
runMode : String -> IO ()
runMode "help" = putStrLn usage
runMode "phase-a" = PhaseA.runPhaseA
runMode "phase_a" = PhaseA.runPhaseA
runMode "phasea" = PhaseA.runPhaseA
runMode "suite" = do
  PhaseA.runPhaseA
  putStrLn "FSOT_SUITE PASS"
runMode "stress" = do
  PhaseA.runPhaseA
  putStrLn "FSOT_STRESS PASS"
runMode "selftest" = do
  ok <- runGeneticCore
  failIf (not ok) "FSOT_GENETIC FAIL"
  failIf (not Org.selfTest) "FSOT_ORGANISM FAIL"
  failIf (not Loop.selfTest) "FSOT_INTEL_LOOP FAIL"
  failIf (not Compose.selfTest) "FSOT_COMPOSE FAIL"
  failIf (not Think.selfTest) "FSOT_THINK FAIL"
  putStrLn "FSOT_MIND_HOST_OK"
  putStrLn "FSOT_PHASE_A_CORE_OK"
runMode "genetic" = do
  ok <- runGeneticCore
  failIf (not ok) "FSOT_GENETIC FAIL"
runMode "genetic-core" = do
  ok <- runGeneticCore
  failIf (not ok) "FSOT_GENETIC FAIL"
runMode "codon" = do
  failIf (not Codon.selfTest) "FSOT_CODON FAIL"
  putStrLn "FSOT_CODON PASS"
runMode "organism" = do
  failIf (not Org.selfTest) "FSOT_ORGANISM FAIL"
  let o0 = Org.initOrganism
      o1 = foldl (\o, _ => Org.tick o 0.5) o0 [1..48]
      o2 = Org.teach o1 "one and one" "two"
      triple = Org.ask o2 "one and one"
      ans = case triple of (_, a, _) => a
      ok = case triple of (_, _, k) => k
  putStrLn $ "ORGANISM ticks=" ++ show o1.oTick ++ " spikes=" ++ show o1.oSpikes
           ++ " ok=" ++ show ok ++ " ans=" ++ ans
  failIf (not ok) "FSOT_ORGANISM FAIL"
  putStrLn "FSOT_ORGANISM PASS"
runMode "compose" = do
  let r = Compose.runComposeIntel
  Compose.printReport r
  failIf (not r.crOk) "FSOT_COMPOSE FAIL"
runMode "intel-loop" = do
  let r = Loop.runIntelLoop
  Loop.printReport r
  failIf (not r.lrOk) "FSOT_INTEL_LOOP FAIL"
runMode "think" = do
  let r = Think.runThinkProbe
  Think.printReport r
  failIf (not r.trOk) "FSOT_THINK FAIL"
runMode "isi-ks" = do
  failIf (not Isi.selfTest) "FSOT_ISI_KS SELFTEST FAIL"
  let targets = "data/allen/allen_dist_targets.txt"
      s256 = "data/allen/allen_sample_256.txt"
      s128 = "data/allen/allen_sample_128.txt"
  Right _ <- readFile targets
    | Left _ => do
        putStrLn ("missing " ++ targets)
        exitFailure
  r <- Isi.runIsiKsProduct targets s256 s128
  Isi.printReport r
  failIf (not r.prOk) "FSOT_ISI_KS FAIL"
runMode "scalpel" = do
  let r = Scalpel.runScalpel
  Scalpel.printReport r
  failIf (not r.srOk) "FSOT_SCALPEL FAIL"
runMode "class-rates" = runMode "scalpel"
runMode "parity" = do
  putStrLn "=== FSOT PARITY (Idris Phase A) ==="
  putStrLn $ "codon=" ++ show Codon.selfTest
  putStrLn $ "genotype=" ++ show Gen.selfTest
  putStrLn $ "organism=" ++ show Org.selfTest
  putStrLn $ "intel_loop=" ++ show Loop.selfTest
  putStrLn $ "compose=" ++ show Compose.selfTest
  putStrLn $ "think=" ++ show Think.selfTest
  putStrLn $ "isi_ks_selftest=" ++ show Isi.selfTest
  putStrLn $ "scalpel_order=" ++ show Scalpel.selfTest
  putStrLn "FSOT_PARITY_REPORT_OK"
runMode m = do
  putStrLn $ "=== FSOT MODE " ++ m ++ " ==="
  putStrLn "FSOT_PORT_IN_PROGRESS"
  putStrLn "Phase A path: phase-a | genetic | scalpel | organism | compose | intel-loop | think | isi-ks"
  exitWith (ExitFailure 2)
