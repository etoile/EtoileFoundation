/*
	Copyright (C) 2013 Quentin Mathe

	Author:  Quentin Mathe <quentin.mathe@gmail.com>
	Date:  May 2013
	License:  Modified BSD  (see COPYING)
 */

#import "Macros.h"
#import "ETCollectionViewpoint.h"
#import "ETCollection+HOM.h"
#import "NSObject+Model.h"
#import "NSObject+Trait.h"
#import "NSString+Etoile.h"
#import "EtoileCompatibility.h"

#pragma GCC diagnostic ignored "-Wprotocol"

@implementation ETCollectionViewpoint

+ (void) initialize
{
	if (self != [ETCollectionViewpoint class])
		return;
	
	[self applyTraitFromClass: [ETCollectionTrait class]];
	[self applyTraitFromClass: [ETMutableCollectionTrait class]];
}

- (BOOL) isIndexValuePairCollection
{
	return ([self isKeyed] == NO);
}

- (void) observeValueForKeyPath: (NSString *)keyPath
                       ofObject: (id)object
                         change: (NSDictionary *)change
                        context: (void *)context
{
	// TODO: Implement
}

- (void) setRepresentedObject: (id)object
{
	[super setRepresentedObject: object];
	ETAssert(object == nil || [self content] != nil);
}

- (void) didUpdate
{
	[[NSNotificationCenter defaultCenter] postNotificationName: ETCollectionDidUpdateNotification
	                                                    object: [self representedObject]];
}

#pragma mark Collection Protocol
#pragma mark -

- (SEL) collectionSetter
{
	return NSSelectorFromString([NSString stringWithFormat: @"set%@:",
		[[self name] stringByCapitalizingFirstLetter]]);
}

- (BOOL) isMutableCollection
{
	return [[self representedObject] respondsToSelector: [self collectionSetter]];
}

- (BOOL) isKeyed
{
	return [[self content] isKeyed];
}

- (BOOL) isOrdered
{
	return [[self content] isOrdered];
}

- (id) content
{
	return [self value];
}

/* This is an internal addition to the collection protocol. */
- (void) setContent: (id <ETCollection>)aCollection
{
	[self setValue: aCollection];
}

- (NSArray *) contentArray
{
	return [[self content] contentArray];
}

- (NSArray *) arrayRepresentation
{
	return ([self isKeyed] ? [(id <ETKeyedCollection>)[self content] arrayRepresentation] : [self contentArray]);
}

- (NSArray *) viewpointArray
{
	NSArray *viewpoints = [[self content] viewpointArray];
	[[viewpoints mappedCollection] setRepresentedObject: self];
	return viewpoints;
}

- (void) insertObject: (id)object atIndex: (NSUInteger)index hint: (id)hint;
{
	ETAssert([self isMutableCollection]);
	ETAssert([[self content] conformsToProtocol: @protocol(NSMutableCopying)]);
	id <ETCollection, ETCollectionMutation> mutableCollection = [(id)[self content] mutableCopy];

	[mutableCollection insertObject: object atIndex: index hint: hint];

	[self setContent: mutableCollection];
}

- (void) removeObject: (id)object atIndex: (NSUInteger)index hint: (id)hint
{
	ETAssert([self isMutableCollection]);
	ETAssert([[self content] conformsToProtocol: @protocol(NSMutableCopying)]);
	id <ETCollection, ETCollectionMutation> mutableCollection = [(id)[self content] mutableCopy];
	
	[mutableCollection removeObject: object atIndex: index hint: hint];
	
	[self setContent: mutableCollection];
}

@end
