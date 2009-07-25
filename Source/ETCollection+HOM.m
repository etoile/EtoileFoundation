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
 * The following functions will be used by both the ETCollectionHOM categories 
 * and the corresponding proxies.
 */
static inline void ETHOMMapCollectionWithBlockOrInvocationToTarget(
                               id<ETCollectionObject> *aCollection,
                                              id blockOrInvocation,
                                                     BOOL useBlock,
                             id<ETMutableCollectionObject> *aTarget)
{
	BOOL modifiesSelf = ((id*)aCollection == (id*)aTarget);
	id<ETCollectionObject> theCollection = *aCollection;
	id<ETMutableCollectionObject> theTarget = *aTarget;
	NSInvocation *anInvocation = nil;
	SEL selector;

	//Prefetch some stuff to avoid doing it repeatedly in the loop.

	if(NO == useBlock)
	{
		anInvocation = (NSInvocation*)blockOrInvocation;
		selector = [anInvocation selector];
	}

	SEL handlerSelector =
	 @selector(placeObject:inCollection:insteadOfObject:atIndex:havingAlreadyMapped:);
	IMP elementHandler = NULL;
	if ([theCollection
	 respondsToSelector:handlerSelector])
	{
		elementHandler = [(NSObject*)theCollection methodForSelector: handlerSelector];
	}

	/*
	 * For some collections (such as NSDictionary) the index of the object
	 * needs to be tracked. 
 	 */
	unsigned int objectIndex = 0;
	NSNull *nullObject = [NSNull null];
	id <ETCollection> initialCollection = theCollection;
	NSMutableArray *alreadyMapped = nil;

	if (modifiesSelf)
	{
		/* 
		 * When we make snapshot when we want to mutate the collection because 
		 * doing so when enumerating it isn't supported. 
		 * All Foundation collection classes implements NSMutableCopying, so it 
		 * is safe to cast the collection to an NSArray and uses -mutableCopy.
		 */
		initialCollection = [[(NSArray *)theCollection mutableCopy] autorelease];
		/*
		 * For collection ensuring uniqueness of elements, like
		 * NS(Mutable|Index)Set, the objects that were already mapped need to be
		 * tracked.
		 * It is only useful if a mutable collection is changed.
		 */
		alreadyMapped = [[NSMutableArray alloc] init];
	}

	/*
	 * All classes adopting ETCollection provide -objectEnumerator methods.
	 * This just isn't declared because the compiler does not check whether
	 * the original classes provide the method when the protocol is adopted
	 * by a category on those classes (see ETCollection.h). Therefore it is
	 * safe to cast the collection to NSArray of which it is known that
	 * there is an -objectEnumerator method.
	 */
	NSEnumerator *collectionEnumerator = [(NSArray*)initialCollection objectEnumerator];
	FOREACHE(initialCollection, object,id,collectionEnumerator)
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
		#if defined (__clang__)
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

static inline id ETHOMFoldCollectionWithBlockOrInvocationAndInitialValueAndInvert(
                                       id<NSObject,ETCollection>*aCollection,
                                                        id blockOrInvocation,
                                                               BOOL useBlock,
                                                             id initialValue,
                                                            BOOL shallInvert)
{
	id accumulator = initialValue;
	NSInvocation *anInvocation = nil;
	SEL selector;

	if (NO == useBlock)
	{
		anInvocation = (NSInvocation*)blockOrInvocation;
		selector = [anInvocation selector];
	}

	/*
	 * For folding we can safely consider only the content as an array.
	 */
	NSArray *content = [[*aCollection contentArray]retain];
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
		NSUInteger count = 1;
		if (isCounted)
		{
			count = [(NSCountedSet*)*aCollection countForObject: element];
		}
		//Repeat to get stuff like counted sets right.
		for(int i = 0;i < count;i++)
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
			#if defined (__clang__)
			else
			{
				id(^theBlock)(id,id) = (id(^)(id,id))blockOrInvocation;
				accumulator = theBlock(target,argument);
			}
			#endif
		}
	}
	[content release];
	return accumulator;
}


//This function will be potentially be inlined twice as often as the others.
static inline void ETHOMFilterCollectionWithBlockOrInvocationAndTarget(
                                         id<NSObject,ETCollection> *aCollection,
                                                          id  blockOrInvocation,
                                                                  BOOL useBlock,
                         id<NSObject,ETCollection,ETCollectionMutation> *target)
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

	NSArray* content = [[theCollection contentArray] retain];
	
	/*
	 * A snapshot of the object is needed at least for NSDictionary. It needs
	 * to know about the key for which the original object was set in order to
	 * remove/add objects correctly. Also other collections might rely on
	 * additional information about the original collection. Still, we don't
	 * want to bother with creating the snapshot if the collection does not
	 * implement the -placeObject... method.
	 */

	id<NSCopying> snapshot = nil;

	SEL handlerSelector =
	   @selector(placeObject:atIndex:inCollection:basedOnFilter:withSnapshot:);
	IMP elementHandler = NULL;
	if ([theCollection respondsToSelector: handlerSelector])
	{
		elementHandler = [(NSObject*)theCollection methodForSelector: handlerSelector];

		if([theCollection respondsToSelector: @selector(copyWithZone:)])
		{
			snapshot = [(id<NSCopying>)theCollection copyWithZone: NULL];
		}
	}
	unsigned int objectIndex = 0;

	FOREACHI(content, object)
	{
		long long filterResult = (long long)NO;

		if(NO == useBlock)
		{
			if([object respondsToSelector: selector])
			{
				[anInvocation invokeWithTarget: object];
				[anInvocation getReturnValue: &filterResult];
			}
		}
		#if defined (__clang__)
		else
		{
			BOOL(^theBlock)(id) = (BOOL(^)(id))blockOrInvocation;
			filterResult = (long long)theBlock(object);
		}
		#endif
		if (elementHandler != NULL)
		{
			elementHandler(theCollection,handlerSelector,
			                  object,objectIndex,target,
								   (BOOL)filterResult,snapshot);
		}
		else
		{
			if(((id)theTarget == (id)theCollection) && (NO == (BOOL)filterResult))
			{
				[theTarget removeObject: object];
			}
			else if (((id)theTarget!=(id)theCollection) && (BOOL)filterResult)
			{
				[theTarget addObject: object];
			}
		}
		objectIndex++;
	}
	[content release];
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
	ETHOMFilterCollectionWithBlockOrInvocationAndTarget(      
	                       (id<NSObject,ETCollection>*)aCollection,
	                                             blockOrInvocation,
	                                                      useBlock,
	                                                   aCollection);
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
@end

@implementation ETCollectionHOMProxy
- (id) initWithCollection:(id<ETCollection,NSObject>) aCollection
{
	SUPERINIT;
	collection = [aCollection retain];
	return self;
}

- (id) methodSignatureForSelector:(SEL)aSelector
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

- (void) forwardInvocation:(NSInvocation*)anInvocation
{

	ETHOMFilterMutableCollectionWithBlockOrInvocation(
	           (id<NSObject,ETCollection,ETCollectionMutation>*)&collection,
	                                                           anInvocation,
	                                                                     NO);
	//Actually, we don't care for the return value.
	[anInvocation setReturnValue:&collection];
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
- (void) placeObject: (id)mappedObject
        inCollection: (NSCountedSet**)aTarget
     insteadOfObject: (id)originalObject
	         atIndex: (NSUInteger)index
 havingAlreadyMapped: (NSArray*)alreadyMapped
{
	NSUInteger count = [self countForObject: originalObject];
	for(int i=0;i<count;i++)
	{
		if ((id)self == (id)*aTarget) 
		{
			[*aTarget removeObject: originalObject];
		}
		[*aTarget addObject: mappedObject];
	}
}
- (void) placeObject: (id)anObject
             atIndex: (NSUInteger)index
        inCollection: (NSCountedSet**)aTarget
       basedOnFilter: (BOOL)shallInclude
        withSnapshot: (id)snapshot
{
	NSUInteger count = [self countForObject: anObject];
	for(int i=0;i<count;i++)
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
