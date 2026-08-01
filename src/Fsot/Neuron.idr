||| Neuron step — twin of Zig neuron_fixed (host Double).
module Fsot.Neuron

%default covering

public export
record Neuron where
  constructor MkNeuron
  nS : Double
  nRefractory : Int
  nAdapt : Double
  nSpikeCount : Int
  nFireThr : Double
  nRefSteps : Int
  nAdaptStep : Double
  nAdaptGain : Double
  nAdaptDecay : Double
  nRestingS : Double
  nDEff : Double

public export
record StepOut where
  constructor MkStepOut
  soS : Double
  soFired : Bool

public export
defaultNeuron : Neuron
defaultNeuron = MkNeuron 0.45 0 0.0 0 1.05 12 0.7 0.02 0.988 0.45 13.0

public export
step : Neuron -> Double -> (Neuron, StepOut)
step n stim =
  let inRef = n.nRefractory > 0
      adapt' = n.nAdapt * n.nAdaptDecay
      stimEff = max (-0.5) (min 1.5 (stim - adapt'))
      drive = stimEff * 0.22 * (n.nDEff / 13.0)
      sCand = if inRef then n.nRestingS * 0.5 else n.nS * 0.90 + drive + n.nRestingS * 0.02
      fired = not inRef && sCand >= n.nFireThr
  in if fired
       then
         let n' = MkNeuron n.nRestingS n.nRefSteps (adapt' + n.nAdaptStep * n.nAdaptGain)
                          (n.nSpikeCount + 1) n.nFireThr n.nRefSteps n.nAdaptStep n.nAdaptGain
                          n.nAdaptDecay n.nRestingS n.nDEff
         in (n', MkStepOut n.nRestingS True)
       else
         let ref1 = if inRef then n.nRefractory - 1 else 0
             n' = MkNeuron sCand (max 0 ref1) adapt' n.nSpikeCount n.nFireThr n.nRefSteps
                          n.nAdaptStep n.nAdaptGain n.nAdaptDecay n.nRestingS n.nDEff
         in (n', MkStepOut sCand False)

public export
selfTest : Bool
selfTest =
  let go : Int -> Neuron -> Int -> Int
      go 0 _ sp = sp
      go k n sp =
        let (n', o) = step n 0.55
            sp' = sp + if o.soFired then 1 else 0
        in go (k - 1) n' sp'
  in go 200 defaultNeuron 0 >= 1
