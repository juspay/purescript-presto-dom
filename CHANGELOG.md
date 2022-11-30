## [1.39.2](https://bitbucket.org/juspay/purescript-presto-dom/compare/v1.39.1...v1.39.2) (2022-11-30)


### Bug Fixes

* PICAF-10982: setting use stored div as true for second process ([5f1d171](https://bitbucket.org/juspay/purescript-presto-dom/commits/5f1d171b29f7c86dedd4370d94ab04049d036d8b))

## [1.39.1](https://bitbucket.org/juspay/purescript-presto-dom/compare/v1.39.0...v1.39.1) (2022-11-23)


### Bug Fixes

* PICAF-18053: compilation fix ([0c89b07](https://bitbucket.org/juspay/purescript-presto-dom/commits/0c89b071484d003d72c2bb909a37d657aa666d04))

# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.6.0] - 2019-05-11
### Added
- `type ScreenData` is added for storing required internal data in a Ref.
- New animation API.
- Native listView support.

### Removed
- Namespace for screen's unique name is not used anymore.

### Changed
- `type PrestoDOM i w` is changed to `type PrestoDOM`.
- initUI and initUIWithScreen now returns `Ref ScreenData` in its callback.
    
```PureScript
    initUI
      :: (Either Error (Ref.Ref ScreenData) -> Effect Unit)
      -> Effect Canceler

```
    
- runScreen (to be renamed to startScreen) and showScreen (to be renamed to startOverlay) takes two extra argument, Ref ScreenData and a type with Show and Eq instance which is used for unique identification of the Screen.
    
```PureScript
    runScreen
      :: forall action state returnType screenName
       . Show screenName
      => Eq screenName
      => Ref.Ref ScreenData
      -> screenName
      -> Screen action state returnType
      -> (Either Error returnType -> Effect Unit)
      -> Effect Canceler
```

### Deprecated
- runScreen : renamed to startScreen
- showScreen : renamed to startOverlay
- module GetChildProps and module SetChildProps are deprecated and will be removed in next version.
    
    old mapDom is renamed to mapDom_
    
    mapDom don't take `Array (Tuple String i)` and component's view function don't take `Object i` as there last argument.
    
    Now mapDom just apply the action with push

```PureScript
    mapDom
      :: forall a b state
       . ((a -> Effect Unit) -> state -> PrestoDOM)
      -> (b -> Effect Unit)
      -> state
      -> (a -> b)
      -> PrestoDOM
    mapDom view push state actionMap = view (push <<< actionMap) state
```
