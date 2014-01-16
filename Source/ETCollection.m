/*
	Copyright (C) 2007 Quentin Mathe

	Author:  Quentin Mathe <qmathe@club-internet.fr>
	Date:  September 2007
	License: Modified BSD (see COPYING)
 */

#import "ETCollection.h"
#import "ETCollection+HOM.h"
#import "ETIndexValuePair.h"
#import "ETKeyValuePair.h"
#import "NSObject+Trait.h"
#import "NSObject+Model.h"
#import "Macros.h"
#import "EtoileCompatibility.h"

const NSUInteger ETUndeterminedIndex = NSNotFound;

#pragma GCC diagnostic ignored "-Wprotocol"

// Number of classes and categories that must be loaded before 
// ETApplyCollectionTraits() will work.
// The count includes collection categories on NSArray, NSDictionary, NSSet, 
// NSIndexSet, NSMutableArray, NSMutableDictionary, NSMutableSet, NSMutableIndexSet,  
// trait classes ETCollectionTrait and ETMutableCollectionTrait, and 
// ETTraitApplication private class in NSObject+Trait.m
static int loading = 8 + 2 + 1;

void ETApplyCollectionTraits()
{
	if (--loading != 0) return;

	Class collectionTrait = [ETCollectionTrait class];
	NSCAssert(Nil != collectionTrait, @"Collection trait not yet loaded!");
	[NSArray applyTraitFromClass: collectionTrait];
	[NSDictionary applyTraitFromClass: collectionTrait];
	[NSSet applyTraitFromClass: collectionTrait];
	[NSIndexSet applyTraitFromClass: collectionTrait];

	Class mutableCollectionTrait = [ETMutableCollectionTrait class];
	NSCAssert(Nil != collectionTrait, @"Collection trait not yet loaded!");
	[NSMutableArray applyTraitFromClass: mutableCollectionTrait];
	[NSMutableDictionary applyTraitFromClass: mutableCollectionTrait];
	[NSMutableSet applyTraitFromClass: mutableCollectionTrait];
	[NSMutableIndexSet applyTraitFromClass: mutableCollectionTrait];
}

@implementation ETCollectionTrait

+ (void) load
{
	ETApplyCollectionTraits();
}

/** Returns NO. */
- (BOOL) isOrdered
{
	return NO;
}

/** Returns NO. */
- (BOOL) isKeyed
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

/** Forwards the message to the content.

See -content. */
- (NSUInteger) countByEnumeratingWithState: (NSFastEnumerationState *)state 
                                   objects: (id *)objects
                                     count: (NSUInteger)count
{
	return [[self content] countByEnumeratingWithState: state objects: objects count: count];
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

+ (void) load
{
	ETApplyCollectionTraits();
}

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
	NSIndexSet *indexes =
		(index != ETUndeterminedIndex ? [NSIndexSet indexSetWithIndex: index] : [NSIndexSet indexSet]);

	[self insertObjects: (object != nil ? A(object) : [NSArray array])
	          atIndexes: indexes
	              hints: (hint != nil ? A(hint) : nil)];
}

/** Does nothing.

A concrete implementation must be provided in the target class.
The constraints to respect are detailed in -[(ETCollectionMutation) removeObject:atIndex:hint:]. */
- (void) removeObject: (id)object atIndex: (NSUInteger)index hint: (id)hint
{
	NSIndexSet *indexes =
		(index != ETUndeterminedIndex ? [NSIndexSet indexSetWithIndex: index] : [NSIndexSet indexSet]);
	
	[self removeObjects: (object != nil ? A(object) : [NSArray array])
	          atIndexes: indexes
	              hints: (hint != nil ? A(hint) : nil)];
}

- (void) insertObjects: (NSArray *)objects atIndexes: (NSIndexSet *)indexes hints: (NSArray *)hints
{
#if 0
	[self doesNotRecognizeSelector: _cmd];
#else
	for (int i = 0; i < [objects count]; i++)
	{
		[self insertObject: [objects objectAtIndex: i] atIndex: i hint: (hints != nil ? [hints objectAtIndex: i] : nil)];
	}
#endif
}

- (void) removeObjects: (NSArray *)objects atIndexes: (NSIndexSet *)indexes hints: (NSArray *)hints
{
#if 0
	[self doesNotRecognizeSelector: _cmd];
#else
	for (int i = 0; i < [objects count]; i++)
	{
		[self removeObject: [objects objectAtIndex: i] atIndex: i hint: (hints != nil ? [hints objectAtIndex: i] : nil)];
	}
#endif
}

@end


@implementation NSObject (ETCollectionMutationKVOSupport)

/*
 * NSKeyValueChangeSetting is an optimization we don't support, we just treat it 
 * as a subcase of NSKeyValueChangeReplacement.
 */
- (NSKeyValueChange) keyValueChangeForMutationKind: (ETCollectionMutationKind)mutationKind
{
	NSKeyValueChange keyValueChange = 0;

	if (mutationKind == ETCollectionMutationKindInsertion)
	{
		keyValueChange = NSKeyValueChangeInsertion;
	}
	else if (mutationKind == ETCollectionMutationKindRemoval)
	{
		keyValueChange = NSKeyValueChangeRemoval;
	}
	else if (mutationKind == ETCollectionMutationKindReplacement)
	{
		keyValueChange = NSKeyValueChangeReplacement;
	}
	else
	{
		ETAssertUnreachable();
	}
	return keyValueChange;
}

/*
 * NSKeyValueIntersectSetMutation is an optimization we don't support, we just  
 * treat it as a subcase of NSKeyValueSetSetMutation.
 */
- (NSKeyValueSetMutationKind) keyValueSetMutationKindForMutationKind: (ETCollectionMutationKind)mutationKind
{
	NSKeyValueSetMutationKind setMutationKind = 0;

	if (mutationKind == ETCollectionMutationKindInsertion)
	{
		setMutationKind = NSKeyValueUnionSetMutation;
	}
	else if (mutationKind == ETCollectionMutationKindRemoval)
	{
		setMutationKind = NSKeyValueMinusSetMutation;
	}
	else if (mutationKind == ETCollectionMutationKindReplacement)
	{
		setMutationKind = NSKeyValueSetSetMutation;
	}
	else
	{
		ETAssertUnreachable();
	}
	return setMutationKind;
}

- (void) willChangeValueForKey: (NSString *)key
                     atIndexes: (NSIndexSet *)indexes
                   withObjects: (NSArray *)objects
                  mutationKind: (ETCollectionMutationKind)mutationKind
{
	id value = [self valueForKey: key];

	if ([value isKindOfClass: [NSArray class]])
	{
		[self willChange: [self keyValueChangeForMutationKind: mutationKind]
		 valuesAtIndexes: indexes
		          forKey: key];
	}
	else if ([value isKindOfClass: [NSSet class]])
	{
		[self willChangeValueForKey: key
		            withSetMutation: [self keyValueSetMutationKindForMutationKind: mutationKind]
		               usingObjects: [NSSet setWithArray: objects]];
	}
	else
	{
		[self willChangeValueForKey: key];
	}
}

- (void) didChangeValueForKey: (NSString *)key
                    atIndexes: (NSIndexSet *)indexes
                  withObjects: (NSArray *)objects
                 mutationKind: (ETCollectionMutationKind)mutationKind
{
	id value = [self valueForKey: key];

	if ([value isKindOfClass: [NSArray class]])
	{
		[self didChange: [self keyValueChangeForMutationKind: mutationKind]
		valuesAtIndexes: indexes
		         forKey: key];
	}
	else if ([value isKindOfClass: [NSSet class]])
	{
		[self didChangeValueForKey: key
		           withSetMutation: [self keyValueSetMutationKindForMutationKind: mutationKind]
		              usingObjects: [NSSet setWithArray: objects]];
	}
	else
	{
		[self didChangeValueForKey: key];
	}
}

@end


@implementation NSArray (ETCollection)

+ (void) load
{
	ETApplyCollectionTraits();
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

- (NSArray *) viewpointArray
{
	NSMutableArray *viewpoints = [NSMutableArray arrayWithCapacity: [self count]];

	[self enumerateObjectsUsingBlock: ^(id object, NSUInteger index, BOOL *stop)
	{
		ETIndexValuePair *viewpoint =
			AUTORELEASE([[ETIndexValuePair alloc] initWithIndex: index
			                                              value: object
		                                      representedObject: self]);

		[viewpoints addObject: viewpoint];
	}];
	return viewpoints;
}

- (NSString *) stringValue
{
	return [self descriptionWithLocale: nil];
}

@end

#ifndef GNUSTEP
@implementation NSOrderedSet (ETCollection)

+ (Class) mutableClass
{
	return [NSMutableOrderedSet class];
}

- (BOOL) isOrdered
{
	return YES;
}

- (BOOL) isKeyed
{
	return NO;
}

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
	return [self array];
}

- (NSArray *) viewpointArray
{
	NSMutableArray *viewpoints = [NSMutableArray arrayWithCapacity: [self count]];
	
	[self enumerateObjectsUsingBlock: ^(id object, NSUInteger index, BOOL *stop)
	 {
		 ETIndexValuePair *viewpoint =
		 AUTORELEASE([[ETIndexValuePair alloc] initWithIndex: index
													   value: object
										   representedObject: self]);
		 
		 [viewpoints addObject: viewpoint];
	 }];
	return viewpoints;
}

- (BOOL) containsCollection: (id <ETCollection>)objects
{
	for (id obj in objects)
	{
		if (![self containsObject: obj])
			return NO;
	}
	return YES;
}

@end
#endif

@implementation NSDictionary (ETCollection)

+ (void) load
{
	ETApplyCollectionTraits();
}

/** Returns NSMutableDictionary class. */
+ (Class) mutableClass
{
	return [NSMutableDictionary class];
}

- (BOOL) isKeyed
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
	return [self allValues];
}

- (NSArray *) viewpointArray
{
	NSMutableArray *viewpoints = [NSMutableArray arrayWithCapacity: [self count]];

	[self enumerateKeysAndObjectsUsingBlock: ^(id key, id object, BOOL *stop)
	{
		ETKeyValuePair *viewpoint = [ETKeyValuePair pairWithKey: key value: object];
		[viewpoint setRepresentedObject: self];
		[viewpoints addObject: viewpoint];
	}];
	 return viewpoints;
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

- (NSArray *) arrayRepresentation
{
	NSMutableArray *viewpoints = [NSMutableArray arrayWithCapacity: [self count]];

	[self enumerateKeysAndObjectsUsingBlock: ^(id key, id object, BOOL *stop)
	{
		[viewpoints addObject: [ETKeyValuePair pairWithKey: key value: object]];
	}];
	return viewpoints;
}

@end

@implementation NSSet (ETCollection)

+ (void) load
{
	ETApplyCollectionTraits();
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
	 
- (NSArray *) viewpointArray
{
	NSMutableArray *viewpoints = [NSMutableArray arrayWithCapacity: [self count]];

	[self enumerateObjectsUsingBlock: ^(id object, BOOL *stop)
	{
		ETIndexValuePair *viewpoint =
			AUTORELEASE([[ETIndexValuePair alloc] initWithIndex: ETUndeterminedIndex
			                                              value: object
		                                      representedObject: self]);

		[viewpoints addObject: viewpoint];
	}];
	return viewpoints;
}

- (NSString *)descriptionWithOptions: (NSMutableDictionary *)options
{
	NSMutableString *desc = [NSMutableString string];
	NSString *indent = [options objectForKey: @"kETDescriptionOptionCurrentIndent"];
	if (nil == indent) indent = @"";
	NSString *propertyIndent = [options objectForKey: kETDescriptionOptionPropertyIndent];
	if (nil == propertyIndent) propertyIndent = @"";
	BOOL usesNewLineIndent = ([propertyIndent isEqualToString: @""] == NO);
	NSArray *objects = [self allObjects];
	int n = [objects count];

	[desc appendString: @"{"];

	if (usesNewLineIndent)
	{
  		/* To line up the elements vertically, we increment the indent by the
		   legnth of the opening curly brace */
		indent = [indent stringByAppendingString: @" "];
	}

	for (int i = 0; i < n; i++)
	{
		id obj = [objects objectAtIndex: i];
		BOOL isLast = (i == (n - 1));

		[desc appendString: [obj description]];

		if (isLast)
			break;

		[desc appendString: @", "];
		if (usesNewLineIndent)
		{
			[desc appendString: @"\n"];
			[desc appendString: indent];
		}
	}
	
	[desc appendString: @"}"];

	return desc;
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
	ETApplyCollectionTraits();
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

@implementation NSMutableArray (ETCollectionMutation)

+ (void) load
{
	ETApplyCollectionTraits();
}

/** Inserts the object at the given index in the array.

If the index is ETUndeterminedIndex, the object is added.

See also -[ETCollectionMutation insertObject:atIndex:hint:]. */
- (void) insertObjects: (NSArray *)objects atIndexes: (NSIndexSet *)indexes hints: (NSArray *)hints
{
	NILARG_EXCEPTION_TEST(objects);
	NILARG_EXCEPTION_TEST(indexes);

	if ([objects count] == [indexes count])
	{
		[self insertObjects: objects atIndexes: indexes];
	}
	else if ([indexes isEmpty])
	{
		[self addObjectsFromArray: objects];
	}
	else
	{
		[NSException raise: NSInvalidArgumentException
		            format: @"Mismatched objects and insertion indexes"];
	}
}

/** Removes the object at the given index from the array.

If the index is ETUndeterminedIndex, all occurences of the object matched with 
-isEqual are removed.<br />
When a valid index is provided, the object can be nil.

See also -[ETCollectionMutation removeObject:atIndex:hint:]. */
- (void) removeObjects: (NSArray *)objects atIndexes: (NSIndexSet *)indexes hints: (NSArray *)hints
{
	NILARG_EXCEPTION_TEST(objects);
	NILARG_EXCEPTION_TEST(indexes);

	if ([objects count] == [indexes count])
	{
		[self removeObjectsAtIndexes: indexes];
	}
	else if ([indexes isEmpty])
	{
		[self removeObjectsInArray: objects];
	}
	else
	{
		[NSException raise: NSInvalidArgumentException
		            format: @"Mismatched objects and insertion indexes"];
	}
}

@end

#ifndef GNUSTEP
@implementation NSMutableOrderedSet (ETCollectionMutation)

/** Inserts the object at the given index in the array.
 
 If the index is ETUndeterminedIndex, the object is added.
 
 See also -[ETCollectionMutation insertObject:atIndex:hint:]. */
- (void) insertObject: (id)object atIndex: (NSUInteger)index hint: (id)hint
{
	if (index == ETUndeterminedIndex)
	{
		[self addObject: object];
	}
	else
	{
		[self insertObject: object atIndex: index];
	}
}

/** Removes the object at the given index from the array.
 
 If the index is ETUndeterminedIndex, all occurences of the object matched with
 -isEqual are removed.<br />
 When a valid index is provided, the object can be nil.
 
 See also -[ETCollectionMutation removeObject:atIndex:hint:]. */
- (void) removeObject: (id)object atIndex: (NSUInteger)index hint: (id)hint
{
	NSParameterAssert(object != nil || index != ETUndeterminedIndex);
	
	if (index == ETUndeterminedIndex)
	{
		[self removeObject: object];
	}
	else
	{
		[self removeObjectAtIndex: index];
	}
}

@end
#endif

@implementation NSMutableDictionary (ETCollectionMutation)

+ (void) load
{
	ETApplyCollectionTraits();
}

/** Inserts the object into the receiver for a key which is going to be:

<list>
<item>the hint key if the hint is a key-value pair (see ETKeyValuePair)</item>
<item>else the value returned by -[object insertionKeyForCollection:]</item>
</list>

The index is ignored in all cases.

When a hint is provided, the object to be inserted can be nil.<br />
However the hint value and key must not be nil.

See also -[ETCollectionMutation insertObject:atIndex:hint:]. */
- (void) insertObjects: (NSArray *)objects atIndexes: (NSIndexSet *)indexes hints: (NSArray *)hints
{
	NILARG_EXCEPTION_TEST(objects);
	NILARG_EXCEPTION_TEST(indexes);

	if ([objects count] != [indexes count] && [indexes isEmpty] == NO)
	{
		[NSException raise: NSInvalidArgumentException
		            format: @"Mismatched objects and insertion indexes"];
	}

	if ([[hints firstObject] isKeyValuePair])
	{
		[self addEntriesFromDictionary: [hints dictionaryRepresentation]];
		
		// TODO; Perhaps turn into a debug assertion
		ETAssert([[NSSet setWithArray : (id)[[hints mappedCollection] value]]
			isSubsetOfSet: [NSSet setWithArray: objects]]);
	}
	else
	{
		for (id object in objects)
		{
			[self setObject: object
			         forKey: [object insertionKeyForCollection: self]];
	
		}
	}
}

/** Removes all occurrences of an object in the receiver, unless a a key-value 
pair hint is provided, in this case removes only the object that corresponds to 
the hint key.

The index is ignored in all cases.

When a hint is provided, the object and the hint value can be nil.<br />
However the hint key must not be nil.

See also -[ETCollectionMutation removeObject:atIndex:hint:]. */
- (void) removeObjects: (NSArray *)objects atIndexes: (NSIndexSet *)indexes hints: (NSArray *)hints
{
	NILARG_EXCEPTION_TEST(objects);
	NILARG_EXCEPTION_TEST(indexes);

	if ([objects count] != [indexes count] && [indexes isEmpty] == NO)
	{
		[NSException raise: NSInvalidArgumentException
		            format: @"Mismatched objects and insertion indexes"];
	}

	if ([[hints firstObject] isKeyValuePair])
	{
		[self removeObjectsForKeys: (id)[[hints mappedCollection] key]];
	}
	else
	{
		NSSet *removedValues = [NSSet setWithArray: objects];
		NSMutableSet *removedKeys = [NSMutableSet set];

		[self enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop)
		{
			if ([removedValues member: obj] == obj)
			{
				[removedKeys addObject: key];
			}
		}];
		[self removeObjectsForKeys: [removedKeys allObjects]];
	}
}

@end

@implementation NSMutableSet (ETCollectionMutation)

+ (void) load
{
	ETApplyCollectionTraits();
}

/** Adds the object to the set. 

The index is ignored in all case.

See also -[ETCollectionMutation insertObject:atIndex:hint:]. */
- (void) insertObjects: (NSArray *)objects atIndexes: (NSIndexSet *)indexes hints: (NSArray *)hints
{
	NILARG_EXCEPTION_TEST(objects);
	NILARG_EXCEPTION_TEST(indexes);

	if ([objects count] != [indexes count] && [indexes isEmpty] == NO)
	{
		[NSException raise: NSInvalidArgumentException
		            format: @"Mismatched objects and insertion indexes"];
	}

	[self addObjectsFromArray: objects];
}

/** Removes the object from the set.

The index is ignored in all cases.

See also -[ETCollectionMutation removeObject:atIndex:hint:]. */
- (void) removeObjects: (NSArray *)objects atIndexes: (NSIndexSet *)indexes hints: (NSArray *)hints
{
	NILARG_EXCEPTION_TEST(objects);
	NILARG_EXCEPTION_TEST(indexes);

	if ([objects count] != [indexes count] && [indexes isEmpty] == NO)
	{
		[NSException raise: NSInvalidArgumentException
		            format: @"Mismatched objects and insertion indexes"];
	}

	[self minusSet: [NSSet setWithArray: objects]];
}

@end

// TODO: Both batch insertion and removal into NSMutableIndexSet can become fast,
// if we provide a NSArray class cluster subclass wrapping a NSIndexSet.
// [NSArray initWithIndexSet:] would return it and we would have a private
// method to access the underlying index set (and a special case in each
// primitive batch insertion and removal method).
@implementation NSMutableIndexSet (ETCollectionMutation)

+ (void) load
{
	ETApplyCollectionTraits();
}

/** Adds the number object to the set. 

The index is ignored in all case.

If the object is not a number, raises an NSInvalidArgumentException.

See also -[ETCollectionMutation insertObject:atIndex:hint:]. */
- (void) insertObject: (id)object atIndex: (NSUInteger)index hint: (id)hint
{
	if ([object isNumber])
	{
		[self addIndex: [object unsignedIntegerValue]];
	}
	else
	{
		[NSException raise: NSInvalidArgumentException
		            format: @"Object %@ must be an NSNumber instance to be added to %@ collection", 
		                    object, self];
	}
}

- (void) insertObjects: (NSArray *)objects atIndexes: (NSIndexSet *)indexes hints: (NSArray *)hints
{
	NILARG_EXCEPTION_TEST(objects);
	NILARG_EXCEPTION_TEST(indexes);

	if ([objects count] == [indexes count])
	{
		NSUInteger currentIndex = [indexes firstIndex];
		NSUInteger count = [indexes count];
	 
		for (NSUInteger i = 0; i < count; i++)
		{
			// TODO: Pass the hint
			[self insertObject: [objects objectAtIndex: i]
			           atIndex: currentIndex
			              hint: nil];
			currentIndex = [indexes indexGreaterThanIndex: currentIndex];
		}
	}
	else if ([indexes isEmpty])
	{
		for (id number in objects)
		{
			[self insertObject:  number atIndex: ETUndeterminedIndex hint: nil];
		}
	}
	else
	{
		[NSException raise: NSInvalidArgumentException
		            format: @"Mismatched objects and insertion indexes"];
	}
}

/** Removes the number object from the set.

The index is ignored in all cases.

If the object is not a number, raises an NSInvalidArgumentException.

See also -[ETCollectionMutation removeObject:atIndex:hint:]. */
- (void) removeObject: (id)object atIndex: (NSUInteger)index hint: (id)hint
{
	if ([object isNumber])
	{
		[self removeIndex: [object unsignedIntegerValue]];
	}
	else
	{
		[NSException raise: NSInvalidArgumentException
		            format: @"Object %@ must be an NSNumber instance to be removed from %@ collection", 
		                    object, self];
	}
}

- (void) removeObjects: (NSArray *)objects atIndexes: (NSIndexSet *)indexes hints: (NSArray *)hints
{
	NILARG_EXCEPTION_TEST(objects);
	NILARG_EXCEPTION_TEST(indexes);

	if ([objects count] == [indexes count])
	{
		NSUInteger currentIndex = [indexes firstIndex];
		NSUInteger i, count = [indexes count];
	 
		for (i = 0; i < count; i++)
		{
			// TODO: Pass the hint
			[self removeObject: [objects objectAtIndex: i]
			           atIndex: currentIndex
			              hint: nil];
			currentIndex = [indexes indexGreaterThanIndex: currentIndex];
		}
	}
	else if ([indexes isEmpty])
	{
		for (id number in objects)
		{
			[self removeObject:  number atIndex: ETUndeterminedIndex hint: nil];
		}
	}
	else
	{
		[NSException raise: NSInvalidArgumentException
		            format: @"Mismatched objects and insertion indexes"];
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
to the given one. */
- (NSArray *) arrayByRemovingObject: (id)anObject
{
	NSMutableArray *mutableArray = [NSMutableArray arrayWithArray: self];
	[mutableArray removeObject: anObject];
	/* For safety we return an immutable array */
	return [NSArray arrayWithArray: mutableArray];
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

- (NSString *)descriptionWithOptions: (NSMutableDictionary *)options
{
	NSMutableString *desc = [NSMutableString string];
	NSString *indent = [options objectForKey: @"kETDescriptionOptionCurrentIndent"];
	if (nil == indent) indent = @"";
	NSString *propertyIndent = [options objectForKey: kETDescriptionOptionPropertyIndent];
	if (nil == propertyIndent) propertyIndent = @"";
	BOOL usesNewLineIndent = ([propertyIndent isEqualToString: @""] == NO);
	int n = [self count];

	[desc appendString: @"("];

	if (usesNewLineIndent)
	{
		/* To line up the elements vertically, we increment the indent by the 
		   length of the opening parenthesis */
		indent = [indent stringByAppendingString: @" "];
	}

	for (int i = 0; i < n; i++)
	{
		id obj = [self objectAtIndex: i];
		BOOL isLast = (i == (n - 1));
	
		[desc appendString: [obj description]];

		if (isLast)
			break;

		[desc appendString: @", "];
		if (usesNewLineIndent)
		{
			[desc appendString: @"\n"];
			[desc appendString: indent];
		}
	}
	
	[desc appendString: @")"];

	return desc;
}

@end

@implementation NSDictionary (Etoile)

/** Returns whether the dictionary contains the given key among -allKeys. */
- (BOOL) containsKey: (NSString *)aKey
{
	return ([self objectForKey: aKey] != nil);
}

- (NSString *)descriptionWithOptions: (NSMutableDictionary *)options
{
	NSMutableString *desc = [NSMutableString string];
	NSString *indent = [options objectForKey: @"kETDescriptionOptionCurrentIndent"];
	if (nil == indent) indent = @"";
	NSString *propertyIndent = [options objectForKey: kETDescriptionOptionPropertyIndent];
	if (nil == propertyIndent) propertyIndent = @"";
	BOOL usesNewLineIndent = ([propertyIndent isEqualToString: @""] == NO);
	NSArray *allKeys = [self allKeys];
	int n = [self count];

	[desc appendString: @"{"];

	if (usesNewLineIndent)
	{
		/* To line up the elements vertically, we increment the indent by the 
		   length of the opening parenthesis */
		indent = [indent stringByAppendingString: @" "];
	}

	for (int i = 0; i < n; i++)
	{
		NSString *key = [allKeys objectAtIndex: i];
		id obj = [self objectForKey: key];
		BOOL isLast = (i == (n - 1));
	
		[desc appendFormat: @"%@ = ", key];
		[desc appendString: [obj description]];

		if (isLast)
			break;

		[desc appendString: @"; "];
		if (usesNewLineIndent)
		{
			[desc appendString: @"\n"];
			[desc appendString: indent];
		}
	}
	
	[desc appendString: @"}"];

	return desc;
}

@end

@implementation NSMutableArray (Etoile)

- (void) removeObjectsFromIndex: (NSUInteger)anIndex
{
	[self removeObjectsInRange: NSMakeRange(anIndex, [self count] - anIndex)];
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
