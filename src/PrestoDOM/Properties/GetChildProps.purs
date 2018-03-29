module PrestoDOM.Properties.GetChildProps
    ( override_p
    , root_p

    , a_duration_p
    , a_scaleX_p
    , a_scaleY_p
    , accessibilityHint_p
    , adjustViewBounds_p
    , alpha_p

    , background_p
    , backgroundColor_p
    , backgroundDrawable_p
    , backgroundTint_p
    , btnBackground_p
    , btnColor_p
    , buttonTint_p

    , checked_p
    , clickable_p
    , clipChildren_p
    , color_p
    , colorFilter_p
    , cornerRadius_p
    , curve_p

    , delay_p
    , dividerDrawable_p
    , duration_p

    , elevation_p

    , fillViewport_p
    , focus_p
    , focusable_p
    , focusOut_p
    , fontFamily_p
    , fontSize_p
    , fontStyle_p
    , foreground_p

    , gravity_p

    , hardware_p
    , height_p
    , hint_p
    , hintColor_p

    , imageUrl_p
    , inputType_p
    , inputTypeI_p

    , layout_gravity_p
    , layoutTransition_p
    , letterSpacing_p
    , lineHeight_p

    , margin_p
    , marginEnd_p
    , marginStart_p
    , maxDate_p
    , maxLines_p
    , maxSeek_p
    , maxWidth_p
    , minDate_p
    , minHeight_p
    , minWidth_p

    , orientation_p

    , padding_p
    , pivotX_p
    , pivotY_p
    , progressColor_p

    , rotation_p
    , rotationX_p
    , rotationY_p

    , scaleType_p
    , scaleX_p
    , scaleY_p
    , scrollBarX_p
    , scrollBarY_p
    , selectable_p
    , selectableItem_p
    , selected_p
    , selectedTabIndicatorColor_p
    , selectedTabIndicatorHeight_p
    , setDate_p
    , shadowLayer_p
    , showDividers_p
    , singleLine_p
    , stroke_p

    , tabTextColors_p
    , text_p
    , textAllCaps_p
    , textFromHtml_p
    , textIsSelectable_p
    , textSize_p
    , translationX_p
    , translationY_p
    , translationZ_p
    , toast_p
    , typeface_p

    , url_p

    , values_p
    , visibility_p

    , weight_p
    , width_p
    ) where

import Prelude

-- import Data.Tuple (Tuple(..))
import Data.Maybe (Maybe(..))
import Data.StrMap (StrMap, lookup)

import Halogen.VDom.DOM.Prop (Prop(..))
import PrestoDOM.Types.Core (class IsProp, Length, toPropValue, GenProp(..))

fromGenProp :: forall a i. IsProp a => String -> a -> StrMap GenProp -> Prop i
fromGenProp key default strMap = let value = lookup key strMap
                          in case value of
                                  Just (LengthP v) -> Property key $ toPropValue v
                                  Just (BooleanP v) -> Property key $ toPropValue v
                                  Just (IntP v) -> Property key $ toPropValue v
                                  Just (StringP v) -> Property key $ toPropValue v
                                  Just (TextP v) -> Property "text" $ toPropValue v
                                  Nothing -> Property key $ toPropValue default


override_p :: forall i. String -> String -> StrMap GenProp -> Prop i
override_p = fromGenProp

root_p :: forall i. Boolean -> StrMap GenProp -> Prop i
root_p = fromGenProp "root"


a_duration_p :: forall i. String -> StrMap GenProp -> Prop i
a_duration_p = fromGenProp "a_duration"

a_scaleX_p :: forall i. String -> StrMap GenProp -> Prop i
a_scaleX_p = fromGenProp "a_scaleX"

a_scaleY_p :: forall i. String -> StrMap GenProp -> Prop i
a_scaleY_p = fromGenProp "a_scaleY"

accessibilityHint_p :: forall i. String -> StrMap GenProp -> Prop i
accessibilityHint_p = fromGenProp "accessibilityHint"

adjustViewBounds_p :: forall i. String -> StrMap GenProp -> Prop i
adjustViewBounds_p = fromGenProp "adjustViewBounds"

alpha_p :: forall i. String -> StrMap GenProp -> Prop i
alpha_p = fromGenProp "alpha"



background_p :: forall i. String -> StrMap GenProp -> Prop i
background_p = fromGenProp "background"

backgroundColor_p :: forall i. String -> StrMap GenProp -> Prop i
backgroundColor_p = fromGenProp "backgroundColor"

backgroundDrawable_p :: forall i. String -> StrMap GenProp -> Prop i
backgroundDrawable_p = fromGenProp "backgroundDrawable"

backgroundTint_p :: forall i. String -> StrMap GenProp -> Prop i
backgroundTint_p = fromGenProp "backgroundTint"

btnBackground_p :: forall i. String -> StrMap GenProp -> Prop i
btnBackground_p = fromGenProp "btnBackground"

btnColor_p :: forall i. String -> StrMap GenProp -> Prop i
btnColor_p = fromGenProp "btnColor"

buttonTint_p :: forall i. String -> StrMap GenProp -> Prop i
buttonTint_p = fromGenProp "buttonTint"



checked_p :: forall i. String -> StrMap GenProp -> Prop i
checked_p = fromGenProp "checked"

clickable_p :: forall i. String -> StrMap GenProp -> Prop i
clickable_p = fromGenProp "clickable"

clipChildren_p :: forall i. String -> StrMap GenProp -> Prop i
clipChildren_p = fromGenProp "clipChildren"

color_p :: forall i. String -> StrMap GenProp -> Prop i
color_p = fromGenProp "color"

colorFilter_p :: forall i. String -> StrMap GenProp -> Prop i
colorFilter_p = fromGenProp "colorFilter"

cornerRadius_p :: forall i. String -> StrMap GenProp -> Prop i
cornerRadius_p = fromGenProp "cornerRadius"

curve_p :: forall i. String -> StrMap GenProp -> Prop i
curve_p = fromGenProp "curve"



delay_p :: forall i. String -> StrMap GenProp -> Prop i
delay_p = fromGenProp "delay"

dividerDrawable_p :: forall i. String -> StrMap GenProp -> Prop i
dividerDrawable_p = fromGenProp "dividerDrawable"

duration_p :: forall i. String -> StrMap GenProp -> Prop i
duration_p = fromGenProp "duration"



elevation_p :: forall i. String -> StrMap GenProp -> Prop i
elevation_p = fromGenProp "elevation"



fillViewport_p :: forall i. String -> StrMap GenProp -> Prop i
fillViewport_p = fromGenProp "fillViewport"

focus_p :: forall i. String -> StrMap GenProp -> Prop i
focus_p = fromGenProp "focus"

focusable_p :: forall i. String -> StrMap GenProp -> Prop i
focusable_p = fromGenProp "focusable"

focusOut_p :: forall i. String -> StrMap GenProp -> Prop i
focusOut_p = fromGenProp "focusOut"

fontFamily_p :: forall i. String -> StrMap GenProp -> Prop i
fontFamily_p = fromGenProp "fontFamily"

fontSize_p :: forall i. Int -> StrMap GenProp -> Prop i
fontSize_p = fromGenProp "fontSize"

fontStyle_p :: forall i. String -> StrMap GenProp -> Prop i
fontStyle_p = fromGenProp "fontStyle"

foreground_p :: forall i. String -> StrMap GenProp -> Prop i
foreground_p = fromGenProp "foreground"



gravity_p :: forall i. String -> StrMap GenProp -> Prop i
gravity_p = fromGenProp "gravity"



hardware_p :: forall i. String -> StrMap GenProp -> Prop i
hardware_p = fromGenProp "hardware"

height_p :: forall i. Length -> StrMap GenProp -> Prop i
height_p = fromGenProp "height"

hint_p :: forall i. String -> StrMap GenProp -> Prop i
hint_p = fromGenProp "hint"

hintColor_p :: forall i. String -> StrMap GenProp -> Prop i
hintColor_p = fromGenProp "hintColor"



imageUrl_p :: forall i. String -> StrMap GenProp -> Prop i
imageUrl_p = fromGenProp "imageUrl"

inputType_p :: forall i. String -> StrMap GenProp -> Prop i
inputType_p = fromGenProp "inputType"

inputTypeI_p :: forall i. String -> StrMap GenProp -> Prop i
inputTypeI_p = fromGenProp "inputTypeI"



layout_gravity_p :: forall i. String -> StrMap GenProp -> Prop i
layout_gravity_p = fromGenProp "layout_gravity"

layoutTransition_p :: forall i. String -> StrMap GenProp -> Prop i
layoutTransition_p = fromGenProp "layoutTransition"

letterSpacing_p :: forall i. String -> StrMap GenProp -> Prop i
letterSpacing_p = fromGenProp "letterSpacing"

lineHeight_p :: forall i. String -> StrMap GenProp -> Prop i
lineHeight_p = fromGenProp "lineHeight"



margin_p :: forall i. String -> StrMap GenProp -> Prop i
margin_p = fromGenProp "margin"

marginEnd_p :: forall i. String -> StrMap GenProp -> Prop i
marginEnd_p = fromGenProp "marginEnd"

marginStart_p :: forall i. String -> StrMap GenProp -> Prop i
marginStart_p = fromGenProp "marginStart"

maxDate_p :: forall i. String -> StrMap GenProp -> Prop i
maxDate_p = fromGenProp "maxDate"

maxLines_p :: forall i. String -> StrMap GenProp -> Prop i
maxLines_p = fromGenProp "maxLines"

maxSeek_p :: forall i. String -> StrMap GenProp -> Prop i
maxSeek_p = fromGenProp "maxSeek"

maxWidth_p :: forall i. String -> StrMap GenProp -> Prop i
maxWidth_p = fromGenProp "maxWidth"

minDate_p :: forall i. String -> StrMap GenProp -> Prop i
minDate_p = fromGenProp "minDate"

minHeight_p :: forall i. String -> StrMap GenProp -> Prop i
minHeight_p = fromGenProp "minHeight"

minWidth_p :: forall i. String -> StrMap GenProp -> Prop i
minWidth_p = fromGenProp "minWidth"



orientation_p :: forall i. String -> StrMap GenProp -> Prop i
orientation_p = fromGenProp "orientation"



padding_p :: forall i. String -> StrMap GenProp -> Prop i
padding_p = fromGenProp "padding"

pivotX_p :: forall i. String -> StrMap GenProp -> Prop i
pivotX_p = fromGenProp "pivotX"

pivotY_p :: forall i. String -> StrMap GenProp -> Prop i
pivotY_p = fromGenProp "pivotY"

progressColor_p :: forall i. String -> StrMap GenProp -> Prop i
progressColor_p = fromGenProp "progressColor"



rotation_p :: forall i. String -> StrMap GenProp -> Prop i
rotation_p = fromGenProp "rotation"

rotationX_p :: forall i. String -> StrMap GenProp -> Prop i
rotationX_p = fromGenProp "rotationX"

rotationY_p :: forall i. String -> StrMap GenProp -> Prop i
rotationY_p = fromGenProp "rotationY"



scaleType_p :: forall i. String -> StrMap GenProp -> Prop i
scaleType_p = fromGenProp "scaleType"

scaleX_p :: forall i. String -> StrMap GenProp -> Prop i
scaleX_p = fromGenProp "scaleX"

scaleY_p :: forall i. String -> StrMap GenProp -> Prop i
scaleY_p = fromGenProp "scaleY"

scrollBarX_p :: forall i. String -> StrMap GenProp -> Prop i
scrollBarX_p = fromGenProp "scrollBarX"

scrollBarY_p :: forall i. String -> StrMap GenProp -> Prop i
scrollBarY_p = fromGenProp "scrollBarY"

selectable_p :: forall i. String -> StrMap GenProp -> Prop i
selectable_p = fromGenProp "selectable"

selectableItem_p :: forall i. String -> StrMap GenProp -> Prop i
selectableItem_p = fromGenProp "selectableItem"

selected_p :: forall i. String -> StrMap GenProp -> Prop i
selected_p = fromGenProp "selected"

selectedTabIndicatorColor_p :: forall i. String -> StrMap GenProp -> Prop i
selectedTabIndicatorColor_p = fromGenProp "selectedTabIndicatorColor"

selectedTabIndicatorHeight_p :: forall i. String -> StrMap GenProp -> Prop i
selectedTabIndicatorHeight_p = fromGenProp "selectedTabIndicatorHeight"

setDate_p :: forall i. String -> StrMap GenProp -> Prop i
setDate_p = fromGenProp "setDate"

shadowLayer_p :: forall i. String -> StrMap GenProp -> Prop i
shadowLayer_p = fromGenProp "shadowLayer"

showDividers_p :: forall i. String -> StrMap GenProp -> Prop i
showDividers_p = fromGenProp "showDividers"

singleLine_p :: forall i. String -> StrMap GenProp -> Prop i
singleLine_p = fromGenProp "singleLine"

stroke_p :: forall i. String -> StrMap GenProp -> Prop i
stroke_p = fromGenProp "stroke"



tabTextColors_p :: forall i. String -> StrMap GenProp -> Prop i
tabTextColors_p = fromGenProp "tabTextColors"

text_p :: forall i. String -> StrMap GenProp -> Prop i
text_p = fromGenProp "text"

textAllCaps_p :: forall i. String -> StrMap GenProp -> Prop i
textAllCaps_p = fromGenProp "textAllCaps"

textFromHtml_p :: forall i. String -> StrMap GenProp -> Prop i
textFromHtml_p = fromGenProp "textFromHtml"

textIsSelectable_p :: forall i. String -> StrMap GenProp -> Prop i
textIsSelectable_p = fromGenProp "textIsSelectable"

textSize_p :: forall i. Int -> StrMap GenProp -> Prop i
textSize_p = fromGenProp "textSize"

translationX_p :: forall i. String -> StrMap GenProp -> Prop i
translationX_p = fromGenProp "translationX"

translationY_p :: forall i. String -> StrMap GenProp -> Prop i
translationY_p = fromGenProp "translationY"

translationZ_p :: forall i. String -> StrMap GenProp -> Prop i
translationZ_p = fromGenProp "translationZ"

toast_p :: forall i. String -> StrMap GenProp -> Prop i
toast_p = fromGenProp "toast"

typeface_p :: forall i. String -> StrMap GenProp -> Prop i
typeface_p = fromGenProp "typeface"



url_p :: forall i. String -> StrMap GenProp -> Prop i
url_p = fromGenProp "url"



values_p :: forall i. String -> StrMap GenProp -> Prop i
values_p = fromGenProp "values"

visibility_p :: forall i. String -> StrMap GenProp -> Prop i
visibility_p = fromGenProp "visibility"



weight_p :: forall i. String -> StrMap GenProp -> Prop i
weight_p = fromGenProp "weight"

width_p :: forall i. Length -> StrMap GenProp -> Prop i
width_p = fromGenProp "width"
