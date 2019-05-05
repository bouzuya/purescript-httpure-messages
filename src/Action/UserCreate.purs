module Action.UserCreate
  ( execute
  ) where

import Prelude

import Data.Maybe as Maybe
import HTTPure as HTTPure
import Model.User as UserModel
import Type (DB, User)
import View.UserShow as ViewUserShow

execute :: DB -> User -> HTTPure.ResponseM
execute db user = do
  createdMaybe <- UserModel.create db user
  case createdMaybe of
    Maybe.Nothing -> HTTPure.badRequest "invalid" -- TODO
    Maybe.Just created -> HTTPure.ok (ViewUserShow.render created)
