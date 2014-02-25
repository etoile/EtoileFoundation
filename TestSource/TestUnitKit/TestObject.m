/**
	Copyright (C) 2014 Quentin Mathe

	Date:  January 2014
	License:  Apache License, Version 2.0  (see COPYING)
 */

#import "TestObject.h"

@implementation TestObject

- (void)testEmpty
{

}

@end


@implementation TestObjectInit

- (id)init
{
	self = [super init];
    if (self == nil)
    	return nil;

    [NSException raise: @"Test" format: @"For exception in init"];
    return self;
}

@end


@implementation TestObjectDealloc

- (void)dealloc
{
	[NSException raise: @"Test" format: @"For exception in dealloc"];
	[super dealloc];
}

@end


@implementation TestObjectTestMethod

- (void)testRaisesException
{
    [NSException raise: @"Test" format: @"For exception in test method"];
}

@end
