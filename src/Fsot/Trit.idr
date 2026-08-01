||| FSOT trinary substrate T = {-1, 0, +1}. Twin of Zig trit.zig.
module Fsot.Trit

%default total

public export
Trit : Type
Trit = Int

public export
asTrit : Int -> Trit
asTrit x = if x > 0 then 1 else if x < 0 then -1 else 0

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

public export
codonPrimary : Char -> Char -> Char -> (Trit, Trit, Trit)
codonPrimary c0 c1 c2 = (basePrimary c0, basePrimary c1, basePrimary c2)
