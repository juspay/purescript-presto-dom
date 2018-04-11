module Utils where

import Prelude

import Control.Monad.Aff (Aff)
import Data.Either (Either(..))
import Data.Tuple (Tuple(..))


continue :: forall state a b eff. state -> Either a (Tuple state (Array (Aff eff b)))
continue state = Right (Tuple state [])

exit :: forall retAction state a b eff. retAction -> Either retAction (Tuple state (Array (Aff eff b)))
exit = Left

continueWithCmd :: forall state a b eff. state -> Array (Aff eff b) -> Either a (Tuple state (Array (Aff eff b)))
continueWithCmd state cmds = Right (Tuple state cmds)


