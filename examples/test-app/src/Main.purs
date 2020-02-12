module Main where

import Prelude

import Control.Monad.State (evalStateT)
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Aff.AVar (new)
import Effect.Aff.Class (liftAff)
import Effect.Class (liftEffect)
import Foreign.Object (empty)
import Presto.Core.Language.Runtime.Interpreter (PermissionRunner(..), Runtime(..), run)
import Presto.Core.Types.Permission (PermissionStatus(..))
import Core as Core

main :: Effect Unit
main =
  let runtime = Runtime (const $ pure "") 
                        (PermissionRunner (const $ pure PermissionGranted ) (const $ pure [])) 
                        (const $ liftAff $ liftEffect $ pure "")
      launchFlow = run runtime Core.flow
  in
  launchAff_ $ new empty >>= evalStateT launchFlow