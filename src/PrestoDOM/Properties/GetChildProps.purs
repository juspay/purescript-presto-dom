module PrestoDOM.Properties.GetChildProps
    ( override_
    , root_

    , a_duration_
    , a_scaleX_
    , a_scaleY_
    , accessibilityHint_
    , adjustViewBounds_
    , alpha_

    , background_
    , backgroundColor_
    , backgroundDrawable_
    , backgroundTint_
    , btnBackground_
    , btnColor_
    , buttonTint_

    , checked_
    , clickable_
    , clipChildren_
    , color_
    , colorFilter_
    , cornerRadius_
    , curve_

    , delay_
    , dividerDrawable_
    , duration_

    , elevation_

    , fillViewport_
    , focus_
    , focusable_
    , focusOut_
    , fontFamily_
    , fontSize_
    , fontStyle_
    , foreground_

    , gravity_

    , hardware_
    , height_
    , hint_
    , hintColor_

    , imageUrl_
    , inputType_
    , inputTypeI_

    , layout_gravity_
    , layoutTransition_
    , letterSpacing_
    , lineHeight_

    , margin_
    , marginEnd_
    , marginStart_
    , maxDate_
    , maxLines_
    , maxSeek_
    , maxWidth_
    , minDate_
    , minHeight_
    , minWidth_

    , orientation_

    , padding_
    , pivotX_
    , pivotY_
    , progressColor_

    , rotation_
    , rotationX_
    , rotationY_

    , scaleType_
    , scaleX_
    , scaleY_
    , scrollBarX_
    , scrollBarY_
    , selectable_
    , selectableItem_
    , selected_
    , selectedTabIndicatorColor_
    , selectedTabIndicatorHeight_
    , setDate_
    , shadowLayer_
    , showDividers_
    , singleLine_
    , stroke_

    , tabTextColors_
    , text_
    , textAllCaps_
    , textFromHtml_
    , textIsSelectable_
    , textSize_
    , translationX_
    , translationY_
    , translationZ_
    , toast_
    , typeface_

    , url_

    , values_
    , visibility_

    , weight_
    , width_
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


override_ :: forall i. String -> String -> StrMap GenProp -> Prop i
override_ = fromGenProp

root_ :: forall i. Boolean -> StrMap GenProp -> Prop i
root_ = fromGenProp "root"


a_duration_ :: forall i. String -> StrMap GenProp -> Prop i
a_duration_ = fromGenProp "a_duration"

a_scaleX_ :: forall i. String -> StrMap GenProp -> Prop i
a_scaleX_ = fromGenProp "a_scaleX"

a_scaleY_ :: forall i. String -> StrMap GenProp -> Prop i
a_scaleY_ = fromGenProp "a_scaleY"

accessibilityHint_ :: forall i. String -> StrMap GenProp -> Prop i
accessibilityHint_ = fromGenProp "accessibilityHint"

adjustViewBounds_ :: forall i. String -> StrMap GenProp -> Prop i
adjustViewBounds_ = fromGenProp "adjustViewBounds"

alpha_ :: forall i. String -> StrMap GenProp -> Prop i
alpha_ = fromGenProp "alpha"



background_ :: forall i. String -> StrMap GenProp -> Prop i
background_ = fromGenProp "background"

backgroundColor_ :: forall i. String -> StrMap GenProp -> Prop i
backgroundColor_ = fromGenProp "backgroundColor"

backgroundDrawable_ :: forall i. String -> StrMap GenProp -> Prop i
backgroundDrawable_ = fromGenProp "backgroundDrawable"

backgroundTint_ :: forall i. String -> StrMap GenProp -> Prop i
backgroundTint_ = fromGenProp "backgroundTint"

btnBackground_ :: forall i. String -> StrMap GenProp -> Prop i
btnBackground_ = fromGenProp "btnBackground"

btnColor_ :: forall i. String -> StrMap GenProp -> Prop i
btnColor_ = fromGenProp "btnColor"

buttonTint_ :: forall i. String -> StrMap GenProp -> Prop i
buttonTint_ = fromGenProp "buttonTint"



checked_ :: forall i. String -> StrMap GenProp -> Prop i
checked_ = fromGenProp "checked"

clickable_ :: forall i. String -> StrMap GenProp -> Prop i
clickable_ = fromGenProp "clickable"

clipChildren_ :: forall i. String -> StrMap GenProp -> Prop i
clipChildren_ = fromGenProp "clipChildren"

color_ :: forall i. String -> StrMap GenProp -> Prop i
color_ = fromGenProp "color"

colorFilter_ :: forall i. String -> StrMap GenProp -> Prop i
colorFilter_ = fromGenProp "colorFilter"

cornerRadius_ :: forall i. String -> StrMap GenProp -> Prop i
cornerRadius_ = fromGenProp "cornerRadius"

curve_ :: forall i. String -> StrMap GenProp -> Prop i
curve_ = fromGenProp "curve"



delay_ :: forall i. String -> StrMap GenProp -> Prop i
delay_ = fromGenProp "delay"

dividerDrawable_ :: forall i. String -> StrMap GenProp -> Prop i
dividerDrawable_ = fromGenProp "dividerDrawable"

duration_ :: forall i. String -> StrMap GenProp -> Prop i
duration_ = fromGenProp "duration"



elevation_ :: forall i. String -> StrMap GenProp -> Prop i
elevation_ = fromGenProp "elevation"



fillViewport_ :: forall i. String -> StrMap GenProp -> Prop i
fillViewport_ = fromGenProp "fillViewport"

focus_ :: forall i. String -> StrMap GenProp -> Prop i
focus_ = fromGenProp "focus"

focusable_ :: forall i. String -> StrMap GenProp -> Prop i
focusable_ = fromGenProp "focusable"

focusOut_ :: forall i. String -> StrMap GenProp -> Prop i
focusOut_ = fromGenProp "focusOut"

fontFamily_ :: forall i. String -> StrMap GenProp -> Prop i
fontFamily_ = fromGenProp "fontFamily"

fontSize_ :: forall i. Int -> StrMap GenProp -> Prop i
fontSize_ = fromGenProp "fontSize"

fontStyle_ :: forall i. String -> StrMap GenProp -> Prop i
fontStyle_ = fromGenProp "fontStyle"

foreground_ :: forall i. String -> StrMap GenProp -> Prop i
foreground_ = fromGenProp "foreground"



gravity_ :: forall i. String -> StrMap GenProp -> Prop i
gravity_ = fromGenProp "gravity"



hardware_ :: forall i. String -> StrMap GenProp -> Prop i
hardware_ = fromGenProp "hardware"

height_ :: forall i. Length -> StrMap GenProp -> Prop i
height_ = fromGenProp "height"

hint_ :: forall i. String -> StrMap GenProp -> Prop i
hint_ = fromGenProp "hint"

hintColor_ :: forall i. String -> StrMap GenProp -> Prop i
hintColor_ = fromGenProp "hintColor"



imageUrl_ :: forall i. String -> StrMap GenProp -> Prop i
imageUrl_ = fromGenProp "imageUrl"

inputType_ :: forall i. String -> StrMap GenProp -> Prop i
inputType_ = fromGenProp "inputType"

inputTypeI_ :: forall i. String -> StrMap GenProp -> Prop i
inputTypeI_ = fromGenProp "inputTypeI"



layout_gravity_ :: forall i. String -> StrMap GenProp -> Prop i
layout_gravity_ = fromGenProp "layout_gravity"

layoutTransition_ :: forall i. String -> StrMap GenProp -> Prop i
layoutTransition_ = fromGenProp "layoutTransition"

letterSpacing_ :: forall i. String -> StrMap GenProp -> Prop i
letterSpacing_ = fromGenProp "letterSpacing"

lineHeight_ :: forall i. String -> StrMap GenProp -> Prop i
lineHeight_ = fromGenProp "lineHeight"



margin_ :: forall i. String -> StrMap GenProp -> Prop i
margin_ = fromGenProp "margin"

marginEnd_ :: forall i. String -> StrMap GenProp -> Prop i
marginEnd_ = fromGenProp "marginEnd"

marginStart_ :: forall i. String -> StrMap GenProp -> Prop i
marginStart_ = fromGenProp "marginStart"

maxDate_ :: forall i. String -> StrMap GenProp -> Prop i
maxDate_ = fromGenProp "maxDate"

maxLines_ :: forall i. String -> StrMap GenProp -> Prop i
maxLines_ = fromGenProp "maxLines"

maxSeek_ :: forall i. String -> StrMap GenProp -> Prop i
maxSeek_ = fromGenProp "maxSeek"

maxWidth_ :: forall i. String -> StrMap GenProp -> Prop i
maxWidth_ = fromGenProp "maxWidth"

minDate_ :: forall i. String -> StrMap GenProp -> Prop i
minDate_ = fromGenProp "minDate"

minHeight_ :: forall i. String -> StrMap GenProp -> Prop i
minHeight_ = fromGenProp "minHeight"

minWidth_ :: forall i. String -> StrMap GenProp -> Prop i
minWidth_ = fromGenProp "minWidth"



orientation_ :: forall i. String -> StrMap GenProp -> Prop i
orientation_ = fromGenProp "orientation"



padding_ :: forall i. String -> StrMap GenProp -> Prop i
padding_ = fromGenProp "padding"

pivotX_ :: forall i. String -> StrMap GenProp -> Prop i
pivotX_ = fromGenProp "pivotX"

pivotY_ :: forall i. String -> StrMap GenProp -> Prop i
pivotY_ = fromGenProp "pivotY"

progressColor_ :: forall i. String -> StrMap GenProp -> Prop i
progressColor_ = fromGenProp "progressColor"



rotation_ :: forall i. String -> StrMap GenProp -> Prop i
rotation_ = fromGenProp "rotation"

rotationX_ :: forall i. String -> StrMap GenProp -> Prop i
rotationX_ = fromGenProp "rotationX"

rotationY_ :: forall i. String -> StrMap GenProp -> Prop i
rotationY_ = fromGenProp "rotationY"



scaleType_ :: forall i. String -> StrMap GenProp -> Prop i
scaleType_ = fromGenProp "scaleType"

scaleX_ :: forall i. String -> StrMap GenProp -> Prop i
scaleX_ = fromGenProp "scaleX"

scaleY_ :: forall i. String -> StrMap GenProp -> Prop i
scaleY_ = fromGenProp "scaleY"

scrollBarX_ :: forall i. String -> StrMap GenProp -> Prop i
scrollBarX_ = fromGenProp "scrollBarX"

scrollBarY_ :: forall i. String -> StrMap GenProp -> Prop i
scrollBarY_ = fromGenProp "scrollBarY"

selectable_ :: forall i. String -> StrMap GenProp -> Prop i
selectable_ = fromGenProp "selectable"

selectableItem_ :: forall i. String -> StrMap GenProp -> Prop i
selectableItem_ = fromGenProp "selectableItem"

selected_ :: forall i. String -> StrMap GenProp -> Prop i
selected_ = fromGenProp "selected"

selectedTabIndicatorColor_ :: forall i. String -> StrMap GenProp -> Prop i
selectedTabIndicatorColor_ = fromGenProp "selectedTabIndicatorColor"

selectedTabIndicatorHeight_ :: forall i. String -> StrMap GenProp -> Prop i
selectedTabIndicatorHeight_ = fromGenProp "selectedTabIndicatorHeight"

setDate_ :: forall i. String -> StrMap GenProp -> Prop i
setDate_ = fromGenProp "setDate"

shadowLayer_ :: forall i. String -> StrMap GenProp -> Prop i
shadowLayer_ = fromGenProp "shadowLayer"

showDividers_ :: forall i. String -> StrMap GenProp -> Prop i
showDividers_ = fromGenProp "showDividers"

singleLine_ :: forall i. String -> StrMap GenProp -> Prop i
singleLine_ = fromGenProp "singleLine"

stroke_ :: forall i. String -> StrMap GenProp -> Prop i
stroke_ = fromGenProp "stroke"



tabTextColors_ :: forall i. String -> StrMap GenProp -> Prop i
tabTextColors_ = fromGenProp "tabTextColors"

text_ :: forall i. String -> StrMap GenProp -> Prop i
text_ = fromGenProp "text"

textAllCaps_ :: forall i. String -> StrMap GenProp -> Prop i
textAllCaps_ = fromGenProp "textAllCaps"

textFromHtml_ :: forall i. String -> StrMap GenProp -> Prop i
textFromHtml_ = fromGenProp "textFromHtml"

textIsSelectable_ :: forall i. String -> StrMap GenProp -> Prop i
textIsSelectable_ = fromGenProp "textIsSelectable"

textSize_ :: forall i. Int -> StrMap GenProp -> Prop i
textSize_ = fromGenProp "textSize"

translationX_ :: forall i. String -> StrMap GenProp -> Prop i
translationX_ = fromGenProp "translationX"

translationY_ :: forall i. String -> StrMap GenProp -> Prop i
translationY_ = fromGenProp "translationY"

translationZ_ :: forall i. String -> StrMap GenProp -> Prop i
translationZ_ = fromGenProp "translationZ"

toast_ :: forall i. String -> StrMap GenProp -> Prop i
toast_ = fromGenProp "toast"

typeface_ :: forall i. String -> StrMap GenProp -> Prop i
typeface_ = fromGenProp "typeface"



url_ :: forall i. String -> StrMap GenProp -> Prop i
url_ = fromGenProp "url"



values_ :: forall i. String -> StrMap GenProp -> Prop i
values_ = fromGenProp "values"

visibility_ :: forall i. String -> StrMap GenProp -> Prop i
visibility_ = fromGenProp "visibility"



weight_ :: forall i. String -> StrMap GenProp -> Prop i
weight_ = fromGenProp "weight"

width_ :: forall i. Length -> StrMap GenProp -> Prop i
width_ = fromGenProp "width"
