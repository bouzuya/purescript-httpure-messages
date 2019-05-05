module View.MessageShow
  ( render
  ) where

import Simple.JSON as SimpleJSON
import Type (Message)

render :: Message -> String
render = SimpleJSON.writeJSON
