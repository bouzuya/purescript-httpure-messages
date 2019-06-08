module Main
  ( main
  ) where

import Prelude

import Action as Action
import Data.Either as Either
import Data.Maybe as Maybe
import Data.String as String
import Data.Traversable as Traversable
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Aff as Aff
import Effect.Class as Class
import Effect.Console as Console
import HTTPure (Request, ResponseM)
import HTTPure as HTTPure
import Model.Message as ModelMessage
import Model.User as ModelUser
import Partial.Unsafe as Unsafe
import Query as Query
import Router as Router
import SQLite3 as SQLite3
import Type (DB, UserParams)

initialMessages :: Array { message :: String, userName :: String }
initialMessages =
  [ { message: "Hello"
    , userName: "user 1"
    }
  , { message: "World"
    , userName: "user 1"
    }
  , { message: "World"
    , userName: "user 2"
    }
  ]

initialUsers :: Array UserParams
initialUsers =
  [ { url: "https://duckduckgo.com/", name: "user 1" }
  , { url: "https://bouzuya.net/", name: "user 2" }
  , { url: "https://blog.bouzuya.net/", name: "user 3" }
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
        Either.Left (Router.MethodNotAllowed methods) ->
          HTTPure.methodNotAllowed'
            (HTTPure.header
              "Allow"
              (String.joinWith ", " (map (String.toUpper <<< show) methods)))

    booted :: Effect Unit
    booted = Console.log "Server now up on port 8080"

    createDB :: String -> Aff Unit
    createDB dbFile = do
      conn <- SQLite3.newDB dbFile
      _ <- SQLite3.queryDB conn createMessageTableQuery []
      _ <- SQLite3.queryDB conn createUserTableQuery []
      Traversable.for_ initialUsers \user -> do
        ModelUser.create dbFile user
      users <- ModelUser.index dbFile
      Traversable.for_ initialMessages \{ message, userName } -> do
        userMaybe <-
          pure (Traversable.find (\{ name } -> eq name userName) users)
        case userMaybe of
          Maybe.Nothing -> Unsafe.unsafeCrashWith "no user"
          Maybe.Just { id: user_id } ->
            ModelMessage.create dbFile { user_id, message }

    createMessageTableQuery :: String
    createMessageTableQuery =
      Query.createTable
        "messages"
        [ Query.columnDef "created_at" "TEXT" ["NOT NULL"]
        , Query.columnDef "id" "TEXT" ["PRIMARY KEY"]
        , Query.columnDef "message" "TEXT" ["NOT NULL"]
        , Query.columnDef "user_id" "TEXT" ["NOT NULL"]
        ]

    createUserTableQuery :: String
    createUserTableQuery =
      Query.createTable
        "users"
        [ Query.columnDef "created_at" "TEXT" ["NOT NULL"]
        , Query.columnDef "id" "TEXT" ["PRIMARY KEY"]
        , Query.columnDef "name" "TEXT" ["NOT NULL", "UNIQUE"]
        , Query.columnDef "url" "TEXT" ["NOT NULL"]
        ]

    insertMessageQuery :: String
    insertMessageQuery =
      Query.insertOrIgnore "messages" ["created_at", "id", "message", "user_id"]

    insertUserQuery :: String
    insertUserQuery =
      Query.insertOrIgnore "users" ["id", "name", "url"]

    db :: String
    db = "./main.sqlite"

    port :: Int
    port = 8080
