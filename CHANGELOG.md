# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.6.0] - 2019-05-11
### Added
- New type 'ScreenData' is added for storing required internal data in a Ref.
- New animation API.
- Native listView support.

### Removed
- Namespace for screen's unique name is not used anymore.

### Changed
- 'type PrestoDOM i w' is changed to 'type PrestoDOM'.
- initUI and initUIWithScreen now returns 'Ref ScreenData' in its callback.
    ```PureScript
    initUI
      :: (Either Error (Ref.Ref ScreenData) -> Effect Unit)
      -> Effect Canceler

    initUIWithScreen
      :: forall action state
       . Screen action state Unit
      -> (Either Error (Ref.Ref ScreenData) -> Effect Unit)
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


