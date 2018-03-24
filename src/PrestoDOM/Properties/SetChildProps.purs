module PrestoDOM.Properties.SetChildProps
    ( override_c
    , root_c

    , a_duration_c
    , a_scaleX_c
    , a_scaleY_c
    , accessibilityHint_c
    , adjustViewBounds_c
    , alpha_c

    , background_c
    , backgroundColor_c
    , backgroundDrawable_c
    , backgroundTint_c
    , btnBackground_c
    , btnColor_c
    , buttonTint_c

    , checked_c
    , clickable_c
    , clipChildren_c
    , color_c
    , colorFilter_c
    , cornerRadius_c
    , curve_c

    , delay_c
    , dividerDrawable_c
    , duration_c

    , elevation_c

    , fillViewport_c
    , focus_c
    , focusable_c
    , focusOut_c
    , fontFamily_c
    , fontSize_c
    , fontStyle_c
    , foreground_c

    , gravity_c

    , hardware_c
    , height_c
    , hint_c
    , hintColor_c

    , imageUrl_c
    , inputType_c
    , inputTypeI_c

    , layout_gravity_c
    , layoutTransition_c
    , letterSpacing_c
    , lineHeight_c

    , margin_c
    , marginEnd_c
    , marginStart_c
    , maxDate_c
    , maxLines_c
    , maxSeek_c
    , maxWidth_c
    , minDate_c
    , minHeight_c
    , minWidth_c

    , orientation_c

    , padding_c
    , pivotX_c
    , pivotY_c
    , progressColor_c

    , rotation_c
    , rotationX_c
    , rotationY_c

    , scaleType_c
    , scaleX_c
    , scaleY_c
    , scrollBarX_c
    , scrollBarY_c
    , selectable_c
    , selectableItem_c
    , selected_c
    , selectedTabIndicatorColor_c
    , selectedTabIndicatorHeight_c
    , setDate_c
    , shadowLayer_c
    , showDividers_c
    , singleLine_c
    , stroke_c

    , tabTextColors_c
    , text_c
    , textAllCaps_c
    , textFromHtml_c
    , textIsSelectable_c
    , textSize_c
    , translationX_c
    , translationY_c
    , translationZ_c
    , toast_c
    , typeface_c

    , url_c

    , values_c
    , visibility_c

    , weight_c
    , width_c
    ) where


import Prelude

import Data.Tuple (Tuple(..))
import PrestoDOM.Types.Core (Length, GenProp(..))


override_c :: String -> String -> Tuple String GenProp
override_c key = Tuple key <<< TextP


root_c :: Boolean -> Tuple String GenProp
root_c = Tuple "root" <<< BooleanP


a_duration_c :: String -> Tuple String GenProp
a_duration_c = Tuple "a_duration" <<< StringP

a_scaleX_c :: String -> Tuple String GenProp
a_scaleX_c = Tuple "a_scaleX" <<< StringP

a_scaleY_c :: String -> Tuple String GenProp
a_scaleY_c = Tuple "a_scaleY" <<< StringP

accessibilityHint_c :: String -> Tuple String GenProp
accessibilityHint_c = Tuple "accessibilityHint" <<< StringP

adjustViewBounds_c :: String -> Tuple String GenProp
adjustViewBounds_c = Tuple "adjustViewBounds" <<< StringP

alpha_c :: String -> Tuple String GenProp
alpha_c = Tuple "alpha" <<< StringP



background_c :: String -> Tuple String GenProp
background_c = Tuple "background" <<< StringP

backgroundColor_c :: String -> Tuple String GenProp
backgroundColor_c = Tuple "backgroundColor" <<< StringP

backgroundDrawable_c :: String -> Tuple String GenProp
backgroundDrawable_c = Tuple "backgroundDrawable" <<< StringP

backgroundTint_c :: String -> Tuple String GenProp
backgroundTint_c = Tuple "backgroundTint" <<< StringP

btnBackground_c :: String -> Tuple String GenProp
btnBackground_c = Tuple "btnBackground" <<< StringP

btnColor_c :: String -> Tuple String GenProp
btnColor_c = Tuple "btnColor" <<< StringP

buttonTint_c :: String -> Tuple String GenProp
buttonTint_c = Tuple "buttonTint" <<< StringP



checked_c :: String -> Tuple String GenProp
checked_c = Tuple "checked" <<< StringP

clickable_c :: String -> Tuple String GenProp
clickable_c = Tuple "clickable" <<< StringP

clipChildren_c :: String -> Tuple String GenProp
clipChildren_c = Tuple "clipChildren" <<< StringP

color_c :: String -> Tuple String GenProp
color_c = Tuple "color" <<< StringP

colorFilter_c :: String -> Tuple String GenProp
colorFilter_c = Tuple "colorFilter" <<< StringP

cornerRadius_c :: String -> Tuple String GenProp
cornerRadius_c = Tuple "cornerRadius" <<< StringP

curve_c :: String -> Tuple String GenProp
curve_c = Tuple "curve" <<< StringP



delay_c :: String -> Tuple String GenProp
delay_c = Tuple "delay" <<< StringP

dividerDrawable_c :: String -> Tuple String GenProp
dividerDrawable_c = Tuple "dividerDrawable" <<< StringP

duration_c :: String -> Tuple String GenProp
duration_c = Tuple "duration" <<< StringP



elevation_c :: String -> Tuple String GenProp
elevation_c = Tuple "elevation" <<< StringP



fillViewport_c :: String -> Tuple String GenProp
fillViewport_c = Tuple "fillViewport" <<< StringP

focus_c :: String -> Tuple String GenProp
focus_c = Tuple "focus" <<< StringP

focusable_c :: String -> Tuple String GenProp
focusable_c = Tuple "focusable" <<< StringP

focusOut_c :: String -> Tuple String GenProp
focusOut_c = Tuple "focusOut" <<< StringP

fontFamily_c :: String -> Tuple String GenProp
fontFamily_c = Tuple "fontFamily" <<< StringP

fontSize_c :: Int -> Tuple String GenProp
fontSize_c = Tuple "fontSize" <<< IntP

fontStyle_c :: String -> Tuple String GenProp
fontStyle_c = Tuple "fontStyle" <<< StringP

foreground_c :: String -> Tuple String GenProp
foreground_c = Tuple "foreground" <<< StringP



gravity_c :: String -> Tuple String GenProp
gravity_c = Tuple "gravity" <<< StringP



hardware_c :: String -> Tuple String GenProp
hardware_c = Tuple "hardware" <<< StringP

height_c :: Length -> Tuple String GenProp
height_c = Tuple "height" <<< LengthP

hint_c :: String -> Tuple String GenProp
hint_c = Tuple "hint" <<< StringP

hintColor_c :: String -> Tuple String GenProp
hintColor_c = Tuple "hintColor" <<< StringP



imageUrl_c :: String -> Tuple String GenProp
imageUrl_c = Tuple "imageUrl" <<< StringP

inputType_c :: String -> Tuple String GenProp
inputType_c = Tuple "inputType" <<< StringP

inputTypeI_c :: String -> Tuple String GenProp
inputTypeI_c = Tuple "inputTypeI" <<< StringP



layout_gravity_c :: String -> Tuple String GenProp
layout_gravity_c = Tuple "layout_gravity" <<< StringP

layoutTransition_c :: String -> Tuple String GenProp
layoutTransition_c = Tuple "layoutTransition" <<< StringP

letterSpacing_c :: String -> Tuple String GenProp
letterSpacing_c = Tuple "letterSpacing" <<< StringP

lineHeight_c :: String -> Tuple String GenProp
lineHeight_c = Tuple "lineHeight" <<< StringP



margin_c :: String -> Tuple String GenProp
margin_c = Tuple "margin" <<< StringP

marginEnd_c :: String -> Tuple String GenProp
marginEnd_c = Tuple "marginEnd" <<< StringP

marginStart_c :: String -> Tuple String GenProp
marginStart_c = Tuple "marginStart" <<< StringP

maxDate_c :: String -> Tuple String GenProp
maxDate_c = Tuple "maxDate" <<< StringP

maxLines_c :: String -> Tuple String GenProp
maxLines_c = Tuple "maxLines" <<< StringP

maxSeek_c :: String -> Tuple String GenProp
maxSeek_c = Tuple "maxSeek" <<< StringP

maxWidth_c :: String -> Tuple String GenProp
maxWidth_c = Tuple "maxWidth" <<< StringP

minDate_c :: String -> Tuple String GenProp
minDate_c = Tuple "minDate" <<< StringP

minHeight_c :: String -> Tuple String GenProp
minHeight_c = Tuple "minHeight" <<< StringP

minWidth_c :: String -> Tuple String GenProp
minWidth_c = Tuple "minWidth" <<< StringP



orientation_c :: String -> Tuple String GenProp
orientation_c = Tuple "orientation" <<< StringP



padding_c :: String -> Tuple String GenProp
padding_c = Tuple "padding" <<< StringP

pivotX_c :: String -> Tuple String GenProp
pivotX_c = Tuple "pivotX" <<< StringP

pivotY_c :: String -> Tuple String GenProp
pivotY_c = Tuple "pivotY" <<< StringP

progressColor_c :: String -> Tuple String GenProp
progressColor_c = Tuple "progressColor" <<< StringP



rotation_c :: String -> Tuple String GenProp
rotation_c = Tuple "rotation" <<< StringP

rotationX_c :: String -> Tuple String GenProp
rotationX_c = Tuple "rotationX" <<< StringP

rotationY_c :: String -> Tuple String GenProp
rotationY_c = Tuple "rotationY" <<< StringP



scaleType_c :: String -> Tuple String GenProp
scaleType_c = Tuple "scaleType" <<< StringP

scaleX_c :: String -> Tuple String GenProp
scaleX_c = Tuple "scaleX" <<< StringP

scaleY_c :: String -> Tuple String GenProp
scaleY_c = Tuple "scaleY" <<< StringP

scrollBarX_c :: String -> Tuple String GenProp
scrollBarX_c = Tuple "scrollBarX" <<< StringP

scrollBarY_c :: String -> Tuple String GenProp
scrollBarY_c = Tuple "scrollBarY" <<< StringP

selectable_c :: String -> Tuple String GenProp
selectable_c = Tuple "selectable" <<< StringP

selectableItem_c :: String -> Tuple String GenProp
selectableItem_c = Tuple "selectableItem" <<< StringP

selected_c :: String -> Tuple String GenProp
selected_c = Tuple "selected" <<< StringP

selectedTabIndicatorColor_c :: String -> Tuple String GenProp
selectedTabIndicatorColor_c = Tuple "selectedTabIndicatorColor" <<< StringP

selectedTabIndicatorHeight_c :: String -> Tuple String GenProp
selectedTabIndicatorHeight_c = Tuple "selectedTabIndicatorHeight" <<< StringP

setDate_c :: String -> Tuple String GenProp
setDate_c = Tuple "setDate" <<< StringP

shadowLayer_c :: String -> Tuple String GenProp
shadowLayer_c = Tuple "shadowLayer" <<< StringP

showDividers_c :: String -> Tuple String GenProp
showDividers_c = Tuple "showDividers" <<< StringP

singleLine_c :: String -> Tuple String GenProp
singleLine_c = Tuple "singleLine" <<< StringP

stroke_c :: String -> Tuple String GenProp
stroke_c = Tuple "stroke" <<< StringP



tabTextColors_c :: String -> Tuple String GenProp
tabTextColors_c = Tuple "tabTextColors" <<< StringP

text_c :: String -> Tuple String GenProp
text_c = Tuple "text" <<< StringP

textAllCaps_c :: String -> Tuple String GenProp
textAllCaps_c = Tuple "textAllCaps" <<< StringP

textFromHtml_c :: String -> Tuple String GenProp
textFromHtml_c = Tuple "textFromHtml" <<< StringP

textIsSelectable_c :: String -> Tuple String GenProp
textIsSelectable_c = Tuple "textIsSelectable" <<< StringP

textSize_c :: Int -> Tuple String GenProp
textSize_c = Tuple "textSize" <<< IntP

translationX_c :: String -> Tuple String GenProp
translationX_c = Tuple "translationX" <<< StringP

translationY_c :: String -> Tuple String GenProp
translationY_c = Tuple "translationY" <<< StringP

translationZ_c :: String -> Tuple String GenProp
translationZ_c = Tuple "translationZ" <<< StringP

toast_c :: String -> Tuple String GenProp
toast_c = Tuple "toast" <<< StringP

typeface_c :: String -> Tuple String GenProp
typeface_c = Tuple "typeface" <<< StringP



url_c :: String -> Tuple String GenProp
url_c = Tuple "url" <<< StringP



values_c :: String -> Tuple String GenProp
values_c = Tuple "values" <<< StringP

visibility_c :: String -> Tuple String GenProp
visibility_c = Tuple "visibility" <<< StringP



weight_c :: String -> Tuple String GenProp
weight_c = Tuple "weight" <<< StringP

width_c :: Length -> Tuple String GenProp
width_c = Tuple "width" <<< LengthP
