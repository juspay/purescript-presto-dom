
module PrestoDOM.Core.Types.Language.Flow where

import Prelude

import Effect.Aff (makeAff)
import Effect.Class (liftEffect)
import Presto.Core.Flow (Flow, doAff)
import Presto.Core.Types.Language.Flow(getLogFields)
import PrestoDOM (Screen)
import PrestoDOM.Core (initUI, initUIWithScreen, runScreen, showScreen, updateScreen, prepareScreen) as PrestoDOM
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
runScreen screen = do
  json <- getLogFields
  doAff do makeAff \cb -> PrestoDOM.runScreen screen cb json

prepareScreen
  :: forall action state retType
   . Screen action state retType
  -> Flow Unit
prepareScreen screen = do
  json <- getLogFields
  doAff (makeAff \cb -> PrestoDOM.prepareScreen screen cb json)

showScreen :: forall action state retType. Show action => Loggable action => Screen action state retType -> Flow retType
showScreen screen = do
  json <- getLogFields
  doAff do makeAff \cb -> PrestoDOM.showScreen screen cb json

updateScreen :: forall action state retType. Show action => Loggable action => Screen action state retType -> Flow Unit
updateScreen screen = do
  json <- getLogFields
  doAff do liftEffect $ PrestoDOM.updateScreen screen json
