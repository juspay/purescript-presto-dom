## Module PrestoDOM.Types.Core

#### `PropName`

``` purescript
newtype PropName value
  = PropName String
```

##### Instances
``` purescript
Newtype (PropName value) _
```

#### `PrestoDOM`

``` purescript
type PrestoDOM i w = VDom (Array (Prop i)) w
```

#### `Props`

``` purescript
type Props i = Array (Prop i)
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

#### `Screen`

``` purescript
type Screen action st eff retAction = { initialState :: st, view :: (action -> Eff (ref :: REF, frp :: FRP, dom :: DOM | eff) Unit) -> st -> VDom (Array (Prop (PropEff eff))) Void, eval :: action -> st -> Eval eff action retAction st }
```

#### `PropEff`

``` purescript
type PropEff e = Eff (ref :: REF, frp :: FRP, dom :: DOM | e) Unit
```

#### `Eval`

``` purescript
type Eval eff action retAction st = Either (Tuple (Maybe st) retAction) (Tuple st (Cmd eff action))
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


### Re-exported from Halogen.VDom.DOM.Prop:

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

### Re-exported from Halogen.VDom.Types:

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

### Re-exported from PrestoDOM.Types.DomAttributes:

#### `Visibility`

``` purescript
data Visibility
  = VISIBLE
  | INVISIBLE
  | GONE
```

#### `Typeface`

``` purescript
data Typeface
  = NORMAL
  | BOLD
  | ITALIC
  | BOLD_ITALIC
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

