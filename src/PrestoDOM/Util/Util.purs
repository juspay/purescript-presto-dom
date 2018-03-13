module PrestoDOM.Util where

import Prelude
import PrestoDOM.Core

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)
import DOM (DOM)
import DOM.HTML.HTMLImageElement (create)
import DOM.Node.Types (Element, Document)
import FRP (FRP)
import FRP as F
import FRP.Behavior (Behavior, behavior, sample_, unfold)
import FRP.Behavior as B
import FRP.Event (Event, subscribe)
import FRP.Event as E
import Halogen.VDom (Step(..), VDom, VDomMachine, VDomSpec(..), buildVDom, extract)
import Halogen.VDom.Machine (never, step, extract)
import Prelude (Unit, Void, bind, const, discard, pure, unit, ($))
import PrestoDOM.Properties (a_duration)
import PrestoDOM.Types (Rec)
import Unsafe.Coerce (unsafeCoerce)

foreign import logNode :: forall eff a . a  -> Eff eff Unit
foreign import applyAttributes ∷ forall i eff. Element → (Array (Prop i)) → Eff eff (Array (Prop i))
foreign import done :: forall eff. Eff eff Unit
foreign import patchAttributes ∷ forall i eff. Element → (Array (Prop i)) → (Array (Prop i)) → Eff eff (Array (Prop i))
foreign import cleanupAttributes ∷ forall i eff. Element → (Array (Prop i)) → Eff eff Unit
foreign import getLatestMachine :: forall m a b eff. Eff eff (Step m a b)
foreign import storeMachine :: forall eff m a b. Step m a b -> Eff eff Unit
foreign import getRootNode :: forall eff. Eff eff Document
foreign import insertDom :: forall a b eff. a -> b -> Eff eff Unit

buildAttributes
  ∷ ∀ eff a
  . Element
  → VDomMachine eff (Array (Prop a)) Unit
buildAttributes elem = apply
  where
  apply ∷ forall e. VDomMachine e (Array (Prop a)) Unit
  apply attrs = do
    x <- applyAttributes elem attrs
    pure
      (Step unit
        (patch x)
        (done x))

  patch ∷ forall e. (Array (Prop a)) → VDomMachine e (Array (Prop a)) Unit
  patch attrs1 attrs2 = do
    x <- patchAttributes elem attrs1 attrs2
    pure
      (Step unit
        (patch x)
        (done x))

  done ∷ forall e. (Array (Prop a)) → Eff e Unit
  done attrs = cleanupAttributes elem attrs

spec :: forall i e. Document -> VDomSpec e (Array (Prop i)) Void
spec document =  VDomSpec {
      buildWidget: const never
    , buildAttributes: buildAttributes
    , document : document
    }

render :: forall i state eff a.
  (state -> VDom (Array (Prop i)) Void)
  -> state
  -> Eff ( dom :: DOM, frp :: FRP | eff )
    {  updateState :: (Behavior state
                      -> Event a
                      -> Eff (frp :: FRP, dom :: DOM | eff) (Eff (frp :: FRP, dom :: DOM | eff) Unit))
    , stateBeh :: Behavior state }
render dom state = do
  root <- getRootNode
  machine <- buildVDom (spec root) (dom state)
  storeMachine machine
  insertDom root (extract machine)
  { event, push } <- E.create
  let stateBeh = B.step state event
  _ <- sample_ stateBeh event `E.subscribe` (\x -> patchAndRun x dom)
  pure { updateState : (updateState push), stateBeh }

updateState :: forall eff state a. (state -> Eff ( frp :: FRP | eff ) Unit)
  -> Behavior state
  -> Event a
  -> Eff (frp :: FRP | eff) (Eff (frp :: FRP | eff) Unit)
updateState stateFn beh event = sample_ beh event `subscribe` (\newState -> do
  _ <- logNode newState
  stateFn newState)


patchAndRun :: forall a b t state i. state -> (state -> VDom (Array (Prop i)) Void) -> Eff t Unit
patchAndRun state myDom = do
  machine <- getLatestMachine
  newMachine <- step machine (myDom state)
  storeMachine newMachine

type Component action st eff =
  {
    initialState :: st
  , view :: (action -> Eff (frp :: FRP, dom :: DOM | eff) Unit) -> st -> VDom (Array (Prop action)) Void
  , eval :: action -> st -> st
  }


runElm :: forall action i st eff.
  Component action st eff
  -> Eff ( frp :: FRP, dom :: DOM | eff ) (Eff ( frp :: FRP, dom :: DOM | eff ) Unit)
runElm { initialState, view, eval } = do
  { event, push } <- E.create
  let initState = initialState
  root <- getRootNode
  machine <- buildVDom (spec root) (view push initState)
  storeMachine machine
  insertDom root (extract machine)
  sample_ (unfold eval event initState) event `subscribe` (\newState -> do
    patchAndRun newState (view push))


mapDom :: forall a b state eff w.
  ((a -> Eff (frp :: FRP | eff) Unit) -> state -> PrestoDOM a w)
  -> (b -> Eff (frp :: FRP | eff) Unit)
  -> state
  -> (a -> b)
  -> PrestoDOM b w
mapDom view push state actionMap = unsafeCoerce view (push <<< actionMap) state
