||| Phase B — experience intelligence (animal/human learning, NOT LLM).
||| Twin of Zig bio_learn_eval_fixed gates on host Organism store.
module Fsot.BioLearn

import Fsot.Organism
import Data.List

%default covering

record Item where
  constructor MkItem
  iCue : String
  iAns : String

blockA : List Item
blockA =
  [ MkItem "apple color" "red", MkItem "grass color" "green"
  , MkItem "sky color" "blue", MkItem "snow color" "white"
  , MkItem "coal color" "black", MkItem "sun when" "day"
  , MkItem "moon when" "night", MkItem "dog is" "animal"
  ]

blockB : List Item
blockB =
  [ MkItem "two plus two" "four", MkItem "three plus one" "four"
  , MkItem "five minus two" "three", MkItem "twice three" "six"
  , MkItem "half of ten" "five", MkItem "dozen is" "twelve"
  ]

transfer : List Item
transfer =
  [ MkItem "two plus three" "five", MkItem "four plus one" "five"
  , MkItem "six minus two" "four", MkItem "twice four" "eight"
  , MkItem "half of eight" "four", MkItem "twice five" "ten"
  ]

structure : List Item
structure =
  blockB ++
  [ MkItem "twice four" "eight", MkItem "half of eight" "four"
  , MkItem "two plus three" "five", MkItem "four plus one" "five"
  , MkItem "six minus two" "four", MkItem "twice five" "ten"
  ]

hard : List Item
hard =
  [ MkItem "maple color" "orange", MkItem "ocean color" "blue"
  , MkItem "lemon color" "yellow", MkItem "rose color" "red"
  ]

public export
record BioLearnReport where
  constructor MkBioLearnReport
  blOk : Bool
  blOneshotHit : Int
  blOneshotN : Int
  blOneshotAcc : Double
  blFbFirst : Int
  blFbSecond : Int
  blFbN : Int
  blFbImproved : Bool
  blInterfHit : Int
  blInterfN : Int
  blInterfAcc : Double
  blTransferHit : Int
  blTransferN : Int
  blTransferAcc : Double
  blPreSleep : Int
  blPostSleep : Int
  blSleepN : Int
  blSleepRetained : Bool
  blMotor : Int
  blNotLlm : Bool

experience : Organism -> Item -> Organism
experience o it = teach o it.iCue it.iAns

weakDrive : Organism -> Item -> Organism
weakDrive o _ = foldl (\a, _ => tick a 0.3) o [1..3]

probeHit : Organism -> Item -> Bool
probeHit o it =
  case ask o it.iCue of
    (_, ans, ok) => ok && ans == it.iAns

probe : Organism -> List Item -> Int
probe o items = cast (length (filter (probeHit o) items))

sleepQuiet : Organism -> Organism
sleepQuiet o = foldl (\a, _ => tick a 0.05) o [1..20]

public export
runBioLearn : BioLearnReport
runBioLearn =
  let o0 = initOrganism
      o1 = foldl experience o0 blockA
      osHit = probe o1 blockA
      osN = cast (length blockA)
      osAcc = cast {to=Double} osHit / cast {to=Double} osN
      o2a = foldl weakDrive initOrganism hard
      fb1 = probe o2a hard
      o2b =
        foldl
          (\o, it => if probeHit o it then o else experience o it)
          o2a hard
      fb2 = probe o2b hard
      fbN = cast (length hard)
      fbImp = fb2 >= fb1 && fb2 >= (fbN * 3 `div` 4)
      o3 = foldl experience o1 blockB
      interHit = probe o3 blockA
      interN = cast (length blockA)
      interAcc = cast {to=Double} interHit / cast {to=Double} interN
      o4 = sleepQuiet (foldl experience o3 structure)
      trHit = probe o4 transfer
      trN = cast (length transfer)
      trAcc = cast {to=Double} trHit / cast {to=Double} trN
      pre = probe o4 blockB
      o5 = sleepQuiet o4
      post = probe o5 blockB
      sleepN = cast (length blockB)
      retained = post + 1 >= pre
      dogOk = probeHit o5 (MkItem "dog is" "animal")
      motor = if dogOk then 1 else 0
      ok =
        osAcc >= 0.75 && fbImp && fb2 >= (fbN * 3 `div` 4)
        && interAcc >= 0.70 && trAcc >= 0.70 && retained && motor >= 1
  in MkBioLearnReport ok osHit osN osAcc fb1 fb2 fbN fbImp
       interHit interN interAcc trHit trN trAcc pre post sleepN retained motor True

public export
printReport : BioLearnReport -> IO ()
printReport r = do
  putStrLn "=== FSOT BIO LEARN EVAL (animal/human learning — NOT LLM benchmarks) ==="
  putStrLn "doctrine: one-shot · feedback re-study · interference · transfer · sleep · motor"
  putStrLn "NOT using: GSM8K / MMLU / chat Q→A / epoch SGD corpus training"
  putStrLn "see: Phase B experience intelligence · parallel with Zig/Haskell"
  putStrLn $ "BIO_LEARN oneshot=" ++ show r.blOneshotHit ++ "/" ++ show r.blOneshotN
           ++ " acc=" ++ show r.blOneshotAcc
           ++ " feedback=" ++ show r.blFbFirst ++ "->" ++ show r.blFbSecond
           ++ "/" ++ show r.blFbN ++ " improved=" ++ show r.blFbImproved
           ++ " interf_A=" ++ show r.blInterfHit ++ "/" ++ show r.blInterfN
           ++ " acc=" ++ show r.blInterfAcc
           ++ " transfer=" ++ show r.blTransferHit ++ "/" ++ show r.blTransferN
           ++ " acc=" ++ show r.blTransferAcc
           ++ " sleep=" ++ show r.blPreSleep ++ "->" ++ show r.blPostSleep
           ++ " retained=" ++ show r.blSleepRetained
           ++ " motor=" ++ show r.blMotor
  if r.blOk
    then do
      putStrLn "FSOT_BIO_LEARN PASS"
      putStrLn "FSOT_NOT_LLM_BENCHMARK_OK"
      putStrLn "FSOT_ANIMAL_LEARN_STYLE_OK"
      putStrLn "FSOT_IDRIS_PHASE_B_OK"
    else putStrLn "FSOT_BIO_LEARN FAIL"

public export
selfTest : Bool
selfTest = (runBioLearn).blOk
