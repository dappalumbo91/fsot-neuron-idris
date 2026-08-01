||| Mind host — genetic-first. DNA physical function via trinary + FSOT.
module Fsot.Mind

import Fsot.GeneticCore
import Fsot.Codon as Codon
import Fsot.Genotype as Gen
import System
import Data.String

%default covering

export
usage : String
usage = unlines
  [ "usage: fsot-mind <mode>"
  , "  genetic | genetic-core | selftest = DNA->trinary->FSOT FI core"
  , "  codon      = ATG Met + PRIMARY trip"
  , "  parity     = capability note"
  , "  help"
  , ""
  , "Doctrine: physical DNA through trinary + FSOT (docs/DNA_TRINARY_FSOT.md)"
  ]

export
runMode : String -> IO ()
runMode mode = case mode of
  "help" => putStrLn usage
  "selftest" => do
    ok <- runGeneticCore
    if ok then pure () else exitFailure
  "genetic" => do
    ok <- runGeneticCore
    if ok then pure () else exitFailure
  "genetic-core" => do
    ok <- runGeneticCore
    if ok then pure () else exitFailure
  "codon" =>
    if Codon.selfTest
      then putStrLn "FSOT_CODON PASS"
      else do
        putStrLn "FSOT_CODON FAIL"
        exitFailure
  "parity" => do
    putStrLn "=== FSOT PARITY (Idris genetic spine) ==="
    putStrLn "doctrine: DNA physical function via PRIMARY trinary + FSOT seeds"
    putStrLn $ "codon=" ++ show Codon.selfTest
    putStrLn $ "genotype=" ++ show Gen.selfTest
    putStrLn "see docs/DNA_TRINARY_FSOT.md"
    putStrLn "FSOT_PARITY_REPORT_OK"
  "isi-ks" => do
    putStrLn "FSOT_PORT_IN_PROGRESS"
    putStrLn "isi-ks pending full AllenIsiKs type polish; genetic core is authority path"
    exitWith (ExitFailure 2)
  m => do
    putStrLn $ "=== FSOT MODE " ++ m ++ " ==="
    putStrLn "FSOT_PORT_IN_PROGRESS"
    putStrLn "see docs/FULL_CAPABILITY_PARITY.md"
    exitWith (ExitFailure 2)
