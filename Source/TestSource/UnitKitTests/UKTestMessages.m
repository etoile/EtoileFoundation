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

#import "UKTestMessages.h"


@implementation UKTestMessages

- (id) init
{
    self = [super init];
    handler = [UKTestHandler handler];
    [handler setDelegate:self];
    return self;
}

- (void) dealloc
{
    [reportedMessage release];
    [super dealloc];
}

- (NSString *) localizedString:(NSString *)key
{
    NSBundle *bundle = [NSBundle bundleForClass:[UKTestHandler class]];
    return NSLocalizedStringFromTableInBundle(key, @"UKTestHandler", 
                                              bundle, @"");
}

- (void) reportStatus:(BOOL)cond inFile:(char *)filename line:(int)line message:(NSString *)msg
{
    reportedMessage = [msg retain];
}

- (void) testUKPass
{
    UKPass();
    [handler setDelegate:nil];
    UKStringsEqual([self localizedString:@"msgUKPass"], reportedMessage);
}

- (void) testUKFail
{
    UKFail();
    [handler setDelegate:nil];
    UKStringsEqual([self localizedString:@"msgUKFail"], reportedMessage);
}

- (void) testUKTrue
{
    UKTrue(YES);
    [handler setDelegate:nil];
    UKStringsEqual([self localizedString:@"msgUKTrue.pass"], reportedMessage);
}

- (void) testUKTrue_Negative
{
    UKTrue(NO);
    [handler setDelegate:nil];
    UKStringsEqual([self localizedString:@"msgUKTrue.fail"], reportedMessage);
}

- (void) testUKFalse
{
    UKFalse(NO);
    [handler setDelegate:nil];
    UKStringsEqual([self localizedString:@"msgUKFalse.pass"], reportedMessage);
}

- (void) testUKFalse_Negative
{
    UKFalse(YES);
    [handler setDelegate:nil];
    UKStringsEqual([self localizedString:@"msgUKFalse.fail"], reportedMessage);
}

- (void) testUKNil
{
    UKNil(nil);
    [handler setDelegate:nil];
    UKStringsEqual([self localizedString:@"msgUKNil.pass"], reportedMessage);
}

- (void) testUKNil_Negative
{
   UKNil(@"");
    [handler setDelegate:nil];
    NSString *expected = [NSString stringWithFormat:[self localizedString:@"msgUKNil.fail"], @"\"\""];
    UKStringsEqual(expected, reportedMessage);
}

- (void) testUKNotNil
{
    UKNotNil(@"");
    [handler setDelegate:nil];
    NSString *expected = [NSString stringWithFormat:[self localizedString:@"msgUKNotNil.pass"], @"\"\""];
    UKStringsEqual(expected, reportedMessage);
}

- (void) testUKNotNil_Negative
{
    UKNotNil(nil);
    [handler setDelegate:nil];
    UKStringsEqual([self localizedString:@"msgUKNotNil.fail"], reportedMessage);
}

- (void) testUKIntsEqual
{
    UKIntsEqual(1, 1);
    [handler setDelegate:nil];   
    NSString *expected = [NSString stringWithFormat:[self localizedString:@"msgUKIntsEqual.pass"], 1, 1];
    UKStringsEqual(expected, reportedMessage);
}

- (void) testUKIntsEqual_Negative
{
    UKIntsEqual(1, 2);
    [handler setDelegate:nil];
    NSString *expected = [NSString stringWithFormat:[self localizedString:@"msgUKIntsEqual.fail"], 1, 2];
    UKStringsEqual(expected, reportedMessage);
}

// test ukintsnotequal?

- (void) testUKFloatsEqual
{
    float a = 1.0;
    UKFloatsEqual(a, a, 0.1);
    NSString *expected = [NSString stringWithFormat:[self localizedString:@"msgUKFloatsEqual.pass"], a, a];
    UKStringsEqual(expected, reportedMessage);
}

- (void) testUKFloatsEqual_Negative
{
    float a = 1.0;
    float b = 2.0;
    UKFloatsEqual(a, b, 0.1);
    [handler setDelegate:nil];
    NSString *expected = [NSString stringWithFormat:[self localizedString:@"msgUKFloatsEqual.fail"], a - 0.1, a + 0.1, b];
    UKStringsEqual(expected, reportedMessage);
}
/*
- (void) testUKFloatsNotEqual
{
    UKFloatsNotEqual(1.0, 2.0, 0.1);
    [handler setDelegate:nil];
    UKStringsEqual(@"UKFloatsNotEqual", reportedMessage);
}

- (void) testUKFloatsNotEqual_Negative
{
    float a = 1.0;
    float b = 1.0;
    UKFloatsNotEqual(a, b, 0.1);
    [handler setDelegate:nil];
    NSString *expectedMessage = [NSString stringWithFormat:@"UKFloatsNotEqual failed, %f == %f", a, b];
    UKStringsEqual(expectedMessage, reportedMessage);
}

- (void) testUKObjectsEqual
{
    UKObjectsEqual(self, self);
    [handler setDelegate:nil];
    UKStringsEqual(@"UKObjectsEqual", reportedMessage);
}

- (void) testUKObjectsEqual_Negative
{
    UKObjectsEqual(self, @"asdf");
    [handler setDelegate:nil];
    UKStringsEqual(@"UKObjectsEqual failed", reportedMessage);
}

- (void) testUKObjectsSame
{
    UKObjectsSame(self, self);
    [handler setDelegate:nil];
    UKStringsEqual(@"UKObjectsSame", reportedMessage);
}

- (void) testUKObjectsSame_Negative
{
    UKObjectsSame(self, @"asdf");
    [handler setDelegate:nil];
    UKStringsEqual(@"UKObjectsSame failed", reportedMessage);
}

- (void) testUKStringsEqual
{
    UKStringsEqual(@"a", @"a");
    [handler setDelegate:nil];
    UKStringsEqual(@"UKStringsEqual", reportedMessage);
}

- (void) testUKStringsEqual_Negative
{
    UKStringsEqual(@"a", @"b");
    [handler setDelegate:nil];
    UKStringsEqual(@"UKStringsEqual failed", reportedMessage);
}

- (void) testUKStringContains
{
    UKStringContains(@"Now is the time", @"the time");
    [handler setDelegate:nil];
    UKStringsEqual(@"UKStringContains", reportedMessage);
}

- (void) testUKStringContains_Negative
{
    UKStringContains(@"asdf", @"zzzzz");
    [handler setDelegate:nil];
    UKStringsEqual(@"UKStringContains failed", reportedMessage);
}

- (void) testUKStringDoesNotContain
{
    UKStringDoesNotContain(@"asdf", @"zzzzz");
    [handler setDelegate:nil];
    UKStringsEqual(@"UKStringDoesNotContain", reportedMessage);
}

- (void) testUKStringDoesNotContain_Negative
{
    UKStringDoesNotContain(@"Now is the time", @"the time");
    [handler setDelegate:nil];
    UKStringsEqual(@"UKStringDoesNotContain failed", reportedMessage);
}
*/


@end
