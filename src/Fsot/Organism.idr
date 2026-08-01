||| Continuous organism — twin of Zig organism_fixed.
module Fsot.Organism

import Fsot.Memory
import Fsot.Neuron
import Data.List

%default covering

public export
record Organism where
  constructor MkOrganism
  oNeurons : List Neuron
  oStore : Store
  oTick : Int
  oSpikes : Int

nUnits : Int
nUnits = 32

public export
initOrganism : Organism
initOrganism = MkOrganism (replicate (cast nUnits) defaultNeuron) emptyStore 0 0

stepOnce : List Neuron -> Double -> (List Neuron, Int)
stepOnce ns stim =
  let outs = map (\n => step n stim) ns
      ns' = map fst outs
      sp = cast {to=Int} (length (filter soFired (map snd outs)))
  in (ns', sp)

goTicks : Int -> List Neuron -> Double -> Int -> (List Neuron, Int)
goTicks 0 ns _ sp = (ns, sp)
goTicks k ns stim sp =
  let (ns', s) = stepOnce ns stim
  in goTicks (k - 1) ns' stim (sp + s)

public export
tick : Organism -> Double -> Organism
tick o stim =
  let (ns1, sp1) = goTicks 4 o.oNeurons stim 0
  in MkOrganism ns1 o.oStore (o.oTick + 1) (o.oSpikes + sp1)

public export
teach : Organism -> String -> String -> Organism
teach o cue ans = MkOrganism o.oNeurons (encode o.oStore cue ans) o.oTick o.oSpikes

public export
ask : Organism -> String -> (Organism, String, Bool)
ask o cue =
  let (ans, ok) = retrieve o.oStore cue
  in (o, ans, ok)

public export
selfTest : Bool
selfTest =
  let o0 = initOrganism
      o1 = foldl (\o, _ => tick o 0.5) o0 [1..20]
      o2 = teach o1 "one and one" "two"
      res = ask o2 "one and one"
      ans = case res of (_, a, _) => a
      ok = case res of (_, _, k) => k
  in ok && ans == "two"
