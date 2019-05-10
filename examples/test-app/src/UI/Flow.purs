module UI.Flow where

import Prelude

import Presto.Core.Types.Language.Flow (Flow)
import UI.Controller (ExitAction(..))
import UI.Controller as Controller

genericScreenFlow :: Controller.ExitAction -> Flow Unit
genericScreenFlow ScreenA = pure unit
genericScreenFlow ScreenB = pure unit
genericScreenFlow ScreenC = pure unit
genericScreenFlow ScreenD = pure unit
genericScreenFlow ShowLoader = pure unit
genericScreenFlow ShowPopUP = pure unit
genericScreenFlow BackPress = pure unit
genericScreenFlow Click = pure unit