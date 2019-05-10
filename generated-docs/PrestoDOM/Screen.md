## Module PrestoDOM.Screen

#### `ScreenStack`

``` purescript
data ScreenStack a
  = ScreenStack (Stack (Tuple String a)) (Object a)
```

#### `ScreenCache`

``` purescript
type ScreenCache a = Object a
```

#### `stackInitialize`

``` purescript
stackInitialize :: forall a. ScreenStack a
```

#### `stackLookup`

``` purescript
stackLookup :: forall a. String -> ScreenStack a -> Maybe a
```

#### `stackPush`

``` purescript
stackPush :: forall a. String -> a -> ScreenStack a -> ScreenStack a
```

#### `stackPopTill`

``` purescript
stackPopTill :: forall a. String -> ScreenStack a -> Tuple (ScreenStack a) (Array (Tuple String a))
```

#### `cacheInitialize`

``` purescript
cacheInitialize :: forall a. ScreenCache a
```

#### `cacheLookup`

``` purescript
cacheLookup :: forall a. String -> ScreenCache a -> Maybe a
```

#### `cacheInsert`

``` purescript
cacheInsert :: forall a. String -> a -> ScreenCache a -> ScreenCache a
```

#### `cacheDelete`

``` purescript
cacheDelete :: forall a. String -> ScreenCache a -> ScreenCache a
```


