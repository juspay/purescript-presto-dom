module PrestoDOM.Core
   ( runScreen
   , showScreen
   , initUI
   , initUIWithScreen
   , mapDom
   ) where

import Prelude

import Effect (Effect)
import Effect.Aff (Canceler, Error, nonCanceler)
import Data.Newtype (un)
import Effect.Uncurried as EFn
import Web.DOM.Document (Document) as DOM
import Data.Either (Either(..), either)
import Data.Foldable (for_)
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..), fst)
import Foreign.Object as Object
import FRP.Behavior (sample_, unfold)
import FRP.Event (subscribe)
import FRP.Event as E
import Halogen.VDom (VDomSpec(VDomSpec), buildVDom)
import Halogen.VDom.DOM.Prop (Prop, buildProp)
import Halogen.VDom.Machine (Step, step, extract)
import Halogen.VDom.Thunk (Thunk, buildThunk)
import PrestoDOM.Types.Core (ElemName(..), VDom(Elem), PrestoDOM, Screen, Namespace, PrestoWidget(..))
import PrestoDOM.Utils (continue)

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

foreign import getRootNode :: Effect DOM.Document

foreign import setRootNode
    :: forall a
     . EFn.EffectFn1
        (Maybe a)
        DOM.Document

foreign import insertDom :: forall a b. EFn.EffectFn2 a b Unit

foreign import updateDom :: forall a b. EFn.EffectFn2 a b Unit

foreign import processWidget :: Effect Unit

foreign import saveScreenNameImpl
    :: EFn.EffectFn1
        (Maybe Namespace)
        Boolean


foreign import cacheScreenImpl
    :: EFn.EffectFn1
        (Maybe Namespace)
        Boolean

spec :: DOM.Document -> VDomSpec (Array (Prop (Effect Unit))) (Thunk PrestoWidget (Effect Unit))
spec document =  VDomSpec {
      buildWidget : buildThunk (un PrestoWidget)
    , buildAttributes: buildProp logger
    , document : document
    }

logger :: forall a. (a → Effect Unit)
logger a = do
    _ <- EFn.runEffectFn1 emitter a
    pure unit


patchAndRun :: forall w i. VDom (Array (Prop i)) w -> Effect Unit
patchAndRun myDom = do
  screenName <- getScreenName myDom
  machine <- EFn.runEffectFn1 getLatestMachine screenName
  newMachine <- EFn.runEffectFn2 step (machine) (myDom)
  EFn.runEffectFn2 storeMachine newMachine screenName

initUIWithScreen
  :: forall action state
   . Screen action state Unit
  -> (Either Error Unit -> Effect Unit)
  -> Effect Canceler
initUIWithScreen { initialState, view, eval } cb = do
  { event, push } <- E.create
  let myDom = view push initialState
  root <- EFn.runEffectFn1 setRootNode Nothing
  machine <- EFn.runEffectFn1 (buildVDom (spec root)) myDom
  EFn.runEffectFn2 insertDom root (extract machine)
  cb $ Right unit
  pure nonCanceler

initUI
  :: (Either Error Unit -> Effect Unit)
  -> Effect Canceler
initUI cb = do
  root <- EFn.runEffectFn1 setRootNode Nothing
  machine <- EFn.runEffectFn1 (buildVDom (spec root)) view
  EFn.runEffectFn2 insertDom root (extract machine)
  cb $ Right unit
  pure nonCanceler
    where
          view = Elem Nothing (ElemName "linearLayout") [] []



runScreenImpl
    :: forall action state returnType
     . Boolean
    -> Screen action state returnType
    -> (Either Error returnType -> Effect Unit)
    -> Effect Canceler
runScreenImpl cache { initialState, view, eval } cb = do
  { event, push } <- E.create
  let myDom = view push initialState
  screenName <- getScreenName myDom
  patch <- if cache
               then checkCachedScreen screenName
               else compareScreen screenName

  case patch of
    false -> do
        root <- getRootNode
        machine <- EFn.runEffectFn1 (buildVDom (spec root)) myDom
        EFn.runEffectFn2 storeMachine machine screenName
        if cache
            then EFn.runEffectFn2 updateDom root (extract machine)
            else EFn.runEffectFn2 insertDom root (extract machine)
        processWidget
    true ->
        patchAndRun myDom

  let stateBeh = unfold (\action eitherState -> eitherState >>= (eval action <<< fst)) event (continue initialState)
  _ <- sample_ stateBeh event `subscribe` (either (onExit push) $ onStateChange push)
  pure nonCanceler
    where
          onStateChange push (Tuple state cmds) =
              patchAndRun (view push state)
              *> for_ cmds (\effAction -> effAction >>= push)

          onExit push (Tuple st ret) =
              case st of
                   Just s -> patchAndRun (view push  s) *> (cb $ Right ret)
                   Nothing -> cb $ Right ret

runScreen
    :: forall action state returnType
     . Screen action state returnType
    -> (Either Error returnType -> Effect Unit)
    -> Effect Canceler
runScreen = runScreenImpl false

showScreen
    :: forall action state returnType
     . Screen action state returnType
    -> (Either Error returnType -> Effect Unit)
    -> Effect Canceler
showScreen = runScreenImpl true


getScreenName :: forall a w. VDom a w -> Effect (Maybe Namespace)
getScreenName (Elem screen _ _ _) = pure screen
getScreenName _ = pure Nothing

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

