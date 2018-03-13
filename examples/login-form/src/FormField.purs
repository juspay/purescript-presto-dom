module FormField where

import Prelude
import PrestoDOM.Core
import PrestoDOM.Elements
import PrestoDOM.Events
import PrestoDOM.Properties
import PrestoDOM.Types

import Control.Monad.Eff (Eff)
import DOM (DOM)
import FRP (FRP)
import FRP.Behavior (sample_, step, unfold)
import FRP.Event (create, subscribe)
import Halogen.VDom (buildVDom, extract)
import PrestoDOM.Util (Component, getRootNode, insertDom, patchAndRun, spec, storeMachine)


data Action = TextChanged String
type Label = String

type State =
  { text :: String
  , value :: String
  }

initialState :: Label -> State
initialState label = { text : label , value : "" }

eval :: Action -> State -> State
eval (TextChanged value) state = state { value = value }

component :: forall i eff. Component Action State eff
component =
  {
    initialState : initialState "Label"
  , view
  , eval
  }

view :: forall i w eff. (Action -> Eff (frp :: FRP | eff) Unit) -> State -> PrestoDOM Action w
view push state =
  linearLayout
    [ height $ V 150
    , width Match_Parent
    , orientation "vertical"
    , margin "20,20,20,20"
    ]
    [ linearLayout
        [ height $ V 30
        , width Match_Parent
        , margin "10,20,20,20"
        , text state.text
        , textSize "28"
        ]
        []
    , linearLayout
        []
        [ editText
        [ height (V 40)
        , width Match_Parent
        , margin "10,10,10,10"
        , textSize "20"
        , name "name"
        , color "#00000"
        , text state.value
        , onChangeT push TextChanged
        ]
        ]
    ]
