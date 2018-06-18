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
import PrestoDOM.Events (onClick, attachTimer)
import PrestoDOM.Types.Core (PrestoDOM, Screen, Eval, Namespace(..), PropEff)
import PrestoDOM.Utils (continue, continueWithCmd, updateAndExit, exit)

data Action =
  Username FormField.Action
  | Password FormField.Action
  | TimerAction
  | SubmitClicked
  | SubmitClicked2

type State =
  { errorMessage :: String
  , toggle :: Boolean
  , timer :: Int
  , usernameState :: FormField.State
  , passwordState :: FormField.State
  }

initialState :: State
initialState =
  { errorMessage : ""
  , toggle : true
  , timer : 120
  , usernameState : (FormField.initialState "username")
  , passwordState : (FormField.initialState "password")
  }

eval :: forall eff. Action -> State -> Eval eff Action Unit State
eval (Username action) state = continue state { usernameState = FormField.eval action state.usernameState }
eval TimerAction state = continue $
    case (state.timer < 0) of
         false -> state {timer = state.timer - 1}
         true -> state {timer = 0}
eval (Password action) state = let t = if state.passwordState.value == "turn" then false else true in continue state { passwordState = FormField.eval action state.passwordState, toggle = t }
eval SubmitClicked2 state = continue state { errorMessage = "Yes, yo hoo", toggle = true }
eval SubmitClicked state = continue state { errorMessage = "Your account is blocked", toggle = false }
    {-- if state.passwordState.value == "blueberry" && state.usernameState.value /= "" --}
    {--     then exit unit --}
    {--     else (continueWithCmd (state { errorMessage = "Your account is blocked" }) [ (pure $ Username $ FormField.TextChanged "evalaction")]) --}


screen :: forall eff. Screen Action State eff Unit
screen =
  {
    initialState
  , view
  , eval
  }

-- TODO : Make push implicit
view :: forall i w eff. (Action -> PropEff eff) -> State -> PrestoDOM (PropEff eff) w
view push state =
  linearLayout_ (Namespace "loginForm")
    [ height MATCH_PARENT
    , width MATCH_PARENT
    , background "#323232"
    , attachTimer push (const TimerAction)
    , gravity CENTER
    ]
    [ linearLayout
    case state.toggle of
                 true -> ([ height $ V 600
                          , width $ V 400
                          {-- , background "#000000" --}
                          , orientation VERTICAL
                          , gravity CENTER
                          ])
                 false -> ([ height $ V 600
                          , width $ V 400
                          , background "#000000"
                          , orientation VERTICAL
                          , onClick push (const SubmitClicked)
                          {-- , gravity CENTER --}
                          ])
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
          {-- , onClick push (const SubmitClicked) --}
          , text $ show state.timer <> " sec" <> state.passwordState.value <> state.errorMessage
          ]
        , linearLayout
            case state.toggle of
                 true ->   ([ height $ V 50
                            , width MATCH_PARENT
                            , margin $ Margin 20 20 20 20
                            , background "#969696"
                            , gravity CENTER
                            , onClick push (const SubmitClicked)
                            ])
                 false ->  ([ height $ V 50
                            , width MATCH_PARENT
                            , margin $ Margin 20 20 20 20
                            , background "#969696"
                            , gravity CENTER
                            , onClick push (const SubmitClicked2)
                            ])

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
