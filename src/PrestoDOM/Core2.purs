module PrestoDOM.Core2 where

import Prelude

import Data.Either (Either(..), either)
import Data.Foldable (for_)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Newtype (un)
import Data.Traversable (traverse)
import Data.Tuple (Tuple(..), fst)
import Effect (Effect)
import Effect.Aff (Canceler, effectCanceler)
import Effect.Exception (Error)
import Effect.Ref as Ref
import Effect.Uncurried as EFn
import FRP.Behavior (sample_, unfold)
import FRP.Event (EventIO, subscribe)
import FRP.Event as E
import Foreign (Foreign)
import Foreign.Generic (encode)
import Halogen.VDom (Step, VDom, VDomSpec(..), buildVDom, extract, step)
import Halogen.VDom.DOM.Prop (buildProp)
import Halogen.VDom.Thunk (Thunk, buildThunk)
import Halogen.VDom.Types (FnObject)
import PrestoDOM.Events (manualEventsName)
import PrestoDOM.Types.Core (class Loggable, PrestoWidget(..), Prop, ScopedScreen)
import PrestoDOM.Utils (continue, logAction)
import Tracker (trackScreen)
import Tracker.Labels as L
import Tracker.Types (Level(..), Screen(..)) as T

foreign import setUpBaseState :: String -> Foreign -> Effect Unit
foreign import insertDom :: forall a. EFn.EffectFn4 String String a Boolean Unit
foreign import storeMachine :: forall a b . EFn.EffectFn3 (Step a b) String String Unit
foreign import getLatestMachine :: forall a b . EFn.EffectFn2 String String (Step a b)
foreign import isInStack :: EFn.EffectFn2 String String Boolean
foreign import isCached :: EFn.EffectFn2 String String Boolean
foreign import cancelExistingActions :: EFn.EffectFn2 String String Unit
foreign import saveCanceller :: EFn.EffectFn3 String String (Effect Unit) Unit
foreign import callAnimation :: EFn.EffectFn3 String String Boolean Unit
foreign import checkAndDeleteFromHideAndRemoveStacks :: EFn.EffectFn2 String String Unit
foreign import terminateUIImpl :: EFn.EffectFn1 String Unit
foreign import setToTopOfStack :: EFn.EffectFn2 String String Unit
foreign import addToCachedList :: EFn.EffectFn2 String String Unit
foreign import makeScreenVisible :: EFn.EffectFn2 String String Unit

foreign import addChild :: forall a b. String -> EFn.EffectFn3 a b Int Unit
foreign import addProperty :: forall a b. String -> EFn.EffectFn3 String a b Unit
foreign import cancelBehavior :: EFn.EffectFn1 String Unit
foreign import createPrestoElement :: forall a. Effect a
foreign import moveChild :: forall a b. String -> EFn.EffectFn3 a b Int Unit
foreign import removeChild :: forall a b. String -> EFn.EffectFn3 a b Int Unit
foreign import replaceView :: forall a. String -> EFn.EffectFn2 a (Array String) Unit
foreign import updateProperty ∷ forall a b. String -> EFn.EffectFn3 String a b Unit

foreign import setManualEvents :: forall a b. String -> String -> a -> b -> Effect Unit
foreign import fireManualEvent :: forall a. String -> a -> Effect Unit

sanitiseNamespace :: Maybe String -> String
sanitiseNamespace = fromMaybe "default"

patchAndRun :: forall w i. String -> Maybe String -> VDom (Array (Prop i)) w -> Effect Unit
patchAndRun screenName namespace myDom = do
  machine <- EFn.runEffectFn2 getLatestMachine screenName (sanitiseNamespace namespace)
  newMachine <- EFn.runEffectFn2 step (machine) (myDom)
  EFn.runEffectFn3 storeMachine newMachine screenName (sanitiseNamespace namespace)

spec
  :: String 
  -> String
  -> VDomSpec (Array (Prop (Effect Unit))) (Thunk PrestoWidget (Effect Unit))
spec namespace screen =
  VDomSpec
    { buildWidget : buildThunk (un PrestoWidget)
    , buildAttributes: buildProp identity
    , fnObject : fun
    }
  where
  fun :: FnObject
  fun = { replaceView : replaceView namespace
        , setManualEvents : setManualEvents namespace screen
        , addChild : addChild namespace
        , moveChild : moveChild namespace
        , removeChild : removeChild namespace
        , createPrestoElement
        , addProperty : addProperty namespace
        , updateProperty : updateProperty namespace
        , cancelBehavior
        , manualEventsName : manualEventsName unit
        }


controllerActions :: forall action state returnType
  . Show action => Loggable action
  => EventIO action
  -> ScopedScreen action state returnType
  -> (Either Error returnType -> Effect Unit)
  -> Effect Canceler
controllerActions {event, push} {initialState, view, eval, name, globalEvents, parent} cb  = do
  timerRef <- Ref.new Nothing
  let stateBeh = unfold execEval event { previousAction : Nothing, currentAction : Nothing, eitherState : (continue initialState)}
  canceller <- sample_ stateBeh event `subscribe` (\a -> either (onExit a.previousAction a.currentAction timerRef) (onStateChange a.previousAction a.currentAction timerRef) a.eitherState)
  cancellers <- traverse registerEvents globalEvents
  EFn.runEffectFn3 saveCanceller name (sanitiseNamespace parent) $ joinCancellers cancellers canceller
  pure $ effectCanceler (EFn.runEffectFn2 cancelExistingActions name (sanitiseNamespace parent))
    where
      onStateChange previousAction currentAction timerRef (Tuple state cmds) = do
        result <- patchAndRun name parent (view push state)
          *> for_ cmds (\effAction -> effAction >>= push)
        _ <- logAction timerRef previousAction currentAction false -- debounce
        pure result
      onExit previousAction currentAction timerRef (Tuple st ret) = do
        result <- 
          case st of
            Just s -> patchAndRun name parent (view push s) *> (EFn.runEffectFn2 cancelExistingActions name (sanitiseNamespace parent) >>= \_ -> cb $ Right ret)
            Nothing -> EFn.runEffectFn2 cancelExistingActions name (sanitiseNamespace parent) >>= \_ -> cb $ Right ret
        _ <- logAction timerRef previousAction currentAction true -- logNow
        pure result
      registerEvents =
        (\f -> f push)
      execEval action st = 
        { previousAction : st.currentAction
        , currentAction : Just action
        , eitherState : (st.eitherState >>= (eval action <<< fst))
        }

-- initUIWithNameSpace
-- getId and namespace for the same
-- createState in local state variable for the same

initUIWithNameSpace :: String -> Maybe String -> Effect Unit
initUIWithNameSpace namespace id =
  setUpBaseState namespace $ encode id

initUIWithScreen :: 
  forall action state returnType. 
  String -> Maybe String -> ScopedScreen action state returnType -> Effect Unit
initUIWithScreen namespace id screen = do
  initUIWithNameSpace namespace id
  let myDom = screen.view (\_ -> pure unit) screen.initialState
  machine <- EFn.runEffectFn1 (buildVDom (spec (sanitiseNamespace screen.parent) screen.name)) myDom
  EFn.runEffectFn4 insertDom (fromMaybe "default" screen.parent) screen.name (extract machine) false

-- runScreen
-- check if namespace exists
-- else check if screen exists
-- yes -> remove all screens above from stack
--     -> Trigger patch and run for current screen
--     -> trigger exitB animation of top screen on the stack (B != A)
--     -> trigger entryB animation for current screen (B != A)
--     -> onAnimationEnd remove previous top of stack (B != A)
-- no  -> add screen on top of stack
runScreen :: forall action state returnType
  . Show action => Loggable action
  => ScopedScreen action state returnType
  -> (Either Error returnType -> Effect Unit)
  -> Effect Canceler
runScreen {initialState, view, eval, name, globalEvents, parent} cb = do
  EFn.runEffectFn2 checkAndDeleteFromHideAndRemoveStacks name (sanitiseNamespace parent)
  {event, push} <- E.create
  _ <- trackScreen T.Screen T.Info L.UPCOMING_SCREEN "screen" name
  let myDom = view push initialState
  check <- EFn.runEffectFn2 isInStack name (sanitiseNamespace parent) <#> not
  EFn.runEffectFn2 setToTopOfStack (sanitiseNamespace parent) name
  if check
    then do
      machine <- EFn.runEffectFn1 (buildVDom (spec (sanitiseNamespace parent) name)) myDom
      EFn.runEffectFn4 insertDom (fromMaybe "default" parent) name (extract machine) false
      EFn.runEffectFn3 storeMachine machine name (sanitiseNamespace parent)
    else do
      patchAndRun name parent myDom
      EFn.runEffectFn2 makeScreenVisible (sanitiseNamespace parent) name
      EFn.runEffectFn3 callAnimation name (sanitiseNamespace parent) false
  controllerActions {event, push} {initialState, view, eval, name, globalEvents, parent} cb

-- showScreen
-- check if namespace exists
-- check if screen was rendered before
-- yes -> patch and run
--     -> startAnimation entry animation (B != A)
--     -> trigger exitAnimation, if previous screen was show screen (B != A)
--     -> onAnimationEnd remove turn visibility to gone for previous show screen (B != A)
-- no  -> add screen into cache list
showScreen :: forall action state returnType
  . Show action => Loggable action
  => ScopedScreen action state returnType
  -> (Either Error returnType -> Effect Unit)
  -> Effect Canceler
showScreen {initialState, view, eval, name, globalEvents, parent} cb = do
  EFn.runEffectFn2 checkAndDeleteFromHideAndRemoveStacks name (sanitiseNamespace parent)
  {event, push} <- E.create
  _ <- trackScreen T.Screen T.Info L.UPCOMING_SCREEN "overlay" name
  let myDom = view push initialState
  check <- EFn.runEffectFn2 isCached name (sanitiseNamespace parent) <#> not
  EFn.runEffectFn2 addToCachedList (sanitiseNamespace parent) name
  if check
    then do
      machine <- EFn.runEffectFn1 (buildVDom (spec (sanitiseNamespace parent) name)) myDom
      EFn.runEffectFn4 insertDom (fromMaybe "default" parent) name (extract machine) true
      EFn.runEffectFn3 storeMachine machine name (sanitiseNamespace parent)
    else do
      patchAndRun name parent myDom
      EFn.runEffectFn2 makeScreenVisible (sanitiseNamespace parent) name
      EFn.runEffectFn3 callAnimation name (sanitiseNamespace parent) true
  controllerActions {event, push} {initialState, view, eval, name, globalEvents, parent} cb

updateScreen :: forall action state returnType
     . Show action => Loggable action => ScopedScreen action state returnType
    -> Effect Unit
updateScreen { initialState, view, eval, name , globalEvents, parent } = do
  let myDom = view (\_ -> pure unit ) initialState
  patchAndRun name parent myDom

terminateUI :: String -> Effect Unit
terminateUI nameSpace = EFn.runEffectFn1 terminateUIImpl nameSpace

joinCancellers :: Array (Effect Unit) -> Effect Unit -> Effect Unit
joinCancellers cancellers canceller = do
  _ <- traverse identity cancellers
  canceller

processEvent :: forall a. String -> a -> Effect Unit
processEvent = fireManualEvent
