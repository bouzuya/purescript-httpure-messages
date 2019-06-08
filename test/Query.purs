module Test.Query
  ( tests
  ) where

import Data.String as String
import Query as Query
import Test.Unit (TestSuite)
import Test.Unit as TestUnit
import Test.Unit.Assert as Assert

tests :: TestSuite
tests = TestUnit.suite "Query" do
  TestUnit.test "insert" do
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
      (Query.insert "users" ["id", "name", "url"])
