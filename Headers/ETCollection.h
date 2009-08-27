/*
	ETCollection.h
	
	NSObject and collection class additions like a collection protocol.
 
	Copyright (C) 2007 Quentin Mathe
 
	Author:  Quentin Mathe <qmathe@club-internet.fr>
	Date:  September 2007
 
	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions are met:

	* Redistributions of source code must retain the above copyright notice,
	  this list of conditions and the following disclaimer.
	* Redistributions in binary form must reproduce the above copyright notice,
	  this list of conditions and the following disclaimer in the documentation
	  and/or other materials provided with the distribution.
	* Neither the name of the Etoile project nor the names of its contributors
	  may be used to endorse or promote products derived from this software
	  without specific prior written permission.

	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
	AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
	IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
	ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
	LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
	SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
	INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
	CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
	ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
	THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

/* Collection Access and Mutation Protocols */

/* NOTE: -isEmpty, -count and -objectEnumerator could be put in a 
   ETCollectionMixin because their implementation doesn't vary or their value 
   can be extrapolated from -contentArray. */
   
@protocol ETCollection
/** Returns whether the receiveir stores the elements in a sorted order or not. */
- (BOOL) isOrdered;
/** Returns YES when the collection contains no elements, otherwise returns NO. */
- (BOOL) isEmpty;
/** Returns the underlying data structure object holding the content or self 
	when the protocol is adopted by a class which is a content data structure 
	by itself (like NSArray, NSDictionary, NSSet etc.). 
	Content by its very nature is always a collection of other objects. As 
	such, content may hold one or no objects (empty collection).
	When adopted, this method must never return nil. */
- (id) content;
/** Returns the content as a new NSArray-based collection of objects. 
	When adopted, this method must never return nil, you should generally 
	return an empty NSArray instead. */
- (NSArray *) contentArray;
/** Returns an enumerator which can be used as a conveniency to iterate over 
	the elements of the content one-by-one. */
//- (NSEnumerator *) objectEnumerator;
/** Returns the number of elements hold by the receiver. */
//- (unsigned int) count;

// FIXME: Both objectEnumerator and count are problematic because they are 
// declared on NSArray, NSDictionary etc. therefore the compiler complains about
// unimplemented method when the protocol is adopted by a category on the 
// collection. I think the compiler should be smart enough to check whether the
// original class already declares/implements the method or not. 
@end

@protocol ETCollectionMutation
- (void) addObject: (id)object;
- (void) insertObject: (id)object atIndex: (unsigned int)index;
- (void) removeObject: (id)object;
// NOTE: Next method could allow to simplify type checking of added and removed
// objects and provides -addObject: -removeObject: implementation in a mixin.
// For example you could declare elementType as ETLayoutItem to ensure proper 
// type checking. If you check against [self class], in ETLayoutItemGroup you
// won't be able to accept ETLayoutItem instances. So the valid common supertype
// of collection objects must be declared in a superclass if you define subtype
// for collection objects. ETLayer and ETLayoutItemGroup are such subtypes of 
// ETLayoutItem.
//- (NSString *) elementType;
@end


/* Adopted by the following Foundation classes  */

@interface NSArray (ETCollection) <ETCollection>
+ (Class) mutableClass;
- (BOOL) isOrdered;
- (BOOL) isEmpty;
- (id) content;
- (NSArray *) contentArray;
@end

@interface NSDictionary (ETCollection) <ETCollection>
+ (Class) mutableClass;
- (BOOL) isOrdered;
- (BOOL) isEmpty;
- (id) content;
- (NSArray *) contentArray;
- (NSString *) identifierAtIndex: (unsigned int)index;
@end

@interface NSSet (ETCollection) <ETCollection>
+ (Class) mutableClass;
- (BOOL) isOrdered;
- (BOOL) isEmpty;
- (id) content;
- (NSArray *) contentArray;
@end

/** NSCountedSet is a NSMutableSet subclass and thereby inherits the collection 
protocol methods implemented in NSSet(ETCollection). */
@interface NSCountedSet (ETCollection)
+ (Class) mutableClass;
@end

@interface NSIndexSet (ETCollection) <ETCollection>
+ (Class) mutableClass;
- (BOOL) isOrdered;
- (BOOL) isEmpty;
- (id) content;
- (NSArray *) contentArray;
- (NSEnumerator *) objectEnumerator;
@end

@interface NSMutableArray (ETCollectionMutation) <ETCollectionMutation>

@end

@interface NSMutableDictionary (ETCollectionMutation) <ETCollectionMutation>
- (void) addObject: (id)object;
- (void) insertObject: (id)object atIndex: (unsigned int)index;
- (void) removeObject: (id)object;
@end

@interface NSMutableSet (ETCollectionMutation) <ETCollectionMutation>
- (void) addObject: (id)object;
- (void) insertObject: (id)object atIndex: (unsigned int)index;
@end

@interface NSMutableIndexSet (ETCollectionMutation) <ETCollectionMutation>
- (void) addObject: (id)object;
- (void) insertObject: (id)object atIndex: (unsigned int)index;
- (void) removeObject: (id)object;
@end

/* NSArray Extensions */

@interface NSArray (Etoile)

- (id) firstObject;
- (NSArray *) arrayByRemovingObjectsInArray: (NSArray *)anArray;

/* Deprecated (DO NOT USE, WILL BE REMOVED LATER) */

- (NSArray *) objectsMatchingValue: (id)value forKey: (NSString *)key;
- (id) firstObjectMatchingValue: (id)value forKey: (NSString *)key;

@end

