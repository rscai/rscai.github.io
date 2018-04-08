---
layout: post
title: Richardson Maturity Model
author: Ray Cai
---
# Richardson Maturity Model

## Overview

## Level 0 - HTTP

On level 0 API, it is using HTTP as a transport system for remote interaction, but without using any of the mechanism of web. It is not using the HTTP verbs or status code.
A level 0 API usually include below features:

1. Use one or a few URL endpoint to receive all request
2. Send all request by one HTTP method, mostly POST
3. Always response HTTP status 200 regardless of sucess or fail
4. Contain verbs, likes action or command code, in request body
5. Contain status in response body, likes SUCESS, FAIL, etc.
6. The structures of request body and response body are action/command specific

For example, here is a set of API of blogging service. It should handle two domain models `Post` and `Comment`. And it should support operations:

1. Create `Post`
2. Create `Comment`, each `Comment` must belong to some `Post`, and newed `Comment` stays at state `SUBMITTED`
3. Accept `Comment`, it only works when `Comment` stays at state `SUBMITTED`, and it transits to state `ACCEPTED` after accepted
4. Reject `Comment`, it only works when `Comment` stays at state `SUBMITTED`, and it transits to state `REJECTED` after rejected
5. Delete `Comment`, it is able to remove `Comment` in any state
6. Delete `Post`, it will delete all related `Comment`

On level 0 API desgin, it exposes one URL endpoint to receive all request, and only uses HTTP method **POST**.

Because it uses one URL endpoint to receive all request, it is not able to determine operation type by URL or HTTP method. Therefore it has to provide operation, action or command code in request body. And per business requirement, the parameters are different among operation/action/command. Considering of code simplification, it usually defines a generic structure to contain various parameters, likes type-free key-value list.

**Request Payload:**
Path|Type|Description
----|----|-----------
command|String|must be 'createPost'
parameters.content|String|content of post

**Example:**

```http
POST /api/level0/operation HTTP/1.1
Content-Type: application/json;charset=UTF-8
Accept: application/json
Host: localhost:8080
Content-Length: 86

{
  "command" : "createPost",
  "parameters" : {
    "content" : "Test post 123"
  }
}
```

In response, it does not use HTTP status. Therefore it has to provide status code in response body, and wrapper business data in type-free key-value list.

**Response Paylaod:**

Path|Type|Description
----|----|-----------
status|String|result status
message|String|error message if failed
parameters.id|Long|post's id
parameters.content|String|post's content
parameters.createdAt|Date|timestamp of created post

**Example:**

```http
HTTP/1.1 200 OK
Content-Type: application/json
Content-Length: 164

{
  "status" : "SUCCESS",
  "message" : "",
  "parameters" : {
    "id" : 3,
    "content" : "Test post 123",
    "createdAt" : "Sun Mar 11 15:43:11 CST 2018"
  }
}
```

**Cons:**

TODO

## Level 1 - Resources

The first step towards the Glory of Rest in the RMM is to introduce resources. So now rather than making all our requests to a singular service endpoint, we now start talking to individual resources.

Compared to level 0, level 1 has features:

1. ~~Use one or a few URL endpoint to receive all request~~ **Expose multiple URL endpoints, each one only responds to requests of individual resource**
2. Send all request by one HTTP method, mostly POST
3. Always response HTTP status 200 regardless of sucess or fail
4. Contain verbs, likes action or command code, in request body
5. Contain status in response body, likes SUCESS, FAIL, etc.
6. ~~The structures of request body and response body are action/command specific~~ **Each URL endpoint only accept fixed structure request payload and response fixed structure payload**
7. **Define resources which used in many reqeuest/response paylaod**

Take previous blogging API as example, in level 1 pattern, it should define resources `Post` and `Comment`.

**Post:**

Field|Type|Optional?|Description
-----|----|---------|-----------
id|Long|N|unique identifier
content|String|N|content of post
createdAt|Date|N|timestamp of created post

**Example(in JSON):**

```json
{
    "id" : 5,
    "content" : "Test Post 123",
    "createdAt" : "2018-03-11T07:43:11.840+0000"
  }
```

**Comment:**

Field|Type|Optional?|Description
-----|----|---------|-----------
id|Long|N|unique identifier
content|String|N|content of comment
createdAt|Date|N|timestamp of created comment
postId|Long|N|post's id

**Example(in JSON):**

```json
{
    "id" : 4,
    "content" : "Test Comment 123",
    "createdAt" : "2018-03-11T07:43:11.705+0000",
    "post" : {
      "id" : 1,
      "content" : "Test Post 1",
      "createdAt" : "2018-03-11T07:43:11.524+0000"
    }
  }
```

It exposes individual URL endpoint for each resource. And because each URL endpoint only accept request of one resource, therefore it is able to add strict constraint on request payload.
Take resource `Post` as example, it exposes URL endpoint `/api/level1/post` to accept all `Post` related request. And define constraint on request payload by using resource `Post` definition.

**Request Payload:**

Path|Type|Description
----|----|-----------
command|String|must be 'createPost'
data|Post|post

**Example:**

```http
POST /api/level1/post HTTP/1.1
Content-Type: application/json
Accept: application/json
Host: localhost:8080
Content-Length: 117

{
  "command" : "create",
  "data" : {
    "id" : null,
    "content" : "Test Post 123",
    "createdAt" : null
  }
}
```

Correspondingly, the struct of response payload is fixed too.

**Response Payload:**
Path|Type|Description
----|----|-----------
status|String|result status
message|String|error message if failed
data|Post|post

**Example:**

```http
HTTP/1.1 200 OK
Content-Type: application/json;charset=UTF-8
Content-Length: 160

{
  "status" : "SUCCESS",
  "message" : null,
  "data" : {
    "id" : 5,
    "content" : "Test Post 123",
    "createdAt" : "2018-03-11T07:43:11.840+0000"
  }
}
```

**Cons:**

TODO

## level 2 - HTTP Verbs

It uses HTTP POST verbs for interactions in level 0 and 1. At these levels it doesn't make much difference, they are both being used as tunneling mechanisms allowing you to tunnel your interactions through HTTP. Level 2 moves away from this, using the HTTP verbs as closely as possible to how they are used in HTTP itself.

Compared to level, level 2 has features:

1. Expose multiple URL endpoints, each one only responds to requests of individual resource
2. ~~Send all request by one HTTP method, mostly POST~~
3. ~~Always response HTTP status 200 regardless of sucess or fail~~
4. ~~Contain verbs, likes action or command code, in request body~~
5. ~~Contain status in response body, likes SUCESS, FAIL, etc.~~
6. Each URL endpoint only accept fixed structure request payload and response fixed structure payload
7. Define resources which used in many reqeuest/response paylaod

**CRUD**

**HTTP Verbs**

## level 3 -- Hypermedia Controls

## Reference

* [Richardson Maturity Model](https://www.martinfowler.com/articles/richardsonMaturityModel.html)
* [Remote Procedure Invocation](http://www.enterpriseintegrationpatterns.com/patterns/messaging/EncapsulatedSynchronousIntegration.html)
