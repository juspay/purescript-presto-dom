## Module PrestoDOM.Core

#### `runScreen`

``` purescript
runScreen :: forall action state returnType. Screen action state returnType -> (Either Error returnType -> Effect Unit) -> Effect Canceler
```

#### `showScreen`

``` purescript
showScreen :: forall action state returnType. Screen action state returnType -> (Either Error returnType -> Effect Unit) -> Effect Canceler
```

#### `mapDom`

``` purescript
mapDom :: forall i a b state w. ((a -> Effect Unit) -> state -> Object i -> PrestoDOM (Effect Unit) w) -> (b -> Effect Unit) -> state -> (a -> b) -> Array (Tuple String i) -> PrestoDOM (Effect Unit) w
```


