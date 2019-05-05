module Type
  ( DB
  , User
  ) where

type DB = String

type User =
  { id :: String
  , name :: String
  , url :: String
  }
