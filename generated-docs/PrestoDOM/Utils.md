## Module PrestoDOM.Utils

#### `continue`

``` purescript
continue :: forall state action returnType. state -> Eval action returnType state
```

#### `exit`

``` purescript
exit :: forall state action returnType. returnType -> Eval action returnType state
```

#### `updateAndExit`

``` purescript
updateAndExit :: forall state action returnType. state -> returnType -> Eval action returnType state
```

#### `continueWithCmd`

``` purescript
continueWithCmd :: forall state action returnType. state -> Cmd action -> Eval action returnType state
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


