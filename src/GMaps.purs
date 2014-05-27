module GMaps where

import Control.Monad.Eff

import DomHelpers

data MapOptions = MapOptions
  { zoom :: Number
  , center :: LatLng
  , mapTypeId :: String
  }

data MarkerOptions = MarkerOptions
  { position :: LatLng
  , map :: Map
  , title :: String
  }

data InfoWindowOptions = InfoWindowOptions
  { content :: String
  }

data InfoWindow

data Marker

foreign import data Map :: *
data LatLng

foreign import gMap
  "function gMap(ele) {\
  \  return function(opts) {\
  \    return function() {\
  \      return (new google.maps.Map(ele, opts.values[0]));\
  \    };\
  \  };\
  \}" :: forall eff. Element -> MapOptions -> Eff eff Map


foreign import newLatLng
  "function newLatLng(x) {\
  \  return function(y) {\
  \    return function() {\
  \      return (new google.maps.LatLng(x, y));\
  \    };\
  \ };\
  \}" :: forall eff. Number -> Number -> Eff eff LatLng

foreign import panTo
  "function panTo(map) {\
  \  return function(x) {\
  \    return function() {\
  \      map.panTo(x);\
  \      return;\
  \    };\
  \  };\
  \}" :: forall eff. Map -> LatLng -> Eff eff Unit

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
