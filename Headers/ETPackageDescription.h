/**
    Copyright (C) 2010 Quentin Mathe

    Date:  March 2010
    License:  Modified BSD (see COPYING)
 */

#import <Foundation/Foundation.h>
#import <EtoileFoundation/ETModelElementDescription.h>
#import <EtoileFoundation/ETCollection.h>

@class ETEntityDescription, ETPropertyDescription;

/** @group Metamodel
@abstract Collection of related entity descriptions, usually equivalent to a data model.

A package can also include extensions to other entity descriptions. An extension 
is a property description whose owner doesn't belong to the package it gets 
added to.<br />
For example, a category can be described with a property description array, and 
these property descriptions packaged as extensions to be resolved later (usually 
when the package is imported/deserialized).

From a Model Builder perspective, a package is the document you work on to 
specify a data model.  */
@interface ETPackageDescription : ETModelElementDescription <ETCollection, ETCollectionMutation>
{
    @private
    NSMutableSet *_entityDescriptions;
    NSMutableSet *_propertyDescriptions;
    NSUInteger _version;
    BOOL _supportsNamespace;
}


/** @taskunit Metamodel Description */


/** Self-description (aka meta-metamodel). */
+ (ETEntityDescription *) newEntityDescription;


/** @taskunit Querying Type */


/** Returns YES. */
@property (nonatomic, readonly) BOOL isPackageDescription;
/** Returns <em>Package</em>. */
@property (nonatomic, readonly) NSString *typeDescription;


/** @taskunit Schema Versioning */


@property (nonatomic, assign) NSUInteger version;


/** @taskunit Namespace Support */


@property (nonatomic, assign) BOOL supportsNamespace;


/** @taskunit Packaged Entity Descriptions */


/** Adds the given entity to the package, the package becomes its owner.

Will remove every property from the package that extends this entity and 
previously added with -addPropertyDescription: or -setPropertyDescriptions:. */
- (void) addEntityDescription: (ETEntityDescription *)anEntityDescription;
/** Removes the given entity from the package. */
- (void) removeEntityDescription: (ETEntityDescription *)anEntityDescription;
/** The entities that belong to the package.

For each entity added or removed, the behavior described in
-addEntityDescription: and -removeEntityDescription: applies.

The returned collection is an autoreleased copy. */
@property (nonatomic, retain) NSSet *entityDescriptions;


/** @taskunit Packaged Entity Extensions */


/** Adds the given entity extension to the package.

The property owner must be the entity to be extended.<br />
Raises an NSInvalidArgumentException when the property owner is nil or already 
belongs to the package. */
- (void) addPropertyDescription: (ETPropertyDescription *)propertyDescription;
/** Removes the given entity extension from the package. */
- (void) removePropertyDescription: (ETPropertyDescription *)propertyDescription;
/** The entity extensions that belong to the package.

For each entity extensions added or removed, the behavior described in
-addPropertyDescription: and -removePropertyDescription: applies.

The returned collection is an autoreleased copy. */
@property (nonatomic, retain) NSSet *propertyDescriptions;


/** @taskunit Runtime Consistency Check */


/** Checks the receiver conforms to the FM3 constraint spec and adds a short 
warning to the given array for each failure. */
- (void) checkConstraints: (NSMutableArray *)warnings;

@end
