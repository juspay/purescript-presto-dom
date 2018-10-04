module Main where

import Prelude

import Effect (Effect)
import Effect.Aff (Aff, launchAff_, makeAff, delay, Milliseconds(..))
import Effect.Class.Console (log)
import View.LoginForm as LoginForm
import PrestoDOM.Core (runScreen, initUI)
import PrestoDOM.Types.Core (Screen)

main :: forall eff. Effect Unit
main = do
  _ <- launchAff_ do
     _ <- makeAff (\cb -> initUI cb)
     _ <- runUI LoginForm.screen "2"

     pure unit

  pure unit

runUI :: forall a r s. Screen a s r -> String -> Aff Unit
runUI screen  txt = do
  _ <- makeAff (\cb -> runScreen screen cb)
  log $ "Completed " <> txt
