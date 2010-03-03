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
#import "Macros.h"
#import "EtoileCompatibility.h"

/**
 * A description of an "entity", which can either be a class or a prototype.
 */
@implementation ETEntityDescription 

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

static ETEntityDescription *selfDesc = nil;

+ (ETEntityDescription *) entityDescription
{
	if (nil != selfDesc) return selfDesc;

	selfDesc = [ETEntityDescription descriptionWithName: @"ETEntityDescription"];
	
	ETPropertyDescription *abstract = [ETPropertyDescription descriptionWithName: @"abstract" owner: selfDesc];
	ETPropertyDescription *root = [ETPropertyDescription descriptionWithName: @"root" owner: selfDesc];
	[root setDerived: YES];
	ETPropertyDescription *propertyDescriptions = [ETPropertyDescription descriptionWithName: @"propertyDescriptions" owner: selfDesc];
	[propertyDescriptions setMultivalued: YES];
	//FIXME: In order for the next line to make sense, we need to have a
	//       globally shared repository of entity descriptions, since
	//       the entity description of ETEntityDescription has a refernece
	//       to the entity description of ETPropertyDescription
	//[propertyDescriptions setOpposite: [[ETPropertyDescription entityDescription] propertyDescriptionForName: @"owner"];
	ETPropertyDescription *parent = [ETPropertyDescription descriptionWithName: @"parent" owner: selfDesc];
	
	[selfDesc setPropertyDescriptions: A(abstract, root, propertyDescriptions, parent)];
	[selfDesc setParent: [[self superclass] entityDescription]];
	
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
		[_propertyDescriptions setObject: propertyDescription
								  forKey: [propertyDescription name]];
	}
}

- (void) addPropertyDescriptionsObject: (ETPropertyDescription *)propertyDescription
{
	[_propertyDescriptions setObject: propertyDescription
							  forKey: [propertyDescription name]];
}

- (void) removePropertyDescriptionsObject: (ETPropertyDescription *)propertyDescription
{
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

- (ETPropertyDescription *)propertyDescriptionForName: (NSString *)name
{
	return [_propertyDescriptions valueForKey: name];
}

- (ETValidationResult *) validateValue: (id)value forKey: (NSString *)key
{
	return [[self propertyDescriptionForName: key] validateValue: value forKey: key];
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
		
