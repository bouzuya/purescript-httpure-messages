module Test.Query
  ( tests
  ) where

import Prelude

import Data.String as String
import Query as Query
import Test.Unit (TestSuite)
import Test.Unit as TestUnit
import Test.Unit.Assert as Assert

tests :: TestSuite
tests = TestUnit.suite "Query" do
  TestUnit.test "createTable" do
    Assert.equal
      (String.joinWith
        "\n"
        [ "CREATE TABLE IF NOT EXISTS users"
        , "  ( id TEXT PRIMARY KEY"
        , "  , name TEXT NOT NULL UNIQUE"
        , "  , url TEXT NOT NULL"
        , "  )"
        ])
      (Query.createTable
        "users"
        [ Query.columnDef "id" "TEXT" ["PRIMARY KEY"]
        , Query.columnDef "name" "TEXT" ["NOT NULL", "UNIQUE"]
        , Query.columnDef "url" "TEXT" ["NOT NULL"]
        ])

  TestUnit.test "insertOrIgnore" do
    Assert.equal
      (String.joinWith
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
        ])
      (Query.insertOrIgnore "users" ["id", "name", "url"])
