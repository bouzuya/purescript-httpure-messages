module Main
  ( main
  ) where

import Prelude

import Action as Action
import Bouzuya.DateTime.Formatter.DateTime as DateTimeFormatter
import Data.Either as Either
import Data.Maybe as Maybe
import Data.String as String
import Data.Traversable as Traversable
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Aff as Aff
import Effect.Class as Class
import Effect.Console as Console
import Foreign as Foreign
import HTTPure (Request, ResponseM)
import HTTPure as HTTPure
import Partial.Unsafe as Unsafe
import Router as Router
import SQLite3 as SQLite3
import Type (DB, Message, Timestamp(..), User)
import Type as Type

initialMessages :: Array Message
initialMessages =
  map
    (\{ created_at, id, message, user_id } ->
      let
        dt =
          Unsafe.unsafePartial
            (Maybe.fromJust (DateTimeFormatter.fromString created_at))
      in { created_at: Timestamp dt, id, message, user_id })
    [ { created_at: "2019-01-02T03:04:05"
      , id: "1"
      , message: "Hello"
      , user_id: "1"
      }
    , { created_at: "2019-01-02T03:04:10"
      , id: "2"
      , message: "World"
      , user_id: "1"
      }
    , { created_at: "2019-01-02T03:04:20"
      , id: "3"
      , message: "World"
      , user_id: "2"
      }
    ]

initialUsers :: Array User
initialUsers =
  [ { id: "1", url: "https://duckduckgo.com/", name: "search engine" }
  , { id: "2", url: "https://bouzuya.net/", name: "my page" }
  , { id: "3", url: "https://blog.bouzuya.net/", name: "my blog" }
  ]

main :: Effect Unit
main = Aff.launchAff_ do
  _ <- createDB db
  _ <- Class.liftEffect (HTTPure.serve port (app db) booted)
  pure unit
  where
    app :: DB -> Request -> ResponseM
    app db' request =
      case Router.router request of
        Either.Right action -> Action.execute db' action
        Either.Left (Router.ClientError _) ->
          HTTPure.badRequest "invalid params"
        Either.Left Router.NotFound ->
          HTTPure.notFound

    booted :: Effect Unit
    booted = Console.log "Server now up on port 8080"

    createDB :: String -> Aff Unit
    createDB dbFile = do
      conn <- SQLite3.newDB dbFile
      _ <- SQLite3.queryDB conn createMessageTableQuery []
      _ <- SQLite3.queryDB conn createUserTableQuery []
      Traversable.for_ initialUsers \{ id, url, name } -> do
        SQLite3.queryDB
          conn
          insertUserQuery
          (map
            Foreign.unsafeToForeign
            [ id, name, url ])
      Traversable.for_
        initialMessages
        \{ created_at, id, message, user_id } -> do
        SQLite3.queryDB
          conn
          insertMessageQuery
          (map
            Foreign.unsafeToForeign
            [ Type.timestampToString created_at, id, message, user_id ])
      SQLite3.closeDB conn

    createMessageTableQuery :: String
    createMessageTableQuery =
      String.joinWith
        "\n"
        [ "CREATE TABLE IF NOT EXISTS messages"
        , "  ( created_at TEXT NOT NULL"
        , "  , id TEXT PRIMARY KEY"
        , "  , message TEXT NOT NULL"
        , "  , user_id TEXT NOT NULL"
        , "  )"
        ]

    createUserTableQuery :: String
    createUserTableQuery =
      String.joinWith
        "\n"
        [ "CREATE TABLE IF NOT EXISTS users"
        , "  ( id TEXT PRIMARY KEY"
        , "  , name TEXT NOT NULL UNIQUE"
        , "  , url TEXT NOT NULL"
        , "  )"
        ]

    insertMessageQuery :: String
    insertMessageQuery =
      String.joinWith
        "\n"
        [ "INSERT OR IGNORE INTO messages"
        , "  ( created_at"
        , "  , id"
        , "  , message"
        , "  , user_id"
        , "  )"
        , "  VALUES"
        , "  ( ?"
        , "  , ?"
        , "  , ?"
        , "  , ?"
        , "  )"
        ]

    insertUserQuery :: String
    insertUserQuery =
      String.joinWith
        "\n"
        [ "INSERT OR IGNORE INTO users"
        , "  ( id"
        , "  , name"
        , "  , url"
        , "  )"
        , "  VALUES"
        , "  ( ?"
        , "  , ?"
        , "  , ?"
        , "  )"
        ]

    db :: String
    db = "./main.sqlite"

    port :: Int
    port = 8080
