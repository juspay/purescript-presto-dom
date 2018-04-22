module PrestoDOM.Core where

import Prelude

import Control.Monad.Eff (Eff)
import Control.Monad.Aff (Canceler, Error, nonCanceler)
import Control.Monad.Eff.Timer as T
import Data.Tuple (Tuple)
import Data.StrMap (StrMap, fromFoldable)
import DOM (DOM)
import DOM.Node.Types (Element, Document)
import Data.Either (Either(..), either)
import FRP (FRP)
import FRP.Behavior (sample_, unfold)
import FRP.Event (subscribe)
import FRP.Event as E
import Halogen.VDom (Step(..), VDom, VDomMachine, VDomSpec(..), buildVDom)
import Halogen.VDom.DOM.Prop (Prop)
import Halogen.VDom.Machine (never, step, extract)
import PrestoDOM.Types.Core (PrestoDOM, Screen)
import Unsafe.Coerce (unsafeCoerce)

foreign import applyAttributes ∷ forall i eff. Element → (Array (Prop i)) → Eff eff (Array (Prop i))
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
  done attrs = pure unit

spec :: forall i e. Document -> VDomSpec e (Array (Prop i)) Void
spec document =  VDomSpec {
      buildWidget: const never
    , buildAttributes: buildAttributes
    , document : document
    }

patchAndRun :: forall t state i. state -> (state -> VDom (Array (Prop i)) Void) -> Eff t Unit
patchAndRun state myDom = do
  machine <- getLatestMachine
  newMachine <- step machine (myDom state)
  storeMachine newMachine

initScreen
  :: forall action eff
   . VDom (Array (Prop action)) Void
  -> (Either Error Unit -> Eff (frp :: FRP, dom :: DOM, timer :: T.TIMER | eff) Unit)
  -> Eff ( frp :: FRP, dom :: DOM, timer :: T.TIMER | eff ) (Canceler ( frp :: FRP, dom :: DOM, timer :: T.TIMER | eff ))
initScreen view cb = do
  root <- getRootNode
  machine <- buildVDom (spec root) view
  storeMachine machine
  insertDom root (extract machine)
  cb $ Right unit
  pure nonCanceler


runScreen'
    :: forall action st eff retAction
     . Boolean
    -> Screen action st eff retAction
    -> (Either Error retAction -> Eff (frp :: FRP, dom :: DOM | eff) Unit)
    -> Eff ( frp :: FRP, dom :: DOM | eff ) (Canceler ( frp :: FRP, dom :: DOM | eff ))
runScreen' rerender { initialState, view, eval } cb = do
  { event, push } <- E.create
  let initState = initialState
  case rerender of
    true -> do
        root <- getRootNode
        machine <- buildVDom (spec root) (view push initState)
        storeMachine machine
        insertDom root (extract machine)
    false ->
        patchAndRun initState (view push)
  let stateBeh = unfold (\action eitherState -> eitherState >>= (eval action)) event (Right initialState)
  _ <- sample_ stateBeh event `subscribe` (\eitherState ->
       either (\a -> cb $ Right a) (\state -> patchAndRun state (view push) *> pure unit) eitherState)
  pure nonCanceler

runScreen :: forall action st eff retAction.
    Screen action st eff retAction
    -> (Either Error retAction -> Eff (frp :: FRP, dom :: DOM | eff) Unit)
    -> Eff ( frp :: FRP, dom :: DOM | eff ) (Canceler ( frp :: FRP, dom :: DOM | eff ))
runScreen = runScreen' true

mapDom
  :: forall i a b state eff w
   . ((a -> Eff (frp :: FRP | eff) Unit) -> state -> StrMap i -> PrestoDOM a w)
  -> (b -> Eff (frp :: FRP | eff) Unit)
  -> state
  -> (a -> b)
  -> Array (Tuple String i)
  -> PrestoDOM b w
mapDom view push state actionMap = unsafeCoerce view (push <<< actionMap) state <<< fromFoldable
