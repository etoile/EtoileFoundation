/*
   Copyright (C) 2007 Yen-Ju Chen <yjchenx gmail>

   This application is free software; you can redistribute it and/or 
   modify it under the terms of the MIT license. See COPYING.

*/

#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>

/** ETUUID does not have a designated initializer. */
@interface ETUUID : NSObject <NSCopying>
{
	unsigned char uuid[16];
}

+ (id) UUID;

/**
 * Initialize the UUID object with a 128-bit binary value
 */
- (id) initWithUUID: (unsigned char *)aUUID;
/**
 * Initialize the UUID object from a string representation.
 */
- (id) initWithString: (NSString *)aString;
- (BOOL) isEqual: (id)anObject;
- (NSString *) stringValue;
- (unsigned char *) UUIDValue;

@end

#define ETUUIDSize (36 * sizeof(char))

@interface NSString (ETUUID)
+ (NSString *) UUIDString;
@end
