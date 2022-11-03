module PrestoDOM.Core.Types where

import Prelude

import Control.Alt ((<|>))
import Data.Maybe (Maybe)
import Effect (Effect)
import Foreign (Foreign)
import Foreign.Object (Object)
import Halogen.VDom (Step)
import Foreign.Class (class Decode, class Encode, decode)
import FRP.Event (EventIO)
import Unsafe.Coerce (unsafeCoerce)
import PrestoDOM.Types.Core (PrestoDOM)
import Presto.Core.Utils.Encoding (defaultDecode, defaultEncode)
import Data.Newtype (class Newtype)
import Data.Generic.Rep (class Generic)

-- Changing types to unify types for all screens
foreign import data Machine :: Type
foreign import data Event :: Type

makeMachine :: forall a b. Step a b -> Machine
makeMachine = unsafeCoerce

unMachine :: forall a b. Machine -> Step a b
unMachine = unsafeCoerce

makeEvent :: forall a. EventIO a -> Event
makeEvent = unsafeCoerce

unEvent :: forall a. Event -> EventIO a
unEvent = unsafeCoerce

type NameSpaceState w i = 
  { id :: Maybe String
  , root :: PrestoDOM w i
  , machineMap :: Object Machine
  , screenStack :: Array String
  , hideList :: Array String
  , removeList :: Array String
  , screenCache :: Array String
  , screenHideCallbacks :: Object (Effect Unit)
  , screenShowCallbacks :: Object (Effect Unit)
  , screenRemoveCallbacks :: Object (Effect Unit)
  , cancelers :: Object (Effect Unit)
  , stackRoot :: Int
  , cacheRoot :: Int
  , animations :: AnimationState
  , registeredEvents :: Object (Object (Effect Unit))
  , shouldHideCacheRoot :: Boolean
  , mappQueue :: Array MicroappData -- Create the type for this
  , fragmentCallbacks :: Object (Array FragmentCallback) -- create the type for this
  , shouldReplayCallbacks :: Object Boolean
  , eventIOs :: Object Event
  }

type AnimationState =
  { entry :: Object (Object AnimationObject)
  , exit :: Object (Object AnimationObject)
  , entryF :: Object (Object AnimationObject)
  , exitF :: Object (Object AnimationObject)
  , entryB :: Object (Object AnimationObject)
  , exitB :: Object (Object AnimationObject)
  , animationStack :: Array String
  , animationCache :: Array String
  , lastAnimatedScreen :: Maybe String
  }

type AnimationObject =
  { visibility :: String
  , inlineAnimation :: String
  , onAnimationEnd :: String -> Unit
  , type :: String
  }

type MicroappData =
  { payload :: String
  , viewGroupTag :: String
  , useLinearLayout :: Maybe Boolean
  , requestId :: String
  , service :: String
  , elemId :: String
  , callback :: forall a. (a -> Effect Unit)
  }

type FragmentCallback =
  { payload :: { code :: Int
    , message :: String
    }
  , callback :: forall a. (a -> Effect Unit)
  }

type VdomTree = {
      "type" :: String
    , children :: Array Foreign
    , props :: Object Foreign
    , parentType :: Foreign
    , __ref :: Maybe {__id :: Foreign}
    , service :: Maybe String
    , requestId :: Maybe String
    , elemType :: Maybe String
    , keyId :: Maybe String
    }
newtype Child = Child 
  { keyId :: Maybe String, 
    type :: String, 
    children :: Array (Foreign), 
    props :: Foreign, 
    elemType :: Maybe String
  }

derive instance genericChild :: Generic Child _
derive instance newtypeChild :: Newtype Child _
instance decodeChild :: Decode Child where decode = defaultDecode
instance encodeChild :: Encode Child where encode = defaultEncode


-- props Object Foreign
-- __ref : {__id : Int}
-- type
-- requestId
-- service
-- Children Array DOM.Node
data NodeTree 
  = NodeTree {
      "type" :: String
    , children :: Array NodeTree
    , props :: Object Foreign
    , requestId :: Maybe String
    , service :: Maybe String
    }
  | NodeEnd

instance decodeNodeTree :: Decode NodeTree where
  decode a = 
    NodeTree <$> decode a -- TRY TO DECODE TO NODE
    <|> pure NodeEnd -- IF DECODE FAILS; DONT FAIL ENTIRE TREE; ALWAYS FALLBACK TO END

type InsertState =
  { rootId :: Foreign
  , dom :: Foreign
  , length :: Foreign
  , callback :: Foreign
  , id :: Foreign
  }

type UpdateActions =
  { action :: String
  , parent :: VdomTree
  , elem :: VdomTree
  , index :: Int
  }

type ListItemType =
  { itemView :: Foreign
  , holderViews :: Array (Object Foreign)
  , keyPropMap :: Object (Object String)
  , keyIdMap :: Object String
  , animationIdMap :: Object Foreign
  }