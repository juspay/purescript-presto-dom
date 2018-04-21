module LoginForm where

import Prelude
import PrestoDOM.Elements.Elements
import PrestoDOM.Properties
import PrestoDOM.Types.DomAttributes

import Control.Monad.Eff (Eff)
import DOM (DOM)
import Data.Either (Either(..))
import FRP (FRP)
import FRP.Behavior (sample_, step, unfold)
import FRP.Event (create, subscribe)
import FormField as FormField
import Halogen.VDom (buildVDom, extract)
import PrestoDOM.Core (mapDom, getRootNode, insertDom, patchAndRun, spec, storeMachine)
import PrestoDOM.Events (onClick)
import PrestoDOM.Types.Core (PrestoDOM, Screen)

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

eval :: Action -> State -> Either Unit State
eval (Username action) state = Right $ state { usernameState = FormField.eval action state.usernameState }
eval (Password action) state = Right $ state { passwordState = FormField.eval action state.passwordState }
eval SubmitClicked state =
    if state.passwordState.value == "blueberry" && state.usernameState.value /= ""
        then (Left unit)
        else (Right $ state { errorMessage = "Your account is blocked" })


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
          , margin "20,20,20,20"
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
