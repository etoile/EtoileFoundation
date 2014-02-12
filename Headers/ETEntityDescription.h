/**
	Copyright (C) 2009 Eric Wasylishen

	Author:  Eric Wasylishen <ewasylishen@gmail.com>
	Date:  July 2009
	License:  Modified BSD (see COPYING)
 */

#import <EtoileFoundation/ETPropertyValueCoding.h>
#import <EtoileFoundation/ETCollection.h>
#import <EtoileFoundation/ETModelElementDescription.h>

@class ETPackageDescription, ETPropertyDescription, ETValidationResult, ETUTI;

/** @group Model and Metamodel
@abstract A description of an entity, which can either be a class or a prototype. */
@interface ETEntityDescription : ETModelElementDescription <ETCollection, ETCollectionMutation>
{
	@private
	BOOL _abstract;
	NSMutableDictionary *_propertyDescriptions;
	NSArray *_cachedAllPropertyDescriptions;
	ETEntityDescription *_parent;
	ETPackageDescription *_owner;
	NSString *_localizedDescription;
	NSArray *_UIBuilderPropertyNames;
	NSString *_diffAlgorithm;
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
-addPropertyDescription: and -removePropertyDescription: applies. */
@property (nonatomic, retain) NSArray *propertyDescriptions;
/** Adds the given property description to this entity, the entity becomes its
owner. */
- (void) addPropertyDescription: (ETPropertyDescription *)propertyDescription;
/** Removes the given property description from this entity. */
- (void) removePropertyDescription: (ETPropertyDescription *)propertyDescription;
/** Descriptions of the entity's properties, including those declared in parent 
entities. */
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

@end


/** @group Model and Metamodel

Used to describe Model description primitives: object, string, boolean 
etc. See -[ETEntityDescription isPrimitive].

This class is used internally. You can possibly use it to support new 
primitives. */
@interface ETPrimitiveEntityDescription : ETEntityDescription

/** @taskunit Type Querying */

/** Returns YES. */
@property (nonatomic, readonly) BOOL isPrimitive;

@end


/** @group Model and Metamodel

Used to describe Model description C primitives: float, BOOL, etc.
See -[ETEntityDescription isCPrimitive].

This class is used internally. You can possibly use it to support new 
primitives. */
@interface ETCPrimitiveEntityDescription : ETPrimitiveEntityDescription

/** @taskunit Type Querying */

/** Returns YES. */
@property (nonatomic, readonly) BOOL isCPrimitive;
@end


/** @group Model and Metamodel

WARNING: This class is under development and must be ignored.

Very simple implementation of an adaptive model object that is causally
connected to its description. This means that changes to the entity description 
immediately take effect in the instance of ETAdaptiveModelObject.

Causal connection is ensured through the implementation of -valueForProperty: 
and -setValue:forProperty:. */
@interface ETAdaptiveModelObject : NSObject
{
	@private
	NSMutableDictionary *_properties;
	ETEntityDescription *_description;
}

/** @taskunit Property Value Coding */

/** Returns the property value if the property is declared in the metamodel 
(aka entity description). */
- (id) valueForProperty: (NSString *)key;
/** Sets the property value and returns YES when the property is declared in 
the metamodel and it allows the value to be set. In all other cases, does 
nothing and returns NO. */ 
- (BOOL) setValue: (id)value forProperty: (NSString *)key;

@end
