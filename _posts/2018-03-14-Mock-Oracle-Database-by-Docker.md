---
layout: post
title: Mock Oracle Database by Docker
author: Ray Cai
---
# Mock Oracle Database by Docker

> for testing

[TOC]

## Overview

## System and Software Information

Name|Version
----|-------
OS  | Ubuntu 16.04.4 LTS (GNU/Linux 4.4.0-116-generic x86_64)
Docker| 17.12.1-ce, build 7390fc6

## Docker

> Docker provides a way to run applications securely isolated in a container, packaged with all its dependencies and libraries.

### Install Docker

See offical document [Install Docker](https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-docker-ce-1).

### Enable Remote API

Set the hosts array in the `/etc/docker/daemon.json` to connect to the UNIX socket and an IP address, as follows:

```json
{
  "hosts": ["fd://", "tcp://0.0.0.0:4243"]
}
```

Restart docker daemon

```shell
service docker restart
```

It may get error:

```txt
unable to configure the Docker daemon with file /etc/docker/daemon.json: the following directives are specified both as a flag and in the configuration file: hosts: (from flag: [fd://], from file: [tcp://0.0.0.0:4243])
```

It because `docker.service` hard code argument `-H fd://` for `/usr/bin/dockerd`. Edit `/lib/systemd/system/docker.service`, change `ExecStart=/usr/bin/dockerd -H fd://` to `ExecStart=/usr/bin/dockerd`.

```txt
[Service]
Type=notify
# the default is not to use systemd for cgroups because the delegate issues still
# exists and systemd currently does not support the cgroup feature set required
# for containers run by docker
ExecStart=/usr/bin/dockerd
ExecReload=/bin/kill -s HUP $MAINPID
LimitNOFILE=1048576
```

Reload `docker.service`

```shell
systemctl daemon-reload
```

Then restart docker daemon

```shell
service docker restart
```

### Verify Docker Remote API

List installed images by commandline client `docker`, it commuicates with docker daemon via sock `unix:///var/run/docker.sock`

```shell
dev@ubuntu-vb:~$ docker image ls
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
sath89/oracle-12c   latest              17cd1ab9d9a7        3 months ago        5.7GB
hello-world         latest              f2a91732366c        3 months ago        1.85kB
```

Send `GET` HTTP request to `http://ubuntu-vb:4243/images/json`, it should get same image list as via commandline client `docker`.

```http
GET /images/json HTTP/1.1
Host: ubuntu-vb:4243
Connection: keep-alive
Cache-Control: max-age=0
Upgrade-Insecure-Requests: 1
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Safari/537.36
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8
Accept-Encoding: gzip, deflate
Accept-Language: zh-CN,zh;q=0.9,en;q=0.8
```

```http
HTTP/1.1 200 OK
Api-Version: 1.35
Content-Type: application/json
Docker-Experimental: false
Ostype: linux
Server: Docker/17.12.1-ce (linux)
Date: Sat, 17 Mar 2018 13:34:59 GMT
Content-Length: 682

[{
    "Containers": -1,
    "Created": 1512650278,
    "Id": "sha256:17cd1ab9d9a7faf883ec2a0b3be19c221fe38212961c925f289e88823ed24a9c",
    "Labels": {},
    "ParentId": "",
    "RepoDigests": ["sath89/oracle-12c@sha256:a0f6f1cfd3738b0c00f4025a656335b53c205b3bfc0722908ee7b1469111665b"],
    "RepoTags": ["sath89/oracle-12c:latest"],
    "SharedSize": -1,
    "Size": 5703441170,
    "VirtualSize": 5703441170
}, {
    "Containers": -1,
    "Created": 1511223798,
    "Id": "sha256:f2a91732366c0332ccd7afd2a5c4ff2b9af81f549370f7a19acd460f87686bc7",
    "Labels": null,
    "ParentId": "",
    "RepoDigests": ["hello-world@sha256:97ce6fa4b6cdc0790cda65fe7290b74cfebd9fa0c9b8c38e979330d547d22ce1"],
    "RepoTags": ["hello-world:latest"],
    "SharedSize": -1,
    "Size": 1848,
    "VirtualSize": 1848
}]
```

## Docker Engine API

[Docker Engine API](https://docs.docker.com/engine/api/latest/)

## Dockerizing Oracle Database

Oracle does not offer offical docker image of Oracle Database, but provide [docker file](https://github.com/oracle/docker-images/tree/master/OracleDatabase/SingleInstance), allow users to build image by themselves. Besides, there are a lot of thrid party Oracle Database docker images. Here I use third party Oracle Database docker images [sath89/oracle-xe-11g](https://hub.docker.com/r/sath89/oracle-xe-11g/) for convience.

```shell
docker pull sath89/oracle-xe-11g
```

```shell
docker run -d -e WEB_CONSOLE=false -p 1521:1521 sath89/oracle-xe-11g
```

```txt
port: 1521
sid: xe
service name: xe
username: system
password: oracle
```

```http
POST /containers/create HTTP/1.1
content-type: application/json

{
    "Env":[
        "WEB_CONSOLE=false"
    ],
    "Image":"sath89/oracle-xe-11g",
    "HostConfig":{
        "PortBindings":{
            "1521/tcp":[
                {
                    "HostPort":"1521"
                }
            ]
        }
    }
}
```

```http
201 Created
api-version: 1.35
content-type: application/json
docker-experimental: false
ostype: linux
server: Docker/17.12.1-ce (linux)
date: Mon, 19 Mar 2018 13:57:28 GMT
content-length: 90

{
"Id": "0eb6f3bfcdeba9fd604bae3f684d077a59b8a5c8daad0fa947977a284e80ac93",
"Warnings": null
}
```

```http
POST /containers/{containerId}/start HTTP/1.1
```

```http
204 No Content
api-version: 1.35
docker-experimental: false
ostype: linux
server: Docker/17.12.1-ce (linux)
date: Mon, 19 Mar 2018 14:04:59 GMT

```

```http
POST /containers/{containerId}/stop HTTP/1.1
```

```http
204 No Content
api-version: 1.35
docker-experimental: false
ostype: linux
server: Docker/17.12.1-ce (linux)
date: Mon, 19 Mar 2018 14:02:34 GMT

```

```http
DELETE /containers/{containerId} HTTP/1.1
```

```http
204 No Content
api-version: 1.35
docker-experimental: false
ostype: linux
server: Docker/17.12.1-ce (linux)
date: Mon, 19 Mar 2018 14:07:41 GMT

```

Force delete container

```http
DELETE /containers/{containerId}?force=true HTTP/1.1
```

```http
204 No Content
api-version: 1.35
docker-experimental: false
ostype: linux
server: Docker/17.12.1-ce (linux)
date: Mon, 19 Mar 2018 14:09:53 GMT
```

## Reference

* [Install Docker](https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-docker-ce-1)
* [Examples using the Docker Engine SDKs and Docker API](https://docs.docker.com/develop/sdk/examples/)
* [Quick Tip – How to enable Docker Remote API?](https://www.virtuallyghetto.com/2014/07/quick-tip-how-to-enable-docker-remote-api.html)
