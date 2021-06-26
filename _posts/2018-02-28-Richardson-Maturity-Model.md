---
layout: post
title: Richardson Maturity Model
author: Ray Cai
---
# Richardson Maturity Model

* TOC
{:toc}

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
8. **Use HTTP Verbs to represent action**
9. **Use HTTP Status to represent result**

Action|HTTP Verb|URL
------|---------|----------------------
Create|POST     |/resourceType
Update|PUT      |/resourceType/{id}
Delete|DELETE   |/resourceType/{id}
Read  |GET      |/resourceType/{id}
Query |GET      |/resourceType?{queryString}

HTTP Status| Description
------|-------------
200 | OK
201 |Created
204 | No Content
404 |Not Found
500 |Internal Server Error

### Create Resource

Example request:

```http
POST /api/level2/post HTTP/1.1
Content-Type: application/json
Accept: application/json
Host: localhost:8080
Content-Length: 73

{
  "id" : null,
  "content" : "New Post content",
  "createdAt" : null
}
```

Example response:

```http
HTTP/1.1 201 Created
Content-Type: application/json;charset=UTF-8
Content-Length: 97

{
  "id" : 21,
  "content" : "New Post content",
  "createdAt" : "2018-04-30T12:02:08.667+0000"
}
```

### Update Resource

Example request:

```http
PUT /api/level2/post/28 HTTP/1.1
Content-Type: application/json
Accept: application/json
Host: localhost:8080
Content-Length: 79

{
  "id" : 28,
  "content" : "Updated Content",
  "createdAt" : 1525089728910
}
```

Example response:

```http
HTTP/1.1 200 OK
Content-Type: application/json;charset=UTF-8
Content-Length: 96

{
  "id" : 28,
  "content" : "Updated Content",
  "createdAt" : "2018-04-30T12:02:08.910+0000"
}
```

### Delete Resource

Request example:

```http
DELETE /api/level2/post/22 HTTP/1.1
Content-Type: application/json
Accept: application/json
Host: localhost:8080
```

Response example:

```http
HTTP/1.1 200 OK
Content-Type: application/json;charset=UTF-8
Content-Length: 97

{
  "id" : 22,
  "content" : "Original Content",
  "createdAt" : "2018-04-30T12:02:08.719+0000"
}
```

### Get Resource

Request example:

```http
GET /api/level2/post/20 HTTP/1.1
Content-Type: application/json
Accept: application/json
Host: localhost:8080
```

Response example:

```http
HTTP/1.1 200 OK
Content-Type: application/json;charset=UTF-8
Content-Length: 97

{
  "id" : 20,
  "content" : "Original Content",
  "createdAt" : "2018-04-30T12:02:08.626+0000"
}
```

### Query Resource

Request example:

```http
GET /api/level2/post HTTP/1.1
Content-Type: application/json
Accept: application/json
Host: localhost:8080
```

Response example:

```http
HTTP/1.1 200 OK
Content-Type: application/json;charset=UTF-8
Content-Length: 497

[ {
  "id" : 23,
  "content" : "Original Content",
  "createdAt" : "2018-04-30T12:02:08.845+0000"
}, {
  "id" : 24,
  "content" : "Original Content",
  "createdAt" : "2018-04-30T12:02:08.856+0000"
}, {
  "id" : 25,
  "content" : "Original Content",
  "createdAt" : "2018-04-30T12:02:08.862+0000"
}, {
  "id" : 26,
  "content" : "Original Content",
  "createdAt" : "2018-04-30T12:02:08.866+0000"
}, {
  "id" : 27,
  "content" : "Original Content",
  "createdAt" : "2018-04-30T12:02:08.873+0000"
} ]
```

### Sub Resource

Action|HTTP Verb|URL
------|---------|----------------------
Create|POST     |/resourceType/{id}/subResourceType
Update|PUT      |/resourceType/{id}/subResourceType/{subResourceId}
Delete|DELETE   |/resourceType/{id}/subResourceType/{subResourceId}
Read  |GET      |/resourceType/{id}/subResourceType/{subResourceTypeId}
Query |GET      |/resourceType/{id}/subResourceType?{queryString}

#### Create Sub Resource

Request example:

```http
POST /api/level2/post/6/comment HTTP/1.1
Content-Type: application/json
Accept: application/json
Host: localhost:8080
Content-Length: 174

{
  "id" : null,
  "content" : "Comment's content",
  "createdAt" : null,
  "post" : {
    "id" : 6,
    "content" : "Original Content",
    "createdAt" : 1525089727497
  }
}
```

Response example:

```http
HTTP/1.1 201 Created
Content-Type: application/json;charset=UTF-8
Content-Length: 214

{
  "id" : 7,
  "content" : "Comment's content",
  "createdAt" : "2018-04-30T12:02:07.578+0000",
  "post" : {
    "id" : 6,
    "content" : "Original Content",
    "createdAt" : "2018-04-30T12:02:07.497+0000"
  }
}
```

#### Update Sub Resource

Request example:

```http
PUT /api/level2/post/18/comment/19 HTTP/1.1
Content-Type: application/json
Accept: application/json
Host: localhost:8080
Content-Length: 180

{
  "id" : 19,
  "content" : "Updated content",
  "createdAt" : 1525089728552,
  "post" : {
    "id" : 18,
    "content" : "Original Content",
    "createdAt" : 1525089728534
  }
}
```

Response example:

```http
HTTP/1.1 200 OK
Content-Type: application/json;charset=UTF-8
Content-Length: 214

{
  "id" : 19,
  "content" : "Updated content",
  "createdAt" : "2018-04-30T12:02:08.552+0000",
  "post" : {
    "id" : 18,
    "content" : "Original Content",
    "createdAt" : "2018-04-30T12:02:08.534+0000"
  }
}
```

#### Delete Sub Resource

Request example:

```http
DELETE /api/level2/post/8/comment/9 HTTP/1.1
Content-Type: application/json
Accept: application/json
Host: localhost:8080
```

Response example:

```http
HTTP/1.1 200 OK
Content-Type: application/json;charset=UTF-8
Content-Length: 217

{
  "id" : 9,
  "content" : "New Comment's conent",
  "createdAt" : "2018-04-30T12:02:07.678+0000",
  "post" : {
    "id" : 8,
    "content" : "Original Content",
    "createdAt" : "2018-04-30T12:02:07.648+0000"
  }
}
```

#### Get Sub Resource

Request example:

```http
GET /api/level2/post/16/comment/17 HTTP/1.1
Content-Type: application/json
Accept: application/json
Host: localhost:8080
```

Response example:

```http
HTTP/1.1 200 OK
Content-Type: application/json;charset=UTF-8
Content-Length: 219

{
  "id" : 17,
  "content" : "New Comment's conent",
  "createdAt" : "2018-04-30T12:02:08.462+0000",
  "post" : {
    "id" : 16,
    "content" : "Original Content",
    "createdAt" : "2018-04-30T12:02:08.445+0000"
  }
}
```

#### Query Sub Resource

Request example:

```http
GET /api/level2/post/10/comment HTTP/1.1
Content-Type: application/json
Accept: application/json
Host: localhost:8080
```

Response example:

```http
HTTP/1.1 200 OK
Content-Type: application/json;charset=UTF-8
Content-Length: 1107

[ {
  "id" : 11,
  "content" : "New Comment's conent",
  "createdAt" : "2018-04-30T12:02:07.822+0000",
  "post" : {
    "id" : 10,
    "content" : "Original Content",
    "createdAt" : "2018-04-30T12:02:07.785+0000"
  }
}, {
  "id" : 12,
  "content" : "New Comment's conent",
  "createdAt" : "2018-04-30T12:02:07.848+0000",
  "post" : {
    "id" : 10,
    "content" : "Original Content",
    "createdAt" : "2018-04-30T12:02:07.785+0000"
  }
}, {
  "id" : 13,
  "content" : "New Comment's conent",
  "createdAt" : "2018-04-30T12:02:07.872+0000",
  "post" : {
    "id" : 10,
    "content" : "Original Content",
    "createdAt" : "2018-04-30T12:02:07.785+0000"
  }
}, {
  "id" : 14,
  "content" : "New Comment's conent",
  "createdAt" : "2018-04-30T12:02:07.895+0000",
  "post" : {
    "id" : 10,
    "content" : "Original Content",
    "createdAt" : "2018-04-30T12:02:07.785+0000"
  }
}, {
  "id" : 15,
  "content" : "New Comment's conent",
  "createdAt" : "2018-04-30T12:02:07.919+0000",
  "post" : {
    "id" : 10,
    "content" : "Original Content",
    "createdAt" : "2018-04-30T12:02:07.785+0000"
  }
} ]
```

## level 3 -- Hypermedia Controls

All resources are connected.

```puml
digraph d {
  collection_1 [label=collection]
  resource_11 [label=resource]
  resource_12 [label=resource]
  collection_2 [label=collection]
  resource_21 [label=resource]
  resource_22 [label=resource]
  resource_23 [label=resource]

  collection_1 -> resource_11
  collection_1 -> resource_12

  collection_2 -> resource_21
  collection_2 -> resource_22
  collection_2 -> resource_23

  resource_23 -> resource_11
}
```

For example:

```puml
digraph d {
  post_collection [label=posts]
  post_1 [label="post#1"]
  post_2 [label="post#2"]
  comment_collection [label=comments]
  comment_11 [label="comment#11"]
  comment_12 [label="comment#12"]
  comment_21 [label="comment#21"]

  post_collection -> post_1 [label="/posts/1"]
  post_collection -> post_2 [label="/posts/2"]

  comment_collection -> comment_11 [label="/comments/11"]
  comment_collection -> comment_12 [label="/comments/12"]
  comment_collection -> comment_21 [label="/comments/21"]

  comment_11 -> post_1 [label="/comments/11/post"]
  comment_12 -> post_1 [label="/comments/12/post"]
  comment_21 -> post_2 [label="/comments/21/post"]

  university [style=dotted,label=""]

  university -> post_collection [label="/posts"]
  university -> comment_collection [label="/comments"]

  {rank=same;post_collection,comment_collection}
  {rank=same;post_1,post_2}
  {rank=same;comment_11,comment_12,comment_21}
}
```

### Create Resource

#### Create resource node

Request example:

```http
POST /comments HTTP/1.1
Content-Type: application/json
Accept: application/json
Host: localhost:8080
Content-Length: 66

{
  "id" : null,
  "content" : "comment 1",
  "createdAt" : null
}
```

Response example:

```http
HTTP/1.1 201 Created
Location: http://localhost:8080/comments/5af80a6f18151728a745b2ae
Content-Type: application/json;charset=UTF-8
Content-Length: 263

{
  "content" : "comment 1",
  "createdAt" : null,
  "_links" : {
    "self" : {
      "href" : "http://localhost:8080/comments/5af80a6f18151728a745b2ae"
    },
    "comment" : {
      "href" : "http://localhost:8080/comments/5af80a6f18151728a745b2ae"
    }
  }
}
```

#### Link to other resource

Request example:

```http
POST /posts/5af80a6f18151728a745b2ad/comments HTTP/1.1
Content-Type: text/uri-list
Host: localhost:8080
Content-Length: 55

http://localhost:8080/comments/5af80a6f18151728a745b2ae
```

Response example:

```http
HTTP/1.1 204 No Content

```

## Comparison

Feature| Level 0| Level 1| Level 2| Level 3
-----|--------|--------|--------|---------
HTTP |✔︎|✔︎|✔︎|✔︎
Domain Model| |✔︎|✔︎|✔︎
HTTP Verbs| | |✔︎|✔︎
HTTP Status| | |✔︎|✔︎

## Reference

* [Richardson Maturity Model](https://www.martinfowler.com/articles/richardsonMaturityModel.html)
* [Remote Procedure Invocation](http://www.enterpriseintegrationpatterns.com/patterns/messaging/EncapsulatedSynchronousIntegration.html)
* [Hypertext Transfer Protocol -- HTTP/1.1](https://tools.ietf.org/rfc/rfc2616.txt)
* [The text/uri-list Internet Media Type](https://tools.ietf.org/html/rfc2483#section-5)
* [Ricahrdson Maturity Model Example](https://github.com/rscai/richardson-maturity-model-example)