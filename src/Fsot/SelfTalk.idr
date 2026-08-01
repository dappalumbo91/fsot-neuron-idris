||| Self-talk re-entry (host twin of Zig self_talk_fixed).
module Fsot.SelfTalk

import Fsot.Organism
import Data.List

%default covering

record Fact where
  constructor MkFact
  fCue : String
  fAns : String

seeds : List Fact
seeds =
  [ MkFact "dog" "animal", MkFact "water" "liquid"
  , MkFact "sun" "star", MkFact "I can learn" "true"
  ]

selfCues : List (String, String, String)
selfCues =
  [ ("what do I know about dog", "dog", "animal")
  , ("remind myself water", "water", "liquid")
  , ("I know the sun is", "sun", "star")
  , ("can I learn", "I can learn", "true")
  ]

public export
record SelfTalkReport where
  constructor MkSelfTalk
  stOk : Bool
  stSeeded : Int
  stCues : Int
  stRetrieve : Int
  stReencode : Int
  stLast : String

public export
runSelfTalk : SelfTalkReport
runSelfTalk =
  let o0 = foldl (\o, f => teach o f.fCue f.fAns) initOrganism seeds
      stepOne : Organism -> (String, String, String) -> Int -> Int -> String
               -> (Organism, Int, Int, String)
      stepOne o (heard, cue, expect) ret re lastS =
        let o1 = foldl (\a, _ => tick a 0.45) o [1..3]
            hit =
              case ask o1 cue of
                (_, ans, ok) => ok && ans == expect
            o2 = if hit then teach o1 ("selftalk:" ++ heard) expect else o1
            ret' = ret + if hit then 1 else 0
            re' = re + if hit then 1 else 0
            last' = if hit then heard else lastS
        in (o2, ret', re', last')
      go : Organism -> List (String, String, String) -> Int -> Int -> String
         -> (Organism, Int, Int, String)
      go o [] ret re lastS = (o, ret, re, lastS)
      go o (sc :: rest) ret re lastS =
        case stepOne o sc ret re lastS of
          (o', ret', re', last') => go o' rest ret' re' last'
      final = go o0 selfCues 0 0 ""
      oF = case final of (o, _, _, _) => o
      ret = case final of (_, r, _, _) => r
      re = case final of (_, _, e, _) => e
      lastS = case final of (_, _, _, l) => l
      prove =
        cast {to=Int} (length
          [ () | f <- seeds
          , case ask oF f.fCue of (_, a, ok) => ok && a == f.fAns ])
      ok = ret >= 3 && re >= 3 && prove >= 3
  in MkSelfTalk ok (cast (length seeds)) (cast (length selfCues)) ret re lastS

public export
printReport : SelfTalkReport -> IO ()
printReport r = do
  putStrLn "=== FSOT SELF-TALK (internal dialogue re-entry - NOT LLM chat) ==="
  putStrLn $ "SELF_TALK seeded=" ++ show r.stSeeded ++ " cues=" ++ show r.stCues
           ++ " retrieve=" ++ show r.stRetrieve ++ " reencode=" ++ show r.stReencode
           ++ " last=\"" ++ r.stLast ++ "\""
  if r.stOk
    then do
      putStrLn "FSOT_SELF_TALK_REENCODE_OK"
      putStrLn "FSOT_SELF_TALK PASS"
    else putStrLn "FSOT_SELF_TALK FAIL"
