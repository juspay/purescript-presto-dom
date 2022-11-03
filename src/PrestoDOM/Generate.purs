module PrestoDOM.Generate where

import Prelude
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Traversable (traverse)
import Data.Tuple (Tuple(..))
import Effect (Effect)
import Foreign (Foreign)
import Halogen.VDom.Types (VDom(..), ElemName(..))
import Halogen.VDom.DOM.Prop (Prop(..), propFromAny)
import Unsafe.Coerce (unsafeCoerce)
import Foreign.Generic (decode)
import Control.Monad.Except(runExcept)
import Data.Either (hush)
import PrestoDOM.Core.Types(Child(..))


foreign import getProps :: forall a b c d. a -> (String -> c -> Prop b) -> d -> Effect (Array (Prop b))
foreign import getVdom :: Effect Foreign
foreign import throwError :: String -> String -> Unit

generateMyDom :: forall a w. Effect (VDom (Array (Prop a)) w)
generateMyDom = do
  x <- getVdom
  generateBuildVdom $ decodeChild x 

generateBuildVdom :: forall a w. Child -> Effect (VDom (Array (Prop a)) w)
generateBuildVdom v@(Child vdom) = do
    vdomProps <- getProps (vdom.props) (prop) (vdom)
    case (fromMaybe "" vdom.elemType) of
        "elem" -> do
            x <- getElemChild v
            pure (Elem Nothing (ElemName vdom.type) (vdomProps) (x))
        "keyed" -> do
            x <- getKeyedChild v
            pure (Keyed Nothing (ElemName vdom.type) (vdomProps) (x))
        x -> unsafeCoerce $ throwError "VDOM Error" $ "Unexpected type" <> x <> "present in vdom" --Crashing intentionally

getElemChild :: forall a w. Child -> Effect (Array (VDom (Array (Prop a)) w))
getElemChild v@(Child vdom) =
  traverse (\a -> do
              let c@(Child child) = (decodeChild a)
              x <- (generateBuildVdom c)
              pure x
            ) vdom.children

getKeyedChild :: forall a w. Child -> Effect (Array (Tuple (String) (VDom (Array (Prop a)) w)))
getKeyedChild v@(Child vdom) =
  traverse (\a -> do
              let c@(Child child) = (decodeChild a)
              x <- (generateBuildVdom c)
              pure (Tuple (fromMaybe "" child.keyId) x)
            ) vdom.children

decodeChild :: Foreign -> Child
decodeChild vdom = case (hush $ runExcept $ decode vdom) of
                      Just ch@(Child c) -> ch
                      _ -> unsafeCoerce $ throwError "VDOM Error" "Decode of vdom child failed"
prop ∷ ∀ a b. String → b → Prop a
prop key val = Property key (propFromAny val)
