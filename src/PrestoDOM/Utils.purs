module PrestoDOM.Utils where

import Prelude

import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..))
import PrestoDOM.Types.Core (Eval, Cmd)


continue :: forall state action retAction eff. state -> Eval eff action retAction state
continue state = Right (Tuple state [])

exit :: forall state action retAction eff. retAction -> Eval eff action retAction state
exit = Left <<< Tuple Nothing

updateAndExit :: forall state action retAction eff. state -> retAction -> Eval eff action retAction state
updateAndExit state = Left <<< Tuple (Just state)

continueWithCmd :: forall state action retAction eff. state -> Cmd eff action -> Eval eff action retAction state
continueWithCmd state cmds = Right (Tuple state cmds)
