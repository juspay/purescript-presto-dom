module Utils where

import Prelude

import Control.Monad.Aff (Aff)
import Data.Either (Either(..))
import Data.Tuple (Tuple(..))
import PrestoDOM.Types.Core (Eval, Cmd)


continue :: forall state action retAction eff. state -> Eval eff action retAction state
continue state = Right (Tuple state [])

exit :: forall retAction state action retAction eff. retAction -> Eval eff action retAction state
exit = Left

continueWithCmd :: forall state action retAction eff. state -> Cmd eff action -> Eval eff action retAction state
continueWithCmd state cmds = Right (Tuple state cmds)
