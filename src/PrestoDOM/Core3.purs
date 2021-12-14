module PrestoDOM.Core3
  ( addChildImpl
  , addProperty
  , addScreenWithAnim
  , addToCachedList
  , addToPatchQueue
  , addViewToParent
  , attachScreen
  , awaitPrerenderFinished
  , cacheMachine
  , cachePushEvents
  , callAnimation
  , canPreRender
  , cancelBehavior
  , cancelExistingActions
  , checkAndDeleteFromHideAndRemoveStacks
  , controllerActions
  , createPrestoElement
  , createPushQueue
  , decrementPatchCounter
  , domAll
  , fireManualEvent
  , getAndSetEventFromState
  , getCachedMachine
  , getCachedMachineImpl
  , getCurrentActivity
  , getEventIO
  , getLatestMachine
  , getListDataCommands
  , getListDataFromMapps
  , getPaddingForStroke
  , getPushFn
  , hideCacheRootOnAnimationEnd
  , incrementPatchCounter
  , initUIWithNameSpace
  , initUIWithScreen
  , insertDom
  , isCached
  , isInStack
  , isScreenPushActive
  , joinCancellers
  , launchAffWithCounter
  , makeCacheRootVisible
  , makeScreenVisible
  , moveChild
  , parseParams
  , parseProps
  , patchAndRun
  , patchBlock
  , prepareAndStoreView
  , prepareDom
  , prepareScreen
  , processEvent
  , processEventWithId
  , removeChild
  , render
  , renderOrPatch
  , replaceView
  , replayFragmentCallbacks
  , replayFragmentCallbacks'
  , replayListFragmentCallbacks
  , runController
  , runScreen
  , sanitiseNamespace
  , saveCanceller
  , setControllerStates
  , setManualEvents
  , setPatchToActive
  , setScreenPushActive
  , setToTopOfStack
  , setUpBaseState
  , showScreen
  , spec
  , startedToPrepare
  , storeMachine
  , terminateUI
  , terminateUIImpl
  , terminateUIImplWithCallback
  , terminateUIWithCallback
  , updateChildren
  , updateChildrenImpl
  , updateMicroAppPayload
  , updateMicroAppPayloadImpl
  , updateProp
  , updateProperties
  , updatePropertiesImpl
  , updateScreen
  , updateActivity
  )
  where

import Prelude

import Control.Monad.Except(runExcept)
import Control.Alt ((<|>))
import Data.Either (Either(..), either, hush)
import Data.Foldable (for_)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Newtype (un)
import Data.Traversable (traverse)
import Data.Tuple (Tuple(..), fst)
import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Aff (Canceler, effectCanceler, Aff, makeAff, forkAff, joinFiber, launchAff_, nonCanceler)
import Effect.Exception (Error)
import Effect.Ref as Ref
import Effect.Uncurried as EFn
import Effect.Uncurried as Efn
import FRP.Behavior (sample_, unfold)
import FRP.Event (EventIO, subscribe)
import FRP.Event as E
import Foreign (Foreign, unsafeToForeign)
import Foreign.Generic (encode, decode, class Decode)
import Foreign.Object (Object, update, insert, delete, isEmpty, lookup)
import Halogen.VDom (Step, VDom, VDomSpec(..), buildVDom, extract, step)
import Halogen.VDom.DOM.Prop (buildProp)
import Halogen.VDom.Thunk (Thunk, buildThunk)
import Halogen.VDom.Types (FnObject)
import PrestoDOM.Events (manualEventsName)
import PrestoDOM.Types.Core (class Loggable, PrestoWidget(..), Prop, ScopedScreen, Controller, ScreenBase)
import PrestoDOM.Utils (continue, logAction)
import Tracker (trackScreen, trackLifeCycle)
import Tracker.Labels as L
import Tracker.Types (Level(..), Screen(..), Lifecycle(..)) as T
import Unsafe.Coerce (unsafeCoerce)

import PrestoDOM.Core.Types (InsertState, UpdateActions, VdomTree)
import PrestoDOM.Core.Utils (callMicroAppsForListState, extractAndDecode, extractJsonAndDecode, forkoutListState, generateCommands, getListData, replayListFragmentCallbacks', verifyFont, verifyImage, attachUrlImages)

foreign import setUpBaseState :: String -> Foreign -> Effect Unit
foreign import insertDom :: forall a. EFn.EffectFn4 String String a Boolean InsertState
foreign import addViewToParent :: EFn.EffectFn1 InsertState Unit
foreign import parseProps :: EFn.EffectFn4 Foreign String Foreign String {ids :: Foreign, dom :: Foreign}
foreign import storeMachine :: forall a b . EFn.EffectFn3 (Step a b) String String Unit
foreign import getLatestMachine :: forall a b . EFn.EffectFn2 String String (Step a b)
foreign import isInStack :: EFn.EffectFn2 String String Boolean
foreign import isCached :: EFn.EffectFn2 String String Boolean
foreign import cancelExistingActions :: EFn.EffectFn2 String String Unit
foreign import saveCanceller :: EFn.EffectFn3 String String (Effect Unit) Unit
foreign import callAnimation :: EFn.EffectFn3 String String Boolean Unit
foreign import checkAndDeleteFromHideAndRemoveStacks :: EFn.EffectFn2 String String Unit
foreign import terminateUIImpl :: EFn.EffectFn1 String Unit
foreign import terminateUIImplWithCallback :: (Int -> String -> Effect Unit) ->  EFn.EffectFn1 String Unit
foreign import setToTopOfStack :: EFn.EffectFn2 String String Unit
foreign import addToCachedList :: EFn.EffectFn2 String String Unit
foreign import makeCacheRootVisible :: EFn.EffectFn1 String Unit
foreign import hideCacheRootOnAnimationEnd :: EFn.EffectFn1 String Unit
foreign import makeScreenVisible :: EFn.EffectFn2 String String Unit

foreign import addChildImpl :: forall a b. String -> String -> EFn.EffectFn3 a b Int InsertState
foreign import addProperty :: forall a b. String -> EFn.EffectFn3 String a b Unit
foreign import cancelBehavior :: EFn.EffectFn1 String Unit
foreign import createPrestoElement :: forall a. Effect a
foreign import moveChild :: forall a b. String -> EFn.EffectFn3 a b Int Unit
foreign import removeChild :: forall a b. String -> EFn.EffectFn3 a b Int Unit
foreign import replaceView :: forall a. String -> EFn.EffectFn2 a (Array String) Unit
foreign import updatePropertiesImpl :: forall a b. String -> EFn.EffectFn2 a b Unit
foreign import updateMicroAppPayloadImpl ∷ forall b. EFn.EffectFn3 String b Boolean Unit
foreign import updateActivity :: String -> Effect Unit
foreign import getCurrentActivity :: Effect String

foreign import setManualEvents :: forall a b. String -> String -> a -> b -> Effect Unit
foreign import fireManualEvent :: forall a. String -> a -> Effect Unit
foreign import replayFragmentCallbacks' :: forall a. String -> String -> (a -> Effect Unit) -> Effect (Effect Unit)

foreign import getAndSetEventFromState :: forall a. EFn.EffectFn3 String String (Effect (EventIO a)) (EventIO a)

foreign import processEventWithId :: forall a. String -> a -> Effect Unit
foreign import incrementPatchCounter :: String -> String -> Effect Unit
foreign import decrementPatchCounter :: String -> String -> Effect Unit
foreign import setPatchToActive :: String -> String -> Effect Unit
foreign import addToPatchQueue :: String -> String -> Effect Unit -> Effect Unit
foreign import parseParams :: forall a b c d. EFn.EffectFn3 a b c d

foreign import getListDataCommands :: forall a. EFn.EffectFn2 (Array (Object a)) Foreign Foreign
foreign import setControllerStates :: String -> String -> Effect Unit

foreign import cachePushEvents :: String -> String -> Effect Unit -> String -> Effect Unit
foreign import isScreenPushActive :: String -> String -> String -> Effect Boolean
foreign import setScreenPushActive :: String -> String -> String -> Effect Unit

foreign import canPreRender :: Unit -> Boolean
foreign import cacheMachine :: forall a b . EFn.EffectFn3 (Step a b) String String Unit
foreign import prepareDom :: forall a. EFn.EffectFn3 a String String Foreign
foreign import getCachedMachineImpl :: forall a b . EFn.EffectFn4 ((Step a b) -> Maybe (Step a b)) (Maybe (Step a b)) String String (Maybe (Step a b))
foreign import prepareAndStoreView :: EFn.EffectFn5 (Effect Unit) Foreign String String String Unit
foreign import attachScreen :: EFn.EffectFn3 String String Foreign Unit
foreign import render :: EFn.EffectFn1 String Unit
foreign import startedToPrepare :: EFn.EffectFn2 String String Unit
foreign import awaitPrerenderFinished :: EFn.EffectFn3 String String (Effect Unit) Unit

foreign import addScreenWithAnim :: EFn.EffectFn3 Foreign String String Unit

foreign import getTimeInMillis :: Effect Number




updateProperties :: forall a b. String -> String -> EFn.EffectFn2 a b Unit
updateProperties namespace screenName = do
  let
    function = updatePropertiesImpl namespace
  Efn.mkEffectFn2
    $ \elem rawProps -> do
        let
          default = Efn.runEffectFn2 function rawProps elem
          aff = rawProps # unsafeCoerce
            # decode # runExcept # hush
            <#> \props ->
                  launchAffWithCounter namespace screenName do
                    updatedProps <- props
                      # updateProp "fontStyle" verifyFont
                      >>= updateProp "imageUrl" (verifyImage Nothing "" )
                      >>= updateProp "placeHolder" (verifyImage Nothing "")
                      >>= getListDataFromMapps namespace screenName elem
                      >>= getPaddingForStroke namespace screenName elem
                      <#> delete "payload"
                    if isEmpty $ delete "id" updatedProps
                      then pure unit -- Don't send if payload is the only changed key
                      else liftEffect $ Efn.runEffectFn2 function (unsafeCoerce $ encode updatedProps) elem
        fromMaybe default aff

updateProp :: forall a. Decode a => String -> (Maybe a -> Aff (Maybe Foreign)) -> Object Foreign -> Aff (Object Foreign)
updateProp key checkFunc props = do
  a <- checkFunc $ extractAndDecode key props
  pure $ update (const a) key props

launchAffWithCounter :: forall a. String -> String -> Aff a -> Effect Unit
launchAffWithCounter namespace screenName aff = do
  _ <- incrementPatchCounter namespace screenName
  launchAff_ do
    _ <- aff
    liftEffect $ decrementPatchCounter namespace screenName

getListDataFromMapps :: forall elem. String -> String -> elem -> Object Foreign -> Aff (Object Foreign)
getListDataFromMapps namespace screenName elem props = do
  let (vdomTree :: Maybe VdomTree) = hush $ runExcept $ decode $ unsafeToForeign elem
  case vdomTree of
    Just tree@{"type" : "listView", __ref : (Just {__id : id})} -> do
      let (payloads :: Maybe (Object Foreign)) = extractJsonAndDecode "payload" props
      let newListData = extractAndDecode "listData" props
      let mapp = fromMaybe (encode $ unit) $ lookup "onMicroappResponse" props
      let (listData :: Maybe (Array (Object Foreign))) = newListData <|> (extractAndDecode "listData" tree.props)
      updatedListData <-
        case payloads, listData, newListData of
          Just p, Just ld, _ -> callMicroAppsForListState id namespace screenName ld p mapp <#> Just
          Nothing, _, Just ld -> liftEffect $ getListData id ld <#> Just
          _, _, _ -> pure newListData
      case updatedListData of
        Just uld -> do
            EFn.runEffectFn2 getListDataCommands uld (encode tree)
              # liftEffect
              <#> flip (insert "listData") props
        _ -> pure props
    _ -> pure props

getPaddingForStroke :: forall elem. String -> String -> elem -> Object Foreign -> Aff (Object Foreign)
getPaddingForStroke namespace screenName elem props = do
  let (vdomTree :: Maybe VdomTree) = hush $ runExcept $ decode $ unsafeToForeign elem
  case vdomTree of
    Just tree -> do
      let (stroke :: Maybe String) = extractAndDecode "stroke" props
      let padding = extractAndDecode "padding" props
      let (oldPadding :: Maybe String) = padding <|> (extractAndDecode "padding" tree.props)
      case stroke, oldPadding of
        Just s, Just oP -> pure $ insert "padding" (encode oP) props
        _, _ -> pure props
    _ -> pure props

updateMicroAppPayload ∷ forall b. String -> EFn.EffectFn3 String b Boolean Unit
updateMicroAppPayload screenName =
  Efn.mkEffectFn3
    $ \val elem isPatch -> do
        let (vdomTree :: Maybe VdomTree) = hush $ runExcept $ decode $ unsafeToForeign elem
        case vdomTree, isPatch of
          Just tree@{"type" : "listView"}, true -> pure unit
          _, _ -> Efn.runEffectFn3 updateMicroAppPayloadImpl val elem isPatch

updateChildren :: forall a. String -> String -> EFn.EffectFn1 a Unit
updateChildren namespace screenName = do
  Efn.mkEffectFn1
    $ \rawActions -> do
          rawActions # unsafeCoerce
            # decode # runExcept # hush
            <#> updateChildrenImpl namespace screenName <#> launchAffWithCounter namespace screenName
            # fromMaybe (pure unit)

updateChildrenImpl :: String -> String -> Array UpdateActions -> Aff (Array Unit)
updateChildrenImpl namespace screenName = do
  traverse
    \{action, parent, elem, index} ->
        case action of
          "add" -> do
              insertState <- liftEffect $ Efn.runEffectFn3 (addChildImpl namespace screenName) (encode elem) (encode parent) index
              domAllOut <- domAll {name : screenName, parent : Just namespace} (unsafeToForeign {}) insertState.dom
              liftEffect $ EFn.runEffectFn1 addViewToParent (insertState {dom = domAllOut})
          "move" -> liftEffect $ EFn.runEffectFn3 (moveChild namespace) elem parent index
          _ -> pure unit -- Should never reach here

sanitiseNamespace :: Maybe String -> Effect String
sanitiseNamespace maybeNS = do
  let ns = fromMaybe "default" maybeNS
  pure ns

initUIWithNameSpace :: String -> Maybe String -> Effect Unit
initUIWithNameSpace namespace id = do
  setUpBaseState namespace $ encode id
  EFn.runEffectFn1 render namespace

initUIWithScreen ::
  forall action state returnType.
  String -> Maybe String -> ScopedScreen action state returnType -> Aff Unit
initUIWithScreen namespace id screen = do
  liftEffect $ initUIWithNameSpace namespace id
  let myDom = screen.view (\_ -> pure unit) screen.initialState
  ns <- liftEffect $ sanitiseNamespace screen.parent
  machine <- liftEffect $ EFn.runEffectFn1 (buildVDom (spec ns screen.name)) myDom
  insertState <- liftEffect $ EFn.runEffectFn4 insertDom ns screen.name (extract machine) false
  domAllOut <- domAll screen (unsafeToForeign {}) insertState.dom
  liftEffect $ EFn.runEffectFn1 addViewToParent (insertState {dom = domAllOut})

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
        , updateChildren : updateChildren namespace screen
        {--
        Compresss into a update children interface
        , moveChild : moveChild namespace
        --}
        , removeChild : removeChild namespace
        , createPrestoElement
        , updateProperties : updateProperties namespace screen
        , cancelBehavior
        , manualEventsName : manualEventsName unit
        , updateMicroAppPayload : updateMicroAppPayload namespace
        , parseParams : parseParams
        }

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
      pre_rendering_started <- liftEffect getTimeInMillis
      liftEffect $ trackScreen T.Screen T.Info L.PRERENDERED_SCREEN "pre_rendering_started" screen.name json
      let myDom = view (\_ -> pure unit) screen.initialState
      machine <- liftEffect $ EFn.runEffectFn1 (buildVDom (spec ns name)) myDom

      liftEffect $ EFn.runEffectFn3 cacheMachine machine name ns

      dom <- liftEffect $ EFn.runEffectFn3 prepareDom (extract machine) name ns
      -- DO NOT CHANGE THIS TO ENCODE,
      -- THE JSON IN THIS BLOCK IS MODIFIED IN JS
      -- AND CAN IMPACT ALL ENCODE USAGES
      domAllOut <- domAll screen (unsafeToForeign {}) dom
      makeAff $ \cB -> do
         EFn.runEffectFn5 prepareAndStoreView (callBack cB pre_rendering_started) domAllOut (ns <> name) ns name
         pure nonCanceler

    where
    callBack cb pre_rendering_started = do
        pre_rendering_ended <- getTimeInMillis
        let latency = (pre_rendering_ended - pre_rendering_started)
        trackScreen T.Screen T.Info L.PRERENDERED_SCREEN "pre_rendering_finished" screen.name json
        trackLifeCycle T.Microapp T.Info L.PRERENDERED_SCREEN "latency" (unsafeToForeign {pre_rendering_started : pre_rendering_started, pre_rendering_ended : pre_rendering_ended, pre_rendering_latency : latency}) json
        cb (Right unit)

runScreen :: forall action state returnType
  . Show action => Loggable action
  => ScopedScreen action state returnType
  -> (Object Foreign)
  -> Aff returnType
runScreen st@{ name, parent, view} json = do
  ns <- liftEffect $ sanitiseNamespace parent
  makeAff (\cb -> Efn.runEffectFn3 awaitPrerenderFinished ns name (cb $ Right unit) $> nonCanceler )
  liftEffect $ EFn.runEffectFn2 checkAndDeleteFromHideAndRemoveStacks ns name
  check <- liftEffect $  EFn.runEffectFn2 isInStack name ns <#> not
  eventIO <- liftEffect $ getEventIO name parent
  _ <- liftEffect $ trackScreen T.Screen T.Info L.CURRENT_SCREEN "screen" name json
  _ <- liftEffect $ trackScreen T.Screen T.Info L.UPCOMING_SCREEN "screen" name json
  liftEffect $ Efn.runEffectFn1 hideCacheRootOnAnimationEnd ns
  liftEffect $ EFn.runEffectFn2 setToTopOfStack ns name
  renderOrPatch eventIO st check false
  makeAff $ controllerActions eventIO st json (patchAndRun name parent (view eventIO.push))

renderOrPatch :: forall action state returnType
  . Show action => Loggable action
  => EventIO action
  -> ScopedScreen action state returnType
  -> Boolean -> Boolean -> Aff Unit
renderOrPatch {event, push} st@{ initialState, view, eval, name , globalEvents, parent } true isCache = do
  let myDom = view push initialState
  ns <- liftEffect $ sanitiseNamespace parent
  prMachine <- if isCache then pure Nothing else getCachedMachine ns name
  case prMachine of
    Just machine -> liftEffect do
      EFn.runEffectFn3 attachScreen ns name (extract machine)
      newMachine <- EFn.runEffectFn2 step machine myDom
      EFn.runEffectFn3 storeMachine newMachine name ns
      EFn.runEffectFn3 addScreenWithAnim (extract newMachine) name ns
      setPatchToActive ns name
      EFn.runEffectFn1 attachUrlImages (ns <> name)
    Nothing -> do
      machine <- liftEffect $ EFn.runEffectFn1 (buildVDom (spec ns name)) myDom
      insertState <- liftEffect $ EFn.runEffectFn4 insertDom ns name (extract machine) isCache
      -- DO NOT CHANGE THIS TO ENCODE,
      -- THE JSON IN THIS BLOCK IS MODIFIED IN JS
      -- AND CAN IMPACT ALL ENCODE USAGES
      domAllOut <- domAll st (unsafeToForeign {}) insertState.dom
      liftEffect $ EFn.runEffectFn1 addViewToParent (insertState {dom = domAllOut})
      liftEffect $ EFn.runEffectFn3 storeMachine machine name ns
renderOrPatch {event, push} { initialState, view, eval, name , globalEvents, parent }false isCache = liftEffect do
  patchAndRun name parent (view push) initialState
  ns <- sanitiseNamespace parent
  EFn.runEffectFn2 makeScreenVisible ns name
  EFn.runEffectFn3 callAnimation name ns isCache

domAll :: forall a. {name :: String, parent :: Maybe String | a} -> Foreign -> Foreign -> Aff Foreign
domAll {name, parent} ids dom = {--dom--} do
  ns <- liftEffect $ sanitiseNamespace parent
  {ids: i, dom:d} <- liftEffect $ EFn.runEffectFn4 parseProps dom name ids ns
  case hush $ runExcept $ decode d of
    Just (vdomTree :: VdomTree) -> do
      fontFiber <- forkAff $ verifyFont $ extractAndDecode "fontStyle" vdomTree.props
      imageFiber <- forkAff $ verifyImage vdomTree.__ref (ns <> name) $ extractAndDecode "imageUrl" vdomTree.props
      placeFiber <- forkAff $ verifyImage Nothing "" $ extractAndDecode "placeHolder" vdomTree.props
      listFiber <- forkoutListState ns name vdomTree."type" vdomTree.props
      children <- domAll {name, parent} i `traverse` vdomTree.children
      font <- joinFiber fontFiber
      image <- joinFiber imageFiber
      placeHolder <- joinFiber placeFiber
      listData <- joinFiber listFiber >>= liftEffect
          <<< \u -> do
            case u of
             Just uld -> Just <$> EFn.runEffectFn2 getListDataCommands uld dom
             _ -> pure Nothing
      let props = vdomTree.props
            # update (const font) "fontStyle"
            # update (const image) "imageUrl"
            # update (const placeHolder) "placeHolder"
            # update (const listData) "listData"
      pure $ generateCommands $ vdomTree {children = children, props = props}
    a -> pure $ encode a
    
runController :: forall action state returnType
  . Show action => Loggable action
  => Controller action state returnType
  -> (Object Foreign) -> Aff returnType
runController st@{name, parent, eval, initialState, globalEvents, emitter} json = do
  ns <- liftEffect $ sanitiseNamespace parent
  _ <- liftEffect $ setControllerStates ns name
  eventIO <- liftEffect $ getEventIO name parent
  makeAff $ controllerActions eventIO st json emitter

patchAndRun :: forall w i state. String -> Maybe String -> (state -> VDom (Array (Prop i)) w) -> state -> Effect Unit
patchAndRun screenName namespace emitter state = do
  let myDom = emitter state
  let patchFunc = patchBlock screenName namespace myDom
  ns <- sanitiseNamespace namespace
  addToPatchQueue ns screenName patchFunc

patchBlock :: forall w i. String -> Maybe String -> VDom (Array (Prop i)) w -> Effect Unit
patchBlock screenName namespace myDom = do
  ns <- sanitiseNamespace namespace
  machine <- EFn.runEffectFn2 getLatestMachine screenName ns
  newMachine <- EFn.runEffectFn2 step (machine) (myDom)
  EFn.runEffectFn3 storeMachine newMachine screenName ns
  setPatchToActive ns screenName

getCachedMachine :: ∀ a b. String -> String → Aff (Maybe (Step a b))
getCachedMachine namespace name = liftEffect $ EFn.runEffectFn4 getCachedMachineImpl Just Nothing namespace name

processEvent :: forall a. String -> a -> Effect Unit
processEvent = fireManualEvent

getPushFn :: forall a. Maybe String -> String -> Effect (a -> Effect Unit)
getPushFn parent name = getEventIO name parent <#> \{push} -> push

replayFragmentCallbacks :: forall a.
  String ->
  String ->
  ({code :: Int, message :: String} -> a) ->
  (a -> Effect Unit) ->
  Effect (Effect Unit)
replayFragmentCallbacks nampespace name action push = replayFragmentCallbacks' nampespace name (push <<< action)

replayListFragmentCallbacks :: forall a.
  String ->
  String ->
  ({code :: Int, message :: String} -> a) ->
  (a -> Effect Unit) ->
  Effect (Effect Unit)
replayListFragmentCallbacks nampespace name action push = replayListFragmentCallbacks' nampespace name (push <<< action)

showScreen :: forall action state returnType
  . Show action => Loggable action
  => ScopedScreen action state returnType
  -> (Object Foreign)
  -> Aff returnType
showScreen st@{name, parent, view} json = do
  ns <- liftEffect $ sanitiseNamespace parent
  makeAff (\cb -> Efn.runEffectFn3 awaitPrerenderFinished ns name (cb $ Right unit) $> nonCanceler )
  liftEffect $ EFn.runEffectFn2 checkAndDeleteFromHideAndRemoveStacks ns name
  liftEffect $ Efn.runEffectFn1 makeCacheRootVisible ns
  check <- liftEffect $  EFn.runEffectFn2 isCached name ns <#> not
  eventIO <- liftEffect $ getEventIO name parent
  _ <- liftEffect $ trackScreen T.Screen T.Info L.CURRENT_SCREEN "overlay" name json
  _ <- liftEffect $ trackScreen T.Screen T.Info L.UPCOMING_SCREEN "overlay" name json
  liftEffect $ EFn.runEffectFn2 addToCachedList ns name
  renderOrPatch eventIO st check true
  makeAff $ controllerActions eventIO st json (patchAndRun name parent (view eventIO.push))

updateScreen :: forall action state returnType
     . Show action => Loggable action => ScopedScreen action state returnType
    -> Effect Unit
updateScreen { initialState, view, eval, name , globalEvents, parent } = do
  -- TODO ::
  -- USE RENDER OR PATCH
  -- ADD LOGIC TO IDENTIFY; IF SCREEN IS RUN OR SHOW SCREEN
  -- MAKE POSSIBLE TO MOVE SCREENS BETWEEN RUN AND SHOW (EXTREMELY EXPERIMENTAL)
  patchAndRun name parent (view (\_ -> pure unit )) initialState


terminateUI :: Maybe String -> Effect Unit
terminateUI nameSpace = EFn.runEffectFn1 terminateUIImpl =<< sanitiseNamespace nameSpace

terminateUIWithCallback :: (Int -> String -> Effect Unit) -> String -> Effect Unit
terminateUIWithCallback cb nameSpace = EFn.runEffectFn1 (terminateUIImplWithCallback cb) nameSpace
