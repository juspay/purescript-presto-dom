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
import Data.String(contains, Pattern(..))
import Data.Tuple (Tuple(..))
import Effect.Uncurried as EFn

import PrestoDOM.Types.Core (class Loggable, performLog, Eval, Cmd)
import Effect(Effect)
import Effect.Ref as Ref
import Effect.Timer as Timer
import Foreign(Foreign)

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
foreign import debounce :: (String -> Foreign -> Effect Unit) -> String -> Foreign -> Effect Unit


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

timeoutDelay :: Int 
timeoutDelay = 300

clearTimeout :: Ref.Ref (Maybe Timer.TimeoutId) -> Effect Unit 
clearTimeout timerRef = do 
  timer <- Ref.read timerRef 
  case timer of 
    Just t -> Timer.clearTimeout t
    Nothing -> pure unit 

logAction :: forall a. Loggable a => Show a => Ref.Ref (Maybe Timer.TimeoutId) -> (Maybe a) -> (Maybe a) -> Boolean -> Effect Unit 
logAction timerRef (Just prevAct) (Just currAct) true = do -- logNow without waiting
  clearTimeout timerRef 
  loggerFunction timerRef prevAct 
  loggerFunction timerRef currAct
logAction timerRef (Just prevAct) (Just currAct) logNow = do
  let previousAction = show prevAct 
      currentAction = show currAct 
  timer <- Ref.read timerRef
  if(previousAction == currentAction) then do -- current == previous, if previous log isn't already logged cancell it and setTimeout for current one.
      clearTimeout timerRef 
      tid <- Timer.setTimeout timeoutDelay $ loggerFunction timerRef currAct
      Ref.write (Just tid) timerRef
    else
      case timer of 
        Just t -> do -- current != previous, timer running, log current and last log
          Timer.clearTimeout t 
          loggerFunction timerRef prevAct
          loggerFunction timerRef currAct
        Nothing -> do -- current != previous, timer NOT running, set timeout for current log
          tid <- Timer.setTimeout timeoutDelay $ loggerFunction timerRef currAct
          Ref.write (Just tid) timerRef 
logAction timerRef Nothing (Just currAct) logNow = do
  tid <- Timer.setTimeout timeoutDelay $ loggerFunction timerRef currAct
  Ref.write (Just tid) timerRef 
logAction _ _ _ _ = pure unit

loggerFunction :: forall a. Loggable a => Show a => Ref.Ref (Maybe Timer.TimeoutId) -> a -> Effect Unit 
loggerFunction ref action = do 
  performLog action
  Ref.write Nothing ref-- set ref to nothing after done.
