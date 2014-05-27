module WebSocket where

import Control.Monad.Eff

foreign import data WebSocket :: *
foreign import data Event :: *

foreign import newWebSocket
  "function newWebSocket(s) {\
  \  return function() {\
  \    return new WebSocket(s);\
  \  };\
  \}" :: forall eff a. String -> Eff eff WebSocket

foreign import addEventListenerWS
  "function addEventListenerWS(ws) {\
  \  return function(s) {\
  \    return function(f) {\
  \      return function() {\
  \        ws[s] = function(msg) { f(msg)(); };\
  \        return;\
  \      };\
  \    };\
  \  };\
  \}" :: forall eff. WebSocket -> String -> (Event -> Eff eff {}) -> Eff eff {}

foreign import sendWS
  "function sendWS(ws) {\
  \  return function(s) {\
  \    return function() {\
  \      if (ws.readyState == 1)\
  \        ws.send(s);\
  \      else\
  \        ws.onopen = function(_) {\
  \          ws.send(s);\
  \          return;\
  \        };\
  \      return;\
  \    };\
  \  };\
  \}" :: forall eff. WebSocket -> String -> Eff eff {}
