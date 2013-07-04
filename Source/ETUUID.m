/*
   Copyright (C) 2007 Yen-Ju Chen <yjchenx gmail>

   This application is free software; you can redistribute it and/or 
   modify it under the terms of the MIT license. See COPYING.

*/

#import <Foundation/Foundation.h>
#import "ETUUID.h"
#import "EtoileCompatibility.h"
#include <stdlib.h>
#include <stdint.h>
#import "Macros.h"


#define TIME_LOW(uuid) (*(uint32_t*)(uuid))
#define TIME_MID(uuid) (*(uint16_t*)(&(uuid)[4]))
#define TIME_HI_AND_VERSION(uuid) (*(uint16_t*)(&(uuid)[6]))
#define CLOCK_SEQ_HI_AND_RESERVED(uuid) (*(&(uuid)[8]))
#define CLOCK_SEQ_LOW(uuid) (*(&(uuid)[9]))
#define NODE(uuid) ((char*)(&(uuid)[10]))

#if defined(__FreeBSD__) || defined(__OpenBSD) || defined(__DragonFly__) || defined(__APPLE__) 
static void ETUUIDGet16RandomBytes(unsigned char bytes[16])
{
	*((uint32_t*)&bytes[0]) = arc4random();
	*((uint32_t*)&bytes[4]) = arc4random();
	*((uint32_t*)&bytes[8]) = arc4random();
	*((uint32_t*)&bytes[12]) = arc4random();
}
#else
#include <openssl/rand.h>
static void ETUUIDGet16RandomBytes(unsigned char bytes[16])
{
	if (1 != RAND_pseudo_bytes(bytes, 16))
	{
		[NSException raise: NSGenericException
					format: @"libcrypto can't automatically seed its random numer generator on your OS"];
	}
}
#endif


@implementation ETUUID

+ (id) UUID
{
	return AUTORELEASE([[self alloc] init]);
}

+ (id) UUIDWithString: (NSString *)aString
{
	return AUTORELEASE([[self alloc] initWithString: aString]);
}

+ (ETUUID *) UUIDWithData: (NSData *)aData
{
    NSParameterAssert([aData length] == 16);
    return [[[self alloc] initWithUUID: [aData bytes]] autorelease];
}

- (id) init
{
	SUPERINIT

	// Initialise with random data.
	ETUUIDGet16RandomBytes(uuid);
	// Clear bits 6 and 7
	CLOCK_SEQ_HI_AND_RESERVED(uuid) &= (unsigned char)63;
	// Set bit 6
	CLOCK_SEQ_HI_AND_RESERVED(uuid) |= (unsigned char)64;
	// Clear the top 4 bits
	TIME_HI_AND_VERSION(uuid) &= 4095;
	// Set the top 4 bits to the version
	TIME_HI_AND_VERSION(uuid) |= 16384;
	return self;
}

- (id) initWithUUID: (const unsigned char *)aUUID
{
	SUPERINIT

	memcpy(&uuid, aUUID, 16);

	return self;
}

- (id) initWithString: (NSString *)aString
{
	NILARG_EXCEPTION_TEST(aString);
	
	if ([aString length] != 36)
	{
		[NSException raise: NSInvalidArgumentException
		            format: @"%@ not 36 characters in length", aString];
	}
	
	SUPERINIT;

	const char *data = [aString UTF8String];
	int scanned = sscanf(data, "%x-%hx-%hx-%2hhx%2hhx-%2hhx%2hhx%2hhx%2hhx%2hhx%2hhx", 
	   &TIME_LOW(uuid), 
	   &TIME_MID(uuid),
	   &TIME_HI_AND_VERSION(uuid),
	   &CLOCK_SEQ_HI_AND_RESERVED(uuid),
	   &CLOCK_SEQ_LOW(uuid),
	   &NODE(uuid)[0],
	   &NODE(uuid)[1],
	   &NODE(uuid)[2],
	   &NODE(uuid)[3],
	   &NODE(uuid)[4],
	   &NODE(uuid)[5]);

	if (scanned != 11)
	{
		[self release];
		[NSException raise: NSInvalidArgumentException
		            format: @"%@ not a well formed UUID", aString];
	}
	
	return self;
}

- (id) copyWithZone: (NSZone *)zone
{
	return RETAIN(self);
}

/* Returns the UUID hash.
   Rough collision estimate for a given number of generated UUIDs, computed 
   with -testHash in TestUUID.m. For each case, -testHash has been run around 
   15 times.
           32-bit NSUInteger               64-bit NSUInteger
   100000: ~1 (between 0 to 3 collisions)  0
   200000: ~4 (1 to 11)                    0
   300000: ~11 (4 to 16)                   0
   400000: ~19 (13 to 31)                  0
   500000: ~28 (20 to 35)                  0
*/
- (NSUInteger) hash
{
	return *((uint64_t *)uuid);
}

- (BOOL) isEqual: (id)anObject
{
	if (![anObject isKindOfClass: [self class]])
	{
		return NO;
	}
	const unsigned char *other_uuid = [anObject UUIDValue];
	for (unsigned i=0 ; i<16 ; i++)
	{
		if (uuid[i] != other_uuid[i])
		{
			return NO;
		}
	}
	return YES;
}

- (NSString *) stringValue
{
	return [NSString stringWithFormat:
		@"%0.8x-%0.4hx-%0.4hx-%0.2hhx%0.2hhx-%0.2hhx%0.2hhx%0.2hhx%0.2hhx%0.2hhx%0.2hhx", 
		   TIME_LOW(uuid), 
		   TIME_MID(uuid),
		   TIME_HI_AND_VERSION(uuid),
		   CLOCK_SEQ_HI_AND_RESERVED(uuid),
		   CLOCK_SEQ_LOW(uuid),
		   NODE(uuid)[0],
		   NODE(uuid)[1],
		   NODE(uuid)[2],
		   NODE(uuid)[3],
		   NODE(uuid)[4],
		   NODE(uuid)[5]];
}

- (const unsigned char *) UUIDValue
{
	return uuid;
}

- (NSString*) description
{
	return [self stringValue];
}
@end


@implementation NSString (ETUUID)

+ (NSString *) UUIDString
{
	ETUUID *uuid = [[ETUUID alloc] init];
	NSString *str = [uuid stringValue];

	RELEASE(uuid);
	return str;
}

@end


@implementation NSUserDefaults (ETUUID)

- (ETUUID *) UUIDForKey: (NSString *)aKey
{
	NSString *uuidString = [self stringForKey: aKey];

	if (uuidString == nil)
	{
		return nil;
	}

	return [ETUUID UUIDWithString: uuidString];
}

- (void) setUUID: (ETUUID *)aUUID forKey: (NSString *)aKey
{
	[self setObject: [aUUID stringValue] forKey: aKey];
}

@end
