
module PrestoDOM.Core.Types.Language.Flow where

import Prelude

import Data.Maybe (Maybe(..))
import Effect.Class (liftEffect)
import Presto.Core.Flow (Flow, doAff)
import Presto.Core.Types.Language.Flow(getLogFields)
import Effect(Effect)
import PrestoDOM.Core as PrestoDOM
import PrestoDOM.Types.Core (class Loggable, ScopedScreen, Controller, Screen)
import PrestoDOM.Utils (addTime2)

initUI :: forall a. Flow a Unit
initUI  = do
  ns <- doAff do liftEffect $ PrestoDOM.sanitiseNamespace $ Just "default"
  doAff do liftEffect $ PrestoDOM.initUIWithNameSpace ns Nothing

initUIWithNameSpace :: String -> Maybe String -> Effect Unit
initUIWithNameSpace = PrestoDOM.initUIWithNameSpace

-- deprecated
initUIWithScreen
  :: forall action state a
   . Screen action state Unit
  -> Flow a Unit
initUIWithScreen screen =
  doAff do PrestoDOM.initUIWithScreen "default" Nothing (mapToScopedScreen screen)

runScreen :: forall action state retType a. Show action => Loggable action => Screen action state retType -> Flow a retType
runScreen screen = do
  _ <- doAff $ liftEffect $ addTime2 "Process_Eval_End"
  _ <- doAff $ liftEffect $ addTime2 "Render_runScreen_Start"
  json <- getLogFields
  doAff $ PrestoDOM.runScreen (mapToScopedScreen screen) json

runScreenWithNameSpace :: forall action state retType a. Show action => Loggable action => ScopedScreen action state retType -> Flow a retType
runScreenWithNameSpace screen = do
  _ <- doAff $ liftEffect $ addTime2 "Process_Eval_End"
  _ <- doAff $ liftEffect $ addTime2 "Render_runScreen_Start"
  json <- getLogFields
  doAff $ PrestoDOM.runScreen screen json

prepareScreenWithNameSpace
  :: forall action state retType a.  Show action => Loggable action => ScopedScreen action state retType -> Flow a Unit
prepareScreenWithNameSpace screen = do
  json <- getLogFields
  doAff $ PrestoDOM.prepareScreen screen json

prepareScreen
  :: forall action state retType a. Show action => Loggable action => Screen action state retType -> Flow a Unit
prepareScreen screen = do
  json <- getLogFields
  doAff $ PrestoDOM.prepareScreen (mapToScopedScreen screen) json

showScreen :: forall action state retType a. Show action => Loggable action => Screen action state retType -> Flow a retType
showScreen screen = do
  json <- getLogFields
  doAff $ PrestoDOM.showScreen (mapToScopedScreen screen) json

showScreenWithNameSpace :: forall action state retType a. Show action => Loggable action => ScopedScreen action state retType -> Flow a retType
showScreenWithNameSpace screen = do
  json <- getLogFields
  doAff $ PrestoDOM.showScreen screen json

runController :: forall action state retType a. Show action => Loggable action => Controller action state retType -> Flow a retType
runController controller = do
  json <- getLogFields
  doAff $ PrestoDOM.runController controller json

updateScreen :: forall action state retType a. Show action => Loggable action => Screen action state retType -> Flow a Unit
updateScreen screen = doAff do liftEffect $ PrestoDOM.updateScreen (mapToScopedScreen screen)

updateScreenWithNameSpace :: forall action state retType a. Show action => Loggable action => ScopedScreen action state retType -> Flow a Unit
updateScreenWithNameSpace screen = doAff do liftEffect $ PrestoDOM.updateScreen screen

mapToScopedScreen :: forall action state retType. Screen action state retType -> ScopedScreen action state retType
mapToScopedScreen screen =
  { initialState : screen.initialState
  , name : screen.name
  , globalEvents : screen.globalEvents
  , view : screen.view
  , eval : screen.eval
  , parent : Nothing
  }

terminateUI :: forall a. Flow a Unit
terminateUI = doAff do liftEffect $ PrestoDOM.terminateUI Nothing