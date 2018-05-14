## Module PrestoDOM.Core

#### `emitter`

``` purescript
emitter :: forall a eff. a -> Eff eff Unit
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
setRootNode :: forall a eff. Maybe a -> Eff eff Document
```

#### `insertDom`

``` purescript
insertDom :: forall a b eff. a -> b -> Eff eff Unit
```

#### `saveScreenNameImpl`

``` purescript
saveScreenNameImpl :: forall eff. Maybe Namespace -> Eff eff Unit
```

#### `getPrevScreen`

``` purescript
getPrevScreen :: forall eff. Eff eff (Maybe Namespace)
```

#### `spec`

``` purescript
spec :: forall e. Document -> VDomSpec (ref :: REF, frp :: FRP, dom :: DOM | e) (Array (Prop (PropEff e))) Void
```

#### `logger`

``` purescript
logger :: forall a eff. (a -> Eff (ref :: REF, dom :: DOM | eff) Unit)
```

#### `patchAndRun`

``` purescript
patchAndRun :: forall t i. VDom (Array (Prop i)) Void -> Eff t Unit
```

#### `initUIWithScreen`

``` purescript
initUIWithScreen :: forall action st eff. Screen action st eff Unit -> (Either Error Unit -> Eff (ref :: REF, frp :: FRP, dom :: DOM | eff) Unit) -> Eff (ref :: REF, frp :: FRP, dom :: DOM | eff) (Canceler (ref :: REF, frp :: FRP, dom :: DOM | eff))
```

#### `initUI`

``` purescript
initUI :: forall eff. (Either Error Unit -> Eff (ref :: REF, frp :: FRP, dom :: DOM | eff) Unit) -> Eff (ref :: REF, frp :: FRP, dom :: DOM | eff) (Canceler (ref :: REF, frp :: FRP, dom :: DOM | eff))
```

#### `runScreen`

``` purescript
runScreen :: forall action st eff retAction. Screen action st eff retAction -> (Either Error retAction -> Eff (ref :: REF, frp :: FRP, dom :: DOM | eff) Unit) -> Eff (ref :: REF, frp :: FRP, dom :: DOM | eff) (Canceler (ref :: REF, frp :: FRP, dom :: DOM | eff))
```

#### `saveScreenName`

``` purescript
saveScreenName :: forall a w eff. VDom a w -> Eff eff (Maybe Namespace)
```

#### `mapDom`

``` purescript
mapDom :: forall i a b state eff w. ((a -> PropEff eff) -> state -> StrMap i -> PrestoDOM (PropEff eff) w) -> (b -> PropEff eff) -> state -> (a -> b) -> Array (Tuple String i) -> PrestoDOM (PropEff eff) w
```


