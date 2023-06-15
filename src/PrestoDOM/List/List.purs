module PrestoDOM.List
  ( ListItem(..)
  , ListData(..)
  , ImageSource(..)
  , AnimationHolder(..)
  , createListData
  , createListItem
  , createOnclick
  , list
  , listDataV2
  , listItem
  , onItemClick
  , onClickHolder
  , textHolder
  , colorHolder
  , imageUrlHolder
  , primaryKeyHolder
  , packageIconHolder
  , textSizeHolder
  , textSizeSpHolder
  , fontStyleHolder
  , backgroundHolder
  , visibilityHolder
  , alphaHolder
  , clickableHolder
  , textFromHtmlHolder
  , preComputeListItem
 , renderImageSource
  , preComputeListItemWithFragment
  , animationSetHolder
  , testIdHolder
  ) where

import Prelude

import Control.Monad.Except (runExcept)
import Data.Array (catMaybes, cons)
import Data.Either (Either(..), hush)
import Foreign.NullOrUndefined (undefined)
import Data.Foldable (foldr, foldM)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.String.CodePoints (drop, contains)
import Data.String.Pattern (Pattern(..))
import Data.Traversable (traverse)
import Data.Tuple (snd)
import Effect (Effect)
import Effect.Aff (effectCanceler, makeAff)
import Effect.Class (liftEffect)
import Effect.Ref (Ref, new, read, modify) as Ref
import Effect.Uncurried as EFn
import Foreign (Foreign, unsafeToForeign)
import Foreign.Class (encode, decode)
import Foreign.Object (Object, alter, empty, fromHomogeneous, insert, singleton, union, update)
import Halogen.VDom.DOM.Prop (Prop(..), PropValue) as P
import Halogen.VDom.Types (VDom(..), ElemName(..))
import Presto.Core.Flow (Flow, doAff)
import Presto.Core.Types.API (class StandardEncode, standardEncode)
import PrestoDOM (PropName(..))
import PrestoDOM.Animation (AnimProp)
import PrestoDOM.Core.Types (ListItemType, VdomTree)
import PrestoDOM.Core.Utils (callbackMapper, setDebounceToCallback, callMicroAppList, generateCommands,extractAndDecode)
import PrestoDOM.Core (createPrestoElement)
import PrestoDOM.Elements.Elements (element)
import PrestoDOM.Events (makeEvent)
import PrestoDOM.Properties (prop)
import PrestoDOM.Types.Core (toPropValue, PrestoDOM)
import Type.Row.Homogeneous (class Homogeneous)
import Unsafe.Coerce (unsafeCoerce)
import Web.Event.Event (EventType(..)) as DOM

preComputeListItem :: forall i p a. VDom (Array (P.Prop i)) p -> Flow a ListItem
preComputeListItem = preComputeListItemWithFragment Nothing

createListItem :: forall i p a. VDom (Array (P.Prop i)) p -> Flow a ListItem
createListItem = preComputeListItem

getBaseId :: Effect Int
getBaseId = (_.__id) <$> unsafeCoerce createPrestoElement

preComputeListItemWithFragment :: forall i p a. Maybe String -> VDom (Array (P.Prop i)) p -> Flow a ListItem
preComputeListItemWithFragment parentType dom = do
  hv <- doAff do liftEffect $ Ref.new []
  kpm <- doAff do liftEffect $ Ref.new empty
  klm <- doAff do liftEffect $ Ref.new empty
  aim <- doAff do liftEffect $ Ref.new empty
  itemView <- extractView hv kpm klm aim (encode parentType) dom
  holderViews <- doAff do liftEffect $ Ref.read hv
  keyPropMap <- doAff do liftEffect $ Ref.read kpm
  keyIdMap <- doAff do liftEffect $ Ref.read klm
  animationIdMap <- doAff do liftEffect $ Ref.read aim
  pure $ mkListItem {itemView : encode itemView, holderViews, keyPropMap, keyIdMap, animationIdMap}

-- Store non holder key names, against view Id
-- in update properties, map keys against prop name
-- get runInUI cmd for each key
-- replace value of the holder prop
-- test samples can be expand or textFromHtml

-- allowedHolderProps :: Array String
-- allowedHolderProps = ["background", "text", "color", "imageUrl", "visibility", "fontStyle", "textSize", "packageIcon", "alpha", "onClick", "primaryKey"]

mkListItem :: ListItemType -> ListItem
mkListItem = unsafeCoerce

getValueFromListItem :: ListItem -> ListItemType
getValueFromListItem = unsafeCoerce

extractView :: forall i p a. Ref.Ref (Array (Object Foreign)) -> Ref.Ref (Object (Object String)) -> Ref.Ref (Object String) -> Ref.Ref (Object Foreign) -> Foreign -> VDom (Array (P.Prop i)) p -> Flow a (Maybe Foreign)
extractView hv kpm klm aim parentType (Elem _ (ElemName name) p c) = do
  children <- catMaybes <$> (extractView hv kpm klm aim (encode $ (Nothing :: Maybe String)) `traverse` c)
  props <- addRunInUI hv =<< foldM (parseProps hv kpm klm aim) {id : Nothing , props : empty} p
  pure $ Just $ generateCommands undefined $ encode
    ({ "type" : name
    , props : props
    , children : children
    , parentType
    , __ref : Nothing
    , service : Nothing
    , requestId : Nothing
    , elemType : Nothing
    , keyId : Nothing
    } :: VdomTree)
extractView hv kpm klm aim parentType (Keyed _ (ElemName name) p c) = do
  children <- catMaybes <$> ((extractView hv kpm klm aim (encode $ (Nothing :: Maybe String)) <<< snd) `traverse` c)
  props <- addRunInUI hv =<< foldM (parseProps hv kpm klm aim) {id : Nothing , props : empty} p
  pure $ Just $ generateCommands undefined $ encode
    ({ "type" : name
    , props : props
    , children : children
    , parentType
    , __ref : Nothing
    , service : Nothing
    , requestId : Nothing
    , elemType : Nothing
    , keyId : Nothing
    } :: VdomTree)
extractView hv kpm klm aim parentType (Microapp s p ch) = do
  children' <- catMaybes <$> (extractView hv kpm klm aim (encode $ (Nothing :: Maybe String)) `traverse` (fromMaybe [] ch))
  props <- addRunInUI hv =<< foldM (parseProps hv kpm klm aim) {id : Nothing , props : empty} p
  let useLinearLayout = case (extractAndDecode "useLinearLayout" props) of --value is Maybe a
        Just a -> a
        Nothing -> false
  listItem_ <- hush <<< runExcept <<< decode <$> (doAff $ makeAff $ \cb -> callMicroAppList s props (cb <<< Right) <#> effectCanceler)
  children <- case listItem_ of
    Just ({holderViews, itemView, keyPropMap, keyIdMap, animationIdMap} :: ListItemType) -> do
        _ <- doAff $ liftEffect $ Ref.modify (flip append holderViews ) hv
        _ <- doAff $ liftEffect $ Ref.modify (flip append keyPropMap ) kpm
        _ <- doAff $ liftEffect $ Ref.modify (flip append keyIdMap ) klm
        _ <- doAff $ liftEffect $ Ref.modify (union animationIdMap ) aim
        pure $ children' <> [itemView]
    _ -> pure []
  pure $ Just $ generateCommands undefined $ encode
    ({ "type" : if useLinearLayout then "linearLayout" else "relativeLayout"
    , props : props
    , children : children
    , parentType
    , __ref : Nothing
    , service : Just s
    , requestId : Nothing
    , elemType : Nothing
    , keyId : Nothing
    } :: VdomTree)
extractView _ _ _ _ _ _ = pure Nothing

getId :: Ref.Ref (Object (Object String)) -> Maybe Int -> Effect Int
getId _ (Just i) = pure i
getId kpm Nothing = do
  i <- getBaseId
  _ <- Ref.modify (insert (show i) empty) kpm
  pure i

parseProps :: forall i a. Ref.Ref (Array (Object Foreign)) -> Ref.Ref (Object (Object String)) -> Ref.Ref (Object String) -> Ref.Ref (Object Foreign)-> {id :: Maybe Int, props :: Object Foreign} -> P.Prop i -> Flow a ({id :: Maybe Int, props :: Object Foreign})
parseProps hv kpm klm aim obj a = do
  i <- doAff do liftEffect $ getId kpm obj.id
  let object = obj { props = insert "id" (unsafeToForeign i) obj.props, id = Just i}
  parsePropsw hv kpm klm aim object a

parsePropsw :: forall i a. Ref.Ref (Array (Object Foreign)) -> Ref.Ref (Object (Object String)) -> Ref.Ref (Object String) -> Ref.Ref (Object Foreign)-> {id :: Maybe Int, props :: Object Foreign} -> P.Prop i -> Flow a ({id :: Maybe Int, props :: Object Foreign})
parsePropsw hv kpm klm aim obj (P.Property a b)
  | a == "holder_inlineAnimation" = do
      i <- doAff do liftEffect $ getId kpm obj.id
      _ <- doAff do liftEffect $ Ref.modify (insert (unsafeCoerce b) (show i)) klm
      _ <- doAff do liftEffect $ Ref.modify (insert (show i) (unsafeCoerce b)) aim
      let object = insert (drop 7 a) (encode $ "inlineAnimation" <> (show i)) $ singleton "id" (encode i)
      _ <- doAff do liftEffect $ Ref.modify (cons object) hv
      pure $ obj { props = insert "id" (unsafeToForeign i) obj.props, id = Just i}
  | contains (Pattern "holder_") a = do
      i <- doAff do liftEffect $ getId kpm obj.id
      _ <- doAff do liftEffect $ Ref.modify (insert (unsafeCoerce b) (show i)) klm
      _ <- doAff do liftEffect $ Ref.modify (update (Just <<< insert (unsafeCoerce b) (drop 7 a)) (show i)) kpm
      let object = insert (drop 7 a) (unsafeToForeign b) $ singleton "id" (encode i)
      _ <- doAff do liftEffect $ Ref.modify (cons object) hv
      pure $ obj { props = insert "id" (unsafeToForeign i) obj.props, id = Just i}
  | otherwise = pure $ obj { props = insert a (unsafeToForeign b) obj.props}
parsePropsw _ _ _ _ obj (P.Payload a) =
  pure $ obj { props = insert "payload" (unsafeToForeign a) obj.props}
parsePropsw _ _ _ _ obj _ = pure $ obj

addRunInUI :: forall a. Ref.Ref (Array (Object Foreign)) -> {id :: Maybe Int, props :: Object Foreign} -> Flow a (Object Foreign)
addRunInUI hv {id:(Just i), props} = doAff $ liftEffect do
  -- TODO Add this only if props need runInUI
  _ <- Ref.read hv
  let object = insert "runInUI" (encode $ "runInUI" <> (show i)) $ singleton "id" (encode i)
  _ <- Ref.modify (cons object) hv
  pure props
addRunInUI _ {props} = pure props

-- | Stringified item view container
foreign import data ListItem :: Type

instance encodeListItem :: StandardEncode ListItem where
  standardEncode = standardEncode <<< getValueFromListItem

-- | Stringified item data container
data ListData = ListData String

data ImageSource =
  ImageName String | ImagePath String | ImageResId Int | ImageUrl String String

-- | Encodes and constructs item data container
createListData :: forall i. Array i -> Array i
createListData vals = vals

-- | Elememt
-- | Flat list inflates the list using template (listItem) and data (listData) provided
-- | for displaying very large list
list :: forall i p. Array (P.Prop i) -> VDom (Array (P.Prop i)) p
list props = element (ElemName "listView") props []

-- | Events
-- | Events supported by list item
onItemClick :: forall a. (a -> Effect Unit ) -> (Int -> a) -> P.Prop (Effect Unit)
onItemClick push f = P.Handler (DOM.EventType "onItemClick") (Just <<< (makeEvent (push <<< f)))

-- | Properties
-- | List template data property
-- listData :: forall i. ListData -> P.Prop i
-- listData (ListData val) = prop (PropName "listData") val

-- | Properties
-- | List template data property
listDataV2 :: forall i r. Homogeneous r P.PropValue => Array (Record r) -> P.Prop i
listDataV2 val = P.ListData $ fromHomogeneous <$> val

-- | List template item property
listItem :: forall i. ListItem -> P.Prop i
-- EVALUATE IF THISIS THE CORRECT PLACE TO ENCODE A PROP
listItem val = P.Nopatch "listItem" $ toPropValue $ encode $ getValueFromListItem val

onClickHolder :: forall action i. (action -> Effect Unit) -> (Int -> action) -> P.Prop i
onClickHolder push action = prop (PropName "holder_onClick") $ createOnclick $ push <<< action

createOnclick :: (Int -> Effect Unit) -> String
createOnclick = setDebounceToCallback <<< callbackMapper <<< EFn.mkEffectFn1

-- | Following properties create a property holder value which is referenced from item data
testIdHolder :: forall i. String -> P.Prop i
testIdHolder = prop (PropName "holder_testID")

textHolder :: forall i. String -> P.Prop i
textHolder = prop (PropName "holder_text")

primaryKeyHolder :: forall i. String -> P.Prop i
primaryKeyHolder = prop (PropName "holder_primaryKey")

imageUrlHolder :: forall i. String -> P.Prop i
imageUrlHolder = prop (PropName "holder_imageUrl")

packageIconHolder :: forall i. String -> P.Prop i
packageIconHolder = prop (PropName "holder_packageIcon")

backgroundHolder :: forall i. String -> P.Prop i
backgroundHolder = prop (PropName "holder_background")

colorHolder :: forall i. String -> P.Prop i
colorHolder = prop (PropName "holder_color")

visibilityHolder :: forall i. String -> P.Prop i
visibilityHolder = prop (PropName "holder_visibility")

textSizeHolder :: forall i. String -> P.Prop i
textSizeHolder = prop (PropName "holder_textSize")

textSizeSpHolder :: forall i. String -> P.Prop i
textSizeSpHolder = prop (PropName "holder_textSizeSp")

fontStyleHolder :: forall i. String -> P.Prop i
fontStyleHolder = prop (PropName "holder_fontStyle")

alphaHolder :: forall i. String -> P.Prop i
alphaHolder = prop (PropName "holder_alpha")

clickableHolder :: forall i. String -> P.Prop i
clickableHolder = prop (PropName "holder_clickable")

textFromHtmlHolder :: forall i. String -> P.Prop i
textFromHtmlHolder = prop (PropName "holder_textFromHtml")

renderImageSource :: ImageSource -> String
renderImageSource imgSrc =
  case imgSrc of
    ImageUrl url placeholder -> "url->" <> url <> "," <>  placeholder
    ImagePath path           -> "path->" <> path
    ImageResId resId         -> "resId->" <> show resId
    ImageName name           -> name


data AnimationHolder = AnimationHolder (Array AnimProp) String

animationSetHolder :: forall w. Array AnimationHolder -> (PrestoDOM (Effect Unit) w) -> PrestoDOM (Effect Unit) w
animationSetHolder = animationSetHolderImpl "holder_inlineAnimation"

-- | Animation set is a composible animation view
-- | It applies the set of animations on the provided view
animationSetHolderImpl :: forall w. String -> Array AnimationHolder -> PrestoDOM (Effect Unit) w -> PrestoDOM (Effect Unit) w
animationSetHolderImpl propName animations view = do
  case view of
    Elem ns eName props child -> do
      let newProps = props <> [prop (PropName propName) filterAnimations] <> [prop (PropName "hasAnimation") "true"]
      Elem ns eName newProps child
    Keyed ns eName props child -> do
      let newProps = props <> [prop (PropName propName) filterAnimations] <> [prop (PropName "hasAnimation") "true"]
      Keyed ns eName newProps child
    _ -> view

  where
    filterAnimations = foldr
                          (\(AnimationHolder anims holder) b -> alter (updateHolder anims) holder b)
                          empty
                          animations

    updateHolder a (Just arr) = Just $ arr <> [a]
    updateHolder a _ = Just [a]
