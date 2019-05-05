module Action.MessageCreate
  ( execute
  ) where

import Prelude

import Data.Maybe as Maybe
import HTTPure as HTTPure
import Model.Message as MessageModel
import Type (DB, Message)
import View.MessageShow as ViewMessageShow

execute :: DB -> Message -> HTTPure.ResponseM
execute db message = do
  createdMaybe <- MessageModel.create db message
  case createdMaybe of
    Maybe.Nothing -> HTTPure.badRequest "invalid" -- TODO
    Maybe.Just created -> HTTPure.ok (ViewMessageShow.render created)
