module MapView.Leaflet where

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
import MapView.DomHelpers
import Global
import Leaflet.LatLng
import Leaflet.LatLngBounds
import Leaflet.Map
import Leaflet.Marker
import Leaflet.Polyline
import Leaflet.TileLayer
import Leaflet.Types
import MapView.WSTypes

streetMap = do
  tile <- tileLayer "http://otile{s}.mqcdn.com/tiles/1.0.0/osm/{z}/{x}/{y}.jpg"
          $ { subdomains: [ "1", "2", "3", "4" ] }
  return $ toILayer tile

temp = do
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

addToPathLeaflet ::
  forall eff.
  Polyline
  -- -> Marker
  -> Map
  -> Coordinate
  -> Eff eff Unit
--addToPath polyline marker roadmap (Coordinate c) = do
addToPathLeaflet polyline roadmap (Coordinate c) = do
  addLatLng (latLng c.latitude c.longitude) polyline
  return unit
  --setMarkerPosition marker latestLatLng
  --panTo roadmap latestLatLng
