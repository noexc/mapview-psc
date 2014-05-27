module Main where

import Data.Array
import Data.Tuple
import Data.Traversable
import Data.Monoid

import Debug.Trace

import Control.Monad.Eff

import DomHelpers
import GMaps
import WebSocket

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

foreign import getData
  "function getData(x) {\
  \  return function() {\
  \    return x.data;\
  \  };\
  \}" :: forall eff. Event -> Eff eff String

main :: Eff (trace :: Trace) {}
main = do
  setDismissAnnouncement
  mapE <- getElementById "map-canvas"
  startingPoint <- newLatLng 0.0 0.0
  roadmap <- gMap mapE (MapOptions { zoom: 6, center: startingPoint, mapTypeId: "roadmap" })
  randomcoord <- newLatLng (-34.397) 150.644
  panTo roadmap randomcoord

  marker <- newMarker (MarkerOptions { position: randomcoord, map: roadmap, title: "HABP Location" })
  iw <- newInfoWindow (InfoWindowOptions { content: "HABP Location" })
  openInfoWindow iw roadmap marker

  socket <- newWebSocket "ws://echo.websocket.org/"
  addEventListenerWS socket "onmessage" updateMap
  sendWS socket "testing"

  trace "hi"
  where
    updateMap e = do
      msgData <- getData e
      trace msgData
