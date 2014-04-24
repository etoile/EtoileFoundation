/*
	Copyright (C) 2009 Eric Wasylishen

	Date:  July 2009
	License:  Modified BSD (see COPYING)
 */

#import <Foundation/Foundation.h>
#import "ETAdaptiveModelObject.h"
#import "ETCollection+HOM.h"
#import "ETEntityDescription.h"
#import "ETPropertyDescription.h"
#import "Macros.h"
#import "EtoileCompatibility.h"


@implementation ETAdaptiveModelObject

- (id) init
{
	SUPERINIT;
	_properties = [[NSMutableDictionary alloc] init];
	_description = [[ETEntityDescription alloc] initWithName: @"Untitled"];
	return self;
}

- (void)dealloc
{
	[_properties release];
	[_description release];
	[super dealloc];
}

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
	return (NSArray *)[[[_description propertyDescriptions] mappedCollection] name];
}

- (NSArray *) allPropertyNames
{
	return (NSArray *)[[[_description allPropertyDescriptions] mappedCollection] name];
}

- (id) valueForKey: (NSString *)key
{
	return [self valueForProperty: key];
}

@end
