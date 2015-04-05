module MapView.DomHelpers where

import Control.Monad.Eff
import Data.DOM.Simple.Types

foreign import setOnclick
  "function setOnclick(ele) {\
  \  return function(f) {\
  \    return function() {\
  \      ele.onclick = f;\
  \      return;\
  \    };\
  \  };\
  \}" :: forall eff a. HTMLElement -> (a -> Unit) -> Eff eff Unit

foreign import setDisplayFn
  "function setDisplayFn(ele) {\
  \  return function(s) {\
  \    return function() {\
  \      return function() {\
  \        ele.style.display = s;\
  \        return;\
  \      };\
  \    };\
  \  };\
  \}" :: forall eff. HTMLElement -> String -> Eff eff (Unit -> Unit)

foreign import setDisplay
  "function setDisplay(ele) {\
  \  return function(s) {\
  \    return function() {\
  \      ele.style.display = s;\
  \      return;\
  \    };\
  \  };\
  \}" :: forall eff. HTMLElement -> String -> Eff eff Unit

foreign import setClass
  "function setClass(ele) {\
  \  return function(s) {\
  \    return function() {\
  \      ele.className = s;\
  \      return;\
  \    };\
  \  };\
  \}" :: forall eff. HTMLElement -> String -> Eff eff (Unit -> Unit)
