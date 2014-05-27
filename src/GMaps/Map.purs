module GMaps.Map where

import Control.Monad.Eff
import DomHelpers
import GMaps.LatLng
import GMaps.MapOptions

foreign import data Map :: *

foreign import gMap
  "function gMap(ele) {\
  \  return function(opts) {\
  \    return function() {\
  \      return (new google.maps.Map(ele, opts.values[0]));\
  \    };\
  \  };\
  \}" :: forall eff. Element -> MapOptions -> Eff eff Map


foreign import panTo
  "function panTo(map) {\
  \  return function(x) {\
  \    return function() {\
  \      map.panTo(x);\
  \      return;\
  \    };\
  \  };\
  \}" :: forall eff. Map -> LatLng -> Eff eff Unit

