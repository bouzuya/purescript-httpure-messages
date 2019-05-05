module Action.MessageDestroy
  ( execute
  ) where

import Prelude

import HTTPure as HTTPure
import Model.Message as MessageModel
import Type (DB)

execute :: DB -> String -> HTTPure.ResponseM
execute db id = do
  deleted <- MessageModel.destroy db id
  if deleted
    then HTTPure.noContent
    else HTTPure.notFound
