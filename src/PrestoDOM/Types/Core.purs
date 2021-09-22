module PrestoDOM.Types.Core
    ( PropName(..)
    , PrestoDOM
    , Props
    , toPropValue
    , GenProp(..)
    , Screen
    , ScreenBase
    , ScopedScreen
    , Controller
    , Eval
    , Cmd
    , PrestoWidget(..)
    , module VDom
    , module Types
    , class IsProp
    , class Loggable
    , performLog
    , defaultPerformLog
    , defaultSkipLog
    ) where

import Prelude

import Data.Tuple (Tuple)
import Data.Either (Either)
import Data.Maybe (Maybe)
import Data.Newtype (class Newtype)
import Effect (Effect)
import Global.Unsafe (unsafeStringify)

import Halogen.VDom.DOM.Prop (Prop, PropValue, propFromBoolean, propFromInt, propFromNumber, propFromString)
import Halogen.VDom.DOM.Prop (Prop) as VDom
import Halogen.VDom.Thunk (Thunk)
import Halogen.VDom.Types (VDom(..), ElemName(..), Namespace(..)) as VDom
import Halogen.VDom.Types (VDom)
import PrestoDOM.Types.DomAttributes (BottomSheetState, Corners, Font, Gradient, Gravity, InputType, Length, LineSpacing, Margin, Orientation, Padding, Position, Shadow, Shimmer, Typeface, Visibility, renderBottomSheetState, renderCorners, renderFont, renderGradient, renderGravity, renderInputType, renderLength, renderLineSpacing, renderMargin, renderOrientation, renderPadding, renderPosition, renderShadow, renderShimmer, renderTypeface, renderVisibility)
import PrestoDOM.Types.DomAttributes (BottomSheetState, Corners, Font, Gradient, Gravity, InputType, Length, LineSpacing, Margin, Orientation, Padding, Position, Shadow, Shimmer, Typeface, Visibility, renderBottomSheetState, renderCorners, renderFont, renderGradient, renderGravity, renderInputType, renderLength, renderLineSpacing, renderMargin, renderOrientation, renderPadding, renderPosition, renderShadow, renderShimmer, renderTypeface, renderVisibility) as Types
{-- data Thunk b = Thunk b (b → Effect DOM.Node) --}
import Tracker (trackAction)
import Tracker.Types (Level(..), Action(..)) as T
import Tracker.Labels (Label(..)) as L
import Foreign(Foreign)
import Foreign.Class (encode)
import Foreign.Object as Object
import Unsafe.Coerce (unsafeCoerce)

newtype PrestoWidget a = PrestoWidget (VDom (Array (Prop a)) (Thunk PrestoWidget a))

derive instance newtypePrestoWidget ∷ Newtype (PrestoWidget a) _

newtype PropName value = PropName String
type PrestoDOM i w = VDom (Array (Prop i)) w
type Cmd action = Array (Effect action)
type Eval action returnType state = Either (Tuple (Maybe state) returnType) (Tuple state (Cmd action))

type Props i = Array (Prop i)

data GenProp
    = LengthP Length
    | PositionP Position
    | MarginP Margin
    | PaddingP Padding
    | FontP Font
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
    | CornersP Corners


type Screen action state returnType = ScreenBase action state returnType (view :: (action -> Effect Unit) -> state -> VDom (Array (Prop (Effect Unit))) (Thunk PrestoWidget (Effect Unit)))

type ScreenBase action state returnType a =
  { initialState :: state
  , name :: String
  , globalEvents :: Array ((action -> Effect Unit) -> Effect (Effect Unit))
  , eval :: action -> state -> Eval action returnType state
  | a
  }

type Controller action state returnType = ScreenBase action state returnType (parent :: Maybe String, emitter :: state -> Effect Unit)

type ScopedScreen action state returnType = ScreenBase action state returnType (parent :: Maybe String, view :: (action -> Effect Unit) -> state -> VDom (Array (Prop (Effect Unit))) (Thunk PrestoWidget (Effect Unit)))

derive instance newtypePropName :: Newtype (PropName value) _

class Loggable a where 
  performLog :: a -> (Object.Object Foreign) ->Effect Unit

defaultPerformLog :: forall a. Show a => a -> (Object.Object Foreign) ->Effect Unit 
defaultPerformLog action json = do
  let value = show action 
  trackAction T.User T.Info L.EVAL "data" (encode value) json

defaultSkipLog :: forall a. Show a => a -> (Object.Object Foreign)-> Effect Unit 
defaultSkipLog _ _ = pure unit

instance stringLoggable :: Loggable String where
  performLog = defaultPerformLog

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

instance foreignIsProp :: IsProp Foreign where
  toPropValue = unsafeCoerce

instance objectIsProp :: IsProp (Object.Object a) where
  toPropValue = unsafeCoerce

instance stringArrayIsProp :: IsProp (Array String) where
  toPropValue = propFromString <<< unsafeStringify

instance lengthIsProp :: IsProp Length where
  toPropValue = propFromString <<< renderLength

instance positionIsProp :: IsProp Position where
  toPropValue = propFromString <<< renderPosition

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

instance cornersIsProp :: IsProp Corners where
  toPropValue = propFromString <<< renderCorners

instance fontIsProp :: IsProp Font where 
  toPropValue = propFromString <<< renderFont

instance lineSpacingIsProp :: IsProp LineSpacing where
  toPropValue = propFromString <<< renderLineSpacing

instance shimmerIsProp :: IsProp Shimmer where
  toPropValue = propFromString <<< renderShimmer

instance bottomSheetStateIsProp :: IsProp BottomSheetState where
  toPropValue = propFromString <<< renderBottomSheetState