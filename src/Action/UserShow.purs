module Action.UserShow
  ( execute
  ) where

import Prelude

import Data.Maybe as Maybe
import HTTPure as HTTPure
import Model.User as UserModel
import Type (DB)
import View.UserShow as ViewUserShow

execute :: DB -> String -> HTTPure.ResponseM
execute db id = do
  userMaybe <- UserModel.show db id
  case userMaybe of
    Maybe.Nothing -> HTTPure.notFound
    Maybe.Just user -> HTTPure.ok (ViewUserShow.render user)
