{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name =
    "my-project"
, dependencies =
    [ "bouzuya-datetime-formatter"
    , "bouzuya-uuid-v4"
    , "console"
    , "effect"
    , "httpure"
    , "node-sqlite3"
    , "simple-json"
    , "test-unit"
    ]
, packages =
    ./packages.dhall
}
