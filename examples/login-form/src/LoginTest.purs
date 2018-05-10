module LoginTest where

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
import PrestoDOM.Types.Core (PrestoDOM, Screen, Eval, Namespace(..), PropEff)
import PrestoDOM.Utils (continue, continueWithCmd, updateAndExit, exit)

data Action =
  SubmitClicked

type State =
  { errorMessage :: String
  , visibility :: Visibility
  }

initialState :: State
initialState =
  { errorMessage : "Yo Ho, Hoist the color High"
  , visibility : VISIBLE
  }

eval :: forall eff. Action -> State -> Eval eff Action Unit State
eval SubmitClicked state = updateAndExit (state {visibility = GONE}) unit
eval _ state = continue state


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
    , gravity CENTER
    , visibility state.visibility
    ]
    [ linearLayout
      [ height $ V 600
      , width $ V 400
      , background "#000000"
      , orientation VERTICAL
      , gravity CENTER
      ]
      [ linearLayout
          [ height $ V 10
          , width MATCH_PARENT
    	  , margin $ Margin 20 0 5 20
          ]
          []
      , linearLayout
        [ height $ V 150
        , width MATCH_PARENT
        , orientation VERTICAL
        , background "#ffff00"
    	, margin $ Margin 20 20 20 20
        , gravity CENTER
        ]
        [ linearLayout
          [ height $ V 50
          , width MATCH_PARENT
          , margin $ MarginHorizontal 20 20
          , background "#ffffff"
          ]
          []
        , linearLayout
          [ height $ V 50
          , width MATCH_PARENT
    	  , margin $ Margin 20 20 20 20
          , background "#00ffff"
          , gravity CENTER
          {-- , onClick push (const SubmitClicked) --}
          ]
          [
            textView
            [ width (V 80)
            , height (V 25)
            , text "YO"
            , textSize 28
            ]
          ]
        ]
      ]
    ]
