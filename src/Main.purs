module Main where

import Control.Monad.Eff
import Data.DOM.Simple.Ajax
import Data.DOM.Simple.Document
import Data.DOM.Simple.Element
import Data.DOM.Simple.Encode
import Data.DOM.Simple.Events hiding (read)
import Data.DOM.Simple.Types
import Data.DOM.Simple.Window
import Data.Either
import Data.Foreign
import Data.Foreign.Class
import Data.Maybe
import Debug.Trace
import DomHelpers hiding (setInnerHtml)
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

setDismissAnnouncement :: forall eff. HTMLDocument -> Eff (dom :: DOM | eff) Unit
setDismissAnnouncement doc = do
  -- TODO: Partial
  Just dismissButton <- getElementById "dismiss_announcement" doc
  Just announcement <- getElementById "announcement" doc
  y <- setDisplayFn announcement "none"
  setOnclick dismissButton y

setAnnouncement :: forall eff. HTMLDocument -> String -> String -> Eff (dom :: DOM | eff) Unit
setAnnouncement doc t c = do
  -- TODO: Partial
  Just announcement <- getElementById "announcement" doc
  Just text <- getElementById "announcement_text" doc
  setInnerHTML t text
  setClass announcement c
  setDisplay announcement "block"

foreign import getData
  "function getData(x) {\
  \  return function() {\
  \    return x.data;\
  \  };\
  \}" :: forall eff. Event -> Eff eff String

main = do
  doc <- document globalWindow
  setDismissAnnouncement doc
  Just mapE <- getElementById "map-canvas" doc
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

  --let example = "{\"coordinates\":{\"latitude\":43.714754626155,\"longitude\":-64.726791873574},\"altitude\":300,\"time\":\"1234321\"}"
  socket <- newWebSocket "ws://127.0.0.1:9160/"
  addEventListenerWS socket "onmessage" $ (\x -> updateMap x mvcA polyline marker)
  --sendWS socket example

  nowMoment <- now
  let leet = momentConstructor "January 1, 0678"
  let leet' = createMoment leet
  Just lastupdate <- getElementById "lastupdate" doc
  let str = liftMoment2 momentFrom nowMoment <$> leet'
  let seven = fromMaybe "Unknown" str
  setInnerHTML seven lastupdate

  trace "hi"
  where
    updateMap e mvcA polyline marker = do
      trace "RX from websocket"
      msgData <- getData e
      case readJSON msgData :: F WSMessage of
        Left err -> trace $ "Error parsing JSON:\n" ++ show err
        Right (LocationBeacon result) -> do
          trace $ unsafeShowJSON result
          case result.coordinates of
            Coordinate coord -> do
              latestLatLng <- newLatLng coord.latitude coord.longitude
              pushMVCArray mvcA latestLatLng
              setPolylinePath polyline mvcA
              setMarkerPosition marker latestLatLng
