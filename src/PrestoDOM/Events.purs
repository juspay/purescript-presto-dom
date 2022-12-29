module PrestoDOM.Events
    ( manualEventsName
    , onClick
    , onChange
    , attachBackPress
    , onMenuItemClick
    , onBackPressed
    , onNetworkChanged
    , makeEvent
    , ScrollState
    , onFocus
    , onScroll
    , onScrollStateChange
    , onRefresh
    , afterRender
    , onAnimationEnd
    , onClickWithLogger
    , pushAndLog
    , setManualEvents
    , setManualEventsName
    , fireManualEvent
    , onMicroappResponse
    , update
    , registerEvent
    , globalOnScroll
    , onSlide
    , onStateChanged
    , MouseEventProperties
    , mouseEventOnClick
    ) where

import Prelude

import Data.Maybe (Maybe(..), fromMaybe)
import Data.Either (hush)
import Control.Monad.Except (runExcept)
import Effect (Effect)
import PrestoDOM.Utils (storeToWindow, getFromWindow, debounce)
import Foreign.Class (encode)
import Foreign.Object (Object, empty, insert, lookup)
import Halogen.VDom.DOM.Prop (Prop(..))
import Tracker.Labels (Label(..)) as L
import Tracker (trackAction)
import Tracker.Types (Level(..), Action(..)) as T
import Unsafe.Coerce as U
import Web.Event.Event (EventType(..), Event) as DOM
import Foreign(Foreign, unsafeToForeign)
import Foreign.Class (decode)
import FRP.Event as E
import FRP.Behavior (sample_, unfold)
import FRP.Event (subscribe)

{-- foreign import dummyEvent :: E.Event Int --}
foreign import backPressHandlerImpl :: Effect Unit

foreign import setManualEvents :: forall a b. (Maybe String) -> a -> b -> Effect Unit
foreign import fireManualEvent :: forall a. String -> a -> Effect Unit

foreign import saveScrollPush :: forall a. (a -> Effect Unit) -> String -> Effect Unit
foreign import getScrollPush :: forall a. String -> Effect (a -> Effect Unit)
foreign import timeOutScroll :: String -> Effect Unit -> Effect Unit
foreign import getLastTimeStamp :: String -> Effect Number
foreign import setLastTimeStamp :: String -> Effect Unit


{-- foreign import saveCanceler --}
{--     :: forall eff --}
{--      . String --}
{--     -> (Eff (frp :: FRP, ref :: REF, dom :: DOM | eff) Unit) --}
{--     -> Effect Unit --}

data ScrollState = SCROLL_STATE_FLING | SCROLL_STATE_IDLE  | SCROLL_STATE_TOUCH_SCROLL

mapScrollState :: Int -> ScrollState
mapScrollState value = case value of
    0 -> SCROLL_STATE_IDLE
    1 -> SCROLL_STATE_TOUCH_SCROLL
    2 -> SCROLL_STATE_FLING
    _ -> SCROLL_STATE_IDLE

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

mouseEventOnClick :: (Maybe MouseEventProperties -> Effect Unit) -> Prop (Effect Unit)
mouseEventOnClick effFn = event (DOM.EventType "onClick") (Just <<< \evnt -> effFn $ hush $ runExcept $ decode $ unsafeToForeign evnt)

onClickWithLogger :: String -> String -> forall a. (a ->  Effect Unit) -> (Unit -> a) -> Object Foreign -> Prop (Effect Unit)
onClickWithLogger label value push f json = event (DOM.EventType "onClick") (Just <<< (makeEvent (pushAndLog label value push json <<< f )))

onRefresh :: forall a. (a ->  Effect Unit) -> (Unit -> a) -> Prop (Effect Unit)
onRefresh push f = event (DOM.EventType "onRefresh") (Just <<< (makeEvent (push <<< f)))

pushAndLog :: forall a. String -> String -> (a -> Effect Unit) -> Object Foreign -> a ->Effect Unit
pushAndLog label value push json a = do
    push a
    debounce (trackAction T.User T.Info L.ON_CLICK) label (encode value) json

onFocus :: forall a. (a ->  Effect Unit) -> (Boolean -> a) -> Prop (Effect Unit)
onFocus push f = event (DOM.EventType "onFocus") (Just <<< (makeEvent (push <<< f)))

onChange :: forall a. (a -> Effect Unit ) -> (String -> a) -> Prop (Effect Unit)
onChange push f = event (DOM.EventType "onChange") (Just <<< (makeEvent (push <<< f)))

attachBackPress :: forall a. (a ->  Effect Unit) -> (Unit -> a) -> Prop (Effect Unit)
attachBackPress push f = event (DOM.EventType "onClick") (Just <<< backPressHandler)

onScroll :: forall a. String -> String -> (a -> Effect Unit ) -> (String -> a) -> Prop (Effect Unit)
onScroll identifier globalEventsIdentifier push f = event (DOM.EventType "onScroll") (Just <<< (makeEvent (\a -> do
    let currentScrollState = {newScroll : a, identifier, push : push <<< f, isTimeOut : false}
    scrollPush <- getScrollPush globalEventsIdentifier
    scrollPush currentScrollState
    )))

globalOnScroll :: forall a. String -> (a -> Effect Unit) -> Effect (Effect Unit)
globalOnScroll identifier _ =  --pure $ pure unit
  do
        { event: event' , push } <- E.create
        _ <- saveScrollPush push identifier
        let stateBehaviour = unfold (scrollStateUpdate identifier) event' ( {scrollState : empty, lastIdentifier : ""})
        canceller <- sample_ stateBehaviour event' `subscribe` (scrollListner push)
        pure canceller
    where
    scrollListner :: (PushState -> Effect Unit) -> ScrollS -> Effect Unit
    scrollListner push st = do
            oldTime <- getLastTimeStamp identifier
            _ <- setLastTimeStamp identifier
            newTime <- getLastTimeStamp identifier
            -- st <- state
            let currentState = lookup st.lastIdentifier st.scrollState
            case currentState of
                Just item   -> do
                    if item.isTimeOut
                        then do
                            if newTime - oldTime >= 200.0
                                then item.push item.oldScroll
                                else pure unit
                        else timeOutScroll st.lastIdentifier (push $ {isTimeOut : true, identifier : st.lastIdentifier, newScroll : item.oldScroll, push : item.push})
                Nothing     -> pure unit
            pure unit

type ScrollS =
  { scrollState :: Object (ScrollHolder)
  , lastIdentifier :: String
  }

type ScrollHolder =
  { hasChanged :: Boolean
  , oldScroll :: String
  , isTimeOut :: Boolean
  , push :: String -> Effect Unit
  }

type PushState =
  { newScroll :: String
  , identifier :: String
  , push :: (String -> Effect Unit)
  , isTimeOut :: Boolean
  }

type MouseEventProperties = {
    clientX :: Number,
    clientY :: Number
}

scrollStateUpdate :: String -> PushState -> ScrollS -> ScrollS
scrollStateUpdate gID newScroll st= do
    let currentState = lookup newScroll.identifier st.scrollState
    case currentState of
        Just item -> do
            if newScroll.isTimeOut
                then
                    let scrollState = insert newScroll.identifier {hasChanged : false, isTimeOut : true, oldScroll : newScroll.newScroll, push : newScroll.push} st.scrollState
                    in { scrollState, lastIdentifier : newScroll.identifier }
                else do
                    let hasChanged = newScroll.newScroll /= item.oldScroll
                    -- let pendingEffects = [do
                    --             push <- getScrollPush gID
                    --             timeOutScroll newScroll.identifier (push $ newScroll{isTimeOut = true})]
                    let scrollState = insert newScroll.identifier {hasChanged, isTimeOut : false, oldScroll : newScroll.newScroll, push : newScroll.push} st.scrollState
                    { scrollState, lastIdentifier : newScroll.identifier }
        Nothing    -> do
            -- let pendingEffects = [newScroll.push newScroll.newScroll]
            let scrollState = insert newScroll.identifier {hasChanged : false, isTimeOut : false, oldScroll : newScroll.newScroll, push : newScroll.push} st.scrollState
            { scrollState, lastIdentifier : newScroll.identifier }

onScrollStateChange :: forall a. (a -> Effect Unit ) -> (ScrollState -> a) -> Prop (Effect Unit)
onScrollStateChange push f = event (DOM.EventType "onScrollStateChange") (Just <<< (makeEvent (push <<< f <<< mapScrollState)))

onSlide :: forall a. (a -> Effect Unit ) -> (Number -> a) -> Prop (Effect Unit)
onSlide push f = event (DOM.EventType "onSlide") (Just <<< (makeEvent (push <<< f)))

onStateChanged :: forall a. (a -> Effect Unit ) -> (Number -> a) -> Prop (Effect Unit)
onStateChanged push f = event (DOM.EventType "onStateChanged") (Just <<< (makeEvent (push <<< f)))


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

update :: forall a b . (a ->  Effect Unit) -> (b -> a) -> Prop (Effect Unit)
update push f = event (DOM.EventType "update") (Just <<< (makeEvent (push <<< f)))


registerEvent :: forall a b . String -> (a ->  Effect Unit) -> (b -> a) -> Prop (Effect Unit)
registerEvent s push f = event (DOM.EventType s) (Just <<< (makeEvent (push <<< f)))

onNetworkChanged :: forall a b . (a ->  Effect Unit) -> (b -> a) -> Prop (Effect Unit)
onNetworkChanged push f = event (DOM.EventType "onNetworkChange") (Just <<< (makeEvent (push <<< f)))

afterRender :: forall a b . (a -> Effect Unit) -> (b -> a) -> Prop (Effect Unit)
afterRender push f = event (DOM.EventType "afterRender") (Just <<< (makeEvent (push <<< f)))

onMicroappResponse :: forall a. (a -> Effect Unit) -> ({code :: Int, message :: String} -> a) -> Prop (Effect Unit)
onMicroappResponse push f = event (DOM.EventType "onMicroappResponse") (Just <<< (makeEvent (push <<< f)))

-- TODO: Change String to a type
manualEventsName :: Unit -> Array String
manualEventsName _ =
  let defaultEvents = [ "onBackPressedEvent" , "onNetworkChange", "update" ]
  in fromMaybe defaultEvents $ getFromWindow "manualEventsName"

setManualEventsName :: Maybe (Array String) -> Effect Unit
setManualEventsName (Just arr)  = storeToWindow "manualEventsName" arr
setManualEventsName Nothing =
  storeToWindow "manualEventsName" [ "onBackPressedEvent" , "onNetworkChange", "update" ]
