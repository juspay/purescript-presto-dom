module PrestoDOM.Utils
  ( continue
  , exit
  , updateAndExit
  , continueWithCmd
  , concatPropsArrayRight
  , concatPropsArrayLeft
  , (<>>)
  , (<<>)
  , storeToWindow
  , getFromWindow
  )where

import Prelude

import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..))
import Effect (Effect)
import Effect.Uncurried as EFn
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

foreign import storeToWindow_ :: forall a. EFn.EffectFn2 String a Unit
foreign import getFromWindow_ :: forall a. String -> (a -> Maybe a) -> (Maybe a) -> a

storeToWindow :: forall a. String -> a -> Effect Unit
storeToWindow = EFn.runEffectFn2 storeToWindow_

getFromWindow :: forall a. String ->  Maybe a
getFromWindow key = getFromWindow_ key Just Nothing
