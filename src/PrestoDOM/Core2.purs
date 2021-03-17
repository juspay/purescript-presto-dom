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
import Effect.Uncurried (EffectFn3, runEffectFn2, runEffectFn3)
import Effect.Uncurried as EFn
import Effect.Uncurried as Efn
import FRP.Behavior (sample_, unfold)
import FRP.Event (EventIO, subscribe)
import FRP.Event as E
import Foreign (Foreign)
import Foreign.Generic (encode)
import Halogen.VDom (Step, VDom, VDomSpec(..), buildVDom, extract, step)
import Halogen.VDom.DOM.Prop (buildProp)
import Halogen.VDom.Thunk (Thunk, buildThunk)
import Halogen.VDom.Types (FnObject)
import PrestoDOM.Core (addChild, addProperty, cancelBehavior, createPrestoElement, joinCancellers, moveChild, removeChild, replaceView, updateProperty)
import PrestoDOM.Events (manualEventsName, setManualEvents)
import PrestoDOM.Types.Core (class Loggable, PrestoWidget(..), Prop, ScopedScreen)
import PrestoDOM.Utils (continue, logAction)
import Tracker (trackScreen)
import Tracker.Labels as L
import Tracker.Types (Level(..), Screen(..)) as T

foreign import setUpBaseState :: String -> Foreign -> Effect Unit
foreign import insertDom :: forall a. EffectFn3 String String a Unit
foreign import storeMachine :: forall a b . EFn.EffectFn3 (Step a b) String String Unit
foreign import getLatestMachine :: forall a b . EFn.EffectFn2 String String (Step a b)
foreign import isInStack :: EFn.EffectFn2 String String Boolean
foreign import isCached :: EFn.EffectFn2 String String Boolean
foreign import cancelExistingActions :: EFn.EffectFn2 String String Unit
foreign import saveCanceller :: EFn.EffectFn3 String String (Effect Unit) Unit
foreign import callAnimation :: EFn.EffectFn3 String String Boolean Unit
foreign import checkAndDeleteFromHideAndRemoveStacks :: EFn.EffectFn2 String String Unit
foreign import terminateUIImpl :: Efn.EffectFn1 String Unit
foreign import setToTopOfStack :: Efn.EffectFn2 String String Unit
foreign import makeScreenVisible :: Efn.EffectFn2 String String Unit

sanitiseNamespace :: Maybe String -> String
sanitiseNamespace = fromMaybe "default"

patchAndRun :: forall w i. String -> Maybe String -> VDom (Array (Prop i)) w -> Effect Unit
patchAndRun screenName namespace myDom = do
  machine <- EFn.runEffectFn2 getLatestMachine screenName (sanitiseNamespace namespace)
  newMachine <- EFn.runEffectFn2 step (machine) (myDom)
  EFn.runEffectFn3 storeMachine newMachine screenName (sanitiseNamespace namespace)

spec
  :: Maybe String
  -> VDomSpec (Array (Prop (Effect Unit))) (Thunk PrestoWidget (Effect Unit))
spec screen =
  VDomSpec
    { buildWidget : buildThunk (un PrestoWidget)
    , buildAttributes: buildProp identity
    , fnObject : fun
    }
  where
  fun :: FnObject
  fun = { replaceView
        , setManualEvents : setManualEvents screen
        , addChild
        , moveChild
        , removeChild
        , createPrestoElement
        , addProperty
        , updateProperty
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
  runEffectFn3 saveCanceller name (sanitiseNamespace parent) $ joinCancellers cancellers canceller
  pure $ effectCanceler (runEffectFn2 cancelExistingActions name (sanitiseNamespace parent))
    where
      onStateChange previousAction currentAction timerRef (Tuple state cmds) = do
        result <- patchAndRun name parent (view push state)
          *> for_ cmds (\effAction -> effAction >>= push)
        _ <- logAction timerRef previousAction currentAction false -- debounce
        pure result
      onExit previousAction currentAction timerRef (Tuple st ret) = do
        result <- 
          case st of
            Just s -> patchAndRun name parent (view push s) *> (runEffectFn2 cancelExistingActions name (sanitiseNamespace parent) >>= \_ -> cb $ Right ret)
            Nothing -> runEffectFn2 cancelExistingActions name (sanitiseNamespace parent) >>= \_ -> cb $ Right ret
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
  Efn.runEffectFn2 checkAndDeleteFromHideAndRemoveStacks name (sanitiseNamespace parent)
  {event, push} <- E.create
  _ <- trackScreen T.Screen T.Info L.UPCOMING_SCREEN "screen" name
  let myDom = view push initialState
  Efn.runEffectFn2 setToTopOfStack (sanitiseNamespace parent) name
  Efn.runEffectFn2 isInStack name (sanitiseNamespace parent) <#> not
    >>= if _
      then do
        machine <- EFn.runEffectFn1 (buildVDom (spec Nothing)) myDom
        EFn.runEffectFn3 insertDom (fromMaybe "default" parent) name (extract machine)
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
  Efn.runEffectFn2 checkAndDeleteFromHideAndRemoveStacks name (sanitiseNamespace parent)
  {event, push} <- E.create
  _ <- trackScreen T.Screen T.Info L.UPCOMING_SCREEN "overlay" name
  let myDom = view push initialState
  runEffectFn2 isCached name (sanitiseNamespace parent)
    >>= if _
      then do
        machine <- EFn.runEffectFn1 (buildVDom (spec Nothing)) myDom
        EFn.runEffectFn3 insertDom (fromMaybe "default" parent) name (extract machine)
        EFn.runEffectFn3 storeMachine machine name (sanitiseNamespace parent)
      else do
        patchAndRun name parent myDom
        EFn.runEffectFn3 callAnimation name (sanitiseNamespace parent) false
  controllerActions {event, push} {initialState, view, eval, name, globalEvents, parent} cb


terminateUI :: String -> Effect Unit
terminateUI nameSpace = Efn.runEffectFn1 terminateUIImpl nameSpace