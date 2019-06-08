module Model.Message
  ( index
  , create
  , show
  , destroy
  ) where

import Prelude

import Bouzuya.UUID.V4 as UUIDv4
import Data.Array as Array
import Data.Either as Either
import Data.Maybe (Maybe)
import Data.Maybe as Maybe
import Effect.Aff (Aff)
import Effect.Aff as Aff
import Effect.Class as Class
import Effect.Now as Now
import Foreign as Foreign
import Prelude as Prelude
import Query as Query
import Record as Record
import SQLite3 as SQLite3
import Simple.JSON as SimpleJSON
import Type (DB, Message, Timestamp(..), MessageCreateParams)
import Type as Type

delete :: DB -> String -> Aff Unit
delete db id = do
  conn <- SQLite3.newDB db
  _ <- SQLite3.queryDB conn query (map Foreign.unsafeToForeign [id])
  SQLite3.closeDB conn
  where
    query = Query.delete "messages" "id = ?"

findAll :: DB -> Aff (Array Message)
findAll db = do
  conn <- SQLite3.newDB db
  rows <- map SimpleJSON.read (SQLite3.queryDB conn query [])
  _ <- SQLite3.closeDB conn
  Either.either (\e -> Aff.throwError (Aff.error (Prelude.show e))) pure rows
  where
    query =
      Query.selectSimple
        [ "created_at"
        , "id"
        , "message"
        , "user_id"
        ]
        "messages"
        "1 = 1"

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
      Query.selectSimple
        [ "created_at"
        , "id"
        , "message"
        , "user_id"
        ]
        "messages"
        "id = ?"

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
      Query.selectSimple
        [ "created_at"
        , "id"
        , "message"
        , "user_id"
        ]
        "messages"
        "user_id = ?"

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

create :: DB -> MessageCreateParams -> Aff (Maybe Message)
create db params = do
  id <- Class.liftEffect (map UUIDv4.toString UUIDv4.generate)
  created_at <- Class.liftEffect (map Timestamp Now.nowDateTime)
  -- TODO: check user_id
  let message' = Record.merge params { created_at, id }
  messageMaybe <- find db id
  case messageMaybe of
    Maybe.Just _ -> pure Maybe.Nothing
    Maybe.Nothing -> do
      _ <- insert db message'
      pure (Maybe.Just message') -- TODO

destroy :: DB -> String -> Aff Boolean
destroy db id = do
  _ <- delete db id
  pure true -- TODO
