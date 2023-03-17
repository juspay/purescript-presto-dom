module UI.Controller where

import Prelude

import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Data.Tuple (Tuple(..))
import Data.Tuple.Nested ((/\))
import Debug.Trace (spy)
import PrestoDOM (Eval, continue, exit)
import Type.Data.Boolean (kind Boolean)

newtype State 
  = State {
      patch :: Boolean
    , count :: Int
    }

data ExitAction
  = BackPress
  | ScreenA
  | ScreenB
  | ScreenC
  | ScreenD
  | ShowLoader
  | ShowPopUP
  | Click

derive instance genericExitAction :: Generic ExitAction _
instance showExitAction :: Show ExitAction where
  show ScreenA = "Run  A"
  show ScreenB = "Show B"
  show ScreenC = "Run  C"
  show ScreenD = "Run  D"
  show ShowLoader = "Show E"
  show a = genericShow a

eval :: ExitAction -> State ->  Eval ExitAction (Tuple Int ExitAction) State
eval Click (State state) = continue $ State $ state {patch = not state.patch, count = state.count + 1}
eval action (State state) = do
  let _ = spy "ACTION" action
  exit $ state.count /\ action