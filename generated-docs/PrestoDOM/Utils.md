## Module PrestoDOM.Utils

#### `continue`

``` purescript
continue :: forall state action retAction eff. state -> Eval eff action retAction state
```

#### `exit`

``` purescript
exit :: forall state action retAction eff. retAction -> Eval eff action retAction state
```

#### `updateAndExit`

``` purescript
updateAndExit :: forall state action retAction eff. state -> retAction -> Eval eff action retAction state
```

#### `continueWithCmd`

``` purescript
continueWithCmd :: forall state action retAction eff. state -> Cmd eff action -> Eval eff action retAction state
```

#### `concatPropsArrayImpl`

``` purescript
concatPropsArrayImpl :: forall a. Array a -> Array a -> Array a
```

#### `concatPropsArrayRight`

``` purescript
concatPropsArrayRight :: forall a. Array a -> Array a -> Array a
```

#### `concatPropsArrayLeft`

``` purescript
concatPropsArrayLeft :: forall a. Array a -> Array a -> Array a
```

#### `(<>>)`

``` purescript
infixr 5 concatPropsArrayRight as <>>
```

#### `(<<>)`

``` purescript
infixr 5 concatPropsArrayLeft as <<>
```


