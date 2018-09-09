## Module PrestoDOM.Types.DomAttributes

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

#### `InputType`

``` purescript
data InputType
  = Password
  | Numeric
  | NumericPassword
  | Disabled
  | TypeText
```

#### `Length`

``` purescript
data Length
  = MATCH_PARENT
  | WRAP_CONTENT
  | V Int
```

#### `Orientation`

``` purescript
data Orientation
  = HORIZONTAL
  | VERTICAL
```

#### `Typeface`

``` purescript
data Typeface
  = NORMAL
  | BOLD
  | ITALIC
  | BOLD_ITALIC
```

#### `Visibility`

``` purescript
data Visibility
  = VISIBLE
  | INVISIBLE
  | GONE
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

#### `Shadow`

``` purescript
data Shadow
  = Shadow Number Number Number Number String Number
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

#### `renderGravity`

``` purescript
renderGravity :: Gravity -> String
```

#### `renderInputType`

``` purescript
renderInputType :: InputType -> String
```

#### `renderLength`

``` purescript
renderLength :: Length -> String
```

#### `renderOrientation`

``` purescript
renderOrientation :: Orientation -> String
```

#### `renderTypeface`

``` purescript
renderTypeface :: Typeface -> String
```

#### `renderVisibility`

``` purescript
renderVisibility :: Visibility -> String
```

#### `renderShadow`

``` purescript
renderShadow :: Shadow -> String
```


