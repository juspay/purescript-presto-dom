module PrestoDOM.Events
    ( manualEventsName
    , onClick
    , onChange
    , attachBackPress
    , onMenuItemClick
    , onBackPressed
    , onNetworkChanged
    , makeEvent
    , afterRender
    , onAnimationEnd
    , onClickWithLogger
    , pushAndLog
    , setManualEvents
    , setManualEventsName
    ) where

import Prelude

import Data.Maybe (Maybe(..), fromMaybe)
import Effect (Effect)
import PrestoDOM.Utils (storeToWindow, getFromWindow, debounce)
import Foreign.Class (encode)
import Halogen.VDom.DOM.Prop (Prop(..))
import Tracker.Labels (Label(..)) as L
import Tracker (trackAction)
import Tracker.Types (Level(..), Action(..)) as T
import Unsafe.Coerce as U
import Web.Event.Event (EventType(..), Event) as DOM
{-- foreign import dummyEvent :: E.Event Int --}
foreign import backPressHandlerImpl :: Effect Unit

foreign import setManualEvents :: forall a b. (Maybe String) -> a -> b -> Effect Unit

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

onClickWithLogger :: String -> String -> forall a. (a ->  Effect Unit) -> (Unit -> a) -> Prop (Effect Unit)
onClickWithLogger label value push f = event (DOM.EventType "onClick") (Just <<< (makeEvent (pushAndLog label value push <<< f)))

pushAndLog :: forall a. String -> String -> (a -> Effect Unit) -> a -> Effect Unit
pushAndLog label value push a = do
    push a
    debounce (trackAction T.User T.Info L.ON_CLICK) label $ encode value

onChange :: forall a. (a -> Effect Unit ) -> (String -> a) -> Prop (Effect Unit)
onChange push f = event (DOM.EventType "onChange") (Just <<< (makeEvent (push <<< f)))

attachBackPress :: forall a. (a ->  Effect Unit) -> (Unit -> a) -> Prop (Effect Unit)
attachBackPress push f = event (DOM.EventType "onClick") (Just <<< backPressHandler)

onAnimationEnd :: forall a. (a ->  Effect Unit) -> (String -> a) -> Prop (Effect Unit)
onAnimationEnd push f = event (DOM.EventType "onAnimationEnd") (Just <<< (makeEvent (push <<< f)))

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

onMenuItemClick :: forall a. (a -> Effect Unit ) -> (Int -> a) -> Prop (Effect Unit)
onMenuItemClick push f = event (DOM.EventType "onMenuItemClick") (Just <<< (makeEvent (push <<< f)))

onBackPressed :: forall a b . (a ->  Effect Unit) -> (b -> a) -> Prop (Effect Unit)
onBackPressed push f = event (DOM.EventType "onBackPressedEvent") (Just <<< (makeEvent (push <<< f)))

onNetworkChanged :: forall a b . (a ->  Effect Unit) -> (b -> a) -> Prop (Effect Unit)
onNetworkChanged push f = event (DOM.EventType "onNetworkChange") (Just <<< (makeEvent (push <<< f)))

afterRender :: forall a b . (a -> Effect Unit) -> (b -> a) -> Prop (Effect Unit)
afterRender push f = event (DOM.EventType "afterRender") (Just <<< (makeEvent (push <<< f)))

-- TODO: Change String to a type
manualEventsName :: Unit -> Array String
manualEventsName _ =
  let defaultEvents = [ "onBackPressedEvent" , "onNetworkChange" ]
  in fromMaybe defaultEvents $ getFromWindow "manualEventsName"

setManualEventsName :: Maybe (Array String) -> Effect Unit
setManualEventsName (Just arr)  = storeToWindow "manualEventsName" arr
setManualEventsName Nothing =
  storeToWindow "manualEventsName" [ "onBackPressedEvent" , "onNetworkChange" ]

