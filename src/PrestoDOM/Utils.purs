module PrestoDOM.Utils where

import Prelude

import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..))
import PrestoDOM.Types.Core (Eval, Cmd)
import Effect(Effect)
import Effect.Ref as Ref
import Effect.Timer as Timer
import Tracker (trackAction)
import Tracker.Types (Level(..), Subcategory(..)) as T
import Tracker.Labels (Label(..)) as L
import Foreign.Class (encode)


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

logAction :: Ref.Ref (Maybe Timer.TimeoutId) -> String -> String -> Effect Unit 
logAction timerRef previousAction currentAction = do 
  timer <- Ref.read timerRef
  if(previousAction == currentAction) then do -- current == previous, if previous log isn't already logged cancell it and setTimeout for current one.
      case timer of 
        Just t -> Timer.clearTimeout t
        Nothing -> pure unit   
      tid <- Timer.setTimeout 5000 $ loggerFunction timerRef currentAction 
      Ref.write (Just tid) timerRef
    else
      case timer of 
        Just t -> do -- current != previous, timer running, log current and last log
          Timer.clearTimeout t 
          loggerFunction timerRef currentAction 
          loggerFunction timerRef previousAction
        Nothing -> do -- current != previous, timer NOT running, set timeout for current log
          tid <- Timer.setTimeout 5000 $ loggerFunction timerRef currentAction
          Ref.write (Just tid) timerRef 

loggerFunction :: Ref.Ref (Maybe Timer.TimeoutId) -> String -> Effect Unit 
loggerFunction ref action = do 
  trackAction T.User T.Info L.EVAL "data" $ encode action
  Ref.write Nothing ref -- set ref to nothing after done.