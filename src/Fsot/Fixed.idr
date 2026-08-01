||| Seed-scaled fixed-point — twin of Zig fixed.zig / Haskell Fsot.Fixed.
||| SCALE = 10^12. Integer storage; mind authority lattice.
module Fsot.Fixed

%default total

public export
Fixed : Type
Fixed = Integer

public export
scale : Integer
scale = 1000000000000

public export
fromInt : Integer -> Fixed
fromInt n = n * scale

public export
toDouble : Fixed -> Double
toDouble x = cast x / cast scale

public export
fromDoubleLab : Double -> Fixed
fromDoubleLab x = cast (cast {to=Integer} (x * cast scale))

public export
add : Fixed -> Fixed -> Fixed
add = (+)

public export
sub : Fixed -> Fixed -> Fixed
sub = (-)

public export
mul : Fixed -> Fixed -> Fixed
mul a b =
  let wide = a * b
      q = wide `div` scale
      r = wide `mod` scale
      ar = if r < 0 then negate r else r
  in if ar * 2 >= scale
        then if wide > 0 then q + 1 else q - 1
        else q

public export
divF : Fixed -> Fixed -> Fixed
divF a 0 = 0
divF a b =
  let wide = a * scale
      q = wide `div` b
      r = wide `mod` b
      ad = if b < 0 then negate b else b
      ar = if r < 0 then negate r else r
  in if ar * 2 >= ad
        then if (wide > 0) == (b > 0) then q + 1 else q - 1
        else q

public export
clamp : Fixed -> Fixed -> Fixed -> Fixed
clamp x lo hi =
  if x < lo then lo else if x > hi then hi else x
