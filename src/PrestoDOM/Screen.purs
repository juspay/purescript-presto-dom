module PrestoDOM.Screen
  ( ScreenStack(..)
  , ScreenCache(..)
  , stackInitialize
  , stackLookup
  , stackPush
  , stackPopTill
  , cacheInitialize
  , cacheLookup
  , cacheInsert
  , cacheDelete
  ) where

import Prelude

import Data.Array (snoc)
import Data.Maybe (Maybe(..))
import Data.Stack (Stack, stackNew, stackPush, stackPop) as Stack
import Data.Tuple (Tuple(..))
import Foreign.Object as Object

data ScreenStack a = ScreenStack (Stack.Stack (Tuple String a)) (Object.Object a)


stackInitialize :: forall a. ScreenStack a
stackInitialize =
  ScreenStack Stack.stackNew Object.empty

stackLookup :: forall a. String -> ScreenStack a -> Maybe a
stackLookup screenName (ScreenStack _ obj) = Object.lookup screenName obj

stackPush :: forall a. String -> a -> ScreenStack a -> ScreenStack a
stackPush screenName screen (ScreenStack stack obj) =
  ScreenStack
    (Stack.stackPush stack $ Tuple screenName screen)
    (Object.insert screenName screen obj)


-- returns updated stack, and Array of (key, value)  poped elems.
stackPopTill :: forall a. String -> ScreenStack a -> Tuple (ScreenStack a) (Array (Tuple String a))
stackPopTill screenName s@(ScreenStack stack obj) =
  case Object.lookup screenName obj of
    Just a -> pop s []
    Nothing -> Tuple s []

  where
    pop ss@(ScreenStack sStack sObj) acc =
      case Stack.stackPop sStack of
        Just (Tuple rStack i@(Tuple name item)) ->
          if name == screenName
            -- halt condition, return same val without modify.
            then Tuple ss acc
            else pop (ScreenStack rStack (Object.delete name sObj)) $ snoc acc i
        Nothing -> Tuple ss acc

type ScreenCache a = Object.Object a

cacheInitialize :: forall a. ScreenCache a
cacheInitialize = Object.empty

cacheLookup :: forall a. String -> ScreenCache a -> Maybe a
cacheLookup = Object.lookup

cacheInsert :: forall a. String -> a -> ScreenCache a -> ScreenCache a
cacheInsert = Object.insert

cacheDelete :: forall a. String -> ScreenCache a -> ScreenCache a
cacheDelete = Object.delete
