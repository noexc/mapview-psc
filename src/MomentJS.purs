module MomentJS where

import Control.Monad.Eff

foreign import timeAgo
  "function timeAgo(date) {\
  \  return function(format) {\
  \    return function() {\
  \      return moment(date, format).fromNow();\
  \    };\
  \  };\
  \}" :: forall eff. String -> String -> Eff eff String
