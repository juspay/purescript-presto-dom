module PrestoDOM.Events where

import Prelude

import Control.Monad.Eff (Eff)
import DOM.Event.Types (EventType(..), Event) as DOM
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..))
import FRP (FRP)
import Halogen.VDom.DOM.Prop (PropValue, propFromBoolean)
import PrestoDOM.Core (Dynamic(..), MEvent, Prop(..), PropName(..))
import PrestoDOM.Properties (prop)
import Unsafe.Coerce (unsafeCoerce)

-- TODO : Remove this
foreign import generateProp :: forall a eff. (a -> Eff eff Unit) -> String
foreign import unsafeProp :: forall a. a -> String

-- TODO :: Change this to handler
onClick :: forall i. Dynamic Boolean -> Prop i
onClick (Dynamic { push }) = prop (PropName "onClick") (generateProp push)

onChange :: forall i. Dynamic String -> Prop i
onChange (Dynamic { push }) = prop (PropName "onChange") (generateProp push)

onClickT :: forall a i eff. (a ->  Eff (frp :: FRP | eff) Unit) -> (Unit -> a) -> Prop a
onClickT push f = prop (PropName "onClick") (unsafeProp (push <<< f))

onChangeT :: forall a i eff. (a ->  Eff (frp :: FRP | eff) Unit) -> (String -> a) -> Prop a
onChangeT push f = prop (PropName "onChange") (unsafeProp (push <<< f))
