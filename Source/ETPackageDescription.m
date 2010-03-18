/*
	Copyright (C) 2010 Quentin Mathe

	Author:  Quentin Mathe <quentin.mathe@gmail.com>
	Date:  March 2010
	License:  Modified BSD (see COPYING)
 */

#import "ETPackageDescription.h"
#import "ETCollection.h"
#import "ETCollection+HOM.h"
#import "ETEntityDescription.h"
#import "ETPropertyDescription.h"
#import "Macros.h"
#import "EtoileCompatibility.h"


@implementation ETPackageDescription

+ (ETEntityDescription *) newEntityDescription
{
	ETEntityDescription *selfDesc = [[ETEntityDescription alloc] initWithName: [self className]];

	// TODO: Add property descriptions...

	return selfDesc;
}

- (id) initWithName: (NSString *)aName
{
	self = [super initWithName: aName];
	if (nil == self) return nil;

	_entityDescriptions = [[NSMutableSet alloc] init];
	_propertyDescriptions = [[NSMutableSet alloc] init];

	return self;
}

- (void) dealloc
{
	DESTROY(_entityDescriptions);
	DESTROY(_propertyDescriptions);
	[super dealloc];
}

- (BOOL) isPackageDescription
{
	return YES;
}

- (void) addEntityDescription: (ETEntityDescription *)anEntityDescription
{
	ETPackageDescription *owner = [anEntityDescription owner];

	if (nil != owner)
	{
		[owner removeEntityDescription: anEntityDescription];
	}
	[anEntityDescription setOwner: self];
	[_entityDescriptions addObject: anEntityDescription];

	NSMutableSet *conflictingExtensions = [NSMutableSet setWithSet: _propertyDescriptions];
	[[[conflictingExtensions filter] owner] isEqual: anEntityDescription];
	[_propertyDescriptions minusSet: conflictingExtensions];
}

- (void) removeEntityDescription: (ETEntityDescription *)anEntityDescription
{
	[anEntityDescription setOwner: nil];
	[_entityDescriptions removeObject: anEntityDescription];
}

- (void) setEntityDescriptions: (NSSet *)entityDescriptions
{
	FOREACH([NSSet setWithSet: _entityDescriptions], oldEntityDesc, ETEntityDescription *)
	{
		[self removeEntityDescription: oldEntityDesc];
	}
	FOREACH(entityDescriptions, newEntityDesc, ETEntityDescription *)
	{
		[self addEntityDescription: newEntityDesc];
	}
}

- (NSSet *) entityDescriptions
{
	return AUTORELEASE([_entityDescriptions copy]);
}

- (void) addPropertyDescription: (ETPropertyDescription *)propertyDescription
{
	INVALIDARG_EXCEPTION_TEST(propertyDescription, nil != propertyDescription);
	INVALIDARG_EXCEPTION_TEST(propertyDescription, 
		NO == [_entityDescriptions containsObject: [propertyDescription owner]]);

	ETPackageDescription *package = [propertyDescription package];

	if (nil != package)
	{
		[package removePropertyDescription: propertyDescription];
	}
	[propertyDescription setPackage: self];
	[_propertyDescriptions addObject: propertyDescription];
}

- (void) removePropertyDescription: (ETPropertyDescription *)propertyDescription
{
	[propertyDescription setPackage: nil];
	[_propertyDescriptions removeObject: propertyDescription];
}

- (void) setPropertyDescriptions: (NSSet *)propertyDescriptions
{
	FOREACH([NSSet setWithSet: _propertyDescriptions], oldPropertyDesc, ETPropertyDescription *)
	{
		[self removePropertyDescription: oldPropertyDesc];
	}
	FOREACH(propertyDescriptions, newPropertyDesc, ETPropertyDescription *)
	{
		[self addPropertyDescription: newPropertyDesc];
	}
}

- (NSSet *) propertyDescriptions
{
	return AUTORELEASE([_propertyDescriptions copy]);
}

- (void) checkConstraints: (NSMutableArray *)warnings
{

}

@end
