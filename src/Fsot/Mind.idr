||| Mind host modes (Idris2 twin of Zig main_mind subset / Haskell Fsot.Mind).
module Fsot.Mind

import Fsot.AllenIsiKs as Isi
import Fsot.BioProbe
import Fsot.CellTypes
import Fsot.Codon as Codon
import Fsot.Genotype as Gen
import System
import System.Directory
import System.File

%default covering

public export
usage : String
usage = unlines
  [ "usage: fsot-mind <mode>"
  , "  selftest   = codon + genotype + isi-ks self tests"
  , "  codon      = 64-codon primary map gate"
  , "  genetic    = class ORF -> phenotype -> FI knobs smoke"
  , "  isi-ks     = full ISI distribution KS product (Allen CSV)"
  , "  scalpel    = class rate smoke (Pyr/PV/SST/VIP order)"
  , "  help       = this text"
  , ""
  , "Twin of Zig fsot_mind / Haskell fsot-mind. Run from project root so data/ resolves."
  ]

failGate : String -> IO ()
failGate msg = do
  putStrLn msg
  exitFailure

runSelfTest : IO ()
runSelfTest = do
  putStrLn "=== FSOT MIND HOST (Idris2) ==="
  putStrLn "doctrine: fixed lattice + 64-codon genetics; Allen readout; twin of Zig/Haskell"
  if not Codon.selfTest then failGate "FSOT_CODON FAIL"
  else do
    putStrLn "FSOT_CODON PASS 64_primary AG=+1 CT=-1 ATG=[+1,-1,+1]"
    if not Gen.selfTest then failGate "FSOT_GENOTYPE FAIL"
    else do
      putStrLn "FSOT_GENOTYPE PASS codon_spine"
      if not Isi.selfTest then failGate "FSOT_ISI_KS SELFTEST FAIL"
      else do
        putStrLn "FSOT_ISI_KS_SELFTEST PASS"
        putStrLn "FSOT_MIND_HOST_OK"
        putStrLn "FSOT_IDRIS_AUTHORITY_OK"

runCodon : IO ()
runCodon = do
  if not Codon.selfTest then failGate "FSOT_CODON FAIL"
  else putStrLn "FSOT_CODON PASS"

showClass : CellType -> IO ()
showClass ct = do
  let (ph, _) = Gen.buildCellTypeGenotype 0 ct False
      kn = Gen.phenotypeFiKnobs ph
      pr = runFIUnit kn 1000
  putStrLn $ classLabel ct
          ++ " ref=" ++ show kn.upRefSteps
          ++ " rate=" ++ show pr.fiRateHz
          ++ " isi=" ++ show pr.fiMeanIsiMs
          ++ " spikes=" ++ show pr.fiSpikes
          ++ " allen_rate=" ++ show (allenRateHz ct)

runGenetic : IO ()
runGenetic = do
  putStrLn "=== FSOT GENETIC (class ORF -> FI) ==="
  if not Gen.selfTest then failGate "FSOT_GENOTYPE FAIL"
  else do
    traverse_ showClass [Pyr, Pv, Sst, Vip]
    putStrLn "FSOT_GENETIC PASS"

runScalpel : IO ()
runScalpel = do
  putStrLn "=== FSOT SCALPEL RATES (smoke - Idris) ==="
  putStrLn "doctrine: PV >> Pyr class order from genetic FI (full abs-Hz iron is Zig primary)"
  let pyr = runFIUnit (paramsFromCellType Pyr 0 False) 1000
      pv = runFIUnit (paramsFromCellType Pv 0 False) 1000
      sst = runFIUnit (paramsFromCellType Sst 0 False) 1000
      vip = runFIUnit (paramsFromCellType Vip 0 False) 1000
  putStrLn $ "Pyr rate=" ++ show pyr.fiRateHz ++ " Hz"
  putStrLn $ "PV  rate=" ++ show pv.fiRateHz ++ " Hz"
  putStrLn $ "SST rate=" ++ show sst.fiRateHz ++ " Hz"
  putStrLn $ "VIP rate=" ++ show vip.fiRateHz ++ " Hz"
  if pv.fiRateHz > pyr.fiRateHz * 1.5
    then do
      putStrLn "FSOT_SCALPEL_ORDER PASS"
      putStrLn "FSOT_PV_FASTER_THAN_PYR_OK"
    else do
      putStrLn "FSOT_SCALPEL_ORDER FAIL"
      exitFailure

runIsiKs : IO ()
runIsiKs = do
  putStrLn "=== FSOT ALLEN ISI DISTRIBUTION KS (PRODUCT - IDRIS) ==="
  if not Isi.selfTest then failGate "FSOT_ALLEN_ISI_KS_PRODUCT SELFTEST FAIL"
  else do
    let targets = "data/allen/allen_dist_targets.txt"
        s256 = "data/allen/allen_sample_256.txt"
        s128 = "data/allen/allen_sample_128.txt"
    Right _ <- readFile targets
      | Left _ => do
          putStrLn $ "missing " ++ targets
          putStrLn "Run from project root (Desktop/FSOT NEURON idris)."
          exitFailure
    r <- Isi.runIsiKsProduct targets s256 s128
    Isi.printReport r
    if not r.prOk then exitFailure else pure ()

public export
runMode : String -> IO ()
runMode mode = case mode of
  "help" => putStrLn usage
  "--help" => putStrLn usage
  "-h" => putStrLn usage
  "selftest" => runSelfTest
  "codon" => runCodon
  "genetic" => runGenetic
  "genetic-var" => runGenetic
  "isi-ks" => runIsiKs
  "isi_ks" => runIsiKs
  "allen-isi-ks" => runIsiKs
  "scalpel" => runScalpel
  "class-rates" => runScalpel
  _ => do
    putStrLn $ "unknown mode: " ++ mode
    putStrLn usage
    exitFailure
