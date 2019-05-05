module Test.Router
  ( tests
  ) where

import Prelude

import Action as Action
import Data.Array as Array
import Data.Either as Either
import Data.Maybe (Maybe)
import Data.Maybe as Maybe
import Data.String as String
import Foreign.Object as Object
import HTTPure (Request)
import HTTPure as HTTPure
import Partial.Unsafe as Unsafe
import Router as Router
import Simple.JSON as SimpleJSON
import Test.Unit (TestSuite)
import Test.Unit as TestUnit
import Test.Unit.Assert as Assert

tests :: TestSuite
tests = TestUnit.suite "Router" do
  let
    request :: String -> String -> Maybe String -> Request
    request s p b =
      let
        body = Maybe.fromMaybe mempty b
        headers = HTTPure.empty
        method = case s of
          "GET" -> HTTPure.Get
          "POST" -> HTTPure.Post
          "PATCH" -> HTTPure.Patch
          "DELETE" -> HTTPure.Delete
          _ -> Unsafe.unsafeCrashWith ("unknown method: " <> s)
        path = Array.drop 1 (String.split (String.Pattern "/") p)
        query = Object.empty
      in
        { body, headers, method, path, query }

  TestUnit.test "GET /users" do
    Assert.equal
      (Either.Right Action.UserIndex)
      (Router.router (request "GET" "/users" Maybe.Nothing))

  TestUnit.test "POST /users" do
    let
      user1 = { id: "1", url: "http://example.com", name: "foo" }
      body1 = SimpleJSON.writeJSON user1
    Assert.equal
      (Either.Right (Action.UserCreate user1))
      (Router.router (request "POST" "/users" (Maybe.Just body1)))

  TestUnit.test "GET /users/{id}" do
    Assert.equal
      (Either.Right (Action.UserShow "abc"))
      (Router.router (request "GET" "/users/abc" Maybe.Nothing))

  TestUnit.test "PATCH /users/{id}" do
    let
      user1 = { id: "abc", url: "http://example.com", name: "foo" }
      body1 = SimpleJSON.writeJSON user1
    Assert.equal
      (Either.Right (Action.UserUpdate "abc" user1))
      (Router.router (request "PATCH" "/users/abc" (Maybe.Just body1)))

  TestUnit.test "DELETE /users/{id}" do
    Assert.equal
      (Either.Right (Action.UserDestroy "abc"))
      (Router.router (request "DELETE" "/users/abc" Maybe.Nothing))
