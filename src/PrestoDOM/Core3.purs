module PrestoDOM.Core3 where
  
import Prelude
import Data.Either (Either(..), either, hush)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Foldable (for_)
import Data.Tuple (Tuple(..), fst)
import Data.Traversable (traverse)
import Effect (Effect)
import Effect.Aff (Canceler, effectCanceler, Aff, makeAff, forkAff, joinFiber, launchAff_, nonCanceler)
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
foreign import addChildImpl :: forall a b. String -> String -> EFn.EffectFn3 a b Int InsertState
foreign import moveChild :: forall a b. String -> EFn.EffectFn3 a b Int Unit
foreign import addViewToParent :: EFn.EffectFn1 InsertState Unit
foreign import setControllerStates :: String -> String -> Effect Unit
foreign import saveCanceller :: EFn.EffectFn3 String String (Effect Unit) Unit
foreign import getCurrentActivity :: Effect String
foreign import setUpBaseState :: String -> Foreign -> Effect Unit
foreign import render :: EFn.EffectFn1 String Unit
foreign import setPatchToActive :: String -> String -> Effect Unit
foreign import addToPatchQueue :: String -> String -> Effect Unit -> Effect Unit
foreign import getLatestMachine :: forall a b . EFn.EffectFn2 String String (Step a b)
foreign import storeMachine :: forall a b . EFn.EffectFn3 (Step a b) String String Unit


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
    
updateChildrenImpl :: String -> String -> Array UpdateActions -> Aff (Array Unit)
updateChildrenImpl namespace screenName =
  traverse
    \{action, parent, elem, index} ->
        case action of
          "add" -> do
              insertState <- liftEffect $ Efn.runEffectFn3 (addChildImpl namespace screenName) (encode elem) (encode parent) index
              domAllOut <- domAll {name : screenName, parent : Just namespace} (unsafeToForeign {}) insertState.dom
              liftEffect $ EFn.runEffectFn1 addViewToParent (insertState {dom = domAllOut})
          "move" -> liftEffect $ EFn.runEffectFn3 (moveChild namespace) elem parent index
          _ -> pure unit -- Should never reach here

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
