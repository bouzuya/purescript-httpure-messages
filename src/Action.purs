module Action
  ( Action(..)
  , UserId
  , execute
  ) where

import Prelude

import Action.UserCreate as ActionUserCreate
import Action.UserDestroy as ActionUserDestroy
import Action.UserIndex as ActionUserIndex
import Action.UserShow as ActionUserShow
import Action.UserUpdate as ActionUserUpdate
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import HTTPure (ResponseM)
import Type (DB, User)

type UserId = String

data Action
  = UserIndex
  | UserCreate User
  | UserShow UserId
  | UserUpdate UserId User
  | UserDestroy UserId

derive instance eqAction :: Eq Action
derive instance genericAction :: Generic Action _
instance showAction :: Show Action where
  show = genericShow

execute :: DB -> Action -> ResponseM
execute db =
  case _ of
    UserIndex -> ActionUserIndex.execute db
    UserCreate user -> ActionUserCreate.execute db user
    UserShow id -> ActionUserShow.execute db id
    UserUpdate id user -> ActionUserUpdate.execute db id user
    UserDestroy id -> ActionUserDestroy.execute db id
