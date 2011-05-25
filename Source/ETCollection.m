/*
	Copyright (C) 2007 Quentin Mathe

	Author:  Quentin Mathe <qmathe@club-internet.fr>
	Date:  September 2007
	License: Modified BSD (see COPYING)
 */

#import "ETCollection.h"
#import "NSObject+Mixins.h"
#import "NSObject+Model.h"
#import "Macros.h"
#import "EtoileCompatibility.h"

const NSUInteger ETUndeterminedIndex = NSNotFound;

#pragma GCC diagnostic ignored "-Wprotocol"

@implementation ETCollectionTrait

/** Returns NO. */
- (BOOL) isOrdered
{
	return NO;
}

/** Returns the content count. 

See -content. */
- (NSUInteger) count
{
	return [[self content] count];
}

/** Returns nil.

A concrete implementation must be provided in the target class. 
The constraints to respect are detailed in -[(ETCollection) content]. */
- (id) content
{
	return nil;
}

/** Returns nil.

A concrete implementation must be provided in the target class.
 The constraints to respect are detailed in -[(ETCollection) contentArray]. */
- (NSArray *) contentArray
{
	return nil;
}

/** Returns whether the content count is zero.

See -count. */
- (BOOL) isEmpty
{
	return ([self count] == 0);
}

/** Returns the content enumerator. 

See -content. */
- (NSEnumerator *) objectEnumerator
{
	return [[self content] objectEnumerator];
}

/** Returns whether the given element belongs to the collection. 

The implementation tests the membership against the content array. 

See -contentArray. */
- (BOOL) containsObject: (id)anObject
{
	return [[self contentArray] containsObject: anObject];
}

/** Returns whether the given elements are a subset of the receiver collection. 

The implementation tests the membership against the content arrays. 

See -contentArray. */
- (BOOL) containsCollection: (id <ETCollection>)objects
{
	NSSet *contentSet = [NSSet setWithArray: [self contentArray]];
	NSSet *otherSet = [NSSet setWithArray: [objects contentArray]];

	return [otherSet isSubsetOfSet: contentSet];
}

@end

@implementation ETMutableCollectionTrait

/** Calls -insertObject:AtIndex:hint: with ETUndeterminedIndex as the index and 
a nil hint. */
- (void) addObject: (id)object
{
	[self insertObject: object atIndex: ETUndeterminedIndex hint: nil];
}

/** Calls -insertObject:AtIndex:hint: with a nil hint. */
- (void) insertObject: (id)object atIndex: (NSUInteger)index
{
	[self insertObject: object atIndex: index hint: nil];
}

/** Calls -removeObject:AtIndex:hint: with ETUndeterminedIndex as the index and 
a nil hint. */
- (void) removeObject: (id)object
{
	[self removeObject: object atIndex: ETUndeterminedIndex hint: nil];
}

/** Calls -insertObject:AtIndex:hint: with a nil object and a nil hint. */
- (void) removeObjectAtIndex: (NSUInteger)index
{
	[self removeObject: nil atIndex: index hint: nil];
}

/** Does nothing.

A concrete implementation must be provided in the target class.
The constraints to respect are detailed in -[(ETCollectionMutation) insertObject:atIndex:hint:]. */
- (void) insertObject: (id)object atIndex: (NSUInteger)index hint: (id)hint
{

}

/** Does nothing.

A concrete implementation must be provided in the target class.
The constraints to respect are detailed in -[(ETCollectionMutation) removeObject:atIndex:hint:]. */
- (void) removeObject: (id)object atIndex: (NSUInteger)index hint: (id)hint
{

}

@end

@implementation NSArray (ETCollection)

+ (void) load
{
	[self applyTraitFromClass: [ETCollectionTrait class]];
}

/** Returns NSMutableDictionary class. */
+ (Class) mutableClass
{
	return [NSMutableArray class];
}

- (BOOL) isOrdered
{
	return YES;
}

// NOTE: Could be removed, was kept to avoid the extra -content message send.
- (BOOL) isEmpty
{
	return ([self count] == 0);
}

- (id) content
{
	return self;
}

- (NSArray *) contentArray
{
	return [NSArray arrayWithArray: self];
}

- (NSString *) stringValue
{
	return [self descriptionWithLocale: nil];
}

- (NSString *) description
{
	return [NSString stringWithFormat: @"Array %d ordered objects", [self count]];
}

@end

@implementation NSDictionary (ETCollection)

+ (void) load
{
	[self applyTraitFromClass: [ETCollectionTrait class]];
}

/** Returns NSMutableDictionary class. */
+ (Class) mutableClass
{
	return [NSMutableDictionary class];
}

// NOTE: Could be removed, was kept to avoid the extra -content message send.
- (BOOL) isEmpty
{
	return ([self count] == 0);
}

- (id) content
{
	return self;
}

- (NSArray *) contentArray
{
	return [self allValues];
}

- (NSString *) identifierAtIndex: (NSUInteger)index
{
	// FIXME: In theory a bad implementation seeing that the documentation
	// states -allKeys and -allValues return objects in an undefined order.
	return [[[self allKeys] objectAtIndex: index] stringValue];
}

- (NSString *) stringValue
{
	return [self descriptionWithLocale: nil];
}

- (NSString *) description
{
	return [NSString stringWithFormat: @"Dictionary %d key/value pairs", [self count]];
}

@end

@implementation NSSet (ETCollection)

+ (void) load
{
	[self applyTraitFromClass: [ETCollectionTrait class]];
}

/** Returns NSMutableSet class. */
+ (Class) mutableClass
{
	return [NSMutableSet class];
}

// NOTE: Could be removed, was kept to avoid the extra -content message send.
- (BOOL) isEmpty
{
	return ([self count] == 0);
}

- (id) content
{
	return self;
}

- (NSArray *) contentArray
{
	return [self allObjects];
}

@end

@implementation NSCountedSet (ETCollection)

/** Returns self, the NSCountedSet class.

NSCountedSet is always mutable and has not immutable equivalent. */
+ (Class) mutableClass
{
	return self;
}

@end

@implementation NSIndexSet (ETCollection)

+ (void) load
{
	[self applyTraitFromClass: [ETCollectionTrait class]];
}

/** Returns NSMutableIndexSet class. */
+ (Class) mutableClass
{
	return [NSMutableIndexSet class];
}

// NOTE: Could be removed, was kept to avoid the extra -content message send.
- (BOOL) isEmpty
{
	return ([self count] == 0);
}

- (id) content
{
	return self;
}

- (NSArray *) contentArray
{
	NSMutableArray *indexes = [NSMutableArray arrayWithCapacity: [self count]];
	int nbOfIndexes = [self count];
	int nbOfCopiedIndexes = -1;
	NSUInteger *copiedIndexes = calloc(sizeof(NSUInteger), nbOfIndexes);
	
	nbOfCopiedIndexes = [self getIndexes: copiedIndexes maxCount: nbOfIndexes
		inIndexRange: NULL];
	
	NSAssert2(nbOfCopiedIndexes > -1, @"Invalid number of copied indexes for "
		@"%@, expected value is %d", self, nbOfIndexes);
	
	// NOTE: i < [self count] prevents the loop to be entered, because negative  
	// int (i) doesn't appear to be inferior to unsigned int (count)
	for (int i = 0; i < nbOfIndexes; i++)
	{
		unsigned int index = copiedIndexes[i];
			
		[indexes addObject: [NSNumber numberWithInt: index]];
	}
	
	free(copiedIndexes);
	
	return indexes;
}

- (NSEnumerator *) objectEnumerator
{
	return [[self contentArray] objectEnumerator];
}

@end

@implementation NSMutableDictionary (ETCollectionMutation)

/** Adds object to the receiver using as key the value returned by 
-[object keyForCollection:] if not nil, otherwise falling back on the highest 
integer value of all keys incremented by one. */
- (void) addObject: (id)object
{
	id key = [object keyForCollection: self];
	
	if (key == nil)
	{
		int i = 0;
		NSNumber *number = nil;
		id matchedObject = nil;

		do {
			number = [NSNumber numberWithInt: i];	
			matchedObject = [self objectForKey: number];
			i++;			
		} while (matchedObject != nil);

		key = number;
	}
	
	[self setObject: object forKey: key];
}

- (void) insertObject: (id)object atIndex: (NSUInteger)index
{
	[self addObject: object];
}

/** Removes all occurrences of an object in  the receiver. */
- (void) removeObject: (id)object
{
	NSEnumerator *e = [[self allKeysForObject: object] objectEnumerator];
	id key = nil;
	
	while ((key = [e nextObject]) != nil)
	{
		[self removeObjectForKey: key];
	}
}

@end

@implementation NSMutableSet (ETCollectionMutation)

- (void) insertObject: (id)object atIndex: (NSUInteger)index
{
	[self addObject: object];
}

@end

@implementation NSMutableIndexSet (ETCollectionMutation)

- (void) addObject: (id)object
{
	if ([object isNumber])
	{
		[self addIndex: [object unsignedIntValue]];
	}
	else
	{
		// TODO: Evaluate whether logging a warning is a better choice than 
		// raising an exception.
		ETLog(@"Object %@ must be an NSNumber instance to be added to %@ "
			@"collection", object, self);
		return;	
	}
}

- (void) insertObject: (id)object atIndex: (NSUInteger)index
{
	[self addObject: object];
}


- (void) removeObject: (id)object
{
	if ([object isNumber])
	{
		[self removeIndex: [object unsignedIntValue]];
	}
	else
	{
		// TODO: Evaluate whether logging a warning is a better choice than 
		// raising an exception.
		ETLog(@"Object %@ must be an NSNumber instance to be removed from %@ "
			@"collection", object, self);
		return;	
	}
}

@end


/* NSArray Extensions */

@implementation NSArray (Etoile)

/** Returns the first object in the array, otherwise returns nil if the array is
empty. */
- (id) firstObject
{
	if ([self isEmpty])
		return nil;

	return [self objectAtIndex: 0];
}

/** Returns a new array by copying the receiver and removing the objects equal 
to those contained in the given array. */
- (NSArray *) arrayByRemovingObjectsInArray: (NSArray *)anArray
{
	NSMutableArray *mutableArray = [NSMutableArray arrayWithArray: self];
	[mutableArray removeObjectsInArray: anArray];
	/* For safety we return an immutable array */
	return [NSArray arrayWithArray: mutableArray];
}

/** Returns a filtered array as -filteredArrayWithPredicate: does but always 
includes in the new array the given objects to be ignored by the filtering. */
- (NSArray *) filteredArrayUsingPredicate: (NSPredicate *)aPredicate
                          ignoringObjects: (NSSet *)ignoredObjects
{
	NSMutableArray *newArray = [NSMutableArray arrayWithCapacity: [self count]];

	FOREACHI(self, object)
	{
		if ([ignoredObjects containsObject: object] 
		 || [aPredicate evaluateWithObject: object])
		{
			[newArray addObject: object];
		}
	}

	return newArray;
}

/** <strong>Deprecated</strong>

Returns the objects on which -valueForKey: returns a value that matches 
the given one.

For every object in the receiver, -valueForKey: will be invoked with the given 
key.

<example>
NSArray *personsNamedJohn = [persons objectsMatchingValue: @"John" forKey: @"name"];
</example>

You should now use -filteredArrayUsingPredicate or -filter instead. For example:

<example>
NSArray *personsNamedJohn = [persons filteredArrayUsingPredicate: 
	[NSPredicate predicateWithFormat: @"name == %@", @"John"]];
</example> */
- (NSArray *) objectsMatchingValue: (id)value forKey: (NSString *)key
{
    NSMutableArray *result = [NSMutableArray array];
    NSArray *values = [self valueForKey: key];

    if (values == nil)
        return result;
    
    int n = [values count];
    
    for (int i = 0; i < n; i++)
    {
        if ([[values objectAtIndex: i] isEqual: value])
        {
            [result addObject: [self objectAtIndex: i]];
        }
    }
    
    return result;
}

/** <strong>Deprecated</strong>

Same as the -objectsMatchingValue:forKey:, except it returns the first 
object that matches the receiver.

Nil is returned when no object can be matched. */
- (id) firstObjectMatchingValue: (id)value forKey: (NSString *)key
{
    NSArray *matchedObjects = [self objectsMatchingValue: value forKey: key];

	if ([matchedObjects isEmpty])
		return nil;
	
	return [matchedObjects firstObject];
}

@end

@implementation NSMutableDictionary (DictionaryOfLists)
- (void)addObject: anObject forKey: aKey
{
	id old = [self objectForKey: aKey];
	if (nil == old)
	{
		[self setObject: anObject forKey: aKey];
	}
	else
	{
		if ([old isKindOfClass: [NSMutableArray class]])
		{
			[(NSMutableArray*)old addObject: anObject];
		}
		else
		{
			[self setObject: [NSMutableArray arrayWithObjects: old, anObject, nil]
			         forKey: aKey];
		}
	}
}
@end
