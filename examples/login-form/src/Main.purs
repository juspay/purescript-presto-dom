module Main where

import Prelude

import Control.Monad.Aff (Aff, launchAff, makeAff)
import Control.Monad.Aff.Console (log)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log) as C
import Control.Monad.Eff.Exception (EXCEPTION)
import Control.Monad.Eff.Timer as T
import DOM (DOM)
import FRP (FRP)
import LoginForm as LoginForm
import LoginTest as LoginTest
import SplashScreen as SplashScreen
import PrestoDOM.Core (runScreen, initScreen)
import PrestoDOM.Types.Core (Screen)

main :: forall eff. Eff ( frp :: FRP, dom :: DOM, timer :: T.TIMER, console :: C.CONSOLE, exception :: EXCEPTION | eff ) Unit
main = do
  -- _ <- launchAff $ makeAff (\err sc -> initScreen SplashScreen.view sc)
  _ <- launchAff do
     log "sojkhkk"
     _ <- makeAff (\err sc -> initScreen SplashScreen.view sc 1000)
     -- void $ T.setTimeout 1000 (C.log "splash timeout")
     log "yo oo oo"
     _ <- runUI LoginForm.screen "2"
     log "fooo"
     _ <- runUI LoginTest.screen "1"

     pure unit
  {-- void $ T.setTimeout 10000 do --}
  {--    C.log "splash timeout" --}

  pure unit

  {-- void $ T.setTimeout 10000 do --}
  {--    C.log "splash timeout" --}
 -- runUI :: forall action eff retAction st. Screen action st eff retAction
--          -> Aff (frp :: FRP, dom :: DOM, console :: CONSOLE | eff) Unit




runUI screen  txt = do
  _ <- makeAff (\err sc -> runScreen screen sc)
  log $ "Completed " <> txt
