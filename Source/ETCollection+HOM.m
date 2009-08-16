/*
	ETCollection+HOM.m

	This module provides map/filter/fold for collections.

	Copyright (C) 2009 Niels Grewe

	Author:  Niels Grewe <niels.grewe@halbordnung.de>
	Date:  June 2009

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
#import "ETCollection.h"
#import "ETCollection+HOM.h"
#import "NSObject+Etoile.h"
#import "Macros.h"


/*
 * Private protocols to collate verbose, often used protocol-combinations.
 */
@protocol ETCollectionObject <NSObject,ETCollection>
@end

@protocol ETMutableCollectionObject <NSObject,ETCollection,ETCollectionMutation>
@end

/*
 * Informal protocol for turning collections into arrays.
 */
@interface NSObject (ETHOMArraysFromCollections)
- (NSArray*) collectionArray;
- (NSArray*) contentsForArrayEquivalent;
@end

/*
 * The following functions will be used by both the ETCollectionHOM categories 
 * and the corresponding proxies.
 */
static inline void ETHOMMapCollectionWithBlockOrInvocationToTargetAsArray(
                            id<NSObject,ETCollection> *aCollection,
                                              id blockOrInvocation,
                                                     BOOL useBlock,
            id<NSObject,ETCollection,ETCollectionMutation> *aTarget,
                                                       BOOL isArrayTarget)
{
	BOOL modifiesSelf = ((id*)aCollection == (id*)aTarget);
	id<NSObject,ETCollection> theCollection = *aCollection;
	id<NSObject,ETCollection,ETCollectionMutation> theTarget = *aTarget;
	NSInvocation *anInvocation = nil;
	// Initialised to get rid of spurious warning from GCC
	SEL selector = @selector(description);

	//Prefetch some stuff to avoid doing it repeatedly in the loop.

	if(NO == useBlock)
	{
		anInvocation = (NSInvocation*)blockOrInvocation;
		selector = [anInvocation selector];
	}

	SEL handlerSelector =
	 @selector(placeObject:inCollection:insteadOfObject:atIndex:havingAlreadyMapped:);
	IMP elementHandler = NULL;
	if ([theCollection respondsToSelector:handlerSelector]
	  && !isArrayTarget)
	{
		elementHandler = [(NSObject*)theCollection methodForSelector: handlerSelector];
	}

	/*
	 * For some collections (such as NSDictionary) the index of the object
	 * needs to be tracked. 
 	 */
	unsigned int objectIndex = 0;
	NSNull *nullObject = [NSNull null];
	NSArray *collectionArray = [(NSObject*)theCollection collectionArray];
	NSMutableArray *alreadyMapped = nil;

	if (modifiesSelf)
	{
		/*
		 * For collection ensuring uniqueness of elements, like
		 * NS(Mutable|Index)Set, the objects that were already mapped need to be
		 * tracked.
		 * It is only useful if a mutable collection is changed.
		 */
		alreadyMapped = [[NSMutableArray alloc] init];
	}

	FOREACHI(collectionArray, object)
	{
		id mapped = nil;
		if(NO == useBlock)
		{
			if([object respondsToSelector:selector])
			{
				[anInvocation invokeWithTarget:object];
				[anInvocation getReturnValue:&mapped];
			}
		}
		#if __has_feature(blocks)
		else
		{
			id(^theBlock)(id) = (id(^)(id))blockOrInvocation;
			mapped = theBlock(object);
		}
		#endif
		if (nil == mapped)
		{
			mapped = nullObject;
		}
		if (modifiesSelf)
		{
			[alreadyMapped addObject: mapped];
		}

		if (elementHandler != NULL)
		{
			elementHandler(theCollection,handlerSelector,
			                              mapped,aTarget,
			                              object,objectIndex,
			                                   alreadyMapped);
		}
		else
		{
			if (modifiesSelf)
			{
				[(NSMutableArray*)theTarget replaceObjectAtIndex: objectIndex
				                                      withObject: mapped];
			}
			else
			{
				[theTarget addObject: mapped];
			}
		}
		objectIndex++;
	}
	if (modifiesSelf)
	{
		[alreadyMapped release];
	}
}

static inline void ETHOMMapCollectionWithBlockOrInvocationToTarget(
                            id<NSObject,ETCollection> *aCollection,
                                              id blockOrInvocation,
                                                     BOOL useBlock,
            id<NSObject,ETCollection,ETCollectionMutation> *aTarget)
{
	ETHOMMapCollectionWithBlockOrInvocationToTargetAsArray(aCollection,
	                                                        blockOrInvocation,
	                                                        useBlock,
	                                                        aTarget,
	                                                        NO);
}

static inline id ETHOMFoldCollectionWithBlockOrInvocationAndInitialValueAndInvert(
                                       id<NSObject,ETCollection>*aCollection,
                                                        id blockOrInvocation,
                                                               BOOL useBlock,
                                                             id initialValue,
                                                            BOOL shallInvert)
{
	id accumulator = initialValue;
	NSInvocation *anInvocation = nil;
	// Initialised to get rid of spurious warning from GCC
	SEL selector = @selector(description);

	if (NO == useBlock)
	{
		anInvocation = (NSInvocation*)blockOrInvocation;
		selector = [anInvocation selector];
	}

	/*
	 * For folding we can safely consider only the content as an array.
	 */
	NSArray *content = [[(NSObject*)*aCollection collectionArray] retain];
	NSEnumerator *contentEnumerator;
	if(NO == shallInvert)
	{
		contentEnumerator = [content objectEnumerator];
	}
	else
	{
		contentEnumerator = [content reverseObjectEnumerator];
	}

	BOOL isCounted = [*aCollection respondsToSelector: @selector(countForObject:)];

	FOREACHE(content, element,id,contentEnumerator)
	{
		id target;
		id argument;
		if(shallInvert==NO)
		{
			target=accumulator;
			argument=element;
		}
		else
		{
			target=element;
			argument=accumulator;
		}

		if(NO == useBlock)
		{
			if([target respondsToSelector:selector])
			{
				[anInvocation setArgument: &argument  atIndex: 2];
				[anInvocation invokeWithTarget:target];
				[anInvocation getReturnValue: &accumulator];
			}
		}
		#if __has_feature(blocks)
		else
		{
			id(^theBlock)(id,id) = (id(^)(id,id))blockOrInvocation;
			accumulator = theBlock(target,argument);
		}
		#endif
	}

	[content release];
	return accumulator;
}

static inline void ETHOMFilterCollectionWithBlockOrInvocationAndTargetAndOriginal(
                                         id<NSObject,ETCollection> *aCollection,
                                                           id blockOrInvocation,
                                                                  BOOL useBlock,
                         id<NSObject,ETCollection,ETCollectionMutation> *target,
                                             id<NSObject,ETCollection> *original)
{
	id<ETCollectionObject> theCollection = (id<ETCollectionObject>)*aCollection;
	id<ETMutableCollectionObject> theTarget = (id<ETMutableCollectionObject>)*target;
	NSInvocation *anInvocation;
	SEL selector;


	if (NO == useBlock)
	{
		anInvocation = (NSInvocation*)blockOrInvocation;
		selector = [anInvocation selector];
	}

	NSArray* content = [[(NSObject*)theCollection collectionArray] retain];
	
	/*
	 * A snapshot of the object is needed at least for NSDictionary. It needs
	 * to know about the key for which the original object was set in order to
	 * remove/add objects correctly. Also other collections might rely on
	 * additional information about the original collection. Still, we don't
	 * want to bother with creating the snapshot if the collection does not
	 * implement the -placeObject... method.
	 */

	id snapshot = nil;

	SEL handlerSelector =
	   @selector(placeObject:atIndex:inCollection:basedOnFilter:withSnapshot:);
	IMP elementHandler = NULL;
	if ([theCollection respondsToSelector: handlerSelector])
	{
		elementHandler = [(NSObject*)*original methodForSelector: handlerSelector];
		if ((id)theCollection != (id)theTarget)
		{
			snapshot = *original;
		}
		else
		{
			if ([theCollection respondsToSelector: @selector(copyWithZone:)])
			{
				snapshot = [(id<NSCopying>)*original copyWithZone: NULL];
			}
		}
	}
	unsigned int objectIndex = 0;
	NSEnumerator *originalEnum = [[(NSObject*)*original collectionArray] objectEnumerator];
	FOREACHI(content, object)
	{
		id originalObject = [originalEnum nextObject];
		long long filterResult = (long long)NO;
		if(NO == useBlock)
		{
			if ([object respondsToSelector: selector])
			{
				[anInvocation invokeWithTarget: object];
				[anInvocation getReturnValue: &filterResult];
			}
		}
		#if __has_feature(blocks)
		else
		{
			BOOL(^theBlock)(id) = (BOOL(^)(id))blockOrInvocation;
			filterResult = (long long)theBlock(object);
		}
		#endif

		if (elementHandler != NULL)
		{
			elementHandler(*original,handlerSelector,
			          originalObject,objectIndex,target,
			      (BOOL)filterResult,snapshot);
		}
		else
		{
			if(((id)theTarget == (id)*original) && (NO == (BOOL)filterResult))
			{
				[theTarget removeObject: originalObject];
			}
			else if (((id)theTarget!=(id)*original) && (BOOL)filterResult)
			{
				[theTarget addObject: originalObject];
			}
		}
		objectIndex++;
	}
	[content release];
}

static inline void ETHOMFilterCollectionWithBlockOrInvocationAndTarget(
                                         id<NSObject,ETCollection> *aCollection,
                                                          id  blockOrInvocation,
                                                                  BOOL useBlock,
                         id<NSObject,ETCollection,ETCollectionMutation> *target)
{
	ETHOMFilterCollectionWithBlockOrInvocationAndTargetAndOriginal(
	                                                      aCollection,
	                                                      blockOrInvocation,
	                                                      useBlock,
	                                                      target,
	                                                      aCollection);
}

static inline id ETHOMFilteredCollectionWithBlockOrInvocation(
                                         id<NSObject,ETCollection> *aCollection,
                                                           id blockOrInvocation,
                                                                  BOOL useBlock)
{
	id<NSObject,ETCollection> theCollection = *aCollection;
	//Cast to id because mutableClass is not yet in any protocols.
	Class mutableClass = [(id)theCollection mutableClass];
	id<ETMutableCollectionObject> mutableCollection = [[mutableClass alloc] init];
	ETHOMFilterCollectionWithBlockOrInvocationAndTarget(aCollection,
	                                                    blockOrInvocation,
	                                                    useBlock,
	             (id<ETCollection,ETCollectionMutation,NSObject>*)&mutableCollection);
	return [mutableCollection autorelease];
}

static inline void ETHOMFilterMutableCollectionWithBlockOrInvocation(
                    id<NSObject,ETCollection,ETCollectionMutation> *aCollection,
                                                           id blockOrInvocation,
                                                                  BOOL useBlock)
{
	ETHOMFilterCollectionWithBlockOrInvocationAndTargetAndOriginal(
	                       (id<NSObject,ETCollection>*)aCollection,
	                                             blockOrInvocation,
	                                                      useBlock,
	                                                   aCollection,
	                                                   aCollection);
}


static inline void ETHOMZipCollectionsWithBlockOrInvocationAndTarget(
                          id<NSObject,ETCollection> *firstCollection,
                         id<NSObject,ETCollection> *secondCollection,
                                                id blockOrInvocation,
                                                       BOOL useBlock,
              id<NSObject,ETCollection,ETCollectionMutation> *target)
{
	BOOL modifiesSelf = ((id*)firstCollection == (id*)target);
	NSInvocation *invocation = nil;
	// Initialised to get rid of spurious warning from GCC
	SEL selector = @selector(description);
	NSArray *contentsFirst = [(NSObject*)*firstCollection collectionArray];
	NSArray *contentsSecond = [(NSObject*)*secondCollection collectionArray];
	if (NO == useBlock)
	{
		invocation = (NSInvocation *)blockOrInvocation;
		selector = [invocation selector];
	}

	SEL handlerSelector =
	 @selector(placeObject:inCollection:insteadOfObject:atIndex:havingAlreadyMapped:);
	IMP elementHandler = NULL;
	if ([*firstCollection respondsToSelector: handlerSelector])
	{
		elementHandler = [(NSObject*)*firstCollection methodForSelector: handlerSelector];
	}

	NSMutableArray *alreadyMapped = nil;
	if (modifiesSelf)
	{
		alreadyMapped = [[NSMutableArray alloc] init];
	}

	NSUInteger objectIndex = 0;
	NSUInteger objectMax = MIN([contentsFirst count],[contentsSecond count]);
	NSNull *nullObject = [NSNull null];

	FOREACHI(contentsFirst,firstObject)
	{
		if (objectIndex >= objectMax)
		{
			break;
		}
		id secondObject = [contentsSecond objectAtIndex: objectIndex];
		id mapped = nil;
		if (NO == useBlock)
		{
			if([firstObject respondsToSelector: selector])
			{
				[invocation setArgument: &secondObject
				                atIndex: 2];
				[invocation invokeWithTarget:firstObject];
				[invocation getReturnValue:&mapped];
			}
		}
		#if __has_feature(blocks)
		else
		{
			id(^theBlock)(id,id) = (id(^)(id,id))blockOrInvocation;
			mapped = theBlock(firstObject,secondObject);
		}
		#endif

		if (nil == mapped)
		{
			mapped = nullObject;
		}

		if (modifiesSelf)
		{
			[alreadyMapped addObject: mapped];
		}

		if (elementHandler != NULL)
		{
			elementHandler(*firstCollection,handlerSelector,
			                         mapped,target,
			                    firstObject,objectIndex,
			                    alreadyMapped);
		}
		else
		{
			if (modifiesSelf)
			{
				[(NSMutableArray*)*target replaceObjectAtIndex: objectIndex
				                                    withObject: mapped];
			}
			else
			{
				[*target addObject: mapped];
			}
		}
	objectIndex++;
	}

	if (modifiesSelf)
	{
		[alreadyMapped release];
	}
}

/*
 * Proxies for higher-order messaging via forwardInvocation.
 */
@interface ETCollectionHOMProxy: NSObject
{
	id<NSObject,ETCollection> collection;
}
@end

@interface ETCollectionMapProxy: ETCollectionHOMProxy
@end

@interface ETCollectionMutationMapProxy: ETCollectionHOMProxy
@end

@interface ETCollectionFoldProxy: ETCollectionHOMProxy
{
	BOOL inverse;
}
@end

@interface ETCollectionMutationFilterProxy: ETCollectionHOMProxy
{
	// Stores a reference to the original collection, even if the actual filter
	// operates on a modified one.
	id<NSObject,ETCollection,ETCollectionMutation> originalCollection;
}
@end

@interface ETCollectionZipProxy: ETCollectionHOMProxy
{
	id<NSObject,ETCollection> secondCollection;
}
@end


@interface ETCollectionMutationZipProxy: ETCollectionZipProxy
@end

@implementation ETCollectionHOMProxy
- (id) initWithCollection:(id<ETCollection,NSObject>) aCollection
{
	SUPERINIT;
	collection = [aCollection retain];
	return self;
}

- (BOOL) respondsToSelector: (SEL)aSelector
{
	NSEnumerator *collectionEnumerator;
	collectionEnumerator = [(NSArray*)collection objectEnumerator];
	FOREACHE(collection,object,id,collectionEnumerator)
	{
		if ([object respondsToSelector: aSelector])
		{
			return YES;
		}
	}
	return [super respondsToSelector: aSelector];
}
- (id) methodSignatureForSelector: (SEL)aSelector
{
	/*
	 * The collection is cast to NSArray because even though all classes
	 * adopting ETCollection provide -objectEnumerator this is not declared.
	 * (See ETColection.h)
	 */
	NSEnumerator *collectionEnumerator;
	collectionEnumerator = [(NSArray*)collection objectEnumerator];
	FOREACHE(collection, object,id,collectionEnumerator)
	{
		if([object respondsToSelector:aSelector])
		{
			return [object methodSignatureForSelector:aSelector];
		}
	}
	return [super methodSignatureForSelector:aSelector];
}

DEALLOC(
	[collection release];
)
@end

@implementation ETCollectionMapProxy
- (void) forwardInvocation:(NSInvocation*)anInvocation
{
	Class mutableClass = [[collection class] mutableClass];
	id<ETMutableCollectionObject> mappedCollection = [[mutableClass alloc] init];
	ETHOMMapCollectionWithBlockOrInvocationToTarget(
	                                    (id<ETCollectionObject>*) &collection,
	                                                             anInvocation,
	                                                                       NO,
	                                                        &mappedCollection);
	[mappedCollection autorelease];
	[anInvocation setReturnValue:&mappedCollection];
}
@end

@implementation ETCollectionMutationMapProxy
- (void) forwardInvocation:(NSInvocation*)anInvocation
{

	ETHOMMapCollectionWithBlockOrInvocationToTarget(
	                                    (id<ETCollectionObject>*) &collection,
	                                                             anInvocation,
	                                                                       NO,
	                              (id<ETMutableCollectionObject>*)&collection);
	//Actually, we don't care for the return value.
	[anInvocation setReturnValue:&collection];
}
@end


@implementation ETCollectionFoldProxy
- (id) initWithCollection: (id<ETCollection,NSObject>)aCollection 
               forInverse: (BOOL)shallInvert
{
	
	if (nil == (self = [super initWithCollection: aCollection]))
	{
		return nil;
	}
	inverse = shallInvert;
	return self;
}

- (void) forwardInvocation:(NSInvocation*)anInvocation
{

	id initialValue;
	[anInvocation getArgument: &initialValue atIndex: 2];
	id foldedValue =
	ETHOMFoldCollectionWithBlockOrInvocationAndInitialValueAndInvert(&collection,
	                                                                 anInvocation,
	                                                                 NO,
	                                                                 initialValue,
                                                                     inverse);
	[anInvocation setReturnValue:&foldedValue];
}
@end


@implementation ETCollectionMutationFilterProxy
- (id) initWithCollection: (id<ETCollection,NSObject>) aCollection
{
	if (nil == (self = [super initWithCollection: aCollection]))
	{
		return nil;
	}
	originalCollection = [aCollection retain];
	return self;
}

- (id) initWithCollection: (id<ETCollection,NSObject>) aCollection
              andOriginal: (id<ETCollection,NSObject>) theOriginal
{
	if (nil == (self = [super initWithCollection: aCollection]))
	{
		return nil;
	}
	originalCollection = [theOriginal retain];
	return self;
}

- (void) forwardInvocation:(NSInvocation*)anInvocation
{
	const char *returnType = [[anInvocation methodSignature] methodReturnType];
	if (0 == strcmp(@encode(BOOL), returnType))
	{
		ETHOMFilterCollectionWithBlockOrInvocationAndTargetAndOriginal(
		           (id<NSObject,ETCollection,ETCollectionMutation>*)&collection,
		                                                           anInvocation,
		                                                                     NO,
		   (id<NSObject,ETCollection,ETCollectionMutation>*)&originalCollection,
		                        (id<NSObject,ETCollection>*)&originalCollection);
		BOOL result = YES;
		[anInvocation setReturnValue: &result];
	}
	else if (0 == strcmp(@encode(id), returnType))
	{
		id<ETMutableCollectionObject> nextCollection = [NSMutableArray array];
		ETHOMMapCollectionWithBlockOrInvocationToTargetAsArray(&collection,
		                                                        anInvocation,
		                                                        NO,
		                        (id<ETMutableCollectionObject>*)&nextCollection,
		                                                        YES);
		id nextProxy = [[[ETCollectionMutationFilterProxy alloc]
		                              initWithCollection: nextCollection
		                                     andOriginal: originalCollection]
													              autorelease];
		[anInvocation setReturnValue: &nextProxy];
	}
	else
	{
		[super forwardInvocation: anInvocation];
	}
}

DEALLOC(
	[originalCollection release];
)
@end

@implementation ETCollectionZipProxy
- (id) initWithCollection: (id<ETCollection,NSObject>) aCollection
            andCollection: (id<ETCollection,NSObject>) anotherCollection
{
	if (nil == (self = [super initWithCollection: aCollection]))
	{
		return nil;
	}
	secondCollection = [anotherCollection retain];
	return self;
}

- (void) forwardInvocation: (NSInvocation *)anInvocation
{
	Class mutableClass = [[collection class] mutableClass];
	id<NSObject,ETCollection,ETCollectionMutation> result = [[[mutableClass alloc] init] autorelease];
	ETHOMZipCollectionsWithBlockOrInvocationAndTarget(&collection,
	                                                  &secondCollection,
	                                                  anInvocation,
	                                                  NO,
	                                                  &result);
	[anInvocation setReturnValue: &result];
}

DEALLOC(
	[secondCollection release];
)
@end

@implementation ETCollectionMutationZipProxy
- (void) forwardInvocation: (NSInvocation *)anInvocation
{
	ETHOMZipCollectionsWithBlockOrInvocationAndTarget(&collection,
	                                            &secondCollection,
	                                                 anInvocation,
	                                                           NO,
	 (id<NSObject,ETCollection,ETCollectionMutation>*)&collection);
	[anInvocation setReturnValue: &collection];
}
@end

@implementation NSArray (ETCollectionHOM)
#include "ETCollection+HOMMethods.m"
@end

@implementation NSDictionary (ETCollectionHOM)
- (void) placeObject: (id)mappedObject
        inCollection: (NSMutableDictionary**)aTarget
     insteadOfObject: (id)originalObject
	         atIndex: (NSUInteger)index
 havingAlreadyMapped: (NSArray*)alreadyMapped
{
	//FIXME: May break if -identifierAtIndex: does not return keys in order.
	[*aTarget setObject: mappedObject forKey: [self identifierAtIndex: index]];
}
- (void) placeObject: (id)anObject
             atIndex: (NSUInteger)index
        inCollection: (NSMutableDictionary**)aTarget
       basedOnFilter: (BOOL)shallInclude
        withSnapshot: (id)snapshot
{
	NSString *key = [(NSDictionary*)snapshot identifierAtIndex: index];
	if (((id)self == (id)*aTarget) && (NO == shallInclude))
	{
		[*aTarget removeObjectForKey: key];
	}
	else if (((id)self != (id)*aTarget) && shallInclude)
	{
		[*aTarget setObject: anObject forKey: key];
	}
}
#include "ETCollection+HOMMethods.m"
@end

@implementation NSSet (ETCollectionHOM)
#include "ETCollection+HOMMethods.m"
@end

@implementation NSIndexSet (ETCollectionHOM)
#include "ETCollection+HOMMethods.m"
@end

@implementation NSMutableArray (ETCollectionHOM)
- (void) placeObject: (id)mappedObject
        inCollection: (NSMutableArray**)aTarget
     insteadOfObject: (id)originalObject
	         atIndex: (NSUInteger)index
 havingAlreadyMapped: (NSArray*)alreadyMapped
{
	if ((id)self == (id)*aTarget)
	{
		[*aTarget replaceObjectAtIndex: index withObject: mappedObject];
	}
	else
	{
		[*aTarget addObject: mappedObject];
	}
}
#include "ETCollectionMutation+HOMMethods.m"
@end

@implementation NSMutableDictionary (ETCollectionHOM)
#include "ETCollectionMutation+HOMMethods.m"
@end

@implementation NSMutableSet (ETCollectionHOM)
- (void) placeObject: (id)mappedObject
        inCollection: (NSMutableSet**)aTarget
     insteadOfObject: (id)originalObject
	         atIndex: (NSUInteger)index
 havingAlreadyMapped: (NSArray*)alreadyMapped
{
	if (((id)self == (id)*aTarget) 
	 && (NO == [alreadyMapped containsObject: originalObject]))
	{
		[*aTarget removeObject: originalObject];
	}
	[*aTarget addObject: mappedObject];
}
#include "ETCollectionMutation+HOMMethods.m"
@end

/*
 * NSCountedSet does not implement the HOM-methods itself, but it does need to
 * override the -placeObject:... method of its superclass. 
 */
@interface NSCountedSet (ETCollectionMapHandler)
@end

@implementation NSCountedSet (ETCOllectionMapHandler)
- (NSArray*) contentsForArrayEquivalent
{
	NSArray *distinctObjects = [self allObjects];
	NSMutableArray *result = [NSMutableArray array];
	FOREACHI(distinctObjects,object)
	{
		for(int i=0; i<[self countForObject:object]; i++)
		{
			[result addObject: object];
		}
	}
	return result;
}

// NOTE: This methods do nothing more than the default implementation. But they
// are needed to override the implementation in NSMutableSet.
- (void) placeObject: (id)mappedObject
        inCollection: (NSCountedSet**)aTarget
     insteadOfObject: (id)originalObject
	         atIndex: (NSUInteger)index
 havingAlreadyMapped: (NSArray*)alreadyMapped
{
	if ((id)self == (id)*aTarget)
	{
		[*aTarget removeObject: originalObject];
	}
	[*aTarget addObject: mappedObject];
}

- (void) placeObject: (id)anObject
             atIndex: (NSUInteger)index
        inCollection: (NSCountedSet**)aTarget
       basedOnFilter: (BOOL)shallInclude
        withSnapshot: (id)snapshot
{
	if (((id) self == (id)*aTarget) && NO == shallInclude)
	{
		[*aTarget removeObject: anObject];
	}
	else if (((id) self != (id)*aTarget) && shallInclude)
	{
		[*aTarget addObject: anObject];
	}
}
@end

@implementation NSMutableIndexSet (ETCollectionHOM)
- (void) placeObject: (id)mappedObject
        inCollection: (NSCountedSet**)aTarget
     insteadOfObject: (id)originalObject
	         atIndex: (NSUInteger)index
 havingAlreadyMapped: (NSArray*)alreadyMapped
{
	if (((id)self == (id)*aTarget) 
	 && (NO == [alreadyMapped containsObject: originalObject]))
	{
		[*aTarget removeObject: originalObject];
	}
	[*aTarget addObject: mappedObject];
}

#include "ETCollectionMutation+HOMMethods.m"
@end
