## Module PrestoDOM.Core

#### `ScreenData`

``` purescript
type ScreenData = { root :: Document, screenStack :: ScreenStack Int, screenCache :: ScreenCache Int, currentScreen :: Maybe (Tuple String Int), currentOverlay :: Maybe (Tuple String Int), machines :: Object (Step (VDom (Array (Prop (Effect Unit))) (Thunk PrestoWidget (Effect Unit))) Node) }
```

#### `runScreen`

``` purescript
runScreen :: forall action state returnType screenName. Show screenName => Eq screenName => Ref ScreenData -> screenName -> Screen action state returnType -> (Either Error returnType -> Effect Unit) -> Effect Canceler
```

#### `showScreen`

``` purescript
showScreen :: forall action state returnType screenName. Show screenName => Eq screenName => Ref ScreenData -> screenName -> Screen action state returnType -> (Either Error returnType -> Effect Unit) -> Effect Canceler
```

#### `initUI`

``` purescript
initUI :: (Either Error (Ref ScreenData) -> Effect Unit) -> Effect Canceler
```

#### `initUIWithScreen`

``` purescript
initUIWithScreen :: forall action state. Screen action state Unit -> (Either Error (Ref ScreenData) -> Effect Unit) -> Effect Canceler
```

#### `mapDom`

``` purescript
mapDom :: forall i a b state. ((a -> Effect Unit) -> state -> Object i -> PrestoDOM) -> (b -> Effect Unit) -> state -> (a -> b) -> Array (Tuple String i) -> PrestoDOM
```


