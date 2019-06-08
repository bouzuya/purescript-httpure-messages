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
import Foreign as Foreign
import Prelude as Prelude
import Query as Query
import SQLite3 as SQLite3
import Simple.JSON as SimpleJSON
import Type (DB, User)

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
    query = Query.selectSimple ["id", "name", "url"] "users" "1 = 1"

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
    query = Query.selectSimple ["id", "name", "url"] "users" "id = ?"

insert :: DB -> User -> Aff Unit
insert db user = do
  conn <- SQLite3.newDB db
  _ <-
    SQLite3.queryDB
      conn
      query
      (map
        Foreign.unsafeToForeign
        [ user.id
        , user.name
        , user.url
        ])
  SQLite3.closeDB conn
  where
    query = Query.insert "users" ["id", "name", "url"]

update' :: DB -> String -> User -> Aff Unit
update' db id user = do
  conn <- SQLite3.newDB db
  _ <-
    SQLite3.queryDB
      conn
      query
      (map
        Foreign.unsafeToForeign
        [ user.name
        , user.url
        , user.id
        ])
  SQLite3.closeDB conn
  where
    query = Query.update "users" ["name", "url"] "id = ?"

--

index :: DB -> Aff (Array User)
index db = findAll db

show :: DB -> String -> Aff (Maybe User)
show db id = find db id

create :: DB -> User -> Aff (Maybe User)
create db user = do
  id <- Class.liftEffect (map UUIDv4.toString UUIDv4.generate)
  let user' = user { id = id }
  userMaybe <- find db id
  case userMaybe of
    Maybe.Just _ -> pure Maybe.Nothing
    Maybe.Nothing -> do
      _ <- insert db user'
      pure (Maybe.Just user') -- TODO

update :: DB -> String -> User -> Aff (Maybe User)
update db id user = do
  _ <- update' db id user
  pure (Maybe.Just user) -- TODO

destroy :: DB -> String -> Aff Boolean
destroy db id = do
  _ <- delete db id
  pure true -- TODO
