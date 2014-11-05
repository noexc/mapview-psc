# Module Documentation

## Module DomHelpers

### Values

    setClass :: forall eff. HTMLElement -> String -> Eff eff (Unit -> Unit)

    setDisplay :: forall eff. HTMLElement -> String -> Eff eff Unit

    setDisplayFn :: forall eff. HTMLElement -> String -> Eff eff (Unit -> Unit)

    setOnclick :: forall eff a. HTMLElement -> (a -> Unit) -> Eff eff Unit


## Module GMaps

## Module GMaps.InfoWindow

### Types

    data InfoWindow :: *

    data InfoWindowOptions where
      InfoWindowOptions :: { content :: String } -> InfoWindowOptions

    type InfoWindowOptionsR = { content :: String }


### Values

    newInfoWindow :: forall eff. InfoWindowOptions -> Eff eff InfoWindow

    newInfoWindowFFI :: forall eff. InfoWindowOptionsR -> Eff eff InfoWindow

    openInfoWindow :: forall eff. InfoWindow -> Map -> Marker -> Eff eff Unit

    runInfoWindowOptions :: InfoWindowOptions -> InfoWindowOptionsR


## Module GMaps.LatLng

### Types

    data LatLng


### Values

    newLatLng :: forall eff. Number -> Number -> Eff eff LatLng


## Module GMaps.MVCArray

### Types

    data MVCArray :: * -> *


### Values

    newMVCArray :: forall eff a. Eff eff (MVCArray a)

    popMVCArray :: forall a eff. MVCArray a -> Eff eff a

    pushMVCArray :: forall a eff. MVCArray a -> a -> Eff eff Unit


## Module GMaps.Map

### Types

    data Map :: *


### Values

    gMap :: forall eff. HTMLElement -> MapOptions -> Eff eff Map

    panTo :: forall eff. Map -> LatLng -> Eff eff Unit


## Module GMaps.MapOptions

### Types

    data MapOptions where
      MapOptions :: { mapTypeId :: String, center :: LatLng, zoom :: Number } -> MapOptions


### Values

    runMapOptions :: MapOptions -> { mapTypeId :: String, center :: LatLng, zoom :: Number }


## Module GMaps.Marker

### Types

    data Marker :: *

    data MarkerOptions where
      MarkerOptions :: { title :: String, map :: Map, position :: LatLng } -> MarkerOptions

    type MarkerOptionsR = { title :: String, map :: Map, position :: LatLng }


### Values

    newMarker :: forall eff. MarkerOptions -> Eff eff Marker

    newMarkerFFI :: forall eff. MarkerOptionsR -> Eff eff Marker

    runMarkerOptions :: MarkerOptions -> MarkerOptionsR

    setMarkerPosition :: forall eff. Marker -> LatLng -> Eff eff Unit


## Module GMaps.Polyline

### Types

    data Polyline :: *

    data PolylineOptions where
      PolylineOptions :: { map :: Map, strokeWeight :: Number, strokeOpacity :: Number, strokeColor :: String, geodescic :: Boolean } -> PolylineOptions


### Values

    newPolyline :: forall eff. PolylineOptions -> Eff eff Polyline

    setPolylinePath :: forall eff. Polyline -> MVCArray LatLng -> Eff eff Unit


## Module Lookangle

### Types

    type Altitude = Number

    data AzElCord where
      AzelCord :: { range :: Number, elevation :: Number, azimuth :: Number } -> AzElCord

    data Coordinate where
      Coordinate :: Latitude -> Longitude -> Altitude -> Coordinate

    type Latitude = Number

    type Longitude = Number


### Values

    lookAngle :: Coordinate -> Coordinate -> AzElCord


## Module Main

### Values

    addToPath :: forall eff. MVCArray LatLng -> Polyline -> Marker -> Coordinate -> Eff eff Unit

    getData :: forall eff. Event -> Eff eff String

    setAnnouncement :: forall eff. HTMLDocument -> String -> String -> Eff (dom :: DOM | eff) Unit

    setDismissAnnouncement :: forall eff. HTMLDocument -> Eff (dom :: DOM | eff) Unit

    updateLookangle :: forall eff a. { altitude :: Number, coordinates :: Coordinate | a } -> Eff (trace :: Debug.Trace.Trace, dom :: DOM | eff) Unit


## Module MapViewWS

### Types

    data Coordinate where
      Coordinate :: { longitude :: Number, latitude :: Number } -> Coordinate

    data WSMessage where
      LocationBeacon :: { time :: String, altitude :: Number, coordinates :: Coordinate } -> WSMessage
      BeaconHistory :: [Coordinate] -> WSMessage


### Type Class Instances

    instance readCoordinate :: IsForeign Coordinate

    instance readWSMessage :: IsForeign WSMessage


### Values

    unsafeShowJSON :: forall a. a -> String


## Module MomentJS

### Types

    data JSMoment :: *

    data Moment a where
      Moment :: JSMoment -> Moment a
      UTCMoment :: JSMoment -> Moment a

    data Now :: !

    data UTCMoment :: *


### Values

    createMoment :: forall a. JSMoment -> Maybe (Moment a)

    liftMoment :: forall a. (JSMoment -> a) -> Moment a -> a

    liftMoment2 :: forall a b. (JSMoment -> JSMoment -> a) -> Moment b -> Moment b -> a

    momentConstructor :: forall a. a -> JSMoment

    momentFrom :: JSMoment -> JSMoment -> String

    momentMethod :: forall a. String -> JSMoment -> a

    now :: forall e. Eff (now :: Now | e) (Moment JSMoment)

    utcMomentConstructor :: forall a. a -> JSMoment

    utcNow :: forall e. Eff (now :: Now | e) (Moment UTCMoment)


## Module WebSocket

### Types

    data Event :: *

    data WebSocket :: *


### Values

    addEventListenerWS :: forall eff. WebSocket -> String -> (Event -> Eff eff Unit) -> Eff eff Unit

    newWebSocket :: forall eff a. String -> Eff eff WebSocket

    sendWS :: forall eff. WebSocket -> String -> Eff eff Unit