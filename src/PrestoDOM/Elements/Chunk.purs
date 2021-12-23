module PrestoDOM.Elements.Chunk
    ( ChunkedNode
    , linearLayout
    , relativeLayout
    ) where

import Halogen.VDom (ElemName(ElemName), VDom)
import Halogen.VDom.DOM.Prop (Prop)
import Halogen.VDom.Types (ShimmerHolder)
import PrestoDOM.Elements.Elements (chunk)

type ChunkedNode i p
   = Array i
  -> ShimmerHolder (Array i) p
  -> VDom (Array i) p


chunkedNode :: forall i p. String -> ChunkedNode (Prop i) p
chunkedNode elem = chunk (ElemName elem)


linearLayout :: forall i p. ChunkedNode (Prop i) p
linearLayout = chunkedNode "linearLayout"

relativeLayout :: forall i p. ChunkedNode (Prop i) p
relativeLayout = chunkedNode "relativeLayout"
