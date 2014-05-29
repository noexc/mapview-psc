module MomentJS where

import Control.Monad.Eff
import Data.Maybe

foreign import data JSMoment :: *
foreign import data Now :: !

-- Phantom type!
data Moment a = Moment JSMoment | UTCMoment JSMoment

foreign import now
  "function now() {\
  \  return Moment(moment());\
  \}" :: forall e. Eff (now :: Now | e) (Moment JSMoment)

foreign import momentConstructor
  "function momentConstructor(s) {\
  \  return function() {\
  \    return moment(s);\
  \  };\
  \}" :: forall a. a -> JSMoment

foreign import utcNow
  "function utcNow() {\
  \  return UTCMoment(moment.utc());\
  \}" :: forall e. Eff (now :: Now | e) (Moment JSMoment)

foreign import utcMomentConstructor
  "function utcMomentConstructor(s) {\
  \  return function() {\
  \    return moment.utc(s);\
  \  };\
  \}" :: forall a. a -> JSMoment

foreign import momentMethod
  "function momentMethod(method) {\
  \  return function(m) {\
  \    return function() {\
  \      return m[method]();\
  \    };\
  \  };\
  \}" :: forall a. String -> JSMoment -> a

foreign import momentFrom
  "function momentFrom(m1) {\
  \  return function(m2) {\
  \    return m1.from(m2);\
  \  };\
  \}" :: JSMoment -> JSMoment -> String

createMoment :: forall a. JSMoment -> Maybe (Moment a)
createMoment x = if momentMethod "isValid" x
                 then Just $ Moment x
                 else Nothing

liftMoment :: forall a. (JSMoment -> a) -> Moment a -> a
liftMoment f (Moment j) = f j

liftMoment2 :: forall a b. (JSMoment -> JSMoment -> a) -> Moment b -> Moment b -> a
liftMoment2 f (Moment j) (Moment k) = f j k
