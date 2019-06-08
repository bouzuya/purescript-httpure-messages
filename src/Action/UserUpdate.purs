module Action.UserUpdate
  ( execute
  ) where

import Prelude

import Data.Maybe as Maybe
import HTTPure as HTTPure
import Model.User as UserModel
import Type (DB, UserParams)
import View.UserShow as ViewUserShow

execute :: DB -> String -> UserParams -> HTTPure.ResponseM
execute db id params = do
  updatedMaybe <- UserModel.update db id params
  case updatedMaybe of
    Maybe.Nothing -> HTTPure.notFound
    Maybe.Just updated -> HTTPure.ok (ViewUserShow.render updated)
