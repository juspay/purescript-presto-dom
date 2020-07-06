module PrestoDOM.Core
   ( runScreen
   , showScreen
   , prepareScreen
   , initUI
   , initUIWithScreen
   , mapDom
   , terminateUI
   , _domAll
   ) where

import Prelude

import Data.Either (Either(..), either)
import Data.Foldable (for_)
import Data.Maybe (Maybe(..))
import Data.Newtype (un)
import Data.Traversable (traverse)
import Data.Tuple (Tuple(..), fst)
import Effect (Effect)
import Effect.Aff (Canceler, Error, effectCanceler, nonCanceler)
import Effect.Uncurried as EFn
import FRP.Behavior (sample_, unfold)
import FRP.Event (subscribe)
import FRP.Event as E
import Foreign.Object as Object
import Halogen.VDom (Namespace(..), VDomSpec(VDomSpec), buildVDom)
import Halogen.VDom.DOM.Prop (Prop, buildProp)
import Halogen.VDom.Machine (Step, step, extract)
import Halogen.VDom.Thunk (Thunk, buildThunk)
import Halogen.VDom.Types (FnObject)
import PrestoDOM.Events (setManualEvents, manualEventsName, setManualEventsName)
import PrestoDOM.Types.Core (ElemName(..), VDom(Elem), PrestoDOM, Screen, Namespace, PrestoWidget(..), class Loggable)
import PrestoDOM.Utils (continue, logAction)
import Tracker (trackScreen)
import Tracker.Types (Level(..), Screen(..)) as T
import Tracker.Labels (Label(..)) as L
import Web.DOM.Document (Document) as DOM
import Effect.Ref as Ref

foreign import terminateUI :: Effect Unit

foreign import emitter
    :: forall a
     . EFn.EffectFn1
        a
        Unit

foreign import getLatestMachine
    :: forall a b
     . EFn.EffectFn1
        (Maybe Namespace)
        (Step a b)

foreign import storeMachine
    :: forall a b
     . EFn.EffectFn2
        (Step a b)
        (Maybe Namespace)
        Unit

foreign import cacheMachine
    :: forall a b
     . EFn.EffectFn2
        (Step a b)
        String
        Unit

foreign import getCachedMachineImpl
    :: forall a b
     . EFn.EffectFn3
        ((Step a b) -> Maybe (Step a b))
        (Maybe (Step a b))
        String
        (Maybe (Step a b))

foreign import getRootNode :: Effect DOM.Document

foreign import setRootNode
    :: forall a
     . EFn.EffectFn1
        (Maybe a)
        DOM.Document

foreign import insertDom :: forall a b. EFn.EffectFn2 a b Unit

foreign import prepareDom
  :: forall  a
   . EFn.EffectFn3 (Unit -> Effect Unit) String a Unit

foreign import addScreenImpl :: forall a b. EFn.EffectFn3 a b String Unit

foreign import updateDom :: forall a b. EFn.EffectFn2 a b Unit

foreign import processWidget :: Effect Unit

foreign import _domAll :: forall a b. a -> b

foreign import setScreenImpl :: EFn.EffectFn1
        String
        Unit

foreign import callAnimation :: EFn.EffectFn1
        String
        Unit

foreign import callAnimation_ :: String -> Boolean -> Effect Unit

foreign import saveScreenNameImpl
    :: EFn.EffectFn1
        (Maybe Namespace)
        Boolean


foreign import cacheScreenImpl
    :: EFn.EffectFn1
        (Maybe Namespace)
        Boolean

 -- | This function is for maintaining backward compatibility between Mystique
 -- | and purescript-presto-dom. It'll also make sure that prepareScreen
 -- | only gets executed in Android.
 -- |
foreign import canPreRender :: Unit -> Boolean
foreign import exitUI :: Int -> Effect Unit
foreign import getScreenNumber :: Effect Int
foreign import cacheCanceller :: Int -> Effect Unit -> Effect Unit

foreign import replaceView :: forall a. EFn.EffectFn1 a Unit
foreign import addChild :: forall a b.  EFn.EffectFn3 a b Int Unit
foreign import moveChild :: forall a b. EFn.EffectFn3 a b Int Unit
foreign import removeChild :: forall a b. EFn.EffectFn3 a b Int Unit
foreign import createPrestoElement :: forall a. Effect a
foreign import addProperty :: ∀ a b. EFn.EffectFn3 String a b Unit
foreign import updateProperty ∷ ∀ a b. EFn.EffectFn3 String a b Unit
foreign import cancelBehavior :: EFn.EffectFn1 String Unit

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

logger :: forall a. (a → Effect Unit)
logger a = do
    _ <- EFn.runEffectFn1 emitter a
    pure unit

getCachedMachine :: ∀ a b. String → Effect (Maybe (Step a b))
getCachedMachine = EFn.runEffectFn3 getCachedMachineImpl Just Nothing

patchAndRun :: forall w i. Maybe Namespace -> VDom (Array (Prop i)) w -> Effect Unit
patchAndRun screenName myDom = do
  machine <- EFn.runEffectFn1 getLatestMachine screenName
  newMachine <- EFn.runEffectFn2 step (machine) (myDom)
  EFn.runEffectFn2 storeMachine newMachine screenName

initUIWithScreen
  :: forall action state
   . Screen action state Unit
  -> (Either Error Unit -> Effect Unit)
  -> Effect Canceler
initUIWithScreen  { initialState, view, eval } cb = do
  { event, push } <- E.create
  let myDom = view push initialState
  root <- EFn.runEffectFn1 setRootNode Nothing
  machine <- EFn.runEffectFn1 (buildVDom (spec Nothing)) myDom
  EFn.runEffectFn2 insertDom root (extract machine)
  cb $ Right unit
  pure nonCanceler

initUI
  :: (Either Error Unit -> Effect Unit)
  -> Effect Canceler
initUI cb = do
  root <- EFn.runEffectFn1 setRootNode Nothing
  machine <- EFn.runEffectFn1 (buildVDom (spec Nothing)) view
  EFn.runEffectFn2 insertDom root (extract machine)
  cb $ Right unit
  pure nonCanceler
    where
          view = Elem Nothing (ElemName "linearLayout") [] []

-- | holds two implementation
-- | 1. runScreen
-- | 2. showScreen
-- |
-- | runScreen : can creates new screen or reuse cached screen and render it
-- |   replacing previous screen
-- | showScreen : creates new screen on top of previous screen
-- |
runScreenImpl
    :: forall action state returnType
     . Show action => Loggable action => Boolean
    -> Screen action state returnType
    -> (Either Error returnType -> Effect Unit)
    -> Effect Canceler
runScreenImpl cache { initialState, view, eval, name , globalEvents } cb = do
  { event, push } <- E.create
  _ <- trackScreen T.Screen T.Info L.UPCOMING_SCREEN (if cache then "overlay" else "screen") name
  screenNumber <- getScreenNumber
  _ <- setScreen name
  let myDom = view push initialState
  patch <- if cache
               then checkCachedScreen screenName
               else compareScreen screenName

  case patch of
    false ->
      (if cache
        then pure Nothing
        else getCachedMachine name) >>=
        case _ of
          Just machine -> do
            root <- getRootNode
            EFn.runEffectFn3 addScreenImpl root  (extract machine) name
            processWidget
            _ <- EFn.runEffectFn1 callAnimation "B"
            newMachine <- EFn.runEffectFn2 step (machine) (myDom)
            EFn.runEffectFn2 storeMachine newMachine screenName
          Nothing -> do
            root <- getRootNode                                       -- window.N
            machine <- EFn.runEffectFn1 (buildVDom (spec Nothing)) myDom -- HalogenVDom Cycle
            EFn.runEffectFn2 storeMachine machine screenName          -- Cache Dom to window
            if cache                                                  -- Show/Run
                then EFn.runEffectFn2 updateDom root (extract machine)-- Add to screen cache
                else EFn.runEffectFn2 insertDom root (extract machine)-- Add to screen stack
            processWidget                                             -- run widgets added by halogen-vdom to window.widgets
    true -> do
      callAnimation_ name cache
      patchAndRun screenName myDom
  timerRef <- Ref.new Nothing
  let stateBeh = unfold execEval event { previousAction : Nothing, currentAction : Nothing, eitherState : (continue initialState)}
  canceller <- sample_ stateBeh event `subscribe` (\a -> either (onExit screenNumber push a.previousAction a.currentAction timerRef) (onStateChange push a.previousAction a.currentAction timerRef) a.eitherState)
  cancellers <- traverse (registerEvents push)  globalEvents
  _ <- cacheCanceller screenNumber $ joinCancellers cancellers canceller
  pure $ effectCanceler (exitUI screenNumber)
    where
          screenName = Just $ Namespace name
          onStateChange push previousAction currentAction timerRef (Tuple state cmds) = do
              result <- patchAndRun screenName (view push state)
                *> for_ cmds (\effAction -> effAction >>= push)
              _ <- logAction timerRef previousAction currentAction false -- debounce
              pure result
          onExit scn push previousAction currentAction timerRef (Tuple st ret) = do
              result <- case st of
                   Just s -> patchAndRun screenName (view push s) *> (exitUI scn >>= \_ -> cb $ Right ret)
                   Nothing -> exitUI scn >>= \_ -> cb $ Right ret
              _ <- logAction timerRef previousAction currentAction true -- logNow
              pure result
          registerEvents push =
            (\f -> f push)
          execEval action st = {
                  previousAction : st.currentAction
                , currentAction : Just action
                , eitherState : (st.eitherState >>= (eval action <<< fst))
                }

joinCancellers :: Array (Effect Unit) -> Effect Unit -> Effect Unit
joinCancellers cancellers canceller = do
  _ <- traverse identity cancellers
  canceller

runScreen
    :: forall action state returnType
     . Show action => Loggable action => Screen action state returnType
    -> (Either Error returnType -> Effect Unit)
    -> Effect Canceler
runScreen scr st = do
  let { initialState, view, eval, name , globalEvents } = scr
  result <- runScreenImpl false scr st
  trackScreen T.Screen T.Info L.CURRENT_SCREEN "screen" name
  pure result

showScreen
    :: forall action state returnType
     . Show action => Loggable action => Screen action state returnType
    -> (Either Error returnType -> Effect Unit)
    -> Effect Canceler
showScreen scr st = do
  let { initialState, view, eval, name , globalEvents } = scr
  result <- runScreenImpl true scr st
  trackScreen T.Screen T.Info L.CURRENT_SCREEN "overlay" name
  pure result

-- | Function is responsible for Pre-rendering. Intended to be called ahead of
-- | time, it'll create and cache screen for future use.
-- | Currently it's not thread safe for ANDROID, can be used for first screen only in
-- | Initiate
-- |
prepareScreen
  :: forall action state returnType
   . Screen action state returnType
  -> (Either Error Unit -> Effect Unit)
  -> Effect Canceler
prepareScreen { initialState, view, eval, name, globalEvents } cb =
  if not (canPreRender unit)
    then (cb $ Right unit) $> nonCanceler
    else do
      trackScreen T.Screen T.Info L.PRERENDERED_SCREEN "pre_rendering_started" name
      { event, push } <- E.create
      let myDom = view push initialState
      machine <- EFn.runEffectFn1 (buildVDom (spec (Just name))) myDom -- HalogenVDom Cycle
      EFn.runEffectFn2 cacheMachine machine name          -- Cache Dom to window
      EFn.runEffectFn3 prepareDom callBack name (extract machine) -- Create and Cache Screen
      pure nonCanceler
      where
      callBack result = do
        trackScreen T.Screen T.Info L.PRERENDERED_SCREEN "pre_rendering_finished" name
        cb (Right result)

setScreen :: String -> Effect Unit
setScreen = EFn.runEffectFn1 setScreenImpl

compareScreen :: Maybe Namespace -> Effect Boolean
compareScreen screen = do
    bool <- EFn.runEffectFn1 saveScreenNameImpl screen
    pure bool

checkCachedScreen :: Maybe Namespace -> Effect Boolean
checkCachedScreen screen = do
    bool <- EFn.runEffectFn1 cacheScreenImpl screen
    pure bool


mapDom
  :: forall i a b state w
   . ((a -> Effect Unit) -> state -> Object.Object i -> PrestoDOM (Effect Unit) w)
  -> (b -> Effect Unit)
  -> state
  -> (a -> b)
  -> Array (Tuple String i)
  -> PrestoDOM (Effect Unit) w
mapDom view push state actionMap = view (push <<< actionMap) state <<< Object.fromFoldable
