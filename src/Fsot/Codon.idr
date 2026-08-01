||| FSOT 64-codon trinary foundation. Twin of Zig codon.zig / Haskell Fsot.Codon.
module Fsot.Codon

import Fsot.Trit
import Fsot.Seeds
import Data.String
import Data.List

%default total

public export
record Residue where
  constructor MkResidue
  resC0 : Char
  resC1 : Char
  resC2 : Char
  resTrip : (Trit, Trit, Trit)
  resAa : Char

public export
upperBase : Char -> Char
upperBase b = case b of
  'u' => 'T'
  'U' => 'T'
  'a' => 'A'
  'c' => 'C'
  'g' => 'G'
  't' => 'T'
  _ => b

public export
dnaToAa : Char -> Char -> Char -> Char
dnaToAa c0 c1 c2 =
  let a = upperBase c0
      b = upperBase c1
      c = upperBase c2
  in case a of
       'T' => case b of
         'T' => case c of
           'T' => 'F'; 'C' => 'F'; 'A' => 'L'; 'G' => 'L'; _ => '?'
         'C' => 'S'
         'A' => case c of
           'T' => 'Y'; 'C' => 'Y'; 'A' => '*'; 'G' => '*'; _ => '?'
         'G' => case c of
           'T' => 'C'; 'C' => 'C'; 'A' => '*'; 'G' => 'W'; _ => '?'
         _ => '?'
       'C' => case b of
         'T' => 'L'; 'C' => 'P'
         'A' => case c of
           'T' => 'H'; 'C' => 'H'; 'A' => 'Q'; 'G' => 'Q'; _ => '?'
         'G' => 'R'
         _ => '?'
       'A' => case b of
         'T' => case c of
           'T' => 'I'; 'C' => 'I'; 'A' => 'I'; 'G' => 'M'; _ => '?'
         'C' => 'T'
         'A' => case c of
           'T' => 'N'; 'C' => 'N'; 'A' => 'K'; 'G' => 'K'; _ => '?'
         'G' => case c of
           'T' => 'S'; 'C' => 'S'; 'A' => 'R'; 'G' => 'R'; _ => '?'
         _ => '?'
       'G' => case b of
         'T' => 'V'; 'C' => 'A'
         'A' => case c of
           'T' => 'D'; 'C' => 'D'; 'A' => 'E'; 'G' => 'E'; _ => '?'
         'G' => 'G'
         _ => '?'
       _ => '?'

public export
aaCharge : Char -> Int
aaCharge aa = case aa of
  'R' => 1; 'H' => 1; 'K' => 1
  'D' => -1; 'E' => -1
  _ => 0

public export
aaIsAromatic : Char -> Bool
aaIsAromatic aa = aa == 'F' || aa == 'Y' || aa == 'W'

||| Decode DNA ORF (length multiple of 3).
public export
decodeOrf : String -> List Residue
decodeOrf dna = go (unpack dna)
  where
    isBase : Char -> Bool
    isBase c = c `elem` (unpack "ACGTacgtUTu")
    go : List Char -> List Residue
    go (x :: y :: z :: rest) =
      if isBase x && isBase y && isBase z
        then
          let a = upperBase x
              b = upperBase y
              c = upperBase z
          in MkResidue a b c (codonPrimary a b c) (dnaToAa a b c) :: go rest
        else go (y :: z :: rest)
    go _ = []

public export
meanSpin : List Residue -> Double
meanSpin [] = 0
meanSpin rs =
  let trips = map resTrip rs
      s = sum [cast (t0 + t1 + t2) | (t0, t1, t2) <- trips]
      n = cast (3 * length rs)
  in s / n

public export
chargeBalance : List Residue -> Int
chargeBalance = sum . map (aaCharge . resAa)

public export
aromaticFraction : List Residue -> Double
aromaticFraction [] = 0
aromaticFraction rs =
  cast (length (filter (aaIsAromatic . resAa) rs)) / cast (length rs)

||| expression = phi^spin * e^{|q|/(pi*n)} * (1 + gamma*aromatic)
public export
geneExpression : List Residue -> Double
geneExpression [] = 1.0
geneExpression rs =
  let spin = meanSpin rs
      n = cast (length rs)
      q = cast (if chargeBalance rs < 0 then negate (chargeBalance rs) else chargeBalance rs)
      arom = aromaticFraction rs
      raw = (phi `pow` spin) * exp (q / (seedPi * n)) * (1.0 + gamma * arom)
  in max 0.05 (min 3.0 raw)

public export
selfTest : Bool
selfTest =
  let atg = codonPrimary 'A' 'T' 'G'
      okTrip = atg == (1, -1, 1)
      aaOk = dnaToAa 'A' 'T' 'G' == 'M'
      res = decodeOrf "ATGGCC"
  in okTrip && aaOk && length res == 2 && geneExpression res > 0
