module PrestoDOM.Events
    ( onClick
    , onChange
    , attachBackPress
    , onMenuItemClick
    , onBackPressed
    , onNetworkChanged
    , afterRender
    ) where

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

attachBackPress :: forall a eff. (a ->  PropEff eff) -> (Unit -> a) -> Prop (PropEff eff)
attachBackPress push f = event (DOM.EventType "onClick") (Just <<< backPressHandler)

onMenuItemClick :: forall a eff. (a -> PropEff eff ) -> (Int -> a) -> Prop (PropEff eff)
onMenuItemClick push f = event (DOM.EventType "onMenuItemClick") (Just <<< (makeEvent (push <<< f)))

onBackPressed :: forall a eff b . (a ->  PropEff eff) -> (b -> a) -> Prop (PropEff eff)
onBackPressed push f = event (DOM.EventType "onBackPressedEvent") (Just <<< (makeEvent (push <<< f)))

onNetworkChanged :: forall a eff b . (a ->  PropEff eff) -> (b -> a) -> Prop (PropEff eff)
onNetworkChanged push f = event (DOM.EventType "onNetworkChange") (Just <<< (makeEvent (push <<< f)))

afterRender :: forall a eff b . (a -> PropEff eff) -> (b -> a) -> Prop (PropEff eff)
afterRender push f = event (DOM.EventType "afterRender") (Just <<< (makeEvent (push <<< f)))