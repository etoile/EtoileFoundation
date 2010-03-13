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
	[selfDesc setParent: (id)NSStringFromClass([self superclass])];

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
	[self removeEntityDescription: [[NSSet setWithSet: _entityDescriptions] each]];
	[self addEntityDescription: [entityDescriptions each]];
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
	[self removePropertyDescription: [[NSSet setWithSet: _propertyDescriptions] each]];
	[self addPropertyDescription: [propertyDescriptions each]];
}

- (NSSet *) propertyDescriptions
{
	return AUTORELEASE([_propertyDescriptions copy]);
}

- (void) checkConstraints: (NSMutableArray *)warnings
{

}

@end
