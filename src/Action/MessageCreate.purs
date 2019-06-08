module Action.MessageCreate
  ( execute
  ) where

import Prelude

import Data.Maybe as Maybe
import HTTPure as HTTPure
import Model.Message as MessageModel
import Type (DB, MessageCreateParams)
import View.MessageShow as ViewMessageShow

execute :: DB -> MessageCreateParams -> HTTPure.ResponseM
execute db params = do
  createdMaybe <- MessageModel.create db params
  case createdMaybe of
    Maybe.Nothing -> HTTPure.badRequest "invalid" -- TODO
    Maybe.Just created -> HTTPure.ok (ViewMessageShow.render created)
