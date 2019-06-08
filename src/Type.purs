module Type
  ( DB
  , Message
  , MessageParams
  , Timestamp
  , User
  , UserParams
  , timestampFromDateTime
  , timestampToString
  ) where

import Prelude

import Bouzuya.DateTime.Formatter.DateTime as DateTimeFormatter
import Data.DateTime (DateTime)
import Data.Maybe as Maybe
import Foreign as Foreign
import Simple.JSON (class ReadForeign, class WriteForeign)
import Simple.JSON as SimpleJSON

newtype Timestamp = Timestamp DateTime

derive newtype instance eqTimestamp :: Eq Timestamp

instance readForeignTimestamp :: ReadForeign Timestamp where
  readImpl f = do
    s <- SimpleJSON.readImpl f
    case DateTimeFormatter.fromString s of
      Maybe.Nothing -> Foreign.fail (Foreign.ForeignError "Timestamp")
      Maybe.Just dt -> pure (Timestamp dt)

instance showTimestamp :: Show Timestamp where
  show (Timestamp dt) = "(Timestamp " <> show dt <> ")"

instance writeForeignTimestamp :: WriteForeign Timestamp where
  writeImpl t = SimpleJSON.writeImpl (timestampToString t)

type DB = String

type Message =
  { created_at :: Timestamp
  , id :: String
  , message :: String
  , user_id :: String
  }

type MessageParams =
  { message :: String
  , user_id :: String
  }

type User =
  { id :: String
  , name :: String
  , url :: String
  }

type UserParams =
  { name :: String
  , url :: String
  }

timestampFromDateTime :: DateTime -> Timestamp
timestampFromDateTime = Timestamp

timestampToString :: Timestamp -> String
timestampToString (Timestamp dt) = DateTimeFormatter.toString dt
