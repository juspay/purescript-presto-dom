## Module PrestoDOM.Events

#### `backPressHandlerImpl`

``` purescript
backPressHandlerImpl :: forall eff. PropEff eff
```

#### `event`

``` purescript
event :: forall a. EventType -> (Event -> Maybe a) -> Prop a
```

#### `makeEvent`

``` purescript
makeEvent :: forall eff a. (a -> PropEff eff) -> (Event -> PropEff eff)
```

#### `backPressHandler`

``` purescript
backPressHandler :: forall eff. (Event -> PropEff eff)
```

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


