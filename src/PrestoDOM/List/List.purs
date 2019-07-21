module PrestoDOM.List
  ( ListItem(..)
  , ListData(..)
  , createListData
  , createListItem
  , list
  , listData
  , listItem
  , onItemClick
  , textHolder
  , colorHolder
  , imageUrlHolder
  , packageIconHolder
  , textSizeHolder
  , fontStyleHolder
  , backgroundHolder
  , visibilityHolder
  , alphaHolder
  ) where

import Prelude

import Data.Maybe (Maybe(..))
import Effect (Effect)
import Global.Unsafe (unsafeStringify)
import Halogen.VDom.DOM.Prop (Prop(..))
import PrestoDOM (ElemName(..), PropName(..), VDom, element)
import PrestoDOM.Core (_domAll)
import PrestoDOM.Events (makeEvent)
import PrestoDOM.Properties (prop)
import Web.Event.Event (EventType(..)) as DOM

foreign import _createListItem :: forall i p a b. VDom (Array (Prop i)) p -> (a -> b) -> String

-- | Stringified item view container
data ListItem = ListItem String

-- | Stringified item data container
data ListData = ListData String

-- | Encodes and constructs item data container
createListData :: forall i. Array i -> ListData
createListData vals = ListData (unsafeStringify vals)

-- | Encodes and constructs item view container
createListItem :: forall i p. VDom (Array (Prop i)) p -> ListItem
createListItem elem = ListItem (_createListItem elem _domAll)

-- | Elememt
-- | Flat list inflates the list using template (listItem) and data (listData) provided 
-- | for displaying very large list
list :: forall i p. Array (Prop i) -> VDom (Array (Prop i)) p
list props = element (ElemName "listView") props []

-- | Events
-- | Events supported by list item
onItemClick :: forall a. (a -> Effect Unit ) -> (Int -> a) -> Prop (Effect Unit)
onItemClick push f = Handler (DOM.EventType "onItemClick") (Just <<< (makeEvent (push <<< f)))

-- | Properties
-- | List template data property
listData :: forall i. ListData -> Prop i
listData (ListData val) = prop (PropName "listData") val

-- | List template item property
listItem :: forall i. ListItem -> Prop i
listItem (ListItem val) = prop (PropName "listItem") val

-- | Following properties create a property holder value which is referenced from item data
textHolder :: forall i. String -> Prop i
textHolder = prop (PropName "holder_text")

imageUrlHolder :: forall i. String -> Prop i
imageUrlHolder = prop (PropName "holder_imageUrl")

packageIconHolder :: forall i. String -> Prop i
packageIconHolder = prop (PropName "holder_packageIcon")

backgroundHolder :: forall i. String -> Prop i
backgroundHolder = prop (PropName "holder_background")

colorHolder :: forall i. String -> Prop i
colorHolder = prop (PropName "holder_color")

visibilityHolder :: forall i. String -> Prop i
visibilityHolder = prop (PropName "holder_visibility")

textSizeHolder :: forall i. String -> Prop i
textSizeHolder = prop (PropName "holder_textSize")

fontStyleHolder :: forall i. String -> Prop i
fontStyleHolder = prop (PropName "holder_fontStyle")

alphaHolder :: forall i. String -> Prop i
alphaHolder = prop (PropName "holder_alpha")

