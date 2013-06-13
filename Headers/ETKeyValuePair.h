/**
	<abstract>A key/value association.</abstract>

	Copyright (C) 2010 Quentin Mathe

	Author:  Quentin Mathe <quentin.mathe@gmail.com>
	Date:  May 2010
	License: Modified BSD (see COPYING)
 */

#import <Foundation/Foundation.h>
#import <EtoileFoundation/ETViewpoint.h>

/** @group Collection Additions

Key value pairs are used by EtoileUI to present and interact with keyed data 
structures.

If you put them in an array, the resulting data structure is roughly equivalent 
to an ordered dictionary or a multi-value collection.
 
For now, ETKeyValuePair doesn't support subclassing. */
@interface ETKeyValuePair : NSObject <ETViewpoint>
{
	@private
	NSString *_key;
	id _value;
	id _representedObject;
}

/** @taskunit Initialization */

+ (id) pairWithKey: (NSString *)aKey value: (id)aValue;
- (id) initWithKey: (NSString *)aKey value: (id)aValue;

/** @taskunit Type Querying */

- (BOOL) isKeyValuePair;

/** @taskunit Observing Changes From Other Objects */

- (NSSet *) observableKeyPaths;

/** @taskunit Controlling the Represented Element */

- (NSString *) key;
- (void) setKey: (NSString *)aKey;
- (id) representedObject;
- (void) setRepresentedObject: (id)anObject;

/** @taskunit Accessing the Represented Element */

- (id) value;
- (void) setValue: (id)aValue;

/** @taskunit Property-Value Coding */

- (NSArray *) propertyNames;

/** @taskunit UI Presentation */

- (NSString *) displayName;

@end

/** @group Collection Additions

ETKeyValuePair-related extensions to NSArray. */
@interface NSArray (ETKeyValuePairRepresentation)
- (NSDictionary *) dictionaryRepresentation;
@end

/** @group Collection Additions

ETKeyValuePair-related extensions to NSObject. */
@interface NSObject (ETKeyValuePair)
- (BOOL) isKeyValuePair;
@end
