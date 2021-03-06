module Model.User
  ( index
  , create
  , show
  , update
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
import Type (DB, User, UserParams)
import Type as Type

delete :: DB -> String -> Aff Unit
delete db id = do
  conn <- SQLite3.newDB db
  _ <- SQLite3.queryDB conn query (map Foreign.unsafeToForeign [id])
  SQLite3.closeDB conn
  where
    query = Query.delete "users" "id = ?"

findAll :: DB -> Aff (Array User)
findAll db = do
  conn <- SQLite3.newDB db
  rows <- map SimpleJSON.read (SQLite3.queryDB conn query [])
  _ <- SQLite3.closeDB conn
  Either.either (\e -> Aff.throwError (Aff.error (Prelude.show e))) pure rows
  where
    query =
      Query.selectSimple ["created_at", "id", "name", "url"] "users" "1 = 1"

find :: DB -> String -> Aff (Maybe User)
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
      Query.selectSimple ["created_at", "id", "name", "url"] "users" "id = ?"

insert :: DB -> User -> Aff Unit
insert db user = do
  conn <- SQLite3.newDB db
  _ <-
    SQLite3.queryDB
      conn
      query
      (map
        Foreign.unsafeToForeign
        [ Type.timestampToString user.created_at
        , user.id
        , user.name
        , user.url
        ])
  SQLite3.closeDB conn
  where
    query = Query.insert "users" ["created_at", "id", "name", "url"]

update' :: DB -> String -> UserParams -> Aff Unit
update' db id params = do
  conn <- SQLite3.newDB db
  _ <-
    SQLite3.queryDB
      conn
      query
      (map
        Foreign.unsafeToForeign
        [ params.name
        , params.url
        , id
        ])
  SQLite3.closeDB conn
  where
    query = Query.update "users" ["name", "url"] "id = ?"

--

index :: DB -> Aff (Array User)
index db = findAll db

show :: DB -> String -> Aff (Maybe User)
show db id = find db id

create :: DB -> UserParams -> Aff (Maybe User)
create db params = do
  id <- Class.liftEffect (map UUIDv4.toString UUIDv4.generate)
  created_at <-
    Class.liftEffect (map Type.timestampFromDateTime Now.nowDateTime)
  let user' = Record.merge params { created_at, id }
  userMaybe <- find db id
  case userMaybe of
    Maybe.Just _ -> pure Maybe.Nothing
    Maybe.Nothing -> do
      _ <- insert db user'
      pure (Maybe.Just user') -- TODO

update :: DB -> String -> UserParams -> Aff (Maybe User)
update db id params = do
  _ <- update' db id params
  userMaybe <- find db id -- TODO
  pure userMaybe

destroy :: DB -> String -> Aff Boolean
destroy db id = do
  _ <- delete db id
  pure true -- TODO
