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
  , textSizeHolder
  , fontStyleHolder
  , backgroundHolder
  , visibilityHolder
  ) where

import Prelude

import Data.Maybe (Maybe(..))
import Effect (Effect)
import Global.Unsafe (unsafeStringify)
import Halogen.VDom.DOM.Prop (Prop(..))
import PrestoDOM (ElemName(..), PrestoDOM, PropName(..), element)
import PrestoDOM.Properties (prop)
import Web.Event.Event (EventType(..), Event) as DOM
import Unsafe.Coerce as U

foreign import _createListItem :: forall a b. PrestoDOM -> (a -> b) -> String

foreign import _domAll :: forall a b. a -> b

makeEvent :: forall a. (a -> Effect Unit ) -> (DOM.Event → Effect Unit)
makeEvent push = \ev -> do
    _ <- push (U.unsafeCoerce ev)
    pure unit

-- | Stringified item view container
data ListItem = ListItem String

-- | Stringified item data container
data ListData = ListData String

-- | Encodes and constructs item data container
createListData :: forall i. Array i -> ListData
createListData vals = ListData (unsafeStringify vals)

-- | Encodes and constructs item view container
createListItem :: PrestoDOM -> ListItem
createListItem elem = ListItem (_createListItem elem _domAll)

-- | Elememt
-- | Flat list inflates the list using template (listItem) and data (listData) provided 
-- | for displaying very large list
list :: Array (Prop (Effect Unit)) -> PrestoDOM
list props = element (ElemName "listView") props []

-- | Events
-- | Events supported by list item
onItemClick :: forall a. (a -> Effect Unit) -> (Int -> a) -> Prop (Effect Unit)
onItemClick push f = Handler (DOM.EventType "onItemClick") (Just <<< (makeEvent (push <<< f)))

-- | Properties
-- | List template data property
listData :: ListData -> Prop (Effect Unit)
listData (ListData val) = prop (PropName "listData") val

-- | List template item property
listItem :: ListItem -> Prop (Effect Unit)
listItem (ListItem val) = prop (PropName "listItem") val

-- | Following properties create a property holder value which is referenced from item data
textHolder :: String -> Prop (Effect Unit)
textHolder = prop (PropName "holder_text")

imageUrlHolder :: String -> Prop (Effect Unit)
imageUrlHolder = prop (PropName "holder_imageUrl")

backgroundHolder :: String -> Prop (Effect Unit)
backgroundHolder = prop (PropName "holder_background")

colorHolder :: String -> Prop (Effect Unit)
colorHolder = prop (PropName "holder_color")

visibilityHolder :: String -> Prop (Effect Unit)
visibilityHolder = prop (PropName "holder_visibility")

textSizeHolder :: String -> Prop (Effect Unit)
textSizeHolder = prop (PropName "holder_textSize")

fontStyleHolder :: String -> Prop (Effect Unit)
fontStyleHolder = prop (PropName "holder_fontStyle")
