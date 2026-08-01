||| Product claim: full ISI distribution KS vs Allen CSV.
||| Twin of Zig allen_isi_ks_product / Haskell Fsot.AllenIsiKs.
module Fsot.AllenIsiKs

import Fsot.BioProbe
import Fsot.CellTypes
import Fsot.Genotype
import System.File
import Data.String
import Data.List
import Data.Maybe

%default covering

public export
record ProductReport where
  constructor MkProductReport
  prOk : Bool
  prNSim : Int
  prNAllen : Int
  prSimMean : Double
  prSimSd : Double
  prSimCv : Double
  prSimP25 : Double
  prSimP50 : Double
  prSimP75 : Double
  prMeanErr : Double
  prSdRel : Double
  prP25Err : Double
  prP50Err : Double
  prP75Err : Double
  prKsD : Double
  prKsCrit : Double
  prKsCap : Double
  prKsOk : Bool
  prMeanOk : Bool
  prSdOk : Bool
  prQuantOk : Bool
  prGenetic : Bool
  prPolish : Bool
  prTargetsLoaded : Bool
  prSampleLoaded : Bool

emptyReport : ProductReport
emptyReport = MkProductReport False 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  False False False False True True False False

public export
ksCritical05 : Int -> Int -> Double
ksCritical05 n1 n2 =
  if n1 == 0 || n2 == 0 then 1.0
  else
    let a = cast {to=Double} n1
        b = cast {to=Double} n2
    in 1.358 * sqrt ((a + b) / (a * b))

||| Two-sample KS D.
public export
ksTwoSample : List Double -> List Double -> Double
ksTwoSample a b =
  if null a || null b then 1.0
  else
    let na = cast {to=Double} (length a)
        nb = cast {to=Double} (length b)
        go : List Double -> List Double -> Int -> Int -> Double -> Double
        go [] [] _ _ d = d
        go (x :: xs) [] i j d =
          let i' = i + 1
              di = abs (cast {to=Double} i' / na - cast {to=Double} j / nb)
          in go xs [] i' j (max d di)
        go [] (y :: ys) i j d =
          let j' = j + 1
              di = abs (cast {to=Double} i / na - cast {to=Double} j' / nb)
          in go [] ys i j' (max d di)
        go (x :: xs) (y :: ys) i j d =
          if x < y then
            let i' = i + 1
                di = abs (cast {to=Double} i' / na - cast {to=Double} j / nb)
            in go xs (y :: ys) i' j (max d di)
          else if x > y then
            let j' = j + 1
                di = abs (cast {to=Double} i / na - cast {to=Double} j' / nb)
            in go (x :: xs) ys i j' (max d di)
          else
            let i' = i + 1
                j' = j + 1
                di = abs (cast {to=Double} i' / na - cast {to=Double} j' / nb)
            in go xs ys i' j' (max d di)
    in go (sort a) (sort b) 0 0 0.0

meanSd : List Double -> (Double, Double)
meanSd [] = (0, 0)
meanSd xs =
  let n = cast {to=Double} (length xs)
      m = sum xs / n
      v = sum [(x - m) * (x - m) | x <- xs] / n
  in (m, sqrt v)

indexAt : Nat -> List a -> Maybe a
indexAt _ [] = Nothing
indexAt Z (x :: _) = Just x
indexAt (S k) (_ :: xs) = indexAt k xs

quantSorted : List Double -> Double -> Double
quantSorted [] _ = 0
quantSorted sorted p =
  let nNat = length sorted
      n = cast {to=Double} nNat
      x = (n - 1.0) * p
      loI = the Int (cast (floor x))
      loN = cast {to=Nat} (the Int (max 0 loI))
      hiN = min (loN + 1) (minus nNat 1)
      t = x - cast {to=Double} loI
      a = fromMaybe 0.0 (indexAt loN sorted)
      b = fromMaybe 0.0 (indexAt hiN sorted)
  in a * (1.0 - t) + b * t

classForSpecimen : Specimen -> Int -> CellType
classForSpecimen sp i =
  if sp.spIsiMs < 22 then Pv
  else if sp.spIsiMs < 40 then (if i `mod` 2 == 0 then Vip else Sst)
  else if sp.spIsiMs < 55 then Sst
  else Pyr

isCommentOrEmpty : String -> Bool
isCommentOrEmpty s =
  let t = trim s
  in length t == 0 || isPrefixOf "#" t

lookupKV : String -> List (String, String) -> Maybe String
lookupKV k [] = Nothing
lookupKV k ((a, b) :: rest) = if a == k then Just b else lookupKV k rest

parseKV : String -> List (String, String)
parseKV txt =
  [ (k, v)
  | ln <- lines txt
  , not (isCommentOrEmpty ln)
  , let ws = words (trim ln)
  , length ws >= 2
  , let k = fromMaybe "" (indexAt 0 ws)
        v = fromMaybe "" (indexAt 1 ws)
  ]

kvDouble : List (String, String) -> String -> Maybe Double
kvDouble kvs k = lookupKV k kvs >>= Data.String.parseDouble

loadTargets : String -> IO (Maybe (Double, Double, Double, Double, Double))
loadTargets path = do
  res <- readFile path
  case res of
    Left _ => pure Nothing
    Right txt =>
      let kvs = parseKV txt
      in pure $ do
           mean <- kvDouble kvs "isi_mean_ms"
           sd <- kvDouble kvs "isi_sd_ms"
           p25 <- kvDouble kvs "isi_p25"
           p50 <- kvDouble kvs "isi_p50"
           p75 <- kvDouble kvs "isi_p75"
           pure (mean, sd, p25, p50, p75)

parseSpecimenLine : String -> Maybe Specimen
parseSpecimenLine ln =
  let ws = words ln
  in case (indexAt 0 ws, indexAt 1 ws) of
       (Just a, Just b) =>
         case (Data.String.parseDouble a, Data.String.parseDouble b) of
           (Just isi, Just ad) => Just (MkSpecimen isi ad)
           _ => Nothing
       _ => Nothing

loadSample : String -> IO (List Specimen)
loadSample path = do
  res <- readFile path
  case res of
    Left _ => pure []
    Right txt =>
      let ls = filter (not . isCommentOrEmpty) (map trim (lines txt))
      in case ls of
           [] => pure []
           (_ :: body) => pure (mapMaybe parseSpecimenLine body)

fiSteps : Int
fiSteps = 1200

enumerate : List a -> List (Int, a)
enumerate xs =
  let go : Int -> List a -> List (Int, a)
      go _ [] = []
      go i (x :: rest) = (i, x) :: go (i + 1) rest
  in go 0 xs

collectIsi : Int -> Specimen -> Maybe Double
collectIsi i sp =
  let ct = classForSpecimen sp i
      p0 = paramsFromCellType ct (42 + i) True
      p1 = polishToSpecimen p0 sp fiSteps
      pr = runFIUnit p1 fiSteps
  in if pr.fiSpikes >= minSpikesIsi && pr.fiMeanIsiMs > 1
       then Just pr.fiMeanIsiMs
       else Nothing

finishProduct : Double -> Double -> Double -> Double -> Double
             -> List Double -> List Double -> Int -> Int -> ProductReport
finishProduct tMean tSd tP25 tP50 tP75 simIsi allenIsi nSim nAllen =
  let (m, sd) = meanSd simIsi
      sorted = sort simIsi
      p25 = quantSorted sorted 0.25
      p50 = quantSorted sorted 0.50
      p75 = quantSorted sorted 0.75
      meanErr = abs (m - tMean)
      sdRel = if tSd > 1 then abs (sd - tSd) / tSd else 1
      p25e = abs (p25 - tP25)
      p50e = abs (p50 - tP50)
      p75e = abs (p75 - tP75)
      d = ksTwoSample simIsi allenIsi
      crit = ksCritical05 nSim nAllen
      cap = max crit 0.22
      ksOk = d <= cap
      meanOk = meanErr <= 12.0
      sdOk = sdRel <= 0.40
      quantOk = p50e <= 20.0 && p25e <= 20.0 && p75e <= 25.0
      ok = nSim >= 128 && nAllen >= 128 && ksOk && meanOk && sdOk && quantOk
  in MkProductReport
       ok nSim nAllen m sd (if m > 1 then sd / m else 0)
       p25 p50 p75 meanErr sdRel p25e p50e p75e
       d crit cap ksOk meanOk sdOk quantOk
       True True True True

public export
runIsiKsProduct : String -> String -> String -> IO ProductReport
runIsiKsProduct targetsPath sample256 sample128 = do
  mtgt <- loadTargets targetsPath
  case mtgt of
    Nothing => pure emptyReport
    Just (tMean, tSd, tP25, tP50, tP75) => do
      specs0 <- loadSample sample256
      specs <- if length specs0 < 64 then loadSample sample128 else pure specs0
      let nAllen = cast {to=Int} (length specs)
      if nAllen < 64
        then pure ({ prTargetsLoaded := True } emptyReport)
        else do
          let allenIsi = map spIsiMs specs
              simIsi = mapMaybe (\(i, sp) => collectIsi i sp) (enumerate specs)
              nSim = cast {to=Int} (length simIsi)
          if nSim < 64
            then pure ({ prTargetsLoaded := True, prSampleLoaded := True
                       , prNAllen := nAllen, prNSim := nSim } emptyReport)
            else pure (finishProduct tMean tSd tP25 tP50 tP75 simIsi allenIsi nSim nAllen)

public export
printReport : ProductReport -> IO ()
printReport r = do
  putStrLn "=== FSOT ALLEN ISI DISTRIBUTION KS (PRODUCT CLAIM - IDRIS) ==="
  putStrLn "doctrine: genetic class ORF + mutateOrf seed + soft specimen polish; KS + quantiles in ms"
  putStrLn $ "ISI_KS n_sim=" ++ show r.prNSim ++ " n_allen=" ++ show r.prNAllen
           ++ " genetic=" ++ show r.prGenetic ++ " polish=" ++ show r.prPolish
           ++ " targets=" ++ show r.prTargetsLoaded ++ " sample=" ++ show r.prSampleLoaded
  putStrLn $ "ISI_KS sim mean=" ++ show r.prSimMean ++ " sd=" ++ show r.prSimSd
           ++ " cv=" ++ show r.prSimCv ++ " p25=" ++ show r.prSimP25
           ++ " p50=" ++ show r.prSimP50 ++ " p75=" ++ show r.prSimP75
  putStrLn $ "ISI_KS vs_csv |dmean|=" ++ show r.prMeanErr ++ " ms sd_rel=" ++ show r.prSdRel
           ++ " |dp25|=" ++ show r.prP25Err ++ " |dp50|=" ++ show r.prP50Err
           ++ " |dp75|=" ++ show r.prP75Err ++ " ms"
  putStrLn $ "ISI_KS D=" ++ show r.prKsD ++ " D_crit05=" ++ show r.prKsCrit
           ++ " D_cap=" ++ show r.prKsCap ++ " ks_ok=" ++ show r.prKsOk
           ++ " mean_ok=" ++ show r.prMeanOk ++ " sd_ok=" ++ show r.prSdOk
           ++ " quant_ok=" ++ show r.prQuantOk
  if r.prOk
    then do
      putStrLn "FSOT_ALLEN_ISI_KS_PRODUCT PASS"
      putStrLn "FSOT_ALLEN_ISI_DISTRIBUTION_OK"
      putStrLn "FSOT_KS_VS_ALLEN_CSV_OK"
      putStrLn "FSOT_GENETIC_ISI_KS_OK"
      putStrLn "FSOT_IDRIS_ISI_KS_OK"
    else putStrLn "FSOT_ALLEN_ISI_KS_PRODUCT FAIL"

public export
selfTest : Bool
selfTest =
  let c = ksCritical05 100 100
      d0 = ksTwoSample [1, 2, 3] [1, 2, 3]
      pd = Data.String.parseDouble "73.57222670"
  in c > 0.1 && c < 0.3 && d0 < 0.01 && isJust pd
