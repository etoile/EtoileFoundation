/**

	Copyright (C) 2013 Quentin Mathe

	Author:  Quentin Mathe <quentin.mathe@gmail.com>
	Date:  June 2013
	License:  Modified BSD (see COPYING)
 */

#import "ETViewpoint.h"
#import "NSObject+HOM.h"
#import "NSObject+Trait.h"
#include <objc/runtime.h>

@implementation ETViewpointTrait

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
	return [[self value] propertyNames];
}

- (id) valueForProperty: (NSString *)aProperty
{
	return [[self value] valueForProperty: aProperty];
}

- (BOOL) setValue: (id)aValue forProperty: (NSString *)aProperty
{
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
