# purescript-httpure-messages

[bouzuya/w010][] 2019-W18

## Note

```
$ curl http://localhost:8080/users | jq .
[
  {
    "url": "https://duckduckgo.com/",
    "name": "search engine",
    "id": "1"
  },
  {
    "url": "https://bouzuya.net/",
    "name": "my page",
    "id": "2"
  },
  {
    "url": "https://blog.bouzuya.net/",
    "name": "my blog",
    "id": "3"
  }
]
```

```
$ curl http://localhost:8080/messages | jq .
[
  {
    "user_id": "1",
    "message": "Hello",
    "id": "1",
    "created_at": "2019-01-02T03:04:05"
  },
  {
    "user_id": "1",
    "message": "World",
    "id": "2",
    "created_at": "2019-01-02T03:04:10"
  },
  {
    "user_id": "2",
    "message": "World",
    "id": "3",
    "created_at": "2019-01-02T03:04:20"
  }
]
```

[bouzuya/w010]: https://github.com/bouzuya/w010
