module Model.Message
  ( index
  , create
  , show
  , destroy
  ) where

import Prelude

import Data.Array as Array
import Data.Either as Either
import Data.Maybe (Maybe)
import Data.Maybe as Maybe
import Data.String as String
import Effect.Aff (Aff)
import Effect.Aff as Aff
import Foreign as Foreign
import Prelude as Prelude
import Query as Query
import SQLite3 as SQLite3
import Simple.JSON as SimpleJSON
import Type (DB, Message)
import Type as Type

delete :: DB -> String -> Aff Unit
delete db id = do
  conn <- SQLite3.newDB db
  _ <- SQLite3.queryDB conn query (map Foreign.unsafeToForeign [id])
  SQLite3.closeDB conn
  where
    query =
      String.joinWith
        "\n"
        [ "DELETE"
        , "  FROM"
        , "    messages"
        , "  WHERE"
        , "    id = ?"
        ]

findAll :: DB -> Aff (Array Message)
findAll db = do
  conn <- SQLite3.newDB db
  rows <- map SimpleJSON.read (SQLite3.queryDB conn query [])
  _ <- SQLite3.closeDB conn
  Either.either (\e -> Aff.throwError (Aff.error (Prelude.show e))) pure rows
  where
    query =
      String.joinWith
        "\n"
        [ "SELECT"
        , "    created_at"
        , "  , id"
        , "  , message"
        , "  , user_id"
        , "  FROM"
        , "    messages"
        ]

find :: DB -> String -> Aff (Maybe Message)
find db id = do
  conn <- SQLite3.newDB db
  rows <-
    map
      SimpleJSON.read
      (SQLite3.queryDB conn query (map Foreign.unsafeToForeign [id]))
  _ <- SQLite3.closeDB conn
  Either.either
    (\e -> Aff.throwError (Aff.error (Prelude.show e)))
    (pure <<< Array.head)
    rows
  where
    query =
      String.joinWith
        "\n"
        [ "SELECT"
        , "    created_at"
        , "  , id"
        , "  , message"
        , "  , user_id"
        , "  FROM"
        , "    messages"
        , "  WHERE"
        , "    id = ?"
        ]

findByUser :: DB -> String -> Aff (Maybe Message)
findByUser db id = do
  conn <- SQLite3.newDB db
  rows <-
    map
      SimpleJSON.read
      (SQLite3.queryDB conn query (map Foreign.unsafeToForeign [id]))
  _ <- SQLite3.closeDB conn
  Either.either
    (\e -> Aff.throwError (Aff.error (Prelude.show e)))
    (pure <<< Array.head)
    rows
  where
    query =
      String.joinWith
        "\n"
        [ "SELECT"
        , "    created_at"
        , "  , id"
        , "  , message"
        , "  , user_id"
        , "  FROM"
        , "    messages"
        , "  WHERE"
        , "    user_id = ?"
        ]

insert :: DB -> Message -> Aff Unit
insert db message = do
  conn <- SQLite3.newDB db
  _ <-
    SQLite3.queryDB
      conn
      query
      (map
        Foreign.unsafeToForeign
        [ Type.timestampToString message.created_at
        , message.id
        , message.message
        , message.user_id
        ])
  SQLite3.closeDB conn
  where
    query =
      Query.insert "messages" ["created_at", "id", "message", "user_id"]

--

index :: DB -> Aff (Array Message)
index db = findAll db

show :: DB -> String -> Aff (Maybe Message)
show db id = find db id

create :: DB -> Message -> Aff (Maybe Message)
create db message = do
  messageMaybe <- find db message.id
  case messageMaybe of
    Maybe.Just _ -> pure Maybe.Nothing
    Maybe.Nothing -> do
      _ <- insert db message
      pure (Maybe.Just message) -- TODO

destroy :: DB -> String -> Aff Boolean
destroy db id = do
  _ <- delete db id
  pure true -- TODO
