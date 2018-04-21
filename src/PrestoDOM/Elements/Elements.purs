module PrestoDOM.Elements.Elements
    ( Node
    , Leaf
    , element
    , keyed
    , linearLayout
    , relativeLayout
    , horizontalScrollView
    , scrollView
    , frameLayout
    , shimmerFrameLayout
    , tabLayout
    , imageView
    , editText
    , listView
    , progressBar
    , textView
    , viewPager
    , button
    , calendar
    , checkBox
    , switch
    , viewWidget
    , webView
    ) where


import Prelude

import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple)
import Halogen.VDom.DOM.Prop (Prop)
import PrestoDOM.Types.Core (ElemName(..), ElemSpec(..), VDom(..))

type Node i p
   = Array i
  -> Array (VDom (Array i) p)
  -> VDom (Array i) p

type Leaf i p
   = Array i
  -> VDom (Array i) p

element :: forall i p. ElemName -> Array (Prop i) -> Array (VDom (Array (Prop i)) p) -> VDom (Array (Prop i)) p
element elemName = Elem <<< ElemSpec Nothing elemName

keyed :: forall i p. ElemName -> Array (Prop i) -> Array (Tuple String (VDom (Array (Prop i)) p)) -> VDom (Array (Prop i)) p
keyed elemName = Keyed <<< ElemSpec Nothing elemName

node :: forall i p. String -> Node (Prop i) p
node elem = element (ElemName elem)

leaf :: forall i p. String -> Leaf (Prop i) p
leaf elem props = element (ElemName elem) props []



linearLayout :: forall i p. Node (Prop i) p
linearLayout = node "linearLayout"

relativeLayout :: forall i p. Node (Prop i) p
relativeLayout = node "relativeLayout"

horizontalScrollView :: forall i p. Node (Prop i) p
horizontalScrollView = node "horizontalScrollView"

scrollView :: forall i p. Node (Prop i) p
scrollView = node "scrollView"

frameLayout :: forall i p. Node (Prop i) p
frameLayout = node "frameLayout"

shimmerFrameLayout :: forall i p. Node (Prop i) p
shimmerFrameLayout = node "shimmerFrameLayout"

tabLayout :: forall i p. Node (Prop i) p
tabLayout = node "tabLayout"

viewPager :: forall i p. Node (Prop i) p
viewPager = node "viewPager"


imageView :: forall i p. Leaf (Prop i) p
imageView = leaf "imageView"

editText :: forall i p. Leaf (Prop i) p
editText = leaf "editText"

listView :: forall i p. Leaf (Prop i) p
listView = leaf "listView"

progressBar :: forall i p. Leaf (Prop i) p
progressBar = leaf "progressBar"

textView :: forall i p. Leaf (Prop i) p
textView = leaf "textView"

button :: forall i p. Leaf (Prop i) p
button = leaf "button"

calendar :: forall i p. Leaf (Prop i) p
calendar = leaf "calendar"

checkBox :: forall i p. Leaf (Prop i) p
checkBox = leaf "checkBox"

switch :: forall i p. Leaf (Prop i) p
switch = leaf "switch"

viewWidget :: forall i p. Leaf (Prop i) p
viewWidget = leaf "viewWidget"

webView :: forall i p. Leaf (Prop i) p
webView = leaf "webView"
