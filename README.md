# purescript-httpure-messages

[bouzuya/w010][] 2019-W18

## Note

### get all users

```
$ curl http://localhost:8080/users | jq .
[
  {
    "url": "https://duckduckgo.com/",
    "name": "user 1",
    "id": "e702f9c7-86ba-48c4-8f9c-5d6414ad639a",
    "created_at": "2019-06-08T08:12:44"
  },
  {
    "url": "https://bouzuya.net/",
    "name": "user 2",
    "id": "68edd65f-b293-439d-8472-7aed122de1de",
    "created_at": "2019-06-08T08:12:44"
  },
  {
    "url": "https://blog.bouzuya.net/",
    "name": "user 3",
    "id": "dcdc3c6c-7e0b-4556-ad8f-030bc7a21bb3",
    "created_at": "2019-06-08T08:12:44"
  }
]
```

### get all messages

```
$ curl http://localhost:8080/messages | jq .
[
  {
    "user_id": "e702f9c7-86ba-48c4-8f9c-5d6414ad639a",
    "message": "Hello",
    "id": "9ca6d19e-6112-4138-92e5-1bf624bd6da9",
    "created_at": "2019-06-08T08:12:44"
  },
  {
    "user_id": "e702f9c7-86ba-48c4-8f9c-5d6414ad639a",
    "message": "World",
    "id": "cee52b10-99c0-4165-afc1-b64a3878c823",
    "created_at": "2019-06-08T08:12:44"
  },
  {
    "user_id": "68edd65f-b293-439d-8472-7aed122de1de",
    "message": "World",
    "id": "0938aff9-4236-4e31-b709-c1f7fc113897",
    "created_at": "2019-06-08T08:12:44"
  }
]
```

### create an user and get an user

```
$ curl -X 'POST' -d '{"url":"https://example.com","name":"foo"}' -s http://localhost:8080/users | jq .
{
  "url": "https://example.com",
  "name": "foo",
  "id": "67edb002-a8ba-4e59-854a-54a4358f0fa4",
  "created_at": "2019-06-08T08:13:42"
}

$ curl -s http://localhost:8080/users/67edb002-a8ba-4e59-854a-54a4358f0fa4 | jq .
{
  "url": "https://example.com",
  "name": "foo",
  "id": "67edb002-a8ba-4e59-854a-54a4358f0fa4",
  "created_at": "2019-06-08T08:13:42"
}
```

### create an message and get an message

```
$ curl -X 'POST' -d '{"message":"hi","user_id":"67edb002-a8ba-4e59-854a-54a4358f0fa4"}' -s http://localhost:8080/messages | jq .
{
  "user_id": "67edb002-a8ba-4e59-854a-54a4358f0fa4",
  "message": "hi",
  "id": "a278c25a-f5ad-472d-81c3-12c06916c96b",
  "created_at": "2019-06-08T08:15:22"
}

$ curl -s http://localhost:8080/messages/a278c25a-f5ad-472d-81c3-12c06916c96b | jq .
{
  "user_id": "67edb002-a8ba-4e59-854a-54a4358f0fa4",
  "message": "hi",
  "id": "a278c25a-f5ad-472d-81c3-12c06916c96b",
  "created_at": "2019-06-08T08:15:22"
}
```

### method not allowed

```
$ curl -X DELETE -D - http://localhost:8080/users
HTTP/1.1 405 Method Not Allowed
Allow: GET, POST
Content-Length: 0
Date: Sat, 08 Jun 2019 06:57:45 GMT
Connection: keep-alive
```

[bouzuya/w010]: https://github.com/bouzuya/w010
