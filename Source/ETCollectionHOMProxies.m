/*
	ETCollectionHOMProxies.m

	Proxy classes to perform higher-order messaging via -forwardInvocation:.

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

#import "ETCollectionHOMProxies.h"
#import "ETCollection.h"
#import "ETCollection+HOM.h"
#import "NSObject+Etoile.h"
#import "Macros.h"

#include "ETCollection+HOMFunctions.m"
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
