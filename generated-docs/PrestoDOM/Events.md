## Module PrestoDOM.Events

#### `onClick`

``` purescript
onClick :: forall a. (a -> Effect Unit) -> (Unit -> a) -> Prop (Effect Unit)
```

#### `onChange`

``` purescript
onChange :: forall a. (a -> Effect Unit) -> (String -> a) -> Prop (Effect Unit)
```

#### `attachBackPress`

``` purescript
attachBackPress :: forall a. (a -> Effect Unit) -> (Unit -> a) -> Prop (Effect Unit)
```

#### `onMenuItemClick`

``` purescript
onMenuItemClick :: forall a. (a -> Effect Unit) -> (Int -> a) -> Prop (Effect Unit)
```

#### `onBackPressed`

``` purescript
onBackPressed :: forall a b. (a -> Effect Unit) -> (b -> a) -> Prop (Effect Unit)
```

#### `onNetworkChanged`

``` purescript
onNetworkChanged :: forall a b. (a -> Effect Unit) -> (b -> a) -> Prop (Effect Unit)
```

#### `afterRender`

``` purescript
afterRender :: forall a b. (a -> Effect Unit) -> (b -> a) -> Prop (Effect Unit)
```


