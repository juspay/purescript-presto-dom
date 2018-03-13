module HomeScreen where

import Prelude

-- import Control.Monad.Aff (Aff)
-- import Control.Monad.State (StateT(..))
-- import PrestoDOM.Core (PrestoDOM)
-- import Unsafe.Coerce (unsafeCoerce)

-- data Action = UsernameChanged String
--             | PasswordChanged String
--             | SubmitClick

-- type State  =
--   {
--     username :: String
--   , password :: String
--   , errorMessage :: String
--   }

-- component :: forall e. Component Action State Unit e
-- component = { initialState, view, eval }
--   where
--     initialState _ = { username : "", password : "", errorMessage : "" }
--     eval (UsernameChanged username) = pure { username : "", password : "", errorMessage : "" }
--     eval (PasswordChanged password) = pure { username : "", password : "", errorMessage : "" }
--     eval SubmitClick = pure { username : "", password : "", errorMessage : "" }
--     view _ = unsafeCoerce unit

-- newtype DOM ev =  DOM ev

-- type Component ev st ip e =
--   {
--     initialState :: ip -> st
--   , view :: st -> DOM ev
--   , eval :: ev -> Aff e st
--   }

-- runUI :: forall ev st ip e. Component ev st ip e -> Aff e Unit
-- runUI = unsafeCoerce





