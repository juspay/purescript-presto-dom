module UI.ScreenA.View where

import Prelude

import Data.Tuple (Tuple(..))
import Effect (Effect)
import PrestoDOM (Gravity(..), Length(..), Namespace(..), Orientation(..), PrestoDOM, Screen, afterRender, background, clickable, gravity, height, linearLayout, linearLayout_, onBackPressed, onClick, orientation, text, textView, width)
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
  linearLayout_ (Namespace "ScreenA")
  [ height MATCH_PARENT
  , width MATCH_PARENT
  , background "#effaff"
  , gravity CENTER
  , clickable true
  , afterRender push $ const ScreenA.BackPress
  , onBackPressed push $ const ScreenA.BackPress
  , orientation VERTICAL
  ]
  [ textView
    [ text $ show ScreenA.ScreenA <> " " <> (show state.patch)
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