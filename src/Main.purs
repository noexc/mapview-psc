module Main where

import Data.Array
import Data.Tuple
import Data.Traversable
import Data.Monoid

import Debug.Trace

import Control.Monad.Eff

import DomHelpers

import GMaps.InfoWindow
import GMaps.LatLng
import GMaps.Map
import GMaps.MapOptions
import GMaps.Marker
import GMaps.MVCArray
import GMaps.Polyline

import MomentJS

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

  mvcA <- newMVCArray :: forall eff. Eff eff (MVCArray LatLng)
  testcoord <- newLatLng (-34.397) 151.644
  pushMVCArray mvcA testcoord
  pushMVCArray mvcA randomcoord

  polyline <- newPolyline (PolylineOptions { geodescic: true
                                           , strokeColor: "#ff0000"
                                           , strokeOpacity: 1.0
                                           , strokeWeight: 2
                                           , map: roadmap
                                           })
  setPolylinePath polyline mvcA

  marker <- newMarker (MarkerOptions { position: randomcoord, map: roadmap, title: "HABP Location" })
  iw <- newInfoWindow (InfoWindowOptions { content: "HABP Location" })
  openInfoWindow iw roadmap marker

  socket <- newWebSocket "ws://echo.websocket.org/"
  addEventListenerWS socket "onmessage" updateMap
  sendWS socket "testing"

  leet <- timeAgo "0678" "YYYY"
  lastupdate <- getElementById "lastupdate"
  setInnerHtml lastupdate leet

  trace "hi"
  where
    updateMap e = do
      msgData <- getData e
      trace msgData
