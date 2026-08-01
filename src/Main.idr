module Main

import Fsot.Mind
import System

main : IO ()
main = do
  args <- getArgs
  case args of
    (_ :: mode :: _) => runMode mode
    _ => runMode "selftest"
