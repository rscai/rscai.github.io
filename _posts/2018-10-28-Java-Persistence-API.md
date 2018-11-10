---
title: Java Persistence API
date: Oct 28, 2018
author: Ray Cai
tags: java jpa orm
---
# Java Persistence API

* TOC
{:toc}

## Overview

The techincal objective of JPA is to provide an object/relational mapping facility for the Java application developer using a Java domain model to manage a relational database.

## Entity

> An entity is a lightweight persistent domain object.
>
>The primary programming artifact is the entity class. An entity class may make use of auxiliary classes that serve as helper classes or that are used to represent the state of the entity.[5]

JPA is designed to map Object-Oriented model to Relational model, **NOT** map Relational model to Object-Oriented model.

>The entity class must be annotated with the `Entity` annotation or denoted in the XML descriptor  as an entity.[5]

The `Entity` to `Relation` mapping could be denoted by XML or Java annotation. Considering of readablity, maintainability and static validation, it recommends describing mapping by Java annotation.

> The entity  class must have a no-arg constructor. The entity class may have other constructors as well. The no-arg constructor msut be public or protected.[5]
>
>The persistent state of an entity is accessed by the persistence provider runtime either via JavaBeans style property accessors ("property access") or via instance variables ("field access"). [5]
>
>Terminology Note: The persistent fields and properties of an entity class are generically referred to in this document as the "attributes" of the class.[5]

[JavaBeans style property accessors](https://docs.oracle.com/javase/tutorial/javabeans/writing/properties.html)

### Single entity to one table

The simplest entity/table mapping is single entity to one table mapping. All attributes of entity are mapped to columns of one table.

```puml
@startuml
class Account <<Entity>> {
    -id: String
    -firstName: String
    -lastName: String
}
@enduml
```

```puml
@startuml
class ACCOUNT << (T,ORCHID) >> {
    ID VARCHAR2(100) NOT NULL
    FIRST_NAME VARCHAR2(100) NOT NULL
    LAST_NAME VARCHAR2(100) NOT NULL
}
@enduml
```

```java
@Entity
@Table(name="ACCOUNT")
public class Account {
    @Id
    @Column(name="ID", length=100)
    private String id;
    @Column(name="FIRST_NAME", length=100)
    private String firstName;
    @Column(name="LAST_NAME", length=100)
    private String lastNane;
}
```

### Single entity to primary and secondary tables

More complex case is that mapping all attributes of entity to columns of more than one.
Considered of database IO tuning, it sometimes split a long table into multiple short tables. For example, entity `Account` has five fields, three of them (`id`, `firstName` and `lastName`) are always not empty, another two fields are nullable. If map all of them to one table, it will get a sparse table. Database IO operation will get more inefficient on sparse table. Therefore, it usually is splitted into two tables in practice.

```puml
@startuml
class Account <<Entity>> {
    -id: String
    -firstName: String
    -lastName: String
    -telphone: String
    -address: String
}
@enduml
```

```puml
@startuml
class ACCOUNT << (T,orchid) >> {
    ID VARCHAR2(100) NOT NULL
    FIRST_NAME VARCHAR2(100) NOT NULL
    LAST_NAME: VARCHAR2(100) NOT NULL
}
class ACCOUNT_CONTACT << (T,orchid) >> {
    ID VARCHAR2(100) NOT NULL
    TELPHONE VARCHAR2(20)
    ADDRESS VARCHAR2(1000)
}

ACCOUNT "1" -- "0..1" ACCOUNT_CONTACT
@enduml
```

```java
@Entity
@Table(name="ACCOUNT")
@SecondaryTable(name="ACCOUNT_CONTACT")
public class Account {
    @Id
    @Column(name="ID", length=100)
    private String id;
    @Column(name="FIRST_NAME", length=100)
    private String firstName;
    @Column(name="LAST_NAME", length=100)
    private String lastName;
    @Column(name="TELPHONE", length=20, table="ACCOUNT_CONTACT")
    private String telphone;
    @Column(name="ADDRESS", length=1000, table="ACCOUNT_CONTACT")
    private String address;
}
```

#### Composition

Composition is a common classes relationship. For example, `Account` composites `Contact`. `Contact` is a part of `Account`, when `Account` destroyed, `Contact` has to be destroyed together.

```puml
@startuml
class Contact {
    -label: String
    -telphone: String
    -address: String
}
class Account <<Entity>> {
    -id: String
    -firstName: String
    -lastName: String
    -contacts: List<Contact>
}
Account *- Contact
@enduml
```

```puml
@startuml
class ACCOUNT << (T,orchid) >> {
    ID VARCHAR2(100) NOT NULL
    FIRST_NAME VARCHAR2(100) NOT NULL
    LAST_NAME: VARCHAR2(100) NOT NULL
}
class ACCOUNT_CONTACT << (T,orchid) >> {
    ID VARCHAR2(100) NOT NULL
    LABEL VARCHAR2(50) NOT NULL
    TELPHONE VARCHAR2(20)
    ADDRESS VARCHAR2(1000)
}

ACCOUNT "1" -- "0..*" ACCOUNT_CONTACT
@enduml
```

```java
@Embeddable
public class Contact {
    @Column(name="LABEL",length=50)
    private String label;
    @Column(name="TELPHONE",length=20)
    private String telphone;
    @Column(name="ADDRESS",length=1000)
    private String address;
}

@Entity
@Table(name="ACCOUNT")
public class Account {
    @Id
    @Column(name="ID",length=100)
    private String id;
    @Column(name="FIRST_NAME",length=100)
    private String firstName;
    @Column(name="LAST_NAME",length=100)
    private String lastName;
    @ElementCollection
    @CollectionTable(
        name="CONTACT",
        joinColumns=@JoinColumn(name="ID")
    )
    private List<Contact> contacts;
}
```

#### Aggregation

Unlike composition relationship, entities of aggregation are independent. For example, `Category` and `Product` are one-to-many relationship, but both of them are independent. When destroyed `Category`, it needn't destroy related `Product` together. Correspondingly, when destroyed `Product`, needn't destroy related `Category` together.

##### Unidirectional OneToMany

```puml
@startuml
class Category <<Entity>> {
    -id: String
    -name: String
    -products: List<Product>
}
class Product <<Entity>> {
    -id: String
    -subject: String
}
Category o- "products" Product
@enduml
```

```puml
@startuml
class CATEGORY << (T,orchid) >> {
    ID VARCHAR2(100) NOT NULL
    NAME VARCHAR2(100) NOT NULL
}
class PRODUCT << (T,orchid) >> {
    ID VARCHAR2(100) NOT NULL
    SUBJECT VARCHAR2(200) NOT NULL
    CATEGORY_ID VARCHAR2(100) NOT NULL
}
CATEGORY "1" -- "0..*" PRODUCT
@enduml
```

```java
@Entity
@Table(name="PRODUCT")
public class Product {
    @Id
    @Column(name="ID", length=100)
    private String id;
    @Column(name="SUBJECT", length=200)
    private String subject;
}

@Entity
@Table(name="CATEGORY")
public class Category {
    @Id
    @Column(name="ID", length=100)
    private String id;
    @Column(name="NAME", length=100)
    private String name;
    @OneToMany
    @JoinColumn(
        name="CATEGORY_ID",
        referencedColumnName="ID"
        )
    private List<Product> products;
}
```

> JPA 1.0 does not support a unidirectional OneToMany relationship without a JoinTable. Since JPA 2.0 there is a support for unidirectional OneToMany. In JPA 2.x a @JoinColumn can be used on a OneToMany to define the foreign key, some JPA providers may support this already.

##### ManyToOne

```puml
@startuml
class Category <<Entity>> {
    -id: String
    -name: String
}
class Product <<Entity>> {
    -id: String
    -subject: String
    -category: Category
}
Category "category" -o Product
@enduml
```

```java
@Entity
@Table(name="PRODUCT")
public class Product {
    @Id
    @Column(name="ID", length=100)
    private String id;
    @Column(name="SUBJECT", length=200)
    private String subject;
    @ManyToOne
    @JoinColumn(name="CATEGORY_ID")
    private Category category
}

@Entity
@Table(name="CATEGORY")
public class Category {
    @Id
    @Column(name="ID", length=100)
    private String id;
    @Column(name="NAME", length=100)
    private String name;
}
```

##### Bidirectional OneToMany

```puml
@startuml
class Category <<Entity>> {
    -id: String
    -name: String
    -products: List<Product>
}
class Product <<Entity>> {
    -id: String
    -subject: String
    -category: Category
}
Category "category" o- "products" Product
@enduml
```

```java
@Entity
@Table(name="PRODUCT")
public class Product {
    @Id
    @Column(name="ID", length=100)
    private String id;
    @Column(name="SUBJECT", length=200)
    private String subject;
    @ManyToOne
    @JoinColumn(name="CATEGORY_ID")
    private Category category
}

@Entity
@Table(name="CATEGORY")
public class Category {
    @Id
    @Column(name="ID", length=100)
    private String id;
    @Column(name="NAME", length=100)
    private String name;
    @OneToMany(mappedBy="category")
    private List<Product> products;
}
```

#### Association

```puml
@startuml
class Collection <<Entity>> {
    -id: String
    -name: String
}
class Product <<Entity>> {
    -id: String
    -subject: String
}
Collection - "products" Product
@enduml
```

```puml
@startuml
class COLLECTION << (T,orchid) >> {
    ID VARCHAR2(100) NOT NUL
    NAME VARCHAR2(100) NOT NULL
}
class PRODUCT << (T,orchid) >> {
    ID VARCHAR2(100) NOT NULL
    SUBJECT VARCHAR2(200) NOT NULL
}
class COLLECTION_PRODUCT_REL << (T,orchid) >> {
    COLLECTION_ID VARCHAR2(100) NOT NULL
    PRODUCT_ID VARCHAR2(100) NOT NULL
}
COLLECTION "1" -- "*" COLLECTION_PRODUCT_REL
COLLECTION_PRODUCT_REL "*" -- "1" PRODUCT
@enduml
```

```java
@Entity
@Table(name="PRODUCT")
public class Product {
    @Id
    @Column(name="ID", length=100)
    private String id;
    @Column(name="SUBJECT", length=200)
    private String subject;
}
@Entity
@Table(name="COLLECTION")
public class Collection {
    @Id
    @Column(name="ID")
    private String id;
    @Column(name="NAME")
    private String name;
    @ManyToMany
    @JoinTable(
        name="COLLECTION_PRODUCT_REL",
        joinColumns=@JoinColumn(name="COLLECTION_ID", referencedColumnName="ID"),
        inverseJoinColumns=@JoinColumn(name="PRODUCT_ID", referencedColumnName="ID")
    )
    private List<Product> products;
}
```

>Although a ManyToMany relationship is always bi-directional on the database, the object model can choose if it will be mapped in both directions, and in which direction it will be mapped in. If you choose to map the relationship in both directions, then one direction must be defined as the owner and the other must use the mappedBy attribute to define its mapping. This also avoids having to duplicate the JoinTable information in both places.
>
>If the mappedBy is not used, then the persistence provider will assume there are two independent relationships, and you will end up getting duplicate rows inserted into the join table. If you have a conceptual bi-directional relationship, but have two different join tables in the database, then you must not use the mappedBy, as you need to maintain two independent tables.
>
>As with all bi-directional relationships it is your object model's and application's responsibility to maintain the relationship in both direction. There is no magic in JPA, if you add or remove to one side of the collection, you must also add or remove from the other side, see object corruption. Technically the database will be updated correctly if you only add/remove from the owning side of the relationship, but then your object model will be out of synch, which can cause issues.[1]

#### Inheritance

```puml
@startuml
enum DeliveryStatus {
    INIT
    ON_DELIVER
    RECEIVED_AND_SIGNED
    REJECTED
    ON_RETURN
}
abstract class Delivery <<Entity>> {
    #id: String
    #status: DeliveryStatus
}
class CustomDelivery <<Entity>> {
}
class EmailDelivery <<Entity>> {
    -email: String
}
class ExpressDelivery <<Entity>> {
    -vendor: String
    -trackId: String
    -recipient: Contact
}

Delivery <|-- CustomDelivery
Delivery <|-- EmailDelivery
Delivery <|-- ExpressDelivery
@enduml
```

There are three basic strategies that are used when mapping a class or class hierarchy to a relational database:

* single table per class hierarchy
* joined subclass strategy
* table per concrete entity class

##### Single Table per Class Hierarchy Strategy

In this strategy, all the classes in a hierarchy are mapped to a single table. The table has a column that servers as a "discriminator column", that is, a column whose value identifies the specific subclass to which the instance taht is represented by the row belongs.
This mapping strategy provides good support for polymorphic relationships between entities and for queries that range over the class hierarchy.
It has the drawback, however, that it requires that the columns that correspond to state specific to the subclasses be nullable.

```puml
@startuml
class DELIVERY << (T, chid) >> {
    ID VARCHAR2(100) NOT NULL
    STATUS VARCHAR2(50) NOT NULL
    DELIVERY_TYPE VARCHAR2(20) NOT NULL
    EMAIL VARCHAR2(100)
    VENDOR VARCHAR2(100)
    TRACK_ID VARCHAR2(50)
    CONTACT_ID VARCHAR2(100)
}
class CONTACT << (T, chid) >> {
    ID VARCHAR2(100) NOT NULL
    TELPHONE VARCHAR2(20) NOT NULL
    ADDRESS VARCHAR2(1000) NOT NULL
}
DELIVERY "1" - "0..1" CONTACT
@enduml
```

```java
@Entity
@Inheritance
@DiscriminatorColumn(name="DELIVERY_TYPE")
@Table(name="DELIVERY")
public abstract class Delivery {
    @Id
    @Column(name="ID", length=100)
    protected String id;
    @Column(name="STATUS", length=50)
    protected DeliveryStatus status;
}

@Entity
@DiscriminatorValue("CUSTOM")
public class CustomDelivery extends Delivery {

}

@Entity
@DiscriminatorValue("EMAIL")
public class EmailDelivery extends Delivery {
    @Column(name="EMAIL", length=100)
    private String email;
}

@Entity
@DiscriminatorValue("EXPRESS")
public class ExpressDelivery extends Delivery {
    @Column(name="VENDOR", length=100)
    private String vendor;
    @Column(name="TRACK_ID", length=50)
    private String trackId;
    @OneToOne
    @JoinColumn(name="CONTACT_ID")
    private Contact contact;
}
```

##### Joined Subclass Strategy

In the joined subclass strategy, the root of the class hierarchy is represented by a single table. Each subclass is represented by a separate table that contains those fields that are specific to the subclass (not inherited from its superclass), as well as the column(s) that represent its primary key. The primary key column(s) of the subclass table serves as a foreign key to the primary key of the superclass table.
This strategy provides support for polymorphic relationships between entities.
It has the drawback that it requires that one or more join operations be performed to instantiate instances of a subclass. In deep class hierarchies, this may lead to unacceptable performance. Queries that range over the class hierarchy likewise require joins.

```puml
@startuml
class DELIVERY << (T, chid) >> {
    ID VARCHAR2(100) NOT NULL
    STATUS VARCHAR2(50) NOT NULL
    DELIVERY_TYPE VARCHAR2(20) NOT NULL
}
class CUSTOM_DELIVERY << (T, chid) >> {
    ID VARCHAR2(100) NOT NULL
}
class EMAIL_DELIVERY << (T, chid) >> {
    ID VARCHAR2(100) NOT NULL
    EMAIL VARCHAR2(100) NOT NULL
}
class EXPRESS_DELIVERY << (T, chid) >> {
    ID VARCHAR2(100) NOT NULL
    VENDOR VARCHAR2(100) NOT NULL
    TRACK_ID VARCHAR2(50) NOT NULL
    CONTACT_ID VARCHAR2(100) NOT NULL
}
DELIVERY "1" -- "0..1" CUSTOM_DELIVERY
DELIVERY "1" -- "0..1" EMAIL_DELIVERY
DELIVERY "1" -- "0..1" EXPRESS_DELIVERY
@enduml
```

```java
@Entity
@Inheritance(strategy=InheritanceType.JOINED)
@DiscriminatorColumn(name="DELIVERY_TYPE")
@Table(name="DELIVERY")
public abstract class Delivery {
    @Id
    @Column(name="ID", length=100)
    protected String id;
    @Column(name="STATUS", length=50)
    protected DeliveryStatus status;
}

@Entity
@DiscriminatorValue("CUSTOM")
@Table(name="CUSTOM_DELIVERY")
public class CustomDelivery extends Delivery {

}

@Entity
@DiscriminatorValue("EMAIL")
@Table(name="EMAIL_DELIVERY")
public class EmailDelivery extends Delivery {
    @Column(name="EMAIL", length=100)
    private String email;
}

@Entity
@DiscriminatorValue("EXPRESS")
@Table(name="EXPRESS_DELIVERY")
public class ExpressDelivery extends Delivery {
    @Column(name="VENDOR", length=100)
    private String vendor;
    @Column(name="TRACK_ID", length=50)
    private String trackId;
    @OneToOne
    @JoinColumn(name="CONTACT_ID")
    private Contact contact;
}
```

##### Table per concrete Class Strategy

In this mapping strategy, each class is mapped to a separate table. All properties of the class, including inherited properties, are mapped to columns of the table for the class.
This trategy has the following drawbacks:

* It provides poor support for polymorphic relationships.
* It typically requires that SQL UNION queries (or a separate SQL query per subclass) be issued for queries that are intended to range over the class hierarchy.

```puml
@startuml
class CUSTOM_DELIVERY << (T, chid) >> {
    ID VARCHAR2(100) NOT NULL
    STATUS VARCHAR2(50) NOT NULL
}
class EMAIL_DELIVERY << (T, chid) >> {
    ID VARCHAR2(100) NOT NULL
    STATUS VARCHAR2(50) NOT NULL
    EMAIL VARCHAR2(100) NOT NULL
}
class EXPRESS_DELIVERY << (T, chid) >> {
    ID VARCHAR2(100) NOT NULL
    STATUS VARCHAR2(50) NOT NULL
    VENDOR VARCHAR2(100) NOT NULL
    TRACK_ID VARCHAR2(50) NOT NULL
    CONTACT_ID VARCHAR2(100) NOT NULL
}
@enduml
```

```java
@Entity
@Inheritance(strategy=InheritanceType.TABLE_PER_CLASS)
public abstract class Delivery {
    @Id
    @Column(name="ID", length=100)
    protected String id;
    @Column(name="STATUS", length=50)
    protected DeliveryStatus status;
}

@Entity
@Table(name="CUSTOM_DELIVERY")
public class CustomDelivery extends Delivery {

}

@Entity
@Table(name="EMAIL_DELIVERY")
public class EmailDelivery extends Delivery {
    @Column(name="EMAIL", length=100)
    private String email;
}

@Entity
@Table(name="EXPRESS_DELIVERY")
public class ExpressDelivery extends Delivery {
    @Column(name="VENDOR", length=100)
    private String vendor;
    @Column(name="TRACK_ID", length=50)
    private String trackId;
    @OneToOne
    @JoinColumn(name="CONTACT_ID")
    private Contact contact;
}
```

## Entity Operation

### EntityManager

>An EntityManager instance is associated with a persistence context. A persistence context is a set of entity instances in which for any persistent entity identity there is a unique entity instance. Within the persistence context, the entity instances and their lifecycle are managed. The `EntityManager` interface defines the methods that are used to interact with the persistence context. The `EntityManager` API is used to create and remove persistent entity instances, to find persistent entities by primary key, and to query over persistent entities.[5]
>
>The set of entities that cna be managed by a given `EntityManager` instance is defined by a persistence unit. A persistence unit defines the set of all classes that are related or grouped by the application, and which must be colocated in their mapping to a single database.[5]

### Entity Instance's Life Cycle

>An entity instance can be characterized as being new, managed, detached and removed.
>
>* A `new` entity instance has no persistent identity, and is not yet associcated with a persistence context.
>* A `managed` entity instance is an instance with a persistent identity that is currently associated with a persistence context.
>* A `detached` entity instance is an instance with a persistent identity that is not (or no longer) associated with a persistence context.
>* A `removed` entity instance is an instance with a persistent identity, assiciated with a persistence context, that will be removed from the database upon transaction commit.[5]

```puml
@startuml
[*]->new
new-->managed: persist
new->new: remove
new->new: detach
managed->managed: persist
managed->removed: remove
managed-->detached: detach
removed-->managed: persist
removed->removed: remove
removed-->detached: detach
detached->[*]: persist
detached->[*]: remove
@enduml
```

Entity instance starts from state `new`, it will transist to state `managed` when invoked the `persist` method on it or by cascading the persist operation.

When invoked the `remove` method on `managed` entity instance, it will transist to state `removed`. Similarly, when invoked the `detach` method on `managed` entity instance, it will transist to state `detached`.

When invoked the `persist` method on `removed` entity instance, it will transist to state `managed`. If invoked `detach` method on entity instance, it will transist to state `detached`.

`detached` is the final state of entity instance. Even it is allowed to invoke `merge` method on `detached` entity instance, but it is creating new one entityn instance than transisting `detached` to another state.

### Transaction

PersistenceContextType:

* TRANSACTION
* EXTENDED

SynchronizationType:

* SYNCHRONIZED
* UNSYNCHRONIZED

>The managed entities of a transaction-scoped persistence context become detached when the transaction commits; the managed entities of an extended persistence context remain managed.
>
>For both transaction-scoped persistence contexts and for extended persistence contexts that are joined to the current transction, transaction rollback causes all `pre-existing` managed instances and removed instances to become detached. The instances' state will be the state of the instances at the point at which the transaction was rolled back. Transaction rollback typically causes the persistence context to be in an inconsistent state at the point of rollback. In particular , the state of version attributes and generated state (e.g., generated primary keys) may be inconsistent. Instances that were formerly managed by the persistence context (including new instances that were made persistent in that transaction) may therefore not be reusable in the same manner as other detached objects -- for example, they may fail when passed to the merge operation.

### Entity Listeners and Callback Methods

Entity lifecycle events:

* `Prepersist`
* `PostPersist`
* `PreRemove`
* `PostRemove`
* `PreUpdate`
* `PostUpdate`
* `PostLoad`

>Entity lifecycle callback methods can be defined on an entity listener class and/or directly on an entity class or mapped superclass.
>
>Callback methods defined on an entity class or mapped superclass have the following signature:
>
>`void <METHOD>()`
>
>Callback methods defined on an entity listener class have the following signature:
>
>`void <METHOD>(Object)`
>
>The `Object` argument is the entity instance for which the callback method is invoked. It may be declared as the actual entity type.
>
>The callback methods can have public, private, protected, or package level access, but must not be `static` or `final`.[5]
>
>The following rules apply to lifecycle callback methods:
>
>* Lifecycle callback methods may throw unchecked/runtime exceptions. A runtime exception thrown by a callback method that executes within a transaction causes that transaction to be marked for rollback if the persistence context is joined to the transaction.
>* Lifecycle callbacks can invoke JNDI, JDBC, JMS, and enterprise beans.
>* In general, the lifecycle method of a portable application should not invoke `EntityManager` or query operations, access other entity instances, or modify relationships whithin the same persistence context. A lifecycle method may modify the non-relationship state of the entity on which it is invoked.[5]

## Query

### Query Language

>The Java Persistence query language is a string-based query language used to define queries over entities and their persistent state. It enbales the application developer to specify the semantics of queries in a portable way, independent of the particular database schema in use in an enterprise environment. The full range of the langauge may be used in both static and dynamic queries.
>
>The query language uses the absdtract persistence schema of entities, including their embedded objects and relationships, for its data model, and it defines operators and expressions based on this data model. It uses a SQL-like syntax to select objects or values based on abstract schema types and relationships. It is possible to parse and validate queries before entities are deployed.[5]

In BNF syntax, a query language statement is defined as:
`QL_statement ::= select_statement|update_statement|delete_statement`

a select statement is a string which contains of the following clauses:

* SELECT, required. Which determines the type of the objects or values to be selected.
* FROM, required. Which declares what domains the query apply on.
* WHERE, optional. Which declares the restrict on the results that retured by the query.
* GROUP BY, optional. Which allows query results to be aggregated in terms of groups.
* HAVING, optional. Which allows filtering over aggregated groups.
* OVER BY, optional. Which declares the order of the returns that returned by the query.

>In BNF syntax, a select statement is defined as:
>`select_statement ::= select_clause from_clause [where_clause] [group_clause] [having_clause] [orderby_clause]`[5]

In BNF syntax, a update statement is defined as:
`update_statement ::= update_clause [where_clasue]`

In BNF syntax, a delete statement is defined as:
`delete_statement ::= delete_clause [where_clause]`

### Criteria API

>The Java Persistence Criteria API, like the Java Persistence query language is based on the abstract persistence schema of entities, their embedded objects, and their relationships as its data model. This abstract persistence schema is materialized in the form of metamodel objects over which the Criteria API operates. The semantics of criteria queries are designed to reflect those of Jave Persistence query language queries.
>
>The syntax of the Criteria API is designed to allow the construction of an object-based query "graph", whose nodes correspond to the semantic query elements.[5]

## Caching

>This specification supports the use of the second-level cache by the persistence provider. The second-level cache, if used, underlies the persistence context, and is largely transparent to the application.
>
>A second-level cache is typically used to enhance performance. Use of a cache, however, may have consequences in terms of the up-to-dateness of data seen by the application, resulting in "stale reads". A stale read is defined as the reading of entities or entity state that is older than the point at which the persistence context was started.

JPA's caching behavior could be configured y options `shared-cache-mode`, `CacheRetriveMode` and `CacheStoreMode`.

`shared-cache-mode` options:

* ALL
* NONE
* ENABLE_SELECTIVE
* DISABLE_SELECTIVE
* UNSPECIFIED

`CacheRetriveMode` options:

* USE
* BYPASS

`CacheStoreMode` options:

* USE
* BYPASS
* REFRESH

## Appendix

### Normal Forms

>Codd introduced the concept of normalization and what is now known as the first normal form (1NF) in 1970. Codd went on to define the second normal form (2NF) and third normal form (3NF) in 1971, and Codd and Raymond F. Boyce defined the Boyce-Codd normal form (BCNF) in 1974.
>
>Informally, a relational database relation is often described as "normalized" if it meets third normal form.[7] Most 3NF relations are free of insertion, update, and deletion anomalies.
>
>The normal forms (from least normalized to most normalized) are:
>
> * UNF: Unnormalized form
> * 1NF: First normal form
> * 2NF: Second normal form
> * 3NF: Third normal form
> * EKNF: Elementary key normal form
> * BCNF: Boyce-Codd normal form
> * 4NF: Fourth normal form
> * ETNF: Essential tuple normal form
> * 5NF: Fifth normal form
> * DKNF: Domain-key normal form
> * 6NF: Sixth normal form[2]

#### First Normal Form (1NF)

>If normalization as described above is to be applicable, the unnormalized collection of relations must satisfy the following conditions:
>
>(1) The graph of interrelationships of the nonsimple domains is a collection of trees.
>(2) No primary key has a component domain which is nonsimple.[2]

#### Second Normal Form (2NF)

>Specifically: a relation is in 2NF if it is in 1NF and no non-prime attribute is dependent on any proper subset of any candidate key of the relation. A non-prime attribute of a relation is an attribute that is not a part of any candidate key of the relation.[3]

#### Third Normal Form (3NF)

>all the attributes in a table are determined only by the candidate keys of that relation and not by any non-prime attributes.[4]

An entity class should be mapped to one ore more relational tables. Entity may has attributes, simple type attribute should be mapped to single column, but complex type attribute may be mapped to extra tables.

## Reference

1. [Java Persistence/Relationships](https://en.wikibooks.org/wiki/Java_Persistence/Relationships)
2. [A Relational Model of Data for Large Shared Data Banks, E. F. Codd, IBM Research Laboratory, San Jose, California](https://www.seas.upenn.edu/~zives/03f/cis550/codd.pdf)
3. [Second normal form](https://en.wikipedia.org/wiki/Second_normal_form)
4. [Third normal form](https://en.wikipedia.org/wiki/Third_normal_form)
5. [JSR 338: Java(TM) Persistence API, Version 2.1](https://jcp.org/aboutJava/communityprocess/final/jsr338/index.html)