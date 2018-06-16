module Main where

import Prelude

import Control.Monad.Aff (Aff, launchAff_, makeAff, delay, Milliseconds(..))
import Control.Monad.Aff.Console (log)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Ref (REF)
import Control.Monad.Eff.Console (CONSOLE, log) as C
import Control.Monad.Eff.Exception (EXCEPTION)
import DOM (DOM)
import FRP (FRP)
import LoginForm as LoginForm
import LoginTest as LoginTest
import SplashScreen as SplashScreen
import PrestoDOM.Core (runScreen, initUIWithScreen, initUI)
import PrestoDOM.Types.Core (Screen)

main :: forall eff. Eff ( frp :: FRP, dom :: DOM, console :: C.CONSOLE, ref :: REF | eff ) Unit
main = do
  _ <- launchAff_ do
     log "sojkhkk"
     _ <- makeAff (\cb -> initUI cb)
     log "yo oo oo"
     _ <- runUI LoginForm.screen "2"
     log "fooo"
     _ <- runUI LoginTest.screen "1"

     pure unit

  pure unit

{-- runUI --}
{--     :: forall action eff retAction st --}
{--      . Screen action st eff retAction --}
{--     -> String --}
{--     -> Aff (frp :: FRP, dom :: DOM, console :: C.CONSOLE | eff) Unit --}
runUI screen  txt = do
  _ <- makeAff (\cb -> runScreen screen cb)
  log $ "Completed " <> txt
