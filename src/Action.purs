module Action
  ( Action(..)
  , MessageId
  , UserId
  , execute
  ) where

import Prelude

import Action.MessageCreate as ActionMessageCreate
import Action.MessageDestroy as ActionMessageDestroy
import Action.MessageIndex as ActionMessageIndex
import Action.MessageShow as ActionMessageShow
import Action.UserCreate as ActionUserCreate
import Action.UserDestroy as ActionUserDestroy
import Action.UserIndex as ActionUserIndex
import Action.UserShow as ActionUserShow
import Action.UserUpdate as ActionUserUpdate
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import HTTPure (ResponseM)
import Type (DB, MessageCreateParams, UserParams)

type MessageId = String
type UserId = String

data Action
  = MessageIndex
  | MessageCreate MessageCreateParams
  | MessageShow MessageId
  | MessageDestroy MessageId
  | UserIndex
  | UserCreate UserParams
  | UserShow UserId
  | UserUpdate UserId UserParams
  | UserDestroy UserId

derive instance eqAction :: Eq Action
derive instance genericAction :: Generic Action _
instance showAction :: Show Action where
  show = genericShow

execute :: DB -> Action -> ResponseM
execute db =
  case _ of
    MessageIndex -> ActionMessageIndex.execute db
    MessageCreate message -> ActionMessageCreate.execute db message
    MessageShow id -> ActionMessageShow.execute db id
    MessageDestroy id -> ActionMessageDestroy.execute db id
    UserIndex -> ActionUserIndex.execute db
    UserCreate user -> ActionUserCreate.execute db user
    UserShow id -> ActionUserShow.execute db id
    UserUpdate id user -> ActionUserUpdate.execute db id user
    UserDestroy id -> ActionUserDestroy.execute db id
