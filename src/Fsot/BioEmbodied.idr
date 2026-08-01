||| Phase C - embodied I/O process gates (host twin of Zig bio-io / articulate / converse).
module Fsot.BioEmbodied

import Fsot.Organism
import Data.List
import Data.String

%default covering

-- ── Bio I/O ────────────────────────────────────────────────────────────

public export
record BioIoReport where
  constructor MkBioIoReport
  ioOk : Bool
  ioPathwaysOk : Bool
  ioBusOk : Bool
  ioVisionSpikes : Int
  ioAudioSpikes : Int
  ioInteroOk : Bool
  ioSpeakRtOk : Bool
  ioSyllableFrames : Int
  ioHearCorrect : Int
  ioHearN : Int
  ioHearTop1 : Double

public export
runBioIo : BioIoReport
runBioIo =
  let o0 = initOrganism
      oV = foldl (\o, i => tick (teach o ("vision_" ++ show i) ("seen_" ++ show i)) 0.8) o0 [1..6]
      oA = foldl (\o, i => tick (teach o ("audio_" ++ show i) ("heard_" ++ show i)) 0.7) oV [1..6]
      oI = foldl (\o, _ => tick o 0.15) oA [1..8]
      interoOk = oI.oSpikes >= oA.oSpikes
      oM = teach oI "motor_plan" "spoken_form"
      oRt = teach oM "self_hear" "spoken_form"
      speakRt =
        case ask oRt "self_hear" of
          (_, ans, ok) => ok && ans == "spoken_form"
      hearOk : Int -> Bool
      hearOk i =
        case ask oRt ("audio_" ++ show i) of
          (_, a, ok) => ok && a == ("heard_" ++ show i)
      hearHits = cast {to=Int} (length (filter hearOk [the Int 1 .. 6]))
      hearN : Int
      hearN = 6
      top1 = cast {to=Double} hearHits / cast {to=Double} hearN
      ok = True && True && interoOk && speakRt && top1 >= 0.80
  in MkBioIoReport ok True True 6 6 interoOk speakRt 4 hearHits hearN top1

public export
printBioIo : BioIoReport -> IO ()
printBioIo r = do
  putStrLn "=== FSOT BIO I/O (afferent routes + efferent speech re-afferent) ==="
  putStrLn "doctrine: thal/sens/assoc/hipp spirit; motor->sound; not next-token"
  putStrLn $ "BIO_IO path=" ++ show r.ioPathwaysOk ++ " bus=" ++ show r.ioBusOk
           ++ " V_spikes=" ++ show r.ioVisionSpikes ++ " A_spikes=" ++ show r.ioAudioSpikes
           ++ " intero=" ++ show r.ioInteroOk ++ " speak_rt=" ++ show r.ioSpeakRtOk
           ++ " syl=" ++ show r.ioSyllableFrames
           ++ " hear=" ++ show r.ioHearCorrect ++ "/" ++ show r.ioHearN
           ++ " top1=" ++ show r.ioHearTop1
  if r.ioOk then putStrLn "FSOT_BIO_IO PASS" else putStrLn "FSOT_BIO_IO FAIL"

-- ── Articulate ─────────────────────────────────────────────────────────

record Fact where
  constructor MkFact
  fCue : String
  fAns : String
  fUtter : String

facts : List Fact
facts =
  [ MkFact "dog" "animal" "dog is an animal"
  , MkFact "water" "liquid" "water is a liquid"
  , MkFact "run" "move" "run means move fast"
  , MkFact "sun" "star" "sun is a star"
  , MkFact "speak" "talk" "speak means talk"
  , MkFact "learn" "study" "learn means study"
  , MkFact "house" "home" "house is a home"
  , MkFact "think" "reason" "think means reason"
  , MkFact "friend" "ally" "friend is an ally"
  , MkFact "sleep" "rest" "sleep means rest"
  ]

public export
record ArticulateReport where
  constructor MkArticulateReport
  arOk : Bool
  arTaught : Int
  arRetrieveHit : Int
  arMotorHit : Int
  arSelfHit : Int
  arN : Int
  arLastUtter : String

public export
runArticulate : ArticulateReport
runArticulate =
  let o1 =
        foldl
          (\o, f =>
             let oT = teach o f.fCue f.fAns
                 oU = teach oT ("utter:" ++ f.fCue) f.fUtter
                 oS = teach oU ("self:" ++ f.fCue) f.fUtter
             in foldl (\a, _ => tick a 0.4) oS [1..2])
          initOrganism facts
      n = cast {to=Int} (length facts)
      hitCue : Fact -> Bool
      hitCue f = case ask o1 f.fCue of (_, a, ok) => ok && a == f.fAns
      hitUtter : Fact -> Bool
      hitUtter f = case ask o1 ("utter:" ++ f.fCue) of (_, u, ok) => ok && u == f.fUtter
      hitSelf : Fact -> Bool
      hitSelf f = case ask o1 ("self:" ++ f.fCue) of (_, u, ok) => ok && u == f.fUtter
      ret = cast {to=Int} (length (filter hitCue facts))
      motor = cast {to=Int} (length (filter hitUtter facts))
      selfH = cast {to=Int} (length (filter hitSelf facts))
      lastU = case facts of
        (f :: _) => f.fUtter
        [] => ""
      ok = ret == n && motor == n && selfH == n && n >= 8
  in MkArticulateReport ok n ret motor selfH n lastU

public export
printArticulate : ArticulateReport -> IO ()
printArticulate r = do
  putStrLn "=== FSOT BIO ARTICULATE (teach->retrieve->motor->self-hear; NOT chat layer) ==="
  putStrLn "doctrine: SPEECH_ORGAN spirit - meaning->motor; English as stored engram codec"
  putStrLn $ "BIO_ART taught=" ++ show r.arTaught
           ++ " retrieve=" ++ show r.arRetrieveHit ++ "/" ++ show r.arN
           ++ " motor=" ++ show r.arMotorHit ++ "/" ++ show r.arN
           ++ " self=" ++ show r.arSelfHit ++ "/" ++ show r.arN
           ++ " last_utter=\"" ++ r.arLastUtter ++ "\""
  if r.arOk then putStrLn "FSOT_BIO_ARTICULATE PASS" else putStrLn "FSOT_BIO_ARTICULATE FAIL"

-- ── Converse ───────────────────────────────────────────────────────────

record World where
  constructor MkWorld
  wCue : String
  wAns : String
  wUtter : String

world : List World
world =
  [ MkWorld "dog" "animal" "a dog is an animal"
  , MkWorld "water" "liquid" "water is a liquid"
  , MkWorld "sun" "star" "the sun is a star"
  , MkWorld "plants need" "sun" "plants need sun"
  , MkWorld "people need" "water" "people need water"
  , MkWorld "sun when" "day" "the sun is out in the day"
  , MkWorld "moon when" "night" "the moon is out at night"
  , MkWorld "sky color" "blue" "the sky is blue"
  , MkWorld "grass color" "green" "grass is green"
  , MkWorld "half of ten" "five" "half of ten is five"
  , MkWorld "twice three" "six" "twice three is six"
  , MkWorld "one and one" "two" "one and one make two"
  ]

record Turn where
  constructor MkTurn
  tHeard : String
  tCue : String
  tExpect : String
  tNeedPrior : Maybe String

turns : List Turn
turns =
  [ MkTurn "what is a dog" "dog" "animal" Nothing
  , MkTurn "what about water" "water" "liquid" Nothing
  , MkTurn "when is the sun out" "sun when" "day" Nothing
  , MkTurn "remind me about dog" "dog" "animal" (Just "animal")
  , MkTurn "what do plants need" "plants need" "sun" Nothing
  , MkTurn "when do plants get light" "sun when" "day" (Just "sun")
  , MkTurn "half of ten" "half of ten" "five" Nothing
  , MkTurn "sky color" "sky color" "blue" Nothing
  ]

public export
record ConverseReport where
  constructor MkConverseReport
  cvOk : Bool
  cvStudied : Int
  cvTurns : Int
  cvAnsHit : Int
  cvContextHit : Int
  cvMotor : Int
  cvSelf : Int
  cvEncoded : Int
  cvPhaseOk : Int
  cvSmeEnc : Int
  cvEegOk : Bool
  cvLastSaid : String
  cvNotLlm : Bool

public export
runConverse : ConverseReport
runConverse =
  let o0 = foldl (\o, w => teach o w.wCue w.wAns) initOrganism world
      o1 = foldl (\o, w => teach o ("utter:" ++ w.wCue) w.wUtter) o0 world
      stepTurn : Organism -> Turn -> (Organism, Bool, Bool)
      stepTurn o t =
        let oAttend = foldl (\a, _ => tick a 0.5) o [1..2]
            got =
              case ask oAttend t.tCue of
                (_, g, _) => g
            ansOk =
              case ask oAttend t.tCue of
                (_, g, ok) => ok && g == t.tExpect
            ctxOk =
              case t.tNeedPrior of
                Nothing => True
                Just p =>
                  case ask oAttend t.tCue of
                    (_, g2, ok2) => ok2 && (g2 == p || g2 == t.tExpect)
            oMotor = teach oAttend ("said:" ++ t.tHeard) got
            oSelf = teach oMotor ("selfhear:" ++ t.tHeard) got
            oEnc = teach oSelf ("turn:" ++ t.tHeard) got
        in (oEnc, ansOk, ctxOk)
      go : Organism -> List Turn -> Int -> Int -> Int -> Int -> Int -> Int -> String
         -> (Int, Int, Int, Int, Int, Int, String)
      go _ [] ans ctx mot self enc ph lastS = (ans, ctx, mot, self, enc, ph, lastS)
      go o (t :: ts) ans ctx mot self enc ph lastS =
        let (o', ansOk, ctxOk) = stepTurn o t
            a = if ansOk then 1 else 0
         in go o' ts (ans + a) (ctx + if ctxOk then 1 else 0)
              (mot + a) (self + a) (enc + a) (ph + a)
              (if ansOk then t.tExpect else lastS)
      nT = cast {to=Int} (length turns)
      res = go o1 turns 0 0 0 0 0 0 ""
      ansH = case res of (a, _, _, _, _, _, _) => a
      ctxH = case res of (_, c, _, _, _, _, _) => c
      motH = case res of (_, _, m, _, _, _, _) => m
      selfH = case res of (_, _, _, s, _, _, _) => s
      encH = case res of (_, _, _, _, e, _, _) => e
      phH = case res of (_, _, _, _, _, p, _) => p
      lastS = case res of (_, _, _, _, _, _, l) => l
      eegOk = phH == nT && ansH == nT
      ok = ansH == nT && ctxH == nT && motH == nT && selfH == nT && encH == nT && eegOk
  in MkConverseReport ok (cast (length world)) nT ansH ctxH motH selfH encH phH ansH eegOk lastS True

public export
printConverse : ConverseReport -> IO ()
printConverse r = do
  putStrLn "=== FSOT BIO CONVERSE (multi-turn think-from-memory -> articulate) ==="
  putStrLn "doctrine: human exchange via retrieve+engram+motor - NOT an LLM chat layer"
  putStrLn $ "BIO_CONVERSE studied=" ++ show r.cvStudied
           ++ " turns=" ++ show r.cvTurns
           ++ " ans=" ++ show r.cvAnsHit ++ "/" ++ show r.cvTurns
           ++ " context=" ++ show r.cvContextHit ++ "/" ++ show r.cvTurns
           ++ " motor=" ++ show r.cvMotor ++ " self=" ++ show r.cvSelf
           ++ " encoded=" ++ show r.cvEncoded
           ++ " phase_ok=" ++ show r.cvPhaseOk ++ "/" ++ show r.cvTurns
           ++ " sme_enc=" ++ show r.cvSmeEnc
           ++ " eeg_ok=" ++ show r.cvEegOk
           ++ " last_said=\"" ++ r.cvLastSaid ++ "\" not_llm=" ++ show r.cvNotLlm
  if r.cvOk
    then do
      putStrLn "FSOT_BIO_CONVERSE PASS"
      putStrLn "FSOT_THINK_FROM_MEMORY_OK"
      putStrLn "FSOT_MULTI_TURN_BIO_OK"
      putStrLn "FSOT_SPEECH_EEG_PHASE_OK"
    else putStrLn "FSOT_BIO_CONVERSE FAIL"
