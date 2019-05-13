module PrestoDOM.Screen
  ( ScreenStack(..)
  , ScreenCache(..)
  , stackInitialize
  {-- , stackLookup --}
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

type ScreenStack a = Stack.Stack (Tuple String a)


stackInitialize :: forall a. ScreenStack a
stackInitialize =
  Stack.stackNew

{-- stackLookup :: forall a. String -> ScreenStack a -> Maybe a --}
{-- stackLookup screenName (ScreenStack _ obj) = Object.lookup screenName obj --}

stackPush :: forall a. String -> a -> ScreenStack a -> ScreenStack a
stackPush screenName screen stack =
  Stack.stackPush stack $ Tuple screenName screen


-- returns updated stack, and Array of (key, value)  poped elems.
stackPopTill :: forall a. String -> ScreenStack a -> Tuple (ScreenStack a) (Array (Tuple String a))
stackPopTill screenName stack =
  pop stack []
  where
    pop sStack acc =
      case Stack.stackPop sStack of
        Just (Tuple rStack i@(Tuple name item)) ->
          if name == screenName
            -- halt condition, return same val without modify.
            then Tuple sStack acc
            else pop rStack $ snoc acc i
        Nothing -> Tuple sStack acc

type ScreenCache a = Object.Object a

cacheInitialize :: forall a. ScreenCache a
cacheInitialize = Object.empty

cacheLookup :: forall a. String -> ScreenCache a -> Maybe a
cacheLookup = Object.lookup

cacheInsert :: forall a. String -> a -> ScreenCache a -> ScreenCache a
cacheInsert = Object.insert

cacheDelete :: forall a. String -> ScreenCache a -> ScreenCache a
cacheDelete = Object.delete
