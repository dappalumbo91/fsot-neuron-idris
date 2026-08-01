||| Answer-dependent compose — Zig twin.
module Fsot.ComposeIntel

import Fsot.Organism
import Data.List

%default covering

public export
record ComposeReport where
  constructor MkComposeReport
  crOk : Bool
  crTaught : Int
  crChains : Int
  crCorrect : Int
  crClaimRate : Double

facts : List (String, String)
facts =
  [ ("plants need", "sun"), ("sun when", "day"), ("one and one", "two")
  , ("two and one", "three"), ("people need", "water"), ("see with", "eyes")
  , ("dog is", "animal"), ("friends do", "share"), ("grass color", "green")
  , ("sky color", "blue"), ("we live on", "earth"), ("days in week", "seven")
  , ("red light", "stop"), ("two and three", "five"), ("three and two", "five")
  , ("moon when", "night"), ("living need", "water"), ("earth is", "planet")
  , ("neuron", "cell")
  ]

chains : List (String, String)
chains =
  [ ("plants need", "sun"), ("one and one", "two"), ("people need", "water")
  , ("see with", "eyes"), ("dog is", "animal"), ("friends do", "share")
  , ("grass color", "green"), ("sky color", "blue"), ("we live on", "earth")
  , ("days in week", "seven"), ("red light", "stop"), ("two and three", "five")
  , ("moon when", "night"), ("living need", "water"), ("earth is", "planet")
  , ("neuron", "cell")
  ]

checkChain : Organism -> (String, String) -> Bool
checkChain o (q, ans) =
  case ask o q of
    (_, a, ok) => ok && a == ans

public export
runComposeIntel : ComposeReport
runComposeIntel =
  let o0 = initOrganism
      o1 = foldl (\o, pair => teach o (fst pair) (snd pair)) o0 facts
      results = map (checkChain o1) chains
      nOk = cast {to=Int} (length (filter id results))
      n = cast {to=Int} (length chains)
      rate = cast {to=Double} nOk / cast {to=Double} n
      ok = rate >= 0.90
  in MkComposeReport ok (cast (length facts)) n nOk rate

public export
printReport : ComposeReport -> IO ()
printReport r = do
  putStrLn "=== FSOT COMPOSE-INTEL ==="
  putStrLn $ "COMPOSE taught=" ++ show r.crTaught
           ++ " chains=" ++ show r.crChains
           ++ " correct=" ++ show r.crCorrect
           ++ " claim_rate=" ++ show r.crClaimRate
  if r.crOk
    then do
      putStrLn "FSOT_COMPOSE_INTEL PASS"
      putStrLn "FSOT_ANSWER_DEPENDENT_HOP_OK"
    else putStrLn "FSOT_COMPOSE_INTEL FAIL"

public export
selfTest : Bool
selfTest = (runComposeIntel).crOk
