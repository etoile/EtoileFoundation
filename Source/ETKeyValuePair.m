/*
	Copyright (C) 2010 Quentin Mathe

	Author:  Quentin Mathe <quentin.mathe@gmail.com>
	Date:  May 2010
	License: Modified BSD (see COPYING)
 */

#import "ETKeyValuePair.h"
#import "ETCollection.h"
#import "NSObject+Model.h"
#import "NSObject+Trait.h"
#import "EtoileCompatibility.h"
#import "Macros.h"

#pragma GCC diagnostic ignored "-Wprotocol"

@interface ETKeyValuePair (ETViewpointTraitAliasedMethods)
- (NSArray *) viewpointTraitPropertyNames;
@end

@implementation ETKeyValuePair

+ (void) initialize
{
	if (self != [ETKeyValuePair class])
		return;

	[self applyTraitFromClass: [ETViewpointTrait class]];
	// FIXME: Method aliasing is broken
	/*[self applyTraitFromClass: [ETViewpointTrait class]
	      excludedMethodNames: [NSSet set]
	       aliasedMethodNames: D(@"viewpointTraitPropertyNames", @"propertyNames")];*/
}

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

- (NSString *) description
{
	return [NSString stringWithFormat: @"%@ = %@, %@ - %@", [self key],
		[self value] , [self representedObject], [super description]];
}

+ (BOOL) automaticallyNotifiesObserversForKey:(NSString *)key
{
	/* Automatic KVO notifications are disabled to prevent conflicts if a 
	   class transform is used to support editing immutable objects. */
	return NO;
}

/** Returns YES. */
- (BOOL) isKeyValuePair
{
	return YES;
}

/** Returns <em>displayName</em>, <em>key</em>, <em>value</em> 
and <em>representedObject</em>. */
- (NSSet *) observableKeyPaths
{
	return S(@"displayeName", @"key", @"value", @"representedObject");
}

#pragma mark Controlling the Represented Element
#pragma mark -

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

#pragma mark Property Value Coding
#pragma mark -

/** Exposes <em>key</em> and <em>value</em> in addition to the inherited properties. */
- (NSArray *) propertyNames
{
	// FIXME: See +intialize
	//return [[self viewpointTraitPropertyNames] arrayByAddingObjectsFromArray: A(@"key")];

	NSArray *properties = [[self value] propertyNames];

	/* If -value is nil, we just return A(@"self", @"value"), there is no need 
	   to return the property description names for the value entity description, 
	   because the value object must exist to access any property. */
	if (properties == nil)
	{
		properties = A(@"self");
	}

	return [properties arrayByAddingObjectsFromArray: A(@"key", @"value")];
}

- (id) valueForProperty: (NSString *)aProperty
{
	/* For key-value pairs that belong to an heterogen collection, the
	   UI presentation uses a 'displayName' column in many cases. It is important 
	   to intercept any 'displayName' access to ensure key-value pairs appear
	   with a name when presented. For example, objects in an ETAspectCategory
	   have their names determined by -[ETKeyValuePair key].
	   -name and -setName: can still be used to access the value object name. */
	if ([aProperty isEqualToString: @"value"] || [aProperty isEqualToString: @"key"]
	 || [aProperty isEqualToString: @"displayName"])
	{
		return [super valueForProperty: aProperty];
	}
	return [[self value] valueForProperty: aProperty];
}

- (BOOL) setValue: (id)aValue forProperty: (NSString *)aProperty
{
	if ([aProperty isEqualToString: @"value"] || [aProperty isEqualToString: @"key"]
	 || [aProperty isEqualToString: @"displayName"])
	{
		return [super setValue: aValue forProperty: aProperty];
	}

	if ([self isMutableValue])
	{
		return [[self value] setValue: aValue forProperty: aProperty];
	}
	else
	{
		return [super setValue: aValue forProperty: aProperty];
	}
}

#pragma mark UI Presentation
#pragma mark -

/** Returns the key. */
- (NSString *) displayName
{
	return _key;
}

#pragma mark Mutability Trait
#pragma mark -

- (Class) originalClass
{
	return [ETKeyValuePair class];
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
