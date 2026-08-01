||| Genetic core gate: DNA ORF → trinary → FSOT expression → class FI order.
||| Biologically: Pyr regular-spiking slower than PV fast-spiking (Allen Cre order).
module Fsot.GeneticCore

import Fsot.Codon as Codon
import Fsot.Genotype as Gen
import Fsot.CellTypes
import Fsot.BioProbe
import Fsot.Trit

%default covering

||| Print one class: ORF-derived knobs + FI rate (Hz).
export
showClass : CellType -> IO ()
showClass ct = do
  let (ph, genes) = Gen.buildCellTypeGenotype 0 ct False
      kn = Gen.phenotypeFiKnobs ph
      pr = runFIUnit kn 1000
  putStrLn $ classLabel ct
          ++ " genes=" ++ show (length genes)
          ++ " spin=" ++ show ph.phCompositeSpin
          ++ " ref=" ++ show kn.upRefSteps
          ++ " rate_Hz=" ++ show pr.fiRateHz
          ++ " isi_ms=" ++ show pr.fiMeanIsiMs
          ++ " allen_Hz=" ++ show (allenRateHz ct)

||| Full genetic self-test: codon chemistry + class order PV >> Pyr.
export
runGeneticCore : IO Bool
runGeneticCore = do
  putStrLn "=== FSOT GENETIC CORE (DNA -> trinary -> FSOT FI) ==="
  putStrLn "doctrine: physical DNA/codon; PRIMARY A,G=+1 C,T=-1; Allen rates are readout"
  putStrLn "see docs/DNA_TRINARY_FSOT.md"
  if not Codon.selfTest
    then do
      putStrLn "FSOT_CODON FAIL (ATG Met / PRIMARY trip)"
      pure False
    else do
      putStrLn "FSOT_CODON PASS ATG=Met PRIMARY=[+1,-1,+1]"
      if not Gen.selfTest
        then do
          putStrLn "FSOT_GENOTYPE FAIL"
          pure False
        else do
          putStrLn "FSOT_GENOTYPE PASS ORF->expression->phenotype"
          traverse_ showClass [Pyr, Pv, Sst, Vip]
          let pyr = runFIUnit (paramsFromCellType Pyr 0 False) 1000
              pv = runFIUnit (paramsFromCellType Pv 0 False) 1000
          putStrLn $ "order PV_rate=" ++ show pv.fiRateHz ++ " Pyr_rate=" ++ show pyr.fiRateHz
          if pv.fiRateHz > pyr.fiRateHz * 1.5
            then do
              putStrLn "FSOT_SCALPEL_ORDER PASS"
              putStrLn "FSOT_PV_FASTER_THAN_PYR_OK"
              putStrLn "FSOT_GENETIC_CORE PASS"
              putStrLn "FSOT_DNA_TRINARY_FSOT_OK"
              pure True
            else do
              putStrLn "FSOT_SCALPEL_ORDER FAIL (Cre order PV >> Pyr required)"
              pure False
