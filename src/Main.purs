module Main
  ( main
  ) where

import Prelude

import Action as Action
import Data.Either as Either
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
import Router as Router
import SQLite3 as SQLite3
import Type (User, DB)

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
      _ <- SQLite3.queryDB conn createTableQuery []
      Traversable.for_ initialUsers \{ id, url, name } -> do
        SQLite3.queryDB
          conn
          createSeed
          (map
            Foreign.unsafeToForeign
            [ id, name, url ])
      SQLite3.closeDB conn

    createSeed :: String
    createSeed =
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

    createTableQuery :: String
    createTableQuery =
      String.joinWith
        "\n"
        [ "CREATE TABLE IF NOT EXISTS users"
        , "  ( id TEXT PRIMARY KEY"
        , "  , name TEXT NOT NULL UNIQUE"
        , "  , url TEXT NOT NULL"
        , "  )"
        ]

    db :: String
    db = "./main.sqlite"

    port :: Int
    port = 8080
