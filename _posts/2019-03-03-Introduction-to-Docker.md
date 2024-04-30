---
author: Ray Cai
date: March 3rd, 2019
---
# Introduction to Docker

## What

TBD

## Why

```puml
@startuml
node {
    frame "OS v x.x" {
        card App
        card library
        card tools

        App -> library: link
        App --> tools: call
    }
}
@enduml
```

## Backup and Recovery

Backup all files and recover to new hardware.

```puml
@startuml
frame "Hardware A" {
    frame OS {
        card app
    }
}
@enduml
```

## Virtualization

```puml
@startuml
frame Hardware {
    frame "Host OS" {
        frame "Guest OS A" {
            card AppA
        }
        frame "Guest OS B" {
            card AppB
        }
    }
}
@enduml
```

## Containerization

```puml
@startuml
frame Hardware {
    frame OS {
        frame "Docker Engine" {
            frame "Container A" {
                card AppA
            }
            frame "Container B" {
                card AppB
            }
        }
    }
}
@enduml
```

## How 

TBD

## When

TBD

## Reference

