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

    , layout_gravity
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
import PrestoDOM.Types.Core (class IsProp, Length, PropName(..), toPropValue)


prop :: forall value i. IsProp value => PropName value -> value -> Prop i
prop (PropName name) = Property name <<< toPropValue

id_ :: forall i. String -> Prop i
id_ = prop (PropName "id")


root :: forall i. Boolean -> Prop i
root = prop (PropName "root")

a_duration :: forall i. String -> Prop i
a_duration = prop (PropName "a_duration")

a_scaleX :: forall i. String -> Prop i
a_scaleX = prop (PropName "a_scaleX")

a_scaleY :: forall i. String -> Prop i
a_scaleY = prop (PropName "a_scaleY")

accessibilityHint :: forall i. String -> Prop i
accessibilityHint = prop (PropName "accessibilityHint")

adjustViewBounds :: forall i. String -> Prop i
adjustViewBounds = prop (PropName "adjustViewBounds")

alpha :: forall i. String -> Prop i
alpha = prop (PropName "alpha")



background :: forall i. String -> Prop i
background = prop (PropName "background")

backgroundColor :: forall i. String -> Prop i
backgroundColor = prop (PropName "backgroundColor")

backgroundDrawable :: forall i. String -> Prop i
backgroundDrawable = prop (PropName "backgroundDrawable")

backgroundTint :: forall i. String -> Prop i
backgroundTint = prop (PropName "backgroundTint")

btnBackground :: forall i. String -> Prop i
btnBackground = prop (PropName "btnBackground")

btnColor :: forall i. String -> Prop i
btnColor = prop (PropName "btnColor")

buttonTint :: forall i. String -> Prop i
buttonTint = prop (PropName "buttonTint")



checked :: forall i. String -> Prop i
checked = prop (PropName "checked")

clickable :: forall i. String -> Prop i
clickable = prop (PropName "clickable")

clipChildren :: forall i. String -> Prop i
clipChildren = prop (PropName "clipChildren")

color :: forall i. String -> Prop i
color = prop (PropName "color")

colorFilter :: forall i. String -> Prop i
colorFilter = prop (PropName "colorFilter")

cornerRadius :: forall i. String -> Prop i
cornerRadius = prop (PropName "cornerRadius")

curve :: forall i. String -> Prop i
curve = prop (PropName "curve")



delay :: forall i. String -> Prop i
delay = prop (PropName "delay")

dividerDrawable :: forall i. String -> Prop i
dividerDrawable = prop (PropName "dividerDrawable")

duration :: forall i. String -> Prop i
duration = prop (PropName "duration")



elevation :: forall i. String -> Prop i
elevation = prop (PropName "elevation")



fillViewport :: forall i. String -> Prop i
fillViewport = prop (PropName "fillViewport")

focus :: forall i. String -> Prop i
focus = prop (PropName "focus")

focusable :: forall i. String -> Prop i
focusable = prop (PropName "focusable")

focusOut :: forall i. String -> Prop i
focusOut = prop (PropName "focusOut")

fontFamily :: forall i. String -> Prop i
fontFamily = prop (PropName "fontFamily")

fontSize :: forall i. Int -> Prop i
fontSize = prop (PropName "fontSize")

fontStyle :: forall i. String -> Prop i
fontStyle = prop (PropName "fontStyle")

foreground :: forall i. String -> Prop i
foreground = prop (PropName "foreground")



gravity :: forall i. String -> Prop i
gravity = prop (PropName "gravity")



hardware :: forall i. String -> Prop i
hardware = prop (PropName "hardware")

height :: forall i. Length -> Prop i
height = prop (PropName "height")

hint :: forall i. String -> Prop i
hint = prop (PropName "hint")

hintColor :: forall i. String -> Prop i
hintColor = prop (PropName "hintColor")



imageUrl :: forall i. String -> Prop i
imageUrl = prop (PropName "imageUrl")

inputType :: forall i. String -> Prop i
inputType = prop (PropName "inputType")

inputTypeI :: forall i. String -> Prop i
inputTypeI = prop (PropName "inputTypeI")



layout_gravity :: forall i. String -> Prop i
layout_gravity = prop (PropName "layout_gravity")

layoutTransition :: forall i. String -> Prop i
layoutTransition = prop (PropName "layoutTransition")

letterSpacing :: forall i. String -> Prop i
letterSpacing = prop (PropName "letterSpacing")

lineHeight :: forall i. String -> Prop i
lineHeight = prop (PropName "lineHeight")



margin :: forall i. String -> Prop i
margin = prop (PropName "margin")

marginEnd :: forall i. String -> Prop i
marginEnd = prop (PropName "marginEnd")

marginStart :: forall i. String -> Prop i
marginStart = prop (PropName "marginStart")

maxDate :: forall i. String -> Prop i
maxDate = prop (PropName "maxDate")

maxLines :: forall i. String -> Prop i
maxLines = prop (PropName "maxLines")

maxSeek :: forall i. String -> Prop i
maxSeek = prop (PropName "maxSeek")

maxWidth :: forall i. String -> Prop i
maxWidth = prop (PropName "maxWidth")

minDate :: forall i. String -> Prop i
minDate = prop (PropName "minDate")

minHeight :: forall i. String -> Prop i
minHeight = prop (PropName "minHeight")

minWidth :: forall i. String -> Prop i
minWidth = prop (PropName "minWidth")



orientation :: forall i. String -> Prop i
orientation = prop (PropName "orientation")



padding :: forall i. String -> Prop i
padding = prop (PropName "padding")

pivotX :: forall i. String -> Prop i
pivotX = prop (PropName "pivotX")

pivotY :: forall i. String -> Prop i
pivotY = prop (PropName "pivotY")

progressColor :: forall i. String -> Prop i
progressColor = prop (PropName "progressColor")



rotation :: forall i. String -> Prop i
rotation = prop (PropName "rotation")

rotationX :: forall i. String -> Prop i
rotationX = prop (PropName "rotationX")

rotationY :: forall i. String -> Prop i
rotationY = prop (PropName "rotationY")



scaleType :: forall i. String -> Prop i
scaleType = prop (PropName "scaleType")

scaleX :: forall i. String -> Prop i
scaleX = prop (PropName "scaleX")

scaleY :: forall i. String -> Prop i
scaleY = prop (PropName "scaleY")

scrollBarX :: forall i. String -> Prop i
scrollBarX = prop (PropName "scrollBarX")

scrollBarY :: forall i. String -> Prop i
scrollBarY = prop (PropName "scrollBarY")

selectable :: forall i. String -> Prop i
selectable = prop (PropName "selectable")

selectableItem :: forall i. String -> Prop i
selectableItem = prop (PropName "selectableItem")

selected :: forall i. String -> Prop i
selected = prop (PropName "selected")

selectedTabIndicatorColor :: forall i. String -> Prop i
selectedTabIndicatorColor = prop (PropName "selectedTabIndicatorColor")

selectedTabIndicatorHeight :: forall i. String -> Prop i
selectedTabIndicatorHeight = prop (PropName "selectedTabIndicatorHeight")

setDate :: forall i. String -> Prop i
setDate = prop (PropName "setDate")

shadowLayer :: forall i. String -> Prop i
shadowLayer = prop (PropName "shadowLayer")

showDividers :: forall i. String -> Prop i
showDividers = prop (PropName "showDividers")

singleLine :: forall i. String -> Prop i
singleLine = prop (PropName "singleLine")

stroke :: forall i. String -> Prop i
stroke = prop (PropName "stroke")

caretColor :: forall i. String -> Prop i
caretColor = prop (PropName "caretColor")

tabTextColors :: forall i. String -> Prop i
tabTextColors = prop (PropName "tabTextColors")

text :: forall i. String -> Prop i
text = prop (PropName "text")

textAllCaps :: forall i. String -> Prop i
textAllCaps = prop (PropName "textAllCaps")

textFromHtml :: forall i. String -> Prop i
textFromHtml = prop (PropName "textFromHtml")

textIsSelectable :: forall i. String -> Prop i
textIsSelectable = prop (PropName "textIsSelectable")

textSize :: forall i. Int -> Prop i
textSize = prop (PropName "textSize")

translationX :: forall i. String -> Prop i
translationX = prop (PropName "translationX")

translationY :: forall i. String -> Prop i
translationY = prop (PropName "translationY")

translationZ :: forall i. String -> Prop i
translationZ = prop (PropName "translationZ")

toast :: forall i. String -> Prop i
toast = prop (PropName "toast")

typeface :: forall i. String -> Prop i
typeface = prop (PropName "typeface")



url :: forall i. String -> Prop i
url = prop (PropName "url")



values :: forall i. String -> Prop i
values = prop (PropName "values")

visibility :: forall i. String -> Prop i
visibility = prop (PropName "visibility")



weight :: forall i. String -> Prop i
weight = prop (PropName "weight")

width :: forall i. Length -> Prop i
width = prop (PropName "width")

alignParentBottom :: forall i. String -> Prop i
alignParentBottom = prop (PropName "alignParentBottom")

alignParentLeft :: forall i. String -> Prop i
alignParentLeft = prop (PropName "alignParentLeft")
