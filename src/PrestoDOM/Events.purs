module PrestoDOM.Events where

import Prelude

import Control.Monad.Eff (Eff)
-- import DOM.Event.Types (EventType(..), Event) as DOM
import FRP (FRP)
import Halogen.VDom.DOM.Prop (Prop)
import PrestoDOM.Properties (prop)
import PrestoDOM.Types.Core (PropName(..))

-- TODO : Remove this
foreign import unsafeProp :: forall a. a -> String

onClick :: forall a eff. (a ->  Eff (frp :: FRP | eff) Unit) -> (Unit -> a) -> Prop a
onClick push f = prop (PropName "onClick") (unsafeProp (push <<< f))

onChange :: forall a eff. (a ->  Eff (frp :: FRP | eff) Unit) -> (String -> a) -> Prop a
onChange push f = prop (PropName "onChange") (unsafeProp (push <<< f))

onBackPressed :: forall a eff. (a ->  Eff (frp :: FRP | eff) Unit) -> (Unit -> a) -> Prop a
onBackPressed push f = prop (PropName "onBackPressed") (unsafeProp (push <<< f))

