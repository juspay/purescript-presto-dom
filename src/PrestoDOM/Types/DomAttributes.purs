module PrestoDOM.Types.DomAttributes
    ( Gravity(..)
    , Gradient(..)
    , InputType(..)
    , Length(..)
    , Position(..)
    , Orientation(..)
    , Typeface(..)
    , Visibility(..)
    , Padding(..)
    , Margin(..)
    , Shadow(..)
    , Corners(..)
    , renderMargin
    , renderPadding
    , renderGravity
    , renderGradient
    , renderInputType
    , renderLength
    , renderPosition
    , renderOrientation
    , renderTypeface
    , renderVisibility
    , renderShadow
    , renderCorners
    ) where

import Prelude (show, (<>))
import Data.Function.Uncurried (Fn3, runFn3)

foreign import stringifyGradient :: Fn3 String Number (Array String) String

data Length
    = MATCH_PARENT
    | WRAP_CONTENT
    | V Int


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

renderInputType :: InputType -> String
renderInputType = case _ of
    Password -> "password"
    Numeric -> "numeric"
    NumericPassword -> "numericPassword"
    Disabled -> "disabled"
    TypeText -> "text"



-- orientation:

-- type: 'i'
-- horizontal: 0
-- vertical: 1
data Orientation
    = HORIZONTAL
    | VERTICAL

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

data Gradient
  = Radial (Array String)
  | Linear Number (Array String)

renderGradient :: Gradient -> String
renderGradient = case _ of
  Radial arr       -> runFn3 stringifyGradient "radial" 0.0 arr
  Linear angle arr -> runFn3 stringifyGradient "linear" angle arr


data Shadow = Shadow Number Number Number Number String Number

renderShadow :: Shadow -> String
renderShadow (Shadow x y blur spread color opacity) = show x <> "," <> show y <> "," <> show blur <> "," <> show spread <> "," <> color <> "," <> show opacity

data Corners
 = Corners Number Boolean Boolean Boolean Boolean
 | Corner Number

renderCorners :: Corners -> String
renderCorners (Corners r tl tr br bl) = show r <> "," <> boolString tl <> "," <> boolString tr <> "," <> boolString br <> "," <> boolString bl
renderCorners (Corner r) = show r

boolString :: Boolean -> String
boolString true = "1"
boolString _ = "0"