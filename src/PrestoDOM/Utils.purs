module PrestoDOM.Utils where

import Prelude

import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..))
import PrestoDOM.Types.Core (Eval, Cmd)


continue
  :: forall state action returnType
   . state
  -> Eval action returnType state
continue state = Right (Tuple state [])

exit
  :: forall state action returnType
   . returnType
  -> Eval action returnType state
exit = Left <<< Tuple Nothing

updateAndExit
  :: forall state action returnType
   . state
  -> returnType
  -> Eval action returnType state
updateAndExit state = Left <<< Tuple (Just state)

continueWithCmd
  :: forall state action returnType
   . state
  -> Cmd action
  -> Eval action returnType state
continueWithCmd state cmds = Right (Tuple state cmds)


foreign import concatPropsArrayImpl :: forall a. Array a -> Array a -> Array a


concatPropsArrayRight :: forall a. Array a -> Array a -> Array a
concatPropsArrayRight = concatPropsArrayImpl

concatPropsArrayLeft :: forall a. Array a -> Array a -> Array a
concatPropsArrayLeft = flip concatPropsArrayImpl

infixr 5 concatPropsArrayRight as <>>

infixr 5 concatPropsArrayLeft as <<>
