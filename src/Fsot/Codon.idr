||| DNA physical function as FSOT trinary code.
|||
||| Wet biology:
|||   bases A/C/G/T → codon triplets → IUPAC amino acids → charge / aromaticity
||| FSOT encoding (PRIMARY):
|||   A,G → +1 ; C,T → −1   (purine / pyrimidine partition)
||| Expression uses seeds φ, π, γ only — not free FI tables.
|||
||| Authority: Zig src/codon.zig · data/64_codon_trinary_map.txt
||| Doctrine: docs/DNA_TRINARY_FSOT.md
module Fsot.Codon

import Fsot.Trit
import Fsot.Seeds
import Data.String
import Data.List

%default covering

||| One translated codon: wet bases + PRIMARY trip + amino acid.
public export
record Residue where
  constructor MkResidue
  resC0 : Char
  resC1 : Char
  resC2 : Char
  ||| PRIMARY trinary trip — chemical purine/pyrimidine as spin
  resTrip : (Trit, Trit, Trit)
  ||| IUPAC single-letter amino acid ('*' = stop)
  resAa : Char

||| Normalize RNA U→T and case for genetic code table.
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

||| Standard genetic code (DNA sense). Authority: IUPAC / wet translation.
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

||| Side-chain charge at physiological pH (channel expression physics).
public export
aaCharge : Char -> Int
aaCharge aa = case aa of
  'R' => 1; 'H' => 1; 'K' => 1
  'D' => -1; 'E' => -1
  _ => 0

||| Aromatic residues — membrane / stacking contribution to expression.
public export
aaIsAromatic : Char -> Bool
aaIsAromatic aa = aa == 'F' || aa == 'Y' || aa == 'W'

||| Decode DNA ORF in reading-frame steps of 3 (physical translation frame).
public export
decodeOrf : String -> List Residue
decodeOrf dna = go (filter isBase (unpack dna))
  where
    isBase : Char -> Bool
    isBase c = c `elem` (the (List Char) ['A','C','G','T','a','c','g','t','U','u'])
    go : List Char -> List Residue
    go (x :: y :: z :: rest) =
      let a = upperBase x
          b = upperBase y
          c = upperBase z
      in MkResidue a b c (codonPrimary a b c) (dnaToAa a b c) :: go rest
    go _ = []

||| Mean PRIMARY spin over ORF — trinary summary of purine/pyrimidine content.
public export
meanSpin : List Residue -> Double
meanSpin [] = 0.0
meanSpin rs =
  let trips = map resTrip rs
      s = foldl (+) 0.0 [cast {to=Double} (t0 + t1 + t2) | (t0, t1, t2) <- trips]
      n = cast {to=Double} (3 * length rs)
  in s / n

public export
chargeBalance : List Residue -> Int
chargeBalance = sum . map (aaCharge . resAa)

public export
aromaticFraction : List Residue -> Double
aromaticFraction [] = 0.0
aromaticFraction rs =
  cast {to=Double} (length (filter (aaIsAromatic . resAa) rs))
    / cast {to=Double} (length rs)

||| FSOT gene expression from translated ORF.
||| expression = φ^spin · e^{|q|/(π·n)} · (1 + γ·aromatic)
||| Seeds only — biologically: more spin/charge/aromatic → stronger program drive.
public export
geneExpression : List Residue -> Double
geneExpression [] = 1.0
geneExpression rs =
  let spin = meanSpin rs
      n = cast {to=Double} (length rs)
      qAbs = cast {to=Double} (if chargeBalance rs < 0 then negate (chargeBalance rs) else chargeBalance rs)
      arom = aromaticFraction rs
      raw = (phi `pow` spin) * exp (qAbs / (seedPi * n)) * (1.0 + gamma * arom)
  in max 0.05 (min 3.0 raw)

||| Biological anchors: ATG = Met start; PRIMARY(ATG) = (+1,−1,+1).
public export
selfTest : Bool
selfTest =
  let atg = codonPrimary 'A' 'T' 'G'
      okTrip = atg == (1, -1, 1)
      aaOk = dnaToAa 'A' 'T' 'G' == 'M'
      res = decodeOrf "ATGGCC"
      -- ATG GCC → Met Ala; frame length 2
  in okTrip && aaOk && length res == 2 && geneExpression res > 0.0
