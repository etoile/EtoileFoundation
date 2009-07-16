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
#import <EtoileFoundation/ETValidationResult.h>
#import <EtoileFoundation/ETPropertyDescription.h>
#import <EtoileFoundation/ETUTI.h>

/**
 * A description of an "entity", which can either be a class or a prototype.
 */
@interface ETEntityDescription : NSObject
{
	BOOL _abstract;
	NSString *_name;
	NSMutableDictionary *_propertyDescriptions;
	ETEntityDescription *_parent;
	ETUTI *_type;
}

+ (id) descriptionWithName: (NSString *)name
abstract: (BOOL)abstract
parent: (ETEntityDescription *)parent
propertyDescriptions: (NSArray *)propertyDescriptions
type: (ETUTI *)type;

- (id)  initWithName: (NSString *)name
abstract: (BOOL)abstract
parent: (ETEntityDescription *)parent
propertyDescriptions: (NSArray *)propertyDescriptions
type: (ETUTI *)type;

/**
 * Whether or not this entity is abstract (i.e. can't be instantiated)
 */
- (BOOL) isAbstract;
- (void) setIsAbstract: (BOOL)isAbstract;
/**
 * Whether this is a root entity (has no parent entity)
 */
- (BOOL) isRoot;
/**
 * Name of the entity
 */
- (NSString *) name;
- (void) setName: (NSString *)name;
/**
 * Descriptions of the properties declared on this entity (not including those
 * declared in parent entities)
 */
- (NSArray *) propertyDescriptions;
- (void) setPropertyDescriptions: (NSArray *)propertyDescriptions;
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


/* Validation */

- (ETValidationResult *) validateValue: (id)value forKey: (NSString *)key;
/**
 * Pass a block which takes one argument (the value being validated)
 * and returns an ETValidationResult
 */
- (void) setValidationBlock: (id)aBlock;

@end




@interface ETModelDescriptionRepository : NSObject <ETCollection>
{
	NSMapTable *_descriptions;
}

- (void) registerDescription: (ETEntityDescription *)description
                   forObject: (id)object;
- (ETEntityDescription *) descriptionForObject: (id)object;

@end


@interface NSObject (ETModelObject)

- (id) valueForProperty: (NSString *)key;
- (BOOL) setValue: (id)value forProperty: (NSString *)key;

@end
