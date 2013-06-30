/*
	Copyright (C) 2013 Quentin Mathe

	Author:  Quentin Mathe <quentin.mathe@gmail.com>
	Date:  May 2013
	License:  Modified BSD  (see COPYING)
 */

#import "Macros.h"
#import "ETUnionViewpoint.h"
#import "NSObject+Model.h"
#import "NSObject+Trait.h"
#import "NSString+Etoile.h"
#import "EtoileCompatibility.h"

@implementation ETUnionViewpoint

@synthesize contentKeyPath = _contentKeyPath;

- (id) initWithName: (NSString *)key representedObject: (id)object
{
	_observations =	[NSMutableDictionary new];

	self = [super initWithName: key representedObject: object];
	if (self == nil)
		return nil;

	return self;
}

- (void) dealloc
{
	/* Stop all the observations */
	[self setRepresentedObject: nil];
	DESTROY(_contentKeyPath);
	DESTROY(_observations);
	[super dealloc];
}

- (NSString *) accessedKeyPath
{
	if ([self name] == nil || [[self name] length] == 0)
		return nil;

	if ([self contentKeyPath] == nil)
	{
		return [self name];
	}
	return [[self name] stringByAppendingFormat: @".%@", [self contentKeyPath]];
}

- (id) accessedObjectForMutation
{
	NSString *accessedKeyPath = [self accessedKeyPath];

	if (accessedKeyPath == nil)
		return [self representedObject];

	NSArray *keyPathComponents = [accessedKeyPath componentsSeparatedByString: @"."];
	NSUInteger nbOfComponents = [keyPathComponents count];

	/* If the key path contains no '.', the split results in a single empty string */
	if (nbOfComponents > 1)
	{
		NSArray *baseKeyPathComponents =
			[keyPathComponents subarrayWithRange: NSMakeRange(0,  [keyPathComponents count] - 1)];

		return [[self representedObject] valueForContentKeyPath:
		 	[baseKeyPathComponents componentsJoinedByString: @"."]];
	}
	else if (nbOfComponents == 1)
	{
		return [self representedObject];
	}
	else
	{
		ETAssertUnreachable();
		return nil;
	}
}

- (void) startObserveRepresentedObject: (id)anObject forKeyPath: (NSString *)aKeyPath
{
	ETAssert(_observations != nil);
	NSParameterAssert([anObject isKindOfClass: [NSArray class]] == NO
		&& [anObject isKindOfClass: [NSSet class]] == NO
		&& [anObject isKindOfClass: [NSDictionary class]] == NO);
	
	id intermediateObject = anObject;
	NSUInteger options = (NSKeyValueObservingOptionNew| NSKeyValueObservingOptionOld);
	NSString *intermediateKeyPath = @"";
	BOOL isFirstComponent = YES;

	for (NSString *component in [aKeyPath componentsSeparatedByString: @"."])
	{
		if (intermediateObject == nil)
			return;

		BOOL isOperator = [component hasPrefix: @"@"];
		
		if (isOperator)
			continue;

		if (isFirstComponent)
		{
			intermediateKeyPath = component;
		}
		else
		{
			intermediateKeyPath = [intermediateKeyPath stringByAppendingFormat: @".%@", component];
		}

		BOOL isPrimitiveCollection =
			([intermediateObject isCollection] && [intermediateObject content] == intermediateObject);

		if (isPrimitiveCollection)
		{
			NSAssert([intermediateObject isKeyed] == NO,
				@"Observing keyed collections is not supported yet");

			NSArray *content = [intermediateObject contentArray];

			for (id element in content)
			{
				[element addObserver: self forKeyPath: component options: options context: NULL];
			}
			[_observations setObject: [NSSet setWithArray: content] forKey: intermediateKeyPath];
		}
		else
		{
			[intermediateObject addObserver: self forKeyPath: component options: options context: NULL];
			[_observations setObject: intermediateObject forKey: intermediateKeyPath];
		}

		intermediateObject = [intermediateObject valueForContentKey: component];
		isFirstComponent = NO;
	}
}

- (void) stopObserveRepresentedObject: (id)anObject forKeyPath: (NSString *)aKeyPath
{
	[_observations enumerateKeysAndObjectsUsingBlock: ^(id intermediateKeyPath, id object, BOOL *stop)
	{
		NSString *key = [[intermediateKeyPath componentsSeparatedByString: @"."] lastObject];

		if ([object isKindOfClass: [NSSet class]])
		{
			for (id element in object)
			{
				[element removeObserver: self forKeyPath: key];
			}
		}
		else
	 	{
		 	[object removeObserver: self forKeyPath: key];
	 	}
	}];
	[_observations removeAllObjects];
}

#ifdef OPTIMIZED_OBSERVATION_UPDATE
- (void) updateObservationsForObject: (id)anObject atKeyPath: (NSString *)aBaseKeyPath
{

	NSParameterAssert([[self contentKeyPath] hasPrefix: aBaseKeyPath]);

	// TODO: Implement -stringByRemovingPrefix: and use it.
	unsigned int prefixLength = [aBaseKeyPath length];
	NSRange range = NSMakeRange(prefixLength, [[self contentKeyPath] length] - prefixLength);
	NSString *contentKeyPathEnd = [[self contentKeyPath] substringWithRange: range];
	id intermediateObject = anObject;
	NSString *intermediateKeyPath = baseKeyPath;

	for (NSString *component in [contentKeyPathEnd componentsSeparatedByString: @"."])
	{
		intermediateKeyPath = [intermediateKeyPath stringByAppendingFormat: @".%@", component];

		id observedContent = [_observations objectForKey: intermediateKeyPath];
		id content = [intermediateObject valueForContentKey: component];
		/* The observed content can be nil if the intermediate object was previously nil */

		if ([observedContent isKindOfClass: [NSSet class]])
		{
			if (intermediateObject == nil)
			{
				[_observations remove]
			}
			NSSet *intermediateSet = nil;
			
			if (intermediateObject != nil)
			{
				intermediateSet = [NSSet setWithArray: [intermediateObject contentArray]];
			}
			
			NSSet *removedObjects = [[observedContent mutableCopy] minusSet: intermediateSet];
			NSSet *addedObjects = [[intermediateSet mutableCopy] minusSet: observedContent];

			for (id element in removedObjects)
			{
				[element removeObserver: self forKeyPath: component];
			}
			for (id element in addedObjects)
			{
				[element addObserver: self forKeyPath: component options: options context: NULL];
			}
			RELEASE(removedObjects);
			RELEASE(addedObjects);

			[_observations setObject: intermediateSet forKey: intermediateKeyPath];
		}
		else
		{
			[intermediateObject addObserver: self forKeyPath: component options: options context: NULL];
			[_observations setObject: intermediateObject forKey: intermediateKeyPath];
		}
	}

}
#else
- (void) updateObservationsForObject: (id)anObject atKeyPath: (NSString *)aBaseKeyPath
{
	[self stopObserveRepresentedObject: [self representedObject] forKeyPath: [self observedKeyPath]];
	[self startObserveRepresentedObject: [self representedObject] forKeyPath: [self observedKeyPath]];
}
#endif

- (void) observeValueForKeyPath: (NSString *)keyPath
                       ofObject: (id)object
                         change: (NSDictionary *)change
                        context: (void *)context
{
	if (_isSettingValue)
		return;

	BOOL foundObject = NO;
	NSString *intermediateKeyPath = nil;

	for (intermediateKeyPath in _observations)
	{
		if ([intermediateKeyPath hasSuffix: keyPath] == NO)
			continue;

		id observedContent = [_observations objectForKey: intermediateKeyPath];
		ETAssert(observedContent != nil);
	
		if ([observedContent isKindOfClass: [NSSet class]])
		{
			foundObject = [observedContent containsObject: object];
		}
		else
		{
			foundObject = [observedContent isEqual: object];
		}
		
		if (foundObject)
			break;
	}
	ETAssert(foundObject);

	NSString *baseKeyPath = nil;
	NSArray *keyPathComponents = [intermediateKeyPath componentsSeparatedByString: @"."];

	if ([keyPathComponents count] > 1)
	{
		baseKeyPath = [keyPathComponents lastObject];
	}
	else
	{
		baseKeyPath = intermediateKeyPath;
	}

	[self updateObservationsForObject: object atKeyPath: baseKeyPath];
		
	ETLog(@"Will forward KVO property %@ change", keyPath);
		
	// NOTE: Invoking just -didChangeValueForKey: won't work
	[self willChangeValueForKey: @"value"];
	[self didChangeValueForKey: @"value"];
}

- (NSString *) observedKeyPath
{
	if ([self contentKeyPath] == nil)
		return [super observedKeyPath];

	if ([super observedKeyPath] == nil)
		return [self contentKeyPath];

	return [NSString stringWithFormat: @"%@.%@", [self name], [self contentKeyPath]];
}

- (void) setContentKeyPath: (NSString *)aKeyPath
{
	NSString *oldObservedKeyPath = [self observedKeyPath];
	ASSIGN(_contentKeyPath, aKeyPath);
	/* Update observation and mutable viewpoint trait */
	[self setRepresentedObject: [self representedObject]
	        oldObservedKeyPath: oldObservedKeyPath
	        newObservedKeyPath: [self observedKeyPath]];
}

- (id) content
{
	if ([self contentKeyPath] == nil)
	{
		return [super value];
	}
	else
	{
		return [[super value] valueForContentKeyPath: [self contentKeyPath]];
	}
}

/* This is an internal addition to the collection protocol. */
- (void) setContent: (id <ETCollection>)aCollection
{
	if ([self contentKeyPath] == nil)
	{
		[super setValue: aCollection];
	}
	else
	{
		[[super value] setValue: aCollection forContentKeyPath: [self contentKeyPath]];
	}
}

- (BOOL) setValue: (id)aValue forProperty: (NSString *)aProperty onObject: (id)accessedObject
{
	_isSettingValue = YES;
	NSParameterAssert([aValue isEqual: [[self class] mixedValueMarker]] == NO);
	
	BOOL result = YES;

	for (id object in accessedObject)
	{
		result &= [object setValue: aValue forProperty: aProperty];
	}
	_isSettingValue = NO;
	return result;
}

- (id) valueForProperty: (NSString *)aProperty onObject: (id)accessedObject
{
	NSParameterAssert(aProperty != nil && [aProperty length] > 0);

	id lastValue = nil;
	BOOL isFirstValue = YES;
	
	for (id object in accessedObject)
	{
		id value = [object valueForProperty: aProperty];
		
		if (isFirstValue == NO && value != lastValue && [value isEqual: lastValue] == NO)
		{
			return [[self class] mixedValueMarker];
		}
		isFirstValue = NO;
		lastValue = value;
	}
	
	return lastValue;
}

- (id) value
{
	if ([self contentKeyPath] == nil)
		return nil;

	NSString *component = [[[self contentKeyPath] componentsSeparatedByString: @"."] lastObject];
	return [self valueForProperty: component onObject: [self accessedObjectForMutation]];
}

- (void) setValue: (id)aValue
{
	if ([self contentKeyPath] == nil)
		return;

	NSString *component = [[[self contentKeyPath] componentsSeparatedByString: @"."] lastObject];
	[self setValue: aValue forProperty: component onObject: [self accessedObjectForMutation]];
}

+ (id) mixedValueMarker
{
	return [NSNumber numberWithInteger: -1];
}

- (id) valueForProperty: (NSString *)aProperty
{
	if ([aProperty isEqualToString: @"value"] && [[self value] isViewpoint] == NO)
	{
		return [self value];
	}
	return [self valueForProperty: aProperty onObject: [self content]];
}

- (BOOL) setValue: (id)aValue forProperty: (NSString *)aProperty
{
	if ([aProperty isEqualToString: @"value"] && [[self value] isViewpoint] == NO)
	{
		[self setValue: aValue];
		return YES;
	}
	return [self setValue: aValue forProperty: aProperty onObject: [self content]];
}

#pragma mark Collection Protocol
#pragma mark -

- (SEL) collectionSetter
{
	return NSSelectorFromString([NSString stringWithFormat: @"set%@:",
		[[[self contentKeyPath] lastPathComponent] stringByCapitalizingFirstLetter]]);
}

- (BOOL) isMutableCollection
{
	id accessedObject = [self accessedObjectForMutation];
	ETAssert([accessedObject isCollection]);
	return ([accessedObject count] == 1
		&& [accessedObject respondsToSelector: [self collectionSetter]]);
}

@end
