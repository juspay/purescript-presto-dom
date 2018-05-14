## Module PrestoDOM


### Re-exported from PrestoDOM.Elements.Elements:

#### `Node`

``` purescript
type Node i p = Array i -> Array (VDom (Array i) p) -> VDom (Array i) p
```

#### `Leaf`

``` purescript
type Leaf i p = Array i -> VDom (Array i) p
```

#### `webView`

``` purescript
webView :: forall i p. Leaf (Prop i) p
```

#### `viewWidget`

``` purescript
viewWidget :: forall i p. Leaf (Prop i) p
```

#### `viewPager`

``` purescript
viewPager :: forall i p. Node (Prop i) p
```

#### `textView`

``` purescript
textView :: forall i p. Leaf (Prop i) p
```

#### `tabLayout`

``` purescript
tabLayout :: forall i p. Node (Prop i) p
```

#### `switch`

``` purescript
switch :: forall i p. Leaf (Prop i) p
```

#### `shimmerFrameLayout`

``` purescript
shimmerFrameLayout :: forall i p. Node (Prop i) p
```

#### `scrollView`

``` purescript
scrollView :: forall i p. Node (Prop i) p
```

#### `relativeLayout_`

``` purescript
relativeLayout_ :: forall i p. Namespace -> Node (Prop i) p
```

#### `relativeLayout`

``` purescript
relativeLayout :: forall i p. Node (Prop i) p
```

#### `progressBar`

``` purescript
progressBar :: forall i p. Leaf (Prop i) p
```

#### `listView`

``` purescript
listView :: forall i p. Leaf (Prop i) p
```

#### `linearLayout_`

``` purescript
linearLayout_ :: forall i p. Namespace -> Node (Prop i) p
```

#### `linearLayout`

``` purescript
linearLayout :: forall i p. Node (Prop i) p
```

#### `keyed`

``` purescript
keyed :: forall i p. ElemName -> Array (Prop i) -> Array (Tuple String (VDom (Array (Prop i)) p)) -> VDom (Array (Prop i)) p
```

#### `imageView`

``` purescript
imageView :: forall i p. Leaf (Prop i) p
```

#### `horizontalScrollView`

``` purescript
horizontalScrollView :: forall i p. Node (Prop i) p
```

#### `frameLayout`

``` purescript
frameLayout :: forall i p. Node (Prop i) p
```

#### `element`

``` purescript
element :: forall i p. ElemName -> Array (Prop i) -> Array (VDom (Array (Prop i)) p) -> VDom (Array (Prop i)) p
```

#### `editText`

``` purescript
editText :: forall i p. Leaf (Prop i) p
```

#### `checkBox`

``` purescript
checkBox :: forall i p. Leaf (Prop i) p
```

#### `calendar`

``` purescript
calendar :: forall i p. Leaf (Prop i) p
```

#### `button`

``` purescript
button :: forall i p. Leaf (Prop i) p
```

### Re-exported from PrestoDOM.Events:

#### `onClick`

``` purescript
onClick :: forall a eff. (a -> PropEff eff) -> (Unit -> a) -> Prop (PropEff eff)
```

#### `onChange`

``` purescript
onChange :: forall a eff. (a -> PropEff eff) -> (String -> a) -> Prop (PropEff eff)
```

#### `onBackPressed`

``` purescript
onBackPressed :: forall a eff. (a -> PropEff eff) -> (Unit -> a) -> Prop (PropEff eff)
```

#### `makeEvent`

``` purescript
makeEvent :: forall eff a. (a -> PropEff eff) -> (Event -> PropEff eff)
```

#### `event`

``` purescript
event :: forall a. EventType -> (Event -> Maybe a) -> Prop a
```

#### `backPressHandlerImpl`

``` purescript
backPressHandlerImpl :: forall eff. PropEff eff
```

#### `backPressHandler`

``` purescript
backPressHandler :: forall eff. (Event -> PropEff eff)
```

### Re-exported from PrestoDOM.Properties:

#### `width`

``` purescript
width :: forall i. Length -> Prop i
```

#### `weight`

``` purescript
weight :: forall i. String -> Prop i
```

#### `visibility`

``` purescript
visibility :: forall i. Visibility -> Prop i
```

Visibility

#### `values`

``` purescript
values :: forall i. String -> Prop i
```

String

#### `url`

``` purescript
url :: forall i. String -> Prop i
```

String

#### `typeface`

``` purescript
typeface :: forall i. Typeface -> Prop i
```

Typeface

#### `translationZ`

``` purescript
translationZ :: forall i. Number -> Prop i
```

Number

#### `translationY`

``` purescript
translationY :: forall i. Number -> Prop i
```

Number

#### `translationX`

``` purescript
translationX :: forall i. Number -> Prop i
```

Number

#### `toast`

``` purescript
toast :: forall i. String -> Prop i
```

String

#### `textSize`

``` purescript
textSize :: forall i. Int -> Prop i
```

#### `textIsSelectable`

``` purescript
textIsSelectable :: forall i. Boolean -> Prop i
```

Boolean

#### `textFromHtml`

``` purescript
textFromHtml :: forall i. String -> Prop i
```

String

#### `textAllCaps`

``` purescript
textAllCaps :: forall i. Boolean -> Prop i
```

Boolean

#### `text`

``` purescript
text :: forall i. String -> Prop i
```

String

#### `tabTextColors`

``` purescript
tabTextColors :: forall i. String -> Prop i
```

Unknown

#### `stroke`

``` purescript
stroke :: forall i. String -> Prop i
```

Unknown

#### `singleLine`

``` purescript
singleLine :: forall i. Boolean -> Prop i
```

Boolean

#### `showDividers`

``` purescript
showDividers :: forall i. Int -> Prop i
```

Int

#### `shadowLayer`

``` purescript
shadowLayer :: forall i. String -> Prop i
```

Unknown

#### `setDate`

``` purescript
setDate :: forall i. String -> Prop i
```

L, // long

#### `selectedTabIndicatorHeight`

``` purescript
selectedTabIndicatorHeight :: forall i. Int -> Prop i
```

Int

#### `selectedTabIndicatorColor`

``` purescript
selectedTabIndicatorColor :: forall i. String -> Prop i
```

String

#### `selected`

``` purescript
selected :: forall i. Boolean -> Prop i
```

Boolean

#### `selectableItem`

``` purescript
selectableItem :: forall i. Boolean -> Prop i
```

Boolean

#### `selectable`

``` purescript
selectable :: forall i. Boolean -> Prop i
```

Boolean

#### `scrollBarY`

``` purescript
scrollBarY :: forall i. Boolean -> Prop i
```

Boolean

#### `scrollBarX`

``` purescript
scrollBarX :: forall i. Boolean -> Prop i
```

Boolean

#### `scaleY`

``` purescript
scaleY :: forall i. Number -> Prop i
```

Number

#### `scaleX`

``` purescript
scaleX :: forall i. Number -> Prop i
```

Number

#### `scaleType`

``` purescript
scaleType :: forall i. String -> Prop i
```

String

#### `rotationY`

``` purescript
rotationY :: forall i. Number -> Prop i
```

Number

#### `rotationX`

``` purescript
rotationX :: forall i. Number -> Prop i
```

Number

#### `rotation`

``` purescript
rotation :: forall i. Number -> Prop i
```

Number

#### `root`

``` purescript
root :: forall i. Boolean -> Prop i
```

Boolean

#### `prop`

``` purescript
prop :: forall value i. IsProp value => PropName value -> value -> Prop i
```

#### `progressColor`

``` purescript
progressColor :: forall i. String -> Prop i
```

String

#### `pivotY`

``` purescript
pivotY :: forall i. Number -> Prop i
```

Number

#### `pivotX`

``` purescript
pivotX :: forall i. Number -> Prop i
```

Number

#### `padding`

``` purescript
padding :: forall i. Padding -> Prop i
```

Padding : left, top, right and bottom
PaddingBottom : bottom
PaddingHorizontal : left and right
PaddingLeft : left
PaddingRight : right
PaddingTop : top
PaddingVertical : top and bottom

#### `orientation`

``` purescript
orientation :: forall i. Orientation -> Prop i
```

Orientation

#### `minWidth`

``` purescript
minWidth :: forall i. Int -> Prop i
```

Int

#### `minHeight`

``` purescript
minHeight :: forall i. Int -> Prop i
```

Int

#### `minDate`

``` purescript
minDate :: forall i. String -> Prop i
```

L, // long

#### `maxWidth`

``` purescript
maxWidth :: forall i. Int -> Prop i
```

Int

#### `maxSeek`

``` purescript
maxSeek :: forall i. Int -> Prop i
```

int

#### `maxLines`

``` purescript
maxLines :: forall i. Int -> Prop i
```

Int

#### `maxDate`

``` purescript
maxDate :: forall i. String -> Prop i
```

L, // long

#### `marginStart`

``` purescript
marginStart :: forall i. Int -> Prop i
```

Int

#### `marginEnd`

``` purescript
marginEnd :: forall i. Int -> Prop i
```

Int

#### `margin`

``` purescript
margin :: forall i. Margin -> Prop i
```

Margin : left, top, right and bottom
MarginBottom : bottom
MarginHorizontal : left and right
MarginLeft : left
MarginRight : right
MarginTop : top
MarginVertical : top and bottom

#### `lineHeight`

``` purescript
lineHeight :: forall i. String -> Prop i
```

#### `letterSpacing`

``` purescript
letterSpacing :: forall i. Number -> Prop i
```

Number

#### `layoutTransition`

``` purescript
layoutTransition :: forall i. Boolean -> Prop i
```

Boolean

#### `layoutGravity`

``` purescript
layoutGravity :: forall i. String -> Prop i
```

#### `inputTypeI`

``` purescript
inputTypeI :: forall i. Int -> Prop i
```

Int

#### `inputType`

``` purescript
inputType :: forall i. InputType -> Prop i
```

InputType

#### `imageUrl`

``` purescript
imageUrl :: forall i. String -> Prop i
```

String

#### `id_`

``` purescript
id_ :: forall i. String -> Prop i
```

#### `hintColor`

``` purescript
hintColor :: forall i. String -> Prop i
```

String

#### `hint`

``` purescript
hint :: forall i. String -> Prop i
```

String

#### `height`

``` purescript
height :: forall i. Length -> Prop i
```

#### `hardware`

``` purescript
hardware :: forall i. String -> Prop i
```

Unknown

#### `gravity`

``` purescript
gravity :: forall i. Gravity -> Prop i
```

Gravity

#### `foreground`

``` purescript
foreground :: forall i. Boolean -> Prop i
```

Boolean

#### `fontStyle`

``` purescript
fontStyle :: forall i. String -> Prop i
```

String

#### `fontSize`

``` purescript
fontSize :: forall i. Int -> Prop i
```

Int

#### `fontFamily`

``` purescript
fontFamily :: forall i. String -> Prop i
```

Unknown

#### `focusable`

``` purescript
focusable :: forall i. Boolean -> Prop i
```

Boolean

#### `focusOut`

``` purescript
focusOut :: forall i. String -> Prop i
```

#### `focus`

``` purescript
focus :: forall i. String -> Prop i
```

#### `fillViewport`

``` purescript
fillViewport :: forall i. Boolean -> Prop i
```

Boolean

#### `elevation`

``` purescript
elevation :: forall i. Int -> Prop i
```

Int

#### `duration`

``` purescript
duration :: forall i. String -> Prop i
```

L, // long

#### `dividerDrawable`

``` purescript
dividerDrawable :: forall i. String -> Prop i
```

String

#### `delay`

``` purescript
delay :: forall i. String -> Prop i
```

L, // long

#### `curve`

``` purescript
curve :: forall i. String -> Prop i
```

String

#### `cornerRadius`

``` purescript
cornerRadius :: forall i. Number -> Prop i
```

Number

#### `colorFilter`

``` purescript
colorFilter :: forall i. String -> Prop i
```

Unknown

#### `color`

``` purescript
color :: forall i. String -> Prop i
```

String

#### `clipChildren`

``` purescript
clipChildren :: forall i. Boolean -> Prop i
```

Boolean

#### `clickable`

``` purescript
clickable :: forall i. Boolean -> Prop i
```

Boolean

#### `checked`

``` purescript
checked :: forall i. Boolean -> Prop i
```

Boolean

#### `caretColor`

``` purescript
caretColor :: forall i. String -> Prop i
```

#### `buttonTint`

``` purescript
buttonTint :: forall i. String -> Prop i
```

String

#### `btnColor`

``` purescript
btnColor :: forall i. String -> Prop i
```

String

#### `btnBackground`

``` purescript
btnBackground :: forall i. String -> Prop i
```

String

#### `backgroundTint`

``` purescript
backgroundTint :: forall i. String -> Prop i
```

String

#### `backgroundDrawable`

``` purescript
backgroundDrawable :: forall i. String -> Prop i
```

String

#### `backgroundColor`

``` purescript
backgroundColor :: forall i. String -> Prop i
```

String

#### `background`

``` purescript
background :: forall i. String -> Prop i
```

String

#### `alpha`

``` purescript
alpha :: forall i. Number -> Prop i
```

Number

#### `alignParentLeft`

``` purescript
alignParentLeft :: forall i. String -> Prop i
```

Unknown

#### `alignParentBottom`

``` purescript
alignParentBottom :: forall i. String -> Prop i
```

Unknown

#### `adjustViewBounds`

``` purescript
adjustViewBounds :: forall i. Boolean -> Prop i
```

Boolean

#### `accessibilityHint`

``` purescript
accessibilityHint :: forall i. String -> Prop i
```

String

#### `a_scaleY`

``` purescript
a_scaleY :: forall i. String -> Prop i
```

#### `a_scaleX`

``` purescript
a_scaleX :: forall i. String -> Prop i
```

#### `a_duration`

``` purescript
a_duration :: forall i. String -> Prop i
```

### Re-exported from PrestoDOM.Types.Core:

#### `Visibility`

``` purescript
data Visibility
  = VISIBLE
  | INVISIBLE
  | GONE
```

#### `VDom`

``` purescript
data VDom a w
  = Text String
  | Elem (ElemSpec a) (Array (VDom a w))
  | Keyed (ElemSpec a) (Array (Tuple String (VDom a w)))
  | Widget w
  | Grafted (Graft a w)
```

The core virtual-dom tree type, where `a` is the type of attributes,
and `w` is the type of "widgets". Widgets are machines that have complete
control over the lifecycle of some `DOM.Node`.

The `Grafted` constructor and associated machinery enables `bimap`
fusion using a Coyoneda-like encoding.

##### Instances
``` purescript
Functor (VDom a)
Bifunctor VDom
```

#### `Typeface`

``` purescript
data Typeface
  = NORMAL
  | BOLD
  | ITALIC
  | BOLD_ITALIC
```

#### `Screen`

``` purescript
type Screen action st eff retAction = { initialState :: st, view :: (action -> Eff (ref :: REF, frp :: FRP, dom :: DOM | eff) Unit) -> st -> VDom (Array (Prop (PropEff eff))) Void, eval :: action -> st -> Eval eff action retAction st }
```

#### `Props`

``` purescript
type Props i = Array (Prop i)
```

#### `PropName`

``` purescript
newtype PropName value
  = PropName String
```

##### Instances
``` purescript
Newtype (PropName value) _
```

#### `PropEff`

``` purescript
type PropEff e = Eff (ref :: REF, frp :: FRP, dom :: DOM | e) Unit
```

#### `Prop`

``` purescript
data Prop a
```

Attributes, properties, event handlers, and element lifecycles.
Parameterized by the type of handlers outputs.

##### Instances
``` purescript
Functor Prop
```

#### `PrestoDOM`

``` purescript
type PrestoDOM i w = VDom (Array (Prop i)) w
```

#### `Padding`

``` purescript
data Padding
  = Padding Int Int Int Int
  | PaddingBottom Int
  | PaddingHorizontal Int Int
  | PaddingLeft Int
  | PaddingRight Int
  | PaddingTop Int
  | PaddingVertical Int Int
```

#### `Orientation`

``` purescript
data Orientation
  = HORIZONTAL
  | VERTICAL
```

#### `Namespace`

``` purescript
newtype Namespace
  = Namespace String
```

##### Instances
``` purescript
Newtype Namespace _
Eq Namespace
Ord Namespace
Generic Namespace
```

#### `Margin`

``` purescript
data Margin
  = Margin Int Int Int Int
  | MarginBottom Int
  | MarginHorizontal Int Int
  | MarginLeft Int
  | MarginRight Int
  | MarginTop Int
  | MarginVertical Int Int
```

#### `Length`

``` purescript
data Length
  = MATCH_PARENT
  | WRAP_CONTENT
  | V Int
```

#### `InputType`

``` purescript
data InputType
  = Password
  | Numeric
  | NumericPassword
  | Disabled
  | TypeText
```

#### `Gravity`

``` purescript
data Gravity
  = CENTER_HORIZONTAL
  | CENTER_VERTICAL
  | LEFT
  | RIGHT
  | CENTER
  | TOP_VERTICAL
  | START
  | END
```

#### `GenProp`

``` purescript
data GenProp
  = LengthP Length
  | MarginP Margin
  | PaddingP Padding
  | InputTypeP InputType
  | OrientationP Orientation
  | TypefaceP Typeface
  | VisibilityP Visibility
  | GravityP Gravity
  | NumberP Number
  | BooleanP Boolean
  | IntP Int
  | StringP String
  | TextP String
```

#### `Eval`

``` purescript
type Eval eff action retAction st = Either (Tuple (Maybe st) retAction) (Tuple st (Cmd eff action))
```

#### `ElemSpec`

``` purescript
data ElemSpec a
  = ElemSpec (Maybe Namespace) ElemName a
```

##### Instances
``` purescript
(Eq a) => Eq (ElemSpec a)
(Ord a) => Ord (ElemSpec a)
(Generic a) => Generic (ElemSpec a)
Functor ElemSpec
```

#### `ElemName`

``` purescript
newtype ElemName
  = ElemName String
```

##### Instances
``` purescript
Newtype ElemName _
Eq ElemName
Ord ElemName
Generic ElemName
```

#### `Cmd`

``` purescript
type Cmd eff action = Array (Eff (ref :: REF, frp :: FRP, dom :: DOM | eff) action)
```

#### `IsProp`

``` purescript
class IsProp a  where
  toPropValue :: a -> PropValue
```

##### Instances
``` purescript
IsProp String
IsProp Int
IsProp Number
IsProp Boolean
IsProp Length
IsProp InputType
IsProp Orientation
IsProp Typeface
IsProp Visibility
IsProp Gravity
IsProp Margin
IsProp Padding
```

#### `renderVisibility`

``` purescript
renderVisibility :: Visibility -> String
```

#### `renderTypeface`

``` purescript
renderTypeface :: Typeface -> String
```

#### `renderPadding`

``` purescript
renderPadding :: Padding -> String
```

Padding : left, top, right and bottom
PaddingBottom : bottom
PaddingHorizontal : left and right
PaddingLeft : left
PaddingRight : right
PaddingTop : top
PaddingVertical : top and bottom

#### `renderOrientation`

``` purescript
renderOrientation :: Orientation -> String
```

#### `renderMargin`

``` purescript
renderMargin :: Margin -> String
```

Margin : left, top, right and bottom
MarginBottom : bottom
MarginHorizontal : left and right
MarginLeft : left
MarginRight : right
MarginTop : top
MarginVertical : top and bottom

#### `renderLength`

``` purescript
renderLength :: Length -> String
```

#### `renderInputType`

``` purescript
renderInputType :: InputType -> String
```

#### `renderGravity`

``` purescript
renderGravity :: Gravity -> String
```

### Re-exported from PrestoDOM.Utils:

#### `updateAndExit`

``` purescript
updateAndExit :: forall state action retAction eff. state -> retAction -> Eval eff action retAction state
```

#### `exit`

``` purescript
exit :: forall state action retAction eff. retAction -> Eval eff action retAction state
```

#### `continueWithCmd`

``` purescript
continueWithCmd :: forall state action retAction eff. state -> Cmd eff action -> Eval eff action retAction state
```

#### `continue`

``` purescript
continue :: forall state action retAction eff. state -> Eval eff action retAction state
```

