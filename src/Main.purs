module Main where

import Control.Monad.Eff
import Data.Either
import Data.Foreign
import Data.Maybe
import Debug.Trace
import DomHelpers
import GMaps.InfoWindow
import GMaps.LatLng
import GMaps.Map
import GMaps.MapOptions
import GMaps.Marker
import GMaps.MVCArray
import GMaps.Polyline
import MapViewWS
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

main = do
  setDismissAnnouncement
  mapE <- getElementById "map-canvas"
  startingPoint <- newLatLng 41.714754626155 (-73.726791873574)
  roadmap <- gMap mapE (MapOptions { zoom: 6, center: startingPoint, mapTypeId: "roadmap" })
  randomcoord <- newLatLng 41.714754626155 (-73.726791873574)
  panTo roadmap randomcoord

  mvcA <- newMVCArray :: forall eff. Eff eff (MVCArray LatLng)
  testcoord <- newLatLng 41.714754626155 (-73.726791873574)
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

  nowMoment <- now
  let leet = momentConstructor "January 1, 0678"
  let leet' = createMoment leet
  lastupdate <- getElementById "lastupdate"
  let str = liftMoment2 momentFrom nowMoment <$> leet'
  let seven = fromMaybe "Unknown" str
  setInnerHtml lastupdate seven

  let example = "{\"coordinates\":{\"latitude\":41.714754626155,\"longitude\":-72.726791873574},\"altitude\":300,\"time\":\"1234321\"}"
  trace $ case parseJSON example of
    Left err -> "Error parsing JSON:\n" ++ err
    Right (LocationBeacon result) -> unsafeShowJSON result

  trace "hi"
  where
    updateMap e = do
      msgData <- getData e
      trace msgData
