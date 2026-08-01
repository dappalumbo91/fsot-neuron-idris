||| Intel loop train->sleep->prove — Zig twin.
module Fsot.IntelLoop

import Fsot.Organism
import Data.List

%default covering

record Lesson where
  constructor MkLesson
  lQ : String
  lA : String

lessons : List Lesson
lessons =
  [ MkLesson "one and one" "two"
  , MkLesson "two and one" "three"
  , MkLesson "plants need" "sun"
  , MkLesson "sun when" "day"
  , MkLesson "people need" "water"
  , MkLesson "see with" "eyes"
  , MkLesson "dog is" "animal"
  , MkLesson "friends do" "share"
  , MkLesson "we live on" "earth"
  , MkLesson "days in week" "seven"
  , MkLesson "grass color" "green"
  , MkLesson "sky color" "blue"
  , MkLesson "red light" "stop"
  , MkLesson "living need" "water"
  , MkLesson "two and three" "five"
  , MkLesson "three and two" "five"
  , MkLesson "moon when" "night"
  , MkLesson "earth is" "planet"
  ]

public export
record LoopReport where
  constructor MkLoopReport
  lrOk : Bool
  lrTaught : Int
  lrClaimPre : Double
  lrClaimPost : Double
  lrTransfer : Double

probeAcc : Organism -> Double
probeAcc o =
  let hits = length [() | l <- lessons, let (_, a, ok) = ask o l.lQ, ok && a == l.lA]
  in cast hits / cast (length lessons)

public export
runIntelLoop : LoopReport
runIntelLoop =
  let o0 = initOrganism
      o1 = foldl (\o, l => teach o l.lQ l.lA) o0 lessons
      o2 = foldl (\o, _ => tick o 0.48) o1 [1..40]
      pre = probeAcc o2
      o3 = foldl (\o, l => teach o l.lQ l.lA) o2 (take 9 lessons)
      o4 = foldl (\o, _ => tick o 0.35) o3 [1..20]
      post = probeAcc o4
      tHits = length [() | l <- take 5 lessons, let (_, a, ok) = ask o4 l.lQ, ok && a == l.lA]
      tRate = cast tHits / 5.0
      ok = pre >= 0.90 && post >= 0.90 && tRate >= 0.80
  in MkLoopReport ok (cast (length lessons)) pre post tRate

public export
printReport : LoopReport -> IO ()
printReport r = do
  putStrLn "=== FSOT INTEL LOOP ==="
  putStrLn $ "LOOP taught=" ++ show r.lrTaught
           ++ " claim_pre=" ++ show r.lrClaimPre
           ++ " claim_post=" ++ show r.lrClaimPost
           ++ " transfer=" ++ show r.lrTransfer
  if r.lrOk
    then do
      putStrLn "FSOT_INTEL_LOOP PASS"
      putStrLn "FSOT_TRAIN_SLEEP_PROVE_OK"
    else putStrLn "FSOT_INTEL_LOOP FAIL"

public export
selfTest : Bool
selfTest = (runIntelLoop).lrOk
