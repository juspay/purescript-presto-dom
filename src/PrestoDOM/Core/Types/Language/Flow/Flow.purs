module PrestoDOM.Core.Types.Language.Flow where

import Prelude

import Data.Maybe (Maybe)
import Effect.Aff (makeAff)
import Presto.Core.Flow (Flow, doAff)
import PrestoDOM (Screen)
import PrestoDOM.Core (initUI, initUIWithScreen, runScreen, showScreen, prepareScreen) as PrestoDOM

initUI :: Maybe (Array String) -> Flow Unit
initUI manualEvents = doAff do makeAff \cb -> PrestoDOM.initUI manualEvents cb

initUIWithScreen
  :: forall action state
   . Maybe (Array String)
  -> Screen action state Unit
  -> Flow Unit
initUIWithScreen manualEvents screen =
  doAff
    do
      makeAff \cb -> PrestoDOM.initUIWithScreen manualEvents screen cb

runScreen :: forall action state retType. Screen action state retType -> Flow retType
runScreen screen = doAff do makeAff \cb -> PrestoDOM.runScreen screen cb

prepareScreen
  :: forall action state retType
   . Maybe (Array String)
  -> Screen action state retType
  -> Flow Unit
prepareScreen manualEvents screen =
  doAff
    do
      makeAff \cb -> PrestoDOM.prepareScreen manualEvents screen cb

showScreen :: forall action state retType. Screen action state retType -> Flow retType
showScreen screen = doAff do makeAff \cb -> PrestoDOM.showScreen screen cb
