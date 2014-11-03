module MapViewWS where

import Data.Foreign
import Data.Foreign.Class
--import Data.List

data Coordinate = Coordinate { latitude :: Number
                             , longitude :: Number
                             }

data WSMessage =
  LocationBeacon { coordinates :: Coordinate
                 , altitude :: Number
                 , time :: String
                 }
  | BeaconHistory [Coordinate]

instance readCoordinate :: IsForeign Coordinate where
  read value = do
    lat <- readProp "lat" value
    long <- readProp "lon" value
    return $ Coordinate { latitude: lat
                        , longitude: long
                        }

instance readWSMessage :: IsForeign WSMessage where
  read value =
    if isArray value
      then do
        history <- read value
        return $ BeaconHistory history
      else do
        coord <- readProp "coordinates" value
        altitude <- readProp "altitude" value
        time <- readProp "time" value
        return $ LocationBeacon { coordinates: coord
                                , altitude: altitude
                                , time: time
                                }

foreign import unsafeShowJSON
  "var unsafeShowJSON = JSON.stringify;" :: forall a. a -> String
