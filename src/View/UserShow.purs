module View.UserShow
  ( render
  ) where

import Simple.JSON as SimpleJSON
import Type (User)

render :: User -> String
render = SimpleJSON.writeJSON
