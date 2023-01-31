module PrestoDOM.Types.DomAttributes
  ( BottomSheetState(..)
  , Corners(..)
  , Font(..)
  , Gradient(..)
  , Gravity(..)
  , InputType(..)
  , Length(..)
  , LineSpacing(..)
  , LetterSpacing(..)
  , Margin(..)
  , Orientation(..)
  , Padding(..)
  , Position(..)
  , Shadow(..)
  , Shimmer(..)
  , ShimmerJson
  , Typeface(..)
  , Visibility(..)
  , __IS_ANDROID
  , active
  , alphaBuilder
  , baseAlpha
  , baseColor
  , clipToChildren
  , colorBuilder
  , direction
  , dropOff
  , duration
  , highlightAlpha
  , highlightColor
  , intensity
  , isUndefined
  , renderBottomSheetState
  , renderCorners
  , renderFont
  , renderGradient
  , renderGravity
  , renderInputType
  , renderLength
  , renderLetterSpacing
  , renderLineSpacing
  , renderMargin
  , renderOrientation
  , renderPadding
  , renderPosition
  , renderShadow
  , renderShimmer
  , renderTypeface
  , renderVisibility
  , repeatCount
  , repeatDelay
  , shape
  , tilt
  , toSafeArray
  , toSafeInt
  , toSafeObject
  , toSafeString
  , decodeLengthUtil
  , decodeInputTypeUtil
  , decodeOrientationUtil
  , decodeVisibilityUtil
  , decodeGravityUtil
  , decodeMarginUtil
  , decodePaddingUtil
  , decodeGradientUtil
  , decodeShadowUtil
  , decodeCornersUtil
  , decodeFontUtil
  , decodeLetterSpacingUtil
  )
  where

import Prelude
import Control.Monad.Except(runExcept)
import Control.Monad.Except.Trans (ExceptT, except)
import Data.Either (Either(..))
import Data.Function.Uncurried (Fn3, runFn3)
import Data.Generic.Rep (class Generic)
import Data.Show.Generic (genericShow)
import Data.Int (fromString)
import Data.List.NonEmpty (NonEmptyList, singleton)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.String.Common (toLower)
import Foreign (Foreign, ForeignError(..), unsafeFromForeign, unsafeToForeign)
import Foreign.Class (class Decode, class Encode, encode, decode)
import Presto.Core.Utils.Encoding (defaultEncodeJSON)
import Foreign.Generic (decodeJSON)
import Control.Alt ((<|>))


foreign import stringifyGradient :: Fn3 String Number (Array String) String
foreign import __IS_ANDROID :: Boolean
foreign import __IS_WEB :: Unit -> Boolean

foreign import isUndefined :: forall a. a -> Boolean
foreign import toSafeString :: forall a. a -> String

foreign import toSafeInt
  :: forall a dataConstructor. dataConstructor
  -> String -- foreign string
  -> (String -> Either (NonEmptyList ForeignError) a) -- error constructor
  -> (a -> Either (NonEmptyList ForeignError) a) -- data constructor
  -> Either (NonEmptyList ForeignError) a

foreign import toSafeNumber
  :: forall a dataConstructor. dataConstructor
  -> String -- foreign string
  -> (String -> Either (NonEmptyList ForeignError) a) -- error constructor
  -> (a -> Either (NonEmptyList ForeignError) a) -- data constructor
  -> Either (NonEmptyList ForeignError) a

foreign import toSafeObject
  :: forall a. String -- foreign string
  -> (String -> Either (NonEmptyList ForeignError) a) -- error constructor
  -> (a -> Either (NonEmptyList ForeignError) a) -- data constructor
  -> Either (NonEmptyList ForeignError) a

foreign import toSafeArray
  :: forall dataType dataConstructor foreignType. dataConstructor
  -> foreignType
  -> (String -> Either (NonEmptyList ForeignError) dataType) -- error constructor
  -> (dataType -> Either (NonEmptyList ForeignError) dataType) -- data constructor
  -> (Array String) -- array of dataConstructor argument types
  -> (Either (NonEmptyList ForeignError) dataType)

foreign import toSafeGradientType
  :: String
  -> (String -> Either (NonEmptyList ForeignError) GradientType)
  -> (GradientType -> Either (NonEmptyList ForeignError) GradientType)
  -> Either (NonEmptyList ForeignError) GradientType


data Length
  = MATCH_PARENT
  | WRAP_CONTENT
  | V Int

derive instance genericLength:: Generic Length _
instance decodeLength :: Decode Length where decode = decodeLengthUtil <<< toSafeString <<< unsafeFromForeign
instance showLength :: Show Length where show = genericShow
instance encodeLength :: Encode Length where encode = renderLength >>> unsafeToForeign

decodeLengthUtil :: forall a. Applicative a => String -> ExceptT (NonEmptyList ForeignError) a Length
decodeLengthUtil json =
  if isUndefined json then
    (except <<< Left <<< singleton <<< ForeignError) "Length is undefined"
  else
    except $
    case toLower json of
      "match_parent" -> Right MATCH_PARENT
      "wrap_content" -> Right WRAP_CONTENT
      other -> toSafeInt V other (Left <<< singleton <<< ForeignError) Right

renderLength :: Length -> String
renderLength = case _ of
    MATCH_PARENT -> "match_parent"
    WRAP_CONTENT -> "wrap_content"
    V n -> show n

data Position
  = ABSOLUTE
  | RELATIVE
  | FIXED
  | STATIC
  | STICKY

derive instance genericPosition :: Generic Position _
instance decodePosition :: Decode Position where decode = decodePositionUtil <<< toSafeString <<< unsafeFromForeign
instance showPosition :: Show Position where show = genericShow
instance encodePosition :: Encode Position where encode = renderPosition >>> unsafeToForeign

decodePositionUtil :: forall a. Applicative a => String -> ExceptT (NonEmptyList ForeignError) a Position
decodePositionUtil json =
  if isUndefined json then
    (except <<< Left <<< singleton <<< ForeignError) "position is not defined"
  else
    except $
    case toLower json of
        "absolute"  -> Right ABSOLUTE
        "relative"  -> Right RELATIVE
        "fixed"     -> Right FIXED
        "static"    -> Right STATIC
        "sticky"    -> Right STICKY
        _           -> (Left <<< singleton <<< ForeignError) "Position is not supported"

renderPosition :: Position -> String
renderPosition = case _ of
    ABSOLUTE -> "absolute"
    RELATIVE -> "relative"
    FIXED -> "fixed"
    STATIC -> "static"
    STICKY -> "sticky"


data Margin
    = Margin Int Int Int Int
    | MarginBottom Int
    | MarginHorizontal Int Int
    | MarginLeft Int
    | MarginRight Int
    | MarginTop Int
    | MarginVertical Int Int

derive instance genericMargin:: Generic Margin _
instance decodeMargin :: Decode Margin where decode = decodeMarginUtil <<< unsafeFromForeign
instance encodeMargin :: Encode Margin where encode = encodeMarginUtil
instance showMargin :: Show Margin where show = genericShow

decodeMarginUtil :: forall a. Applicative a => String -> ExceptT (NonEmptyList ForeignError) a Margin
decodeMarginUtil json =
  except $ toSafeArray
    Margin json (Left <<< singleton <<< ForeignError) Right ["int", "int", "int", "int"]

encodeMarginUtil :: Margin -> Foreign
encodeMarginUtil margin =
  case margin of
    Margin a b c d       -> unsafeToForeign [a,b,c,d]
    MarginBottom b       -> unsafeToForeign [0,0,0,b]
    MarginLeft l         -> unsafeToForeign [l,0,0,0]
    MarginRight r        -> unsafeToForeign [0,0,r,0]
    MarginTop t          -> unsafeToForeign [0,t,0,0]
    MarginHorizontal l r -> unsafeToForeign [l,0,r,0]
    MarginVertical t b   -> unsafeToForeign [0,t,0,b]

-- | Margin : left, top, right and bottom
-- | MarginBottom : bottom
-- | MarginHorizontal : left and right
-- | MarginLeft : left
-- | MarginRight : right
-- | MarginTop : top
-- | MarginVertical : top and bottom
renderMargin :: Margin -> String
renderMargin = case _ of
    Margin l t r b       -> show l <> "," <> show t <> "," <> show r <> "," <> show b
    MarginBottom b       -> "0"    <> "," <> "0"    <> "," <> "0"    <> "," <> show b
    MarginHorizontal l r -> show l <> "," <> "0"    <> "," <> show r <> "," <> "0"
    MarginLeft l         -> show l <> "," <> "0"    <> "," <> "0"    <> "," <> "0"
    MarginRight r        -> "0"    <> "," <> "0"    <> "," <> show r <> "," <> "0"
    MarginTop t          -> "0"    <> "," <> show t <> "," <> "0"    <> "," <> "0"
    MarginVertical t b   -> "0"    <> "," <> show t <> "," <> "0"    <> "," <> show b


data Padding
    = Padding Int Int Int Int
    | PaddingBottom Int
    | PaddingHorizontal Int Int
    | PaddingLeft Int
    | PaddingRight Int
    | PaddingTop Int
    | PaddingVertical Int Int

derive instance genericPadding :: Generic Padding _
instance decodePadding :: Decode Padding where decode = decodePaddingUtil <<< unsafeFromForeign
instance encodePadding :: Encode Padding where encode = encodePaddingUtil
instance showPadding :: Show Padding where show = genericShow

decodePaddingUtil :: forall a. Applicative a => String -> ExceptT (NonEmptyList ForeignError) a Padding
decodePaddingUtil json =
  except $ toSafeArray
    Padding json (Left <<< singleton <<< ForeignError) Right ["int", "int", "int", "int"]

encodePaddingUtil :: Padding -> Foreign
encodePaddingUtil padding =
  case padding of
    Padding a b c d        -> unsafeToForeign [a,b,c,d]
    PaddingBottom b        -> unsafeToForeign [0,0,0,b]
    PaddingLeft l          -> unsafeToForeign [l,0,0,0]
    PaddingRight r         -> unsafeToForeign [0,0,r,0]
    PaddingTop t           -> unsafeToForeign [0,t,0,0]
    PaddingHorizontal l r  -> unsafeToForeign [l,0,r,0]
    PaddingVertical t b    -> unsafeToForeign [0,t,0,b]

-- | Padding : left, top, right and bottom
-- | PaddingBottom : bottom
-- | PaddingHorizontal : left and right
-- | PaddingLeft : left
-- | PaddingRight : right
-- | PaddingTop : top
-- | PaddingVertical : top and bottom

renderPadding :: Padding -> String
renderPadding = case _ of
    Padding l t r b       -> show l <> "," <> show t <> "," <> show r <> "," <> show b
    PaddingBottom b       -> "0"    <> "," <> "0"    <> "," <> "0"    <> "," <> show b
    PaddingHorizontal l r -> show l <> "," <> "0"    <> "," <> show r <> "," <> "0"
    PaddingLeft l         -> show l <> "," <> "0"    <> "," <> "0"    <> "," <> "0"
    PaddingRight r        -> "0"    <> "," <> "0"    <> "," <> show r <> "," <> "0"
    PaddingTop t          -> "0"    <> "," <> show t <> "," <> "0"    <> "," <> "0"
    PaddingVertical t b   -> "0"    <> "," <> show t <> "," <> "0"    <> "," <> show b


--  "inputType": {
-- type: 'i',
-- password: '129',
-- numeric: '2',
-- numericPassword: '12',
-- disabled: '0',
-- text: '1'
-- }

data InputType
    = Password
    | Numeric
    | NumericPassword
    | Disabled
    | TypeText
    | Telephone

derive instance genericInputType:: Generic InputType _
instance decodeInputType :: Decode InputType where decode = decodeInputTypeUtil <<< toSafeString <<< unsafeFromForeign
instance showInputType :: Show InputType where show = genericShow
instance encodeInputType :: Encode InputType where encode = encodeInputTypeUtil >>> unsafeToForeign

decodeInputTypeUtil :: forall a. Applicative a => String -> ExceptT (NonEmptyList ForeignError) a InputType
decodeInputTypeUtil json =
  if isUndefined json then
    (except <<< Left <<< singleton <<< ForeignError) "inputType is not defined"
  else
    except $
      case toLower json of
        "password"        -> Right Password
        "numeric"         -> Right Numeric
        "numericpassword" -> Right NumericPassword
        "disabled"        -> Right Disabled
        "typetext"        -> Right TypeText
        "telephone"       -> Right Telephone
        _                 -> (Left <<< singleton <<< ForeignError) "Input Type is not supported"

renderInputType :: InputType -> String
renderInputType = case _ of
    Password -> "password"
    Numeric -> "numeric"
    NumericPassword -> "numericPassword"
    Disabled -> "disabled"
    TypeText -> "text"
    Telephone -> "telephone"

encodeInputTypeUtil :: InputType -> String
encodeInputTypeUtil = case _ of
    Password -> "password"
    Numeric -> "numeric"
    NumericPassword -> "numericPassword"
    Disabled -> "disabled"
    TypeText -> "typeText"
    Telephone -> "telephone"

-- orientation:

-- type: 'i'
-- horizontal: 0
-- vertical: 1
data Orientation
    = HORIZONTAL
    | VERTICAL

derive instance genericOrientation:: Generic Orientation _
instance decodeOrientation :: Decode Orientation where decode = decodeOrientationUtil <<< toSafeString <<< unsafeFromForeign
instance showOrientation:: Show Orientation where show = genericShow
instance encodeOrientation :: Encode Orientation where encode = renderOrientation >>> unsafeToForeign

decodeOrientationUtil :: forall a. Applicative a => String -> ExceptT (NonEmptyList ForeignError) a Orientation
decodeOrientationUtil json =
  if isUndefined json then
    (except <<< Left <<< singleton <<< ForeignError) "Orientation is not defined"
  else
    except $
    case toLower json of
      "horizontal"  -> Right HORIZONTAL
      "vertical"    -> Right VERTICAL
      _             -> (Left <<< singleton <<< ForeignError) "Orientation is not supported"

renderOrientation :: Orientation -> String
renderOrientation = case _ of
    HORIZONTAL -> "horizontal"
    VERTICAL -> "vertical"


-- "typeface": {

-- type: 'i',
-- 'normal': 0,
-- 'bold': 1,
-- 'italic': 2,
-- 'bold_italic': 3
data Typeface
    = NORMAL
    | BOLD
    | ITALIC
    | BOLD_ITALIC

derive instance genericTypeface :: Generic Typeface _
instance decodeTypeface :: Decode Typeface where decode = decodeTypefaceUtil <<< toSafeString <<< unsafeFromForeign
instance showTypeface :: Show Typeface where show = genericShow
instance encodeTypeface :: Encode Typeface where encode = renderTypeface >>> unsafeToForeign

decodeTypefaceUtil :: forall a. Applicative a => String -> ExceptT (NonEmptyList ForeignError) a Typeface
decodeTypefaceUtil json =
  if isUndefined json then
    (except <<< Left <<< singleton <<< ForeignError) "Typeface is not defined"
  else
    except $
    case toLower json of
      "normal"        -> Right NORMAL
      "bold"          -> Right BOLD
      "italic"        -> Right ITALIC
      "bold_italic"   -> Right BOLD_ITALIC
      _              -> (Left <<< singleton <<< ForeignError) "Type face is not supported"

renderTypeface :: Typeface -> String
renderTypeface = case _ of
    NORMAL -> "normal"
    BOLD -> "bold"
    ITALIC -> "italic"
    BOLD_ITALIC -> "bold_italic"


-- visibility:

-- type: 'i'
-- visible: 0
-- invisible: 4
-- gone: 8
data Visibility
    = VISIBLE
    | INVISIBLE
    | GONE

derive instance genericVisibility:: Generic Visibility _
derive instance eqVisibility :: Eq Visibility
instance decodeVisibility :: Decode Visibility where decode = decodeVisibilityUtil <<< toSafeString <<< unsafeFromForeign
instance showVisibility:: Show Visibility where show = genericShow
instance encodeVisibility :: Encode Visibility where encode = renderVisibility >>> unsafeToForeign

decodeVisibilityUtil :: forall a. Applicative a => String -> ExceptT (NonEmptyList ForeignError) a Visibility
decodeVisibilityUtil json =
  if isUndefined json then
    (except <<< Left <<< singleton <<< ForeignError) "Visibility is not defined"
  else
    except $
    case toLower json of
      "visible"     -> Right VISIBLE
      "invisible"   -> Right INVISIBLE
      "gone"        -> Right GONE
      _             -> (Left <<< singleton <<< ForeignError) "Visibility is not supported"

renderVisibility :: Visibility -> String
renderVisibility = case _ of
    VISIBLE -> "visible"
    INVISIBLE -> "invisible"
    GONE -> "gone"


{-- gravity: { --}
{--     type: 'i', --}
{--     center_horizontal: 1 --}
{--     center_vertical: 16 --}
{--     left: 8388611 --}
{--     right: 8388613 --}
{--     center: 17 --}
{--     top_vertical: 48 --}
{--     start: 8388611 --}
{--     end: 8388613 --}
{--     } --}
data Gravity
    = CENTER_HORIZONTAL
    | CENTER_VERTICAL
    | LEFT
    | RIGHT
    | CENTER
    | BOTTOM
    | TOP_VERTICAL
    | START
    | END
    | STRETCH

derive instance genericGravity:: Generic Gravity _
instance decodeGravity :: Decode Gravity where decode = decodeGravityUtil <<< toSafeString <<< unsafeFromForeign
instance encodeGravity :: Encode Gravity where encode = renderGravity >>> unsafeToForeign
instance showGravity:: Show Gravity where show = genericShow

decodeGravityUtil :: forall a. Applicative a => String -> ExceptT (NonEmptyList ForeignError) a Gravity
decodeGravityUtil json =
  if isUndefined json then
    (except <<< Left <<< singleton <<< ForeignError) "gravity is not defined"
  else
    except $
    case toLower json of
      "center_horizontal"   -> Right CENTER_HORIZONTAL
      "center_vertical"     -> Right CENTER_VERTICAL
      "left"                -> Right LEFT
      "right"               -> Right RIGHT
      "center"              -> Right CENTER
      "bottom"              -> Right BOTTOM
      "top_vertical"        -> Right TOP_VERTICAL
      "start"               -> Right START
      "end"                 -> Right END
      "stretch"             -> Right STRETCH
      _                     -> (Left <<< singleton <<< ForeignError) "Gravity is not supported"


renderGravity :: Gravity -> String
renderGravity = case _ of
    CENTER_HORIZONTAL -> "center_horizontal"
    CENTER_VERTICAL -> "center_vertical"
    LEFT -> "left"
    RIGHT -> "right"
    BOTTOM -> "bottom"
    CENTER -> "center"
    TOP_VERTICAL -> "top_vertical"
    START -> "start"
    END -> "end"
    STRETCH -> "stretch"

data Gradient
  = Radial (Array String)
  | Linear Number (Array String)

type GradientType = { type :: Maybe String, angle :: Foreign, values :: Array String }


derive instance genericGradient:: Generic Gradient _
instance showGradient:: Show Gradient where show = genericShow
instance decodeGradient :: Decode Gradient where decode = decodeGradientUtil
instance encodeGradient :: Encode Gradient where encode = encodeGradientUtil >>> encode

decodeGradientUtil :: forall a. Applicative a => Foreign -> ExceptT (NonEmptyList ForeignError) a Gradient
decodeGradientUtil json = let
  (gEither :: Either (NonEmptyList ForeignError) GradientType) = (runExcept $ decode json :: _ GradientType)
  (angle :: Either (NonEmptyList ForeignError) Number) = gEither >>= \a -> (runExcept (decode a.angle) :: _ Number) <|> (runExcept (decode a.angle >>= decodeJSON) :: _ Number)
  commonCode g angle =
    case toLower $ fromMaybe "" g.type of 
      "linear" ->  Right $ Linear angle g.values
      "radial" ->  Right $ Radial g.values 
      _        ->  if angle < 0.0 then Right $ Radial g.values else Right $ Linear angle g.values
  in
  except $
  case gEither, angle of
    Right g, Right ang -> commonCode g ang
    Right g, _ -> commonCode g 0.0
    Left err, _ -> Left err


encodeGradientUtil :: Gradient -> GradientType
encodeGradientUtil = case _ of
  Radial arr       -> { type: Just "radial", angle : encode 0.0, values : arr }
  Linear angle arr -> { type: Just "linear", angle : encode angle, values : arr }


renderGradient :: Gradient -> String
renderGradient = case _ of
  Radial arr       -> runFn3 stringifyGradient "radial" 0.0 arr
  Linear angle arr -> runFn3 stringifyGradient "linear" angle arr


data Shadow = Shadow Number Number Number Number String Number

derive instance genericShadow :: Generic Shadow _
instance decodeShadow :: Decode Shadow where decode = decodeShadowUtil <<< unsafeFromForeign
instance encodeShadow:: Encode Shadow where encode = encodeShadowUtil >>> unsafeToForeign
instance showShadow :: Show Shadow where show = genericShow

decodeShadowUtil :: forall a. Applicative a => String -> ExceptT (NonEmptyList ForeignError) a Shadow
decodeShadowUtil json =
  except $ toSafeArray
    Shadow json (Left <<< singleton <<< ForeignError) Right ["number", "number", "number", "number", "string", "number"]

encodeShadowUtil :: Shadow -> Foreign
encodeShadowUtil (Shadow x y blur spread color opacity) = unsafeToForeign [show x, show y, show blur, show spread, color, show opacity]

renderShadow :: Shadow -> String
renderShadow (Shadow x y blur spread color opacity) = show x <> "," <> show y <> "," <> show blur <> "," <> show spread <> "," <> color <> "," <> show opacity

data Corners
 = Corners Number Boolean Boolean Boolean Boolean
 | Corner Number

derive instance genericCorners :: Generic Corners _
instance decodeCorners :: Decode Corners where decode = decodeCornersUtil <<< unsafeFromForeign
instance encodeCorners :: Encode Corners where encode = encodeCornersUtil >>> unsafeToForeign
instance showCorners :: Show Corners where show = genericShow

decodeCornersUtil :: forall a. Applicative a => String -> ExceptT (NonEmptyList ForeignError) a Corners
decodeCornersUtil json =
  except $ toSafeArray
    Corners json (Left <<< singleton <<< ForeignError) Right ["number", "boolean", "boolean", "boolean", "boolean"]

encodeCornersUtil :: Corners -> Foreign
encodeCornersUtil =
  case _ of
    Corners n a b c d -> unsafeToForeign [show n, show a, show b, show c, show d]
    Corner n          -> unsafeToForeign [show n, "true", "true", "true", "true"]

renderCorners :: Corners -> String
renderCorners (Corners r tl tr br bl) = show r <> "," <> boolString tl <> "," <> boolString tr <> "," <> boolString br <> "," <> boolString bl
renderCorners (Corner r) = show r

boolString :: Boolean -> String
boolString true = "1"
boolString _ = "0"

data Font
  = Url String
  | Res Int
  | FontName String
  | Font String
  | Default String

type FontType = {type :: String, value :: String}

derive instance genericFont:: Generic Font _
instance decodeFont :: Decode Font where decode = decodeFontUtil <<< unsafeFromForeign
instance showFont:: Show Font where show = genericShow
instance encodeFont :: Encode Font where encode = encodeFontUtil >>> unsafeToForeign

decodeFontUtil :: forall a. Applicative a => String -> ExceptT (NonEmptyList ForeignError) a Font
decodeFontUtil json = let
  (parsedFont :: Either (NonEmptyList ForeignError) FontType) = toSafeObject json (Left <<< singleton <<< ForeignError) Right in
  except $
  case parsedFont of
    Left err    -> Left err
    Right font  ->
      case toLower font.type of
        "res"       -> Right (Res (fromMaybe 0 (fromString font.value)))
        "url"       -> Right (Url font.value)
        "fontname"  -> Right (FontName font.value)
        "default"   -> Right (Default font.value)
        "font"      -> Right (Font font.value)
        _           -> (Left <<< singleton <<< ForeignError) "Font type is not supported"

encodeFontUtil :: Font -> FontType
encodeFontUtil font =
  case font of
    FontName nm   -> {type : "fontname", value : nm}
    Font path     -> {type : "font", value : path}
    Res id        -> {type : "res", value : show id}
    Url url       -> {type : "url", value : url}
    Default d     -> {type : "default", value : d}

renderFont :: Font -> String
renderFont = case _ of
    Url url -> url
    Res id -> "resId," <> show id
    FontName fname -> fname
    Font path -> "path," <> path
    Default style -> "default," <> style

data LineSpacing
    = LineSpacing Int Number
    | LineSpacingExtra Int
    | LineSpacingMultiplier Number

renderLineSpacing :: LineSpacing -> String
renderLineSpacing = case _ of
    LineSpacing extra multiplier      -> (show extra) <> "," <> (show multiplier)
    LineSpacingExtra extra            -> (show extra) <> ",1.0"
    LineSpacingMultiplier multiplier  -> "0," <> (show multiplier)

data BottomSheetState
 = EXPANDED
 | COLLAPSED
 | HIDDEN
 | HALF_EXPANDED

renderBottomSheetState :: BottomSheetState -> String
renderBottomSheetState EXPANDED = "expanded"
renderBottomSheetState COLLAPSED = "collapsed"
renderBottomSheetState HIDDEN = "hidden"
renderBottomSheetState HALF_EXPANDED = "halfExpanded"

-- int LEFT_TO_RIGHT = 0;
-- int TOP_TO_BOTTOM = 1;
-- int RIGHT_TO_LEFT = 2;
-- int BOTTOM_TO_TOP = 3;

--INFINITE = -1

--int LINEAR = 0;
--int RADIAL = 1;

type ShimmerJson a = {
    base :: Maybe a,
    highlight :: Maybe a,
    tilt :: Maybe Int,
    intensity :: Maybe Int,
    direction :: Maybe Int,
    duration :: Maybe Int,
    repeatCount :: Maybe Int,
    repeatDelay :: Maybe Number,
    clipToChildren :: Maybe Boolean,
    shape :: Maybe Int,
    dropOff :: Maybe Number,
    active :: Boolean,
    shimmerType :: String
}

data Shimmer
    = AlphaBuilder (ShimmerJson Number)
    | ColorBuilder (ShimmerJson String)

derive instance genericShimmer :: Generic Shimmer _
instance encodeShimmer :: Encode Shimmer 
    where 
        encode (AlphaBuilder a) = encode a
        encode (ColorBuilder a) = encode a

renderShimmer :: Shimmer -> String
renderShimmer = defaultEncodeJSON

alphaBuilder :: Shimmer
alphaBuilder = AlphaBuilder {
    base : Nothing
    , highlight : Nothing
    , tilt : Nothing
    , intensity : Nothing
    , direction : Nothing
    , duration : Nothing
    , repeatCount : Nothing
    , repeatDelay : Nothing
    , clipToChildren : Nothing
    , shape : Nothing
    , dropOff : Nothing
    , active : true
    , shimmerType : "alpha"
    }

tilt :: Int -> Shimmer -> Shimmer
tilt f (AlphaBuilder a) = AlphaBuilder $ a { tilt = Just f}
tilt f (ColorBuilder a) = ColorBuilder $ a { tilt = Just f}

intensity :: Int -> Shimmer -> Shimmer
intensity f (AlphaBuilder a) = AlphaBuilder $ a { intensity = Just f}
intensity f (ColorBuilder a) = ColorBuilder $ a { intensity = Just f}

direction :: Int -> Shimmer -> Shimmer
direction f (AlphaBuilder a) = AlphaBuilder $ a { direction = Just f}
direction f (ColorBuilder a) = ColorBuilder $ a { direction = Just f}

duration :: Int -> Shimmer -> Shimmer
duration f (AlphaBuilder a) = AlphaBuilder $ a { duration = Just f}
duration f (ColorBuilder a) = ColorBuilder $ a { duration = Just f}

repeatCount :: Int -> Shimmer -> Shimmer
repeatCount f (AlphaBuilder a) = AlphaBuilder $ a { repeatCount = Just f}
repeatCount f (ColorBuilder a) = ColorBuilder $ a { repeatCount = Just f}

repeatDelay :: Number -> Shimmer -> Shimmer
repeatDelay f (AlphaBuilder a) = AlphaBuilder $ a { repeatDelay = Just f}
repeatDelay f (ColorBuilder a) = ColorBuilder $ a { repeatDelay = Just f}

clipToChildren :: Boolean -> Shimmer -> Shimmer
clipToChildren f (AlphaBuilder a) = AlphaBuilder $ a { clipToChildren = Just f}
clipToChildren f (ColorBuilder a) = ColorBuilder $ a { clipToChildren = Just f}

shape :: Int -> Shimmer -> Shimmer
shape f (AlphaBuilder a) = AlphaBuilder $ a { shape = Just f}
shape f (ColorBuilder a) = ColorBuilder $ a { shape = Just f}

dropOff :: Number -> Shimmer -> Shimmer
dropOff f (AlphaBuilder a) = AlphaBuilder $ a { dropOff = Just f}
dropOff f (ColorBuilder a) = ColorBuilder $ a { dropOff = Just f}

active :: Boolean -> Shimmer -> Shimmer
active f (AlphaBuilder a) = AlphaBuilder $ a { active = f}
active f (ColorBuilder a) = ColorBuilder $ a { active = f}


baseAlpha :: Number -> Shimmer -> Shimmer
baseAlpha f (AlphaBuilder a) = AlphaBuilder $ a {base = Just f}
baseAlpha _ shimmer = shimmer

highlightAlpha :: Number -> Shimmer -> Shimmer
highlightAlpha f (AlphaBuilder a) = AlphaBuilder $ a {highlight = Just f}
highlightAlpha _ shimmer = shimmer

baseColor :: String -> Shimmer -> Shimmer
baseColor f (ColorBuilder a) = ColorBuilder $ a {base = Just f}
baseColor _ shimmer = shimmer

highlightColor :: String -> Shimmer -> Shimmer
highlightColor f (ColorBuilder a) = ColorBuilder $ a {highlight = Just f}
highlightColor _ shimmer = shimmer

colorBuilder :: Shimmer
colorBuilder = ColorBuilder {
    base : Nothing
    , highlight : Nothing
    , tilt : Nothing
    , intensity : Nothing
    , direction : Nothing
    , duration : Nothing
    , repeatCount : Nothing
    , repeatDelay : Nothing
    , clipToChildren : Nothing
    , shape : Nothing
    , dropOff : Nothing
    , active : true
    , shimmerType : "color"
    }

data LetterSpacing
  = PX Number
  | EM Number
  | REM Number

derive instance genericLetterSpacing:: Generic LetterSpacing _
instance decodeLetterSpacing :: Decode LetterSpacing where decode = decodeLetterSpacingUtil <<< toSafeString <<< unsafeFromForeign
instance showLetterSpacing :: Show LetterSpacing where show = genericShow
instance encodeLetterSpacing :: Encode LetterSpacing where encode = renderLetterSpacing >>> unsafeToForeign

decodeLetterSpacingUtil :: forall a. Applicative a => String -> ExceptT (NonEmptyList ForeignError) a LetterSpacing
decodeLetterSpacingUtil json =
  if isUndefined json then
    (except <<< Left <<< singleton <<< ForeignError) "LetterSpacing is undefined"
  else
    except $ toSafeNumber PX json (Left <<< singleton <<< ForeignError) Right

renderLetterSpacing :: LetterSpacing -> String
renderLetterSpacing =
  case _ of
    PX a    -> func (show a) "px"
    EM b    -> func (show b) "em"
    REM c   -> func (show c) "rem"
  where
    func pre suff = case __IS_WEB unit of
      true  -> pre <> suff
      false -> pre
