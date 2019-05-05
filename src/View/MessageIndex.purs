module View.MessageIndex
  ( render
  ) where

import Simple.JSON as SimpleJSON
import Type (Message)

render :: Array Message -> String
render = SimpleJSON.writeJSON
