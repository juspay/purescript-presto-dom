module Core3 where
  
import Prelude
import Data.Maybe (Maybe(..), fromMaybe)


sanitiseNamespace :: Maybe String -> Effect String
sanitiseNamespace maybeNS = do
  let ns = fromMaybe "default" maybeNS
  pure ns

initUIWithNameSpace :: String -> Maybe String -> Effect Unit
initUIWithNameSpace namespace id = do
  setUpBaseState namespace $ encode id
  EFn.runEffectFn1 render namespace

initUIWithScreen ::
  forall action state returnType.
  String -> Maybe String -> ScopedScreen action state returnType -> Aff Unit
initUIWithScreen namespace id screen = do
  liftEffect $ initUIWithNameSpace namespace id
  let myDom = screen.view (\_ -> pure unit) screen.initialState
  ns <- liftEffect $ sanitiseNamespace screen.parent
  machine <- liftEffect $ EFn.runEffectFn1 (buildVDom (spec ns screen.name)) myDom
  insertState <- liftEffect $ EFn.runEffectFn4 insertDom ns screen.name (extract machine) false
  domAllOut <- domAll screen (unsafeToForeign {}) insertState.dom
  liftEffect $ EFn.runEffectFn1 addViewToParent (insertState {dom = domAllOut})
