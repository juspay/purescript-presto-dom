## [1.41.3](https://ssh.bitbucket.juspay.net/picaf/purescript-presto-dom/compare/v1.41.2...v1.41.3) (2023-01-24)


### Bug Fixes

* PICAF-19321: life cycle id fix ([942a9f5](https://ssh.bitbucket.juspay.net/picaf/purescript-presto-dom/commit/942a9f50b0cec4a14a5b448d73335f8915a40150))

## [1.41.2](https://bitbucket.org/juspay/purescript-presto-dom/compare/v1.41.1...v1.41.2) (2023-01-10)


### Bug Fixes

* PICAF-18952: refactoring JS changes to make PS15 PR easy to review ([f2f50af](https://bitbucket.org/juspay/purescript-presto-dom/commits/f2f50afcef222c923a92e0bb35a6a429cd70d83e))

## [1.41.1](https://bitbucket.org/juspay/purescript-presto-dom/compare/v1.41.0...v1.41.1) (2023-01-10)


### Bug Fixes

* PICAF-16909: Exposing decodeInterpolatorUtil function ([29be380](https://bitbucket.org/juspay/purescript-presto-dom/commits/29be380919a521a5b26e5445b25fc5a962a90b7c))

# [1.41.0](https://bitbucket.org/juspay/purescript-presto-dom/compare/v1.40.0...v1.41.0) (2022-12-29)


### Features

* PICAF-16521: added mouseEventOnClick ([471b0ad](https://bitbucket.org/juspay/purescript-presto-dom/commits/471b0ad80b47ea711b29a02519d63d7f7b023a76))

# [1.40.0](https://bitbucket.org/juspay/purescript-presto-dom/compare/v1.39.3...v1.40.0) (2022-12-29)


### Bug Fixes

* PICAF-18685: corrected the log sequence ([0d450e5](https://bitbucket.org/juspay/purescript-presto-dom/commits/0d450e569251a7ce42e7b2dfd34ac746e24e671e))


### Features

* PICAF-16277: added a prop for framerate ([d4888f1](https://bitbucket.org/juspay/purescript-presto-dom/commits/d4888f1390927df2bd2292eb94c9982dc2684263))

## [1.39.4](https://bitbucket.org/juspay/purescript-presto-dom/compare/v1.39.3...v1.39.4) (2022-12-23)


### Bug Fixes

* PICAF-18685: corrected the log sequence ([0d450e5](https://bitbucket.org/juspay/purescript-presto-dom/commits/0d450e569251a7ce42e7b2dfd34ac746e24e671e))

## [1.39.3](https://bitbucket.org/juspay/purescript-presto-dom/compare/v1.39.2...v1.39.3) (2022-12-02)


### Bug Fixes

* PICAF-10982: Added log line to check ssr support ([5e977f4](https://bitbucket.org/juspay/purescript-presto-dom/commits/5e977f43ec4b2c1089a5624bc101066b2088f4a5))

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
