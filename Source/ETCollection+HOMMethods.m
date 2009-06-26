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
+ (Class) mutableSubclass
{
	/* 
	 * First, find the class that the ETCollection protocol was declared
	 * upon. This is needed because NSArray and friends are class clusters
	 * which are likely to return some private subclass. Classes conforming
	 * to ETCollectionMutation can be reused. 
	 * This is done by shifting a pair of the collectionClass and its
	 * superClass up through the class hierarchy until collectionClass
	 * conforms to the protocol but superClass doesn't, meaning that
	 * collectionClass is the class actually adopting the protocol.
	 */
	Class collectionClass = self;
	Class superClass = [collectionClass superclass];
	BOOL haveFirstAdoptingClass = NO;
	while((NO == haveFirstAdoptingClass) && ([superClass superclass]!= Nil))
	{
		if((YES == [collectionClass conformsToProtocol:
		                             @protocol(ETCollectionMutation)])||
		   ((YES == [collectionClass conformsToProtocol:
		                             @protocol(ETCollection)]) &&
		    (NO == [superClass conformsToProtocol: 
		                             @protocol(ETCollection)]))
		  )
		{
			/*
		         * Either collectionClass conforms to
		         * ETCollectionMutation, or it derives from a superclass
		         * (superClass) that doesn't conform to ETCollection,
		         * hence collectionClass is the adopting class.
		 	 */
			haveFirstAdoptingClass = YES;
		}
		else
		{
			/*
			 * Shift the class pair one step up the hierarchy and
			 * try again.
			 */
			collectionClass = superClass;
			superClass = [collectionClass superclass];
		}
	}

	//Next, get the first level of subclasses for collectionClasses.
	NSArray *classes = [NSArray arrayWithObject: collectionClass];
	NSMutableArray *nextClasses = [[NSMutableArray alloc] init];
	Class mutableCollectionClass = Nil;
	[classes retain];
	do
	{
		/* Find a class on the present level of subclasses that conforms
		 * to ETCollectionMutation.
		 */
		FOREACHI(classes,class)
		{
			/*
			 * It is needed to check for NSMutableArray explicitly
			 * because it does not adopt the ETCollectionMutation
			 * protocol correctly.
			 */
			if(([class conformsToProtocol:
			                 @protocol(ETCollectionMutation)]
		        || (class == [NSMutableArray class]) 
		        ) &&
			   (Nil == mutableCollectionClass))
			{
				mutableCollectionClass = class;	
			}
		}
		if(Nil == mutableCollectionClass)
		{
			/* 
			 * None of the classes at this level conform to
			 * ETCollectionMutation. A new array containing all
			 * subclasses of the present set of classes will be
			 * constructed.
			 */
			[nextClasses removeAllObjects];
			FOREACHI(classes, class)
			{
				NSArray *subClasses;
				subClasses = [class directSubclasses];
				if([subClasses count] > 0)
				{
					[nextClasses addObjectsFromArray:
					                       subClasses];
				}
			}
		}
	[classes autorelease];
	
	//Set the classes for the next iteration to the subclasses just derived.
	classes = [NSArray arrayWithArray: nextClasses];
	[classes retain];
	} while((Nil == mutableCollectionClass) && ([nextClasses count] > 0));
	[classes release];
	[nextClasses release];
	return mutableCollectionClass;
}

- (Class) mutableSubclass 
{
	return [[self class] mutableSubclass];
}

- (id) mappedCollection
{
	return [[[ETCollectionMapProxy alloc] initWithCollection: self]
	                                                    autorelease];
}
- (id) leftFold
{
	return [[[ETCollectionFoldProxy alloc] initWithCollection:self
	                                               forInverse: NO]
	                                                   autorelease];
}

- (id) rightFold
{
	return [[[ETCollectionFoldProxy alloc] initWithCollection:self
	                                               forInverse: YES]
	                                                    autorelease];
}
#if defined (__clang__)

- (id) mappedCollectionWithBlock: (id(^)(id))aBlock
{
	return ETHOMMappedCollectionWithBoIAsBlock(&self,aBlock,YES);
}
- (id) injectObject: (id)initialValue intoBlock: (id(^)(id,id))aBlock 
          andInvert: (BOOL)shallInvert
{

	return ETHOMFoldCollectionWithBoIAsBlockAndInitialValueAndInvert(
	                       &self, aBlock, YES, initialValue, shallInvert);
}
- (id) injectObject: (id)initialValue intoBlock: (id(^)(id,id))aBlock
{
	return [self injectObject: initialValue intoBlock: aBlock 
                        andInvert: NO];
}

- (id) filteredCollectionWithBlock: (BOOL(^)(id))aBlock
{
	return ETHOMFilteredCollectionWithBoIAsBlock(&self, aBlock, YES);
}
#endif
