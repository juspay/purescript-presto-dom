module PrestoDOM.Properties
    ( prop
    , id

    , root
    , a_duration
    , a_scaleX
    , a_scaleY
    , a_translationX
    , a_translationY
    , absolute
    , accessibilityHint
    , adjustViewBounds
    , alpha
    , hideable
    , animation

    , background
    , backgroundColor
    , backgroundDrawable
    , backgroundTint
    , peakHeight
    , btnBackground
    , btnColor
    , buttonTint
    , enableRefresh
    , setEnable
    , buttonClickOverlay

    , cardWidth
    , checked
    , classList
    , className
    , clickable
    , clipChildren
    , color
    , colorFilter
    , cornerRadius
    , curve
    , caretColor
    , cornerRadii

    , delay
    , dividerDrawable
    , duration

    , elevation
    , ellipsize
    , fillViewport
    , focus
    , focusable
    , focusOut
    , fontFamily
    , fontSize
    , fontStyle
    , font
    , foreground
    , fromBottom
    , fromLeft
    , fromRight
    , fromTop

    , gravity
    , gradient

    , hardware
    , height
    , hint
    , hintColor
    , hoverBg
    , hoverColor
    , hoverPath

    , imageUrl
    , inputType
    , inputTypeI

    , layoutGravity
    , layoutTransition
    , bottomFixed
    , autofocus
    , letterSpacing
    , lineHeight
    , lineSpacing

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
    , maxHeight

    , orientation

    , padding
    , percentWidth
    , pivotX
    , pivotY
    , position
    , progressColor
    , packageIcon
    , placeHolder

    , rotation
    , rotationX
    , rotationY
    , removeClassList
    
    , sheetState
    , halfExpandedRatio
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
    , shadow
    , showDividers
    , singleLine
    , stroke
    , shimmer
    , separator
    , separatorRepeat

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
    , useStartApp
    , unNestPayload

    , values
    , visibility

    , weight
    , width
    , alignParentBottom
    , alignParentLeft
    , popupMenu
    , pattern
    , shimmerActive
    , viewGroupTag
    , payload
    ) where

import Prelude

import Data.String (toLower)
import Halogen.VDom.DOM.Prop (Prop(..))
import PrestoDOM.Types.Core (class IsProp, Gradient, Gravity, InputType, Length, Margin, Orientation, Padding, Position, PropName(..), Shadow, Typeface, Visibility, toPropValue)
import PrestoDOM.Types.DomAttributes (BottomSheetState, Corners, Font(..), LineSpacing, Shimmer, __IS_ANDROID)


prop :: forall value i. IsProp value => PropName value -> value -> Prop i
prop (PropName name) = Property name <<< toPropValue

id :: forall i. String -> Prop i
id = prop (PropName "id")

retFontFamilyAndroid :: forall i. String -> Prop i
retFontFamilyAndroid str = case (toLower str) of
  "regular" -> fontFamily "sans-serif,normal"
  "bold" -> fontFamily "sans-serif,bold"
  _ -> fontFamily "sans-serif-medium,normal"

-- | Boolean
root :: forall i. Boolean -> Prop i
root = prop (PropName "root")

a_duration :: forall i. Number -> Prop i
a_duration = prop (PropName "a_duration")

a_scaleX :: forall i. String -> Prop i
a_scaleX = prop (PropName "a_scaleX")

a_scaleY :: forall i. String -> Prop i
a_scaleY = prop (PropName "a_scaleY")

a_translationX :: forall i. Boolean -> Prop i
a_translationX = prop (PropName "a_translationX")

a_translationY :: forall i. Boolean -> Prop i
a_translationY = prop (PropName "a_translationY")

-- | Boolean
absolute :: forall i. Boolean -> Prop i
absolute = prop (PropName "absolute")

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

-- | Boolean 
enableRefresh :: forall i. Boolean -> Prop i
enableRefresh = prop (PropName "enableRefresh")

-- | Boolean 
setEnable :: forall i. Boolean -> Prop i
setEnable = prop (PropName "setEnable")

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

-- | Number
buttonClickOverlay :: forall i. Number -> Prop i
buttonClickOverlay = prop (PropName "buttonClickOverlay")

cardWidth :: forall i. Number -> Prop i
cardWidth = prop (PropName "cardWidth")

-- | Boolean
checked :: forall i. Boolean -> Prop i
checked = prop (PropName "checked")

-- | Array String
classList :: forall i. Array String -> Prop i
classList = prop (PropName "classList")

-- | String
className :: forall i. String -> Prop i
className = prop (PropName "className")

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

cornerRadii :: forall i. Corners -> Prop i
cornerRadii =  prop (PropName "cornerRadii")


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
ellipsize :: forall i. Boolean -> Prop i
ellipsize = prop (PropName "ellipsize")

-- | Boolean
fillViewport :: forall i. Boolean -> Prop i
fillViewport = prop (PropName "fillViewport")

focus :: forall i. Boolean -> Prop i
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

-- | Font
font :: forall i. Font -> Prop i
font fontVal = case fontVal of
    Default str -> (if __IS_ANDROID then retFontFamilyAndroid str else fontFamily str)
    FontName str -> fontStyle str
    _ -> (prop (PropName "font")) fontVal

-- | Boolean
foreground :: forall i. Boolean -> Prop i
foreground = prop (PropName "foreground")


-- | Number
fromBottom :: forall i. Number -> Prop i
fromBottom = prop (PropName "fromBottom")

-- | Number
fromLeft :: forall i. Number -> Prop i
fromLeft = prop (PropName "fromLeft")

-- | Number
fromRight :: forall i. Number -> Prop i
fromRight = prop (PropName "fromRight")

-- | Number
fromTop :: forall i. Number -> Prop i
fromTop = prop (PropName "fromTop")

-- | Gravity
gravity :: forall i. Gravity -> Prop i
gravity = prop (PropName "gravity")

-- | Gradient
gradient :: forall i. Gradient -> Prop i
gradient = prop (PropName "gradient")



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
hoverBg :: forall i. String -> Prop i
hoverBg = prop (PropName "hoverBg")

-- | String
hoverColor :: forall i. String -> Prop i
hoverColor = prop (PropName "hoverColor")

hoverPath :: forall i. String -> Prop i
hoverPath = prop (PropName "hoverPath")

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

-- | Boolean
autofocus :: forall i. Boolean -> Prop i
autofocus = prop (PropName "autofocus")

-- | Number
bottomFixed :: forall i. Number -> Prop i
bottomFixed = prop (PropName "bottomFixed")

-- | Number
letterSpacing :: forall i. Number -> Prop i
letterSpacing = prop (PropName "letterSpacing")

lineHeight :: forall i. String -> Prop i
lineHeight = prop (PropName "lineHeight")

-- | LineSpacing: extra, multiplier
-- | LineSpacingExtra : extra
-- | LineSpacingMultiplier : multiplier
lineSpacing :: forall i. LineSpacing -> Prop i
lineSpacing = prop (PropName "lineSpacing")


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
maxHeight :: forall i. Int -> Prop i
maxHeight = prop (PropName "maxHeight")

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

-- | String
packageIcon :: forall i. String -> Prop i
packageIcon = prop (PropName "packageIcon")

-- | Boolean
percentWidth :: forall i. Boolean -> Prop i
percentWidth = prop (PropName "percentWidth")

-- | Number
pivotX :: forall i. Number -> Prop i
pivotX = prop (PropName "pivotX")

-- | Number
pivotY :: forall i. Number -> Prop i
pivotY = prop (PropName "pivotY")

-- | String
progressColor :: forall i. String -> Prop i
progressColor = prop (PropName "progressColor")

-- | String
placeHolder :: forall i. String -> Prop i
placeHolder = prop (PropName "placeHolder")

-- | Array String
removeClassList :: forall i. Array String -> Prop i
removeClassList = prop (PropName "removeClassList")

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

-- | String 
separator :: ∀ i. String -> Prop i
separator = prop (PropName "separator")

-- | String 
separatorRepeat :: ∀ i. String -> Prop i
separatorRepeat = prop (PropName "separatorRepeat")

-- | L, // long
setDate :: forall i. String -> Prop i
setDate = prop (PropName "setDate")

-- | Shadow
shadow :: forall i. Shadow -> Prop i
shadow = prop (PropName "shadow")

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
weight :: forall i. Number -> Prop i
weight = prop (PropName "weight")

width :: forall i. Length -> Prop i
width = prop (PropName "width")

position :: forall i. Position -> Prop i
position = prop (PropName "position")


-- | Unknown
alignParentBottom :: forall i. String -> Prop i
alignParentBottom = prop (PropName "alignParentBottom")

-- | Unknown
alignParentLeft :: forall i. String -> Prop i
alignParentLeft = prop (PropName "alignParentLeft")


pattern :: forall i. String -> Prop i
pattern = prop (PropName "pattern")

-- | String
popupMenu :: forall i. String -> Prop i
popupMenu = prop (PropName "popupMenu")

-- | Int -- ime option for edittext
imeOptions :: forall i. Int -> Prop i
imeOptions = prop (PropName "imeOptions")

-- | Shimmer Properties -- should start shimmer
shimmer :: forall i. Shimmer -> Prop i
shimmer = prop (PropName "shimmer")

peakHeight :: forall i. Int -> Prop i
peakHeight = prop (PropName "peakHeight")

hideable :: forall i. Boolean -> Prop i
hideable = prop (PropName "hideable")

sheetState :: forall i. BottomSheetState -> Prop i
sheetState = prop (PropName "sheetState")

halfExpandedRatio :: forall i. Number -> Prop i
halfExpandedRatio = prop (PropName "halfExpandedRatio")

-- | Boolean -- should start shimmer
shimmerActive :: forall i. Boolean -> Prop i
shimmerActive true = prop (PropName "shimmerActive") true
shimmerActive false = prop (PropName "shimmerInactive") true

viewGroupTag :: forall i. String -> Prop i
viewGroupTag = prop (PropName "viewGroupTag")

useStartApp :: forall i. Boolean -> Prop i
useStartApp = prop (PropName "useStartApp")

unNestPayload :: forall i. Boolean -> Prop i
unNestPayload = prop (PropName "unNestPayload")

payload :: forall i. String -> Prop i
payload = Payload