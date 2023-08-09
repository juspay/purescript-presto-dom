module PrestoDOM.Properties.GetChildProps
    ( override_p
    , root_p

    , a_duration_p
    , a_scaleX_p
    , a_scaleY_p
    , absolute_p
    , accessibilityHint_p
    , accessibilityImportance_p
    -- , accessibilityFocusable_p
    , adjustViewBounds_p
    , alpha_p

    , background_p
    , backgroundColor_p
    , backgroundDrawable_p
    , backgroundTint_p
    , btnBackground_p
    , btnColor_p
    , buttonTint_p
    , buttonClickOverlay_p

    , checked_p
    , circularLoader_p
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
    , font_p
    , foreground_p
    , fromBottom_p
    , fromLeft_p
    , fromRight_p
    , fromTop_p

    , gravity_p

    , hardware_p
    , height_p
    , hint_p
    , hintColor_p

    , imageUrl_p
    , inputType_p
    , inputTypeI_p

    , layoutGravity_p
    , layoutTransition_p
    , bottomFixed_p
    , autofocus_p
    , letterSpacing_p
    , lineHeight_p

    , margin_p
    , marginEnd_p
    , marginStart_p
    , maxDate_p
    , maxHeight_p
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
    , shadow_p
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

    , alignParentBottom_p
    , alignParentLeft_p
    , nestedScrollView_p
    ) where

import Prelude

-- import Data.Tuple (Tuple(..))
import Data.Maybe (Maybe(..))
import Foreign.Object (Object, lookup)

import Halogen.VDom.DOM.Prop (Prop(..))
import PrestoDOM.Types.Core (class IsProp, Gravity, InputType, Length, Margin, Orientation, Padding, Font, Shadow, Typeface, Visibility, Accessiblity, toPropValue, GenProp(..))

fromGenProp :: forall a i. IsProp a => String -> a -> Object GenProp -> Prop i
fromGenProp key default strMap = let value = lookup key strMap
                          in case value of
                                  Just (LengthP v) -> Property key $ toPropValue v
                                  Just (PositionP v) -> Property key $ toPropValue v
                                  Just (MarginP v) -> Property key $ toPropValue v
                                  Just (PaddingP v) -> Property key $ toPropValue v
                                  Just (InputTypeP v) -> Property key $ toPropValue v
                                  Just (OrientationP v) -> Property key $ toPropValue v
                                  Just (TypefaceP v) -> Property key $ toPropValue v
                                  Just (VisibilityP v) -> Property key $ toPropValue v
                                  Just (GravityP v) -> Property key $ toPropValue v
                                  Just (NumberP v) -> Property key $ toPropValue v
                                  Just (BooleanP v) -> Property key $ toPropValue v
                                  Just (IntP v) -> Property key $ toPropValue v
                                  Just (StringP v) -> Property key $ toPropValue v
                                  Just (ShadowP v) -> Property key $ toPropValue v
                                  Just (TextP v) -> Property "text" $ toPropValue v
                                  Just (CornersP v) -> Property key $ toPropValue v
                                  Just (FontP v) -> Property key $ toPropValue v
                                  Just (AccessiblityP v) -> Property key $ toPropValue v
                                  Nothing -> Property key $ toPropValue default


override_p :: forall i. String -> String -> Object GenProp -> Prop i
override_p = fromGenProp

root_p :: forall i. Boolean -> Object GenProp -> Prop i
root_p = fromGenProp "root"


a_duration_p :: forall i. String -> Object GenProp -> Prop i
a_duration_p = fromGenProp "a_duration"

a_scaleX_p :: forall i. String -> Object GenProp -> Prop i
a_scaleX_p = fromGenProp "a_scaleX"

a_scaleY_p :: forall i. String -> Object GenProp -> Prop i
a_scaleY_p = fromGenProp "a_scaleY"

-- | Boolean
absolute_p :: forall i. Boolean -> Object GenProp -> Prop i
absolute_p = fromGenProp "absolute"

-- | String
accessibilityHint_p :: forall i. String -> Object GenProp -> Prop i
accessibilityHint_p = fromGenProp "accessibilityHint"


-- | Accessiblity
accessibilityImportance_p :: forall i. Accessiblity -> Object GenProp -> Prop i
accessibilityImportance_p = fromGenProp "accessibilityImportance"

-- | Boolean
adjustViewBounds_p :: forall i. Boolean -> Object GenProp -> Prop i
adjustViewBounds_p = fromGenProp "adjustViewBounds"

-- | Number
alpha_p :: forall i. Number -> Object GenProp -> Prop i
alpha_p = fromGenProp "alpha"



-- | String
background_p :: forall i. String -> Object GenProp -> Prop i
background_p = fromGenProp "background"

-- | String
backgroundColor_p :: forall i. String -> Object GenProp -> Prop i
backgroundColor_p = fromGenProp "backgroundColor"

-- | String
backgroundDrawable_p :: forall i. String -> Object GenProp -> Prop i
backgroundDrawable_p = fromGenProp "backgroundDrawable"

-- | String
backgroundTint_p :: forall i. String -> Object GenProp -> Prop i
backgroundTint_p = fromGenProp "backgroundTint"

-- | String
btnBackground_p :: forall i. String -> Object GenProp -> Prop i
btnBackground_p = fromGenProp "btnBackground"

-- | String
btnColor_p :: forall i. String -> Object GenProp -> Prop i
btnColor_p = fromGenProp "btnColor"

-- | String
buttonTint_p :: forall i. String -> Object GenProp -> Prop i
buttonTint_p = fromGenProp "buttonTint"

-- | Number
buttonClickOverlay_p :: forall i. Number -> Object GenProp -> Prop i
buttonClickOverlay_p = fromGenProp "buttonClickOverlay"


-- | Boolean
checked_p :: forall i. Boolean -> Object GenProp -> Prop i
checked_p = fromGenProp "checked"

-- | Boolean
circularLoader_p :: forall i. Boolean -> Object GenProp -> Prop i
circularLoader_p = fromGenProp "circularLoader"

-- | Boolean
clickable_p :: forall i. Boolean -> Object GenProp -> Prop i
clickable_p = fromGenProp "clickable"

-- | Boolean
clipChildren_p :: forall i. Boolean -> Object GenProp -> Prop i
clipChildren_p = fromGenProp "clipChildren"

-- | String
color_p :: forall i. String -> Object GenProp -> Prop i
color_p = fromGenProp "color"

-- | Unknown
colorFilter_p :: forall i. String -> Object GenProp -> Prop i
colorFilter_p = fromGenProp "colorFilter"

-- | Number
cornerRadius_p :: forall i. Number -> Object GenProp -> Prop i
cornerRadius_p = fromGenProp "cornerRadius"

-- curve
-- | String
curve_p :: forall i. String -> Object GenProp -> Prop i
curve_p = fromGenProp "curve"



-- | L, // long
delay_p :: forall i. String -> Object GenProp -> Prop i
delay_p = fromGenProp "delay"

-- | String
dividerDrawable_p :: forall i. String -> Object GenProp -> Prop i
dividerDrawable_p = fromGenProp "dividerDrawable"

-- | L, // long
duration_p :: forall i. String -> Object GenProp -> Prop i
duration_p = fromGenProp "duration"



-- | Int
elevation_p :: forall i. Int -> Object GenProp -> Prop i
elevation_p = fromGenProp "elevation"



-- | Boolean
fillViewport_p :: forall i. Boolean -> Object GenProp -> Prop i
fillViewport_p = fromGenProp "fillViewport"

focus_p :: forall i. String -> Object GenProp -> Prop i
focus_p = fromGenProp "focus"

-- | Boolean
focusable_p :: forall i. Boolean -> Object GenProp -> Prop i
focusable_p = fromGenProp "focusable"

focusOut_p :: forall i. String -> Object GenProp -> Prop i
focusOut_p = fromGenProp "focusOut"

-- | Unknown
fontFamily_p :: forall i. String -> Object GenProp -> Prop i
fontFamily_p = fromGenProp "fontFamily"

-- | Int
fontSize_p :: forall i. Int -> Object GenProp -> Prop i
fontSize_p = fromGenProp "fontSize"

-- | String
fontStyle_p :: forall i. String -> Object GenProp -> Prop i
fontStyle_p = fromGenProp "fontStyle"


-- | Font
font_p :: forall  i. Font -> Object GenProp -> Prop i 
font_p = fromGenProp "font"

-- | Boolean
foreground_p :: forall i. Boolean -> Object GenProp -> Prop i
foreground_p = fromGenProp "foreground"

-- | Number
fromBottom_p :: forall i. Number -> Object GenProp -> Prop i
fromBottom_p = fromGenProp "fromBottom"

-- | Number
fromLeft_p :: forall i. Number -> Object GenProp -> Prop i
fromLeft_p = fromGenProp "fromLeft"

-- | Number
fromRight_p :: forall i. Number -> Object GenProp -> Prop i
fromRight_p = fromGenProp "fromRight"

-- | Number
fromTop_p :: forall i. Number -> Object GenProp -> Prop i
fromTop_p = fromGenProp "fromTop"


-- | Gravity
gravity_p :: forall i. Gravity -> Object GenProp -> Prop i
gravity_p = fromGenProp "gravity"



-- | Unknown
hardware_p :: forall i. String -> Object GenProp -> Prop i
hardware_p = fromGenProp "hardware"

height_p :: forall i. Length -> Object GenProp -> Prop i
height_p = fromGenProp "height"

-- | String
hint_p :: forall i. String -> Object GenProp -> Prop i
hint_p = fromGenProp "hint"

-- | String
hintColor_p :: forall i. String -> Object GenProp -> Prop i
hintColor_p = fromGenProp "hintColor"



-- | String
imageUrl_p :: forall i. String -> Object GenProp -> Prop i
imageUrl_p = fromGenProp "imageUrl"

-- | InputType
inputType_p :: forall i. InputType -> Object GenProp -> Prop i
inputType_p = fromGenProp "inputType"

-- | Int
inputTypeI_p :: forall i. Int -> Object GenProp -> Prop i
inputTypeI_p = fromGenProp "inputTypeI"



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
layoutGravity_p :: forall i. String -> Object GenProp -> Prop i
layoutGravity_p = fromGenProp "layout_gravity"

-- | Boolean
layoutTransition_p :: forall i. Boolean -> Object GenProp -> Prop i
layoutTransition_p = fromGenProp "layoutTransition"

-- | Boolean
autofocus_p :: forall i. Boolean -> Object GenProp -> Prop i
autofocus_p = fromGenProp "autofocus"

-- | Number
bottomFixed_p :: forall i. Number -> Object GenProp -> Prop i
bottomFixed_p = fromGenProp "bottomFixed"


-- | Number
letterSpacing_p :: forall i. Number -> Object GenProp -> Prop i
letterSpacing_p = fromGenProp "letterSpacing"

lineHeight_p :: forall i. String -> Object GenProp -> Prop i
lineHeight_p = fromGenProp "lineHeight"



-- | Margin : left, top, right and bottom
-- | MarginBottom : bottom
-- | MarginHorizontal : left and right
-- | MarginLeft : left
-- | MarginRight : right
-- | MarginTop : top
-- | MarginVertical : top and bottom
margin_p :: forall i. Margin -> Object GenProp -> Prop i
margin_p = fromGenProp "margin"

-- | Int
marginEnd_p :: forall i. Int -> Object GenProp -> Prop i
marginEnd_p = fromGenProp "marginEnd"

-- | Int
marginStart_p :: forall i. Int -> Object GenProp -> Prop i
marginStart_p = fromGenProp "marginStart"

-- | L, // long
maxDate_p :: forall i. String -> Object GenProp -> Prop i
maxDate_p = fromGenProp "maxDate"

-- | Int
maxHeight_p :: forall i. Int -> Object GenProp -> Prop i
maxHeight_p = fromGenProp "maxHeight"

-- | Int
maxLines_p :: forall i. Int -> Object GenProp -> Prop i
maxLines_p = fromGenProp "maxLines"

-- | int
maxSeek_p :: forall i. Int -> Object GenProp -> Prop i
maxSeek_p = fromGenProp "maxSeek"

-- | Int
maxWidth_p :: forall i. Int -> Object GenProp -> Prop i
maxWidth_p = fromGenProp "maxWidth"

-- | L, // long
minDate_p :: forall i. String -> Object GenProp -> Prop i
minDate_p = fromGenProp "minDate"

-- | Int
minHeight_p :: forall i. Int -> Object GenProp -> Prop i
minHeight_p = fromGenProp "minHeight"

-- | Int
minWidth_p :: forall i. Int -> Object GenProp -> Prop i
minWidth_p = fromGenProp "minWidth"



-- | Orientation
orientation_p :: forall i. Orientation -> Object GenProp -> Prop i
orientation_p = fromGenProp "orientation"



-- | Padding : left, top, right and bottom
-- | PaddingBottom : bottom
-- | PaddingHorizontal : left and right
-- | PaddingLeft : left
-- | PaddingRight : right
-- | PaddingTop : top
-- | PaddingVertical : top and bottom
padding_p :: forall i. Padding -> Object GenProp -> Prop i
padding_p = fromGenProp "padding"

-- | Number
pivotX_p :: forall i. Number -> Object GenProp -> Prop i
pivotX_p = fromGenProp "pivotX"

-- | Number
pivotY_p :: forall i. Number -> Object GenProp -> Prop i
pivotY_p = fromGenProp "pivotY"

-- | String
progressColor_p :: forall i. String -> Object GenProp -> Prop i
progressColor_p = fromGenProp "progressColor"



-- | Number
rotation_p :: forall i. Number -> Object GenProp -> Prop i
rotation_p = fromGenProp "rotation"

-- | Number
rotationX_p :: forall i. Number -> Object GenProp -> Prop i
rotationX_p = fromGenProp "rotationX"

-- | Number
rotationY_p :: forall i. Number -> Object GenProp -> Prop i
rotationY_p = fromGenProp "rotationY"



-- | String
scaleType_p :: forall i. String -> Object GenProp -> Prop i
scaleType_p = fromGenProp "scaleType"

-- | Number
scaleX_p :: forall i. Number -> Object GenProp -> Prop i
scaleX_p = fromGenProp "scaleX"

-- | Number
scaleY_p :: forall i. Number -> Object GenProp -> Prop i
scaleY_p = fromGenProp "scaleY"

-- | Boolean
scrollBarX_p :: forall i. Boolean -> Object GenProp -> Prop i
scrollBarX_p = fromGenProp "scrollBarX"

-- | Boolean
scrollBarY_p :: forall i. Boolean -> Object GenProp -> Prop i
scrollBarY_p = fromGenProp "scrollBarY"

-- | Boolean
selectable_p :: forall i. Boolean -> Object GenProp -> Prop i
selectable_p = fromGenProp "selectable"

-- | Boolean
selectableItem_p :: forall i. Boolean -> Object GenProp -> Prop i
selectableItem_p = fromGenProp "selectableItem"

-- | Boolean
selected_p :: forall i. Boolean -> Object GenProp -> Prop i
selected_p = fromGenProp "selected"

-- | String
selectedTabIndicatorColor_p :: forall i. String -> Object GenProp -> Prop i
selectedTabIndicatorColor_p = fromGenProp "selectedTabIndicatorColor"

-- | Int
selectedTabIndicatorHeight_p :: forall i. Int -> Object GenProp -> Prop i
selectedTabIndicatorHeight_p = fromGenProp "selectedTabIndicatorHeight"

-- | L, // long
setDate_p :: forall i. String -> Object GenProp -> Prop i
setDate_p = fromGenProp "setDate"

-- | Unknown
shadow_p :: forall i. Shadow -> Object GenProp -> Prop i
shadow_p = fromGenProp "shadow"

-- | Int
showDividers_p :: forall i. Int -> Object GenProp -> Prop i
showDividers_p = fromGenProp "showDividers"

-- | Boolean
singleLine_p :: forall i. Boolean -> Object GenProp -> Prop i
singleLine_p = fromGenProp "singleLine"

-- | Unknown
stroke_p :: forall i. String -> Object GenProp -> Prop i
stroke_p = fromGenProp "stroke"

-- | Unknown
tabTextColors_p :: forall i. String -> Object GenProp -> Prop i
tabTextColors_p = fromGenProp "tabTextColors"

-- | String
text_p :: forall i. String -> Object GenProp -> Prop i
text_p = fromGenProp "text"

-- | Boolean
textAllCaps_p :: forall i. Boolean -> Object GenProp -> Prop i
textAllCaps_p = fromGenProp "textAllCaps"

-- | String
textFromHtml_p :: forall i. String -> Object GenProp -> Prop i
textFromHtml_p = fromGenProp "textFromHtml"

-- | Boolean
textIsSelectable_p :: forall i. Boolean -> Object GenProp -> Prop i
textIsSelectable_p = fromGenProp "textIsSelectable"

textSize_p :: forall i. Int -> Object GenProp -> Prop i
textSize_p = fromGenProp "textSize"

-- | Number
translationX_p :: forall i. Number -> Object GenProp -> Prop i
translationX_p = fromGenProp "translationX"

-- | Number
translationY_p :: forall i. Number -> Object GenProp -> Prop i
translationY_p = fromGenProp "translationY"

-- | Number
translationZ_p :: forall i. Number -> Object GenProp -> Prop i
translationZ_p = fromGenProp "translationZ"

-- | String
toast_p :: forall i. String -> Object GenProp -> Prop i
toast_p = fromGenProp "toast"

-- | Typeface
typeface_p :: forall i. Typeface -> Object GenProp -> Prop i
typeface_p = fromGenProp "typeface"



-- | String
url_p :: forall i. String -> Object GenProp -> Prop i
url_p = fromGenProp "url"



-- | String
values_p :: forall i. String -> Object GenProp -> Prop i
values_p = fromGenProp "values"

-- | Visibility
visibility_p :: forall i. Visibility -> Object GenProp -> Prop i
visibility_p = fromGenProp "visibility"



{-- type: 'f', --}
{--           match_parent: -1, --}
{--                 wrap_content: -2, --}
weight_p :: forall i. Number -> Object GenProp -> Prop i
weight_p = fromGenProp "weight"

width_p :: forall i. Length -> Object GenProp -> Prop i
width_p = fromGenProp "width"

-- | Unknown
alignParentBottom_p :: forall i. String -> Object GenProp -> Prop i
alignParentBottom_p = fromGenProp "alignParentBottom"

-- | Unknown
alignParentLeft_p :: forall i. String -> Object GenProp -> Prop i
alignParentLeft_p = fromGenProp "alignParentLeft"

nestedScrollView_p :: forall i. Boolean -> Object GenProp -> Prop i
nestedScrollView_p = fromGenProp "nestedScrollView"
