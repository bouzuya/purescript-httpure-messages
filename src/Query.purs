module Query
  ( insert
  ) where

import Prelude

import Data.String as String

insert :: String -> Array String -> String
insert tableName columnNames =
  String.joinWith
    "\n"
    [ ("INSERT OR IGNORE INTO " <> tableName)
    , "  ( "
    , (String.joinWith "\n  , " columnNames)
    , "  )"
    , "  VALUES"
    , "  ( "
    , (String.joinWith "\n  , " (map (const "?") columnNames))
    , "  )"
    ]
