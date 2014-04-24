/*
	Copyright (C) 2009 Niels Grewe

	Author:  Niels Grewe <niels.grewe@halbordnung.de>
	Date:  June 2009
	License:  Modified BSD (see COPYING)
 */

/*
 * NOTE:
 * This file is included by ETCollection+HOM.m to provide reusable methods for
 * higher-order messaging on mutable collections.
 */

- (id)map
{
	return [[[ETCollectionMutationMapProxy alloc] initWithCollection: self]
	                                                           autorelease];
}

- (id)filter
{
	return [[[ETCollectionMutationFilterProxy alloc] initWithCollection: self] autorelease];
}

- (id)filterOut
{
	return [[[ETCollectionMutationFilterProxy alloc] initWithCollection: self
	                                                          andInvert: YES] autorelease];
}
- (id)zipWithCollection: (id<NSObject,ETCollection>)aCollection
{
	return [[[ETCollectionMutationZipProxy alloc] initWithCollection: self
	                                                   andCollection: (id)aCollection] autorelease];
}

- (void)mapWithBlock: (id)aBlock
{
	ETHOMMapCollectionWithBlockOrInvocationToTarget(
	                                  (const id<ETCollectionObject>*) &self,
	                                                                  aBlock,
	                                                                     YES,
	                            (const id<ETMutableCollectionObject>*) &self);
}

- (void)zipWithCollection: (id<NSObject,ETCollection>)aCollection
                 andBlock: (id)aBlock
{
	ETHOMZipCollectionsWithBlockOrInvocationAndTarget(&self,&aCollection,
	                                                  aBlock,YES,
	                                                  &self);
}

#if __has_feature(blocks)
- (void)filterWithBlock: (BOOL(^)(id))aBlock
              andInvert: (BOOL)invert
{
	ETHOMFilterMutableCollectionWithBlockOrInvocationAndInvert(&self,aBlock,YES,invert);
}

- (void)filterWithBlock: (BOOL(^)(id))aBlock
{
	[self filterWithBlock: aBlock andInvert: NO];
}

- (void)filterOutWithBlock: (BOOL(^)(id))aBlock
{
	[self filterWithBlock: aBlock andInvert: YES];
}
#endif
