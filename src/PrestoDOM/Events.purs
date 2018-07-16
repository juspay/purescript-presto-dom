module PrestoDOM.Events where

import Prelude

-- import DOM.Event.Types (EventType(..), Event) as DOM
import Effect (Effect)
import Web.Event.Event (EventType(..), Event) as DOM
import Data.Maybe (Maybe(..))
{-- import FRP.Behavior as B --}
{-- import FRP.Event as E --}
{-- import FRP.Event.Time as TIME --}

import Halogen.VDom.DOM.Prop (Prop(..))
import Unsafe.Coerce as U

{-- foreign import dummyEvent :: E.Event Int --}
foreign import backPressHandlerImpl :: Effect Unit

{-- foreign import saveCanceler --}
{--     :: forall eff --}
{--      . String --}
{--     -> (Eff (frp :: FRP, ref :: REF, dom :: DOM | eff) Unit) --}
{--     -> Effect Unit --}

event :: forall a. DOM.EventType -> (DOM.Event → Maybe a) -> Prop a
event = Handler

makeEvent :: forall a. (a -> Effect Unit ) -> (DOM.Event → Effect Unit)
makeEvent push = \ev -> do
    _ <- push (U.unsafeCoerce ev)
    pure unit

backPressHandler :: (DOM.Event → Effect Unit)
backPressHandler = \ev -> do
    _ <- backPressHandlerImpl
    pure unit

onClick :: forall a. (a ->  Effect Unit) -> (Unit -> a) -> Prop (Effect Unit)
onClick push f = event (DOM.EventType "onClick") (Just <<< (makeEvent (push <<< f)))

onChange :: forall a. (a -> Effect Unit ) -> (String -> a) -> Prop (Effect Unit)
onChange push f = event (DOM.EventType "onChange") (Just <<< (makeEvent (push <<< f)))

attachBackPress :: forall a. (a ->  Effect Unit) -> (Unit -> a) -> Prop (Effect Unit)
attachBackPress push f = event (DOM.EventType "onClick") (Just <<< backPressHandler)



{-- attachTimerHandler --}
{--     :: forall eff a --}
{--      . (a ->  Eff ( frp :: FRP, ref :: REF, dom :: DOM | eff) Unit) --}
{--     -> (Unit -> a) --}
{--     -> Effect Unit --}
{-- attachTimerHandler push f = do --}
{--     let behavior = B.step 0 dummyEvent --}
{--     canceler <- E.subscribe (B.sample_ behavior (TIME.interval 1000)) (\_ -> push $ f unit) --}
{--     saveCanceler "attachTimer" canceler --}

{-- attachTimer :: forall a eff. (a ->  Effect Unit) -> (Unit -> a) -> Prop (Effect Unit) --}
{-- attachTimer push f = --}
{--     BHandler "attachTimer" (Just <<< (\_ -> attachTimerHandler push f)) --}

