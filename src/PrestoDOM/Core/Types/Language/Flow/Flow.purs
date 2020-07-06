
module PrestoDOM.Core.Types.Language.Flow where

import Prelude

import Data.Maybe (Maybe)
import Effect.Aff (makeAff)
import Presto.Core.Flow (Flow, doAff)
import PrestoDOM (Screen)
import PrestoDOM.Core (initUI, initUIWithScreen, runScreen, showScreen, prepareScreen) as PrestoDOM
import PrestoDOM.Types.Core(class Loggable)

initUI :: Flow Unit
initUI  = doAff do makeAff \cb -> PrestoDOM.initUI cb

initUIWithScreen
  :: forall action state
   . Screen action state Unit
  -> Flow Unit
initUIWithScreen screen =
  doAff (makeAff \cb -> PrestoDOM.initUIWithScreen screen cb)

runScreen :: forall action state retType. Show action => Loggable action => Screen action state retType -> Flow retType
runScreen screen = doAff do makeAff \cb -> PrestoDOM.runScreen screen cb

prepareScreen
  :: forall action state retType
   . Screen action state retType
  -> Flow Unit
prepareScreen screen =
  doAff (makeAff \cb -> PrestoDOM.prepareScreen screen cb)

showScreen :: forall action state retType. Show action => Loggable action => Screen action state retType -> Flow retType
showScreen screen = doAff do makeAff \cb -> PrestoDOM.showScreen screen cb
