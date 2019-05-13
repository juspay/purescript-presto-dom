module PrestoDOM.Core
   ( ScreenData
   , runScreen
   , showScreen
   , startScreen
   , startOverlay
   , initUI
   , initUIWithScreen
   , mapDom
   , mapDom_
   ) where

import Prelude

import Data.Array (null, foldr)
import Data.Either (Either(..), either)
import Data.Foldable (for_)
import Data.Maybe (Maybe(..), maybe)
import Data.Newtype (un)
import Data.Tuple (Tuple(..), fst, snd)
import Effect (Effect)
import Effect.Aff (Canceler, Error, nonCanceler)
import Effect.Ref as Ref
import Effect.Uncurried as EFn
import Foreign.Object as Object
import FRP.Behavior (sample_, unfold)
import FRP.Event (subscribe)
import FRP.Event as E
import Halogen.VDom (VDomSpec(VDomSpec), buildVDom)
import Halogen.VDom.DOM.Prop (Prop, buildProp)
import Halogen.VDom.Machine (Step, step, extract)
import Halogen.VDom.Thunk (Thunk, buildThunk)
import PrestoDOM.Screen (ScreenCache, ScreenStack, cacheInitialize, cacheInsert, stackInitialize, stackPopTill, stackPush)
import PrestoDOM.Types.Core (ElemName(..), PrestoDOM, PrestoWidget(..), Screen, VDom(Elem))
import PrestoDOM.Utils (continue)
import Web.DOM.Document (Document) as DOM
import Web.DOM.Node (Node) as DOM

{-- import Debug.Trace (spy, traceM) --}

foreign import emitter
    :: forall a
     . EFn.EffectFn1
        a
        Unit

foreign import setRootNode
    :: forall a
     . EFn.EffectFn1
        (Maybe a)
        DOM.Document

foreign import insertDom :: forall a b. EFn.EffectFn3 a b (Effect Unit) Int

{-- foreign import updateDom :: forall a b. EFn.EffectFn2 a b Int --}

foreign import processWidget :: Effect Unit



foreign import removeFromDom :: EFn.EffectFn2 (Array Int) Int Unit

foreign import makeVisible :: EFn.EffectFn1 Int Unit

foreign import makeInvisible :: EFn.EffectFn2 Int Int Unit




vdomSpec :: DOM.Document -> VDomSpec (Array (Prop (Effect Unit))) (Thunk PrestoWidget (Effect Unit))
vdomSpec document =  VDomSpec {
      buildWidget : buildThunk (un PrestoWidget)
    , buildAttributes: buildProp identity
    , document : document
    }

type ScreenData =
  { root :: DOM.Document
  , screenStack :: ScreenStack Int
  , screenCache :: ScreenCache Int
  , currentScreen :: Maybe (Tuple String Int)
  , currentOverlay :: Maybe (Tuple String Int)
  , machines :: Object.Object (Tuple (Step (VDom (Array (Prop (Effect Unit))) (Thunk PrestoWidget (Effect Unit))) DOM.Node) Int)
  }

initScreenData :: DOM.Document -> ScreenData
initScreenData root =
  { root : root
  , screenStack : stackInitialize
  , screenCache : cacheInitialize
  , currentScreen : Nothing
  , currentOverlay : Nothing
  , machines : Object.empty
  }


type ScreenSpec =
  { getCurrentOverlay :: ScreenData -> Maybe (Tuple String Int)
  , getCurrentScreen :: ScreenData -> Maybe (Tuple String Int)
  , setCurrentScreen :: String -> Int -> ScreenData -> ScreenData
  , updateStoredScreens :: String -> Int -> ScreenData -> ScreenData
  , cache :: Boolean
  , handleOldScreens :: String -> ScreenData -> Tuple (ScreenStack Int) (Array (Tuple String Int))
  }

startScreenSpec :: ScreenSpec
startScreenSpec =
  { getCurrentOverlay : \sData -> sData.currentOverlay
  , getCurrentScreen : \sData ->  sData.currentScreen
  , setCurrentScreen : \s i sData -> sData {currentOverlay = Nothing, currentScreen = Just $ Tuple s i}
  , updateStoredScreens : \s i sData -> sData { screenStack = stackPush s i sData.screenStack }
  , cache : false
  , handleOldScreens : fn
  }
  where
    fn :: String -> ScreenData -> Tuple (ScreenStack Int) (Array (Tuple String Int))
    fn sName sData =
      let (Tuple nStack arr) = stackPopTill sName sData.screenStack
       in Tuple nStack arr

startOverlaySpec :: ScreenSpec
startOverlaySpec =
  { getCurrentOverlay : _.currentOverlay
  , getCurrentScreen : _.currentOverlay
  , setCurrentScreen : \s i sData -> sData {currentOverlay = Just $ Tuple s i}
  , updateStoredScreens : \s i sData -> sData { screenCache = cacheInsert s i sData.screenCache }
  --- handleOldScreen not required for overlays
  , handleOldScreens : \_ sData -> Tuple sData.screenStack []
  , cache : true
  }

checkStoredScreens :: String -> ScreenData -> Maybe Int
checkStoredScreens s sData = snd <$> Object.lookup s sData.machines


logger :: forall a. (a → Effect Unit)
logger a = do
    _ <- EFn.runEffectFn1 emitter a
    pure unit


patchAndRun
  :: Ref.Ref ScreenData
  -> String
  -> PrestoDOM
  -> Effect Unit
patchAndRun ref screenName myDom = do
  sData <- Ref.read ref
  case Object.lookup screenName sData.machines of
    Just (Tuple machine id) -> do
       newMachine <- EFn.runEffectFn2 step (machine) (myDom)
       Ref.modify_ (\s -> s { machines = Object.insert screenName (Tuple newMachine id) s.machines}) ref
    Nothing ->
      pure unit

initUIImpl
  :: PrestoDOM
  -> (Either Error (Ref.Ref ScreenData) -> Effect Unit)
  -> Effect Canceler
initUIImpl view cb = do
  root <- EFn.runEffectFn1 setRootNode Nothing
  ref <- Ref.new $ initScreenData root
  machine <- EFn.runEffectFn1 (buildVDom (vdomSpec root)) view
  _ <- EFn.runEffectFn3 insertDom root (extract machine) afterRenderCb
  cb $ Right ref
  pure nonCanceler

  where
    afterRenderCb :: Effect Unit
    afterRenderCb = pure unit

initUIWithScreen
  :: forall action state
   . Screen action state Unit
  -> (Either Error (Ref.Ref ScreenData) -> Effect Unit)
  -> Effect Canceler
initUIWithScreen { initialState, view, eval } cb = do
  { event, push } <- E.create
  let myDom = view push initialState
  initUIImpl myDom cb


initUI
  :: (Either Error (Ref.Ref ScreenData) -> Effect Unit)
  -> Effect Canceler
initUI cb = do
  initUIImpl view cb
    where
          view = Elem Nothing (ElemName "linearLayout") [] []


data ScreenMode
  = NewScreen
  | SameScreen
  | OldScreen Int

getScreenMode
  :: ScreenSpec
  -> Maybe (Tuple String Int)
  -> Maybe (Tuple String Int)
  -> String
  -> ScreenData
  -> ScreenMode
getScreenMode spec overlay currentScreen incomingSName screenData =
  let isSame = case currentScreen, incomingSName of
                  Just a, b -> fst a == b
                  _, _ -> false

   in case isSame of
        false ->
          case checkStoredScreens incomingSName screenData of
            Nothing -> NewScreen
            Just i -> OldScreen i
        true -> do
          case spec.cache, overlay, currentScreen of
            false, Just ol, Just cs -> OldScreen $ snd cs
            _, _, _ -> SameScreen



runScreenImpl
  :: forall action state returnType screenName
   . Show screenName
  => Eq screenName
  => ScreenSpec
  -> Ref.Ref ScreenData
  -> screenName
  -> Screen action state returnType
  -> (Either Error returnType -> Effect Unit)
  -> Effect Canceler
runScreenImpl spec ref screen { initialState, view, eval } cb = do
  {-- _ <- traceM $ if spec.cache then "OVERLAY" else "SCREEN" --}
  screenData <- Ref.read ref
  { event, push } <- E.create
  let myDom = view push initialState
      screenName = show screen

      overlay = spec.getCurrentOverlay screenData
      currentScreen = spec.getCurrentScreen screenData

      screenMode = getScreenMode spec overlay currentScreen screenName screenData

  -- Debug
  {-- _ <- traceM "screenName" --}
  {-- _ <- traceM screenName --}
  {-- _ <- traceM "incoming screen" --}
  {-- _ <- traceM currentScreen --}

  case screenMode of
    NewScreen -> do
      {-- _ <- traceM "++++++New Screen" --}
      -- Processing
      machine <- EFn.runEffectFn1 (buildVDom (vdomSpec screenData.root)) myDom
      -- Update Dom
      elemId <- EFn.runEffectFn3 insertDom screenData.root (extract machine) afterRenderCb
      -- storeMachine
      -- setCurrentScreen
      -- update stored screens
      _ <- Ref.modify_
                (\s -> spec.setCurrentScreen screenName elemId
                        >>> spec.updateStoredScreens screenName elemId
                        $ s { machines = Object.insert screenName (Tuple machine elemId) s.machines }
                )
                ref
      -- animate
      -- vis
      -- hide old screen
      case overlay, spec.cache of
        Just (Tuple _ id), false -> EFn.runEffectFn2 makeInvisible id 0
        _, _ -> pure unit

      maybe
          (pure unit)
          (\tId -> EFn.runEffectFn2 makeInvisible (snd tId) 0)
          currentScreen

      processWidget

    -- Old Screen
    OldScreen sId -> do
      {-- _ <- traceM "++++++Old Screen" --}
      patchAndRun ref screenName myDom
      -- setCurrentScreen
      _ <- Ref.modify_ (spec.setCurrentScreen screenName sId) ref
      -- make visible
      EFn.runEffectFn1 makeVisible sId
      -- Animate then
      -- remove screens

      maybe
          (pure unit)
          (\tId -> EFn.runEffectFn2 makeInvisible (snd tId) 0)
          overlay

      -- update stored screens
      -- Applicable only for screen.
      let Tuple nStack idSet = spec.handleOldScreens screenName screenData
      case null idSet of
        true -> pure unit
        false -> do
            _ <- Ref.modify_
                      (\s -> s { machines = foldr
                                              (\sName obj -> Object.delete sName obj)
                                              s.machines
                                              (fst <$> idSet)
                               , screenStack = nStack
                               }
                      )
                      ref
            EFn.runEffectFn2 removeFromDom (snd <$>  idSet) 0
      pure unit

    SameScreen -> do
      {-- _ <- traceM "++++++SameScreen" --}
      patchAndRun ref screenName myDom
      -- No Anim

  -- debug
  {-- r <- Ref.read ref --}
  {-- _ <- traceM r --}

  let stateBeh = unfold (\action eitherState -> eitherState >>= (eval action <<< fst)) event (continue initialState)
  _ <- sample_ stateBeh event `subscribe` (either (onExit screenName push) $ onStateChange screenName push)
  pure nonCanceler

  where
    afterRenderCb :: Effect Unit
    afterRenderCb = pure unit

    onStateChange screenName push (Tuple state cmds) =
      patchAndRun ref  screenName (view push state)
        *> for_ cmds (\effAction -> effAction >>= push)

    onExit screenName push (Tuple st ret) =
      case st of
        Just s -> patchAndRun ref screenName (view push  s) *> (cb $ Right ret)
        Nothing -> cb $ Right ret

-- | Deprecated
runScreen
  :: forall action state returnType screenName
   . Show screenName
  => Eq screenName
  => Ref.Ref ScreenData
  -> screenName
  -> Screen action state returnType
  -> (Either Error returnType -> Effect Unit)
  -> Effect Canceler
runScreen = runScreenImpl startScreenSpec

-- | Deprecated
showScreen
  :: forall action state returnType screenName
   . Show screenName
  => Eq screenName
  => Ref.Ref ScreenData
  -> screenName
  -> Screen action state returnType
  -> (Either Error returnType -> Effect Unit)
  -> Effect Canceler
showScreen = runScreenImpl startOverlaySpec

startScreen
  :: forall action state returnType screenName
   . Show screenName
  => Eq screenName
  => Ref.Ref ScreenData
  -> screenName
  -> Screen action state returnType
  -> (Either Error returnType -> Effect Unit)
  -> Effect Canceler
startScreen = runScreenImpl startScreenSpec

startOverlay
  :: forall action state returnType screenName
   . Show screenName
  => Eq screenName
  => Ref.Ref ScreenData
  -> screenName
  -> Screen action state returnType
  -> (Either Error returnType -> Effect Unit)
  -> Effect Canceler
startOverlay = runScreenImpl startOverlaySpec

mapDom
  :: forall a b state
   . ((a -> Effect Unit) -> state -> PrestoDOM)
  -> (b -> Effect Unit)
  -> state
  -> (a -> b)
  -> PrestoDOM
mapDom view push state actionMap = view (push <<< actionMap) state

mapDom_
  :: forall i a b state
   . ((a -> Effect Unit) -> state -> Object.Object i -> PrestoDOM)
  -> (b -> Effect Unit)
  -> state
  -> (a -> b)
  -> Array (Tuple String i)
  -> PrestoDOM
mapDom_ view push state actionMap = view (push <<< actionMap) state <<< Object.fromFoldable

