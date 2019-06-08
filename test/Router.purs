module Test.Router
  ( tests
  ) where

import Prelude

import Action as Action
import Bouzuya.DateTime.Formatter.DateTime as DateTimeFormatter
import Data.Array as Array
import Data.Either as Either
import Data.Maybe (Maybe)
import Data.Maybe as Maybe
import Data.String as String
import Foreign.Object as Object
import HTTPure (Request)
import HTTPure as HTTPure
import HTTPure.Version as Version
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
        httpVersion = Version.HTTP1_1
      in
        { body, headers, httpVersion, method, path, query }

  TestUnit.test "GET /messages" do
    Assert.equal
      (Either.Right Action.MessageIndex)
      (Router.router (request "GET" "/messages" Maybe.Nothing))

  TestUnit.test "POST /messages" do
    let
      dt =
        Unsafe.unsafePartial
          (Maybe.fromJust (DateTimeFormatter.fromString "2019-01-02T03:04:05"))
      message1 =
        { message: "Hello"
        , user_id: "1"
        }
      body1 = SimpleJSON.writeJSON message1
    Assert.equal
      (Either.Right (Action.MessageCreate message1))
      (Router.router (request "POST" "/messages" (Maybe.Just body1)))

  TestUnit.test "GET /messages/{id}" do
    Assert.equal
      (Either.Right (Action.MessageShow "abc"))
      (Router.router (request "GET" "/messages/abc" Maybe.Nothing))

  TestUnit.test "PATCH /messages/{id}" do
    Assert.equal
      (Either.Left (Router.MethodNotAllowed [HTTPure.Get, HTTPure.Delete]))
      (Router.router (request "PATCH" "/messages/abc" (Maybe.Just "")))

  TestUnit.test "DELETE /messages/{id}" do
    Assert.equal
      (Either.Right (Action.MessageDestroy "abc"))
      (Router.router (request "DELETE" "/messages/abc" Maybe.Nothing))

  TestUnit.test "GET /users" do
    Assert.equal
      (Either.Right Action.UserIndex)
      (Router.router (request "GET" "/users" Maybe.Nothing))

  TestUnit.test "POST /users" do
    let
      user1 = { url: "http://example.com", name: "foo" }
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
      user1 = { url: "http://example.com", name: "foo" }
      body1 = SimpleJSON.writeJSON user1
    Assert.equal
      (Either.Right (Action.UserUpdate "abc" user1))
      (Router.router (request "PATCH" "/users/abc" (Maybe.Just body1)))

  TestUnit.test "DELETE /users/{id}" do
    Assert.equal
      (Either.Right (Action.UserDestroy "abc"))
      (Router.router (request "DELETE" "/users/abc" Maybe.Nothing))
