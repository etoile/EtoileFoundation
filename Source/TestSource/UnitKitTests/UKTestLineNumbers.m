/*
 This source is part of UnitKit, a unit test framework for Mac OS X 
 development. You can find more information about UnitKit at:
 
 http://x180.net/Code/UnitKit
 
 Copyright (c)2004 James Duncan Davidson
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 
 The use of the Apache License does not indicate that this project is
 affiliated with the Apache Software Foundation.
 */

#import "UKTestLineNumbers.h"


@implementation UKTestLineNumbers

- (id) init
{
    self = [super init];
    handler = [UKTestHandler handler];
    [handler setDelegate:self];
    return self;
}

- (void) dealloc
{
    [super dealloc];
}

- (void) reportStatus:(BOOL)cond inFile:(char *)filename line:(int)line message:(NSString *)msg
{
    reportedLine = line;
}

- (void) testUKPass
{
    UKPass();
    [handler setDelegate:nil];
    UKIntsEqual((__LINE__ - 2), reportedLine);
}

- (void) testUKFail
{
    UKFail();
    [handler setDelegate:nil];
    UKIntsEqual((__LINE__ - 2), reportedLine);
}

- (void) testUKTrue
{
    UKTrue(YES);
    [handler setDelegate:nil];
    UKIntsEqual((__LINE__ - 2), reportedLine);
}

- (void) testUKTrue_Negative
{
    UKTrue(NO);
    [handler setDelegate:nil];
    UKIntsEqual((__LINE__ - 2), reportedLine);
}

- (void) testUKFalse
{
    UKFalse(NO);
    [handler setDelegate:nil];
    UKIntsEqual((__LINE__ - 2), reportedLine);
}

- (void) testUKFalse_Negative
{
    UKFalse(YES);
    [handler setDelegate:nil];
    UKIntsEqual((__LINE__ - 2), reportedLine);
}

- (void) testUKNil
{
    UKNil(nil);
    [handler setDelegate:nil];
    UKIntsEqual((__LINE__ - 2), reportedLine);
}

- (void) testUKNil_Negative
{
    UKNil(@"");
    [handler setDelegate:nil];
    UKIntsEqual((__LINE__ - 2), reportedLine);
}

- (void) testUKNotNil
{
    UKNotNil(@"");
    [handler setDelegate:nil];
    UKIntsEqual((__LINE__ - 2), reportedLine);
}

- (void) testUKNotNil_Negative
{
    UKNotNil(nil);
    [handler setDelegate:nil];
    UKIntsEqual((__LINE__ - 2), reportedLine);
}

- (void) testUKIntsEqual
{
    UKIntsEqual(1, 1);
    [handler setDelegate:nil];
    UKIntsEqual((__LINE__ - 2), reportedLine);
}

- (void) testUKIntsEqual_Negative
{
    UKIntsEqual(1, 2);
    [handler setDelegate:nil];
    UKIntsEqual((__LINE__ - 2), reportedLine);
}

- (void) testUKFloatsEqual
{
    UKFloatsEqual(1.0, 1.0, 0.1);
    [handler setDelegate:nil];
    UKIntsEqual((__LINE__ - 2), reportedLine);
}

- (void) testUKFloatsEqual_Negative
{
    UKFloatsEqual(1.0, 2.0, 0.1);
    [handler setDelegate:nil];
    UKIntsEqual((__LINE__ - 2), reportedLine);
}

- (void) testUKFloatsNotEqual
{
    UKFloatsNotEqual(1.0, 2.0, 0.1);
    [handler setDelegate:nil];
    UKIntsEqual((__LINE__ - 2), reportedLine);
}

- (void) testUKFloatsNotEqual_Negative
{
    UKFloatsNotEqual(1.0, 1.0, 0.1);
    [handler setDelegate:nil];
    UKIntsEqual((__LINE__ - 2), reportedLine);
}

- (void) testUKObjectsEqual
{
    UKObjectsEqual(self, self);
    [handler setDelegate:nil];
    UKIntsEqual((__LINE__ - 2), reportedLine);
}

- (void) testUKObjectsEqual_Negative
{
    UKObjectsEqual(self, @"asdf");
    [handler setDelegate:nil];
    UKIntsEqual((__LINE__ - 2), reportedLine);
}

- (void) testUKObjectsSame
{
    UKObjectsSame(self, self);
    [handler setDelegate:nil];
    UKIntsEqual((__LINE__ - 2), reportedLine);
}

- (void) testUKObjectsSame_Negative
{
    UKObjectsSame(self, @"asdf");
    [handler setDelegate:nil];
    UKIntsEqual((__LINE__ - 2), reportedLine);
}

- (void) testUKStringsEqual
{
    UKStringsEqual(@"a", @"a");
    [handler setDelegate:nil];
    UKIntsEqual((__LINE__ - 2), reportedLine);
}

- (void) testUKStringsEqual_Negative
{
    UKStringsEqual(@"a", @"b");
    [handler setDelegate:nil];
    UKIntsEqual((__LINE__ - 2), reportedLine);
}

- (void) testUKStringContains
{
    UKStringContains(@"Now is the time", @"the time");
    [handler setDelegate:nil];
    UKIntsEqual((__LINE__ - 2), reportedLine);
}

- (void) testUKStringContains_Negative
{
    UKStringContains(@"asdf", @"zzzzz");
    [handler setDelegate:nil];
    UKIntsEqual((__LINE__ - 2), reportedLine);
}

- (void) testUKStringDoesNotContain
{
    UKStringDoesNotContain(@"asdf", @"zzzzz");
    [handler setDelegate:nil];
    UKIntsEqual((__LINE__ - 2), reportedLine);
}

- (void) testUKStringDoesNotContain_Negative
{
    UKStringDoesNotContain(@"Now is the time", @"the time");
    [handler setDelegate:nil];
    UKIntsEqual((__LINE__ - 2), reportedLine);
}

@end
