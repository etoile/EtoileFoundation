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


@end
