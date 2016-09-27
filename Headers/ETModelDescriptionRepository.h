/**
    Copyright (C) 2010 Quentin Mathe

    Date:  March 2010
    License:  Modified BSD (see COPYING)
 */

#import <Foundation/Foundation.h>
#import <EtoileFoundation/ETModelElementDescription.h>
#import <EtoileFoundation/ETCollection.h>

// NOTE: NSMapTable is not available on iOS (see implementation)
@class ETModelElementDescription, ETEntityDescription, ETPackageDescription, 
    ETPropertyDescription, NSMapTable;

/** @group Metamodel
@abstract Repository used to store the entity descriptions at runtime.

Each repository manages a closed model description graph. Model element 
descriptions present in a repository must only reference objects that belong to 
the same repository.

The repository contains three type of element descriptions:

<list>
<item>ETPackageDescription</item>
<item>ETEntityDescription</item>
<item>ETPropertyDescription</item>
</list>

@section Main and Additional Repositories

A +mainRepository is created in every tool or application at launch time. In 
addition to the core metamodel (Object, String, Number etc.) present in all 
repositories, it contains the meta-metamodel right from the start.

Additional repositories can be created. For example, to store variations on the 
main repository data model. 

All repositories are mostly empty initially. You can collect entity descriptions
provided through +[NSObject newEntityDescription] in additional repositories 
with -collectEntityDescriptionsFromClass:excludedClasses:resolvedNow: or 
-registerEntityDescriptionsForClasses:resolveNow:. Both methods will automatically 
attempt to invoke +newEntityDescription on unknown property or parent types, 
and register these additional entity descriptions. Don't forget to call
-checkConstraints: before using the repository.

@section Registering Model Description

To register an entity description, you must register the entity and its property 
descriptions, and do the same for the parent entity in case it is not registered 
yet.

<example>
[repo addDescription: entityDesc];
[repo addDescriptions: [entityDesc propertyDescriptions]];

[repo addDescription: [entityDesc parentEntity]];
[repo addDescriptions: [[entityDesc parentEntity] propertyDescriptions]];

// and so on
</example>

You must also register at the same time any entity description used as 
-[ETPropertyDescription type] or -[ETPropertyDescription persistentType], 
and any property description referred to by -[ETPropertyDescription opposite]. 
If this last property description itself belongs to an unregisted entity, you 
must register this entity description as described previously and so on.

To register a package description, you must register the entities (and all the 
property and entity descriptions they refer to) and the property extensions in 
a way similar to the previous example.

Note: If the entity describes a class, once registered, you usually bind it to
its class as described in the section Entity and Class Description Binding.

@section Resolving Named References

If your model element descriptions contains named references (rather than 
explicit ones to the real objects) e.g. -[ETProprertyDescription oppositeName], 
these descriptions must be added with -addUnresolvedDescription:, and 
-resolveNamedObjectReferences must be called once you don't need to call 
-addDescription: and -addUnresolvedDescription: anymore.

For references pointing to a package name -[ETEntityDescription ownerName] and 
-[ETPropertyDescription packageName], -resolveNamedObjectReferences will 
automatically create and register the missing package descriptions.

@section Entity and Class Description Binding

By default, a repository can contain entity descriptions that apply to:

<list>
<item>a prototype or a similar object (a free-standing entity is usually used 
with ETAdaptiveModelObject)</item>
<item>a class</item>
</list>

For entity descriptions describing a class, the two-way binding is established 
with -setEntityDescription:forClass:.

If no bound entity description or class can be found, -entityDescriptionForClass: 
and -classForEntityDescription both attempt to return a parent entity or 
superclass.

@section Consistency Checking

Every time entity or package descriptions are added to the repository, you must 
check the model description graph consistency with -checkConstraints:.

It is up to you to do it, because the repository has no way to know when you are 
done adding descriptions and the repository content is in a coherent state that 
won't raise warnings.  */
@interface ETModelDescriptionRepository : NSObject <ETCollection, ETCollectionMutation>
{
    @private
    NSMutableSet *_unresolvedDescriptions; /* Used to build the repository */
    NSMutableDictionary *_descriptionsByName; /* Descriptions registered in the repositiory */
    NSMapTable *_entityDescriptionsByClass;
    NSMapTable *_classesByEntityDescription;
    BOOL _needsConstantStringLookupHack;
}


/** @taskunit Metamodel Description */


/** Self-description (aka meta-metamodel). */
+ (ETEntityDescription *) newEntityDescription;


/** @taskunit Initialization */


/** Returns the initial repository that exists in each process.

When this repository is created, entity descriptions that make up the 
meta-metamodel are collected by invoking +newEntityDescription on every 
ETModelElementDescription subclass and bound to the class that provided the 
description. See -setEntityDescription:forClass:.

After collecting the entity descriptions, -checkConstraints: is called and must
return no warnings, otherwise a NSInternalInconsistencyException is raised. */
+ (id) mainRepository;
/** <init />
Returns a new repository that just contains the core metamodel (Object, Number, 
Boolean, String, Date, Value) and additional primitive entity descriptions (e.g. 
NSInteger, NSPoint etc.). */
- (id) init;


/** @taskunit Collecting Entity Descriptions in Class Hierarchy */


/** Traverses the class hierarchy downwards to collect the entity descriptions 
by invoking +newEntityDescription on each class (including the given class) and 
bind each entity description to the class that provided it. 
See -setEntityDescription:forClass:. 

If resolve is YES, the named references that exists between the descriptions 
are resolved immediately with -resolveNamedObjectReferences. Otherwise they 
are not and the repository remain in an invalid state until 
-resolveNamedObjectReferences is called.
 
See also -registerEntityDescriptionsForClasses:resolveNow:. */
- (void) collectEntityDescriptionsFromClass: (Class)aClass
                            excludedClasses: (NSSet *)excludedClasses 
                                 resolveNow: (BOOL)resolve;
/** Collects the entity descriptions by invoking +newEntityDescription on each 
given class and bind each entity description to the class that provided it.
See -setEntityDescription:forClass:. 
 
For resolveNow, see -collectEntityDescriptionsFromClass:excludedClasses:resolveNow:. */
- (void) registerEntityDescriptionsForClasses: (NSSet *)classes
                                   resolveNow: (BOOL)resolve;

/** @taskunit Registering and Enumerating Descriptions */


/** Returns the default package to which entity descriptions are added when 
they have none and they get put in the repository.

e.g. NSObject is owned by the anonymous package when its entity description is 
automatically registered in the main repository.

See also -addDescription:. */
@property (nonatomic, readonly) ETPackageDescription *anonymousPackageDescription;
/** Adds the given package, entity or property description to the repository.

Full names can be set as late-bound references to other 
ETModelElementDescription objects, in all the following properties:

<list>
<item>ownerName (ETPropertyDescription and ETEntityDescription) -> owner</item>
<item>packageName (ETPropertyDescription and ETEntityDescription) -> package</item>
<item>parentName (ETEntityDescription) -> parent</item>
<item>oppositeName (ETPropertyDescription) -> opposite</item>
<item>typeName (ETPropertyDescription) -> type</item>
<item>persistentTypeName (ETPropertyDescription) -> persistentType</item>
</list>

Note: the name that follows the arrow is the property to be set.

For example, <code>[anEntityDesc setParentName: @"MyPackage.MySuperEntity"]</code> 
or <code>[aPropertyDesc setOppositeName: @"MyPackage.MyEntity.whatever"]</code>.
 
For entity descriptions that belong to the anonymous package, the 
<em>Anonymous</em> prefix can be ommitted. For example, <em>@"NSDate"</em> is 
interpreted as <em>@"Anonymous.NSDate"</em> in -resolveNamedObjectReferences.

Once all the descriptions (unresolved or not) are registered to ensure a valid 
repository state, if any unresolved description was added, you must call 
-resolveNamedObjectReferences on the repository before using it or any 
registered description.
 
If the added entity description is equal to a previously registered entity 
(based on a full name comparison), raises an exception.  */
- (void) addUnresolvedDescription: (ETModelElementDescription *)aDescription;
/** Adds the given package, entity or property description to the repository.

If the given description is an entity description whose owner is nil, 
-anonymousPackageDescription becomes its owner, and it gets registered under 
the full name 'Anonymous.MyEntityName'.

When you are done adding and removing descriptions, don't forget to call 
-checkConstraints:. If the added or removed descriptions include any entity 
descriptions, use also -setEntityDescription:forClass: to update the bindings
between classes and entity descriptions.  */
- (void) addDescription: (ETModelElementDescription *)aDescription;
/** Removes the given package, entity or property description from the repository.

When you are done adding and removing descriptions, don't forget to call 
-checkConstraints:. If the added or removed descriptions include any entity 
descriptions, use also -setEntityDescription:forClass: to update the bindings
between classes and entity descriptions. */
- (void) removeDescription: (ETModelElementDescription *)aDescription;
/** Returns the packages registered in the repository.

The returned collection is an autoreleased copy. */
@property (nonatomic, readonly) NSArray *packageDescriptions;
/** Returns the entity descriptions registered in the repository.

The returned collection is an autoreleased copy. */
@property (nonatomic, readonly) NSArray *entityDescriptions;
/** Returns the property description registered in the repository.

The returned collection is an autoreleased copy. */
@property (nonatomic, readonly) NSArray *propertyDescriptions;
/** Returns all the package, entity and property descriptions registered in the 
repository.

The returned collection is an autoreleased copy. */
@property (nonatomic, readonly) NSArray *allDescriptions;
/** Returns a package, entity or property description registered for the given 
full name.

e.g. <em>Anonymous.NSObject</em> for NSObject entity.
 
For model element descriptions that belong to the anonymous package, the 
<em>Anonymous</em> prefix can be ommitted. For example, 
<em>@"ETModelElementDescription.name"</em> is interpreted as 
<em>@"Anonymous.ETModelDescription.name"</em>. */
- (id) descriptionForName: (NSString *)aFullName;


/** @taskunit Binding Descriptions to Class Instances and Prototypes */


/** Returns the class bound to the given entity description.

If no class is explicitly bound, returns the first bound class in the parent 
entity chain (by checking recursively until reaching the root entity whether the 
parent entity is bound to a class).

See -entityDescriptionForClass: and -setEntityDescription:forClass:. */
- (Class) classForEntityDescription: (ETEntityDescription*)anEntityDescription;
/** Returns the entity description bound to the given class.

If no entity description is explicitly bound, returns the first bound entity in 
the superclass chain (by checking recursively until reaching the root class 
whether the superclass is bound to an entity).

See -classForEntityDescription: and -setEntityDescription:forClass:. */
- (ETEntityDescription *) entityDescriptionForClass: (Class)aClass;
/** Creates a two-way binding between the given entity description and class.

For entity descriptions not created in +[NSObject newEntityDescription] and not 
registered in the +mainRepository, this method must be invoked explicitly. 

See -entityDescriptionForClass: and -classForEntityDescription:. */
- (void) setEntityDescription: (ETEntityDescription *)anEntityDescription
                     forClass: (Class)aClass;


/** @taskunit Resolving References Between Entity Descriptions */


/** Resolves named references for all the description properties listed in 
-addUnresolvedDescription:.
 
The package descriptions missing in the repository are also created based on 
-[ETEntityDescription ownerName] for the unresolved entity descriptions. By
default, -[NSObject newBasicEntityDescription] sets the package name to the 
bundle identifier owning the class returning the entity description.

For more details, you should also read Named References section in 
ETPropertyDescription class description.

When you are done resolving references, don't forget to call -checkConstraints:. 
If the added or removed descriptions include any entity descriptions, use also 
-setEntityDescription:forClass: to update the bindings between classes and 
entity descriptions. */
- (void) resolveNamedObjectReferences;


/** @taskunit Runtime Consistency Check */


/** Checks the receiver content conforms to the FM3 constraint spec and adds a 
short warning to the given array for each failure. */
- (void) checkConstraints: (NSMutableArray *)warnings;

@end
