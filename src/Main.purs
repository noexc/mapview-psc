module Main where

import Control.Monad (when)
import Control.Monad.Eff
import Control.Monad.Eff.Ref
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
import Data.String
import Debug.Trace
import MapView.DomHelpers
import qualified MapView.Lookangle as L
import MapView.WSTypes
import MapView.WebSocket
import GMaps.InfoWindow
import GMaps.LatLng
import GMaps.Map
import GMaps.MapOptions
import GMaps.Marker
import GMaps.MVCArray
import GMaps.Polyline
import Global
import MomentJS

--foreign import data DOM :: !

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
  lastReceivedPacket <- newRef Nothing

  doc <- document globalWindow
  --setDismissAnnouncement doc
  Just mapE <- getElementById "map-canvas" doc
  startingPoint <- newLatLng 40.371975 (-83.060578)
  roadmap <- gMap mapE (MapOptions { zoom: 10, center: startingPoint, mapTypeId: "roadmap" })
  mvcA <- newMVCArray :: forall eff. Eff eff (MVCArray LatLng)

  -- Various bits of test data to play with.
  --randomcoord <- newLatLng 41.714754626155 (-73.726791873574)
  --testcoord <- newLatLng 41.714754626155 (-73.726791873574)
  --pushMVCArray mvcA testcoord
  --pushMVCArray mvcA randomcoord

  polyline <- newPolyline (PolylineOptions { geodescic: true
                                           , strokeColor: "#ff0000"
                                           , strokeOpacity: 1.0
                                           , strokeWeight: 2
                                           , map: roadmap
                                           })
  setPolylinePath polyline mvcA

  marker <- newMarker (MarkerOptions { position: startingPoint, map: roadmap, title: "HABP Location", icon: Nothing })
  gpsdMarker <- newMarker (MarkerOptions { position: startingPoint, map: roadmap, title: "Chase Car Location", icon: Just "images/car.png"  })

  -- TODO: info window.
  --iw <- newInfoWindow (InfoWindowOptions { content: "HABP Location" })
  --openInfoWindow iw roadmap marker

  --let example = "{\"coordinates\":{\"latitude\":43.714754626155,\"longitude\":-64.726791873574},\"altitude\":300,\"time\":\"1234321\"}"
  socket <- newWebSocket "ws://127.0.0.1:9160/"
  addEventListenerWS socket "onmessage" $ (\x -> handleEvent x mvcA polyline marker gpsdMarker lastReceivedPacket roadmap)
  --sendWS socket example

  where
    -- This is in purescript-strings#master, but not in a release currently.
    -- Interestingly, indexOf returns a 'Maybe Number' in master too.
    contains x s = indexOf s x /= -1

    handleEvent e mvcA polyline marker gpsdMarker lastReceivedPacket roadmap = do
      msgData <- getData e
      --trace $ "Got: " ++ msgData
      if (msgData `contains` "local:")
        then case readJSON (drop (length "local:") msgData) :: F L.Coordinate of
               Left err -> trace $ "Error parsing JSON:\n" ++ show err
               Right coord@(L.Coordinate lat lon alt) -> do
                 -- TODO: Fix partiality
                 doc <- document globalWindow
                 Just fLat' <- getElementById "f_lat" doc
                 Just fLon' <- getElementById "f_lon" doc
                 Just fAlt' <- getElementById "f_alt" doc
                 setValue (show lat) fLat'
                 setValue (show lon) fLon'
                 setValue (show alt) fAlt'
                 updateCarPosition gpsdMarker coord
                 result <- readRef lastReceivedPacket
                 case result of
                   Just res -> updateLookangle res.coordinates res.altitude
                   _ -> return unit
        else case readJSON msgData :: F WSMessage of
               Left err -> trace $ "Error parsing JSON:\n" ++ show err
               Right (LocationBeacon result) -> do
                 --trace $ unsafeShowJSON result
                 writeRef lastReceivedPacket (Just result)
                 addToPath mvcA polyline marker roadmap result.coordinates
                 updateLookangle result.coordinates result.altitude
                 updateTimestamp result.time
                 updateAltitude result.altitude
                 updateVoltage result.voltage
               Right (BeaconHistory coordinates) -> do
                 --trace $ unsafeShowJSON coordinates
                 traverse_ (addToPath mvcA polyline marker roadmap) coordinates

updateCarPosition ::
  forall eff.
  Marker
  -> L.Coordinate
  -> Eff eff Unit
updateCarPosition marker (L.Coordinate lat lon _) = do
  latlon <- newLatLng lat lon
  setMarkerPosition marker latlon

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
  MVCArray LatLng
  -> Polyline
  -> Marker
  -> Map
  -> Coordinate
  -> Eff eff Unit
addToPath mvcA polyline marker roadmap (Coordinate c) = do
  latestLatLng <- newLatLng c.latitude c.longitude
  pushMVCArray mvcA latestLatLng
  setPolylinePath polyline mvcA
  setMarkerPosition marker latestLatLng
  panTo roadmap latestLatLng

updateAltitude ::
  forall eff.
  Number
  -> Eff (dom :: DOM | eff) Unit
updateAltitude alt = do
  doc <- document globalWindow
  -- TODO: Partial
  Just altField <- getElementById "balloon_altitude" doc
  setInnerHTML (show alt) altField

updateVoltage ::
  forall eff.
  Number
  -> Eff (dom :: DOM | eff) Unit
updateVoltage vlt = do
  doc <- document globalWindow
  -- TODO: Partial
  Just vltField <- getElementById "balloon_voltage" doc
  setInnerHTML (show vlt) vltField


-- TODO: Fix partiality.
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
