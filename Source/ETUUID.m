/*
   Copyright (C) 2007 Yen-Ju Chen <yjchenx gmail>

   This application is free software; you can redistribute it and/or 
   modify it under the terms of the MIT license. See COPYING.

*/

#import "ETUUID.h"
#import "Macros.h"


@implementation ETUUID

- (id) init
{
	SUPERINIT

	int status;

	uuid_create(&uuid, &status);

	if (status != uuid_s_ok)
	{
		[self release];
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
		[self release];
		return nil;
	}

	return self;
}

- (BOOL) isEqual: (id)anObject
{
	if (![anObject isKindOfClass: [self class]])
	{
		return NO;
	}

	int status;

	uuid_t *u2 = [anObject uuid];

	return (uuid_compare(&uuid, u2, &status) == 0);
}

- (NSString *) stringValue
{
	char *str;
	int status;

	uuid_to_string(&uuid, &str, &status);
	if(status != uuid_s_ok)
	{
		return nil;
	}

	NSString *u = [NSString stringWithUTF8String: str];
	free(str);

	return u;
}

- (uuid_t *) uuid
{
	return &uuid;
}

@end


@implementation NSString (ETUUID)

+ (NSString *) UUIDString
{
	ETUUID *uuid = [[ETUUID alloc] init];
	NSString *str = [uuid stringValue];

	[uuid release];
	return str;
}

@end
