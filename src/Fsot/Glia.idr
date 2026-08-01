||| Glia product gates (host twin of Zig glia_product_fixed).
module Fsot.Glia

import Data.List

%default covering

nAstro : Int
nAstro = 8

public export
record GliaState where
  constructor MkGlia
  gSupply : List Double
  gLoad : List Double
  gCaPhase : List Double
  gMicro : Double
  gTick : Int
  gClear : Int
  gSurges : Int

public export
initGlia : GliaState
initGlia =
  MkGlia
    (replicate (cast nAstro) 0.55)
    (replicate (cast nAstro) 0.0)
    [cast i / cast nAstro | i <- [the Int 0 .. nAstro - 1]]
    0.2 0 0 0

setAt : Nat -> a -> List a -> List a
setAt _ _ [] = []
setAt Z v (_ :: xs) = v :: xs
setAt (S k) v (x :: xs) = x :: setAt k v xs

indexD : Nat -> List Double -> Double
indexD _ [] = 0
indexD Z (x :: _) = x
indexD (S k) (_ :: xs) = indexD k xs

tileOf : Int -> Int
tileOf u = min (u `div` 4) (nAstro - 1)

clampD : Double -> Double -> Double -> Double
clampD lo hi x = max lo (min hi x)

stepTile : Int -> List Double -> List Double -> List Double -> Int -> Int
        -> (List Double, List Double, List Double, Int, Int)
stepTile t sup load ca clear surges =
  let s0 = indexD (cast t) sup
      l0 = indexD (cast t) load
      c0 = indexD (cast t) ca
      cleared = 0.12 * (s0 + 0.1)
      l1 = if l0 > cleared then l0 - cleared else 0.0
      c1 = if l0 > 0.0 then clear + 1 else clear
      s1 = clampD 0.05 1.0 (s0 + 0.08 * (0.42 - s0) - 0.12 * l1)
      cA = c0 + 0.07
  in if cA > 1.0
       then (setAt (cast t) (clampD 0.05 1.0 (s1 + 0.04)) sup
            , setAt (cast t) l1 load
            , setAt (cast t) (cA - 1.0) ca
            , c1, surges + 1)
       else (setAt (cast t) s1 sup
            , setAt (cast t) l1 load
            , setAt (cast t) cA ca
            , c1, surges)

public export
stepAfterSpikes : GliaState -> List Bool -> GliaState
stepAfterSpikes g fired =
  let n = cast {to=Int} (length fired)
      deposit : Int -> Double
      deposit t =
        sum
          [ 0.08
          | (u, f) <- zip [the Int 0 .. n - 1] fired
          , f
          , tileOf u == t
          ]
      loads1 = [indexD (cast t) g.gLoad + deposit t | t <- [the Int 0 .. nAstro - 1]]
      goTiles : Int -> List Double -> List Double -> List Double -> Int -> Int
              -> (List Double, List Double, List Double, Int, Int)
      goTiles t sup load ca clear surges =
        if t >= nAstro then (sup, load, ca, clear, surges)
        else
          case stepTile t sup load ca clear surges of
            (s2, l2, c2, cl2, su2) => goTiles (t + 1) s2 l2 c2 cl2 su2
      res = goTiles 0 g.gSupply loads1 g.gCaPhase g.gClear g.gSurges
      supF = case res of (s, _, _, _, _) => s
      loadF = case res of (_, l, _, _, _) => l
      caF = case res of (_, _, c, _, _) => c
      clearF = case res of (_, _, _, cl, _) => cl
      surgeF = case res of (_, _, _, _, su) => su
      multi =
        cast {to=Int} (length
          [ ()
          | t <- [the Int 0 .. nAstro - 2]
          , indexD (cast t) loadF > 0.4
          , indexD (cast (t + 1)) loadF > 0.4
          ])
      meanLoad = sum loadF / cast nAstro
      micro = clampD 0.05 0.85 (0.15 + 0.4 * meanLoad)
      extra = if g.gTick `mod` 11 == 0 then multi else 0
  in MkGlia supF loadF caF micro (g.gTick + 1) clearF (surgeF + extra)

plasticityGain : GliaState -> Double
plasticityGain g =
  let sup = indexD 0 g.gSupply
      ca = indexD 0 g.gCaPhase
      caBump = if ca < 0.15 then 0.12 else 0.0
  in clampD 0.2 1.6 (0.189 + sup * 0.72 + caBump)

public export
record GliaProductReport where
  constructor MkGliaProduct
  gpOk : Bool
  gpSteps : Int
  gpSurges : Int
  gpClear : Int
  gpSupply : Double
  gpRatio : Double
  gpConsol : Double

public export
runGliaProduct : Int -> GliaProductReport
runGliaProduct maxSteps =
  let nUnits = 32
      go : Int -> GliaState -> GliaState
      go 0 g = g
      go k g =
        let stepN = maxSteps - k
            fired =
              [ (u + stepN) `mod` 5 == 0 || (u + stepN) `mod` 7 == 0
              | u <- [the Int 0 .. nUnits - 1]
              ]
        in go (k - 1) (stepAfterSpikes g fired)
      gF = go maxSteps initGlia
      supply = sum gF.gSupply / cast nAstro
      etaW = plasticityGain gF
      etaB : Double
      etaB = 0.189
      ratio = etaW / etaB
      dens = cast {to=Double} gF.gSurges / cast {to=Double} (max maxSteps 1)
      consol = supply * (1.0 + 2.0 * dens)
      surgeOk = gF.gSurges >= 3
      etaOk = ratio >= 1.05
      consolOk = consol >= 0.12 || dens >= 0.05
  in MkGliaProduct (surgeOk && etaOk && consolOk) maxSteps gF.gSurges gF.gClear supply ratio consol

public export
printGliaProduct : GliaProductReport -> IO ()
printGliaProduct r = do
  putStrLn "=== FSOT GLIA PRODUCT (astrocyte Ca + consolidate bias) ==="
  putStrLn $ "GLIA steps=" ++ show r.gpSteps ++ " surges=" ++ show r.gpSurges
           ++ " clear=" ++ show r.gpClear ++ " supply=" ++ show r.gpSupply
           ++ " ratio=" ++ show r.gpRatio ++ " consol=" ++ show r.gpConsol
  if r.gpOk
    then do
      putStrLn "FSOT_GLIA_CA_SURGE_OK"
      putStrLn "FSOT_GLIA_CONSOLIDATE_OK"
      putStrLn "FSOT_GLIA_PRODUCT PASS"
    else putStrLn "FSOT_GLIA_PRODUCT FAIL"
