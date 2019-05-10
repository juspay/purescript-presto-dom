module UI.ScreenE.View where

import Prelude

import Data.Tuple (Tuple(..))
import Effect (Effect)
import PrestoDOM (Gravity(..), Length(..), Margin(..), Namespace(..), Orientation(..), PrestoDOM, Screen, background, clickable, gravity, height, linearLayout, linearLayout_, margin, onBackPressed, onClick, orientation, text, textView, translationZ, width)
import UI.Button as Button
import UI.Controller (State(..))
import UI.Controller as ScreenA

screen :: Boolean -> Int -> Screen ScreenA.ExitAction ScreenA.State (Tuple Int ScreenA.ExitAction)
screen bool int = 
  { initialState : ScreenA.State { patch : bool, count : int }
  , view
  , eval : ScreenA.eval
  }

view :: forall w
  . (ScreenA.ExitAction -> Effect Unit)
  -> ScreenA.State
  -> PrestoDOM
view push (State state) =
  linearLayout_ (Namespace "ScreenE")
  [ height MATCH_PARENT
  , width MATCH_PARENT
  , background "#55FF7700"
  , gravity CENTER
  , clickable true
  , onBackPressed push (const ScreenA.BackPress)
  , orientation VERTICAL
  , translationZ 200.0
  ]
  [ linearLayout
    [ height MATCH_PARENT
    , width MATCH_PARENT
    , margin $ Margin 101 0 0 0
    , gravity CENTER
    , background "#FFFFFF"
    , orientation VERTICAL
    ]
    [ textView
      [ text $ show ScreenA.ShowLoader <> " " <> (show state.patch)
      , height $ V 50
      , width MATCH_PARENT
      ] 
    , textView
        [ text $ "CLICK HERE" <> " " <> (show state.count)
        , height $ V 50
        , width MATCH_PARENT
        , onClick push $ const ScreenA.Click
        ]
    , Button.view ScreenA.ScreenA push state.patch
    , Button.view ScreenA.ScreenB push $ not state.patch
    , Button.view ScreenA.ScreenC push state.patch
    , Button.view ScreenA.ScreenD push $ not state.patch
    , Button.view ScreenA.ShowLoader push state.patch
    ] 
  ]