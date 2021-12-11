module Core3 where
  
import Prelude
import Data.Maybe (Maybe(..), fromMaybe)


sanitiseNamespace :: Maybe String -> Effect String
sanitiseNamespace maybeNS = do
  let ns = fromMaybe "default" maybeNS
  pure ns
