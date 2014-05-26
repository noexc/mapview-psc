module Main where

import Data.Array
import Data.Tuple
import Data.Traversable
import Data.Monoid

import Debug.Trace

import Control.Monad.Eff

foreign import data Element :: *
foreign import data Map :: *

foreign import getElementById
  "function getElementById(id) {\
  \  return function() {\
  \    return document.getElementById(id);\
  \  };\
  \}" :: forall eff. String -> Eff eff Element

foreign import setOnclick
  "function setOnclick(ele) {\
  \  return function(f) {\
  \    return function() {\
  \      ele.onclick = f;\
  \      return;\
  \    };\
  \  };\
  \}" :: forall eff a. Element -> (a -> Unit) -> Eff eff Unit

foreign import setDisplayFn
  "function setDisplayFn(ele) {\
  \  return function(s) {\
  \    return function() {\
  \      return function() {\
  \        ele.style.display = s;\
  \        return;\
  \      };\
  \    };\
  \  };\
  \}" :: forall eff. Element -> String -> Eff eff (Unit -> Unit)

foreign import setDisplay
  "function setDisplay(ele) {\
  \  return function(s) {\
  \    return function() {\
  \      ele.style.display = s;\
  \      return;\
  \    };\
  \  };\
  \}" :: forall eff. Element -> String -> Eff eff Unit

foreign import setInnerHtml
  "function setInnerHtml(ele) {\
  \  return function(s) {\
  \    return function() {\
  \      ele.innerHTML = s;\
  \      return;\
  \    };\
  \  };\
  \}" :: forall eff. Element -> String -> Eff eff (Unit -> Unit)

foreign import setClass
  "function setClass(ele) {\
  \  return function(s) {\
  \    return function() {\
  \      ele.className = s;\
  \      return;\
  \    };\
  \  };\
  \}" :: forall eff. Element -> String -> Eff eff (Unit -> Unit)

data MapOptions = MapOptions {
    zoom :: Number
  , center :: LatLng
  , mapTypeId :: String
  }

foreign import gMap
  "function gMap(ele) {\
  \  return function(opts) {\
  \    return function() {\
  \      return (new google.maps.Map(ele, opts.values[0]));\
  \    };\
  \  };\
  \}" :: forall eff. Element -> MapOptions -> Eff eff Map

data LatLng

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

setDismissAnnouncement :: forall eff. Eff eff Unit
setDismissAnnouncement = do
  dismissButton <- getElementById "dismiss_announcement"
  announcement <- getElementById "announcement"
  y <- setDisplayFn announcement "none"
  setOnclick dismissButton y

setAnnouncement :: forall eff. String -> String -> Eff eff Unit
setAnnouncement t c = do
  announcement <- getElementById "announcement"
  text <- getElementById "announcement_text"
  setInnerHtml text t
  setClass announcement c
  setDisplay announcement "block"

main :: Eff (trace :: Trace) {}
main = do
  setDismissAnnouncement
  mapE <- getElementById "map-canvas"
  startingPoint <- newLatLng 0.0 0.0
  roadmap <- gMap mapE (MapOptions { zoom: 6, center: startingPoint, mapTypeId: "roadmap" })
  randomcoord <- newLatLng (-34.397) 150.644
  panTo roadmap randomcoord
  trace "hi"
