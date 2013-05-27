/*
	Copyright (C) 2013 Quentin Mathe

	Author:  Quentin Mathe <quentin.mathe@gmail.com>
	Date:  May 2013
	License:  Modified BSD  (see COPYING)
 */

#import "Macros.h"
#import "ETMutableObjectViewpoint.h"
#import "NSObject+Model.h"
#import "NSObject+Trait.h"
#import "NSString+Etoile.h"
#import "EtoileCompatibility.h"

#pragma GCC diagnostic ignored "-Wprotocol"

@implementation ETMutableObjectViewpoint

@synthesize representedObject = _representedObject, name = _name;

/** Returns a new autoreleased viewpoint that represents the property
identified by the given name in object. */
+ (id) viewpointWithName: (NSString *)key representedObject: (id)object
{
	return AUTORELEASE([[[self class] alloc] initWithName: key representedObject: object]);
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
		// FIXME: [_representedObject removeObserver: self forKeyPath: name];
	}
	ASSIGN(_representedObject, object);
	
	if (nil != object)
	{
		// FIXME: [object addObserver: self forKeyPath: name options: 0 context: NULL];
	}
}

#pragma mark Property Value Coding
#pragma mark -

- (id) value
{
	return [[self representedObject] valueForProperty: [self name]];
}

- (void) setValue: (id)aValue
{
	[[self representedObject] setValue: aValue forProperty: [self name]];
}

- (NSArray *) propertyNames
{
	return [[self value] propertyNames];
}

- (id) valueForProperty: (NSString *)aProperty
{
	return [[self value] valueForProperty: aProperty];
}

- (BOOL) setValue: (id)aValue forProperty: (NSString *)aProperty
{
	return [super setValue: aValue forProperty: aProperty];
}

@end
