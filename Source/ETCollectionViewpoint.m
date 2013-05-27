/*
	Copyright (C) 2013 Quentin Mathe

	Author:  Quentin Mathe <quentin.mathe@gmail.com>
	Date:  May 2013
	License:  Modified BSD  (see COPYING)
 */

#import "Macros.h"
#import "ETCollectionViewpoint.h"
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

- (void) observeValueForKeyPath: (NSString *)keyPath
                       ofObject: (id)object
                         change: (NSDictionary *)change
                        context: (void *)context
{
	// TODO: Implement
}

- (void) setRepresentedObject: (id)object
{
	NSString *name = [self name];
	
	NSParameterAssert(nil != name);
	
	if (nil != [super representedObject])
	{
		// FIXME: [_representedObject removeObserver: self forKeyPath: name];
	}
	[super setRepresentedObject: object];
	
	if (nil != object)
	{
		// FIXME: [object addObserver: self forKeyPath: name options: 0 context: NULL];
		ETAssert([self content] != nil);
	}
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
	return ([self isKeyed] ? [[self content] arrayRepresentation] : [self contentArray]);
}

- (void) insertObject: (id)object atIndex: (NSUInteger)index hint: (id)hint;
{
	ETAssert([self isMutableCollection]);
	id <ETCollection, ETCollectionMutation> mutableCollection = [[self content] mutableCopy];

	[mutableCollection insertObject: object atIndex: index hint: hint];

	[self setContent: mutableCollection];
}

- (void) removeObject: (id)object atIndex: (NSUInteger)index hint: (id)hint
{
	ETAssert([self isMutableCollection]);
	id <ETCollection, ETCollectionMutation> mutableCollection = [[self content] mutableCopy];
	
	[mutableCollection removeObject: object atIndex: index hint: hint];
	
	[self setContent: mutableCollection];
}

@end
