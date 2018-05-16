module FormField where

import Prelude
import PrestoDOM.Elements.Elements
import PrestoDOM.Properties
import PrestoDOM.Types.DomAttributes

import Control.Monad.Eff (Eff)
import Data.StrMap (StrMap)
import DOM (DOM)
import FRP (FRP)
import FRP.Behavior (sample_, step, unfold)
import FRP.Event (create, subscribe)
import Halogen.VDom (buildVDom, extract)
import PrestoDOM.Events (onChange)
import PrestoDOM.Types.Core (PrestoDOM, PropEff)

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


view :: forall i w eff. (Action -> PropEff eff) -> State -> StrMap String -> PrestoDOM (PropEff eff) w
view push state _ =
  linearLayout
    [ height $ V 150
    , background "#123eee"
    , width MATCH_PARENT
    , orientation VERTICAL
    , margin $ Margin 20 20 20 20
    ]
   -- [ linearLayout [height MATCH_PARENT, width MATCH_PARENT] -- linear
    [ textView
        [ height $ V 30
        , width MATCH_PARENT
        , margin $ Margin 10 20 20 20
        , background "#eee123"
        , color "#000000"
        , text state.text
        , textSize 28
        ]
    ,  editText
            [ height (V 40)
            , width MATCH_PARENT
            , margin $ Margin 10 10 10 10
            , background "#ffffff"
            , textSize 20
            , color "#00ff00"
            , onChange push TextChanged
            ]
  --  ] -- linear
    ]
