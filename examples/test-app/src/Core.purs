module Core where

import Prelude

import Data.Tuple (Tuple(..))
import Data.Generic.Rep (class Generic)
import Data.Show.Generic (genericShow)
import Data.Either
import Data.Generic.Rep.Eq (genericEq)
import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Ref as Ref
import Presto.Core.Types.Language.Flow (Flow, doAff, initUI, oneOf, runScreen, showScreen)
import PrestoDOM (Screen)
import PrestoDOM.Core (ScreenData)
import UI.Controller (ExitAction(..))
import UI.ScreenA.View as A
import UI.ScreenB.View as B
import UI.ScreenC.View as C
import UI.ScreenD.View as D
import UI.ScreenE.View as E


data ScreenName
  = Flow
  | SA
  | SB
  | SC
  | SD
  | SE

derive instance genericScreenName :: Generic ScreenName _

instance eqScreenName :: Eq ScreenName where
  eq = genericEq

instance showScreenName :: Show ScreenName where
  show = genericShow

flow :: Flow Unit
flow = do
  ref <- initUI
  screenAFlow ref initialScreenStates

type ScreenStates = {a :: BaseState, b :: BaseState, c :: BaseState, d :: BaseState, e :: BaseState}
type BaseState = {bool :: Boolean, count :: Int}

initialScreenStates :: ScreenStates
initialScreenStates = { a : {bool : false, count : 0}
                      , b : {bool : false, count : 0}
                      , c : {bool : false, count : 0}
                      , d : {bool : false, count : 0}
                      , e : {bool : false, count : 0}
                      }

screenAFlow :: Ref.Ref ScreenData -> ScreenStates -> Flow Unit
screenAFlow ref state = do
  let st = state { a = state.a {bool = not state.a.bool}}
  result <- runAndSetScreen ref SA $ A.screen st.a.bool st.a.count
  _ <- case result of
        Tuple count ScreenA -> screenAFlow ref $ st { a = st.a { count = count }}
        Tuple count ScreenB -> screenBFlow ref $ st { a = st.a { count = count }}
        Tuple count ScreenC -> screenCFlow ref $ st { a = st.a { count = count }}
        Tuple count ScreenD -> screenDFlow ref $ st { a = st.a { count = count }}
        Tuple count ShowLoader -> screenEFlow ref $ st { a = st.a { count = count }}
        _ -> screenAFlow ref st
  pure unit

screenBFlow :: Ref.Ref ScreenData -> ScreenStates -> Flow Unit
screenBFlow ref state = do
  let st = state { b = state.b {bool = not state.b.bool}}
  result <- showAndSetScreen ref SB $ B.screen st.b.bool st.b.count
  _ <- case result of
        Tuple count ScreenA -> screenAFlow ref $ st { b = st.b { count = count }}
        Tuple count ScreenB -> screenBFlow ref $ st { b = st.b { count = count }}
        Tuple count ScreenC -> screenCFlow ref $ st { b = st.b { count = count }}
        Tuple count ScreenD -> screenDFlow ref $ st { b = st.b { count = count }}
        Tuple count ShowLoader -> screenEFlow ref $ st { b = st.b { count = count }}
        _ -> screenAFlow ref st
  pure unit

screenCFlow :: Ref.Ref ScreenData -> ScreenStates -> Flow Unit
screenCFlow ref state = do
  let st = state { c = state.c {bool = not state.c.bool}}
  result <- runAndSetScreen ref SC $ C.screen st.c.bool st.c.count
  _ <- case result of
        Tuple count ScreenA -> screenAFlow ref $ st { c = st.c { count = count }}
        Tuple count ScreenB -> screenBFlow ref $ st { c = st.c { count = count }}
        Tuple count ScreenC -> screenCFlow ref $ st { c = st.c { count = count }}
        Tuple count ScreenD -> screenDFlow ref $ st { c = st.c { count = count }}
        Tuple count ShowLoader -> screenEFlow ref $ st { c = st.c { count = count }}
        _ -> screenAFlow ref st
  pure unit

screenDFlow :: Ref.Ref ScreenData -> ScreenStates -> Flow Unit
screenDFlow ref state = do
  let st = state { d = state.d {bool = not state.d.bool}}
  result <- runAndSetScreen ref SD $ D.screen st.d.bool st.d.count
  _ <- case result of
        Tuple count ScreenA -> screenAFlow ref $ st { d = st.d { count = count }}
        Tuple count ScreenB -> screenBFlow ref $ st { d = st.d { count = count }}
        Tuple count ScreenC -> screenCFlow ref $ st { d = st.d { count = count }}
        Tuple count ScreenD -> screenDFlow ref $ st { d = st.d { count = count }}
        Tuple count ShowLoader -> screenEFlow ref $ st { d = st.d { count = count }}
        _ -> screenAFlow ref st
  pure unit

screenEFlow :: Ref.Ref ScreenData -> ScreenStates -> Flow Unit
screenEFlow ref state = do
  let st = state { e = state.e {bool = not state.e.bool}}
  result <- showAndSetScreen ref SE $ E.screen st.e.bool st.e.count
  _ <- case result of
        Tuple count ScreenA -> screenAFlow ref $ st { e = st.e { count = count }}
        Tuple count ScreenB -> screenBFlow ref $ st { e = st.e { count = count }}
        Tuple count ScreenC -> screenCFlow ref $ st { e = st.e { count = count }}
        Tuple count ScreenD -> screenDFlow ref $ st { e = st.e { count = count }}
        Tuple count ShowLoader -> screenEFlow ref $ st { e = st.e { count = count }}
        _ -> screenAFlow ref st
  pure unit

runAndSetScreen
  :: forall action state exit screenName
   . Show screenName
  => Eq screenName
  => Ref.Ref ScreenData
  -> screenName
  -> Screen action state exit
  -> Flow exit
runAndSetScreen ref screenName screen = do
  doAff do liftEffect $ setScreen $ show screenName
  runScreen ref screenName screen

showAndSetScreen
  :: forall action state exit screenName
   . Show screenName
  => Eq screenName
  => Ref.Ref ScreenData
  -> screenName
  -> Screen action state exit
  -> Flow exit
showAndSetScreen ref screenName screen = do
  doAff do liftEffect $ setScreen $ show screenName
  showScreen ref screenName screen

foreign import setScreen :: String -> Effect Unit