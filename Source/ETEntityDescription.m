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
#import "ETCollection.h"
#import "ETCollection+HOM.h"
#import "ETPropertyDescription.h"
#import "ETReflection.h"
#import "ETValidationResult.h"
#import "NSObject+Model.h"
#import "Macros.h"
#import "EtoileCompatibility.h"

/**
 * A description of an "entity", which can either be a class or a prototype.
 */
@implementation ETEntityDescription 

+ (ETEntityDescription *) rootEntityDescription
{
	return [NSObject newEntityDescription];
}

- (id)  initWithName: (NSString *)name
{
	self = [super initWithName: name];
	if (nil == self) return nil;

	_abstract = NO;
	_propertyDescriptions = [[NSMutableDictionary alloc] init];
	_parent = nil;
	return self;
}

- (void) dealloc
{
	DESTROY(_propertyDescriptions);
	[super dealloc];
}

+ (ETEntityDescription *) newEntityDescription
{
	ETEntityDescription *selfDesc = [ETEntityDescription descriptionWithName: [self className]];

	NSArray *inheritedPropertyDescs = [[super newEntityDescription] allPropertyDescriptions];
	ETPropertyDescription *abstract = [ETPropertyDescription descriptionWithName: @"abstract"];
	ETPropertyDescription *root = [ETPropertyDescription descriptionWithName: @"root"];
	[root setDerived: YES];
	ETPropertyDescription *propertyDescriptions = 
		[ETPropertyDescription descriptionWithName: @"propertyDescriptions"];
	[propertyDescriptions setMultivalued: YES];
	//FIXME: In order for the next line to make sense, we need to have a
	//       globally shared repository of entity descriptions, since
	//       the entity description of ETEntityDescription has a refernece
	//       to the entity description of ETPropertyDescription
	//[propertyDescriptions setOpposite: [[ETPropertyDescription entityDescription] propertyDescriptionForName: @"owner"];
	ETPropertyDescription *parent = [ETPropertyDescription descriptionWithName: @"parent"];
	
	[selfDesc setPropertyDescriptions: [inheritedPropertyDescs arrayByAddingObjectsFromArray: 
		A(abstract, root, propertyDescriptions, parent)]];
	[selfDesc setParent: (id)NSStringFromClass([self superclass])];
	
	return selfDesc;
}

- (BOOL) isAbstract
{
	return _abstract;
}

- (void) setAbstract: (BOOL)isAbstract
{
	_abstract = isAbstract;
}

- (BOOL) isRoot
{
	return [self parent] == nil;
}

- (NSArray *) propertyDescriptions
{
	return [_propertyDescriptions allValues];
}

- (void) setPropertyDescriptions: (NSArray *)propertyDescriptions
{
	FOREACH([self propertyDescriptions], oldProperty, ETPropertyDescription *)
	{
		[oldProperty setOwner: nil];
	}
	[_propertyDescriptions release];
	
	_propertyDescriptions = [[NSMutableDictionary alloc] initWithCapacity:
		[propertyDescriptions count]];
	FOREACH(propertyDescriptions, propertyDescription, ETPropertyDescription *)
	{
		[self addPropertyDescription: propertyDescription];
	}
}

- (void) addPropertyDescription: (ETPropertyDescription *)propertyDescription
{
	ETEntityDescription *owner = [propertyDescription owner];

	if (nil != owner)
	{
		[owner removePropertyDescription: propertyDescription];
	}
	[propertyDescription setOwner: self];
	[_propertyDescriptions setObject: propertyDescription
							  forKey: [propertyDescription name]];
}

- (void) removePropertyDescription: (ETPropertyDescription *)propertyDescription
{
	[propertyDescription setOwner: nil];
	[_propertyDescriptions removeObjectForKey: [propertyDescription name]];
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
	_parent = parentDescription;
}

- (ETPackageDescription *) owner
{
	return _owner;
}

- (void) setOwner: (ETPackageDescription *)owner
{
	_owner = owner;
}

- (ETPropertyDescription *)propertyDescriptionForName: (NSString *)name
{
	return [_propertyDescriptions valueForKey: name];
}

- (ETValidationResult *) validateValue: (id)value forKey: (NSString *)key
{
	return [[self propertyDescriptionForName: key] validateValue: value forKey: key];
}

/* For now, private and not used except in -checkConstraints:. */
- (BOOL) isPrimitive
{
	return NO;
}

/* Inspired by the Java implementation of FAME */
- (void) checkConstraints: (NSMutableArray *)warnings
{
	int container = 0;

	FOREACH([self allPropertyDescriptions], propertyDesc, ETPropertyDescription *)
	{
		[propertyDesc checkConstraints: warnings];

		if ([propertyDesc isContainer])
			container++;
	}
	if (container > 1) 
	{
		[warnings addObject: [self warningWithMessage: 
			@"Found more than one container/composite relationship"]];
	}

	if ([self isEqual: [[self class] rootEntityDescription]] == NO 
	 && [self isPrimitive] == NO) 
	{
		if ([self parent] == nil)
		{
			[warnings addObject: [self warningWithMessage: @"Miss a parent"]];
		}
		if ([[self parent] isPrimitive]) 
		{
			[warnings addObject: [self warningWithMessage: 
				@"Primitives are not allowed to be parent"]];
		}
	}
	else
	{
		ETAssert(nil == [self parent]);
	}

	NSMutableSet *entityDescSet = [NSMutableSet setWithObject: self];
	ETEntityDescription *entityDesc = self;

	while (entityDesc != nil)
	{
		if ([entityDescSet containsObject: entityDesc])
		{
			[warnings addObject: [self warningWithMessage: 
				@"Found a loop in the parent chain"]];
			break;
		}
		[entityDescSet addObject: entityDesc];
		entityDesc = [entityDesc parent];
	}
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
		
		
/**
 Very simple implementation of an adaptive model object that is causally 
 connected to its description. This means that changes to the entity description
 immediately take effect in the instance of ETAdaptiveModelObject.
 
 Causal connection is ensured through the implementation of
 -valueForProperty: and -setValue:forProperty:.
 */		
@implementation ETAdaptiveModelObject 

- (id) init
{
	SUPERINIT;
	_properties = [[NSMutableDictionary alloc] init];
	_description = [[ETEntityDescription alloc] initWithName: @"Untitled"];
	return self;
}

DEALLOC(DESTROY(_properties); DESTROY(_description);)

/* Property-value coding */
		
- (id) valueForProperty: (NSString *)key
{
	ETPropertyDescription *desc = [_description propertyDescriptionForName: key];
	if (desc != nil)
	{
		return [_properties valueForKey: key];
	}
	else
	{
		return nil;
	}
}
			
- (BOOL) setValue: (id)value forProperty: (NSString *)key
{
	ETPropertyDescription *desc = [_description propertyDescriptionForName: key];
	if (desc != nil && ![desc isDerived])
	{
		[_properties setValue:value forKey: key];
		return YES;
	}
	return NO;
}

- (NSArray *) propertyNames
{
	//FIXME: Optimize if needed.
	return (NSArray *)[[[_description propertyDescriptions] mappedCollection] name];
}
		
- (NSArray *) allPropertyNames
{
	return (NSArray *)[[[_description allPropertyDescriptions] mappedCollection] name];
}
		
/* Key-value coding */

- (id) valueForKey: (NSString *)key
{
	return [self valueForProperty: key];
}
		
@end
		
