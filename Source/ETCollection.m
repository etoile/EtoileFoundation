/*
    Copyright (C) 2007 Quentin Mathe

    Date:  September 2007
    License: Modified BSD (see COPYING)
 */

#import "ETCollection.h"
#import "ETCollection+HOM.h"
#import "ETIndexValuePair.h"
#import "ETKeyValuePair.h"
#import "NSArray+Etoile.h"
#import "NSObject+Trait.h"
#import "NSObject+Model.h"
#import "Macros.h"
#import "EtoileCompatibility.h"

const NSUInteger ETUndeterminedIndex = NSNotFound;

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
                  hints: (hint != nil ? A(hint) : [NSArray array])];
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
                  hints: (hint != nil ? A(hint) : [NSArray array])];
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

- (void) validateMutationForObjects: (NSArray *)objects
                          atIndexes: (NSIndexSet *)indexes
                              hints: (NSArray *)hints
                          isRemoval: (BOOL)isRemoval
{
    NILARG_EXCEPTION_TEST(objects);
    NILARG_EXCEPTION_TEST(indexes);
    if (hints == nil)
    {
        NILARG_EXCEPTION_TEST(hints);
    }
    BOOL isIndexBasedRemoval = ([objects isEmpty] && isRemoval);

    if ([indexes isEmpty] == NO && [objects count] != [indexes count] && isIndexBasedRemoval == NO)
    {
        [NSException raise: NSInvalidArgumentException
                    format: @"Mismatched mutation objects and indexes"];
    }

    if ([hints isEmpty] == NO)
    {
        if ([objects isEmpty] == NO && [hints count] != [objects count])
        {
            [NSException raise: NSInvalidArgumentException
                        format: @"Mismatched mutation objects and hints"];
        }

        if ([indexes isEmpty] == NO && [hints count] != [indexes count])
        {
            [NSException raise: NSInvalidArgumentException
                        format: @"Mismatched mutation indexes and hints"];
        }
    }
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

#ifdef GNUSTEP
    if ([value isKindOfClass: [NSArray class]] || [value isKindOfClass: [NSPointerArray class]])
#else
    if ([value isKindOfClass: [NSArray class]] 
     || [value isKindOfClass: [NSOrderedSet class]] 
     || [value isKindOfClass: [NSPointerArray class]])
#endif
    {
        [self willChange: [self keyValueChangeForMutationKind: mutationKind]
         valuesAtIndexes: indexes
                  forKey: key];
    }
    else if ([value isKindOfClass: [NSSet class]] || [value isKindOfClass: [NSHashTable class]])
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

#ifdef GNUSTEP
    if ([value isKindOfClass: [NSArray class]] || [value isKindOfClass: [NSPointerArray class]])
#else
    if ([value isKindOfClass: [NSArray class]] 
     || [value isKindOfClass: [NSOrderedSet class]] 
     || [value isKindOfClass: [NSPointerArray class]])
#endif
    {
        [self didChange: [self keyValueChangeForMutationKind: mutationKind]
        valuesAtIndexes: indexes
                 forKey: key];
    }
    else if ([value isKindOfClass: [NSSet class]] || [value isKindOfClass: [NSHashTable class]])
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

// TODO: Move to NSSet+Etoile.m
- (NSString *)descriptionWithOptions: (NSMutableDictionary *)options
{
    NSMutableString *desc = [NSMutableString string];
    NSString *indent = [options objectForKey: @"kETDescriptionOptionCurrentIndent"];
    if (nil == indent) indent = @"";
    NSString *propertyIndent = [options objectForKey: kETDescriptionOptionPropertyIndent];
    if (nil == propertyIndent) propertyIndent = @"";
    BOOL usesNewLineIndent = ([propertyIndent isEqualToString: @""] == NO);
    NSArray *objects = [self allObjects];
    NSInteger n = [objects count];

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
    NSUInteger nbOfIndexes = [self count];
    NSInteger nbOfCopiedIndexes = -1;
    NSUInteger *copiedIndexes = calloc(sizeof(NSUInteger), nbOfIndexes);
    
    nbOfCopiedIndexes = [self getIndexes: copiedIndexes maxCount: nbOfIndexes
        inIndexRange: NULL];
    
    NSAssert2(nbOfCopiedIndexes > -1, @"Invalid number of copied indexes for "
        @"%@, expected value is %d", self, (unsigned int)nbOfIndexes);
    
    // NOTE: i < [self count] prevents the loop to be entered, because negative  
    // int (i) doesn't appear to be inferior to unsigned int (count)
    for (int i = 0; i < nbOfIndexes; i++)
    {
        NSUInteger index = copiedIndexes[i];
            
        [indexes addObject: [NSNumber numberWithUnsignedInteger: index]];
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
    [self validateMutationForObjects: objects atIndexes: indexes hints: hints isRemoval: NO];

    if ([objects count] == [indexes count])
    {
        [self insertObjects: objects atIndexes: indexes];
    }
    else
    {
        [self addObjectsFromArray: objects];
    }
}

/** Removes the object at the given index from the array.

If the index is ETUndeterminedIndex, all occurences of the object matched with 
-isEqual are removed.<br />
When a valid index is provided, the object can be nil.

See also -[ETCollectionMutation removeObject:atIndex:hint:]. */
- (void) removeObjects: (NSArray *)objects atIndexes: (NSIndexSet *)indexes hints: (NSArray *)hints
{
    [self validateMutationForObjects: objects atIndexes: indexes hints: hints isRemoval: YES];

    if ([objects isEmpty] || [objects count] == [indexes count])
    {
        [self removeObjectsAtIndexes: indexes];
    }
    else
    {
        [self removeObjectsInArray: objects];
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
    [self validateMutationForObjects: objects atIndexes: indexes hints: hints isRemoval: NO];

    if ([[hints firstObject] isKeyValuePair])
    {
        [self addEntriesFromDictionary: [hints dictionaryRepresentation]];
        
        // TODO; Perhaps turn into a debug assertion
        ETAssert([[NSSet setWithArray : (id)[(ETKeyValuePair *)[hints mappedCollection] value]]
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
    [self validateMutationForObjects: objects atIndexes: indexes hints: hints isRemoval: YES];

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
    [self validateMutationForObjects: objects atIndexes: indexes hints: hints isRemoval: NO];
    [self addObjectsFromArray: objects];
}

/** Removes the object from the set.

The index is ignored in all cases.

See also -[ETCollectionMutation removeObject:atIndex:hint:]. */
- (void) removeObjects: (NSArray *)objects atIndexes: (NSIndexSet *)indexes hints: (NSArray *)hints
{
    [self validateMutationForObjects: objects atIndexes: indexes hints: hints isRemoval: YES];
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
    [self validateMutationForObjects: objects atIndexes: indexes hints: hints isRemoval: NO];

    for (id number in objects)
    {
        [self insertObject:  number atIndex: ETUndeterminedIndex hint: nil];
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
    [self validateMutationForObjects: objects atIndexes: indexes hints: hints isRemoval: YES];

    for (id number in objects)
    {
        [self removeObject:  number atIndex: ETUndeterminedIndex hint: nil];
    }
}

@end

