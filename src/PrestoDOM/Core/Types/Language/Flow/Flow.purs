
module PrestoDOM.Core.Types.Language.Flow where

import Prelude

import Data.Maybe (Maybe(..))
import Effect.Aff (makeAff, nonCanceler)
import Effect.Class (liftEffect)
import Presto.Core.Flow (Flow, doAff)
import Presto.Core.Types.Language.Flow(getLogFields)
import PrestoDOM (Screen)
import PrestoDOM.Core (prepareScreen) as PrestoDOM
import PrestoDOM.Core2 as PrestoDOM2
import PrestoDOM.Types.Core (class Loggable, ScopedScreen)

initUI :: Flow Unit
initUI  = doAff do makeAff \cb -> PrestoDOM2.initUIWithNameSpace "default" Nothing *> pure nonCanceler

-- deprecated
initUIWithScreen
  :: forall action state
   . Screen action state Unit
  -> Flow Unit
initUIWithScreen screen =
  doAff do makeAff \cb -> PrestoDOM2.initUIWithScreen "default" Nothing (mapToScopedScreen screen) *> pure nonCanceler

runScreen :: forall action state retType. Show action => Loggable action => Screen action state retType -> Flow retType
runScreen screen = do
  json <- getLogFields
  doAff do makeAff \cb -> PrestoDOM2.runScreen (mapToScopedScreen screen) cb json

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
  doAff do makeAff \cb -> PrestoDOM2.showScreen (mapToScopedScreen screen) cb json

updateScreen :: forall action state retType. Show action => Loggable action => Screen action state retType -> Flow Unit
updateScreen screen = doAff do liftEffect $ PrestoDOM2.updateScreen (mapToScopedScreen screen)

mapToScopedScreen :: forall action state retType. Screen action state retType -> ScopedScreen action state retType
mapToScopedScreen screen =
  { initialState : screen.initialState
  , name : screen.name
  , globalEvents : screen.globalEvents
  , view : screen.view
  , eval : screen.eval
  , parent : Nothing
  }
