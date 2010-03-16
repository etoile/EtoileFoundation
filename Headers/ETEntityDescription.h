/*
 ETEntityDescription.h
 
 A model description framework inspired by FAME 
 (http://scg.unibe.ch/wiki/projects/fame)
 
 Copyright (C) 2009 Eric Wasylishen

 Author:  Eric Wasylishen <ewasylishen@gmail.com>
 Date:  July 2009
 License:  Modified BSD (see COPYING)
 */

#import <EtoileFoundation/ETPropertyValueCoding.h>
#import <EtoileFoundation/ETCollection.h>
#import <EtoileFoundation/ETModelElementDescription.h>

@class ETPackageDescription, ETPropertyDescription, ETValidationResult, ETUTI;

/**
 * A description of an "entity", which can either be a class or a prototype.
 */
@interface ETEntityDescription : ETModelElementDescription
{
	BOOL _abstract;
	NSMutableDictionary *_propertyDescriptions;
	ETEntityDescription *_parent;
	ETPackageDescription *_owner;
}

/**
 * The entity description that should end the parent chain of every entity 
 * description.
 *
 * Will be used by -checkConstraints:.
 */
+ (ETEntityDescription *) rootEntityDescription;

/** Returns YES. */
- (BOOL) isEntityDescription;

/* Property getters/setters */

/**
 * Whether or not this entity is abstract (i.e. can't be instantiated)
 */
- (BOOL) isAbstract;
- (void) setAbstract: (BOOL)isAbstract;
/**
 * Whether this is a root entity (has no parent entity)
 */
- (BOOL) isRoot;
/**
 * Descriptions of the properties declared on this entity (not including those
 * declared in parent entities)
 */
- (NSArray *) propertyDescriptions;
- (void) setPropertyDescriptions: (NSArray *)propertyDescriptions;
- (void) addPropertyDescription: (ETPropertyDescription *)propertyDescription;
- (void) removePropertyDescription: (ETPropertyDescription *)propertyDescription;

/**
 * Descriptions of the entity's properties, including those declared in parent
 * entities.
 */
- (NSArray *) allPropertyDescriptions;
/**
 * The parent entity of this entity. (Superclass or prototype)
 */
- (ETEntityDescription *) parent;
- (void) setParent: (ETEntityDescription *)parentDescription;
/** 
 * The package to which this entity belongs to.
 */
- (ETPackageDescription *) owner;
- (void) setOwner: (ETPackageDescription *)owner;

/* Utility methods */

- (ETPropertyDescription *)propertyDescriptionForName: (NSString *)name;

/* Validation */

- (ETValidationResult *) validateValue: (id)value forKey: (NSString *)key;

@end


@interface ETAdaptiveModelObject : NSObject
{
	NSMutableDictionary *_properties;
	ETEntityDescription *_description;
}

- (id) valueForProperty: (NSString *)key;
- (BOOL) setValue: (id)value forProperty: (NSString *)key;

@end
