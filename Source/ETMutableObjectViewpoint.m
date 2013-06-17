/*
	Copyright (C) 2013 Quentin Mathe

	Author:  Quentin Mathe <quentin.mathe@gmail.com>
	Date:  May 2013
	License:  Modified BSD  (see COPYING)
 */

#import "Macros.h"
#import "ETCollection.h"
#import "ETMutableObjectViewpoint.h"
#import "NSObject+HOM.h"
#import "NSObject+Model.h"
#import "NSObject+Trait.h"
#import "NSString+Etoile.h"
#import "EtoileCompatibility.h"

#pragma GCC diagnostic ignored "-Wprotocol"

@implementation ETMutableObjectViewpoint

@synthesize representedObject = _representedObject, name = _name;

+ (void) initialize
{
	if (self != [ETMutableObjectViewpoint class])
		return;
	
	[self applyTraitFromClass: [ETViewpointTrait class]];
}

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

+ (BOOL) automaticallyNotifiesObserversForKey:(NSString *)key
{
	/* -setValue: changes the represented object but not the viewpoint state.
	   The viewpoint synthesizes a value change notification if a represented 
	   object property changes (see -observeValueForKeyPath:ofObject:change:context:).
	   If other objects observe the viewpoint, these objects receives a KVO 
	   notification for -value. */
	if ([key isEqualToString: @"value"])
	{
		return NO;
	}
	else
	{
		return [super automaticallyNotifiesObserversForKey: key];
	}
}

- (NSSet *) observableKeyPaths
{
	return S(@"value", @"representedObject");
}

// NOTE: By keeping track of the observer, we could do...
// [observer observeValueForKeyPath: @"value" ofObject: self change: change
//	context: NULL]
- (void) observeValueForKeyPath: (NSString *)keyPath
                       ofObject: (id)object
                         change: (NSDictionary *)change
                        context: (void *)context
{
	NSParameterAssert([keyPath isEqualToString: [self name]]);
	
	if (_isSettingValue)
		return;
	
	ETLog(@"Will forward KVO property %@ change", keyPath);

	// NOTE: Invoking just -didChangeValueForKey: won't work
	[self willChangeValueForKey: @"value"];
	[self didChangeValueForKey: @"value"];
}

- (NSString *) observedKeyPath
{
	return ([[self name] isEqualToString: @"self"] ? nil : [self name]);
}

- (BOOL) isObservableObject: (id)anObject
{
	return ([anObject isKindOfClass: [NSSet class]] == NO
		 && [anObject isKindOfClass: [NSArray class]] == NO);
}

- (void) setRepresentedObject: (id)object
{
	NSString *name = [self name];
	
	NSParameterAssert(nil != name);
	
	if (nil != _representedObject)
	{
		if ([self observedKeyPath] != nil && [self isObservableObject: _representedObject])
		{
			[_representedObject removeObserver: self forKeyPath: [self observedKeyPath]];
		}
		[self unapplyMutableViewpointTraitForValue: [self value]];
	}
	ASSIGN(_representedObject, object);
	
	if (nil != object && [[self observedKeyPath] hasPrefix: @"self"] == NO)
	{
		if ([self observedKeyPath] != nil && [self isObservableObject: _representedObject])
		{
			NSUInteger options = (NSKeyValueObservingOptionNew| NSKeyValueObservingOptionOld);
			[object addObserver: self forKeyPath: [self observedKeyPath] options: options context: NULL];
		}
		[self applyMutableViewpointTraitForValue: [self value]];
	}
}

#pragma mark Property Value Coding
#pragma mark -

/** Returns whether the -value object properties should be accessed through 
Key-Value-Coding rather than Property-Value-Coding.

By default, returns NO.

When YES is returned, -valueForProperty: accepts any key (e.g. a dictionary key), 
otherwise only a property exposed by -propertyNames is valid.<br />

When the KVC use is turned on, -value might start to return a non-nil value 
because the property value which was not exposed with PVC can be now retrieved 
with KVC. */
- (BOOL) usesKeyValueCodingForAccessingValueProperties
{
	return _usesKeyValueCodingForAccessingValueProperties;
}

/** Sets whether the represented object properties should be accessed
through Key-Value-Coding rather than Property-Value-Coding.

See -usesKeyValueCodingForAccessingValueProperties. */
- (void) setUsesKeyValueCodingForAccessingValueProperties: (BOOL)usesKVC
{
	_usesKeyValueCodingForAccessingValueProperties = usesKVC;
}

- (void) reportPropertyAccessFailure: (BOOL)hasFoundProperty
{
	if (hasFoundProperty)
		return;

	[NSException raise: NSInvalidArgumentException
				format: @"Found no property %@ among -propertyNames of %@ in %@.\n"
	                     "If you use an entity description for %@, you should "
	                     "add a property description, otherwise just override "
	                     "-propertyNames to include %@.",
	                     [self name], [[self representedObject] primitiveDescription],
	                     self, [[self representedObject] primitiveDescription], [self name]];
}

/** Returns the value of the property. */
- (id) value
{
	if ([[self representedObject] requiresKeyValueCodingForAccessingProperties])
	{
		return [[self representedObject] valueForKey: [self name]];
	}
	else /* Use PVC by default */
	{
		return [[self representedObject] valueForProperty: [self name]];
	}
}

/** Sets the value of the property to be the given object value. */
- (void) setValue: (id)objectValue
{
	_isSettingValue = YES;
	if ([[self representedObject] requiresKeyValueCodingForAccessingProperties])
	{
		[[self representedObject] setValue: objectValue forKey: [self name]];
	}
	else /* Use PVC by default */
	{
		[self reportPropertyAccessFailure: [[self representedObject] setValue: objectValue
		                                                          forProperty: [self name]]];
	}
	_isSettingValue = NO;
}

- (NSArray *) propertyNames
{
	// FIXME: See +intialize
	//return [[self viewpointTraitPropertyNames] arrayByAddingObjectsFromArray: A(@"value")];

	NSArray *properties = [[self value] propertyNames];
	
	/* If -value is nil, we just return A(@"self", @"value"), there is no need 
	   to return the property description names for the value entity description, 
	   because the value object must exist to access any property. */
	if (properties == nil)
	{
		properties = A(@"self");
	}
	
	return [properties arrayByAddingObjectsFromArray: A(@"value")];
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
	return [ETMutableObjectViewpoint class];
}

@end
