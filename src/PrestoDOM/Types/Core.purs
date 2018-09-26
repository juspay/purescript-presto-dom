module PrestoDOM.Types.Core
    ( PropName(..)
    , PrestoDOM
    , Props
    , toPropValue
    , GenProp(..)
    , Screen
    , PropEff
    , Eval
    , Cmd
    , module VDom
    , module Types
    , class IsProp
    ) where

import Prelude

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Ref (REF)
import DOM (DOM)
import Data.Tuple (Tuple)
import Data.Either (Either)
import Data.Maybe (Maybe)
import Data.Newtype (class Newtype)
import FRP (FRP)
import Halogen.VDom.DOM.Prop (Prop, PropValue, propFromBoolean, propFromInt, propFromNumber, propFromString)
import Halogen.VDom.DOM.Prop (Prop) as VDom
import Halogen.VDom.Types (VDom(..), ElemSpec(..), ElemName(..), Namespace(..)) as VDom
import Halogen.VDom.Types (VDom)
import PrestoDOM.Types.DomAttributes (Gravity, Gradient, InputType, Length, Margin, Orientation, Padding, Typeface, Visibility, Shadow, renderGravity, renderGradient, renderInputType, renderLength, renderMargin, renderOrientation, renderPadding, renderTypeface, renderVisibility, renderShadow)
import PrestoDOM.Types.DomAttributes as Types

newtype PropName value = PropName String
type PrestoDOM i w = VDom (Array (Prop i)) w
type Cmd eff action = Array (Eff (ref :: REF, frp :: FRP, dom :: DOM | eff) action)
type Eval eff action retAction st = Either (Tuple (Maybe st) retAction) (Tuple st (Cmd eff action))

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


type PropEff e = Eff ( ref :: REF , frp :: FRP, dom :: DOM | e ) Unit

type Screen action st eff retAction =
  { initialState :: st
  , view :: (action -> Eff (ref :: REF, frp :: FRP, dom :: DOM | eff) Unit) -> st -> VDom (Array (Prop (PropEff eff))) Void
  , eval :: action -> st -> Eval eff action retAction st
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

instance gradientIsProp :: IsProp Gradient where
  toPropValue = propFromString <<< renderGradient

instance marginIsProp :: IsProp Margin where
  toPropValue = propFromString <<< renderMargin

instance paddingIsProp :: IsProp Padding where
  toPropValue = propFromString <<< renderPadding

instance shadowIsProp :: IsProp Shadow where
  toPropValue = propFromString <<< renderShadow
