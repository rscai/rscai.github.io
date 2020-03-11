---
author: Ray Cai
date: August 18th, 2019
---
# 一個小時學會Python

## What?

Python是一門高級、通用用途、多范式、動態類型、解釋型程序設計語言。

## Hello World

```python
def sayHello:
    print("Hello World!")

if __name__ == "__main__":
    sayHello()
```

用Python解釋器執行：

```bash
python helloworld.py
```

## Dynamical typing

TBD

## 多范式

Python支持多種編程范式，包括：

* Procedural 過程式
* Object-Oriented 面向對象
* Functional 函數式

### Procedural

過程式編程的核心概念是：數據結構和過程。Python中，數據結構由類實現，過程由函數實現。

#### 使用Class定義結構

使用Class定義雙向鏈表的節點：

```python
>>> class Node:
...     def __init__(self):
...         self.value = None
...         self.previous = None
...         self.next = None
... 
```

使用Class的構造器創建Node實例，並讀寫成員字段：

```python
>>> head = Node()
>>> head.value=0
>>> second = Node()
>>> second.value=1
>>> head.next = second
>>> second.previous = head
>>> head.value
0
>>> head.next.value
1
```

#### 使用函數實現過程

使用def定義一個Fibonacci函數：

```python
>>> def fibo(n):
...     if n == 0:
...         return 1
...     if n == 1:
...         return 1
...     return fibo(n-1) + fibo(n-2)
... 
```

調用函數：

```python
>>> fibo(10)
89
```

### Object-Oriented

Objecte Oriented 的核心元素是Class和Object。Object Oriented的四大特性是：

* Encapsulation 封裝
* Inheritence 繼承
* Abstraction 抽象
* Polymorphysm 多態

#### Class和Object

##### 聲明Class

Class聲明主要包括：

* 類名
* 基類
* 字段field
* 方法method
* 構造器

```python
class ClassName(BaseClassName):
    def __init__(self):
        self.name = "default"
    def otherMethod(self, parameters):
        # do something
```

Class使用關鍵字`class`聲明。
基類可選，默認為`object`。
構造器固定名字為`__init__`。
字段在構造器中顯示聲明。
方法的第一個參數必需是self - object自身。

##### 創建Object

使用構造器方法創建對象：

```python
aObject = ClassName()
```

##### Encapsulation 封裝

###### Public Access
TBD

###### Protected Access
TBD

###### Private Access

TBD

```python
class Person:
    def __init__(self, name):
        self.__name = name
    def sayHello(self):
        print("Hello "+self.__name)
    def rename(self, newName):
        self.__name = newName
```

```python
>>> a = Person("Bob")
>>> a.__name
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
AttributeError: 'Person' object has no attribute '__name'
>>> a.sayHello()
Hello Bob
>>> a.rename("Mike")
>>> a.sayHello()
Hello Mike
```

##### Inheritence 繼承

單繼承

多繼承

TBD

##### Abstraction 抽象

Interface 

TBD

##### Polymorphysm 多態

Overload
Override

### Functional 

#### Function as First-Class

TBD

#### Immutable Collection

TBD

## 內建類和函數

Python內建了List、Tuple、Set和Dictionary四個常用數據類型。

#### List

List是一個有序的、可變的集合。使用List可以實現Stack。

##### 創建空List

```python
>>> a = []
>>> a
[]
>>> 
```

##### 創建帶元素的List

```python
>>> a = [1,2,3]
>>> a
[1, 2, 3]
>>> 
```

##### 往List添加元素

```python
>>> a = [1,2,3]
>>> a
[1, 2, 3]
>>> a.append(4)
>>> a
[1, 2, 3, 4]
>>> 
```

##### 往List指定位置插入元素

```python
>>> a = [1,2,3]
>>> a
[1, 2, 3]
>>> a.insert(1,10)
>>> a
[1, 10, 2, 3]
>>> 
```

##### 從list中移除元素

```python
>>> a = [1,2,3]
>>> a
[1, 2, 3]
>>> a.remove(2)
>>> a
[1, 3]
>>> 
```

##### 從List中移除指定位置上的元素

```python
>>> a = [1,2,3]
>>> a
[1, 2, 3]
>>> del a[1]
>>> a
[1, 3]
>>> 
```

##### 获取List中指定位置的元素

```python
>>> a = [1,2,3]
>>> a
[1, 2, 3]
>>> a[1]
2
>>> 
```

##### 获取List的子串

```python
>>> a = [1,2,3,4]
>>> a
[1, 2, 3, 4]
>>> a[1:3]
[2, 3]
>>> 
```

##### 壓棧

```python
>>> a = [1,2,3]
>>> a
[1, 2, 3]
>>> a.append(4)
>>> a
[1, 2, 3, 4]
>>>
```

##### 出棧

```python
>>> a = [1,2,3,4]
>>> a
[1, 2, 3, 4]
>>> a.pop()
4
>>> 
```

#### Tuple

Tuple是不可變的List。

##### 創建空Tuple

```python
>>> a = ()
>>> a
()
>>> 
```

##### 創建有值的Tuple

```python
>>> a = (1,2,3)
>>> a
(1, 2, 3)
>>> 
```

##### 通過下標訪問Tuple內元素

```python
>>> a = (1,2,3)
>>> a
(1, 2, 3)
>>> a[1]
2
>>> 
```

##### 自動解包Tuple

```python
>>> a = (1,2,3)
>>> a
(1, 2, 3)
>>> one, two, three = a
>>> one
1
>>> two
2
>>> three
3
>>> 
```

#### Set

Set是無序的、不包含重復元素的集合。

##### 創建空Set

```python
>>> s = {}
>>> s
{}
>>> 
```

##### 創建包含元素的Set

```python
>>> s = {1,2,3}
>>> s
{1, 2, 3}
```

##### 往Set中添加元素

```python
>>> s = {1,2,3}
>>> s
{1, 2, 3}
>>> s.add(4)
>>> s
{1, 2, 3, 4}
```

##### 從Set中移除元素

```python
>>> s = {1,2,3}
>>> s
{1, 2, 3}
>>> s.remove(2)
>>> s
{1, 3}
```


#### Dictionary

