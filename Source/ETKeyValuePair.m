/*
	Copyright (C) 2010 Quentin Mathe

	Author:  Quentin Mathe <quentin.mathe@gmail.com>
	Date:  May 2010
	License: Modified BSD (see COPYING)
 */

#import "ETKeyValuePair.h"
#import "ETCollection.h"
#import "NSObject+Model.h"
#import "EtoileCompatibility.h"
#import "Macros.h"

@implementation ETKeyValuePair

/** Returns a new autoreleased pair with the given key and value. */
+ (id) pairWithKey: (NSString *)aKey value: (id)aValue
{
	return AUTORELEASE([[self alloc] initWithKey: aKey value: aValue]);
}

/** <init />
Initializes and returns a new pair with the given key and value. */
- (id) initWithKey: (NSString *)aKey value: (id)aValue
{
	SUPERINIT;
	ASSIGN(_key, aKey);
	ASSIGN(_value, aValue);
	return self;
}

- (id) init
{
	return nil;
}

- (void) dealloc
{
	DESTROY(_key);
	DESTROY(_value);
	DESTROY(_representedObject);
	[super dealloc];
}

/** Returns YES when both key and value are equal, otherwise returns NO. */
- (BOOL) isEqual: (id)object
{
	if ([object isKindOfClass: [ETKeyValuePair class]] == NO)
		return NO;

	return ([[self key] isEqualToString: [object key]] && [[self value] isEqual: [object value]]);
}

- (NSUInteger)hash
{
	return [[self key] hash] ^ [[self value] hash];
}

/** Returns YES. */
- (BOOL) isKeyValuePair
{
	return YES;
}

/** Returns the pair identifier. */
- (NSString *) key
{
	return _key;
}

/** Sets the pair identifier. */
- (void) setKey: (NSString *)aKey
{
	if ([self validateKey: aKey] == NO)
		return;

	NSString *oldKey = RETAIN(_key);
	ASSIGN(_key, aKey);
	[self didChangeKeyOrValueForOldKey: oldKey value: [self value]];
	RELEASE(oldKey);
}

/** Returns the pair content. */
- (id) value
{
	return _value;
}

/** Sets the pair content. */
- (void) setValue: (id)aValue
{
	id oldValue = RETAIN(_value);
	ASSIGN(_value, aValue);
	[self didChangeKeyOrValueForOldKey: [self key] value: oldValue];
	RELEASE(oldValue);
}

// TODO: Formalize ETKeyValuePair a bit more as a viewpoint. When a represented
// object is set -value should look up its value dynamically (no value cached in an ivar).

- (id) representedObject
{
	return _representedObject;
}

- (void) setRepresentedObject: (id)anObject
{
	INVALIDARG_EXCEPTION_TEST(anObject, [anObject conformsToProtocol: @protocol(ETCollection)]);
	ASSIGN(_representedObject, anObject);
}

- (BOOL) validateKey: (NSString *)aKey
{
	id collection = [self representedObject];

	if (collection == nil || [collection isKeyed] == NO)
		return YES;

	// TODO: Remove content call once -objectForKey: is in ETKeyedCollection
	BOOL isNewKeyAvailable = ([[collection content] objectForKey: aKey] == nil);
	return isNewKeyAvailable;
}

- (void) didChangeKeyOrValueForOldKey: (NSString *)oldKey value: (id)oldValue
{
	NSParameterAssert(oldKey != nil);
	id collection = [self representedObject];

	/* Checking -isKeyed ensures we don't attempt to mutate a key-value pair array */
	if (collection == nil || [collection isKeyed] == NO)
		return;

	if ([collection isMutableCollection] == NO)
	{
		[NSException raise: NSInternalInconsistencyException
					format: @"Tried to mutate immutable collection %@ through %@",
		                    collection, self];
		return;
	}

	id value = [self value];
	NSUInteger index = ETUndeterminedIndex;

	/* Foundation doesn't provide ordered keyed collections, but somebody might implement one */
	if ([collection isOrdered])
	{
		// TODO: -Declare a ETOrderedCollection protocol that includes -indexOfObject:
		[collection indexOfObject: value];
	}

	[collection removeObject: nil atIndex: index hint: [ETKeyValuePair pairWithKey: oldKey value: oldValue]];
	[collection insertObject: value atIndex: index hint: self];
}

/** Exposes <em>key</em> and <em>value</em> in addition to the inherited properties. */
- (NSArray *) propertyNames
{
	return [[[self value] propertyNames] arrayByAddingObjectsFromArray: A(@"key", @"value")];
}

/** Returns the key. */
- (NSString *) displayName
{
	return _key;
}

- (id) valueForProperty: (NSString *)aProperty
{
	if ([aProperty isEqualToString: @"value"] || [aProperty isEqualToString: @"key"])
	{
		return [super valueForProperty: aProperty];
	}
	return [[self value] valueForProperty: aProperty];
}

- (BOOL) setValue: (id)aValue forProperty: (NSString *)aProperty
{
	if ([aProperty isEqualToString: @"value"] || [aProperty isEqualToString: @"key"])
	{
		return [super setValue: aValue forProperty: aProperty];
	}
	return [[self value] setValue: aValue forProperty: aProperty];
}

@end


@implementation NSArray (ETKeyValuePairRepresentation)

/** Returns a dictionary where every ETKeyValuePair present in the array is 
turned into a key/value entry.

For every other object, its index in the array becomes its key in the 
dictionary.

The returned dictionary is autoreleased.

Raises an NSGenericException when the receiver contains an object which is not 
an ETKeyValuePair object. */
- (NSDictionary *) dictionaryRepresentation
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity: [self count]];
	Class keyValuePairClass = [ETKeyValuePair class];

	FOREACH(self, pair, ETKeyValuePair *)
	{
		if ([pair isKindOfClass: keyValuePairClass] == NO)
		{
			[NSException raise: NSGenericException 
			            format: @"Array %@ must only contain ETKeyValuePair objects", 
			                    [self primitiveDescription]];
		}
		[dict setObject: [pair value] forKey: [pair key]];
	}

	return dict;
}

@end


@implementation NSObject (ETKeyValuePair)

/** Returns whether the receiver is a ETKeyValuePair instance. */
- (BOOL) isKeyValuePair
{
	return NO;
}

@end
