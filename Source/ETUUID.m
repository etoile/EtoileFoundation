/*
   Copyright (C) 2007 Yen-Ju Chen <yjchenx gmail>

   This application is free software; you can redistribute it and/or 
   modify it under the terms of the MIT license. See COPYING.

*/

#import "ETUUID.h"
#import "Macros.h"


@implementation ETUUID

+ (id) UUID
{
	return AUTORELEASE([[self alloc] init]);
}

- (id) init
{
	SUPERINIT

	int status;

	uuid_create(&uuid, &status);

	if (status != uuid_s_ok)
	{
		RELEASE(self);
		return nil;
	}

	return self;
}

- (id) initWithUUID: (uuid_t *)aUUID
{
	SUPERINIT

	memcpy(&uuid, aUUID, 16);

	return self;
}

- (id) initWithString: (NSString *)aString
{
	SUPERINIT

	int status;

	uuid_from_string([aString UTF8String], &uuid, &status);

	if (status != uuid_s_ok)
	{
		RELEASE(self);
		return nil;
	}

	return self;
}

- (id) copyWithZone: (NSZone *)zone
{
	return RETAIN(self);
}

- (BOOL) isEqual: (id)anObject
{
	if (![anObject isKindOfClass: [self class]])
	{
		return NO;
	}

	int status;
	uuid_t *u2 = [anObject UUIDValue];
	int result = uuid_equal(&uuid, u2, &status);

	if (status != uuid_s_ok)
	{
		return NO;
	}

	return (result != 0);
}

- (NSString *) stringValue
{
	char *str = NULL;
	int status;

	uuid_dce_to_string(&uuid, &str, &status);
	if (status != uuid_s_ok)
	{
		return nil;
	}

	NSString *u = [NSString stringWithUTF8String: str];
	free(str);

	return u;
}

- (uuid_t *) UUIDValue
{
	return &uuid;
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
