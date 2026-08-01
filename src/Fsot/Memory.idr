||| Episodic memory — twin of Zig memory_fixed (host).
module Fsot.Memory

import Data.List
import Data.String

%default covering

public export
record Engram where
  constructor MkEngram
  eCue : String
  eAns : String

public export
record Store where
  constructor MkStore
  sEngrams : List Engram

public export
emptyStore : Store
emptyStore = MkStore []

public export
encode : Store -> String -> String -> Store
encode st cue ans = MkStore (MkEngram cue ans :: take 511 st.sEngrams)

public export
retrieve : Store -> String -> (String, Bool)
retrieve st cue =
  case find (\e => e.eCue == cue) st.sEngrams of
    Just e => (e.eAns, True)
    Nothing =>
      -- weak overlap
      case find (\e => isInfixOf cue e.eCue || isInfixOf e.eCue cue) st.sEngrams of
        Just e => (e.eAns, True)
        Nothing => ("", False)

public export
selfTest : Bool
selfTest =
  let st = encode (encode emptyStore "one and one" "two") "plants need" "sun"
      (a, ok) = retrieve st "one and one"
  in ok && a == "two"
