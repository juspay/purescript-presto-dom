module Widget.CanvasJS.Charts where

import Prelude

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Ref (REF)
import Data.Exists (Exists, mkExists, runExists)
import Data.Function.Uncurried as Fn

import DOM.Node.Types (Node) as DOM
import PrestoDOM
import PrestoDOM.Core (Thunk(..))

import DOM (DOM)
import FRP (FRP)
import Halogen.VDom as V
import Halogen.VDom.Util (refEq)

import Unsafe.Coerce (unsafeCoerce)


foreign import createChart :: forall a e. String -> ChartData a -> Eff e DOM.Node

foreign import renderChart :: forall e. Eff e Unit

-- you may use some predefined purescript date library instead of this
foreign import newDate :: Fn.Fn3 Int Int Int NewDate
foreign import toogleDataSeries :: forall a. a -> Unit


foreign import data NewDate :: Type
foreign import data Chart :: Type


type Crosshair =
  { enabled :: Boolean
  , snapToDataPoint :: Boolean
  }



type DataPoint = { x :: NewDate, y :: Int }


type PlotData =
  { "type" :: String
   , showInLegend :: Boolean
   , name :: String
   , lineDashType :: String
   , markerType :: String
   , xValueFormatString :: String
   , color :: String
   , dataPoints :: Array DataPoint
   }

type ChartData a =
  { animationEnabled :: Boolean
  , theme :: String
  , title :: { text :: String
            }
  , axisX :: { valueFormatString :: String
            , crosshair :: Crosshair
            }
  , axisY :: { title :: String
            , crosshair :: Crosshair
            }
  , toolTip :: { shared :: Boolean }
  , legend :: { cursor :: String
             , verticalAlign :: String
             , horizontalAlign :: String
             , dockInsidePlotArea :: Boolean
             , itemclick :: (a -> Unit)
             }
  , "data" :: Array PlotData
  }



chartData :: forall a. ChartData a
chartData =
  { animationEnabled : true
  , theme : "light2"
  , title : { text : "Site Traffic"
            }
  , axisX : { valueFormatString: "DD MMM"
            , crosshair: { enabled : true
                         , snapToDataPoint : true
                         }
            }
  , axisY : { title: "Number of Visits"
            , crosshair : { enabled : true
                          , snapToDataPoint : false
                          }
            }
  , toolTip : { shared : true }
  , legend : { cursor : "pointer"
             , verticalAlign : "bottom"
             , horizontalAlign : "left"
             , dockInsidePlotArea : true
             , itemclick : toogleDataSeries
             }
  , "data" : plotData
  }


plotData :: Array PlotData
plotData = [{ "type" : "line"
             , showInLegend: true
             , name : "Total Visit"
             , markerType : "square"
             , xValueFormatString : "DD MMM, YYYY"
             , color : "#F08080"
             , lineDashType: ""
             , dataPoints : dataPointTotalVisit
	           }
          , { "type" : "line"
            , showInLegend : true
            , name: "Unique Visit"
            , markerType : "circle"
            , xValueFormatString : ""
            , color : "green"
            , lineDashType: "dash"
            , dataPoints: dataPointUniqueVisit
            }
          ]

dataPointTotalVisit :: Array DataPoint
dataPointTotalVisit = [ { x: (Fn.runFn3 newDate 2017 0 3), y: 650 },
      { x: (Fn.runFn3 newDate 2017 0 4), y: 700 },
      { x: (Fn.runFn3 newDate 2017 0 5), y: 710 },
      { x: (Fn.runFn3 newDate 2017 0 6), y: 658 },
			{ x: (Fn.runFn3 newDate 2017 0 7), y: 734 },
			{ x: (Fn.runFn3 newDate 2017 0 8), y: 963 },
			{ x: (Fn.runFn3 newDate 2017 0 9), y: 847 },
			{ x: (Fn.runFn3 newDate 2017 0 10), y: 853 },
			{ x: (Fn.runFn3 newDate 2017 0 11), y: 869 },
			{ x: (Fn.runFn3 newDate 2017 0 12), y: 943 },
			{ x: (Fn.runFn3 newDate 2017 0 13), y: 970 },
			{ x: (Fn.runFn3 newDate 2017 0 14), y: 869 },
			{ x: (Fn.runFn3 newDate 2017 0 15), y: 890 },
			{ x: (Fn.runFn3 newDate 2017 0 16), y: 930 }
		]

dataPointUniqueVisit :: Array DataPoint
dataPointUniqueVisit = [ { x: (Fn.runFn3 newDate 2017 0 3), y: 510 },
			{ x: (Fn.runFn3 newDate 2017 0 4), y: 560 },
			{ x: (Fn.runFn3 newDate 2017 0 5), y: 540 },
			{ x: (Fn.runFn3 newDate 2017 0 6), y: 558 },
			{ x: (Fn.runFn3 newDate 2017 0 7), y: 544 },
			{ x: (Fn.runFn3 newDate 2017 0 8), y: 693 },
			{ x: (Fn.runFn3 newDate 2017 0 9), y: 657 },
			{ x: (Fn.runFn3 newDate 2017 0 10), y: 663 },
			{ x: (Fn.runFn3 newDate 2017 0 11), y: 639 },
			{ x: (Fn.runFn3 newDate 2017 0 12), y: 673 },
			{ x: (Fn.runFn3 newDate 2017 0 13), y: 660 },
			{ x: (Fn.runFn3 newDate 2017 0 14), y: 562 },
			{ x: (Fn.runFn3 newDate 2017 0 15), y: 643 },
			{ x: (Fn.runFn3 newDate 2017 0 16), y: 570 }
		]


type VDom e = V.VDom (Array (Prop (PropEff e))) (Exists (Thunk e))


siteTraffic
	:: forall a e
   . {viewID :: String, cData :: ChartData a}
	-> VDom e
siteTraffic val = V.Widget (mkExists (Thunk val renderCanvasJS))


renderCanvasJS :: forall a e. {viewID :: String, cData :: ChartData a} -> Eff e DOM.Node
renderCanvasJS {viewID, cData} = createChart viewID cData


