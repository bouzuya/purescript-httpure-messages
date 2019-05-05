module Action.MessageIndex
  ( execute
  ) where

import Prelude

import HTTPure as HTTPure
import Model.Message as MessageModel
import Type (DB)
import View.MessageIndex as ViewMessageIndex

execute :: DB -> HTTPure.ResponseM
execute db = do
  users <- MessageModel.index db
  HTTPure.ok (ViewMessageIndex.render users)
