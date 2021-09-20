module PrestoDOM.Animation
  ( Animation(..)
  , AnimProp(..)
  , Interpolator(..)
  , RepeatMode(..)
  , RepeatCount(..)
  , duration
  , delay
  , repeatMode
  , repeatCount
  , toX
  , fromX
  , toY
  , fromY
  , toScaleX
  , toScaleY
  , fromScaleX
  , fromScaleY
  , fromRotation
  , toRotation
  , fromRotationX
  , toRotationX
  , fromRotationY
  , toRotationY
  , fromAlpha
  , toAlpha
  , interpolator
  , tag
  , animationSet
  , entryAnimationSet
  , entryAnimationSetForward
  , entryAnimationSetBackward
  , exitAnimationSet
  , exitAnimationSetForward
  , exitAnimationSetBackward
  , _mergeAnimation
  ) where

import Prelude

import Control.Monad.Except.Trans (ExceptT, except)
import Data.Array (length)
import Data.Foldable (foldr)
import Data.Generic.Rep (class Generic)
import Data.Either (Either(..))
import Data.String.Common (toLower)
import Foreign.Class (class Decode)
import Foreign (ForeignError(..), unsafeFromForeign)
import Data.List.NonEmpty (NonEmptyList, singleton)
import Effect (Effect)

import PrestoDOM.Properties (prop)
import PrestoDOM.Types.Core (PropName(PropName), VDom(Keyed, Elem), PrestoDOM)
import PrestoDOM.Types.DomAttributes(isUndefined, toSafeString, toSafeArray, toSafeObject, toSafeInt)

foreign import _mergeAnimation :: forall a. a -> String

foreign import toSafeInterpolator
  :: forall a. String -- foreign string
  -> (String -> Either (NonEmptyList ForeignError) a) -- error constructor
  ->  (a -> Either (NonEmptyList ForeignError) a) -- data constructor
  -> Either (NonEmptyList ForeignError) a

-- | Animation data constructor
-- | Boolean indicates if the animation must be appplied on the view
data Animation = Animation (Array AnimProp) Boolean

-- | Animation prop with name and value
data AnimProp = AnimProp String String

-- | RepeatMode supports Restart and Reverse
data RepeatMode = Restart | Reverse

-- | RepeatMode count specifier
data RepeatCount = NoRepeat | Repeat Int | Infinite

-- | Interpolators supported by the animation API
data Interpolator = EaseIn | EaseOut | EaseInOut | Linear | Bounce | Bezier Number Number Number Number

derive instance genericInterpolator :: Generic Interpolator _

instance showInterpolator :: Show Interpolator where
  show =
    case _ of
      Linear -> "linear"
      Bounce -> "bounce"
      EaseIn -> "easein"
      EaseOut -> "easeout"
      EaseInOut -> "easeinout"
      Bezier a b c d -> show a <> "," <> show b <> "," <> show c <> "," <> show d

derive instance genericRepeatMode :: Generic RepeatMode _

instance showRepeatMode :: Show RepeatMode where
  show = case _ of
           Restart -> "restart"
           Reverse -> "reverse"

derive instance genericRepeatCount :: Generic RepeatCount _

instance showRepeatCount :: Show RepeatCount where
  show = case _ of
           NoRepeat -> "0"
           Infinite -> "-1"
           Repeat n -> show n

-- | Foreign to Type Decoding Utils

-- | Interpolator Type

type InterpolatorType = {type :: String, value :: Array Number}
instance decodeInterpolator :: Decode Interpolator where decode = decodeInterpolatorUtil <<< unsafeFromForeign

decodeInterpolatorUtil :: forall a. Applicative a => String -> ExceptT (NonEmptyList ForeignError) a Interpolator
decodeInterpolatorUtil json = let
  (parsedFont :: Either (NonEmptyList ForeignError) InterpolatorType) = toSafeInterpolator json (Left <<< singleton <<< ForeignError) Right
  in
  except $
    case parsedFont of
      Left err -> Left err
      Right obj ->
        case toLower obj.type of
          "bezier"    -> toSafeArray Bezier obj.value (Left <<< singleton <<< ForeignError) Right ["number", "number", "number", "number"]
          "easein"    -> Right EaseIn
          "easeout"   -> Right EaseOut
          "easeinout" -> Right EaseInOut
          "linear"    -> Right Linear
          "bounce"    -> Right Bounce
          _           -> (Left <<< singleton <<< ForeignError) $ "Interpolator is not supported"

-- | Repeat Mode
instance decodeRepeatMode :: Decode RepeatMode where decode = decodeRepeatModeUtil <<< toSafeString <<< unsafeFromForeign

decodeRepeatModeUtil :: forall a. Applicative a => String -> ExceptT (NonEmptyList ForeignError) a RepeatMode
decodeRepeatModeUtil json =
  if isUndefined json then
    (except <<< Left <<< singleton <<< ForeignError) "Repeat Mode is not defined"
  else
    except $
      case toLower json of
        "restart" -> Right Restart
        "reverse" -> Right Reverse
        _         -> (Left <<< singleton <<< ForeignError) $ "Repeat Mode is not supported"

-- | Repeat Count
type RepeatCountType = {type :: String, value :: String}

instance decodeRepeatCount :: Decode RepeatCount where decode = decodeRepeatCountUtil <<< unsafeFromForeign

decodeRepeatCountUtil :: forall a. Applicative a => String -> ExceptT (NonEmptyList ForeignError) a RepeatCount
decodeRepeatCountUtil json = let
  (parsedFont :: Either (NonEmptyList ForeignError) RepeatCountType) = toSafeObject json (Left <<< singleton <<< ForeignError) Right in
  except $
    case parsedFont of
      Left err -> Left err
      Right obj ->
        case toLower obj.type of
          "repeat"    -> toSafeInt Repeat obj.value (Left <<< singleton <<< ForeignError) Right
          "norepeat"  -> Right NoRepeat
          "infinite"  -> Right Infinite
          _           -> (Left <<< singleton <<< ForeignError) $ "Repeat Count is not supported"

-- | Base animation prop handler
animProp :: forall a. Show a => String -> a -> AnimProp
animProp prop val = AnimProp prop $ show val

-- | Duration of the animation
-- | Unit: Milli-seconds
-- | Default: 0
duration :: Int -> AnimProp
duration = animProp "duration"

-- | Delay on the start of the animation
-- | Unit: Milli-seconds
-- | Default: 0
delay :: Int -> AnimProp
delay = animProp "delay"

-- | Repeat mode of the animation
-- | Either reverse or restart
-- | Default: NoRepeat
repeatMode :: RepeatMode -> AnimProp
repeatMode = animProp "repeatMode"

-- | Repeat count of the animation
-- | Default: 0
repeatCount :: RepeatCount -> AnimProp
repeatCount = animProp "repeatCount"

-- | End translation X value of the animation
-- | Unit: DP (Density Pixel)
-- | Default: current translation X of the view
toX :: Int -> AnimProp
toX = animProp "toX"

-- | Start translation X value of the animation
-- | Unit: DP (Density Pixel)
-- | Default: current translation X of the view
fromX :: Int -> AnimProp
fromX = animProp "fromX"

-- | End translation Y value of the animation
-- | Default: current translation Y of the view
-- | Unit: DP (Density Pixel)
toY :: Int -> AnimProp
toY = animProp "toY"

-- | Start translation Y value of the animation
-- | Default: current translation Y of the view
-- | Unit: DP (Density Pixel)
fromY :: Int -> AnimProp
fromY = animProp "fromY"

-- | End scale X value of the animation
-- | Default: current scale X of the view
-- | Unit: Decimal (0.0 - 1.0, relative to the view)
toScaleX :: Number -> AnimProp
toScaleX = animProp "toScaleX"

-- | Start scale X value of the animation
-- | Default: current scale X of the view
-- | Unit: Decimal (0.0 - 1.0, relative to the view)
fromScaleX :: Number -> AnimProp
fromScaleX = animProp "fromScaleX"

-- | End scale Y value of the animation
-- | Default: current scale Y of the view
-- | Unit: Decimal (0.0 - 1.0, relative to the view)
toScaleY :: Number -> AnimProp
toScaleY = animProp "toScaleY"

-- | Start scale Y value of the animation
-- | Default: current scale Y of the view
-- | Unit: Decimal (0.0 - 1.0, relative to the view)
fromScaleY :: Number -> AnimProp
fromScaleY = animProp "fromScaleY"

-- | Start rotation value of the animation
-- | Default: current rotation of the view
-- | Unit: Degree (0 - 360)
fromRotation :: Int -> AnimProp
fromRotation = animProp "fromRotation"

-- | End rotation value of the animation
-- | Default: current rotation of the view
-- | Unit: Degree (0 - 360)
toRotation :: Int -> AnimProp
toRotation = animProp "toRotation"

-- | End rotation X value of the animation
-- | Default: current rotation X of the view
-- | Unit: Degree (0 - 360)
toRotationX :: Int -> AnimProp
toRotationX = animProp "toRotationX"

-- | End rotation value of the animation
-- | Default: current rotation X of the view
-- | Unit: Degree (0 - 360)
fromRotationX :: Int -> AnimProp
fromRotationX = animProp "fromRotationX"

-- | Start rotation Y value of the animation
-- | Default: current rotation Y of the view
-- | Unit: Degree (0 - 360)
fromRotationY :: Int -> AnimProp
fromRotationY = animProp "fromRotationY"

-- | End rotation Y value of the animation
-- | Default: current rotation Y of the view
-- | Unit: Degree (0 - 360)
toRotationY :: Int -> AnimProp
toRotationY = animProp "toRotationY"

-- | Start opacity of the animation
-- | Default: current opacity of the view
-- | Unit: Decimal (0.0 - 1.0)
fromAlpha :: Number -> AnimProp
fromAlpha = animProp "fromAlpha"

-- | End opacity of the animation
-- | Default: current opacity of the view
-- | Unit: Decimal (0.0 - 1.0)
toAlpha :: Number -> AnimProp
toAlpha = animProp "toAlpha"

-- | Animation tag used for identifying the animation on event callback
-- | Not a mandatory prop
interpolator :: Interpolator -> AnimProp
interpolator = animProp "interpolator"

-- | Animation tag used for identifying the animation on event callback
-- | Not a mandatory prop
tag :: String -> AnimProp
tag = AnimProp "tag"

entryAnimationSet :: forall w. Array Animation -> PrestoDOM (Effect Unit) w -> PrestoDOM (Effect Unit) w
entryAnimationSet = animationSetImpl "entryAnimation"

exitAnimationSet :: forall w. Array Animation -> PrestoDOM (Effect Unit) w -> PrestoDOM (Effect Unit) w
exitAnimationSet = animationSetImpl "exitAnimation"

entryAnimationSetForward :: forall w. Array Animation -> PrestoDOM (Effect Unit) w -> PrestoDOM (Effect Unit) w
entryAnimationSetForward = animationSetImpl "entryAnimationF"

exitAnimationSetForward :: forall w. Array Animation -> PrestoDOM (Effect Unit) w -> PrestoDOM (Effect Unit) w
exitAnimationSetForward = animationSetImpl "exitAnimationF"

entryAnimationSetBackward :: forall w. Array Animation -> PrestoDOM (Effect Unit) w -> PrestoDOM (Effect Unit) w
entryAnimationSetBackward = animationSetImpl "entryAnimationB"

exitAnimationSetBackward :: forall w. Array Animation -> PrestoDOM (Effect Unit) w -> PrestoDOM (Effect Unit) w
exitAnimationSetBackward = animationSetImpl "exitAnimationB"

animationSet :: forall w. Array Animation -> PrestoDOM (Effect Unit) w -> PrestoDOM (Effect Unit) w
animationSet = animationSetImpl "inlineAnimation"

-- | Animation set is a composible animation view
-- | It applies the set of animations on the provided view
animationSetImpl :: forall w. String -> Array Animation -> PrestoDOM (Effect Unit) w -> PrestoDOM (Effect Unit) w
animationSetImpl propName animations view = do
  case (length filterAnimations) == 0, view of
    false, Elem ns eName props child -> do
      let newProps = props <> [prop (PropName propName) $ _mergeAnimation filterAnimations] <> [prop (PropName "hasAnimation") "true"]
      Elem ns eName newProps child
    false, Keyed ns eName props child -> do
      let newProps = props <> [prop (PropName propName) $ _mergeAnimation filterAnimations] <> [prop (PropName "hasAnimation") "true"]
      Keyed ns eName newProps child
    _ , _ -> view

  where
    filterAnimations = foldr
                          (\(Animation anims shouldRun) b -> if (shouldRun) then ([anims] <> b) else b)
                          ([] :: Array (Array AnimProp))
                          animations
