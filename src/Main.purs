module Main where

import Data.Array
import Data.Tuple
import Data.Traversable
import Data.Monoid

import Debug.Trace

import Control.Monad.Eff

import Graphics.Canvas
import Graphics.Canvas.Drawing

foreign import data Element :: *
foreign import data Map :: *

foreign import getElementById
  "function getElementById(id) {\
  \  return function() {\
  \    return document.getElementById(id);\
  \  };\
  \}" :: forall eff. String -> Eff eff CanvasElement

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
  \}" :: forall eff. CanvasElement -> MapOptions -> Eff eff Map

data LatLng

foreign import newLatLng
  "function newLatLng(x) {\
  \  return function(y) {\
  \    return function() {\
  \      return (new google.maps.LatLng(x, y));\
  \    };\
  \ };\
  \}" :: forall eff. Number -> Number -> Eff eff LatLng



main = do
  mapE <- getElementById "map-canvas"
  startingPoint <- newLatLng 0.0 0.0
  gMap mapE (MapOptions { zoom: 6, center: startingPoint, mapTypeId: "roadmap" })
  trace "hi"
