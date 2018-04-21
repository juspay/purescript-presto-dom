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
import PrestoDOM.Types.Core (PrestoDOM, Screen)

data Action =
  SubmitClicked

type State =
  { errorMessage :: String
  }

initialState :: State
initialState =
  { errorMessage : "Yo Ho, Hoist the color High"
  }

eval :: Action -> State -> Either Unit State
eval SubmitClicked state = Left unit
eval _ state = Right state


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
      [ linearLayout
          [ height $ V 10
          , width MATCH_PARENT
          , margin "20,0,5,10"
          ]
          []
      , linearLayout
        [ height $ V 150
        , width MATCH_PARENT
        , orientation VERTICAL
        , margin "20,20,20,20"
        , gravity CENTER
        ]
        [ linearLayout
          [ height $ V 50
          , width MATCH_PARENT
          , margin "20,0,20,0"
          , text state.errorMessage
          ]
          []
        , linearLayout
          [ height $ V 50
          , width MATCH_PARENT
          , margin "20,50,20,20"
          , background "#969696"
          , gravity CENTER
          , onClick push (const SubmitClicked)
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
