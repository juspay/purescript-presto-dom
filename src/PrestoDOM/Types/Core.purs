module PrestoDOM.Types.Core
    ( PropName(..)
    , PrestoDOM
    , Props
    , toPropValue
    , GenProp(..)
    , Screen
    , Eval
    , Cmd
    , module VDom
    , module Types
    , class IsProp
    ) where

import Prelude

import Data.Tuple (Tuple)
import Data.Either (Either)
{-- import Data.Exists (Exists) --}
import Data.Maybe (Maybe)
import Data.Newtype (class Newtype)
import Effect (Effect)

import Halogen.VDom.DOM.Prop (Prop, PropValue, propFromBoolean, propFromInt, propFromNumber, propFromString)
import Halogen.VDom.DOM.Prop (Prop) as VDom
import Halogen.VDom.Thunk (Thunk)
import Halogen.VDom.Types (VDom(..), ElemName(..), Namespace(..)) as VDom
import Halogen.VDom.Types (VDom)
import PrestoDOM.Types.DomAttributes (Gravity, InputType, Length, Margin, Orientation, Padding, Typeface, Visibility, Shadow, renderGravity, renderInputType, renderLength, renderMargin, renderOrientation, renderPadding, renderTypeface, renderVisibility, renderShadow)
import PrestoDOM.Types.DomAttributes (Gravity(..), InputType(..), Length(..), Margin(..), Orientation(..), Padding(..), Shadow(..), Typeface(..), Visibility(..), renderGravity, renderInputType, renderLength, renderMargin, renderOrientation, renderPadding, renderShadow, renderTypeface, renderVisibility) as Types
import Web.DOM.Node (Node) as DOM

newtype PropName value = PropName String
type PrestoDOM i w = VDom (Array (Prop i)) w
type Cmd action = Array (Effect action)
type Eval action returnType state = Either (Tuple (Maybe state) returnType) (Tuple state (Cmd action))

type Props i = Array (Prop i)

data GenProp
    = LengthP Length
    | MarginP Margin
    | PaddingP Padding
    | InputTypeP InputType
    | OrientationP Orientation
    | TypefaceP Typeface
    | VisibilityP Visibility
    | GravityP Gravity
    | NumberP Number
    | BooleanP Boolean
    | IntP Int
    | StringP String
    | TextP String
    | ShadowP Shadow


type Screen action state returnType =
  { initialState :: state
  , view :: (action -> Effect Unit) -> state -> VDom (Array (Prop (Effect Unit))) (Thunk Effect DOM.Node)
  , eval :: action -> state -> Eval action returnType state
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

instance marginIsProp :: IsProp Margin where
  toPropValue = propFromString <<< renderMargin

instance paddingIsProp :: IsProp Padding where
  toPropValue = propFromString <<< renderPadding

instance shadowIsProp :: IsProp Shadow where
  toPropValue = propFromString <<< renderShadow
