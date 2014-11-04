module Lookangle where

import Math

type Latitude  = Number
type Longitude = Number
type Altitude  = Number
data Coordinate = Coordinate Latitude Longitude Altitude
data AzElCord   = AzelCord { azimuth :: Number, elevation :: Number, range :: Number }

-- | Given a source and destination coordinate, return the look angle and
-- range to the object.
lookAngle ::
  Coordinate    -- ^ Source coordinate
  -> Coordinate -- ^ Destination coordinate
  -> AzElCord
lookAngle (Coordinate gLat gLon gAlt) (Coordinate pLat pLon pAlt) =
  AzelCord {
    azimuth: azimuth',
    elevation: elevation',
    range: range'
  }
  where
    earthRadius  = 6378137
    groundRadius = earthRadius + gAlt
    pointRadius  = earthRadius + pAlt
    gLat'        = (pi / 180) * gLat
    gLon'        = (pi / 180) * gLon
    pLat'        = (pi / 180) * pLat
    pLon'        = (pi / 180) * pLon

    -- WGS84-specific
    wgs84F   = 1 / 298.257223563
    wgs84Ecc = 8.1819190842621E-2
    wgs84N   = earthRadius / sqrt (1 - (pow wgs84Ecc 2) * (pow (sin gLat') 2))

    -- WGS84 -> ECR
    gX = (wgs84N + gAlt) * cos gLat' * cos gLon'
    gY = (wgs84N + gAlt) * cos gLat' * sin gLon'
    gZ = (wgs84N * (pow (1 - wgs84Ecc) 2) + gAlt) * sin gLat'

    pX = (wgs84N + pAlt) * cos pLat' * cos pLon'
    pY = (wgs84N + pAlt) * cos pLat' * sin pLon'
    pZ = (wgs84N * (pow (1 - wgs84Ecc) 2) + pAlt) * sin pLat'

    rangeX = pX - gX
    rangeY = pY - gY
    rangeZ = pZ - gZ

    -- Topocentric Horizon
    rotS = sin gLat' * cos gLon' * rangeX + sin gLat' * sin gLon' * rangeY - cos gLat' * rangeZ
    rotE = -(sin gLon' * rangeX) + cos gLon' * rangeY
    rotZ = cos gLat' * cos gLon' * rangeX + cos gLat' * sin gLon' * rangeY + sin gLat' * rangeZ

    range' = sqrt $ (pow rotS 2) + (pow rotE 2) + (pow rotZ 2)

    elRad = if range' == 0
             then pi / 2
             else asin (rotZ / range')

    azRad = if rotS > 0
            then atan (-(rotE / rotS)) + pi
            else if rotS < 0
                 then atan (-(rotE / rotS)) + (2 * pi)
                 else pi / 2

    elevation' = elRad * (180 / pi)
    azimuth'   = azRad * (180 / pi)
