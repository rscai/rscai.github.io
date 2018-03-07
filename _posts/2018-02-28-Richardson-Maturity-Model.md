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

```HTTP
POST /api/level0/operation HTTP/1.1
```

Because it uses one URL endpoint to receive all request, it is not able to determine operation type by URL or HTTP method. Therefore it has to provide operation, action or command code in request body. And per business requirement, the parameters are different among operation/action/command. Considering of code simplification, it usually defines a generic structure to contain various parameters, likes type-free key-value list.

```json
{
    "command": "createPost",
    "parameters": {
        "content": "Test post 123"
    }
}
```

In response, it does not use HTTP status. Therefore it has to provide status code in response body, and wrapper business data in type-free key-value list.

```json
{
    "status": "SUCCESS",
    "message": "",
    "parameters": {
        "id": 1,
        "content": "Test post 123",
        "createdAt": "Mon Mar 05 22:20:50 CST 2018"
    }
}
```

## Level 1 - Resources

## level 2 - HTTP Verbs

## level 3 -- Hypermedia Controls

## Reference

* [Richardson Maturity Model](https://www.martinfowler.com/articles/richardsonMaturityModel.html)
* [Remote Procedure Invocation](http://www.enterpriseintegrationpatterns.com/patterns/messaging/EncapsulatedSynchronousIntegration.html)
