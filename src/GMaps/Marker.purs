module GMaps.Marker where

import Control.Monad.Eff
import GMaps.LatLng
import GMaps.Map

data MarkerOptions = MarkerOptions
  { position :: LatLng
  , map :: Map
  , title :: String
  }

data Marker

foreign import newMarker
  "function newMarker(opts) {\
  \  return function() {\
  \    return new google.maps.Marker(opts.values[0]);\
  \  };\
  \}" :: forall eff. MarkerOptions -> Eff eff Marker

foreign import setMarkerPosition
  "function setMarkerPosition(marker) {\
  \  return function(latlng) {\
  \    return function() {\
  \      return marker.setPosition(latlng);\
  \    };\
  \  };\
  \}" :: forall eff. MarkerOptions -> Eff eff {}
