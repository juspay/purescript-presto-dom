module PrestoDOM.Types.DomAttributes
    ( Gravity(..)
    , InputType(..)
    , Length(..)
    , Orientation(..)
    , Typeface(..)
    , Visibility(..)
    , renderGravity
    , renderInputType
    , renderLength
    , renderOrientation
    , renderTypeface
    , renderVisibility
    ) where

import Prelude (show)

data Length
    = MATCH_PARENT
    | WRAP_CONTENT
    | V Int


renderLength :: Length -> String
renderLength = case _ of
    MATCH_PARENT -> "match_parent"
    WRAP_CONTENT -> "wrap_content"
    V n -> show n




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
    | TOP_VERTICAL
    | START
    | END

renderGravity :: Gravity -> String
renderGravity = case _ of
    CENTER_HORIZONTAL -> "center_horizontal"
    CENTER_VERTICAL -> "center_vertical"
    LEFT -> "left"
    RIGHT -> "right"
    CENTER -> "center"
    TOP_VERTICAL -> "top_vertical"
    START -> "start"
    END -> "end"
