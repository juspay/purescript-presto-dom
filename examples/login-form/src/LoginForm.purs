module LoginForm where

import Prelude
import PrestoDOM.Elements.Elements
import PrestoDOM.Properties
import PrestoDOM.Types.DomAttributes

import Control.Monad.Aff (Aff)
import Control.Monad.Eff (Eff)
import DOM (DOM)
import Data.Either (Either(..))
import Data.Exists (Exists, mkExists, runExists)
import Data.Tuple (Tuple(..))
import FRP (FRP)
import FRP.Behavior (sample_, step, unfold)
import FRP.Event (create, subscribe)
import FormField as FormField
import Halogen.VDom (buildVDom, extract)
import PrestoDOM.Core (mapDom, getRootNode, insertDom, patchAndRun, spec, storeMachine, Thunk(..))
import PrestoDOM.Events (onClick)
import PrestoDOM.Types.Core (PrestoDOM, Screen, Eval, Namespace(..), PropEff)
import PrestoDOM.Utils (continue, continueWithCmd, updateAndExit, exit)
import Widget.CanvasJS.Charts as W


data Action =
  Username FormField.Action
  | Password FormField.Action
  | SubmitClicked
  | SubmitClicked2

type State =
  { errorMessage :: String
  , toggle :: Boolean
  , usernameState :: FormField.State
  , passwordState :: FormField.State
  }

initialState :: State
initialState =
  { errorMessage : ""
  , toggle : true
  , usernameState : (FormField.initialState "username")
  , passwordState : (FormField.initialState "password")
  }

eval :: forall eff. Action -> State -> Eval eff Action Unit State
eval (Username action) state = continue state { usernameState = FormField.eval action state.usernameState }
eval (Password action) state = let t = if state.passwordState.value == "turn" then false else true in continue state { passwordState = FormField.eval action state.passwordState, toggle = t }
eval SubmitClicked2 state = continue state { errorMessage = "Yes, yo hoo", toggle = true }
eval SubmitClicked state = continue state { errorMessage = "Your account is blocked", toggle = false }
    {-- if state.passwordState.value == "blueberry" && state.usernameState.value /= "" --}
    {--     then exit unit --}
    {--     else (continueWithCmd (state { errorMessage = "Your account is blocked" }) [ (pure $ Username $ FormField.TextChanged "evalaction")]) --}


screen :: forall eff. Screen Action State eff Unit (Exists (Thunk eff))
screen =
  {
    initialState
  , view
  , eval
  }

-- TODO : Make push implicit
view :: forall i w eff. (Action -> PropEff eff) -> State -> PrestoDOM (PropEff eff) (Exists (Thunk eff))
view push state =
  linearLayout_ (Namespace "loginForm")
    [ height MATCH_PARENT
    , width MATCH_PARENT
    , background "#323232"
    , gravity CENTER
    ]
    [ linearLayout
			[ height $ V 600
			, width $ V 1600
			, orientation VERTICAL
    	, gravity CENTER
			]
			[ W.siteTraffic { viewID : "canvasJS", cData : W.chartData }  ]
    ]
