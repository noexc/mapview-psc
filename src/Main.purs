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
import Data.Foldable (traverse_)
import Data.Foreign
import Data.Foreign.Class
import Data.Maybe
import Debug.Trace
import DomHelpers
import Leaflet.LatLng
import Leaflet.LatLngBounds
import Leaflet.Map
import Leaflet.Marker
import Leaflet.Polyline
import Leaflet.TileLayer
import Leaflet.Types
import Global
import qualified Lookangle as L
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


streetMap = do
  tile <- tileLayer "http://{s}.mqcdn.com/tiles/1.0.0/osm/{z}/{x}/{y}.jpg"
          $ { subdomains: [ "otile1", "otile2", "otile3", "otile4" ] }
  return $ toILayer tile

main = do
  doc <- document globalWindow
  --setDismissAnnouncement doc
  let startingPoint = latLng 40.371975 (-83.060578)
  -- TODO: Make bounds not be required in -leaflet.
  bounds <- pad 0.5 $ latLngBounds startingPoint startingPoint
  tiles <- streetMap
  roadmap <- createMap "map-canvas" { attributionControl: false
                                    , center: startingPoint
                                    , layers: [tiles]
                                    , maxBounds: bounds
                                    , zoom: 8
                                    }

  -- Various bits of test data to play with.
  --randomcoord <- newLatLng 41.714754626155 (-73.726791873574)
  --testcoord <- newLatLng 41.714754626155 (-73.726791873574)
  --pushMVCArray mvcA testcoord
  --pushMVCArray mvcA randomcoord

  let polyline' = polyline [] { stroke: true
                              , color: "#03f"
                              , weight: 5
                              , opacity: 0.8
                              , fill: false
                              , fillColor: "#03f"
                              , fillOpacity: 0.8
                              , dashArray: ""
                              , lineCap: ""
                              , lineJoin: ""
                              , clickable: true
                              , pointerEvents: ""
                              , className: ""
                              , smoothFactor: 1.0
                              , noClip: false
                              }

  addTo polyline' roadmap

  --marker <- newMarker (MarkerOptions { position: startingPoint, map: roadmap, title: "HABP Location" })

  -- TODO: info window.
  --iw <- newInfoWindow (InfoWindowOptions { content: "HABP Location" })
  --openInfoWindow iw roadmap marker

  --let example = "{\"coordinates\":{\"latitude\":43.714754626155,\"longitude\":-64.726791873574},\"altitude\":300,\"time\":\"1234321\"}"
  socket <- newWebSocket "ws://mv-ws1-b.elrod.me:9160/"
  addEventListenerWS socket "onmessage" $ (\x -> handleEvent x polyline' marker roadmap)
  --sendWS socket example

  where
    handleEvent e polyline marker roadmap = do
      --trace "RX from websocket"
      msgData <- getData e
      --trace msgData
      case readJSON msgData :: F WSMessage of
        Left err -> do
          trace $ "Error parsing JSON: " ++ show err ++ "\n"
          trace $ "Received data was: " ++ show msgData
        Right (LocationBeacon result) -> do
          --trace $ unsafeShowJSON result
          --addToPath polyline marker roadmap result.coordinates
          addToPath polyline roadmap result.coordinates
          updateLookangle result.coordinates result.altitude
          updateTimestamp result.time
          updateTemperature result.temperature
        Right (BeaconHistory coordinates) -> do
          --trace $ unsafeShowJSON coordinates
          --traverse_ (addToPath polyline marker roadmap) coordinates
          traverse_ (addToPath polyline roadmap) coordinates

updateTemperature ::
  forall eff.
  Celsius
  -> Eff (dom :: DOM | eff) Unit
updateTemperature temp = do
  doc <- document globalWindow
  Just tempField <- getElementById "temperature" doc
  setInnerHTML (show temp) tempField

updateTimestamp ::
  forall eff.
  String
  -> Eff (dom :: DOM, now :: MomentJS.Now | eff) Unit
updateTimestamp time = do
  doc <- document globalWindow
  --nowMoment <- now
  --let last = createMoment (momentConstructor time)
  Just lastupdate <- getElementById "lastupdate" doc
  --let str = liftMoment2 momentFrom nowMoment <$> last
  --let humanReadableTime = fromMaybe "Unknown" str
  setInnerHTML time lastupdate

addToPath ::
  forall eff.
  Polyline
  -- -> Marker
  -> Map
  -> Coordinate
  -> Eff eff Unit
--addToPath polyline marker roadmap (Coordinate c) = do
addToPath polyline roadmap (Coordinate c) = do
  addLatLng (latLng c.latitude c.longitude) polyline
  return unit
  --setMarkerPosition marker latestLatLng
  --panTo roadmap latestLatLng

updateLookangle ::
  forall eff a.
  Coordinate
  -> Number
  -> Eff (dom :: DOM | eff) Unit
updateLookangle (Coordinate c) altitude = do
  doc <- document globalWindow
  Just lookangle <- getElementById "lookangle" doc
  Just fLat' <- getElementById "f_lat" doc
  Just fLon' <- getElementById "f_lon" doc
  Just fAlt' <- getElementById "f_alt" doc
  fLat <- readFloat <$> value fLat'
  fLon <- readFloat <$> value fLon'
  fAlt <- readFloat <$> value fAlt'
  let angle = L.lookAngle
              (L.Coordinate fLat fLon fAlt)
              (L.Coordinate c.latitude c.longitude altitude)
  setInnerHTML (show angle) lookangle
