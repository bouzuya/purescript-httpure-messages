module Action.MessageShow
  ( execute
  ) where

import Prelude

import Data.Maybe as Maybe
import HTTPure as HTTPure
import Model.Message as MessageModel
import Type (DB)
import View.MessageShow as ViewMessageShow

execute :: DB -> String -> HTTPure.ResponseM
execute db id = do
  userMaybe <- MessageModel.show db id
  case userMaybe of
    Maybe.Nothing -> HTTPure.notFound
    Maybe.Just user -> HTTPure.ok (ViewMessageShow.render user)
