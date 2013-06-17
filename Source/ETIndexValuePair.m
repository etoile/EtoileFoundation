/*
	Copyright (C) 2013 Quentin Mathe

	Author:  Quentin Mathe <quentin.mathe@gmail.com>
	Date:  June 2013
	License:  Modified BSD  (see COPYING)
 */

#import "Macros.h"
#import "ETCollection.h"
#import "ETIndexValuePair.h"
#import "ETViewpoint.h"
#import "NSObject+HOM.h"
#import "NSObject+Model.h"
#import "NSObject+Trait.h"
#import "NSString+Etoile.h"
#import "EtoileCompatibility.h"
#include <objc/runtime.h>

#pragma GCC diagnostic ignored "-Wprotocol"

@interface ETIndexValuePair (ETViewpointTraitAliasedMethods)
- (NSArray *) viewpointTraitPropertyNames;
@end

@implementation ETIndexValuePair

@synthesize representedObject = _representedObject, index = _index;

+ (void) initialize
{
	if (self != [ETIndexValuePair class])
		return;
	
	[self applyTraitFromClass: [ETViewpointTrait class]];
	// FIXME: Method aliasing is broken
	/*[self applyTraitFromClass: [ETViewpointTrait class]
	      excludedMethodNames: [NSSet set]
	       aliasedMethodNames: D(@"viewpointTraitPropertyNames", @"propertyNames")];
	ETAssert([self instancesRespondToSelector: @selector(viewpointTraitPropertyNames)]);
	ETAssert([self instancesRespondToSelector: @selector(propertyNames)]);*/
}

/** <init />
Returns and initializes a new viewpoint that represents the element at the
given index in a collection. */
- (id) initWithIndex: (NSUInteger)index value: (id)value representedObject: (id <ETCollection>)object
{
	SUPERINIT;
	_index = index;
	ASSIGN(_value, value);
	[self setRepresentedObject: object];
	return self;
}

- (id) init
{
	return [self initWithIndex: ETUndeterminedIndex value: nil representedObject: nil];
}

- (void) dealloc
{
	DESTROY(_value);
	[self setRepresentedObject: nil]; /* Will end collection update observation */
	[super dealloc];
}

/** Returns YES when both index and value are equal, otherwise returns NO. */
- (BOOL) isEqual: (id)object
{
	if ([object isKindOfClass: [ETIndexValuePair class]] == NO)
		return NO;
	
	return ([self index] == [object index] && [[self value] isEqual: [object value]]);
}

- (NSUInteger)hash
{
	return [self index] ^ [[self value] hash];
}

- (NSString *) description
{
	return [NSString stringWithFormat: @"%lu = %@, %@ - %@", [self index],
		[self value] , [self representedObject], [super description]];
}

/** Returns YES. */
- (BOOL) isIndexValuePair
{
	return YES;
}

+ (BOOL) automaticallyNotifiesObserversForKey:(NSString *)key
{
	/* Automatic KVO notifications are disabled to prevent conflicts if a 
	   class transform is used to support editing immutable objects. */
	return NO;
}

/** Returns <em>value</em> and <em>representedObject</em>. */
- (NSSet *) observableKeyPaths
{
	return S(@"value", @"representedObject");
}

#pragma mark Controlling the Represented Element
#pragma mark -

- (void) setRepresentedObject: (id)object
{	
	if (nil != _representedObject)
	{
		// TODO: End observe ETCollectionDidUpdateNotification
		[self unapplyMutableViewpointTraitForValue: [self value]];
	}
	ASSIGN(_representedObject, object);
	
	if (nil != object)
	{
		// TODO: Begin observe ETCollectionDidUpdateNotification
		[self applyMutableViewpointTraitForValue: [self value]];
	}
}

/** Returns the element at the current index in the represented object. */
- (id) value
{
	return _value;
}

/** Sets the element at the current index in the represented object to be the
given object value. */
- (void) setValue: (id)aValue
{
	id oldValue = RETAIN(_value);
	ASSIGN(_value, aValue);
	[self didChangeValueForOldValue: oldValue];
	RELEASE(oldValue);
}

- (void) didChangeValueForOldValue: (id)oldValue
{
	ETAssert([self index] != ETUndeterminedIndex);

	id collection = [self representedObject];

	if (collection == nil)
		return;
	
	if ([collection isMutableCollection] == NO)
	{
		[NSException raise: NSInternalInconsistencyException
					format: @"Tried to mutate immutable collection %@ through %@",
		                    collection, self];
		return;
	}

	id newValue = [self value];

	[[self representedObject] removeObject: oldValue atIndex: [self index] hint: nil];
	[[self representedObject] insertObject: newValue atIndex: [self index] hint: nil];
}

#pragma mark Property Value Coding
#pragma mark -

- (NSArray *) propertyNames
{
	// FIXME: See +intialize
	//return [[self viewpointTraitPropertyNames] arrayByAddingObjectsFromArray: A(@"index")];

	NSArray *properties = [[self value] propertyNames];
	
	/* If -value is nil, we just return A(@"self", @"value"), there is no need 
	   to return the property description names for the value entity description, 
	   because the value object must exist to access any property. */
	if (properties == nil)
	{
		properties = A(@"self");
	}
	
	return [properties arrayByAddingObjectsFromArray: A(@"value", @"index")];
}

/** Returns the value bound to the given property of -value.
 
This method accesses properties of the represented element. */
- (id) valueForProperty: (NSString *)aProperty
{
	if ([aProperty isEqualToString: @"value"] && [[self value] isViewpoint] == NO)
	{
		return [super valueForProperty: aProperty];
	}
	return [[self value] valueForProperty: aProperty];
}

/** Sets the value bound to the given property of -value.
 
This method accesses properties of the represented property or element. */
- (BOOL) setValue: (id)aValue forProperty: (NSString *)aProperty
{
	if ([aProperty isEqualToString: @"value"] && [[self value] isViewpoint] == NO)
	{
		return [super setValue: aValue forProperty: aProperty];
	}

	if ([self isMutableValue])
	{
		return [[self value] setValue: aValue forProperty: aProperty];
	}
	else
	{
		return [super setValue: aValue forProperty: aProperty];
	}
}

#pragma mark Mutability Trait
#pragma mark -

- (Class) originalClass
{
	return [ETIndexValuePair class];
}

@end


@implementation NSObject (ETIndexValuePair)

- (BOOL) isIndexValuePair
{
	return NO;
}

@end
