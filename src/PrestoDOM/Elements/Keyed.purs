module PrestoDOM.Elements.Keyed
    ( KeyedNode
    , linearLayout
    , relativeLayout
    , horizontalScrollView
    , listView
    , frameLayout
    , shimmerFrameLayout
    , tabLayout
    , viewPager
    , scrollView
    , flexBoxLayout
    ) where

import Data.Tuple (Tuple)
import Halogen.VDom (ElemName(ElemName), VDom)
import Halogen.VDom.DOM.Prop (Prop)
import PrestoDOM.Elements.Elements (keyed)

type KeyedNode i p
   = Array i
  -> Array (Tuple String (VDom (Array i) p))
  -> VDom (Array i) p


keyedNode :: forall i p. String -> KeyedNode (Prop i) p
keyedNode elem = keyed (ElemName elem)


linearLayout :: forall i p. KeyedNode (Prop i) p
linearLayout = keyedNode "linearLayout"

relativeLayout :: forall i p. KeyedNode (Prop i) p
relativeLayout = keyedNode "relativeLayout"

horizontalScrollView :: forall i p. KeyedNode (Prop i) p
horizontalScrollView = keyedNode "horizontalScrollView"

listView :: forall i p. KeyedNode (Prop i) p
listView = keyedNode "listView"

frameLayout :: forall i p. KeyedNode (Prop i) p
frameLayout = keyedNode "frameLayout"

shimmerFrameLayout :: forall i p. KeyedNode (Prop i) p
shimmerFrameLayout = keyedNode "shimmerFrameLayout"

tabLayout :: forall i p. KeyedNode (Prop i) p
tabLayout = keyedNode "tabLayout"

viewPager :: forall i p. KeyedNode (Prop i) p
viewPager = keyedNode "viewPager"

scrollView :: forall i p. KeyedNode (Prop i) p
scrollView = keyedNode "scrollView"

flexBoxLayout :: forall i p. KeyedNode (Prop i) p
flexBoxLayout = keyedNode "flexBoxLayout"

