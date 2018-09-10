module View.FormField where

import Prelude

import Effect (Effect)

import Foreign.Object (Object)
import PrestoDOM.Elements.Elements
import PrestoDOM.Properties
import PrestoDOM.Types.DomAttributes
import PrestoDOM.Events (onChange)
import PrestoDOM.Types.Core (PrestoDOM)
import Controller.FormField(Action(..), State)


view :: forall w eff. (Action -> Effect Unit) -> State -> Object String -> PrestoDOM (Effect Unit) w
view push state _ =
  linearLayout
    [ height $ V 150
    , width MATCH_PARENT
    , orientation VERTICAL
    , margin $ Margin 20 20 20 20
    ]
    [ linearLayout
        [ height $ V 30
        , width MATCH_PARENT
        , margin $ Margin 10 20 20 20
        , text state.text
        , textSize 28
        ]
        []
    , linearLayout
        []
        [ editText
            [ height (V 40)
            , width MATCH_PARENT
            , margin $ Margin 10 10 10 10
            , textSize 20
            , color "#00000"
            , text state.value
            , onChange push TextChanged
            ]
        ]
    ]
