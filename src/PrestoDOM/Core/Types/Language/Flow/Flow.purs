
module PrestoDOM.Core.Types.Language.Flow where

import Prelude

import Data.Maybe (Maybe(..))
import Effect.Aff (makeAff)
import Effect.Class (liftEffect)
import Presto.Core.Flow (Flow, doAff)
import Presto.Core.Types.Language.Flow(getLogFields)
import Effect(Effect)
import PrestoDOM.Core (prepareScreen) as PrestoDOM
import PrestoDOM.Core2 as PrestoDOM2
import PrestoDOM.Types.Core (class Loggable, ScopedScreen, Controller, Screen)

initUI :: forall a. Flow a Unit
initUI  = doAff do liftEffect $ PrestoDOM2.initUIWithNameSpace "default" Nothing

initUIWithNameSpace :: String -> Maybe String -> Effect Unit
initUIWithNameSpace = PrestoDOM2.initUIWithNameSpace

-- deprecated
initUIWithScreen
  :: forall action state a
   . Screen action state Unit
  -> Flow a Unit
initUIWithScreen screen =
  doAff do PrestoDOM2.initUIWithScreen "default" Nothing (mapToScopedScreen screen)

runScreen :: forall action state retType a. Show action => Loggable action => Screen action state retType -> Flow a retType
runScreen screen = do
  json <- getLogFields
  doAff $ PrestoDOM2.runScreen (mapToScopedScreen screen) json

runScreenWithNameSpace :: forall action state retType a. Show action => Loggable action => ScopedScreen action state retType -> Flow a retType
runScreenWithNameSpace screen = do
  json <- getLogFields
  doAff $ PrestoDOM2.runScreen screen json

prepareScreen
  :: forall action state retType a
   . Screen action state retType
  -> Flow a Unit
prepareScreen screen = do
  json <- getLogFields
  doAff (makeAff \cb -> PrestoDOM.prepareScreen screen cb json)

showScreen :: forall action state retType a. Show action => Loggable action => Screen action state retType -> Flow a retType
showScreen screen = do
  json <- getLogFields
  doAff $ PrestoDOM2.showScreen (mapToScopedScreen screen) json

showScreenWithNameSpace :: forall action state retType a. Show action => Loggable action => ScopedScreen action state retType -> Flow a retType
showScreenWithNameSpace screen = do
  json <- getLogFields
  doAff $ PrestoDOM2.showScreen screen json

runController :: forall action state retType a. Show action => Loggable action => Controller action state retType -> Flow a retType
runController controller = do
  json <- getLogFields
  doAff $ PrestoDOM2.runController controller json

updateScreen :: forall action state retType a. Show action => Loggable action => Screen action state retType -> Flow a Unit
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
