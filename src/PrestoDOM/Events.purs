module PrestoDOM.Events where

import Prelude

-- import DOM.Event.Types (EventType(..), Event) as DOM
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Unsafe (unsafePerformEff)
import Control.Monad.Eff.Ref (REF)
import DOM.Event.Types (EventType(..), Event) as DOM
import Data.Maybe (Maybe(..))
import DOM (DOM)
import FRP (FRP)
import FRP.Behavior as B
import FRP.Event as E
import FRP.Event.Time as TIME

import Halogen.VDom.DOM.Prop (Prop(..))
import PrestoDOM.Types.Core (PropEff)
import Unsafe.Coerce as U

foreign import dummyEvent :: E.Event Int
foreign import backPressHandlerImpl :: forall eff. PropEff eff

foreign import saveCanceler
    :: forall eff
     . String
    -> (Eff (frp :: FRP, ref :: REF, dom :: DOM | eff) Unit)
    -> PropEff eff

event :: forall a. DOM.EventType -> (DOM.Event → Maybe a) -> Prop a
event = Handler

makeEvent :: forall eff a. (a -> PropEff eff ) -> (DOM.Event → PropEff eff)
makeEvent push = \ev -> do
    _ <- push (U.unsafeCoerce ev)
    pure unit

backPressHandler :: forall eff.  (DOM.Event → PropEff eff)
backPressHandler = \ev -> do
    _ <- backPressHandlerImpl
    pure unit

onClick :: forall a eff. (a ->  PropEff eff) -> (Unit -> a) -> Prop (PropEff eff)
onClick push f = event (DOM.EventType "onClick") (Just <<< (makeEvent (push <<< f)))

onChange :: forall a eff. (a -> PropEff eff ) -> (String -> a) -> Prop (PropEff eff)
onChange push f = event (DOM.EventType "onChange") (Just <<< (makeEvent (push <<< f)))

attachBackPress :: forall a eff. (a ->  PropEff eff) -> (Unit -> a) -> Prop (PropEff eff)
attachBackPress push f = event (DOM.EventType "onClick") (Just <<< backPressHandler)



attachTimerHandler
    :: forall eff a
     . (a ->  Eff ( frp :: FRP, ref :: REF, dom :: DOM | eff) Unit)
    -> (Unit -> a)
    -> PropEff eff
attachTimerHandler push f = do
    let behavior = B.step 0 dummyEvent
    canceler <- E.subscribe (B.sample_ behavior (TIME.interval 1000)) (\_ -> push $ f unit)
    saveCanceler "attachTimer" canceler

attachTimer :: forall a eff. (a ->  PropEff eff) -> (Unit -> a) -> Prop (PropEff eff)
attachTimer push f =
    BHandler "attachTimer" (Just <<< (\_ -> attachTimerHandler push f))

