/**
	<abstract>A key/value association.</abstract>

	Copyright (C) 2010 Quentin Mathe

	Author:  Quentin Mathe <quentin.mathe@gmail.com>
	Date:  May 2010
	License: Modified BSD (see COPYING)
 */

#import <Foundation/Foundation.h>

/** Key value pairs are used by EtoileUI to present and interact with keyed data 
structures.

If you put them in an array, the resulting data structure is roughly equivalent 
to an ordered dictionary or a multi-value collection. */
@interface ETKeyValuePair : NSObject
{
	@private
	NSString *_key;
	id _value;
}

- (id) initWithKey: (NSString *)aKey value: (id)aValue;

- (NSString *) key;
- (void) setKey: (NSString *)aKey;
- (id) value;
- (void) setValue: (id)aValue;

- (NSArray *) properties;

- (NSString *) displayName;

@end

/** ETKeyValuePair-related extensions to NSArray. */
@interface NSArray (ETKeyValuePairRepresentation)
- (NSDictionary *) dictionaryRepresentation;
@end

/** ETKeyValuePair-related extensions to NSDictionary. */
@interface NSDictionary (ETKeyValuePairRepresentation)
- (NSArray *) arrayRepresentation;
@end

