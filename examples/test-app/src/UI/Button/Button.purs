module UI.Button where

import Prelude

import Effect (Effect)
import PrestoDOM (Gravity(..), Length(..), Margin(..), Orientation(..), Padding(..), PrestoDOM, background, color, cornerRadius, gravity, height, linearLayout, margin, onClick, orientation, padding, text, textView, width)
import UI.Controller as Contoller

view :: forall a w
  . Show a
  => a
  -> (a -> Effect Unit)
  -> Boolean
  -> PrestoDOM 
view action push bool = 
  linearLayout
  [ height $ V 50
  , width $ V 125
  , cornerRadius 5.0
  , gravity CENTER
  , padding $ Padding 5 5 5 5
  , margin $ Margin 5 5 5 5
  , background if bool then "#affeff" else "#500100"
  , onClick push (const action)
  ]
  [ textView
    [ height $ V 17
    , width MATCH_PARENT
    , gravity CENTER
    , color if bool then "#000000" else "#ffffff"
    , text $ show action
    ]
  ]