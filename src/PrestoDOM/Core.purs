module PrestoDOM.Core where

import Prelude

import Control.Monad.Eff (Eff)
import Control.Monad.Aff (Canceler, Error, nonCanceler)
import Data.Exists (Exists, runExists)
import Data.Function.Uncurried as Fn
import Data.StrMap (StrMap, fromFoldable)
import DOM (DOM)
import Control.Monad.Eff.Ref (REF)
import DOM.Node.Types (Document)
import DOM.Node.Types (Node) as DOM
import Data.Either (Either(..), either)
import Data.Foldable (for_)
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..), fst)
import FRP (FRP)
import FRP.Behavior (sample_, unfold)
import FRP.Event (subscribe)
import FRP.Event as E
import Halogen.VDom (Step(..), VDomSpec(VDomSpec), buildVDom, VDomMachine)
import Halogen.VDom.DOM.Prop (Prop, buildProp)
import Halogen.VDom.Machine (never, step, extract)
import Halogen.VDom.Util (refEq)
import PrestoDOM.Types.Core (ElemName(..), ElemSpec(..), VDom(Elem), PrestoDOM, Screen, PropEff, Namespace, Thunk(..))
import Unsafe.Coerce (unsafeCoerce)
import PrestoDOM.Utils (continue)

{-- foreign import logMe :: forall a. String -> a -> a --}
foreign import emitter :: forall a eff. a -> Eff eff Unit
foreign import getLatestMachine :: forall m a b eff. Eff eff (Step m a b)
foreign import storeMachine :: forall eff m a b. Step m a b -> Eff eff Unit
foreign import getRootNode :: forall eff. Eff eff Document
foreign import setRootNode :: forall a eff. Maybe a -> Eff eff Document
foreign import insertDom :: forall a b eff. a -> b -> Eff eff Unit
foreign import processWidget :: forall eff. Eff eff Unit

foreign import saveScreenNameImpl :: forall eff. Maybe Namespace -> Eff eff Unit
foreign import getPrevScreen :: forall eff. Eff eff (Maybe Namespace)




buildWidget
  ∷ ∀ e
	. VDomSpec ( ref :: REF , frp :: FRP, dom :: DOM | e ) (Array (Prop (PropEff e))) (Exists (Thunk e))
	→ VDomMachine ( ref :: REF , frp :: FRP, dom :: DOM | e ) (Exists (Thunk e)) DOM.Node
buildWidget spec = render
  where
        render = runExists \(Thunk a render') → do
           node ← render' a
           pure (Step node
                (Fn.runFn2 patch (unsafeCoerce a) node)
                (pure unit))
        patch = Fn.mkFn2 \a node → runExists \(Thunk b render') →
           if Fn.runFn2 refEq a b
               then pure (Step node
                         (Fn.runFn2 patch a node)
                         (pure unit))
               else do
                  node <- render' b
                  pure (Step node
                       (Fn.runFn2 patch (unsafeCoerce b) node)
                       (pure unit))



spec :: forall e. Document -> VDomSpec ( ref :: REF , frp :: FRP, dom :: DOM | e ) (Array (Prop (PropEff e))) (Exists (Thunk e))
spec document =  VDomSpec {
      buildWidget
    , buildAttributes: buildProp id
    , document : document
    }

logger :: forall a eff. (a → Eff (ref ∷ REF, dom ∷ DOM | eff) Unit)
logger a = do
    _ <- emitter a
    pure unit


patchAndRun :: forall eff w i. VDom (Array (Prop i)) w -> Eff eff Unit
patchAndRun myDom = do
  machine <- getLatestMachine
  newMachine <- step machine (myDom)
  storeMachine newMachine

initUIWithScreen
  :: forall action st eff
   . Screen action st eff Unit
  -> (Either Error Unit -> Eff (ref :: REF, frp :: FRP, dom :: DOM | eff) Unit)
  -> Eff ( ref :: REF, frp :: FRP, dom :: DOM | eff) (Canceler ( ref :: REF, frp :: FRP, dom :: DOM | eff ))
initUIWithScreen { initialState, view, eval } cb = do
  { event, push } <- E.create
  let myDom = view push initialState
  root <- setRootNode Nothing
  _ <- saveScreenName myDom
  machine <- buildVDom (spec root) myDom
  storeMachine machine
  {-- ref ← Ref.newRef machine --}
  insertDom root (extract machine)
  cb $ Right unit
  pure nonCanceler

initUI
  :: forall eff
   . (Either Error Unit -> Eff (ref :: REF, frp :: FRP, dom :: DOM | eff) Unit)
  -> Eff ( ref :: REF, frp :: FRP, dom :: DOM | eff) (Canceler ( ref :: REF, frp :: FRP, dom :: DOM | eff ))
initUI cb = do
  root <- setRootNode Nothing
  _ <- saveScreenName view
  machine <- buildVDom (spec root) view
  storeMachine machine
  insertDom root (extract machine)
  cb $ Right unit
  pure nonCanceler
    where
          view = Elem (ElemSpec Nothing (ElemName "linearLayout") []) []


runScreen
    :: forall action st eff retAction
     . Screen action st eff retAction
    -> (Either Error retAction -> Eff (ref :: REF, frp :: FRP, dom :: DOM | eff) Unit)
    -> Eff ( ref :: REF, frp :: FRP, dom :: DOM | eff ) (Canceler ( ref :: REF, frp :: FRP, dom :: DOM | eff ))
runScreen { initialState, view, eval } cb = do
  { event, push } <- E.create
  let initState = initialState
  let myDom = view push initState
  screenName <- saveScreenName myDom
  patch <- compareScreen (screenName)

  case patch of
    false -> do
        root <- getRootNode
        machine <- buildVDom (spec root) myDom
        storeMachine machine
        insertDom root (extract machine)
        processWidget
    true ->
        patchAndRun myDom
  -- let stateBeh = unfold (\action eitherState -> eitherState >>= (eval action)) event (Right initialState)
  let stateBeh = unfold (\action eitherState -> eitherState >>= (eval action <<< fst)) event (continue initialState)
  _ <- sample_ stateBeh event `subscribe` (either (onExit push) $ onStateChange push)
  pure nonCanceler
    where
          onStateChange push (Tuple state cmds) =
              patchAndRun (view push state)
              *> for_ cmds (\effAction -> effAction >>= push)

          onExit push (Tuple st ret) =
              case st of
                   Just s -> patchAndRun (view push s) *> (cb $ Right ret)
                   Nothing -> cb $ Right ret


          compareScreen (Just currScreen) = do
              screenName <- getPrevScreen
              case screenName of
                   Nothing -> pure false
                   Just screen -> pure $ (screen == currScreen)
          compareScreen Nothing = pure false


saveScreenName :: forall a w eff. VDom a w -> Eff eff (Maybe Namespace)
saveScreenName (Elem (ElemSpec screen _ _) _) = do
    _ <- saveScreenNameImpl screen
    pure screen
saveScreenName _ = do
    _ <- saveScreenNameImpl Nothing
    pure Nothing



mapDom
  :: forall i a b state eff w
   . ((a -> PropEff eff) -> state -> StrMap i -> PrestoDOM (PropEff eff) w)
  -> (b -> PropEff eff)
  -> state
  -> (a -> b)
  -> Array (Tuple String i)
  -> PrestoDOM (PropEff eff) w
mapDom view push state actionMap = unsafeCoerce view (push <<< actionMap) state <<< fromFoldable
