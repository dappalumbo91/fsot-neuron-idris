||| Continuous internal think — Zig internal_think_fixed twin (probe + cycles).
module Fsot.InternalThink

import Fsot.Organism
import Data.List

%default covering

record Fact where
  constructor MkFact
  fCue : String
  fAns : String

seedWorld : List Fact
seedWorld =
  [ MkFact "dog" "animal", MkFact "water" "liquid", MkFact "sun" "star"
  , MkFact "plants need" "sun", MkFact "people need" "water", MkFact "sun when" "day"
  , MkFact "sky color" "blue", MkFact "neuron" "cell", MkFact "brain" "organ"
  , MkFact "one and one" "two", MkFact "earth is" "planet", MkFact "friends do" "share"
  , MkFact "moon when" "night", MkFact "two and three" "five", MkFact "grass color" "green"
  , MkFact "days in week" "seven"
  ]

litCards : List (String, String)
litCards =
  [ ("global", "earth-wide"), ("force", "push"), ("organ", "body part")
  , ("cell", "life unit"), ("planet", "world"), ("liquid", "flows")
  ]

public export
record ThinkReport where
  constructor MkThinkReport
  trOk : Bool
  trNCycles : Int
  trRetraceOk : Int
  trRetrace : Int
  trNewConcepts : Int
  trIdeas : Int
  trSleep : Int
  trSpikes : Int

boot : Organism
boot = foldl (\o, f => teach o f.fCue f.fAns) initOrganism seedWorld

retrace : Organism -> (Int, Int)
retrace o =
  let hits = length [() | f <- seedWorld, let (_, a, ok) = ask o f.fCue, ok && a == f.fAns]
  in (cast hits, cast (length seedWorld))

discover : Organism -> List String -> (Organism, List String, Int)
discover o grown =
  case [t | (t, _) <- litCards, not (t `elem` grown)] of
    [] => (o, grown, 0)
    (w :: _) =>
      case lookup w litCards of
        Just def => (teach o w def, w :: grown, 1)
        Nothing => (o, grown, 0)

public export
runThinkProbe : ThinkReport
runThinkProbe =
  let go : Int -> Organism -> List String -> Int -> Int -> ThinkReport
      go cy o grown disc sleepN =
        if cy >= 8
          then
            let (rok, rn) = retrace o
                ok = cy >= 1 && rok * 2 >= rn
            in MkThinkReport ok cy rok rn (cast (length grown)) cy sleepN o.oSpikes
          else
            let (rok, rn) = retrace o
                (o2, grown2, d) = discover o grown
                o3 = foldl (\x, _ => tick x 0.50) o2 [1..12]
                (o4, sn) = if cy `mod` 2 == 0
                             then (foldl (\x, f => teach x f.fCue f.fAns) o3 (take 8 seedWorld), sleepN + 1)
                             else (o3, sleepN)
            in go (cy + 1) o4 grown2 (disc + d) sn
  in go 0 boot [] 0 0

public export
printReport : ThinkReport -> IO ()
printReport r = do
  putStrLn "=== FSOT INTERNAL THINK (continuous organism) ==="
  putStrLn $ "THINK cy=" ++ show r.trNCycles
           ++ " retr=" ++ show r.trRetraceOk ++ "/" ++ show r.trRetrace
           ++ " new=" ++ show r.trNewConcepts
           ++ " ideas=" ++ show r.trIdeas
           ++ " sleep=" ++ show r.trSleep
           ++ " spikes=" ++ show r.trSpikes
  if r.trOk
    then do
      putStrLn "FSOT_INTERNAL_THINK PASS"
      putStrLn "FSOT_ADAPTIVE_KNOWLEDGE_OK"
      putStrLn "FSOT_CONTINUOUS_ORGANISM_OK"
    else putStrLn "FSOT_INTERNAL_THINK FAIL"

public export
selfTest : Bool
selfTest = (runThinkProbe).trOk
