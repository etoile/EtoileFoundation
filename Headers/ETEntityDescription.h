/**
    Copyright (C) 2009 Eric Wasylishen, Quentin Mathe

    Date:  July 2009
    License:  Modified BSD (see COPYING)
 */

#import <EtoileFoundation/ETPropertyValueCoding.h>
#import <EtoileFoundation/ETCollection.h>
#import <EtoileFoundation/ETModelElementDescription.h>

@class ETPackageDescription, ETPropertyDescription, ETValidationResult, ETUTI;

/** 
 * @group Metamodel
 * @abstract A description of an entity, which can either be a class or a prototype.
 *
 * For an introduction, see ETModelElementDescription.
 *
 * @section Freezing
 *
 * If -isFrozen is YES, the entity description is largely immutable, you can 
 * only add or remove transient property descriptions with 
 * -addPropertyDescription: and -removePropertyDescription.
 */
@interface ETEntityDescription : ETModelElementDescription <ETCollection, ETCollectionMutation>
{
    @private
    BOOL _abstract;
    NSMutableDictionary *_propertyDescriptions;
    ETEntityDescription *_parent;
    NSPointerArray *_children;
    ETPackageDescription *_owner;
    NSString *_parentName;
    NSString *_ownerName;
    NSString *_localizedDescription;
    NSArray *_UIBuilderPropertyNames;
    NSString *_diffAlgorithm;
    
    NSArray *_cachedAllPropertyDescriptions;
    NSDictionary *_cachedAllPropertyDescriptionsByName;
    NSArray *_cachedAllPropertyDescriptionNames;
    NSArray *_cachedAllPersistentPropertyDescriptions;
}


/** @taskunit Metamodel Description */


/** Self-description (aka meta-metamodel). */
+ (ETEntityDescription *) newEntityDescription;
/** The name of the entity description that should end the parent chain of 
every entity description.

This entity description is the Object primitive in the repository. See 
ETModelDescriptionRepository.

Will be used by -checkConstraints:. */
+ (NSString *) rootEntityDescriptionName;


/** @taskunit Querying Type */


/** Returns YES. */
@property (nonatomic, readonly) BOOL isEntityDescription;
/**  Returns <em>Entity</em>. */
@property (nonatomic, readonly) NSString *typeDescription;
/** Whether or not this entity is a primitive (i.e. describes attributes and 
not relationships).

Primitives include both object and C primitives. e.g. NSString, NSDate, 
NSInteger, float, etc.

See also -[ETPropertyDescription isRelationship]. */
@property (nonatomic, readonly) BOOL isPrimitive;
/** Whether or not this entity is a C primitive (i.e. describes attributes whose 
values are not objects). e.g. NSInteger, float, etc.

If YES is returned, -isPrimitive returns the same.

See also -[ETPropertyDescription isPrimitive]. */
@property (nonatomic, readonly) BOOL isCPrimitive;


/** @taskunit Model Specification */


/** Whether or not this entity is abstract (i.e. can't be instantiated). */
@property (nonatomic, assign, getter=isAbstract) BOOL abstract;


/** @taskunit Inheritance and Owning Package */


/** Whether this is a root entity (has no parent entity). */
@property (nonatomic, readonly) BOOL isRoot;
/** The parent entity of this entity. (Superclass or prototype)

The parent is retained, because the parent doesn't track its subentities. */
@property (nonatomic, retain) ETEntityDescription *parent;
/** Returns whether the given entity is a subentity of the receiver. */
- (BOOL) isKindOfEntity: (ETEntityDescription *)anEntityDesc;
/** The package to which this entity belongs to. */
@property (nonatomic, assign) ETPackageDescription *owner;
@property (nonatomic, readonly) NSArray *allPackageDescriptions;


/** @taskunit Property Descriptions */


/** Names of the property descriptions (not including those declared in parent 
entities). */
@property (nonatomic, readonly) NSArray *propertyDescriptionNames;
/** Names of all property descriptions including those declared in parent 
entities. */
@property (nonatomic, readonly) NSArray *allPropertyDescriptionNames;
/** Descriptions of the properties declared on this entity (not including those
declared in parent entities).

For each property added or removed, the behavior described in
-addPropertyDescription: and -removePropertyDescription: applies.

If -isFrozen returns YES, transient properties can still be added or removed 
with -addPropertyDescription: and -removePropertyDescription, but not directly 
with this setter. */
@property (nonatomic, retain) NSArray *propertyDescriptions;
/** Adds the given property description to this entity, the entity becomes its
owner.

If -isFrozen is YES, this method can still be used to add a transient property 
description. */
- (void) addPropertyDescription: (ETPropertyDescription *)propertyDescription;
/** Removes the given property description from this entity. */
- (void) removePropertyDescription: (ETPropertyDescription *)propertyDescription;
/** Descriptions of the entity's properties, including those declared in parent 
entities.

If -isFrozen is YES, this method can still be used to remove a transient 
property description. */
@property (nonatomic, readonly) NSArray *allPropertyDescriptions;
/** Descriptions of the entity's persistent properties, including those declared 
in parent entities.

See -[ETPropertyDescription isPersistent]. */
@property (nonatomic, readonly) NSArray *allPersistentPropertyDescriptions;
/** Returns the property description which matches the given name.

See also -propertyDescriptionsForNames: and -[ETModelElementDescription name] 
which is inherited by ETPropertyDescription. */
- (ETPropertyDescription *)propertyDescriptionForName: (NSString *)name;
/** Returns the property descriptions which matches the given names.
 
See also -propertyDescriptionForName: and -[ETModelElementDescription name]
which is inherited by ETPropertyDescription. */
- (NSArray *)propertyDescriptionsForNames: (NSArray *)names;


/** @taskunit Late-bound References */


/** 
 * The name of the parent entity.
 *
 * -[ETModelDescriptionRepository resolveNamedObjectReferences] sets -parent  
 * based on the parent name. Once resolved, -parentName returns nil.
 *
 * You should use this setter inside +[NSObject newEntityDescription].
 *
 * This property doesn't appear in the meta-metamodel, see +newEntityDescription.
 *
 * See also -parent. 
 */
@property (nonatomic, copy) NSString *parentName;
/** 
 * The name of the package to which this entity belongs to.
 *
 * -[ETModelDescriptionRepository resolveNamedObjectReferences] sets -owner 
 * based on the owner name. Once resolved, -ownerName returns nil.
 *
 * This property doesn't appear in the meta-metamodel, see +newEntityDescription.
 *
 * You should use this setter inside +[NSObject newEntityDescription]. 
 */
@property (nonatomic, copy) NSString *ownerName;


/** @taskunit Model Presentation */


/**
 * A short and human-readable description e.g. Person, Music Track.
 *
 * This is used to present the entity type to the user in the UI.
 *
 * By default, returns the entity name that is not localized.
 */
@property (nonatomic, copy) NSString *localizedDescription;


/** @taskunit UI Builder Support */


/**
 * The names of the entity properties visible in a IDE / UI builder inspector
 * (not including those declared in parent entities).
 */
@property (nonatomic, copy) NSArray *UIBuilderPropertyNames;
/**
 * The names of the entity properties visible in a UIDE / UI builder inspector,
 * including those declared in the parent entities.
 */
@property (nonatomic, readonly) NSArray *allUIBuilderPropertyNames;


/** @taskunit Diff/Merge */


/**
 * Diff algorithm name.
 *
 * Normally nil, in which case the default diff/merge algorithm is used.
 */
@property (nonatomic, copy) NSString *diffAlgorithm;


/** @taskunit Validation and Runtime Consistency Check */


/** Tries to validate the value that corresponds to the given property name, 
by delegating the validation to the right property description, and returns a 
validation result object. */
- (ETValidationResult *) validateValue: (id)value forKey: (NSString *)key;
/** Checks the given value and its type against the receiver type, and returns
whether the value type is a subtype of the receiver.

This method doesn't execute any model validation as -validateValue:forKey:
does. */
- (BOOL) isValidValue: (id)aValue type: (ETEntityDescription *)anEntityDesc;


/** @taskunit Internal */


/**
 * Returns whether the entity description has become immutable.
 *
 * For details, see Freezing section.
 */
@property (nonatomic, readonly) BOOL isFrozen;


@end


/** @group Metamodel
@abstract A description of an entity bound to attributes in the metamodel, and 
value objects in the model.

Used to describe the (meta)model primitives: object, string, boolean etc. 
See -[ETEntityDescription isPrimitive].

This class is used internally. You can possibly use it to support new 
primitives. */
@interface ETPrimitiveEntityDescription : ETEntityDescription

/** @taskunit Type Querying */

/** Returns YES. */
@property (nonatomic, readonly) BOOL isPrimitive;

@end


/** @group Metamodel
@abstract A description of an entity bound to C attributes in the metamodel, and 
C values in the model.

Used to describe the (meta)model C primitives: float, BOOL, etc. 
See -[ETEntityDescription isCPrimitive].

This class is used internally. You can possibly use it to support new 
primitives. */
@interface ETCPrimitiveEntityDescription : ETPrimitiveEntityDescription

/** @taskunit Type Querying */

/** Returns YES. */
@property (nonatomic, readonly) BOOL isCPrimitive;
@end
