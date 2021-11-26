module PrestoDOM.Elements.Elements
    ( Node
    , Leaf
    , element
    , keyed

    , linearLayout_
    , relativeLayout_

    , bottomSheetLayout
    , coordinatorLayout
    , swipeRefreshLayout
    , linearLayout
    , mapp
    , mappWithLoader
    , relativeLayout
    , horizontalScrollView
    , scrollView
    , frameLayout
    , shimmerFrameLayout
    , tabLayout
    , lottieAnimationView
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



import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple)
import Halogen.VDom.DOM.Prop (Prop)
import PrestoDOM.Types.Core (ElemName(..), VDom(..), Namespace)

type Node i p
   = Array i
  -> Array (VDom (Array i) p)
  -> VDom (Array i) p

type Leaf i p
   = Array i
  -> VDom (Array i) p

rootElement
    :: forall i p
     . Namespace
    -> ElemName
    -> Array (Prop i)
    -> Array (VDom (Array (Prop i)) p)
    -> VDom (Array (Prop i)) p
rootElement screenName elemName = Elem (Just screenName) elemName

element :: forall i p. ElemName -> Array (Prop i) -> Array (VDom (Array (Prop i)) p) -> VDom (Array (Prop i)) p
element elemName = Elem Nothing elemName

keyed :: forall i p. ElemName -> Array (Prop i) -> Array (Tuple String (VDom (Array (Prop i)) p)) -> VDom (Array (Prop i)) p
keyed elemName = Keyed Nothing elemName

node :: forall i p. String -> Node (Prop i) p
node elem = element (ElemName elem)

leaf :: forall i p. String -> Leaf (Prop i) p
leaf elem props = node elem props []



linearLayout_ :: forall i p. Namespace -> Node (Prop i) p
linearLayout_ screenName = rootElement screenName (ElemName "linearLayout")

relativeLayout_ :: forall i p. Namespace -> Node (Prop i) p
relativeLayout_ screenName = rootElement screenName (ElemName "relativeLayout")



linearLayout :: forall i p. Node (Prop i) p
linearLayout = node "linearLayout"

coordinatorLayout :: forall i p. Node (Prop i) p
coordinatorLayout = node "coordinatorLayout"

bottomSheetLayout :: forall i p. Node (Prop i) p
bottomSheetLayout = node "bottomSheetLayout"

swipeRefreshLayout :: forall i p. Node (Prop i) p
swipeRefreshLayout = node "swipeRefreshLayout"

relativeLayout :: forall i p. Node (Prop i) p
relativeLayout = node "relativeLayout"

horizontalScrollView :: forall i p. Node (Prop i) p
horizontalScrollView = node "horizontalScrollView"

listView :: forall i p. Node (Prop i) p
listView = node "listView"

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



lottieAnimationView :: forall i p. Leaf (Prop i) p
lottieAnimationView = leaf "lottieAnimationView"

imageView :: forall i p. Leaf (Prop i) p
imageView = leaf "imageView"

editText :: forall i p. Leaf (Prop i) p
editText = leaf "editText"

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

mapp :: forall i p. String -> Array (Prop i) -> VDom (Array (Prop i)) p
mapp service a = Microapp service a Nothing

mappWithLoader :: forall i p. String -> Array (Prop i) -> Array (VDom (Array (Prop i)) p) -> VDom (Array (Prop i)) p
mappWithLoader service a ch = Microapp service a (Just ch)