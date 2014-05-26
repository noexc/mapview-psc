module DomHelpers where

import Control.Monad.Eff

foreign import data Element :: *

foreign import getElementById
  "function getElementById(id) {\
  \  return function() {\
  \    return document.getElementById(id);\
  \  };\
  \}" :: forall eff. String -> Eff eff Element

foreign import setOnclick
  "function setOnclick(ele) {\
  \  return function(f) {\
  \    return function() {\
  \      ele.onclick = f;\
  \      return;\
  \    };\
  \  };\
  \}" :: forall eff a. Element -> (a -> Unit) -> Eff eff Unit

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
  \}" :: forall eff. Element -> String -> Eff eff (Unit -> Unit)

foreign import setDisplay
  "function setDisplay(ele) {\
  \  return function(s) {\
  \    return function() {\
  \      ele.style.display = s;\
  \      return;\
  \    };\
  \  };\
  \}" :: forall eff. Element -> String -> Eff eff Unit

foreign import setInnerHtml
  "function setInnerHtml(ele) {\
  \  return function(s) {\
  \    return function() {\
  \      ele.innerHTML = s;\
  \      return;\
  \    };\
  \  };\
  \}" :: forall eff. Element -> String -> Eff eff (Unit -> Unit)

foreign import setClass
  "function setClass(ele) {\
  \  return function(s) {\
  \    return function() {\
  \      ele.className = s;\
  \      return;\
  \    };\
  \  };\
  \}" :: forall eff. Element -> String -> Eff eff (Unit -> Unit)
