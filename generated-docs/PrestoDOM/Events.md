## Module PrestoDOM.Events

#### `unsafeProp`

``` purescript
unsafeProp :: forall a. a -> String
```

#### `onClick`

``` purescript
onClick :: forall a eff. (a -> Eff (frp :: FRP | eff) Unit) -> (Unit -> a) -> Prop a
```

#### `onChange`

``` purescript
onChange :: forall a eff. (a -> Eff (frp :: FRP | eff) Unit) -> (String -> a) -> Prop a
```

#### `onBackPressed`

``` purescript
onBackPressed :: forall a eff. (a -> Eff (frp :: FRP | eff) Unit) -> (Unit -> a) -> Prop a
```


