# Module Documentation

## Module Main

### Values

    addToPath :: forall eff. MVCArray LatLng -> Polyline -> Marker -> Map -> Coordinate -> Eff eff Unit

    getData :: forall eff. Event -> Eff eff String

    setAnnouncement :: forall eff. HTMLDocument -> String -> String -> Eff (dom :: DOM | eff) Unit

    setDismissAnnouncement :: forall eff. HTMLDocument -> Eff (dom :: DOM | eff) Unit

    updateLookangle :: forall eff a. Coordinate -> Number -> Eff (dom :: DOM | eff) Unit

    updateTemperature :: forall eff. Celsius -> Eff (dom :: DOM | eff) Unit

    updateTimestamp :: forall eff. String -> Eff (now :: MomentJS.Now, dom :: DOM | eff) Unit


## Module MapView.DomHelpers

### Values

    setClass :: forall eff. HTMLElement -> String -> Eff eff (Unit -> Unit)

    setDisplay :: forall eff. HTMLElement -> String -> Eff eff Unit

    setDisplayFn :: forall eff. HTMLElement -> String -> Eff eff (Unit -> Unit)

    setOnclick :: forall eff a. HTMLElement -> (a -> Unit) -> Eff eff Unit


## Module MapView.Leaflet

### Values

    addToPathLeaflet :: forall eff. Polyline -> Map -> Coordinate -> Eff eff Unit


## Module MapView.Lookangle

### Types

    type Altitude = Number

    data AzElCord where
      AzElCord :: { range :: Number, elevation :: Number, azimuth :: Number } -> AzElCord

    data Coordinate where
      Coordinate :: Latitude -> Longitude -> Altitude -> Coordinate

    type Latitude = Number

    type Longitude = Number


### Type Class Instances

    instance showAzElCord :: Show AzElCord

    instance showCoordinate :: Show Coordinate


### Values

    lookAngle :: Coordinate -> Coordinate -> AzElCord


## Module MapView.WSTypes

### Types

    newtype Celsius where
      Celsius :: Number -> Celsius

    data Coordinate where
      Coordinate :: { longitude :: Number, latitude :: Number } -> Coordinate

    data WSMessage where
      LocationBeacon :: { temperature :: Celsius, time :: String, altitude :: Number, coordinates :: Coordinate } -> WSMessage
      BeaconHistory :: [Coordinate] -> WSMessage


### Type Class Instances

    instance readCoordinate :: IsForeign Coordinate

    instance readWSMessage :: IsForeign WSMessage

    instance showCelsius :: Show Celsius


### Values

    unsafeShowJSON :: forall a. a -> String


## Module MapView.WebSocket

### Types

    data Event :: *

    data WebSocket :: *


### Values

    addEventListenerWS :: forall eff. WebSocket -> String -> (Event -> Eff eff Unit) -> Eff eff Unit

    newWebSocket :: forall eff a. String -> Eff eff WebSocket

    sendWS :: forall eff. WebSocket -> String -> Eff eff Unit


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