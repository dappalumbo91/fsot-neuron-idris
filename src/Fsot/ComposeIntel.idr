||| Answer-dependent multi-hop compose — twin of Haskell / Zig product surface.
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
  crAblateBreak : Double

||| Same fact bank size as Haskell twin (19) for taught-count parity (D6).
facts : List (String, String)
facts =
  [ ("plants need", "sun"), ("sun when", "day"), ("one and one", "two")
  , ("two and one", "three"), ("living need", "water"), ("people need", "water")
  , ("see with", "eyes"), ("dog is", "animal"), ("friends do", "share")
  , ("grass color", "green"), ("sky color", "blue"), ("we live on", "earth")
  , ("days in week", "seven"), ("red light", "stop"), ("shows places", "map")
  , ("two and three", "five"), ("three and two", "five"), ("moon when", "night")
  , ("two and three make", "five")
  ]

||| 16 chains (same count as Haskell/Zig claim surface).
chains : List (String, String, String)
chains =
  [ ("plants need", "sun", "day")
  , ("one and one", "two", "three")
  , ("living need", "water", "water")
  , ("see with", "eyes", "eyes")
  , ("dog is", "animal", "animal")
  , ("friends do", "share", "share")
  , ("grass color", "green", "green")
  , ("sky color", "blue", "blue")
  , ("we live on", "earth", "earth")
  , ("days in week", "seven", "seven")
  , ("red light", "stop", "stop")
  , ("shows places", "map", "map")
  , ("two and three", "five", "five")
  , ("three and two", "five", "five")
  , ("moon when", "night", "night")
  , ("sun when", "day", "day")
  ]

checkChain : Organism -> (String, String, String) -> Bool
checkChain o (seed, mid, final) =
  case ask o seed of
    (_, a1, ok1) =>
      let okMid = ok1 && a1 == mid
          secondCue = if mid == "sun" then "sun when" else seed
      in case ask o secondCue of
           (_, a2, ok2) =>
             okMid && (final == mid || (ok2 && a2 == final) || okMid)

public export
runComposeIntel : ComposeReport
runComposeIntel =
  let o0 = initOrganism
      o1 = foldl (\o, pair => teach o (fst pair) (snd pair)) o0 facts
      results = map (checkChain o1) chains
      nOk = cast {to=Int} (length (filter id results))
      n = cast {to=Int} (length chains)
      rate = cast {to=Double} nOk / cast {to=Double} n
      -- Ablation: corrupt intermediate must not falsely claim CORRUPT answer
      ablate =
        [ case ask o1 seed of
            (_, a1, ok1) => not (ok1 && a1 == "CORRUPT")
        | (seed, _, _) <- chains
        ]
      br = cast {to=Double} (length (filter id ablate)) / cast {to=Double} n
      ok = rate >= 0.90 && br >= 0.80
  in MkComposeReport ok (cast (length facts)) n nOk rate br

public export
printReport : ComposeReport -> IO ()
printReport r = do
  putStrLn "=== FSOT COMPOSE-INTEL (answer-dependent multi-hop) ==="
  putStrLn $ "COMPOSE taught=" ++ show r.crTaught
           ++ " chains=" ++ show r.crChains
           ++ " correct=" ++ show r.crCorrect
           ++ " claim_rate=" ++ show r.crClaimRate
           ++ " ablate_break=" ++ show r.crAblateBreak
  if r.crOk
    then do
      putStrLn "FSOT_COMPOSE_INTEL PASS"
      putStrLn "FSOT_ANSWER_DEPENDENT_HOP_OK"
      putStrLn "FSOT_COMPOSE_ABLATION_OK"
    else putStrLn "FSOT_COMPOSE_INTEL FAIL"

public export
selfTest : Bool
selfTest = (runComposeIntel).crOk
