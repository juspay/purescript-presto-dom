module PrestoDOM.Properties.SetChildProps
    ( override_c
    , root_c

    , a_duration_c
    , a_scaleX_c
    , a_scaleY_c
    , absolute_c
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
    , circularLoader_c
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
    , font_c
    , foreground_c
    , fromBottom_c
    , fromLeft_c
    , fromRight_c
    , fromTop_c

    , gravity_c

    , hardware_c
    , height_c
    , hint_c
    , hintColor_c

    , imageUrl_c
    , inputType_c
    , inputTypeI_c

    , layoutGravity_c
    , layoutTransition_c
    , bottomFixed_c
    , autofocus_c
    , letterSpacing_c
    , lineHeight_c

    , margin_c
    , marginEnd_c
    , marginStart_c
    , maxDate_c
    , maxHeight_c
    , maxLines_c
    , maxSeek_c
    , maxWidth_c
    , minDate_c
    , minHeight_c
    , minWidth_c

    , orientation_c
    , position_c
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
    , shadow_c
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

    , alignParentBottom_c
    , alignParentLeft_c
    , nestedScrollView_c
    ) where


import Prelude

import Data.Tuple (Tuple(..))
import PrestoDOM.Types.Core (Gravity, InputType, Length, Margin, Font, Orientation, Padding, Position, Shadow, Typeface, Visibility, GenProp(..))


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

-- | Boolean
absolute_c :: Boolean -> Tuple String GenProp
absolute_c = Tuple "absolute" <<< BooleanP

-- | String
accessibilityHint_c :: String -> Tuple String GenProp
accessibilityHint_c = Tuple "accessibilityHint" <<< StringP

-- | Boolean
adjustViewBounds_c :: Boolean -> Tuple String GenProp
adjustViewBounds_c = Tuple "adjustViewBounds" <<< BooleanP

-- | Number
alpha_c :: Number -> Tuple String GenProp
alpha_c = Tuple "alpha" <<< NumberP



-- | String
background_c :: String -> Tuple String GenProp
background_c = Tuple "background" <<< StringP

-- | String
backgroundColor_c :: String -> Tuple String GenProp
backgroundColor_c = Tuple "backgroundColor" <<< StringP

-- | String
backgroundDrawable_c :: String -> Tuple String GenProp
backgroundDrawable_c = Tuple "backgroundDrawable" <<< StringP

-- | String
backgroundTint_c :: String -> Tuple String GenProp
backgroundTint_c = Tuple "backgroundTint" <<< StringP

-- | String
btnBackground_c :: String -> Tuple String GenProp
btnBackground_c = Tuple "btnBackground" <<< StringP

-- | String
btnColor_c :: String -> Tuple String GenProp
btnColor_c = Tuple "btnColor" <<< StringP

-- | String
buttonTint_c :: String -> Tuple String GenProp
buttonTint_c = Tuple "buttonTint" <<< StringP

-- | Boolean
checked_c :: Boolean -> Tuple String GenProp
checked_c = Tuple "checked" <<< BooleanP

-- | Boolean
circularLoader_c :: Boolean -> Tuple String GenProp
circularLoader_c = Tuple "circularLoader" <<< BooleanP

-- | Boolean
clickable_c :: Boolean -> Tuple String GenProp
clickable_c = Tuple "clickable" <<< BooleanP

-- | Boolean
clipChildren_c :: Boolean -> Tuple String GenProp
clipChildren_c = Tuple "clipChildren" <<< BooleanP

-- | String
color_c :: String -> Tuple String GenProp
color_c = Tuple "color" <<< StringP

-- | Unknown
colorFilter_c :: String -> Tuple String GenProp
colorFilter_c = Tuple "colorFilter" <<< StringP

-- | Number
cornerRadius_c :: Number -> Tuple String GenProp
cornerRadius_c = Tuple "cornerRadius" <<< NumberP

-- curve
-- | String
curve_c :: String -> Tuple String GenProp
curve_c = Tuple "curve" <<< StringP



-- | L, // long
delay_c :: String -> Tuple String GenProp
delay_c = Tuple "delay" <<< StringP

-- | String
dividerDrawable_c :: String -> Tuple String GenProp
dividerDrawable_c = Tuple "dividerDrawable" <<< StringP

-- | L, // long
duration_c :: String -> Tuple String GenProp
duration_c = Tuple "duration" <<< StringP



-- | Int
elevation_c :: Int -> Tuple String GenProp
elevation_c = Tuple "elevation" <<< IntP



-- | Boolean
fillViewport_c :: Boolean -> Tuple String GenProp
fillViewport_c = Tuple "fillViewport" <<< BooleanP

focus_c :: String -> Tuple String GenProp
focus_c = Tuple "focus" <<< StringP

-- | Boolean
focusable_c :: Boolean -> Tuple String GenProp
focusable_c = Tuple "focusable" <<< BooleanP

focusOut_c :: String -> Tuple String GenProp
focusOut_c = Tuple "focusOut" <<< StringP

-- | Unknown
fontFamily_c :: String -> Tuple String GenProp
fontFamily_c = Tuple "fontFamily" <<< StringP

-- | Int
fontSize_c :: Int -> Tuple String GenProp
fontSize_c = Tuple "fontSize" <<< IntP

-- | String
fontStyle_c :: String -> Tuple String GenProp
fontStyle_c = Tuple "fontStyle" <<< StringP

-- | Font
font_c :: Font -> Tuple String GenProp
font_c = Tuple "font" <<< FontP

-- | Boolean
foreground_c :: Boolean -> Tuple String GenProp
foreground_c = Tuple "foreground" <<< BooleanP

-- | Boolean
fromBottom_c :: Boolean -> Tuple String GenProp
fromBottom_c = Tuple "fromBottom" <<< BooleanP

-- | Boolean
fromLeft_c :: Boolean -> Tuple String GenProp
fromLeft_c = Tuple "fromLeft" <<< BooleanP

-- | Boolean
fromRight_c :: Boolean -> Tuple String GenProp
fromRight_c = Tuple "fromRight" <<< BooleanP

-- | Boolean
fromTop_c :: Boolean -> Tuple String GenProp
fromTop_c = Tuple "fromTop" <<< BooleanP


-- | Gravity
gravity_c :: Gravity -> Tuple String GenProp
gravity_c = Tuple "gravity" <<< GravityP



-- | Unknown
hardware_c :: String -> Tuple String GenProp
hardware_c = Tuple "hardware" <<< StringP

height_c :: Length -> Tuple String GenProp
height_c = Tuple "height" <<< LengthP

-- | String
hint_c :: String -> Tuple String GenProp
hint_c = Tuple "hint" <<< StringP

-- | String
hintColor_c :: String -> Tuple String GenProp
hintColor_c = Tuple "hintColor" <<< StringP



-- | String
imageUrl_c :: String -> Tuple String GenProp
imageUrl_c = Tuple "imageUrl" <<< StringP

-- | InputType
inputType_c :: InputType -> Tuple String GenProp
inputType_c = Tuple "inputType" <<< InputTypeP

-- | Int
inputTypeI_c :: Int -> Tuple String GenProp
inputTypeI_c = Tuple "inputTypeI" <<< IntP



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
layoutGravity_c :: String -> Tuple String GenProp
layoutGravity_c = Tuple "layout_gravity" <<< StringP

-- | Boolean
layoutTransition_c :: Boolean -> Tuple String GenProp
layoutTransition_c = Tuple "layoutTransition" <<< BooleanP

-- | Boolean
autofocus_c :: Boolean -> Tuple String GenProp
autofocus_c = Tuple "autofocus" <<< BooleanP

-- | Number
bottomFixed_c :: Number -> Tuple String GenProp
bottomFixed_c = Tuple "bottomFixed" <<< NumberP

-- | Number
letterSpacing_c :: Number -> Tuple String GenProp
letterSpacing_c = Tuple "letterSpacing" <<< NumberP

lineHeight_c :: String -> Tuple String GenProp
lineHeight_c = Tuple "lineHeight" <<< StringP



-- | Margin : left, top, right and bottom
-- | MarginBottom : bottom
-- | MarginHorizontal : left and right
-- | MarginLeft : left
-- | MarginRight : right
-- | MarginTop : top
-- | MarginVertical : top and bottom
margin_c :: Margin -> Tuple String GenProp
margin_c = Tuple "margin" <<< MarginP

-- | Int
marginEnd_c :: Int -> Tuple String GenProp
marginEnd_c = Tuple "marginEnd" <<< IntP

-- | Int
marginStart_c :: Int -> Tuple String GenProp
marginStart_c = Tuple "marginStart" <<< IntP

-- | L, // long
maxDate_c :: String -> Tuple String GenProp
maxDate_c = Tuple "maxDate" <<< StringP

-- | Int
maxHeight_c :: Int -> Tuple String GenProp
maxHeight_c = Tuple "maxHeight" <<< IntP

-- | Int
maxLines_c :: Int -> Tuple String GenProp
maxLines_c = Tuple "maxLines" <<< IntP

-- | int
maxSeek_c :: Int -> Tuple String GenProp
maxSeek_c = Tuple "maxSeek" <<< IntP

-- | Int
maxWidth_c :: Int -> Tuple String GenProp
maxWidth_c = Tuple "maxWidth" <<< IntP

-- | L, // long
minDate_c :: String -> Tuple String GenProp
minDate_c = Tuple "minDate" <<< StringP

-- | Int
minHeight_c :: Int -> Tuple String GenProp
minHeight_c = Tuple "minHeight" <<< IntP

-- | Int
minWidth_c :: Int -> Tuple String GenProp
minWidth_c = Tuple "minWidth" <<< IntP



-- | Orientation
orientation_c :: Orientation -> Tuple String GenProp
orientation_c = Tuple "orientation" <<< OrientationP



-- | Padding : left, top, right and bottom
-- | PaddingBottom : bottom
-- | PaddingHorizontal : left and right
-- | PaddingLeft : left
-- | PaddingRight : right
-- | PaddingTop : top
-- | PaddingVertical : top and bottom
padding_c :: Padding -> Tuple String GenProp
padding_c = Tuple "padding" <<< PaddingP

position_c :: Position -> Tuple String GenProp
position_c = Tuple "position" <<< PositionP

-- | Number
pivotX_c :: Number -> Tuple String GenProp
pivotX_c = Tuple "pivotX" <<< NumberP

-- | Number
pivotY_c :: Number -> Tuple String GenProp
pivotY_c = Tuple "pivotY" <<< NumberP

-- | String
progressColor_c :: String -> Tuple String GenProp
progressColor_c = Tuple "progressColor" <<< StringP



-- | Number
rotation_c :: Number -> Tuple String GenProp
rotation_c = Tuple "rotation" <<< NumberP

-- | Number
rotationX_c :: Number -> Tuple String GenProp
rotationX_c = Tuple "rotationX" <<< NumberP

-- | Number
rotationY_c :: Number -> Tuple String GenProp
rotationY_c = Tuple "rotationY" <<< NumberP



-- | String
scaleType_c :: String -> Tuple String GenProp
scaleType_c = Tuple "scaleType" <<< StringP

-- | Number
scaleX_c :: Number -> Tuple String GenProp
scaleX_c = Tuple "scaleX" <<< NumberP

-- | Number
scaleY_c :: Number -> Tuple String GenProp
scaleY_c = Tuple "scaleY" <<< NumberP

-- | Boolean
scrollBarX_c :: Boolean -> Tuple String GenProp
scrollBarX_c = Tuple "scrollBarX" <<< BooleanP

-- | Boolean
scrollBarY_c :: Boolean -> Tuple String GenProp
scrollBarY_c = Tuple "scrollBarY" <<< BooleanP

-- | Boolean
selectable_c :: Boolean -> Tuple String GenProp
selectable_c = Tuple "selectable" <<< BooleanP

-- | Boolean
selectableItem_c :: Boolean -> Tuple String GenProp
selectableItem_c = Tuple "selectableItem" <<< BooleanP

-- | Boolean
selected_c :: Boolean -> Tuple String GenProp
selected_c = Tuple "selected" <<< BooleanP

-- | String
selectedTabIndicatorColor_c :: String -> Tuple String GenProp
selectedTabIndicatorColor_c = Tuple "selectedTabIndicatorColor" <<< StringP

-- | Int
selectedTabIndicatorHeight_c :: Int -> Tuple String GenProp
selectedTabIndicatorHeight_c = Tuple "selectedTabIndicatorHeight" <<< IntP

-- | L, // long
setDate_c :: String -> Tuple String GenProp
setDate_c = Tuple "setDate" <<< StringP

-- | Unknown
shadow_c :: Shadow -> Tuple String GenProp
shadow_c = Tuple "shadow" <<< ShadowP

-- | Int
showDividers_c :: Int -> Tuple String GenProp
showDividers_c = Tuple "showDividers" <<< IntP

-- | Boolean
singleLine_c :: Boolean -> Tuple String GenProp
singleLine_c = Tuple "singleLine" <<< BooleanP

-- | Unknown
stroke_c :: String -> Tuple String GenProp
stroke_c = Tuple "stroke" <<< StringP

-- | Unknown
tabTextColors_c :: String -> Tuple String GenProp
tabTextColors_c = Tuple "tabTextColors" <<< StringP

-- | String
text_c :: String -> Tuple String GenProp
text_c = Tuple "text" <<< StringP

-- | Boolean
textAllCaps_c :: Boolean -> Tuple String GenProp
textAllCaps_c = Tuple "textAllCaps" <<< BooleanP

-- | String
textFromHtml_c :: String -> Tuple String GenProp
textFromHtml_c = Tuple "textFromHtml" <<< StringP

-- | Boolean
textIsSelectable_c :: Boolean -> Tuple String GenProp
textIsSelectable_c = Tuple "textIsSelectable" <<< BooleanP

textSize_c :: Int -> Tuple String GenProp
textSize_c = Tuple "textSize" <<< IntP

-- | Number
translationX_c :: Number -> Tuple String GenProp
translationX_c = Tuple "translationX" <<< NumberP

-- | Number
translationY_c :: Number -> Tuple String GenProp
translationY_c = Tuple "translationY" <<< NumberP

-- | Number
translationZ_c :: Number -> Tuple String GenProp
translationZ_c = Tuple "translationZ" <<< NumberP

-- | String
toast_c :: String -> Tuple String GenProp
toast_c = Tuple "toast" <<< StringP

-- | Typeface
typeface_c :: Typeface -> Tuple String GenProp
typeface_c = Tuple "typeface" <<< TypefaceP



-- | String
url_c :: String -> Tuple String GenProp
url_c = Tuple "url" <<< StringP



-- | String
values_c :: String -> Tuple String GenProp
values_c = Tuple "values" <<< StringP

-- | Visibility
visibility_c :: Visibility -> Tuple String GenProp
visibility_c = Tuple "visibility" <<< VisibilityP



{-- type: 'f', --}
{--           match_parent: -1, --}
{--                 wrap_content: -2, --}
weight_c :: Number -> Tuple String GenProp
weight_c = Tuple "weight" <<< NumberP

width_c :: Length -> Tuple String GenProp
width_c = Tuple "width" <<< LengthP

-- | Unknown
alignParentBottom_c :: String -> Tuple String GenProp
alignParentBottom_c = Tuple "alignParentBottom" <<< StringP

-- | Unknown
alignParentLeft_c :: String -> Tuple String GenProp
alignParentLeft_c = Tuple "alignParentLeft" <<< StringP

nestedScrollView_c :: Boolean -> Tuple String GenProp
nestedScrollView_c = Tuple "nestedScrollView" <<< BooleanP