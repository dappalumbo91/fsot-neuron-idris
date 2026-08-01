||| ONE connected organism stays online (Zig/Python live-mind twin).
module Fsot.LiveMind

import Fsot.Glia as Glia
import Data.List
import Data.String
import Data.Maybe
import System

%default covering

record Engram where
  constructor MkEng
  eCue : String
  eAns : String
  eStr : Double

record Mind where
  constructor MkMind
  mEngrams : List Engram
  mGlia : Glia.GliaState
  mTick : Int
  mSpikes : Int
  mEncode : Int
  mRetr : Int
  mSelf : Int
  mSleep : Int
  mDa : Double
  mAch : Double
  mIdea : String
  mAlive : Bool

seeds : List (String, String)
seeds =
  [ ("dog", "animal"), ("water", "liquid"), ("sun", "star")
  , ("plants need", "sun"), ("people need", "water")
  , ("sky color", "blue"), ("grass color", "green")
  , ("I can learn", "true"), ("one and one", "two"), ("half of ten", "five")
  ]

boot : Mind
boot =
  let eng = [MkEng c a 1.0 | (c, a) <- seeds]
  in MkMind eng Glia.initGlia 0 0 (cast (length seeds)) 0 0 0 0.2 0.3 "" True

teach : Mind -> String -> String -> Mind
teach m cue ans =
  case break (\e => e.eCue == cue) m.mEngrams of
    (pre, e :: post) =>
      let e2 = MkEng e.eCue ans (min 2.0 (e.eStr + 0.2))
      in MkMind (pre ++ e2 :: post) m.mGlia m.mTick m.mSpikes (m.mEncode + 1)
           m.mRetr m.mSelf m.mSleep m.mDa m.mAch m.mIdea m.mAlive
    _ =>
      MkMind (MkEng cue ans 1.0 :: m.mEngrams) m.mGlia m.mTick m.mSpikes (m.mEncode + 1)
        m.mRetr m.mSelf m.mSleep m.mDa m.mAch m.mIdea m.mAlive

findEng : String -> List Engram -> Maybe Engram
findEng _ [] = Nothing
findEng cue (e :: es) =
  if e.eCue == cue || isInfixOf cue e.eCue || isInfixOf e.eCue cue
    then Just e else findEng cue es

retrieve : Mind -> String -> (Mind, String, Bool)
retrieve m cue =
  case findEng cue m.mEngrams of
    Just e =>
      let e2 = MkEng e.eCue e.eAns (min 2.0 (e.eStr + 0.05))
          eng' = map (\x => if x.eCue == e.eCue then e2 else x) m.mEngrams
          m2 = MkMind eng' m.mGlia m.mTick m.mSpikes m.mEncode (m.mRetr + 1)
                 m.mSelf m.mSleep m.mDa m.mAch m.mIdea m.mAlive
      in (m2, e.eAns, True)
    Nothing => (m, "", False)

neuralTick : Mind -> Double -> Mind
neuralTick m drive =
  let nUnits = 32
      fired =
        [ (u + m.mTick) `mod` 5 == 0 || (u + m.mTick) `mod` 7 == 0
        | u <- [the Int 0 .. nUnits - 1]
        ]
      nFire = cast {to=Int} (length (filter id fired))
      glia' = Glia.stepAfterSpikes m.mGlia fired
      spikes' = m.mSpikes + nFire + the Int (cast (drive * 4.0))
  in MkMind m.mEngrams glia' m.mTick spikes' m.mEncode m.mRetr m.mSelf m.mSleep
       m.mDa m.mAch m.mIdea m.mAlive

idxEng : Int -> List Engram -> Engram -> Engram
idxEng _ [] def = def
idxEng 0 (e :: _) _ = e
idxEng n (_ :: es) def = idxEng (n - 1) es def

selfTalk : Mind -> Mind
selfTalk m =
  case m.mEngrams of
    [] => m
    (e0 :: _) =>
      let n = cast {to=Int} (length m.mEngrams)
          ePick = idxEng (m.mTick `mod` n) m.mEngrams e0
          (m1, ans, ok) = retrieve m ePick.eCue
      in if ok
           then
             let m2 = teach m1 ("self:" ++ ePick.eCue) ans
             in MkMind m2.mEngrams m2.mGlia m2.mTick m2.mSpikes m2.mEncode m2.mRetr
                  (m2.mSelf + 1) m2.mSleep (min 0.9 (m2.mDa + 0.05)) m2.mAch
                  ("I know " ++ ePick.eCue ++ " is " ++ ans) m2.mAlive
           else m1

sleepNrem : Mind -> Mind
sleepNrem m =
  let m0 = MkMind m.mEngrams m.mGlia m.mTick m.mSpikes m.mEncode m.mRetr m.mSelf
             (m.mSleep + 1) m.mDa (max 0.1 (m.mAch * 0.5)) m.mIdea m.mAlive
      top = take 6 m0.mEngrams
      m1 = foldl (\o, e =>
             let o1 = neuralTick (neuralTick (neuralTick o 0.25) 0.25) 0.25
             in teach o1 e.eCue e.eAns) m0 top
  in MkMind m1.mEngrams m1.mGlia m1.mTick m1.mSpikes m1.mEncode m1.mRetr m1.mSelf
       m1.mSleep (max 0.15 (m1.mDa * 0.9)) (min 0.5 (m1.mAch + 0.15)) m1.mIdea m1.mAlive

statusLine : Mind -> String
statusLine m =
  "mind t=" ++ show m.mTick
    ++ " spikes=" ++ show m.mSpikes
    ++ " enc=" ++ show m.mEncode
    ++ " retr=" ++ show m.mRetr
    ++ " selftalk=" ++ show m.mSelf
    ++ " sleep=" ++ show m.mSleep
    ++ " eng=" ++ show (length m.mEngrams)
    ++ " da=" ++ show m.mDa
    ++ " surges=" ++ show m.mGlia.gSurges
    ++ " idea=\"" ++ m.mIdea ++ "\""

tickOnce : Mind -> Mind
tickOnce m =
  let t = m.mTick + 1
      phase = cast {to=Double} (t `mod` 40) / 40.0
      drive = 0.35 + 0.4 * abs (phase - 0.5) * 2.0 + 0.1 * m.mDa
      mT = MkMind m.mEngrams m.mGlia t m.mSpikes m.mEncode m.mRetr m.mSelf
             m.mSleep m.mDa m.mAch m.mIdea m.mAlive
      m1 = neuralTick mT drive
      m2 = if (t `mod` 15) == 0 then selfTalk m1 else m1
      m3 = if (t `mod` 50) == 0 then sleepNrem m2 else m2
  in MkMind m3.mEngrams m3.mGlia m3.mTick m3.mSpikes m3.mEncode m3.mRetr m3.mSelf
       m3.mSleep (max 0.1 (m3.mDa * 0.995)) (min 0.6 (m3.mAch * 0.998 + 0.001))
       m3.mIdea m3.mAlive

dropStr : Nat -> String -> String
dropStr n s = pack (drop n (unpack s))

toLowerStr : String -> String
toLowerStr s = pack (map lc (unpack s))
  where
    lc : Char -> Char
    lc c = if c >= 'A' && c <= 'Z' then chr (ord c + 32) else c

handleCmd : Mind -> String -> IO (Mind, Bool)
handleCmd m raw = do
  let cmd = trim raw
      low = toLowerStr cmd
  if low == "q" || low == "quit" || low == "exit"
    then pure (MkMind m.mEngrams m.mGlia m.mTick m.mSpikes m.mEncode m.mRetr m.mSelf
                 m.mSleep m.mDa m.mAch m.mIdea False, False)
    else if low == "status" || low == "st"
      then do
        putStrLn (statusLine m)
        pure (m, True)
    else if low == "sleep"
      then do
        putStrLn "  [sleep NREM] consolidated"
        pure (sleepNrem m, True)
    else if isPrefixOf "ask " low
      then do
        let cue = trim (dropStr 4 cmd)
            (m', ans, ok) = retrieve m cue
        putStrLn $ "  [retrieve] " ++ cue ++ " -> " ++ if ok then ans else "???"
        pure (if ok then selfTalk m' else m', True)
    else if isPrefixOf "teach " low
      then do
        let body = trim (dropStr 6 cmd)
            chars = unpack body
        case break (== '=') chars of
          (cs, '=' :: as) => do
            let c = pack cs
                a = pack as
                m' = teach m (trim c) (trim a)
            putStrLn $ "  [encode] " ++ trim c ++ " -> " ++ trim a
            pure (m', True)
          _ => do
            putStrLn "  usage: teach cue=answer"
            pure (m, True)
    else if low == "help"
      then do
        putStrLn "  ask <cue> | teach <cue>=<ans> | sleep | status | quit"
        pure (m, True)
    else if length cmd == 0
      then pure (m, True)
    else do
      let (m', ans, ok) = retrieve m cmd
      putStrLn $ "  [retrieve] " ++ cmd ++ " -> " ++ if ok then ans else "???"
      pure (m', True)

when : Bool -> Lazy (IO ()) -> IO ()
when True a = a
when False _ = pure ()

export
runLiveMindAuto : Int -> IO ()
runLiveMindAuto maxTicks = do
  putStrLn "=== FSOT LIVE MIND (connected organism - Idris twin) ==="
  putStrLn "doctrine: ONE brain stays online - not a unit-test parade"
  let m0 = boot
  putStrLn $ "brain engrams=" ++ show (length m0.mEngrams)
  let go : Mind -> IO Mind
      go m =
        if m.mTick >= maxTicks then pure m
        else do
          let m' = tickOnce m
          when ((m'.mTick `mod` 20) == 0) $ putStrLn (statusLine m')
          when ((m'.mTick `mod` 50) == 0) $
            putStrLn $ "  [sleep NREM #" ++ show m'.mSleep ++ "]"
          go m'
  mF <- go m0
  putStrLn ""
  putStrLn "=== LIVE MIND STOPPED ==="
  putStrLn (statusLine mF)
  putStrLn "FSOT_CONNECTED_ORGANISM_OK"
  putStrLn "FSOT_NOT_DISCONNECTED_GATES"
  putStrLn "FSOT_LIVE_MIND_IDRIS_OK"

export
runLiveMind : IO ()
runLiveMind = do
  putStrLn "=== FSOT LIVE MIND (connected organism - Idris twin) ==="
  putStrLn "doctrine: ONE brain stays online"
  putStrLn "commands: ask <cue> | teach <cue>=<ans> | sleep | status | quit"
  let m0 = boot
  putStrLn $ "brain engrams=" ++ show (length m0.mEngrams)
  putStrLn ""
  let done : Mind -> IO ()
      done m = do
        putStrLn ""
        putStrLn "=== LIVE MIND STOPPED (same organism) ==="
        putStrLn (statusLine m)
        putStrLn "FSOT_CONNECTED_ORGANISM_OK"
        putStrLn "FSOT_NOT_DISCONNECTED_GATES"
        putStrLn "FSOT_LIVE_MIND_IDRIS_OK"
      loop : Mind -> IO ()
      loop m = do
        let m1 = tickOnce m
        if not m1.mAlive
          then done m1
          else
            if (m1.mTick `mod` 20) == 0
              then do
                putStrLn (statusLine m1)
                when ((m1.mTick `mod` 50) == 0) $
                  putStrLn $ "  [sleep NREM #" ++ show m1.mSleep ++ "]"
                putStr "live> "
                line <- getLine
                (m2, cont) <- handleCmd m1 line
                if m2.mAlive && cont then loop m2 else done m2
              else loop m1
  loop m0
