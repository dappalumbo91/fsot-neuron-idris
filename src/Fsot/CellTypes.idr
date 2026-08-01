||| Cortical cell classes Pyr / PV / SST / VIP.
module Fsot.CellTypes

%default total

public export
data CellType = Pyr | Pv | Sst | Vip

public export
classLabel : CellType -> String
classLabel Pyr = "Pyr"
classLabel Pv = "PV"
classLabel Sst = "SST"
classLabel Vip = "VIP"

public export
allenRateHz : CellType -> Double
allenRateHz Pyr = 16.35121532610921
allenRateHz Pv = 83.3504049172855
allenRateHz Sst = 29.538052683455557
allenRateHz Vip = 34.81541758294487
