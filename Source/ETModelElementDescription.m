/*
	Copyright (C) 2009 Eric Wasylishen

	Author:  Eric Wasylishen <ewasylishen@gmail.com>
	Date:  July 2009
	License:  Modified BSD (see COPYING)
 */

#import "ETModelElementDescription.h"
#import "ETEntityDescription.h"
#import "ETPropertyDescription.h"
#import "ETUTI.h"
#import "Macros.h"
#import "EtoileCompatibility.h"


@implementation ETModelElementDescription

+ (ETEntityDescription *) newEntityDescription
{
	ETEntityDescription *selfDesc = [[ETEntityDescription alloc] initWithName: [self className]];
	
	ETPropertyDescription *name = [ETPropertyDescription descriptionWithName: @"name"];
	ETPropertyDescription *fullName = [ETPropertyDescription descriptionWithName: @"fullName"];
	[fullName setDerived: YES];
	// TODO: To support overriden property descriptions would allow to declare 
	// 'owner' at the abstract class level too (as FM3 spec does).
	//ETPropertyDescription *owner = [ETPropertyDescription descriptionWithName: @"owner"];
	//[owner setDerived: YES];
	ETPropertyDescription *itemIdentifier = [ETPropertyDescription descriptionWithName: @"itemIdentifier"];

	[selfDesc setAbstract: YES];	
	[selfDesc setPropertyDescriptions: A(name, fullName, itemIdentifier)];
	[selfDesc setParent: (id)NSStringFromClass([self superclass])];

	return selfDesc;
}

+ (id) descriptionWithName: (NSString *)name
{
	return [[[[self class] alloc] initWithName: name] autorelease];
}

- (id) initWithName: (NSString *)name
{
	if ([[self class] isMemberOfClass: [ETModelElementDescription class]])
	{
		DESTROY(self);
		return nil;
	}
	NILARG_EXCEPTION_TEST(name);
	// TODO: Check the name is not in use once we have a repository.

	SUPERINIT;
	ASSIGN(_name, name);
	return self;
}

- (void) dealloc
{
	DESTROY(_name);
	DESTROY(_itemIdentifier);
	[super dealloc];
}

- (BOOL) isPropertyDescription
{
	return NO;
}

- (BOOL) isEntityDescription
{
	return NO;
}

- (BOOL) isPackageDescription
{
	return NO;
}

- (NSString *) description
{
	return [NSString stringWithFormat: @"%@ %@", [super description], [self fullName]];
}

- (NSString *) name
{
	return _name;
}

- (void) setName: (NSString *)name
{
	ASSIGN(_name, name);
}

- (NSString *) fullName
{
	if (nil != [self owner])
	{
		return [NSString stringWithFormat: @"%@.%@", [[self owner] fullName], [self name]];
	}
	else
	{
		return [self name];
	}
}

- (id) owner
{
	return nil;
}

- (NSString *) itemIdentifier;
{
	return _itemIdentifier;
}

- (void) setItemIdentifier: (NSString *)anIdentifier
{
	ASSIGN(_itemIdentifier, anIdentifier);
}

- (void) checkConstraints: (NSMutableArray *)warnings
{

}

- (NSString *) warningWithMessage: (NSString *)msg
{
	return [[self description] stringByAppendingFormat: @" - %@", msg];
}

@end
