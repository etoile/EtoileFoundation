/*
 ETEntityDescription.m
 
 Entity description in a model description framework inspired by FAME 
 (http://scg.unibe.ch/wiki/projects/fame)
 
 Copyright (C) 2009 Eric Wasylishen

 Author:  Eric Wasylishen <ewasylishen@gmail.com>
 Date:  July 2009
 License:  Modified BSD (see COPYING)
 */

#import <Foundation/Foundation.h>
#import "ETEntityDescription.h"
#import "ETPropertyDescription.h"
#import "ETCollection.h"
#import "ETReflection.h"
#import "Macros.h"
#import "EtoileCompatibility.h"

/**
 * A description of an "entity", which can either be a class or a prototype.
 */
@implementation ETEntityDescription 

+ (id) descriptionWithName: (NSString *)name
                  abstract: (BOOL)abstract
                    parent: (ETEntityDescription *)parent
      propertyDescriptions: (NSArray *)propertyDescriptions
                       UTI: (ETUTI *)UTI
{
	return [[[ETEntityDescription alloc] initWithName: name
											 abstract: abstract
											   parent: parent
								 propertyDescriptions: propertyDescriptions
												  UTI: UTI] autorelease];
}

- (id)  initWithName: (NSString *)name
            abstract: (BOOL)abstract
              parent: (ETEntityDescription *)parent
propertyDescriptions: (NSArray *)propertyDescriptions
                 UTI: (ETUTI *)UTI
{
	SUPERINIT;
	ASSIGN(_name, name);
	_abstract = abstract;
	_parent = parent;
	ASSIGN(_propertyDescriptions, propertyDescriptions);
	ASSIGN(_UTI, UTI);
	return self;
}
- (void) dealloc
{
	DESTROY(_name);
	DESTROY(_propertyDescriptions);
	DESTROY(_UTI);
	[super dealloc];
}
- (BOOL) isAbstract
{
	return _abstract;
}
- (void) setIsAbstract: (BOOL)isAbstract
{
	_abstract = isAbstract;
}
- (BOOL) isRoot
{
	return [self parent] == nil;
}
- (NSString *) name
{
	return _name;
}
- (void) setName: (NSString *)name
{
	ASSIGN(_name, name);
}
- (NSArray *) propertyDescriptions
{
	return [_propertyDescriptions allValues];
}
- (NSArray *) allPropertyDescriptions
{
	return [[_propertyDescriptions allValues] arrayByAddingObjectsFromArray:
			[[self parent] allPropertyDescriptions]];
}
- (ETEntityDescription *) parent
{
	return _parent;
}
- (void) setParent: (ETEntityDescription *)parentDescription
{
	ASSIGN(_parent, parentDescription);
}
- (ETUTI *)UTI
{
	return _UTI;
}
- (void)setUTI: (ETUTI *)UTI
{
	ASSIGN(_UTI, UTI);
}

// TODO: validation

@end





@implementation ETModelDescriptionRepository

+ (ETEntityDescription *) inferredDescriptionForObject: (id)object
{
	// FIXME: Should only autogenerate once per class
	
	id<ETObjectMirror> mirror = [ETReflection reflectObject: object];
	
	NSMutableArray *propertyDescriptions = [NSMutableArray array];	
	FOREACH([object properties], propertyName, NSString *)
	{
		[propertyDescriptions addObject: [ETPropertyDescription
										  descriptionWithName: propertyName
										  type: [ETUTI typeWithClass: [NSObject class]]
										  derived: NO
										  multivalued: NO
										  readOnly: NO
										  visible: YES]];		
	}
	
	return [ETEntityDescription 
			entityDescriptionWithName: [mirror name]
			type: [mirror type]
			propertyDescriptions: propertyDescriptions 
			abstract: NO
			container: [object conformsToProtocol: @protocol(ETCollection)] 
			root: ([mirror superclassMirror] != nil)];
}

- (NSArray *) contentArray
{
	
}

@end










#if 0
// Serialization

/**
 * Serialize the object using the ETModelDescription meta-meta model.
 */
- (NSDictionary *) _ETModelDescriptionSerializationOfObject: (id)obj withAlreadySerializedObjectsAndIds: 
{
	NSMutableDictionary *serialization = [NSMutableDictionary dictionary];
	id desc = [obj entityDescription];
	if (desc)
	{
		FOREACH([desc propertyDescriptions], propertyDescription, ETPropertyDescription *)
		{
			
		}
	}
	else if ([obj class] == [NSArray class]) // NSDictionary, NSNumber
	{
		return D(@"primitiveType", @"NSArray", 
		@"value", [[obj map] serialize...];
		}
		else if ([NSValueAdaptor blahBlahBlah] works..)
		{
			// serialize using value adapter stuff
		}
		return serialization;
		}
		
#endif
		
		
		@interface ETModelObject : NSObject
		{
			ETEntityDescription *_description;
		}
		
		@end
		
		@implementation ETModelObject
		
		- (id) valueForProperty: (NSString *)key
		{
			id value = nil;
			
			if ([_description hasProperty: key])
			{
				value = [self primitiveValueForKey: key];
			}
			else
			{
				// TODO: Turn into an ETDebugLog which takes an object (or a class) to
				// to limit the logging to a particular object or set of instances.
#ifdef DEBUG_PVC
				ETLog(@"WARNING: Found no value for property %@ in %@", key, self);
#endif
			}
			
			return value;
		}
		
		- (BOOL) setValue: (id)value forProperty: (NSString *)key
		{
			BOOL result = NO;
			
			if ([_description hasProperty: key] &&
				![_description valueForKeyPath: @"properties.name(=key).derived"])
			{
				[self setPrimitiveValue: value forKey: key];
				result = YES;
			}
			else
			{
				// TODO: Turn into an ETDebugLog which takes an object (or a class) to
				// to limit the logging to a particular object or set of instances.
#ifdef DEBUG_PVC
				ETLog(@"WARNING: Trying to set value %@ for property %@ missing in "
					  @"immutable property collection of %@", value, key, self);
#endif
			}
			
			return result;
		}
		
		@end
		
		
		@interface NSObject (ETModelDescription)
		- (ETEntityDescription *)entityDescription;
		@end
		
		@implementation NSObject (ETModelDescription)
		- (ETEntityDescription *)entityDescription
		{
			return [[ETModelDescriptionRepository defaultRepository]
					descriptionForObject: self];
		}
		@end
