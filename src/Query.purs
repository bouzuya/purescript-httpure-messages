module Query
  ( columnDef
  , createTable
  , delete
  , insert
  , insertOrIgnore
  , selectSimple
  , update
  ) where

import Prelude

import Data.String as String

type TableName = String
type ColumnName = String
type TypeName = String
type ColumnConstraint = String
type ColumnDef =
  { columnName :: ColumnName
  , typeName :: TypeName
  , columnConstraints :: Array ColumnConstraint
  }

columnDef :: ColumnName -> TypeName -> Array ColumnConstraint -> ColumnDef
columnDef columnName typeName columnConstraints =
  { columnName, typeName, columnConstraints }

createTable :: TableName -> Array ColumnDef -> String
createTable tableName columnDefs =
  String.joinWith
    "\n"
    [ "CREATE TABLE IF NOT EXISTS " <> tableName
    , "  ( " <> (String.joinWith "\n  , " (map columnDefToString columnDefs))
    , "  )"
    ]

delete :: TableName -> String -> String
delete tableName condition =
  String.joinWith
    "\n"
    [ "DELETE"
    , "  FROM " <> tableName
    , " WHERE " <> condition
    ]

insert :: TableName -> Array ColumnName -> String
insert tableName columnNames =
  String.joinWith
    "\n"
    [ "INSERT INTO " <> tableName
    , "  ( " <> (String.joinWith "\n  , " columnNames)
    , "  )"
    , "  VALUES"
    , "  ( " <> (String.joinWith "\n  , " (map (const "?") columnNames))
    , "  )"
    ]

insertOrIgnore :: TableName -> Array ColumnName -> String
insertOrIgnore tableName columnNames =
  String.joinWith
    "\n"
    [ "INSERT OR IGNORE INTO " <> tableName
    , "  ( " <> (String.joinWith "\n  , " columnNames)
    , "  )"
    , "  VALUES"
    , "  ( " <> (String.joinWith "\n  , " (map (const "?") columnNames))
    , "  )"
    ]

selectSimple :: Array ColumnName -> TableName -> String -> String
selectSimple columnNames tableName condition =
  String.joinWith
    "\n"
    [ "SELECT " <> (String.joinWith "\n     , " columnNames)
    , "  FROM " <> tableName
    , " WHERE " <> condition
    ]

update :: TableName -> Array ColumnName -> String -> String
update tableName columnNames condition =
  String.joinWith
    "\n"
    [ "UPDATE " <> tableName
    , "   SET " <> (String.joinWith "\n     , " (map (_ <> " = ?") columnNames))
    , " WHERE " <> condition
    ]

-- private

columnDefToString :: ColumnDef -> String
columnDefToString { columnName, typeName, columnConstraints } =
  String.joinWith
    " "
    [ columnName
    , typeName
    , String.joinWith " " columnConstraints
    ]
