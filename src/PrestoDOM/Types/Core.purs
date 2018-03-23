module PrestoDOM.Types.Core
    ( PropName(..)
    , PrestoDOM
    , toPropValue
    , Screen
    , module VDom
    , module Types
    , class IsProp
    ) where

import Prelude

import Control.Monad.Eff (Eff)
import DOM (DOM)
import Data.Either (Either)
import Data.Maybe (Maybe)
import Data.Newtype (class Newtype)
import Data.Tuple (Tuple(..))
import FRP (FRP)
import FRP.Event (Event, subscribe)
import Halogen.VDom.DOM.Prop (Prop, PropValue, propFromBoolean, propFromInt, propFromNumber, propFromString)
import Halogen.VDom.Types (VDom(..), ElemSpec(..), ElemName(..), Namespace(..)) as VDom
import Halogen.VDom.Types (VDom)
import PrestoDOM.Types.DomAttributes (Length, renderLength)
import PrestoDOM.Types.DomAttributes as Types

newtype PropName value = PropName String
type PrestoDOM i w = VDom (Array (Prop i)) w

type Screen action st eff retAction =
  {
    initialState :: st
  , view :: (action -> Eff (frp :: FRP, dom :: DOM | eff) Unit) -> st -> VDom (Array (Prop action)) Void
  , eval :: action -> st -> Either retAction st
  }

derive instance newtypePropName :: Newtype (PropName value) _

class IsProp a where
  toPropValue :: a -> PropValue

instance stringIsProp :: IsProp String where
  toPropValue = propFromString

instance intIsProp :: IsProp Int where
  toPropValue = propFromInt

instance numberIsProp :: IsProp Number where
  toPropValue = propFromNumber

instance booleanIsProp :: IsProp Boolean where
  toPropValue = propFromBoolean

instance lengthIsProp :: IsProp Length where
  toPropValue = propFromString <<< renderLength
