module PrestoDOM.Core.Types.Language.Flow where

import Prelude

import Effect.Aff (makeAff)
import Presto.Core.Flow (Flow, doAff)
import PrestoDOM (Screen)
import PrestoDOM.Core (initUI, initUIWithScreen, runScreen, showScreen) as PrestoDOM
import PrestoDOM.Types.Core(class Loggable)

initUI :: Flow Unit
initUI = doAff do makeAff \cb -> PrestoDOM.initUI cb

initUIWithScreen :: forall action state. Screen action state Unit -> Flow Unit
initUIWithScreen screen = doAff do makeAff \cb -> PrestoDOM.initUIWithScreen screen cb

runScreen :: forall action state retType. Show action => Loggable action => Screen action state retType -> Flow retType
runScreen screen = doAff do makeAff \cb -> PrestoDOM.runScreen screen cb

showScreen :: forall action state retType. Show action => Loggable action => Screen action state retType -> Flow retType
showScreen screen = doAff do makeAff \cb -> PrestoDOM.showScreen screen cb