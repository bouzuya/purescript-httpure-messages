module Action.UserUpdate
  ( execute
  ) where

import Prelude

import Data.Maybe as Maybe
import HTTPure as HTTPure
import Model.User as UserModel
import Type (DB, User)
import View.UserShow as ViewUserShow

execute :: DB -> String -> User -> HTTPure.ResponseM
execute db id user = do
  updatedMaybe <- UserModel.update db id user
  case updatedMaybe of
    Maybe.Nothing -> HTTPure.notFound
    Maybe.Just updated -> HTTPure.ok (ViewUserShow.render updated)
