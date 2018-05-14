module PrestoDOM.Events where

import Prelude

-- import DOM.Event.Types (EventType(..), Event) as DOM
import DOM.Event.Types (EventType(..), Event) as DOM
import Data.Maybe (Maybe(..))
import Halogen.VDom.DOM.Prop (Prop(..))
import PrestoDOM.Types.Core (PropEff)
import Unsafe.Coerce as U

foreign import backPressHandlerImpl :: forall eff. PropEff eff

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

onBackPressed :: forall a eff. (a ->  PropEff eff) -> (Unit -> a) -> Prop (PropEff eff)
onBackPressed push f = event (DOM.EventType "onClick") (Just <<< backPressHandler)

