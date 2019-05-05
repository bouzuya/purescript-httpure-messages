module Action.UserIndex
  ( execute
  ) where

import Prelude

import HTTPure as HTTPure
import Model.User as UserModel
import Type (DB)
import View.UserIndex as ViewUserIndex

execute :: DB -> HTTPure.ResponseM
execute db = do
  users <- UserModel.index db
  HTTPure.ok (ViewUserIndex.render users)
