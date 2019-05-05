module Action.UserDestroy
  ( execute
  ) where

import Prelude

import HTTPure as HTTPure
import Model.User as UserModel
import Type (DB)

execute :: DB -> String -> HTTPure.ResponseM
execute db id = do
  deleted <- UserModel.destroy db id
  if deleted
    then HTTPure.noContent
    else HTTPure.notFound
