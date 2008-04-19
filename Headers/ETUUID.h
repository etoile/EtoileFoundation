/*
   Copyright (C) 2007 Yen-Ju Chen <yjchenx gmail>

   This application is free software; you can redistribute it and/or 
   modify it under the terms of the MIT license. See COPYING.

*/

#import <Foundation/Foundation.h>
#if 1 || defined(__linux__) || defined(__APPLE__)
#import <EtoileFoundation/uuid_dce.h>
#else /* FreeBSD, DragonFlyBSD, NetBSD */
#import <uuid.h>
#endif


@interface ETUUID : NSObject 
{
	uuid_t uuid;
}
/**
 * Initialize the UUID object with a 128-bit binary value
 */
- (id) initWithUUID:(uuid_t*)aUUID;
/**
 * Initialize the UUID object from a string representation.
 */
- (id) initWithString:(NSString*)aString;
- (BOOL) isEqual:(id)anObject;
- (NSString*) stringValue;
- (uuid_t*) uuid;
@end

#define ETUUIDSize (36 * sizeof(char))

@interface NSString (ETUUID)

+ (NSString *) UUIDString;
@end
