module PrestoDOM.Core
	( MEvent
    , class IsProp
    , toPropValue
    , PropName(..)
    , click
    , module Exports
    , Dynamic(..)
    , class MkDynamic
    , mkDyn
    , beh
    , ev
    , PrestoDOM
	) where

import Prelude

import Control.Monad.Eff (Eff)
import DOM (DOM)
import DOM.Event.EventTarget (eventListener)
import DOM.HTML.HTMLImageElement as E
import Data.Foreign (Foreign)
import Data.Generic (class Generic)
import Data.Lens (Getter', Lens, Lens', lens)
import Data.Lens.Record (prop)
import Data.Maybe (Maybe(..))
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype, unwrap)
import Data.Symbol (SProxy(..))
import Data.Tuple (Tuple)
import FRP (FRP)
import FRP.Behavior (Behavior, behavior, step)
import FRP.Event (Event, create)
import Halogen.VDom.DOM.Prop (ElemRef(..), Prop(..), PropValue, propFromBoolean, propFromInt, propFromNumber, propFromString)
import Halogen.VDom.DOM.Prop (Prop(..), PropValue) as Exports
import PrestoDOM.Types (Length(..), VDom, renderLength)
import Unsafe.Coerce (unsafeCoerce)

foreign import click :: MEvent

data MEvent

{-- data AttrTypes = String | Foreign --}
-- data AttrValue = AttrValue String | ScreenTag Foreign | Some MEvent

-- newtype Attr a = Attr (Array (Prop a))

-- type Prop = Tuple String AttrValue type-safe wrapper for property names.
-- |
-- | The phantom type `value` describes the type of value which this property
-- | requires.
newtype PropName value = PropName String
type PrestoDOM i w = VDom (Array (Prop i)) w

derive instance newtypePropName :: Newtype (PropName value) _
derive newtype instance eqPropName :: Eq (PropName value)
derive newtype instance ordPropName :: Ord (PropName value)
derive instance genericPropName :: Generic (PropName value)

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

data Dynamic a = Dynamic
  {
    beh :: Behavior a
  , event :: Event a
  , push :: a -> Eff (frp :: FRP) Unit
  }

class MkDynamic a where
  mkDyn :: forall eff. a -> Eff (frp :: FRP | eff) (Dynamic a)

instance strDyn :: MkDynamic String where
  mkDyn = genericMkDyn

instance boolDyn :: MkDynamic Boolean where
  mkDyn = genericMkDyn

-- TODO : Fix the Effect Problem
genericMkDyn :: forall eff a. a -> Eff (frp :: FRP | eff) (Dynamic a)
genericMkDyn defaultValue = unsafeCoerce $ do
  { event, push } <- create
  pure $ Dynamic { beh : (step defaultValue event), event, push }

_Dynamic :: forall a . Lens' (Dynamic a) { beh :: Behavior a, event :: Event a,push :: a -> Eff (frp :: FRP) Unit }
_Dynamic = lens (\(Dynamic rec) -> rec) (\_ -> Dynamic)

beh :: forall a. Getter' (Dynamic a) (Behavior a)
beh = _Dynamic <<< (prop (SProxy :: SProxy "beh"))

ev :: forall a. Getter' (Dynamic a) (Event a)
ev = _Dynamic <<< (prop (SProxy :: SProxy "event"))
