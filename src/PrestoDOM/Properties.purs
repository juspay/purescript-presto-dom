module PrestoDOM.Properties
    ( prop
    , id_

    , root
    , a_duration
    , a_scaleX
    , a_scaleY
    , accessibilityHint
    , adjustViewBounds
    , alpha
    , animation

    , background
    , backgroundColor
    , backgroundDrawable
    , backgroundTint
    , btnBackground
    , btnColor
    , buttonTint

    , checked
    , clickable
    , clipChildren
    , color
    , colorFilter
    , cornerRadius
    , curve
    , caretColor

    , delay
    , dividerDrawable
    , duration

    , elevation

    , fillViewport
    , focus
    , focusable
    , focusOut
    , fontFamily
    , fontSize
    , fontStyle
    , foreground

    , gravity

    , hardware
    , height
    , hint
    , hintColor

    , imageUrl
    , inputType
    , inputTypeI

    , layoutGravity
    , layoutTransition
    , letterSpacing
    , lineHeight

    , margin
    , marginEnd
    , marginStart
    , maxDate
    , maxLines
    , maxSeek
    , maxWidth
    , minDate
    , minHeight
    , minWidth

    , orientation

    , padding
    , pivotX
    , pivotY
    , progressColor

    , rotation
    , rotationX
    , rotationY

    , scaleType
    , scaleX
    , scaleY
    , scrollBarX
    , scrollBarY
    , selectable
    , selectableItem
    , selected
    , selectedTabIndicatorColor
    , selectedTabIndicatorHeight
    , setDate
    , shadowLayer
    , showDividers
    , singleLine
    , stroke

    , tabTextColors
    , text
    , textAllCaps
    , textFromHtml
    , textIsSelectable
    , textSize
    , translationX
    , translationY
    , translationZ
    , toast
    , typeface

    , url

    , values
    , visibility

    , weight
    , width
    , alignParentBottom
    , alignParentLeft
    ) where

import Prelude

-- import Data.Tuple (Tuple(..))
import Halogen.VDom.DOM.Prop (Prop(..))
import PrestoDOM.Types.Core (class IsProp, PropName(..), Margin, Padding, Gravity, InputType, Length, Orientation, Typeface, Visibility, toPropValue)


prop :: forall value i. IsProp value => PropName value -> value -> Prop i
prop (PropName name) = Property name <<< toPropValue

id_ :: forall i. String -> Prop i
id_ = prop (PropName "id")


-- | Boolean
root :: forall i. Boolean -> Prop i
root = prop (PropName "root")

a_duration :: forall i. String -> Prop i
a_duration = prop (PropName "a_duration")

a_scaleX :: forall i. String -> Prop i
a_scaleX = prop (PropName "a_scaleX")

a_scaleY :: forall i. String -> Prop i
a_scaleY = prop (PropName "a_scaleY")

-- | String
accessibilityHint :: forall i. String -> Prop i
accessibilityHint = prop (PropName "accessibilityHint")

-- | Boolean
adjustViewBounds :: forall i. Boolean -> Prop i
adjustViewBounds = prop (PropName "adjustViewBounds")

-- | Number
alpha :: forall i. Number -> Prop i
alpha = prop (PropName "alpha")

animation :: forall i. String -> Prop i
animation = prop (PropName "animation")


-- | String
background :: forall i. String -> Prop i
background = prop (PropName "background")

-- | String
backgroundColor :: forall i. String -> Prop i
backgroundColor = prop (PropName "backgroundColor")

-- | String
backgroundDrawable :: forall i. String -> Prop i
backgroundDrawable = prop (PropName "backgroundDrawable")

-- | String
backgroundTint :: forall i. String -> Prop i
backgroundTint = prop (PropName "backgroundTint")

-- | String
btnBackground :: forall i. String -> Prop i
btnBackground = prop (PropName "btnBackground")

-- | String
btnColor :: forall i. String -> Prop i
btnColor = prop (PropName "btnColor")

-- | String
buttonTint :: forall i. String -> Prop i
buttonTint = prop (PropName "buttonTint")



-- | Boolean
checked :: forall i. Boolean -> Prop i
checked = prop (PropName "checked")

-- | Boolean
clickable :: forall i. Boolean -> Prop i
clickable = prop (PropName "clickable")

-- | Boolean
clipChildren :: forall i. Boolean -> Prop i
clipChildren = prop (PropName "clipChildren")

-- | String
color :: forall i. String -> Prop i
color = prop (PropName "color")

-- | Unknown
colorFilter :: forall i. String -> Prop i
colorFilter = prop (PropName "colorFilter")

-- | Number
cornerRadius :: forall i. Number -> Prop i
cornerRadius = prop (PropName "cornerRadius")

-- curve
-- | String
curve :: forall i. String -> Prop i
curve = prop (PropName "curve")



-- | L, // long
delay :: forall i. String -> Prop i
delay = prop (PropName "delay")

-- | String
dividerDrawable :: forall i. String -> Prop i
dividerDrawable = prop (PropName "dividerDrawable")

-- | L, // long
duration :: forall i. String -> Prop i
duration = prop (PropName "duration")



-- | Int
elevation :: forall i. Int -> Prop i
elevation = prop (PropName "elevation")



-- | Boolean
fillViewport :: forall i. Boolean -> Prop i
fillViewport = prop (PropName "fillViewport")

focus :: forall i. String -> Prop i
focus = prop (PropName "focus")

-- | Boolean
focusable :: forall i. Boolean -> Prop i
focusable = prop (PropName "focusable")

focusOut :: forall i. String -> Prop i
focusOut = prop (PropName "focusOut")

-- | Unknown
fontFamily :: forall i. String -> Prop i
fontFamily = prop (PropName "fontFamily")

-- | Int
fontSize :: forall i. Int -> Prop i
fontSize = prop (PropName "fontSize")

-- | String
fontStyle :: forall i. String -> Prop i
fontStyle = prop (PropName "fontStyle")

-- | Boolean
foreground :: forall i. Boolean -> Prop i
foreground = prop (PropName "foreground")



-- | Gravity
gravity :: forall i. Gravity -> Prop i
gravity = prop (PropName "gravity")



-- | Unknown
hardware :: forall i. String -> Prop i
hardware = prop (PropName "hardware")

height :: forall i. Length -> Prop i
height = prop (PropName "height")

-- | String
hint :: forall i. String -> Prop i
hint = prop (PropName "hint")

-- | String
hintColor :: forall i. String -> Prop i
hintColor = prop (PropName "hintColor")



-- | String
imageUrl :: forall i. String -> Prop i
imageUrl = prop (PropName "imageUrl")

-- | InputType
inputType :: forall i. InputType -> Prop i
inputType = prop (PropName "inputType")

-- | Int
inputTypeI :: forall i. Int -> Prop i
inputTypeI = prop (PropName "inputTypeI")



{-- values: [{ --}
{--           type: 'i', --}
{--  bottom_right: 21, --}
{-- top: 30, --}
{-- bottom: 50, --}
{-- left: 3, --}
{-- right: 5, --}
{-- center: 17, --}
{-- center_horizontal: 1, --}
{-- center_vertical: 16, --}
{-- start: 8388611, --}
{-- end: 8388613,}] --}
layoutGravity :: forall i. String -> Prop i
layoutGravity = prop (PropName "layout_gravity")

-- | Boolean
layoutTransition :: forall i. Boolean -> Prop i
layoutTransition = prop (PropName "layoutTransition")

-- | Number
letterSpacing :: forall i. Number -> Prop i
letterSpacing = prop (PropName "letterSpacing")

lineHeight :: forall i. String -> Prop i
lineHeight = prop (PropName "lineHeight")



-- | Margin : left, top, right and bottom
-- | MarginBottom : bottom
-- | MarginHorizontal : left and right
-- | MarginLeft : left
-- | MarginRight : right
-- | MarginTop : top
-- | MarginVertical : top and bottom
margin :: forall i. Margin -> Prop i
margin = prop (PropName "margin")

-- | Int
marginEnd :: forall i. Int -> Prop i
marginEnd = prop (PropName "marginEnd")

-- | Int
marginStart :: forall i. Int -> Prop i
marginStart = prop (PropName "marginStart")

-- | L, // long
maxDate :: forall i. String -> Prop i
maxDate = prop (PropName "maxDate")

-- | Int
maxLines :: forall i. Int -> Prop i
maxLines = prop (PropName "maxLines")

-- | int
maxSeek :: forall i. Int -> Prop i
maxSeek = prop (PropName "maxSeek")

-- | Int
maxWidth :: forall i. Int -> Prop i
maxWidth = prop (PropName "maxWidth")

-- | L, // long
minDate :: forall i. String -> Prop i
minDate = prop (PropName "minDate")

-- | Int
minHeight :: forall i. Int -> Prop i
minHeight = prop (PropName "minHeight")

-- | Int
minWidth :: forall i. Int -> Prop i
minWidth = prop (PropName "minWidth")



-- | Orientation
orientation :: forall i. Orientation -> Prop i
orientation = prop (PropName "orientation")



-- | Padding : left, top, right and bottom
-- | PaddingBottom : bottom
-- | PaddingHorizontal : left and right
-- | PaddingLeft : left
-- | PaddingRight : right
-- | PaddingTop : top
-- | PaddingVertical : top and bottom
padding :: forall i. Padding -> Prop i
padding = prop (PropName "padding")

-- | Number
pivotX :: forall i. Number -> Prop i
pivotX = prop (PropName "pivotX")

-- | Number
pivotY :: forall i. Number -> Prop i
pivotY = prop (PropName "pivotY")

-- | String
progressColor :: forall i. String -> Prop i
progressColor = prop (PropName "progressColor")



-- | Number
rotation :: forall i. Number -> Prop i
rotation = prop (PropName "rotation")

-- | Number
rotationX :: forall i. Number -> Prop i
rotationX = prop (PropName "rotationX")

-- | Number
rotationY :: forall i. Number -> Prop i
rotationY = prop (PropName "rotationY")



-- | String
scaleType :: forall i. String -> Prop i
scaleType = prop (PropName "scaleType")

-- | Number
scaleX :: forall i. Number -> Prop i
scaleX = prop (PropName "scaleX")

-- | Number
scaleY :: forall i. Number -> Prop i
scaleY = prop (PropName "scaleY")

-- | Boolean
scrollBarX :: forall i. Boolean -> Prop i
scrollBarX = prop (PropName "scrollBarX")

-- | Boolean
scrollBarY :: forall i. Boolean -> Prop i
scrollBarY = prop (PropName "scrollBarY")

-- | Boolean
selectable :: forall i. Boolean -> Prop i
selectable = prop (PropName "selectable")

-- | Boolean
selectableItem :: forall i. Boolean -> Prop i
selectableItem = prop (PropName "selectableItem")

-- | Boolean
selected :: forall i. Boolean -> Prop i
selected = prop (PropName "selected")

-- | String
selectedTabIndicatorColor :: forall i. String -> Prop i
selectedTabIndicatorColor = prop (PropName "selectedTabIndicatorColor")

-- | Int
selectedTabIndicatorHeight :: forall i. Int -> Prop i
selectedTabIndicatorHeight = prop (PropName "selectedTabIndicatorHeight")

-- | L, // long
setDate :: forall i. String -> Prop i
setDate = prop (PropName "setDate")

-- | Unknown
shadowLayer :: forall i. String -> Prop i
shadowLayer = prop (PropName "shadowLayer")

-- | Int
showDividers :: forall i. Int -> Prop i
showDividers = prop (PropName "showDividers")

-- | Boolean
singleLine :: forall i. Boolean -> Prop i
singleLine = prop (PropName "singleLine")

-- | Unknown
stroke :: forall i. String -> Prop i
stroke = prop (PropName "stroke")

caretColor :: forall i. String -> Prop i
caretColor = prop (PropName "caretColor")

-- | Unknown
tabTextColors :: forall i. String -> Prop i
tabTextColors = prop (PropName "tabTextColors")

-- | String
text :: forall i. String -> Prop i
text = prop (PropName "text")

-- | Boolean
textAllCaps :: forall i. Boolean -> Prop i
textAllCaps = prop (PropName "textAllCaps")

-- | String
textFromHtml :: forall i. String -> Prop i
textFromHtml = prop (PropName "textFromHtml")

-- | Boolean
textIsSelectable :: forall i. Boolean -> Prop i
textIsSelectable = prop (PropName "textIsSelectable")

textSize :: forall i. Int -> Prop i
textSize = prop (PropName "textSize")

-- | Number
translationX :: forall i. Number -> Prop i
translationX = prop (PropName "translationX")

-- | Number
translationY :: forall i. Number -> Prop i
translationY = prop (PropName "translationY")

-- | Number
translationZ :: forall i. Number -> Prop i
translationZ = prop (PropName "translationZ")

-- | String
toast :: forall i. String -> Prop i
toast = prop (PropName "toast")

-- | Typeface
typeface :: forall i. Typeface -> Prop i
typeface = prop (PropName "typeface")



-- | String
url :: forall i. String -> Prop i
url = prop (PropName "url")



-- | String
values :: forall i. String -> Prop i
values = prop (PropName "values")

-- | Visibility
visibility :: forall i. Visibility -> Prop i
visibility = prop (PropName "visibility")



{-- type: 'f', --}
{--           match_parent: -1, --}
{--                 wrap_content: -2, --}
weight :: forall i. String -> Prop i
weight = prop (PropName "weight")

width :: forall i. Length -> Prop i
width = prop (PropName "width")

-- | Unknown
alignParentBottom :: forall i. String -> Prop i
alignParentBottom = prop (PropName "alignParentBottom")

-- | Unknown
alignParentLeft :: forall i. String -> Prop i
alignParentLeft = prop (PropName "alignParentLeft")
