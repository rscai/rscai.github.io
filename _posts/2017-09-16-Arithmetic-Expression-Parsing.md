---
layout: post
title: Arithmetic Expression Parsing
author: Ray Cai
date: September 16, 2017
---

## Abstract
Parse literal arithmetic expression into Tree.

## Problem
Given literal arithmetic expression, convert into tree model. In the tree model, node which has higher operator precedence stays at higher level.

For example:
```java
1 + 2
```

```dot
digraph d {
    addition [label="+"];

    addition -> 1
    addition -> 2
}
```

```java
1 + 2 * 3 - 4 / 5
```
```dot
digraph d {
    addition [label="+"];
    subtraction [label="-"];
    1
    multiplication [label="*"];
    division [label="/"];

    addition -> 1
    addition -> multiplication
    multiplication -> 2
    multiplication -> 3
    subtraction -> addition
    subtraction -> division
    division -> 4
    division -> 5
}
```

## Algorithm
Categorize elements of arithmetic expression into:
1. Numeric
2. Addition operator
3. Subtraction operator
4. Multiplication operator
5. Division operator

And assign rank for them:

Numeric > Multiplication operator == Division operator > Addition operator == Subtraction operator

Suppose:
* S is an arithmetic expression which consists of **Numeric**, **Addition Operator**, **Subtraction operator**, **Multiplication operator** and **Division operator**
* E is an ordered list, in which each element is one of **Numeric**, **Addition Operator**, **Subtraction operator**, **Multiplication operator** or **Division operator**
* T is a binary tree, in which each node is one of **Numeric**, **Addition Operator**, **Subtraction operator**, **Multiplication operator** or **Division operator**

**Step:**
1. Take first e as the T, point `lastNode` to e
2. For remaining e:
    a. append e as child of `lastNode`
    b. raise e until encounter parent is less than e
    c. point `lastNode` to e

**Raise Algorithm**
Given node e, 
* D is e's left child
* B is e's parent
* B has left child C
* e is B's right child
* A is B's parent

```dot
digraph d{
    A -> F
    A -> B
    B -> C
    B -> e
    e -> D
}
```
After raised, 
* D should be B's right child
* e should be B's parent
* e take B's position of A, if B is left child of A then e be left child of A, if B is right child of A then e be right child of A
```dot
digraph d {
    A -> F
    A -> B
    B -> C
    B -> e
    e -> D

    D -> e [style=dotted]
    e -> B [style=dotted]
    B -> D [style=dotted]
}
```
```dot
digraph d {
    A -> F
    A -> e
    e -> B
    B -> C
    B -> D
}
```

For example, input S `1 + 2 * 3 - 4 / 5`. Tokenize it as 
```dot
graph g {
    tokens [shape=record, label="1|+|2|*|3|-|4|/|5"]
}
```
**Case 1:** T is empty, insert e as root of T.
double circle notates `lastNode`
grey circle notates e
```dot
digraph d {
    1 [shape=doublecircle,style=filled,color=grey]

}
```
**Case 2:** raise e to root of T.
```dot
digraph d {
    1 [shape=doublecircle]
    addition [label="+",style=filled,color=grey]

    1 -> addition

}
```
e(+)'s parent (1) is not less than e, then raise e
```dot
digraph d{
    1 [shape=doublecircle]
    addition [label="+",style=filled,color=grey]

    addition -> 1

}
```
Point `lastNode` to e
```dot
digraph d{
    1
    addition [shape=doublecircle,label="+",style=filled,color=grey]

    addition -> 1

}
```
**Case 3:** raise e until encounter parent is less than e.
```dot
digraph d {
    addition [label="+"];
    1
    2 [shape=doublecircle]
    multiplication [label="*",style=filled,color=grey]

    addition -> 1
    addition -> 2
    2 -> multiplication
}
```
Raise e(`*`) until encounter parent is less than e(`*`)
```dot
digraph d {
    addition [label="+"];
    1
    2 
    multiplication [shape=doublecircle,label="*",style=filled,color=grey]

    addition -> 1
    addition -> multiplication
    multiplication -> 2
}
``` 
**Case 4:** encounter parent which is less than e, without any raise operation.
```dot
digraph d{
    addition [label="+"];
    1
    2 
    multiplication [label="*"]
    3 [shape=doublecircle,style=filled,color=grey]

    addition -> 1
    addition -> multiplication
    multiplication -> 2
    multiplication -> 3
}
```
**Case 5:** raise more than once.
```dot
digraph d{
    addition [label="+"];
    1
    2 
    multiplication [label="*"]
    3 [shape=doublecircle]
    subtraction [label="-",style=filled,color=grey]

    addition -> 1
    addition -> multiplication
    multiplication -> 2
    multiplication -> 3
    3 -> subtraction
}
```
`3` is not less than e(`-`), raise e
```dot
digraph d{
    addition [label="+"];
    1
    2 
    multiplication [label="*"]
    3 [shape=doublecircle]
    subtraction [label="-",style=filled,color=grey]

    addition -> 1
    addition -> multiplication
    multiplication -> 2
    multiplication -> subtraction
    subtraction -> 3
}
```
`*` is not less than e(`-`), raise e again
```dot
digraph d{
    addition [label="+"];
    1
    2 
    multiplication [label="*"]
    3 [shape=doublecircle]
    subtraction [label="-",style=filled,color=grey]

    addition -> 1
    addition -> subtraction
    multiplication -> 2
    multiplication -> 3
    subtraction -> multiplication
}
```
`+` is not less than e(`-`), raise e again
```dot
digraph d{
    addition [label="+"];
    1
    2 
    multiplication [label="*"]
    3 [shape=doublecircle]
    subtraction [label="-",style=filled,color=grey]

    addition -> 1
    addition -> multiplication
    multiplication -> 2
    multiplication -> 3
    subtraction -> addition
}
```
Point `lastNode` to e(`-`)
```dot
digraph d{
    addition [label="+"];
    1
    2 
    multiplication [label="*"]
    3 
    subtraction [shape=doublecircle,label="-",style=filled,color=grey]

    addition -> 1
    addition -> multiplication
    multiplication -> 2
    multiplication -> 3
    subtraction -> addition
}
```

## Reference
1. [Order of Operations](https://en.wikipedia.org/wiki/Order_of_operations) 