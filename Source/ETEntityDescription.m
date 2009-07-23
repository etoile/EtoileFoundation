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
	[self setPropertyDescriptions: propertyDescriptions];
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
- (ETUTI *)UTI
{
	return _UTI;
}
- (void)setUTI: (ETUTI *)UTI
{
	ASSIGN(_UTI, UTI);
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
		
		
		
		
@implementation ETAdaptiveModelObject 

- (id) valueForProperty: (NSString *)key
{
	return [_properties valueForKey: key];
}
			
- (BOOL) setValue: (id)value forProperty: (NSString *)key
{
	FOREACH([_description propertyDescriptions], description, ETPropertyDescription *)
	{
		// FIXME: Do more validation.
		if ([[description name] isEqualToString: key] && ![description isDerived])
		{
			[_properties setValue:value forKey: key];
			return YES;
		}
	}
	return NO;
}
		
// FIXME: support multivalue read/write access

@end
		
