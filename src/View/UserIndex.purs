module View.UserIndex
  ( render
  ) where

import Simple.JSON as SimpleJSON
import Type (User)

render :: Array User -> String
render = SimpleJSON.writeJSON
