/**

	Copyright (C) 2013 Quentin Mathe

	Author:  Quentin Mathe <quentin.mathe@gmail.com>
	Date:  June 2013
	License:  Modified BSD (see COPYING)
 */

#import "ETViewpoint.h"
#import "ETEntityDescription.h"
#import "ETModelDescriptionRepository.h"
#import "NSObject+HOM.h"
#import "NSObject+Model.h"
#import "NSObject+Trait.h"
#include <objc/runtime.h>

@implementation ETViewpointTrait

- (BOOL) isViewpoint
{
	return YES;
}

- (id) representedObject
{
	[self doesNotRecognizeSelector: _cmd];
	return nil;
}

- (void) setRepresentedObject: (id)object
{
	[self doesNotRecognizeSelector: _cmd];
}

- (id) value
{
	[self doesNotRecognizeSelector: _cmd];
	return nil;
}

- (void) setValue: (id)objectValue
{
	[self doesNotRecognizeSelector: _cmd];
}

- (NSArray *) propertyNames
{
	NSArray *properties = [[self value] propertyNames];

	/* If -value is nil, we just return A(@"value"), there is no need to return  
	   the property description names for the value entity description, because  
	   the value object must exist to access any property. */
	if (properties == nil)
	{
		properties = [NSArray array];
	}

	return [properties arrayByAddingObjectsFromArray: A(@"value")];
}

- (id) valueForProperty: (NSString *)aProperty
{
	return [[self value] valueForProperty: aProperty];
}

- (BOOL) setValue: (id)aValue forProperty: (NSString *)aProperty
{
	/* Since model properties are edited through ETLayoutItem or ETViewpoint 
	   objects, we delegate the value type validation to the model object. */
	return [[self value] setValue: aValue forProperty: aProperty];
}

#pragma mark Mutability Trait
#pragma mark -

- (Class) originalClass
{
	[self doesNotRecognizeSelector: _cmd];
	return Nil;
}

- (BOOL) isMutableValue
{
	return [[self class] isEqual: [self originalClass]];
}

- (Class) subclassForMutableViewpointTraitClass: (Class)aTraitClass
{
	const char *subclassName = [[NSString stringWithFormat: @"%@%@",
		NSStringFromClass([self class]), NSStringFromClass(aTraitClass)] UTF8String];
	Class subclass = objc_getClass(subclassName);

	if (subclass == Nil)
	{
		subclass = objc_allocateClassPair([self class], subclassName, 0);
		objc_registerClassPair(subclass);

		[subclass applyTraitFromClass: aTraitClass];
	}
	return subclass;
}

- (void) applyMutableViewpointTraitForValue: (id)aValue
{
	Class traitClass = [(id <ETViewpointMutation>)[[aValue class] ifResponds] mutableViewpointClass];
	
	if (traitClass == Nil)
		return;

	NSAssert([self isMemberOfClass: [self originalClass]],
		@"Setting the represented object is not yet supported if the current "
		 "element was an immutable value previously.");

	object_setClass(self, [self subclassForMutableViewpointTraitClass: traitClass]);
	ETAssert([self isMutableValue] == NO);
}

- (void) unapplyMutableViewpointTraitForValue: (id)aValue
{
	// TODO: Unapply exisisting trait
}

@end


@implementation NSObject (ETViewpointAdditions)

- (BOOL) isViewpoint
{
	return NO;
}

- (id) valueForContentKey: (NSString *)key
{
	if ([self isViewpoint])
	{
		return [self valueForProperty: key];
	}
	else
	{
		return [self valueForKey: key];
	}
}

- (void) setValue: (id)aValue forContentKey: (NSString *)key
{
	if ([self isViewpoint])
	{
		[self setValue: aValue forProperty: key];
	}
	else
	{
		[self setValue: aValue forKey: key];
	}
}

- (id) valueForContentKeyPath: (NSString *)aKeyPath
{
	NILARG_EXCEPTION_TEST(aKeyPath);
	INVALIDARG_EXCEPTION_TEST(aKeyPath, [aKeyPath length] != 0);

	id intermediateObject = self;

	for (NSString *key in [aKeyPath componentsSeparatedByString: @"."])
	{
		BOOL isOperator = [key hasPrefix: @"@"];
		
		if (isOperator)
			continue;

		intermediateObject = [intermediateObject valueForContentKey: key];
	}
	return intermediateObject;
}

- (void) setValue: (id)aValue forContentKeyPath: (NSString *)aKeyPath
{
	NSArray *keyPathComponents = [aKeyPath componentsSeparatedByString: @"."];
	NSArray *baseKeyPathComponents =
		[keyPathComponents subarrayWithRange: NSMakeRange(0, [keyPathComponents count] - 1)];
	NSString *baseKeyPath = [baseKeyPathComponents componentsJoinedByString: @"."];
		
	id intermediateObject = [self valueForContentKeyPath: baseKeyPath];

	[intermediateObject setValue: aValue forContentKey: [keyPathComponents lastObject]];
}

@end


// NOTE: Private addition that might make sense to expose in ETCollection protocol
@interface ETCollectionTrait (ETViewpointAdditions)
@end

@implementation  ETCollectionTrait (ETViewpointAdditions)

- (BOOL) isPrimitiveCollection
{
	return [self isEqual: [self content]];
}

- (id) valueForContentKey: (NSString *)key
{
	if ([self isPrimitiveCollection] == NO)
		return [super valueForContentKey: key];

	NSMutableArray *content = [NSMutableArray arrayWithCapacity: [self count]];

	/* For returning content of keyed collections such as dictionaries, we 
	   must use -objectEnumerator */
	for (id element in [self objectEnumerator])
	{
		id value = [element valueForContentKey: key];

		if (value == nil)
			continue;

		[content addObject: value];
	}
	return content;
}

- (void) setValue: (id)aValue forContentKey: (NSString *)key
{
	if ([self isPrimitiveCollection] == NO)
	{
		[super setValue: aValue forContentKey: key];
		return;
	}

	/* For accessing content of keyed collections such as dictionaries, we 
	   must use -objectEnumerator */	
	for (id element in [self objectEnumerator])
	{
		[element setValue: aValue forContentKey: key];
	}
}

@end
