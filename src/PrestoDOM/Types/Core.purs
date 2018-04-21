module PrestoDOM.Types.Core
    ( PropName(..)
    , PrestoDOM
    , Props
    , toPropValue
    , GenProp(..)
    , Screen
    , module VDom
    , module Types
    , class IsProp
    ) where

import Prelude

import Control.Monad.Eff (Eff)
import DOM (DOM)
import Data.Either (Either)
import Data.Newtype (class Newtype)
import FRP (FRP)
import Halogen.VDom.DOM.Prop (Prop, PropValue, propFromBoolean, propFromInt, propFromNumber, propFromString)
import Halogen.VDom.DOM.Prop (Prop) as VDom
import Halogen.VDom.Types (VDom(..), ElemSpec(..), ElemName(..), Namespace(..)) as VDom
import Halogen.VDom.Types (VDom)
import PrestoDOM.Types.DomAttributes (Gravity, InputType, Length, Orientation, Typeface, Visibility, renderGravity, renderInputType, renderLength, renderOrientation, renderTypeface, renderVisibility)
import PrestoDOM.Types.DomAttributes as Types

newtype PropName value = PropName String
type PrestoDOM i w = VDom (Array (Prop i)) w

type Props i = Array (Prop i)

data GenProp
    = LengthP Length
    | BooleanP Boolean
    | IntP Int
    | StringP String
    | TextP String


type Screen action st eff retAction =
  { initialState :: st
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

instance inputTypeIsProp :: IsProp InputType where
  toPropValue = propFromString <<< renderInputType

instance orientationIsProp :: IsProp Orientation where
  toPropValue = propFromString <<< renderOrientation

instance typefaceIsProp :: IsProp Typeface where
  toPropValue = propFromString <<< renderTypeface

instance visibilityIsProp :: IsProp Visibility where
  toPropValue = propFromString <<< renderVisibility

instance gravityIsProp :: IsProp Gravity where
  toPropValue = propFromString <<< renderGravity
