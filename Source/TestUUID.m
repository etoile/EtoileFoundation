/*
   Copyright (C) 2007 Yen-Ju Chen <yjchenx gmail>

   This application is free software; you can redistribute it and/or 
   modify it under the terms of the MIT license. See COPYING.

*/

#import <Foundation/Foundation.h>
#import <UnitKit/UnitKit.h>
#import "ETUUID.h"


@interface TestUUID: NSObject <UKTest>
@end

@implementation TestUUID

- (void) testUUIDObject
{
	id uuid = [ETUUID UUID];

	UKNotNil(uuid);
	UKNotNil([uuid stringValue]);
	UKTrue([uuid UUIDValue] != NULL);

	id uuid2 = [[ETUUID alloc] initWithUUID: [uuid UUIDValue]];
	int result;

	UKObjectsEqual(uuid, uuid2);
	uuid_equal([uuid UUIDValue], [uuid2 UUIDValue], &result);
	UKTrue(result == uuid_s_ok);

	id uuid3 = [[ETUUID alloc] initWithString: [uuid stringValue]];

	UKObjectsEqual(uuid, uuid3);
	UKObjectsEqual([uuid stringValue], [uuid3 stringValue]);

	id uuidString = [NSString UUIDString];
	id uuid4 = [[ETUUID alloc] initWithString: uuidString];
	id uuid5 = [[ETUUID alloc] initWithString: uuidString];

	UKObjectsEqual(uuidString, [uuid4 stringValue]);
	UKObjectsNotEqual(uuid, uuid4);
	UKObjectsEqual(uuid5, uuid4);
}

#if 0
- (void) testString
{
	NSLog(@"Long testing begins. It should be less than minutes.");

	NSMutableSet *set = [[NSMutableSet alloc] init];
	int i, count = 10000;

	for (i = 0; i < count; i++)
	{
		NSString *uuid = [NSString UUIDString];
		UKNotNil(uuid);
		UKFalse([set containsObject: uuid]);
		[set addObject: uuid];
		//NSLog(@"uuid %@", uuid);
	}
	DESTROY(set);

	NSLog(@"Long testing is done");
}
#endif

- (BOOL) handleDCEError: (int)error
{
	switch(error) {
		case uuid_s_ok:
			return YES;
		default:
			NSLog(@"UUID Error: %d", error);
			return NO;
	}
}

- (void) testDCE
{
	uuid_t uuid, uuid2;
	int status;
	int result;
	char *str = NULL;

	uuid_create(&uuid, &status);
	UKTrue([self handleDCEError: status]);
	result = uuid_is_nil(&uuid, &status);
	UKTrue([self handleDCEError: status]);
	NSLog(@"uuid_is_nil returns %d", result);
	UKIntsEqual(0, result); // not nil
	result = uuid_equal(&uuid, &uuid, &status);
	UKTrue([self handleDCEError: status]);
	NSLog(@"uuid_is_equal returns %d", result);
	UKIntsNotEqual(0, result); // equal

	// Next test fails with libossp-uuid 1.6.1 and lower (included a fix in 
	// the bundled version, see ../UUID)
	uuid_to_string(&uuid, &str, &status);
	UKTrue([self handleDCEError: status]);
	NSLog(@"DCE UUID string: %s", str);
	uuid_from_string(str, &uuid2, &status);
	UKTrue([self handleDCEError: status]);
	result = uuid_equal(&uuid, &uuid2, &status);
	UKTrue([self handleDCEError: status]);
	NSLog(@"uuid_equal returns %d", result);
	UKIntsNotEqual(0, result); // equal
}

/* OSSP Library Tests */

#ifdef OSSP

- (BOOL) handleError: (uuid_rc_t)error
{
	switch(error) {
		case UUID_RC_OK:
			return YES;
		default:
			NSLog(@"UUID Error: %d", error);
			return NO;
	}
}

- (void) testV1
{
	uuid_t *uuid = NULL;
	uuid_rc_t result;
	char *str = NULL;

	result = uuid_create(&uuid);
	UKTrue([self handleError: result]);
	result = uuid_make(uuid, UUID_MAKE_V1);
	UKTrue([self handleError: result]);
	result = uuid_export(uuid, UUID_FMT_STR, (void **)&str, NULL);
	UKTrue([self handleError: result]);
	result = uuid_destroy(uuid);
	UKTrue([self handleError: result]);
	NSLog(@"V1: %s", str);
	free(str);
	str = NULL;
}

- (void) testV3
{
	uuid_t *uuid = NULL;
	uuid_t *uuid_ns = NULL;
	uuid_rc_t result;
	char *str = NULL;

	result = uuid_create(&uuid_ns);
	UKTrue([self handleError: result]);
	result = uuid_create(&uuid);
	UKTrue([self handleError: result]);
	result = uuid_load(uuid_ns, "ns:URL");
	UKTrue([self handleError: result]);
	result = uuid_make(uuid, UUID_MAKE_V3, uuid_ns, "http://www.etoile-project.org");
	UKTrue([self handleError: result]);
	result = uuid_export(uuid, UUID_FMT_STR, (void **)&str, NULL);
	UKTrue([self handleError: result]);
	result = uuid_destroy(uuid_ns);
	UKTrue([self handleError: result]);
	result = uuid_destroy(uuid);
	UKTrue([self handleError: result]);
	NSLog(@"V3: %s", str);
	free(str);
	str = NULL;
}

#endif

@end
