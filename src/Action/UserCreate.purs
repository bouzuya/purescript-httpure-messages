module Action.UserCreate
  ( execute
  ) where

import Prelude

import Data.Maybe as Maybe
import HTTPure as HTTPure
import Model.User as UserModel
import Type (DB, UserParams)
import View.UserShow as ViewUserShow

execute :: DB -> UserParams -> HTTPure.ResponseM
execute db params = do
  createdMaybe <- UserModel.create db params
  case createdMaybe of
    Maybe.Nothing -> HTTPure.badRequest "invalid" -- TODO
    Maybe.Just created -> HTTPure.ok (ViewUserShow.render created)
