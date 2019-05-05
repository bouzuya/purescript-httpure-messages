module Type
  ( DB
  , Message
  , Timestamp
  , User
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

instance readForeignTimestamp :: ReadForeign Timestamp where
  readImpl f = do
    s <- SimpleJSON.readImpl f
    case DateTimeFormatter.fromString s of
      Maybe.Nothing -> Foreign.fail (Foreign.ForeignError "Timestamp")
      Maybe.Just dt -> pure (Timestamp dt)

instance writeForeignTimestamp :: WriteForeign Timestamp where
  writeImpl t = SimpleJSON.writeImpl (timestampToString t)

type DB = String

type Message =
  { created_at :: Timestamp
  , message :: String
  , user_id :: String
  , id :: String
  }

type User =
  { id :: String
  , name :: String
  , url :: String
  }

timestampToString :: Timestamp -> String
timestampToString (Timestamp dt) = DateTimeFormatter.toString dt
