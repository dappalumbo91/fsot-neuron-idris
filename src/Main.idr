module Main

import Fsot.GeneticCore
import Fsot.Codon as Codon
import Fsot.Mind
import System

%default covering

main : IO ()
main = do
  args <- getArgs
  case args of
    (_ :: mode :: _) => runMode mode
    _ => do
      ok <- runGeneticCore
      if ok then pure () else exitFailure
