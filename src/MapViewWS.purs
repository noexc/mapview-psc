module MapViewWS where

import Data.Foreign

data Coordinate = Coordinate { latitude :: Number
                               , longitude :: Number
                               }

data WSMessage =
  LocationBeacon { coordinates :: Coordinate
                 , altitude :: Number
                 , time :: String
                 }

instance readCoordinate :: ReadForeign Coordinate where
  read = do
    lat <- prop "latitude"
    lon <- prop "longitude"
    return $ Coordinate { latitude: lat, longitude: lon }

instance readWSMessage :: ReadForeign WSMessage where
  read = do
    coord <- prop "coordinates"
    altitude <- prop "altitude"
    time <- prop "time"
    return $ LocationBeacon { coordinates: coord
                            , altitude: altitude
                            , time: time
                            }

foreign import unsafeShowJSON
  "var unsafeShowJSON = JSON.stringify;" :: forall a. a -> String
