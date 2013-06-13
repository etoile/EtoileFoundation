/*
	Copyright (C) 2013 Quentin Mathe

	Author:  Quentin Mathe <quentin.mathe@gmail.com>
	Date:  May 2013
	License:  Modified BSD  (see COPYING)
 */

#import "Macros.h"
#import "ETUnionViewpoint.h"
#import "NSObject+Model.h"
#import "NSObject+Trait.h"
#import "NSString+Etoile.h"
#import "EtoileCompatibility.h"

@implementation ETUnionViewpoint

@synthesize contentKeyPath = _contentKeyPath;

- (id) accessedObjectForMutation
{
	id intermediateObject = [self representedObject];
	NSString *keyPath = [self observedKeyPath];

	for (NSString *component in [keyPath componentsSeparatedByString: @"."])
	{
		BOOL isComponentBeforeLast = [keyPath hasSuffix: component];
		BOOL isOperator = [component hasPrefix: @"@"];

		if (isOperator || isComponentBeforeLast)
			break;
		
		intermediateObject = [intermediateObject valueForKey: component];

		if ([intermediateObject isCollection])
			break;
	}
	
	return intermediateObject;
}

- (NSString *) observedKeyPath
{
	if ([self contentKeyPath] == nil)
		return [super observedKeyPath];

	if ([super observedKeyPath] == nil)
		return [self contentKeyPath];

	return [NSString stringWithFormat: @"%@.%@", [self name], [self contentKeyPath]];
}

- (id) value
{
	if ([self contentKeyPath] == nil)
	{
		return [super value];
	}
	else
	{
		return [[super value] valueForKeyPath: [self contentKeyPath]];
	}
}

- (void) setValue: (id)aValue
{
	if ([self contentKeyPath] == nil)
	{
		[super setValue: aValue];
	}
	else
	{
		[[super value] setValue: aValue forKeyPath: [self contentKeyPath]];
	}
}

+ (id) mixedValueMarker
{
	return [NSNumber numberWithInteger: -1];
}

- (id) valueForProperty: (NSString *)aProperty
{
	id lastValue = nil;
	BOOL isFirstValue = YES;
	
	for (id object in [self value])
	{
		id value = [object valueForProperty: aProperty];
		
		if (isFirstValue == NO && value != lastValue && [value isEqual: lastValue] == NO)
		{
			return [[self class] mixedValueMarker];
		}
		isFirstValue = NO;
		lastValue = value;
	}

	return lastValue;
}

- (BOOL) setValue: (id)aValue forProperty: (NSString *)aProperty
{
	NSParameterAssert([aValue isEqual: [[self class] mixedValueMarker]] == NO);

	BOOL result = YES;

	for (id object in [self value])
	{
		result &= [object setValue: aValue forProperty: aProperty];
	}
	return result;
}

#pragma mark Collection Protocol
#pragma mark -

- (SEL) collectionSetter
{
	return NSSelectorFromString([NSString stringWithFormat: @"set%@:",
		[[[self contentKeyPath] lastPathComponent] stringByCapitalizingFirstLetter]]);
}

- (BOOL) isMutableCollection
{
	return ([[super value] count] == 1
		&& [[self accessedObjectForMutation] respondsToSelector: [self collectionSetter]]);
}

@end
