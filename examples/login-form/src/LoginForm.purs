module LoginForm where

import Prelude
import PrestoDOM.Elements.Elements
import PrestoDOM.Properties
import PrestoDOM.Types.DomAttributes

import Control.Monad.Aff (Aff)
import Control.Monad.Eff (Eff)
import DOM (DOM)
import Data.Either (Either(..))
import Data.Tuple (Tuple(..))
import FRP (FRP)
import FRP.Behavior (sample_, step, unfold)
import FRP.Event (create, subscribe)
import FormField as FormField
import Halogen.VDom (buildVDom, extract)
import PrestoDOM.Core (mapDom, getRootNode, insertDom, patchAndRun, spec, storeMachine)
import PrestoDOM.Events (onClick)
import PrestoDOM.Types.Core (PrestoDOM, Screen, Eval)
import PrestoDOM.Utils (continue, continueWithCmd, updateAndExit, exit)

data Action =
  Username FormField.Action
  | Password FormField.Action
  | SubmitClicked

type State =
  { errorMessage :: String
  , usernameState :: FormField.State
  , passwordState :: FormField.State
  }

initialState :: State
initialState =
  { errorMessage : ""
  , usernameState : (FormField.initialState "username")
  , passwordState : (FormField.initialState "password")
  }

eval :: forall eff. Action -> State -> Eval eff Action Unit State
eval (Username action) state = continue state { usernameState = FormField.eval action state.usernameState }
eval (Password action) state = continue state { passwordState = FormField.eval action state.passwordState }
eval SubmitClicked state =
    if state.passwordState.value == "blueberry" && state.usernameState.value /= ""
        then exit unit
        else (continueWithCmd (state { errorMessage = "Your account is blocked" }) [ (pure $ Username $ FormField.TextChanged "evalaction")])


screen :: forall eff. Screen Action State eff Unit
screen =
  {
    initialState
  , view
  , eval
  }

-- TODO : Make push implicit
view :: forall i w eff. (Action -> Eff (frp :: FRP | eff) Unit) -> State -> PrestoDOM Action w
view push state =
  linearLayout
    [ height MATCH_PARENT
    , width MATCH_PARENT
    , background "#323232"
    , gravity CENTER
    ]
    [ linearLayout
      [ height $ V 600
      , width $ V 400
      , background "#000000"
      , orientation VERTICAL
      , gravity CENTER
      ]
      [ (mapDom FormField.view push state.usernameState Username [])
      , (mapDom FormField.view push state.passwordState Password [])
      , linearLayout
        [ height $ V 150
        , width MATCH_PARENT
        , orientation VERTICAL
        , background "#eae212"
        , gravity CENTER
        ]
        [ textView
          [ height $ V 50
          , color "#000000"
          , background "#ffffff"
          , width MATCH_PARENT
          , text state.errorMessage
          ]
        , linearLayout
          [ height $ V 50
          , width MATCH_PARENT
          , margin $ Margin 20 20 20 20
          , background "#969696"
          , gravity CENTER
          , onClick push (const SubmitClicked)
          ]
          [
            textView
            [ width (V 80)
            , height (V 25)
            , text "Submit"
            , color "#007700"
            , textSize 28
            ]
          ]
        ]
      ]
    ]
