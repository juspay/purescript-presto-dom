## Module PrestoDOM.Elements.Elements

#### `Node`

``` purescript
type Node i p = Array i -> Array (VDom (Array i) p) -> VDom (Array i) p
```

#### `Leaf`

``` purescript
type Leaf i p = Array i -> VDom (Array i) p
```

#### `element`

``` purescript
element :: forall i p. ElemName -> Array (Prop i) -> Array (VDom (Array (Prop i)) p) -> VDom (Array (Prop i)) p
```

#### `keyed`

``` purescript
keyed :: forall i p. ElemName -> Array (Prop i) -> Array (Tuple String (VDom (Array (Prop i)) p)) -> VDom (Array (Prop i)) p
```

#### `linearLayout_`

``` purescript
linearLayout_ :: forall i p. Namespace -> Node (Prop i) p
```

#### `relativeLayout_`

``` purescript
relativeLayout_ :: forall i p. Namespace -> Node (Prop i) p
```

#### `linearLayout`

``` purescript
linearLayout :: forall i p. Node (Prop i) p
```

#### `relativeLayout`

``` purescript
relativeLayout :: forall i p. Node (Prop i) p
```

#### `horizontalScrollView`

``` purescript
horizontalScrollView :: forall i p. Node (Prop i) p
```

#### `scrollView`

``` purescript
scrollView :: forall i p. Node (Prop i) p
```

#### `frameLayout`

``` purescript
frameLayout :: forall i p. Node (Prop i) p
```

#### `shimmerFrameLayout`

``` purescript
shimmerFrameLayout :: forall i p. Node (Prop i) p
```

#### `tabLayout`

``` purescript
tabLayout :: forall i p. Node (Prop i) p
```

#### `imageView`

``` purescript
imageView :: forall i p. Leaf (Prop i) p
```

#### `editText`

``` purescript
editText :: forall i p. Leaf (Prop i) p
```

#### `listView`

``` purescript
listView :: forall i p. Leaf (Prop i) p
```

#### `progressBar`

``` purescript
progressBar :: forall i p. Leaf (Prop i) p
```

#### `textView`

``` purescript
textView :: forall i p. Leaf (Prop i) p
```

#### `viewPager`

``` purescript
viewPager :: forall i p. Node (Prop i) p
```

#### `button`

``` purescript
button :: forall i p. Leaf (Prop i) p
```

#### `calendar`

``` purescript
calendar :: forall i p. Leaf (Prop i) p
```

#### `checkBox`

``` purescript
checkBox :: forall i p. Leaf (Prop i) p
```

#### `switch`

``` purescript
switch :: forall i p. Leaf (Prop i) p
```

#### `viewWidget`

``` purescript
viewWidget :: forall i p. Leaf (Prop i) p
```

#### `webView`

``` purescript
webView :: forall i p. Leaf (Prop i) p
```


