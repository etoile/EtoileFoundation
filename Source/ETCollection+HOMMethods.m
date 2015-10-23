/*
	Copyright (C) 2009 Niels Grewe

	Date:  June 2009
	License:  Modified BSD (see COPYING)
 */

/*
 * NOTE:
 * This file is included by ETCollection+HOM.m to provide reusable methods for
 * higher-order messaging on collection classes.
 */

- (id)mappedCollection
{
	return [[[ETCollectionMapProxy alloc] initWithCollection: self]
	                                                    autorelease];
}
- (id)leftFold
{
	return [[[ETCollectionFoldProxy alloc] initWithCollection: self
	                                               forInverse: NO]
	                                                   autorelease];
}

- (id)rightFold
{
	return [[[ETCollectionFoldProxy alloc] initWithCollection: self
	                                               forInverse: YES]
	                                                    autorelease];
}

- (id)zippedCollectionWithCollection: (id<NSObject,ETCollection>)aCollection
{
	return [[[ETCollectionZipProxy alloc] initWithCollection: self
	                                           andCollection: (id)aCollection]
	                                                              autorelease];
}

- (NSArray*)collectionArray
{
	return [self collectionArrayAndInfo: NULL];
}

- (id)mappedCollectionWithBlock: (id)aBlock
{
	id<ETMutableCollectionObject> mappedCollection = [[[[self class] mutableClass] alloc] init];
	ETHOMMapCollectionWithBlockOrInvocationToTarget(
	                                       (const id<ETCollectionObject>*) &self,
	                                                                      aBlock,
	                                                                         YES,
	                                                          &mappedCollection);
	return [mappedCollection autorelease];
}

- (id)leftFoldWithInitialValue: (id)initialValue
                     intoBlock: (id)aBlock
{
	return ETHOMFoldCollectionWithBlockOrInvocationAndInitialValueAndInvert(
	                            &self, aBlock, YES, initialValue, NO);
}

- (id)rightFoldWithInitialValue: (id)initialValue
                      intoBlock: (id)aBlock
{
	return ETHOMFoldCollectionWithBlockOrInvocationAndInitialValueAndInvert(
	                            &self, aBlock, YES, initialValue, YES);
}

- (id)zippedCollectionWithCollection: (id<NSObject,ETCollection>)aCollection
                            andBlock: (id)aBlock
{
	id<NSObject,ETCollection,ETCollectionMutation> target = [[[[[(id)self class] mutableClass] alloc] init] autorelease];
	ETHOMZipCollectionsWithBlockOrInvocationAndTarget(&self,
	                                                  (id<ETCollectionObject> *)&aCollection,
	                                                  aBlock,
	                                                  YES,
	                                                  (id<ETMutableCollectionObject> *)&target);
	return target;
}

#if __has_feature(blocks)
- (id)filteredCollectionWithBlock: (BOOL(^)(id))aBlock
                        andInvert: (BOOL)invert
{
	return ETHOMFilteredCollectionWithBlockOrInvocationAndInvert(&self, aBlock, YES, invert);
}
- (id)filteredCollectionWithBlock: (BOOL(^)(id))aBlock
{
	return [self filteredCollectionWithBlock: aBlock
	                               andInvert: NO];
}

- (id)filteredOutCollectionWithBlock: (BOOL(^)(id))aBlock
{
	return [self filteredCollectionWithBlock: aBlock
	                               andInvert: YES];
}
#endif
