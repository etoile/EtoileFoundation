/*
	ETCollection+HOMMethods.m

	Reusable methods for higher-order messaging on collection classes.

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

/*
 * NOTE:
 * This file is included by ETCollection+HOM.m to provide reusable methods for
 * higher-order messaging on collection classes.
 */

- (id) mappedCollection
{
	return [[[ETCollectionMapProxy alloc] initWithCollection: self]
	                                                    autorelease];
}
- (id) leftFold
{
	return [[[ETCollectionFoldProxy alloc] initWithCollection: self
	                                               forInverse: NO]
	                                                   autorelease];
}

- (id) rightFold
{
	return [[[ETCollectionFoldProxy alloc] initWithCollection: self
	                                               forInverse: YES]
	                                                    autorelease];
}
#if defined (__clang__)

- (id) mappedCollectionWithBlock: (id(^)(id))aBlock
{
	id<ETMutableCollectionObject> mappedCollection = [[[[self class] mutableClass] alloc] init];
	ETHOMMapCollectionWithBlockOrInvocationToTarget(
	                                            (id<ETCollectionObject>*) &self,
	                                                                      aBlock,
	                                                          &mappedCollection);
	return [mappedCollection autorelease];
}
- (id) injectObject: (id)initialValue intoBlock: (id(^)(id,id))aBlock 
          andInvert: (BOOL)shallInvert
{

	return ETHOMFoldCollectionWithBlockOrInvocationAndInitialValueAndInvert(
	                               &self, aBlock, initialValue, shallInvert);
}
- (id) injectObject: (id)initialValue intoBlock: (id(^)(id,id))aBlock
{
	return [self injectObject: initialValue intoBlock: aBlock 
                        andInvert: NO];
}

- (id) filteredCollectionWithBlock: (BOOL(^)(id))aBlock
{
	return ETHOMFilteredCollectionWithBlockOrInvocation(&self, aBlock);
}
#endif
