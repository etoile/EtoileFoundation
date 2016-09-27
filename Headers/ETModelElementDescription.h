/**
    Copyright (C) 2009 Eric Wasylishen

    Date:  July 2009
    License:  Modified BSD (see COPYING)
 */

#import <Foundation/Foundation.h>

@class ETEntityDescription, ETUTI;

/** @group Metamodel
@abstract Abstract base class used by Model Description core classes.

The Model Description classes implement a Metamodel framework inspired by 
[FAME](http://scg.unibe.ch/wiki/projects/fame).

Within this Metamodel, ETModelElementDescription provide basic abilities:

<list>
<item>Unique Naming per element in a ETModelDescriptionRepository, see -fullName</item>
<item>Ownership per element in a ETPackageDescription, see -owner</item>
<item>Constraint Checking, see -checkConstraints:</item>
<item>Freezing to prevent changes to a Metamodel (useful to support immutable 
versioned metamodels, e.g. a Persistency Schema), see -makeFrozen</item>
</list>

ETEntityDescription, ETPropertyDescription and ETPackageDescription all inherit 
from ETModelElementDescription. A model element description can be registered 
inside a model description repository using -[ETModelDescriptionRepository addDescription:].

@section Conceptual Model

This metamodel is based on the [FM3 specification](http://scg.unibe.ch/wiki/projects/fame/fm3).

For a good introduction, read the paper [FAME — A Polyglot Library
for Metamodeling at Runtime](http://www.iam.unibe.ch/~akuhn/d/Kuhn-2008-MRT-Fame.pdf)

We support the entire FM3 specification with some minor adjustements, however 
the tower (model, metamodel, meta-metamodel) is not explicitly modeled in the 
API unlike in FAME.

The MSE serialization format is also unsupported. In the future, we will provide 
our own exchange format based on JSON.

@section FAME Terminology Change Summary

Those changes were made to further simplify the FAME terminology which can get 
obscure since it overlaps with the host language object model, prevent any 
conflict with existing GNUstep/Cocoa API and reuse GNUstep/Cocoa naming habits.

We list the FAME term first, then its equivalent name in EtoileFoundation:

<deflist>
<term>FM3.Element</term><desc>ETModelElementDescription</desc>
<term>FM3.Class</term><desc>ETEntityDescription</desc>
<term>FM3.Property</term><desc>ETPropertyDescription</desc>
<term>FM3.RuntimeElement</term><desc>ETAdaptiveModelObject</desc>
<term>attributes (in Class)</term><desc>propertyDescriptions (in ETEntityDescription)</desc>
<term>allAttributes (in Class)</term><desc>allPropertyDescriptions (in ETEntityDescription)</desc>
<term>superclass (in Class)</term><desc>parent (in ETEntityDescription)</desc>
<term>package (in Class)</term><desc>owner (in ETEntityDescription)</desc>
<term>class (in Property)</term><desc>owner (in ETPropertyDescription)</desc>
</deflist>

For the last two points, we can consider FM3.Property.class and 
FM3.Class.package have been merged into a single FM3.Element.owner property in 
EtoileFoundation since they were redundant.

@section Changes to FAME

In EtoileFoundation, there is a -owner property that represents either:

<list>
<item>a owning entity in ETPropertyDescription</item>
<item>an owning package in ETEntityDescription</item>
<item>no owner (-owner returns nil) in ETPackageDescription</item>
</list>

While in FAME, owner is a derived property and these various owner kinds are 
each modeled using a distinct property (class in FM3.Property and package in 
FM3.Class).

In FAME, container implies not multivalued. In EtoileFoundation, multivalued 
now controls whether a property is a container or not, and -isContainer is now 
derived.

Unlike FAME, EtoileFoundation does support overriding property descriptions. 
This is mainly useful, for read-only properties overriden as read-write in 
subclasses/subentities.

@section Additions to FAME

-isPersistent has been added to control the persistency, how the interpret the 
metamodel and its constraints for the framework providing the persistent support 
is up to this framework. For now, some CoreObject constraints are harcoded in 
the metamodel.

-isReadOnly has been added to support set-once properties.

-itemIdentifier has been added as a mean to get precise control over the UI 
generation with EtoileUI.

@section Removals to FAME/EMOF

NamedElement and NestedElement protocols don't exist explicitly.

Property description names can be in upper case (FAME was imposing lower case 
as a constraint).

@section Metamodel Constraint Summary

Metamodel constraints are checked in -checkConstraints:, while model constraints 
are validated in -[ETPropertyDescription validateValue:forKey:]. 

Note: In the future, -checkConstraints: should probably be delegated to 
-[ETPropertyDescription validateValue:forKey:] in the meta-metamodel

If we sum up the changes to the FAME conceptual model, for the new 
ETPropertyDescription, the metamodel constraints are:

<list>
<item>composite is derived from opposite.container</item>
<item>derived and not multivalued implies container</item>
<item>derived implies not persistent</item>
<item>if set, opposite.opposite must be self (i.e. opposite properties must 
refer to each other)</item>
<item>if set, opposite.owner must be type</item>
<item>owner must not be nil</item>
<item>type must not be nil</item>
</list>

At the model level, the semantics are:

<list>
<item>container property chains may not include cycles</item>
<item>opposite properties must refer to each other</item>
<item>any multivalued property defaults to empty</item>
<item>boolean properties default to false</item>
<item>non primitive properties default to nil</item>
<item>string and number properties do not have a default value (could be changed 
later)</item>
</list>

Note: The two first points are model constraints, but 
-[ETPropertyDescription validateValue:forKey:] doesn't check them.

Since the metamodel is the model of the meta-metamodel, the model semantics 
apply to the metamodel too.

For the new ETEntityDescription, the metamodel constraints are:

<list>
<item>parent is not nil</item>
<item>parent must not be a primitive, unless self is a primitive</item>
<item>parent chain may not include cycles (could be removed, this comes from 
'container property chains may not include cycles' in the model semantics of 
ETPropertyDescription)</item>
<item>package must not be nil</item>
<item>allPropertyDescriptions is derived as union of propertyDescription and 
parent.allPropertyDescriptions</item>
<item>elements in propertyDescriptions override identically named elements from  
parent.propertyDescriptions in allPropertyDescriptions</item>
<item>allPropertyDescriptions must have unique names</item>
</list>

For the new ETPackageDescription, the metamodel constraints are:

<list>
<item>owner is not nil</item>
<item>entityDescriptions must have unique names</item>
<item>for each element in extensions, its owner is not in entityDescriptions</item>
</list> 
 
@section Discussion of Composite and Aggregate Terminology in UML

To recap the relationship types from UML:

<deflist>
<term>association</term>
<desc>a relationship between two objects with no additional constraints.</desc>
<term>aggregation</term>
<desc>a type of association, with the constraint that all of the pointers 
in an object graph belonging to aggregation relationships form a DAG (this
doesn’t preclude the relationship being many:many). Aggregation represents a
whole-part relationship, and descendent objects in this DAG can be considered
a “part of” all of their ancestors .</desc>
<term>composition</term>
<desc>a type of aggregation, with the additional constraint that an object can 
only have one composite pointer to it at a time (across all incoming 
relationships).</desc>
</deflist>

I think these definitions are complete, but for more info, see "association",
"aggregate", and "composite" in “The Unified Modeling Language Reference
Manual”. Note that aggregation and composite are just restrictions on the 
object graph, and they are orthogonal to relationship cardinality (one:one, 
one:many, many:many), although composite relationships can’t be many:many as a 
consequence of the definition of composite.

CoreObject implements a subset of the UML design with some of our own 
restrictions: If a relationship is many:many, we add no additional constraints 
(it’s a UML association). If a relationship is one:many or one:one, and 
bidirectional, we treat it as a UML aggregation. Note that CoreObject doesn’t 
support UML the composition constraint described above. Unfortunately the 
CoreObject source code uses the term “composite” a lot in ways that don’t match 
UML.

Also note that an UML aggregation relationship with a one:one/many constraint 
is similar to UML composition; the only difference is that UML composition adds 
the additional constraint that the object can have only one incoming composite 
reference across all of its relationships.

It could be worth supporting the full UML model, or supporting FAME’s model, 
because CoreObject’s current model is a bit weird in that relationship 
cardinality determines object graph constraints (association, aggregation, 
composition). For example, in CoreObject it’s impossible to model associations 
that are one:one or one:many, but are not aggregations (so you want to allow 
cycles). It’s also strange that a relationship in CoreObject can only be 
aggregation if it’s also bidirectional, this should probably be changed.
However, I'm not sure about these points; any changes need to be carefully
considered, especially with respect to COCopier.

@section Composite and Aggregate in FAME

FAME lacks the aggregation/composition distinction, it only has composition. 
Composition in FAME is almost the same as UML (no cycles in the pointers making 
up composite relationships between objects, plus every object can only have a 
single incoming composite pointer). For the second condition, FAME is slightly 
stricter in that a Class can only have a single incoming composite 
relationship, whereas UML permits multiple incoming composite relationships as 
long as only one of them is non-NULL at a time (roughly speaking, UML puts the 
constraint at runtime, FAME puts the constraint at compile time). */
@interface ETModelElementDescription : NSObject
{
    @private
    NSString *_name;
    NSString *_displayName;
    NSString *_itemIdentifier;
    BOOL _isMetaMetamodel;
    @protected
    BOOL _isFrozen;
}


/** @taskunit Metamodel Description */


/** <override-subclass />
Returns a new self-description (aka meta-metamodel). */
+ (ETEntityDescription *) newEntityDescription;


/** @taskunit Initialization */


/** Returns an autoreleased entity, property or package description.

See also -initWithName:. */
+ (id) descriptionWithName: (NSString *)name;

/** <init />
Initializes and returns an entity, property or package description.

You must only invoke this method on subclasses, otherwise nil is returned.

You should pass the property name in argument for a property description. And   
the class name for an entity description, the only exception is when the entity 
description applies to a prototype rather than a class.

Raises an NSInvalidArgumentException when the name is nil or already in use. */
- (id) initWithName: (NSString *)name;
/** Initializes and returns entity, property or package description whose name 
is <em>Untitled</em>. */
- (id) init;


/** @taskunit Querying Type */


/** Returns whether the receiver describes a property. */
@property (nonatomic, readonly) BOOL isPropertyDescription;
/** Returns whether the receiver describes an entity. */
@property (nonatomic, readonly) BOOL isEntityDescription;
/** Returns whether the receiver describes a package. */
@property (nonatomic, readonly) BOOL isPackageDescription;


/** @taskunit Basic Model Specification */


/** The name of the entity, property or package. */
@property (nonatomic, copy) NSString *name;
/** Returns the name that uniquely identify the receiver.

The name is a key path built by joining every names in the owner chain up to 
the root owner. The key path pattern is:
<code>ownerName*.receiverName</code>.<br /> 
The <em>+</em> sign indicates <em>ownerName</em> can be repeated zero or multiple times.

Given a class <em>Movie</em> and its property <em>director</em>. The full names are:

<list>
<item>Movie for the class</item>
<item>Movie.director for the property</item>
</list> */
@property (nonatomic, readonly) NSString *fullName;
/** <override-dummy />
Returns the element that owns the receiver.

For a property, the owner is the entity it belongs to.<br />
For an entity, there is no owner, unless the entity belongs to a package.<br />
For a package, there is no owner.

By default, returns nil. */
@property (nonatomic, readonly) id owner;
/** Wether the receiver describes an object that belongs to the metamodel. */
@property (nonatomic, assign) BOOL isMetaMetamodel;


/** @taskunit Model Presentation */


/**
 * A short and human-readable name e.g. Person, Music Track, Anchor Point.
 *
 * This is used to present the entity, property or package localized name to
 * the user in the UI.
 *
 * By default, returns -name that is not localized, but in a capitalized and 
 * spaced version. For an ETEntityDescription, the type prefix is removed (if 
 * +[NSObject typePrefix] returns a valid value). For example, ETMusicTrack is 
 * returned as <em>Music Track</em>.
 *
 * You can override this built-in display name by setting a custom one.
 */ 
@property (nonatomic, copy) NSString *displayName;
/** <override-subclass />
Returns a short and human-readable description of the receiver type.

It must be derived from the class name. e.g. <em>Package</em> for
ETPackageDescription.

By default, returns <em>Element</em>. */
@property (nonatomic, readonly) NSString *typeDescription;
/** The hint that precises how the receiver should be rendered e.g. at UI level.

You can use this hint to identify which object to ouput, every time a new
representation has to be generated based on the description.

ETModelDescriptionRenderer in EtoileUI uses it to look up a template item that
will represent the property at the UI level.

By default, returns nil. */
@property (nonatomic, copy) NSString *itemIdentifier;


/** @taskunit Runtime Consistency Check */


/** <override-dummy />
Checks the receiver conforms to the FM3 constraint spec and adds a short warning
to the given array for each failure.

A warning must be a NSString instance that describes the issue. Every warning
should be created with -warningWithMessage:. */
- (void) checkConstraints: (NSMutableArray *)warnings;
/** Returns an autoreleased warning built with the given explanation.

See -checkConstraints:. */
- (NSString *) warningWithMessage: (NSString *)msg;


/** @taskunit Internal */


/**
 * <override-never />
 * Throws an exception if the frozen flag is YES. This should be called in
 * ETModelElementDescription and subclasses before every mutation.
 */
- (void) checkNotFrozen;
/**
 * <override-subclass />
 * Marks the receiver as frozen. From this point, the receiver is immutable
 * and any attempt to mutate it will cause an exception to be thrown.
 */
- (void) makeFrozen;

@end
