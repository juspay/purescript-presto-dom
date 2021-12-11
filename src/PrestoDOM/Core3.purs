module PrestoDOM.Core3 where
  
import Prelude
import Data.Either (Either(..), either, hush)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Foldable (for_)
import Data.Tuple (Tuple(..), fst)
import Data.Traversable (traverse)
import Effect (Effect)
import Effect.Aff (Canceler, effectCanceler, Aff)
import Effect.Class (liftEffect)
import Effect.Exception (Error)
import Effect.Uncurried as EFn
import FRP.Behavior (sample_, unfold)
import FRP.Event (EventIO, subscribe)
import Foreign.Generic (encode, decode, class Decode)
import Effect.Ref as Ref
import Foreign (Foreign, unsafeToForeign)
import Foreign.Object (Object)
import PrestoDOM.Types.Core (class Loggable, PrestoWidget(..), Prop, ScopedScreen, Controller, ScreenBase)
import PrestoDOM.Utils (continue, logAction)
import Tracker (trackScreen)
import Tracker.Labels as L
import Tracker.Types (Level(..), Screen(..)) as T
import Control.Alt ((<|>))
import FRP.Event as E
import Foreign (Foreign, unsafeToForeign)
import Foreign.Generic (encode, decode, class Decode)
import Control.Monad.Except(runExcept)
import Halogen.VDom (Step, VDom, VDomSpec(..), buildVDom, extract, step)


foreign import startedToPrepare :: EFn.EffectFn2 String String Unit

foreign import getAndSetEventFromState :: forall a. EFn.EffectFn3 String String (Effect (EventIO a)) (EventIO a)

foreign import getCurrentActivity :: Effect String

foreign import cachePushEvents :: String -> String -> Effect Unit -> String -> Effect Unit

foreign import isScreenPushActive :: String -> String -> String -> Effect Boolean

foreign import setScreenPushActive :: String -> String -> String -> Effect Unit
foreign import cancelExistingActions :: EFn.EffectFn2 String String Unit
foreign import saveCanceller :: EFn.EffectFn3 String String (Effect Unit) Unit
foreign import getCurrentActivity :: Effect String
foreign import setUpBaseState :: String -> Foreign -> Effect Unit
foreign import render :: EFn.EffectFn1 String Unit

sanitiseNamespace :: Maybe String -> Effect String
sanitiseNamespace maybeNS = do
  let ns = fromMaybe "default" maybeNS
  pure ns

initUIWithNameSpace :: String -> Maybe String -> Effect Unit
initUIWithNameSpace namespace id = do
  setUpBaseState namespace $ encode id
  EFn.runEffectFn1 render namespace


joinCancellers :: Array (Effect Unit) -> Effect Unit -> Effect Unit
joinCancellers cancellers canceller = do
  _ <- traverse identity cancellers
  canceller

controllerActions :: forall action state returnType a
  . Show action => Loggable action
  => EventIO action
  -> ScreenBase action state returnType (parent :: Maybe String| a)
  -> (Object Foreign)
  -> (state -> Effect Unit)
  -> (Either Error returnType -> Effect Unit)
  -> Effect Canceler
controllerActions {event, push} {initialState, eval, name, globalEvents, parent} json emitter cb = do
  ns <- sanitiseNamespace parent
  _ <- EFn.runEffectFn2 cancelExistingActions name ns
  timerRef <- Ref.new Nothing
  let stateBeh = unfold execEval event { previousAction : Nothing, currentAction : Nothing, eitherState : (continue initialState)}
  canceller <- sample_ stateBeh event `subscribe` (\a -> either (onExit a.previousAction a.currentAction timerRef) (onStateChange a.previousAction a.currentAction timerRef) a.eitherState)
  activityId <- getCurrentActivity
  _ <- setScreenPushActive ns name activityId
  cancellers <- traverse registerEvents globalEvents
  EFn.runEffectFn3 saveCanceller name ns $ joinCancellers cancellers canceller
  pure $ effectCanceler (EFn.runEffectFn2 cancelExistingActions name ns)
    where
      onStateChange previousAction currentAction timerRef (Tuple state cmds) = do
        result <- emitter state
        _ <- for_ cmds (\effAction -> effAction >>= push)
        logAction timerRef previousAction currentAction false json -- debounce
      onExit previousAction currentAction timerRef (Tuple st ret) = do
        EFn.runEffectFn2 cancelExistingActions name =<< sanitiseNamespace parent
        result <- fromMaybe (pure unit) $ st <#> emitter
        cb $ Right ret
        logAction timerRef previousAction currentAction true json-- logNow
      registerEvents =
        (\f -> f push)
      execEval action st =
        { previousAction : st.currentAction
        , currentAction : Just action
        , eitherState : (st.eitherState >>= (eval action <<< fst))
        }

getEventIO :: forall action. String -> Maybe String -> Effect (EventIO action)
getEventIO screenName parent = do
  ns <- sanitiseNamespace parent
  {event, push} <- Efn.runEffectFn3 getAndSetEventFromState ns screenName E.create
  activityId <- getCurrentActivity
  pure $ {event, push : createPushQueue ns screenName push activityId}

createPushQueue :: forall action. String -> String -> (action -> Effect Unit) -> String -> action -> Effect Unit
createPushQueue namespace screenName push activityId action = do
  isScreenPushActive namespace screenName activityId >>=
    if _
      then push action
      else cachePushEvents namespace screenName (push action) activityId

prepareScreen :: forall action state returnType
  . Show action => Loggable action
  => ScopedScreen action state returnType
  -> Object Foreign
  -> Aff Unit
prepareScreen screen@{name, parent, view} json = do
  if not (canPreRender unit)
    then pure unit
    else do 
      ns <- liftEffect $ sanitiseNamespace parent
      liftEffect <<< setUpBaseState ns $ encode (Nothing :: Maybe String )
      liftEffect $ EFn.runEffectFn2 startedToPrepare ns name
      liftEffect $ trackScreen T.Screen T.Info L.PRERENDERED_SCREEN "pre_rendering_started" screen.name json
      let myDom = view (\_ -> pure unit) screen.initialState
