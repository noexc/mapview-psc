module MapView.WSTypes where

import Data.Foreign
import Data.Foreign.Class
--import Data.List

data Coordinate = Coordinate { latitude :: Number
                             , longitude :: Number
                             }

newtype Celsius = Celsius Number

instance showCelsius :: Show Celsius where
  show (Celsius c) = show c ++ "°C"

newtype TelemetryCRC = TelemetryCRC Number
newtype CalculatedCRC = CalculatedCRC Number
data CRCConfirmation = CRCMatch Number
                     | CRCMismatch TelemetryCRC CalculatedCRC

instance showCRCConfirmation :: Show CRCConfirmation where
  show (CRCMatch n) = "CRC MATCH: " ++ show n
  show (CRCMismatch (TelemetryCRC t) (CalculatedCRC c)) =
    "CRC MISMATCH: expected(" ++ show c ++ ") /= received(" ++ show t ++ ")"

isCRCMatch :: CRCConfirmation -> Boolean
isCRCMatch (CRCMatch _) = true
isCRCMatch _ = false

data WSMessage =
  LocationBeacon { coordinates :: Coordinate
                 , altitude :: Number
                 , time :: String
                 , crc :: CRCConfirmation
                 }
  | BeaconHistory [Coordinate]

instance readCoordinate :: IsForeign Coordinate where
  read value = do
    lat <- readProp "lat" value
    long <- readProp "lon" value
    return $ Coordinate { latitude: lat
                        , longitude: long
                        }

instance readCRC :: IsForeign CRCConfirmation where
  read value = do
    match <- readProp "match" value
    if match
      then do
        crc <- readProp "crc" value
        return $ CRCMatch crc
      else do
        received <- TelemetryCRC <$> readProp "received" value
        expected <- CalculatedCRC <$> readProp "expected" value
        return $ CRCMismatch received expected

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
        crc <- readProp "crc" value
        return $ LocationBeacon { coordinates: coord
                                , altitude: altitude
                                , time: time
                                , crc: crc
                                }

foreign import unsafeShowJSON
  "var unsafeShowJSON = JSON.stringify;" :: forall a. a -> String
