---
layout: post
title: Oracle Database in Docker
author: Ray Cai
date: October 2nd, 2017
---

## Abstract
Create, Destroy, Start and Stop Oracle Database by Docker.

## Docker
[Docker is the world’s leading software container platform. Developers use Docker to eliminate “works on my machine” problems when collaborating on code with co-workers. Operators use Docker to run and manage apps side-by-side in isolated containers to get better compute density. Enterprises use Docker to build agile software delivery pipelines to ship new features faster, more securely and with confidence for both Linux, Windows Server, and Linux-on-mainframe apps.](https://www.docker.com/what-docker)

### Container
[Containers are a way to package software in a format that can run isolated on a shared operating system. Unlike VMs, containers do not bundle a full operating system - only libraries and settings required to make the software work are needed. This makes for efficient, lightweight, self-contained systems and guarantees that software will always run the same, regardless of where it’s deployed.](https://www.docker.com/what-docker)

### Image
Image is the template of container.

### SDKs and API
[Develop with Docker Engine SDKs and API](https://docs.docker.com/develop/sdk/)

## Oracle Database in Docker
### Pull Pre-built Image
It seems Oracle does not release pre-built docker image of Oracle Database, but opened [image build scripts](https://github.com/oracle/docker-images). Fortunately, some one had built [image](https://hub.docker.com/r/sath89/oracle-12c/).

**Pull Image**
```shell
docker pull sath89/oracle-12c
```

```shell
caishileideMacBook-Pro:~ rscai$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
sath89/oracle-12c   latest              f52b86b93aab        3 days ago          5.7GB
```

### Build Your Image
TBD

### Container Life Cycle

* Create container
    ```shell
    docker create [ -name CONTAINER_NAME ] [ -e VARIABLE_NAME=VARIABLE_VALUE ] [ -p HOST_POST:CONTAINER_PORT ] [ -v HOST_DIR:CONTAINER_DIR ] IMAGE
    ```
    **Turn off Web Console, export port 1521, mapping host's directories to container's**
    ```shell
    docker create -name oracle-db-1 -e WEB_CONSOLE=false -p 1521:1521 -v /my/oracle/data:/u01/app/oracle -v /my/oracle/init/SCRIPTSorSQL:/docker-entrypoint-initdb.d sath89/oracle-12c
    ```
    When container started, it will execute all SQL scripts which under /docker-entrypoint-initdb.d. Therefore it's able to set initialization script by mapping scripts to /docker-entrypoint-initdb.d.
    **List all containers**
    ```shell
    caishileideMacBook-Pro:~ rscai$ docker ps -a
    CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
    0d578c5b8533        sath89/oracle-12c   "/entrypoint.sh "   3 minutes ago       Created                                 oracle-db-1
    ```

* Start container
    ```shell
    docker start CONTAINER
    ```
    ```shell
    caishileideMacBook-Pro:~ rscai$ docker start oracle-db-1
    oracle-db-1
    caishileideMacBook-Pro:~ rscai$ docker ps
    CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS                              NAMES
    0d578c5b8533        sath89/oracle-12c   "/entrypoint.sh "   5 minutes ago       Up 5 seconds        0.0.0.0:1521->1521/tcp, 8080/tcp   oracle-db-1
    ```

* Stop container
    ```shell
    docker stop CONTAINER
    ```
    ```shell
    caishileideMacBook-Pro:~ rscai$ docker stop oracle-db-1
    oracle-db-1
    caishileideMacBook-Pro:~ rscai$ docker ps
    CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
    caishileideMacBook-Pro:~ rscai$ docker ps -a
    CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                        PORTS               NAMES
    0d578c5b8533        sath89/oracle-12c   "/entrypoint.sh "   7 minutes ago       Exited (137) 16 seconds ago                       oracle-db-1
    ```

* Destroy container
    ```shell
    docker rm CONTAINER
    ```
    ```shell
    caishileideMacBook-Pro:~ rscai$ docker rm oracle-db-1
    oracle-db-1
    caishileideMacBook-Pro:~ rscai$ docker ps -a
    CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
    ```
## Create/Destroy Container Remotely

### Docker Remote API
TBD

### Custom Wrapper RESTFul Service

[docker-rest-api](https://github.com/rscai/docker-rest-api) 


## Reference
* [Get Oracle JDBC drivers and UCP from Oracle Maven Repository (without IDEs)](https://blogs.oracle.com/dev2dev/get-oracle-jdbc-drivers-and-ucp-from-oracle-maven-repository-without-ides)

