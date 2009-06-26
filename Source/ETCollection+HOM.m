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
 * The following functions will be used by both the ETCollectionHOM categories 
 * and the corresponding proxies.
 */
static inline id ETHOMMappedCollectionWithBoIAsBlock(
                            id<NSObject,ETCollection>*aCollection,
                                             id blockOrInvocation,
                                                     BOOL isBlock)
{
	NSInvocation *anInvocation = nil;
	SEL selector;
	id<NSObject,ETCollection> theCollection = *aCollection;
	Class mutableCollectionClass;
	//Cast to NSArray because mutableClass is not yet in any protocol.
	mutableCollectionClass = [(NSArray*)theCollection mutableSubclass];
	id<ETCollectionMutation> mappedCollection;
	mappedCollection = [[mutableCollectionClass alloc] init];

	/*
	 * For some collections (such as NSDictionary) the index of the object
	 * needs to be tracked. 
 	 */
	unsigned int objectIndex = 0;

	/*
	 * All classes adopting ETCollection provide -objectEnumerator methods.
	 * This just isn't declared because the compiler does not check whether
	 * the original classes provide the method when the protocol is adopted
	 * by a category on those classes (see ETCollection.h). Therefore it is
	 * safe to cast the collection to NSArray of which it is known that
	 * there is an -objectEnumerator method.
	 */
	NSEnumerator *collectionEnumerator;
	collectionEnumerator = [(NSArray*)theCollection objectEnumerator];
	FOREACHW(theCollection, object,id,collectionEnumerator)
	{
		id mapped = nil;
		if(NO == isBlock)
		{
			NSInvocation *anInvocation;
			anInvocation = (NSInvocation*)blockOrInvocation;
			SEL selector = [anInvocation selector];
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
			mapped = [NSNull null];
		}
		
		//Special handling for basic ETCollection adopting subclasses.
		if([[theCollection class] isSubclassOfClass:
		                                          [NSDictionary class]])
		{
			/* 
			 * FIXME: -identifierAtIndex: uses -allKeys which is not
			 * guaranteed to return the keys in any particular
			 * order.
			 */
			NSString *key = [(NSDictionary*)theCollection
			                 identifierAtIndex:objectIndex];
			[(NSMutableDictionary*)mappedCollection 
			                  setObject: mapped forKey:key];
		}
		else if ([[theCollection class] isSubclassOfClass:
		                                  [NSCountedSet class]])
		{
			NSUInteger count = [(NSCountedSet*)theCollection
			                                 countForObject:object];
			int i;
			for(i=0;i<count;i++)
			{
				[mappedCollection addObject:mapped];
			}
		}
		else if ([[theCollection class] isSubclassOfClass:
		                                  [NSIndexSet class]])
		{
			if([mapped respondsToSelector:
			             @selector(unsignedIntegerValue)])
			{
				[(NSMutableIndexSet*)mappedCollection
				addIndex: [mapped unsignedIntegerValue]];
			}
		}
		else
		{
			[mappedCollection addObject:mapped];
		}
		objectIndex++;
	}
	return [(NSObject*)mappedCollection autorelease];
}
static inline void ETHOMMapMutableCollectionWithBoIAsBlock(
       id<NSObject,ETCollection,ETCollectionMutation>*aCollection,
                                             id blockOrInvocation,
                                                    BOOL isBlock)
{
	/*
	 * For some collections (such as NSDictionary) the index of the object
	 * needs to be tracked. 
 	 */
	unsigned int objectIndex = 0;

	/*
	 * Also, for collections enforcing uniqueness of elements
	 * (NSMutable*Set), we need to keep track of elements which were already
	 * mapped.
	 */
	NSMutableArray* alreadyMapped = [[NSMutableArray alloc]init]; 

	NSArray* content = [*aCollection contentArray];
	id<NSObject,ETCollection,ETCollectionMutation> theCollection;
	theCollection = *aCollection;
	[content retain];
	FOREACHI(content, object)
	{
		id mapped = nil;
		if(NO == isBlock)
		{
			NSInvocation *anInvocation;
			anInvocation = (NSInvocation*)blockOrInvocation;
			SEL selector = [anInvocation selector];
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
			mapped = [NSNull null];
		}
		[alreadyMapped addObject: mapped];	

		if([[theCollection class] isSubclassOfClass: 
		                                   [NSMutableDictionary class]])
		{
			/* 
			 * FIXME: -identifierAtIndex: uses -allKeys which is not
			 * guaranteed to return the keys in any particular
			 * order.
			 */
			NSString *key = [(NSDictionary*)theCollection
			                 identifierAtIndex:objectIndex];
			[(NSMutableDictionary*)theCollection 
			                  setObject: mapped forKey:key];
		}
		else if ([[theCollection class] isSubclassOfClass:
		                                  [NSMutableSet class]])
		{
			int i,count;
			BOOL isCounted;
			if([theCollection respondsToSelector:
			                   @selector(countForObject:)])
			{
				count = [(NSCountedSet*)theCollection 
				                countForObject: object];
				isCounted = YES;
			}
			else
			{
				count = 1;
				isCounted = NO;
			}
			for(i=0;i<count;i++)
			{
				if((NO == [alreadyMapped containsObject: 
				                                    object]) ||
				   (YES == isCounted))
				{
					[theCollection removeObject: object];
				}
				[theCollection addObject: mapped];
			}
		}
		else if ([[theCollection class] isSubclassOfClass:
		                                 [NSMutableIndexSet class]])
		{
			if([mapped respondsToSelector:
			             @selector(unsignedIntegerValue)])
			{
				if([alreadyMapped containsObject: object] == NO)
				{
					[(NSMutableIndexSet*)theCollection
					  removeIndex: 
				             [object unsignedIntegerValue]];
				}
				[(NSMutableIndexSet*)theCollection
				    addIndex: [mapped unsignedIntegerValue]];
			}
		}
		else
		{
			[(NSMutableArray*)theCollection replaceObjectAtIndex: 
			                                          objectIndex
			                                    withObject: mapped];
		}
		objectIndex++;
	}
	[alreadyMapped release];
	[content release];
}

static inline id ETHOMFoldCollectionWithBoIAsBlockAndInitialValueAndInvert(
                                       id<NSObject,ETCollection>*aCollection,
                                                        id blockOrInvocation,
                                                                BOOL isBlock,
                                                             id initialValue,
                                                            BOOL shallInvert)
{
	NSInvocation *anInvocation = nil;
	SEL selector;
	id accumulator = initialValue;

	/*
	 * For folding we can safely consider only the content as an array.
	 */
	NSArray *content = [*aCollection contentArray];
	[content retain];
	NSEnumerator *contentEnumerator;
	if(NO == shallInvert)
	{
		contentEnumerator = [content objectEnumerator];
	}
	else
	{
		contentEnumerator = [content reverseObjectEnumerator];
	}

	FOREACHW(content, element,id,contentEnumerator)
	{
		NSUInteger i, count;
		count = 1;
		if ([*aCollection respondsToSelector:
		                                   @selector(countForObject:)])
		{
			count = [(NSCountedSet*)*aCollection countForObject:
			                                               element];
		}
		//Repeat to get stuff like counted sets right.
		for(i = 0;i < count;i++)
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

			if(NO == isBlock)
			{
				NSInvocation *anInvocation;
				anInvocation = (NSInvocation*)blockOrInvocation;
				SEL selector = [anInvocation selector];
				if([target respondsToSelector:selector])
				{
					[anInvocation setArgument: &argument 
					                  atIndex: 2];
					[anInvocation invokeWithTarget:target];
					[anInvocation getReturnValue:
					                         &accumulator];
				}
			}
			#if defined (__clang__)
			else
			{
				id(^theBlock)(id,id) = 
				                (id(^)(id,id))blockOrInvocation;
				accumulator = theBlock(target,argument);
			}
			#endif
		}
	}
	[content release];
	return accumulator;
}


//This function will be potentially be inlined twice as often as the others.
static inline void ETHOMFilterCollectionWithBoIAsBlockAndTarget(
                                         id<NSObject,ETCollection> *aCollection,
                                                          id  blockOrInvocation,
                                                                   BOOL isBlock,
                         id<NSObject,ETCollection,ETCollectionMutation> *target)
{
	id<NSObject,ETCollection,ETCollectionMutation> theCollection,theTarget;
	theCollection =
	           (id<NSObject,ETCollection,ETCollectionMutation>)*aCollection;
	theTarget = (id<NSObject,ETCollection,ETCollectionMutation>)*target;

	NSArray* content = [theCollection contentArray];
	[content retain];
	
	/*
	 * For NSDictionaries the index of the object needs to be tracked.
	 * Additionally, if a NSMutableDictionary is being manipulated, a
	 * snapshot of the keys is needed.
	 */	
	NSArray* keys;
	unsigned int objectIndex = 0;
	if([theCollection respondsToSelector: @selector(allKeys)])
	{
		/*
		 * FIXME: -allKeys is not guaranteed to return the keys in the
		 * correct order.
		 */
		keys = [(NSDictionary*)theCollection allKeys];
	}
	
	FOREACHI(content, object)
	{
		int i, count;
		count = 1;
		
		long long filterResult;
		filterResult = (long long)NO;
		if(NO == isBlock)
		{
			NSInvocation *theInvocation;
			SEL theSelector;
			theInvocation = (NSInvocation*)blockOrInvocation;
			theSelector = [theInvocation selector];
			if([object respondsToSelector: theSelector])
			{
				[theInvocation invokeWithTarget: object];
				[theInvocation getReturnValue: &filterResult];
			}
		}
		#if defined (__clang__)
		else
		{
			BOOL(^theBlock)(id) = (BOOL(^)(id))blockOrInvocation;
			filterResult = (long long)theBlock(object);
		}
		#endif
		if ([theCollection respondsToSelector:
		                                  @selector(countForObject:)])
		{
			count = [(NSCountedSet*)theCollection countForObject:
			                                               object];
		}
		for(i=0;i<count;i++)
		{
			if([[theCollection class] isSubclassOfClass: 
			                           [NSMutableDictionary class]])
			{
				NSString *key = [keys
				                     objectAtIndex:objectIndex];
				if((theTarget==theCollection) &&
			           (NO == (BOOL)filterResult))
				{
					/*
					 * Matches when manipulating a mutable
					 * collection.
					 */
					[(NSMutableDictionary*)theTarget 
				                  removeObjectForKey:key];
				}
				else if ((theTarget!=theCollection) && 
				         (YES == (BOOL)filterResult))
				{
					/*
					 * Matches if the collection being
					 * filtered is immutable and the result
					 * is held by a different collection.
					 */
					[(NSMutableDictionary*)theTarget
				                  setObject: object forKey:key];
				}
				/*
				 * NOTE: It is safe to ignore all other cases
				 * since they represent the objects that
				 * according to the filtering method should not 
				 * be removed from the collection filtered
				 * (if mutable) or added to the collection
				 * holding the filtered objects, respectively.
				 */
			}
			else
			{
				if((theTarget == theCollection) &&
				   (NO == (BOOL)filterResult))
				{
					[theTarget removeObject: object];
				}
				else if ((theTarget!=theCollection) && 
				         (YES == (BOOL)filterResult))
				{
					[theTarget addObject: object];
				}
			}
		}
		objectIndex++;
	}
	[content release];
}
static inline id ETHOMFilteredCollectionWithBoIAsBlock(
                                         id<NSObject,ETCollection> *aCollection,
                                                           id blockOrInvocation,
                                                                   BOOL isBlock)
{
	id<NSObject,ETCollection> theCollection;
	theCollection = *aCollection;
	//Cast to NSArray because mutableClass is not yet in any protocols.
	Class mutableSubclass = [(NSArray*)theCollection mutableSubclass];
	id<NSObject,ETCollectionMutation> mutableCollection;
	mutableCollection = [[mutableSubclass alloc] init];
	ETHOMFilterCollectionWithBoIAsBlockAndTarget(               aCollection,
	                                                      blockOrInvocation,
	                                                                isBlock,
	   (id<NSObject,ETCollection,ETCollectionMutation>*)&mutableCollection);
	return [mutableCollection autorelease];
}



static inline void ETHOMFilterMutableCollectionWithBoIAsBlock(
                    id<NSObject,ETCollection,ETCollectionMutation> *aCollection,
                                                           id blockOrInvocation,
                                                                   BOOL isBlock)
{
	ETHOMFilterCollectionWithBoIAsBlockAndTarget(      
	                       (id<NSObject,ETCollection>*)aCollection,
	                                             blockOrInvocation,
	                                                       isBlock,
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
	SELFINIT;
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
	FOREACHW(collection, object,id,collectionEnumerator)
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

	id<ETCollection> mappedCollection;
	mappedCollection = ETHOMMappedCollectionWithBoIAsBlock(&collection,
	                                                       anInvocation,
	                                                                 NO);
	[anInvocation setReturnValue:&mappedCollection];
}
@end

@implementation ETCollectionMutationMapProxy
- (void) forwardInvocation:(NSInvocation*)anInvocation
{

	ETHOMMapMutableCollectionWithBoIAsBlock(
	           (id<NSObject,ETCollection,ETCollectionMutation>*)&collection,
	                                                           anInvocation,
	                                                                    NO);
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

	id foldedValue;
	id initialValue;
	[anInvocation getArgument: &initialValue atIndex: 2];
	foldedValue = 
	ETHOMFoldCollectionWithBoIAsBlockAndInitialValueAndInvert(&collection,
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

	ETHOMFilterMutableCollectionWithBoIAsBlock(
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
#include "ETCollection+HOMMethods.m"
@end

@implementation NSSet (ETCollectionHOM)
#include "ETCollection+HOMMethods.m"
@end

@implementation NSIndexSet (ETCollectionHOM)
#include "ETCollection+HOMMethods.m"
@end

@implementation NSMutableArray (ETCollectionHOM)
#include "ETCollectionMutation+HOMMethods.m"
@end

@implementation NSMutableDictionary (ETCollectionHOM)
#include "ETCollectionMutation+HOMMethods.m"
@end

@implementation NSMutableSet (ETCollectionHOM)
#include "ETCollectionMutation+HOMMethods.m"
@end

@implementation NSMutableIndexSet (ETCollectionHOM)
#include "ETCollectionMutation+HOMMethods.m"
@end
