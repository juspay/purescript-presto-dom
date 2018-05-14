## Module PrestoDOM.Core

#### `applyAttributes`

``` purescript
applyAttributes :: forall i eff. Element -> (Array (Prop i)) -> Eff eff (Array (Prop i))
```

#### `patchAttributes`

``` purescript
patchAttributes :: forall i eff. Element -> (Array (Prop i)) -> (Array (Prop i)) -> Eff eff (Array (Prop i))
```

#### `cleanupAttributes`

``` purescript
cleanupAttributes :: forall i eff. Element -> (Array (Prop i)) -> Eff eff Unit
```

#### `getLatestMachine`

``` purescript
getLatestMachine :: forall m a b eff. Eff eff (Step m a b)
```

#### `storeMachine`

``` purescript
storeMachine :: forall eff m a b. Step m a b -> Eff eff Unit
```

#### `getRootNode`

``` purescript
getRootNode :: forall eff. Eff eff Document
```

#### `setRootNode`

``` purescript
setRootNode :: forall eff. Eff eff Document
```

#### `insertDom`

``` purescript
insertDom :: forall a b eff. a -> b -> Eff eff Unit
```

#### `buildAttributes`

``` purescript
buildAttributes :: forall eff a. Element -> VDomMachine eff (Array (Prop a)) Unit
```

#### `spec`

``` purescript
spec :: forall i e. Document -> VDomSpec e (Array (Prop i)) Void
```

#### `patchAndRun`

``` purescript
patchAndRun :: forall t state i. state -> (state -> VDom (Array (Prop i)) Void) -> Eff t Unit
```

#### `initUIWithScreen`

``` purescript
initUIWithScreen :: forall action st eff. Screen action st eff Unit -> (Either Error Unit -> Eff (frp :: FRP, dom :: DOM | eff) Unit) -> Eff (frp :: FRP, dom :: DOM | eff) (Canceler (frp :: FRP, dom :: DOM | eff))
```

#### `initUI`

``` purescript
initUI :: forall eff. (Either Error Unit -> Eff (frp :: FRP, dom :: DOM | eff) Unit) -> Eff (frp :: FRP, dom :: DOM | eff) (Canceler (frp :: FRP, dom :: DOM | eff))
```

#### `runScreen'`

``` purescript
runScreen' :: forall action st eff retAction. Boolean -> Screen action st eff retAction -> (Either Error retAction -> Eff (frp :: FRP, dom :: DOM | eff) Unit) -> Eff (frp :: FRP, dom :: DOM | eff) (Canceler (frp :: FRP, dom :: DOM | eff))
```

#### `runScreen`

``` purescript
runScreen :: forall action st eff retAction. Screen action st eff retAction -> (Either Error retAction -> Eff (frp :: FRP, dom :: DOM | eff) Unit) -> Eff (frp :: FRP, dom :: DOM | eff) (Canceler (frp :: FRP, dom :: DOM | eff))
```

#### `mapDom`

``` purescript
mapDom :: forall i a b state eff w. ((a -> Eff (frp :: FRP | eff) Unit) -> state -> StrMap i -> PrestoDOM a w) -> (b -> Eff (frp :: FRP | eff) Unit) -> state -> (a -> b) -> Array (Tuple String i) -> PrestoDOM b w
```


