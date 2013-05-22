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

@synthesize representedObject = _representedObject, name = _name;

+ (void) initialize
{
	if (self != [ETCollectionViewpoint class])
		return;
	
	[self applyTraitFromClass: [ETCollectionTrait class]];
	[self applyTraitFromClass: [ETMutableCollectionTrait class]];
}

/** Returns a new autoreleased viewpoint that represents the property
identified by the given name in object. */
+ (id) viewpointWithName: (NSString *)key representedObject: (id)object
{
	return AUTORELEASE([[ETCollectionViewpoint alloc] initWithName: key representedObject: object]);
}

/** <init />
Returns and initializes a new property viewpoint that represents the property
identified by the given name in object. */
- (id) initWithName: (NSString *)key representedObject: (id)object
{
	NSParameterAssert(nil != key);
	SUPERINIT;
	ASSIGN(_name, key);
	[self setRepresentedObject: object];
	return self;
}

- (id) init
{
	return [self initWithName: nil representedObject: nil];
}

- (void) dealloc
{
	[self setRepresentedObject: nil]; /* Will end KVO observation */
	DESTROY(_name);
	[super dealloc];
}

- (id) copyWithZone: (NSZone *)aZone
{
	return [[[self class] alloc] initWithName: [self name] representedObject: _representedObject];
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
	
	if (nil != _representedObject)
	{
		[_representedObject removeObserver: self forKeyPath: name];
	}
	ASSIGN(_representedObject, object);
	
	if (nil != object)
	{
		[object addObserver: self forKeyPath: name options: 0 context: NULL];
		ETAssert([self content] != nil);
	}
}

- (void) didUpdate
{
	[[NSNotificationCenter defaultCenter] postNotificationName: ETCollectionDidUpdateNotification
	                  object: _representedObject];
}

#pragma mark Property Value Coding
#pragma mark -

- (NSArray *) propertyNames
{
	return [[self content] propertyNames];
}

- (id) valueForProperty: (NSString *)aProperty
{
	return [[self content] valueForProperty: aProperty];
}

- (BOOL) setValue: (id)aValue forProperty: (NSString *)aProperty
{
	return [[self content] setValue: aValue forProperty: aProperty];
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
	return [_representedObject respondsToSelector: [self collectionSetter]];
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
	return [_representedObject valueForProperty: [self name]];
}

/* This is an internal addition to the collection protocol. */
- (void) setContent: (id <ETCollection>)aCollection
{
	[_representedObject setValue: aCollection forProperty: [self name]];
}

- (NSArray *) contentArray
{
	return [[self content] contentArray];
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
