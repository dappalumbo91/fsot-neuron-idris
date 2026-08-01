||| FSOT trinary substrate T = {-1, 0, +1}.
|||
||| PRIMARY base map (DNA chemistry as spin):
|||   purines  A,G → +1
|||   pyrimidines C,T → −1
||| That partition is physical (ring structure), not free labeling.
module Fsot.Trit

%default total

public export
Trit : Type
Trit = Int

public export
asTrit : Int -> Trit
asTrit x = if x > 0 then 1 else if x < 0 then -1 else 0

||| PRIMARY: purine (+1) / pyrimidine (−1).
public export
basePrimary : Char -> Trit
basePrimary b = case b of
  'A' => 1
  'a' => 1
  'G' => 1
  'g' => 1
  'C' => -1
  'c' => -1
  'T' => -1
  't' => -1
  'U' => -1
  'u' => -1
  _ => 0

||| Codon as PRIMARY trip — three bases of chemical spin.
public export
codonPrimary : Char -> Char -> Char -> (Trit, Trit, Trit)
codonPrimary c0 c1 c2 = (basePrimary c0, basePrimary c1, basePrimary c2)

||| SECONDARY (A=+1, T=−1, G/C=0) — optional polarity layer.
public export
baseSecondary : Char -> Trit
baseSecondary b = case b of
  'A' => 1; 'a' => 1
  'T' => -1; 't' => -1; 'U' => -1; 'u' => -1
  'G' => 0; 'g' => 0; 'C' => 0; 'c' => 0
  _ => 0
