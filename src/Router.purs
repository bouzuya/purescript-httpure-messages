module Router
  ( RouteError(..)
  , router
  ) where

import Prelude

import Action (Action(..))
import Data.Either (Either)
import Data.Either as Either
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import HTTPure (Method)
import HTTPure as HTTPure
import Simple.JSON (class ReadForeign)
import Simple.JSON as SimpleJSON

data RouteError
  = ClientError String
  | NotFound -- 404
  | MethodNotAllowed (Array Method) -- 405

derive instance eqRouteError :: Eq RouteError
derive instance genericRouteError :: Generic RouteError _
instance showRouteError :: Show RouteError where
  show = genericShow

fromJSON :: forall a. ReadForeign a => String -> Either RouteError a
fromJSON s =
  Either.either
    (Either.Left <<< ClientError <<< show)
    Either.Right
    (SimpleJSON.readJSON s)

router :: HTTPure.Request -> Either RouteError Action
router request =
  case request.path of
    ["messages"] ->
      case request.method of
        HTTPure.Get -> pure MessageIndex
        HTTPure.Post -> do
          message <- fromJSON request.body
          pure (MessageCreate message)
        _ -> Either.Left (MethodNotAllowed [HTTPure.Get, HTTPure.Post])
    ["messages", id] ->
      case request.method of
        HTTPure.Get -> pure (MessageShow id)
        HTTPure.Delete -> pure (MessageDestroy id)
        _ -> Either.Left (MethodNotAllowed [HTTPure.Get, HTTPure.Delete])
    ["users"] ->
      case request.method of
        HTTPure.Get -> pure UserIndex
        HTTPure.Post -> do
          user <- fromJSON request.body
          pure (UserCreate user)
        _ -> Either.Left (MethodNotAllowed [HTTPure.Get, HTTPure.Post])
    ["users", id] ->
      case request.method of
        HTTPure.Get -> pure (UserShow id)
        HTTPure.Patch -> do
          user <- fromJSON request.body
          pure (UserUpdate id user)
        HTTPure.Delete -> pure (UserDestroy id)
        _ ->
          Either.Left
            (MethodNotAllowed [HTTPure.Get, HTTPure.Patch, HTTPure.Delete])
    _ -> Either.Left NotFound
