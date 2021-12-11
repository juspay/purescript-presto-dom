module Core3 where
  
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

foreign import setScreenPushActive :: String -> String -> String -> Effect Unit
foreign import cancelExistingActions :: EFn.EffectFn3 String String String Unit
foreign import saveCanceller :: EFn.EffectFn4 String String String (Effect Unit) Unit
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
  activityId <- getCurrentActivity
  _ <- EFn.runEffectFn3 cancelExistingActions name ns activityId
  timerRef <- Ref.new Nothing
  let stateBeh = unfold execEval event { previousAction : Nothing, currentAction : Nothing, eitherState : (continue initialState)}
  canceller <- sample_ stateBeh event `subscribe` (\a -> either (onExit a.previousAction a.currentAction timerRef ns activityId) (onStateChange a.previousAction a.currentAction timerRef) a.eitherState)

  _ <- setScreenPushActive ns name activityId
  cancellers <- traverse registerEvents globalEvents
  EFn.runEffectFn4 saveCanceller name ns activityId $ joinCancellers cancellers canceller
  pure $ effectCanceler (EFn.runEffectFn3 cancelExistingActions name ns activityId)
    where
      onStateChange previousAction currentAction timerRef (Tuple state cmds) = do
        result <- emitter state
        _ <- for_ cmds (\effAction -> effAction >>= push)
        logAction timerRef previousAction currentAction false json -- debounce
      onExit previousAction currentAction timerRef ns activityId (Tuple st ret) = do
        EFn.runEffectFn3 cancelExistingActions name ns activityId
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