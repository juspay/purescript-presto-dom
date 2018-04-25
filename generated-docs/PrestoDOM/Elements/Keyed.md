## Module PrestoDOM.Elements.Keyed

#### `KeyedNode`

``` purescript
type KeyedNode i p = Array i -> Array (Tuple String (VDom (Array i) p)) -> VDom (Array i) p
```

#### `linearLayout`

``` purescript
linearLayout :: forall i p. KeyedNode (Prop i) p
```

#### `relativeLayout`

``` purescript
relativeLayout :: forall i p. KeyedNode (Prop i) p
```

#### `horizontalScrollView`

``` purescript
horizontalScrollView :: forall i p. KeyedNode (Prop i) p
```

#### `scrollView`

``` purescript
scrollView :: forall i p. KeyedNode (Prop i) p
```


