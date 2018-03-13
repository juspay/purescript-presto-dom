module Main where

import Prelude

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)
import DOM (DOM)
import FRP (FRP)
import LoginForm as LoginForm
import PrestoDOM.Core (runElm)

main :: forall eff. Eff ( frp :: FRP, dom :: DOM | eff ) (Eff ( frp :: FRP, dom :: DOM | eff) Unit)
main = do
  runElm LoginForm.component
