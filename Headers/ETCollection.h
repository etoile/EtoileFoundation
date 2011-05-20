/**
	<abstract>NSObject and collection class additions like a collection 
	protocol.</abstract>

	Copyright (C) 2007 Quentin Mathe
 
	Author:  Quentin Mathe <qmathe@club-internet.fr>
	Date:  September 2007
	License: Modified BSD (see COPYING)
 */

#import <Foundation/Foundation.h>

/** Marks an element which shouldn't be considered bound to a particular index 
in an ordered collection or whose index isn't yet determined.<br /> 
For use cases, see ETCollectionMutation.

With EtoileUI, can be used to indicate a drop is not an insertion at precise 
index but a simple drop on. */
extern const NSUInteger ETUndeterminedIndex;

/* Collection Access and Mutation Protocols */

/** @group Collection Protocols */ 
@protocol ETCollection
/** Returns whether the receiveir stores the elements in a sorted order or not. */
- (BOOL) isOrdered;
/** Returns YES when the collection contains no elements, otherwise returns NO. */
- (BOOL) isEmpty;
/** Returns the underlying data structure object holding the content or self 
when the protocol is adopted by a class which is a content data structure by 
itself (like NSArray, NSDictionary, NSSet etc.). 

Content by its very nature is always a collection of other objects. As such, 
content may hold one or no objects (empty collection).

When adopted, this method must never return nil. */
- (id) content;
/** Returns the content as a new NSArray-based collection of objects. 

When adopted, this method must never return nil, you should generally 
return an empty NSArray instead. */
- (NSArray *) contentArray;
/** Returns the number of elements hold by the receiver. */
- (NSUInteger) count;
/** Returns an enumerator which can be used as a conveniency to iterate over 
the elements of the content one-by-one. */
- (NSEnumerator *) objectEnumerator;
/** Returns whether the element is included in the collection. */
- (BOOL) containsObject: (id)anObject;
/** Returns whether every element in the given collection are included in the receiver. */
- (BOOL) containsCollection: (id <ETCollection>)objects;
@end

/** @group Collection Protocols */
@protocol ETCollectionMutation
/** Adds the element to the collection. 

When the collection is ordered, the element is inserted as the last element. */
- (void) addObject: (id)object;
/** Inserts the element at the given index in the collection.

When the collection is not ordered, the index is ignored and the behavior is 
the same than -addObject:. */
- (void) insertObject: (id)object atIndex: (NSUInteger)index;
/** Removes the element from the collection. */
- (void) removeObject: (id)object;
/** Removes the element at the given index from the collection. */
- (void) removeObject: (id)object atIndex: (NSUInteger)index;
- (void) insertObject: (id)object atIndex: (NSUInteger)index hint: (id)hint;
- (void) removeObject: (id)object atIndex: (NSUInteger)index hint: (id)hint;
@end

/** @group Collection Protocols

Any mutable collection can also implement the optional methods listed below.

EtoileUI will use these methods when possible.<br />
Initially you can skip implementing them. Later, they can be implemented to 
speed up the communication between your model collections and the layout items 
that represent them at the UI level. In addition, these methods allows to react 
to batch insertion and removal at the model level (e.g. in reply to a pick and 
drop). 

You are not required to implement every method when a class adopts this informal 
protocol.

When  a collection is received in argument, the collection type can be checked 
to know whether the code needs to convert the collection or not, to remove or 
insert its content in the receiver. In most cases, the code below is a useless 
optimization (the else branch is good enough).

<example>
if ([[aCollection content] isArray] == NO)
{
	[personIvarArray addObjectsFromArray: (NSArray *)aCollection];
}
else
{
	[personIvarArray addObjectsFromArray: [aCollection contentArray]];
}
</example>

See NSObject+Model for other methods such as -isArray. */
@interface NSObject (ETBatchCollectionMutation)
/** Inserts the given collection elements at separate indexes.

When the collection is not ordered, the indexes are ignored.

The element are inserted one-by-one by increasing index value while iterating 
over the indexes. When the greatest index is reached and several elements remain  
to be inserted, they are inserted at that same index.<br />
For a more precise description of the behavior ordered collection should comply 
to, see -[NSArray insertObjects:atIndexes:] in Cocoa documentation. */
- (void) insertCollection: (id <ETCollection>)objects atIndexes: (NSIndexSet *)indexes;
/** Removes the elements from the collection. */
- (void) removesCollection: (id <ETCollection>)objects;
/** Removes the elements at the given indexes from the collection.

You should only implement this method when the collection is ordered. */
- (void) removeObjectAtIndexes: (NSIndexSet *)indexes;
@end

/** @group Collection Protocols */
@interface ETCollectionTrait : NSObject <ETCollection>
@end

/** @group Collection Protocols */
@interface ETMutableCollectionTrait : ETCollectionTrait <ETCollectionMutation>
@end

/* Adopted by the following Foundation classes  */

/** @group Collection Protocols */
@interface NSArray (ETCollection) <ETCollection>
+ (Class) mutableClass;
- (BOOL) isOrdered;
- (BOOL) isEmpty;
- (id) content;
- (NSArray *) contentArray;
@end

/** @group Collection Protocols */
@interface NSDictionary (ETCollection) <ETCollection>
+ (Class) mutableClass;
- (BOOL) isOrdered;
- (BOOL) isEmpty;
- (id) content;
- (NSArray *) contentArray;
- (NSString *) identifierAtIndex: (NSUInteger)index;
@end

/** @group Collection Protocols */
@interface NSSet (ETCollection) <ETCollection>
+ (Class) mutableClass;
- (BOOL) isOrdered;
- (BOOL) isEmpty;
- (id) content;
- (NSArray *) contentArray;
@end

/**  @group Collection Protocols

NSCountedSet is a NSMutableSet subclass and thereby inherits the collection 
protocol methods implemented in NSSet(ETCollection). */
@interface NSCountedSet (ETCollection)
+ (Class) mutableClass;
@end

/** @group Collection Protocols */
@interface NSIndexSet (ETCollection) <ETCollection>
+ (Class) mutableClass;
- (BOOL) isOrdered;
- (BOOL) isEmpty;
- (id) content;
- (NSArray *) contentArray;
- (NSEnumerator *) objectEnumerator;
@end

/** @group Collection Protocols */
@interface NSMutableArray (ETCollectionMutation) <ETCollectionMutation>

@end

/** @group Collection Protocols */
@interface NSMutableDictionary (ETCollectionMutation) <ETCollectionMutation>
- (void) addObject: (id)object;
- (void) insertObject: (id)object atIndex: (NSUInteger)index;
- (void) removeObject: (id)object;
@end

/** @group Collection Protocols */
@interface NSMutableSet (ETCollectionMutation) <ETCollectionMutation>
- (void) insertObject: (id)object atIndex: (NSUInteger)index;
@end


/** @group Collection Protocols */
@interface NSMutableIndexSet (ETCollectionMutation) <ETCollectionMutation>
- (void) addObject: (id)object;
- (void) insertObject: (id)object atIndex: (NSUInteger)index;
- (void) removeObject: (id)object;
@end

/** @group Collection Additions */
@interface NSArray (Etoile)

- (id) firstObject;
- (NSArray *) arrayByRemovingObjectsInArray: (NSArray *)anArray;
- (NSArray *) filteredArrayUsingPredicate: (NSPredicate *)aPredicate
                          ignoringObjects: (NSSet *)ignoredObjects;

/** @taskunit Deprecated */

- (NSArray *) objectsMatchingValue: (id)value forKey: (NSString *)key;
- (id) firstObjectMatchingValue: (id)value forKey: (NSString *)key;

@end

/**
 * @group Collection Additions
 *
 * Extension to NSMutableDictionary for a common case where each key may map to
 * several values.
 */
@interface NSMutableDictionary (DictionaryOfLists)
/**
 * Adds an object for the specific key.  If there is no value for this key, it
 * is added.  If there is an existing value and it is a mutable array, then
 * the object is added to the array.  If it is not a mutable array, the
 * existing object and the new object are both added to a new array, which is
 * set for this key in the dictionary.
 */
- (void)addObject: anObject forKey: aKey;
@end
