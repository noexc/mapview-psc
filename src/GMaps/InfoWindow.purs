module GMaps.InfoWindow where

import Control.Monad.Eff
import GMaps.Map
import GMaps.Marker

data InfoWindowOptions = InfoWindowOptions
  { content :: String
  }

data InfoWindow

foreign import newInfoWindow
  "function newInfoWindow(opts) {\
  \  return function() {\
  \    return new google.maps.InfoWindow(opts.values[0]);\
  \  };\
  \}" :: forall eff. InfoWindowOptions -> Eff eff InfoWindow

foreign import openInfoWindow
  "function openInfoWindow(iw) {\
  \  return function(map) {\
  \    return function(marker) {\
  \      return function() {\
  \        iw.open(map, marker);\
  \        return;\
  \      };\
  \    };\
  \  };\
  \}" :: forall eff. InfoWindow -> Map -> Marker -> Eff eff {}
