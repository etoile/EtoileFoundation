/*
	Copyright (C) 2009 Eric Wasylishen

	Author:  Eric Wasylishen <ewasylishen@gmail.com>
	Date:  July 2009
	License:  Modified BSD (see COPYING)
 */

#import "ETModelElementDescription.h"
#import "ETEntityDescription.h"
#import "ETModelDescriptionRepository.h"
#import "ETPropertyDescription.h"
#import "ETUTI.h"
#import "NSObject+Model.h"
#import "NSString+Etoile.h"
#import "Macros.h"
#import "EtoileCompatibility.h"


@implementation ETModelElementDescription

@synthesize name = _name,displayName = _displayName;
@synthesize itemIdentifier = _itemIdentifier, isMetaMetamodel = _isMetaMetamodel;

/** Returns ET. */
+ (NSString *) typePrefix
{
	return @"ET";
}

+ (NSString *) baseClassName
{
	return @"Description";
}

/* As a unique exception, we override +basicEntityDescription to ensure all 
the subclass returned descriptions belongs to the meta-metamodel. */
+ (ETEntityDescription *) newBasicEntityDescription
{
	ETEntityDescription *selfDesc = [super newBasicEntityDescription];
	[selfDesc setIsMetaMetamodel: YES];
	return selfDesc;
}

+ (ETEntityDescription *) newEntityDescription
{
	ETEntityDescription *selfDesc = [self newBasicEntityDescription];

	if ([[selfDesc name] isEqual: [ETModelElementDescription className]] == NO) 
		return selfDesc;
	
	ETPropertyDescription *name = 
		[ETPropertyDescription descriptionWithName: @"name" type: (id)@"NSString"];
	ETPropertyDescription *fullName = 
		[ETPropertyDescription descriptionWithName: @"fullName" type: (id)@"NSString"];
	[fullName setDerived: YES];
	ETPropertyDescription *isMetaMetamodel = 
		[ETPropertyDescription descriptionWithName: @"isMetaMetamodel" type: (id)@"BOOL"];
	// TODO: To support overriden property descriptions would allow to declare 
	// 'owner' at the abstract class level too (as FM3 spec does).
	//ETPropertyDescription *owner = [ETPropertyDescription descriptionWithName: @"owner"];
	//[owner setDerived: YES];
	ETPropertyDescription *itemIdentifier = 
		[ETPropertyDescription descriptionWithName: @"itemIdentifier" type: (id)@"NSString"];
	ETPropertyDescription *displayName =
		[ETPropertyDescription descriptionWithName: @"displayName" type: (id)@"NSString"];
	ETPropertyDescription *typeDescription = 
		[ETPropertyDescription descriptionWithName: @"typeDescription" type: (id)@"NSString"];
	[typeDescription setReadOnly: YES];

	[selfDesc setAbstract: YES];
	[selfDesc setPropertyDescriptions: A(name, fullName, isMetaMetamodel, itemIdentifier, displayName, typeDescription)];

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
	ASSIGNCOPY(_name, name);
	return self;
}

- (id) init
{
	return [self initWithName: _(@"Untitled")];
}

- (void) dealloc
{
	DESTROY(_name);
	DESTROY(_itemIdentifier);
	DESTROY(_displayName);
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

- (void) setName: (NSString *)name
{
	[self checkNotFrozen];
	ASSIGNCOPY(_name, name);
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

- (void) setIsMetaMetamodel: (BOOL)isMeta
{
	[self checkNotFrozen];
	_isMetaMetamodel = isMeta;
}

- (void) setItemIdentifier: (NSString *)anIdentifier
{
	[self checkNotFrozen];
	ASSIGNCOPY(_itemIdentifier, anIdentifier);
}

- (void) checkConstraints: (NSMutableArray *)warnings
{

}

- (NSString *) warningWithMessage: (NSString *)msg
{
	return [[self description] stringByAppendingFormat: @" - %@", msg];
}

- (NSString *) typePrefix
{
	return nil;
}

- (NSString *) displayName
{
	if (_displayName != nil)
		return _displayName;

	NSString *typePrefix = [self typePrefix];
	NSString *name = [self name];

	if (typePrefix != nil)
	{
		name = [name substringFromIndex: [typePrefix length]];
	}
	return [[name stringByCapitalizingFirstLetter] stringBySpacingCapitalizedWords];
}

- (NSString *) typeDescription
{
	return @"Element";
}

- (NSArray *) propertyNames
{
	ETModelDescriptionRepository *repo = [ETModelDescriptionRepository mainRepository];

	return [[super propertyNames] arrayByAddingObjectsFromArray: 
		[[repo entityDescriptionForClass: [self class]] allPropertyDescriptionNames]]; 
}

- (void) checkNotFrozen
{
	if (_isFrozen)
	{
		[NSException raise: NSGenericException
					format: @"Illegal mutation of %@ after it has been frozen (marked as immutable)", self];
	}
}

- (void) makeFrozen
{
	ETAssertUnreachable();
}

@end
