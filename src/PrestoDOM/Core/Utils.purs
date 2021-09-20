module PrestoDOM.Core.Utils where

import Prelude

import Data.Array (catMaybes, snoc, zipWith)
import Data.Either (hush, Either(..))
import Data.Maybe (Maybe (..), fromMaybe)
import Data.Foldable (foldl)
import Data.Traversable (traverse)
import Effect (Effect)
import Effect.Aff(Aff, makeAff, nonCanceler, Fiber, forkAff)
import Effect.Ref (Ref, new, modify)
import Foreign (Foreign, unsafeToForeign)
import Foreign.Class (encode, decode, class Decode)
import Foreign.Generic (decodeJSON)
import Foreign.Object (Object, empty, insert, delete, lookup, union)
import Foreign.Object (foldM) as Object
import PrestoDOM.Core.Types (NameSpaceState, VdomTree, NodeTree(..), MicroappData)
import PrestoDOM.Types.Core (PrestoDOM)
import PrestoDOM.Elements.Elements (relativeLayout)
import PrestoDOM.Properties (root, id, height, width)
import PrestoDOM.Types.DomAttributes (Length (..))
import Halogen.VDom.DOM.Prop(PropValue)
import Control.Monad.Except (runExcept)
import Unsafe.Coerce (unsafeCoerce)
import Web.DOM.Node (Node) as DOM
import Effect.Uncurried as EFn

foreign import saveRefToStateImpl :: forall w i. String -> Ref (NameSpaceState w i) -> Effect Unit
foreign import loadRefFromStateImpl :: forall w i.  String -> (Maybe (Ref (NameSpaceState w i))) -> ((Ref (NameSpaceState w i)) -> Maybe (Ref (NameSpaceState w i))) -> Effect (Maybe (Ref (NameSpaceState w i)))
foreign import createPrestoElement :: Effect {__id :: Int}


foreign import callbackMapper :: forall a. (EFn.EffectFn1 a Unit) -> String
foreign import generateCommands :: VdomTree -> Foreign
foreign import generateAndCheckRequestId :: Foreign -> Object Foreign -> Effect Unit
foreign import callMicroAppListItem :: forall a b. String -> a -> (b -> Effect Unit) -> Effect (Effect Unit)
foreign import callMicroApp :: forall a. String -> Foreign -> a -> (Foreign -> Effect Unit) -> Foreign -> String -> String -> Effect (Effect Unit)
foreign import getLatestListData :: Foreign -> Effect (Array (Array (Object Foreign)))
foreign import os :: String
foreign import replayListFragmentCallbacks' :: forall a. String -> String -> (a -> Effect Unit) -> Effect (Effect Unit)

-- hack, should be effect, but behaviour is same, even if gets cached
foreign import setDebounceToCallback :: String -> String

callMicroAppList :: forall a. String -> a -> (Foreign -> Effect Unit) -> Effect (Effect Unit)
callMicroAppList = callMicroAppListItem

saveRefToState :: forall w i. String -> Ref (NameSpaceState w i) -> Effect Unit
saveRefToState = saveRefToStateImpl

loadRefFromState :: forall w i. String -> Effect (Maybe (Ref (NameSpaceState w i)))
loadRefFromState key = loadRefFromStateImpl key Nothing Just

sanitiseNamespace :: Maybe String -> String
sanitiseNamespace = fromMaybe "default"

createNameSpaceState :: forall w i. String -> Maybe String -> Effect (NameSpaceState w i)
createNameSpaceState namespace id = do
  root <- createRoot
  pure $
    { id : id
    , root : root.root
    , machineMap : empty
    , screenStack : []
    , hideList : []
    , removeList : []
    , screenCache : []
    , screenHideCallbacks : empty
    , screenShowCallbacks : empty
    , screenRemoveCallbacks : empty
    , cancelers : empty
    , stackRoot : root.stackRoot
    , cacheRoot : root.cacheRoot
    , animations :
        { entry : empty
        , exit : empty
        , entryF : empty
        , exitF : empty
        , entryB : empty
        , exitB : empty
        , animationStack : []
        , animationCache : []
        , lastAnimatedScreen : Nothing
        }
    , registeredEvents : empty
    , shouldHideCacheRoot : false
    , mappQueue : []
    , fragmentCallbacks : empty
    , shouldReplayCallbacks : empty
    , eventIOs : empty
    }

createRoot :: forall w i. Effect { stackRoot :: Int, cacheRoot :: Int, root :: PrestoDOM w i}
createRoot = do
  rootElem <- createPrestoElement
  stackRoot <- createPrestoElement
  cacheRoot <- createPrestoElement
  pure $
    { stackRoot : stackRoot.__id
    , cacheRoot : cacheRoot.__id
    , root :
        relativeLayout
          [ id $ show rootElem.__id
          , root true
          , height MATCH_PARENT
          , width MATCH_PARENT
          ]
          [ relativeLayout
              [ id $ show stackRoot.__id
              , height MATCH_PARENT
              , width MATCH_PARENT
              ][]
          , relativeLayout
              [ id $ show cacheRoot.__id
              , height MATCH_PARENT
              , width MATCH_PARENT
              ][]
          ]
    }

setUpBaseState :: String -> Maybe String -> Effect Unit
setUpBaseState nameSpace id =
  loadRefFromState nameSpace >>=
    case _ of
      Just value ->
        -- Ignore; initUI was done before
        pure unit
      Nothing ->
        createNameSpaceState nameSpace id
          >>= new
          >>= saveRefToState nameSpace


-- TODO Make Root into VDOM
domAll :: DOM.Node -> String -> String -> Effect Unit
domAll vdom screenName namespace = do
  stateRef <- loadRefFromState namespace
  _ <- case stateRef, hush $ runExcept $ decode $ unsafeToForeign vdom of
    Just ref, Just v -> extractView ref Nothing v
    _, _ -> pure Nothing

    -- Add id
    -- Add root true if parent is null
    -- _ <- extractView Nothing vdom

    -- Duplicate Id detection logic
    -- Fragment caching
    -- OS ANDROID / IOS
        -- DELETE AFTER RENDER
        -- CACHE ANIMATIONS
        -- OS ANDROID
            -- DELETE PROP FOCUS FALSE
    -- OS WEB
        -- onResize to window.resizeEvent
  pure unit


extractView :: forall i w. Ref (NameSpaceState w i) -> Maybe String -> NodeTree -> Effect (Maybe Foreign)
extractView ref parentType (NodeTree nd@{props : p, children : c, "type" : "microapp"}) = do
  cacheMappPayload ref (NodeTree nd)
  extractView ref parentType $ NodeTree $ nd { "type" = "relativeLayout" }
extractView ref parentType (NodeTree {props : p, children : c, "type" :t}) = do
  children <- catMaybes <$> (extractView ref (Just t) `traverse` c)
  props <- p # checkAndAddRoot parentType
    # checkAndAddId
    <#> checkAndDeleteFocus
  pure $ Just $ generateCommands
    { "type" : t
    , props : p
    , children : children
    , parentType : encode parentType
    , __ref : Nothing
    , service : Nothing
    , requestId : Nothing
    }
extractView _ _ _ = pure Nothing

--   = Attribute (Maybe Namespace) String String
--   | Property String PropValue
--   | Handler DOM.EventType (DOM.Event → Maybe a)
--   | Ref (ElemRef DOM.Element → Maybe a)
--   | BHandler String (Unit -> Maybe a)
--   | Payload String

propToForeign :: PropValue -> Foreign
propToForeign = unsafeCoerce

-- Check parentType and decide whether to add root true
checkAndAddRoot :: Maybe String -> Object Foreign -> Object Foreign
checkAndAddRoot Nothing object = object
checkAndAddRoot (Just _) object = insert "root" (encode true) object

checkAndAddId :: Object Foreign -> Effect (Object Foreign)
checkAndAddId object = do
  lookup "id" object
    # case _ of
        Just _ -> pure object
        Nothing -> do
          id <- createPrestoElement
          pure $ insert "id" (encode id.__id) object

checkAndDeleteFocus :: Object Foreign -> Object Foreign
checkAndDeleteFocus object
  | os == "ANDROID" = do
      extractAndDecode "focus" object
        # case _ of
            Just false -> delete "focus" object
            _ -> object
  | otherwise = object

checkAndDeleteAfterRender :: Object Foreign -> Object Foreign
checkAndDeleteAfterRender object
  | os == "WEB" = object
  | otherwise = delete "afterRender" object

extractAndDecode :: forall a. Decode a => String -> Object Foreign -> Maybe a
extractAndDecode a = hush <<< runExcept <<< decode <=< lookup a

extractJsonAndDecode :: forall a. Decode a => String -> Object Foreign -> Maybe a
extractJsonAndDecode a = hush <<< runExcept <<< decodeJSON <=< extractAndDecode a

cacheMappPayload :: forall i w. Ref (NameSpaceState w i) -> NodeTree -> Effect Unit
cacheMappPayload ref (NodeTree {requestId: (Just req), service: (Just ser), props : p}) =
  case extractAndDecode "payload" p, extractAndDecode "id" p of
    Just payload, Just id -> do
      let (mapp :: MicroappData) = { payload : payload
              , viewGroupTag : fromMaybe "main" $ extractAndDecode "viewGroupTag" p
              , requestId : req
              , service : ser
              , elemId : id
              , callback : fromMaybe (unsafeCoerce $ (\_ -> pure unit :: Effect Unit)) $ unsafeCoerce <$> lookup "onMicroappResponse" p
              -- TODO
              -- 1) Make optional -- DONE
              -- 2) Make safe -- HALF DONE :thinkingface
              }
      _ <- modify (\state -> state {mappQueue = snoc state.mappQueue mapp}) ref
      pure unit
    _, _ -> pure unit
cacheMappPayload ref _ = pure unit

-- cacheAnimationPaylod :: forall i w. Ref (NameSpaceState w i) -> NodeTree -> Effect Unit
-- cacheAnimationPaylod ref (NodeTree {requestId: (Just req), service: (Just ser), props : p}) =
  -- read the 6 animation props
  -- cache if present

  -- Override onAnimationEnd

-- Async Prop Validation Functions
-- first cut covers only android
foreign import checkFontisPresent :: String -> (Boolean -> Effect Unit) -> Effect Unit
foreign import checkImageisPresent :: String -> (Boolean -> Effect Unit) -> Effect Unit

verifyFont :: Maybe String -> Aff (Maybe Foreign)
verifyFont Nothing = pure Nothing
verifyFont (Just a) =
  makeAff (\cb -> checkFontisPresent a (Right >>> cb) $> nonCanceler)
    <#> if _
          then Just $ encode a
          else Nothing

verifyImage :: Maybe String -> Aff (Maybe Foreign)
verifyImage Nothing = pure Nothing
verifyImage (Just a) =
  makeAff (\cb -> checkImageisPresent a (Right >>> cb) $> nonCanceler)
    <#> if _
          then Just $ encode a
          else Nothing

forkoutListState :: String -> String -> String -> Object Foreign -> Aff (Fiber (Maybe (Array (Object Foreign))))
forkoutListState namespace screenName "listView" props = do
  let keys = do
        id <- lookup "id" props
        listData <- extractAndDecode "listData" props
        pure {id, listData}
  let payloads = extractJsonAndDecode "payload" props
  let mapp = fromMaybe (encode $ unit) $ lookup "onMicroappResponse" props
  case keys, payloads of
    Just {id, listData}, Just justPayloads -> forkAff $ Just <$> callMicroAppsForListState id namespace screenName listData justPayloads mapp
    Just {id, listData}, _ -> forkAff $ pure $ Just listData
    Nothing, _ -> forkAff $ pure Nothing
forkoutListState _ _ _ _ = forkAff $ pure Nothing


callMicroAppsForListState :: Foreign -> String -> String -> (Array (Object Foreign)) -> Object Foreign -> Foreign -> Aff (Array (Object Foreign))
callMicroAppsForListState id namespace screenName listData microappPayloads mappCallback = do
  -- generateAndCheckRequestId id microappPayloads
  Object.foldM (callSingle id mappCallback namespace screenName) listData microappPayloads
  -- GET ID; CREATE REQUESTID AGAINST VIEW ID + MAPP
  -- UPDATE VIEW ID
  -- LOOP ON ALL PAYLOADS TO CALL ALL MAPPS IN PARALLEL
  -- AWAIT ALL RESULTS TO COMPLETE THE AFF EXECUTION
  -- MERGE ALL RECIEVED OBJECTS INTO THE LIST:DATA
  -- MIGHT NEED TO CONSIDER SCOPEING KEYS WITH MAPP NAMES IN BOTH
  -- LIST ITEM HOLDERS AND LIST ITEM STATE

callSingle :: Foreign ->  Foreign -> String -> String -> (Array (Object Foreign)) -> String -> Foreign -> Aff (Array (Object Foreign))
callSingle id mappCallback namespace screenName  acc service payload = do
  (response :: Array (Object Foreign)) <- (fromMaybe acc <<< hush <<< runExcept <<< decode) <$> (makeAff (\cb -> callMicroApp service id payload (cb <<< Right) mappCallback namespace screenName $> nonCanceler))
  pure $ zipWith union acc response

getListData :: Foreign -> Array (Object Foreign) -> Effect (Array (Object Foreign))
getListData id listData = do
  cachedData <- getLatestListData id
  pure $ foldl mergeListData listData cachedData

mergeListData :: Array (Object Foreign) -> Array (Object Foreign) -> Array (Object Foreign)
mergeListData acc payload = zipWith union acc payload