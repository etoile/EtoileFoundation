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
#import "UKTestMacros.h"

@implementation UKTestMacros

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
    reportedStatus = cond;
}

/* 
// This is a bunch of test failures that I use just to show things failing
- (void) testAllFailures
{
    [handler setDelegate:nil];
    UKFail();
    UKTrue(NO);
    UKFalse(YES);
    UKNil(@"fwip");
    UKNil(self);
    UKNotNil(nil);
    UKIntsEqual(3, 4);
    UKIntsNotEqual(3, 3);
    UKFloatsEqual(22.0, 33.0, 1.0);
    UKFloatsNotEqual(22.1, 22.2, 0.2);
    UKObjectsEqual(self, @"foo");
    UKObjectsNotEqual(self, self);
    UKObjectsSame(self, @"foo");
    UKObjectsNotSame(@"foo", @"foo");
    UKStringsEqual(@"fraggle", @"rock");
    UKStringsNotEqual(@"fraggle", @"fraggle");
    UKStringContains(@"fraggle", @"no");
    UKStringDoesNotContain(@"fraggle", @"fra");
}
*/

- (void) testUKPass
{
    UKPass(); 
    [handler setDelegate:nil];
    NSAssert(reportedStatus, @"Failsafe check on UKPass");
    UKTrue(reportedStatus);
}

- (void) testUKPassWithMessage
{
    UKPass();
    [handler setDelegate:nil];
    NSAssert(reportedStatus, @"Failsafe check on UKPass");
}

- (void) testUKFail
{
    UKFail();
    [handler setDelegate:nil];
    NSAssert(!reportedStatus, @"Failsafe check on UKFail");
    UKFalse(reportedStatus);
}

- (void) testUKTrue_Simple
{
    UKTrue(YES);
    [handler setDelegate:nil];
    NSAssert(reportedStatus, @"Failsafe check on UKTrue");
    UKTrue(reportedStatus);
}

- (void) testUKTrue_Simple_Negative
{
    UKTrue(NO);
    [handler setDelegate:nil];
    NSAssert(!reportedStatus, @"Failsafe check on UKTrue");
    UKFalse(reportedStatus);
}

- (void) testUKTrue_Conditional_GreaterThan
{
    UKTrue(42 > 41);
    [handler setDelegate:nil];
    UKTrue(reportedStatus);
}

- (void) testUKTrue_Conditional_GreaterThan_Negative
{
    UKTrue(41 > 42);
    [handler setDelegate:nil];
    UKFalse(reportedStatus);
}

- (void) testUKTrue_Conditional_LessThan
{
    UKTrue(41 < 42);
    [handler setDelegate:nil];
    UKTrue(reportedStatus);
}

- (void) testUKTrue_Conditional_LessThan_Negative
{
    UKTrue(41 < 40);
    [handler setDelegate:nil];
    UKFalse(reportedStatus);
}

- (void) testUKTrue_Conditional_Equal
{
    UKTrue(42 == 42);
    [handler setDelegate:nil];
    UKTrue(reportedStatus);
}

- (void) testUKTrue_Conditional_Equal_Negative
{
    UKTrue(42 == 41);
    [handler setDelegate:nil];
    UKFalse(reportedStatus);
}

- (void) testUKTrue_Conditional_NotEqual
{
    UKTrue(42 != 41);
    [handler setDelegate:nil];
    UKTrue(reportedStatus);
}

- (void) testUKTrue_Conditional_NotEqual_Negative
{
    UKTrue(42 != 42);
    [handler setDelegate:nil];
    UKFalse(reportedStatus);
}

- (void) testUKTrue_Message
{
    UKTrue([@"foofart" hasPrefix:@"foo"]);
    [handler setDelegate:nil];
    UKTrue(reportedStatus);
}

- (void) testUKTrue_Message_Negative
{
    UKTrue([@"foofart" hasPrefix:@"fart"]);
    [handler setDelegate:nil];
    UKFalse(reportedStatus);
}

- (void) testUKFalse
{
    UKFalse(NO);
    [handler setDelegate:nil];
    NSAssert(reportedStatus, @"Failsafe check on UKFalse");
    UKTrue(reportedStatus);
}

- (void) testUKFalse_Negative
{
    UKFalse(YES);
    [handler setDelegate:nil];
    NSAssert(!reportedStatus, @"Failsafe check on UKFalse");
    UKFalse(reportedStatus);
}

- (void) testUKFalse_Message
{
    UKTrue([@"foofart" hasPrefix:@"fart"]);
    [handler setDelegate:nil];
    UKFalse(reportedStatus);
}

- (void) testUKFalse_Message_Negative
{
    UKTrue([@"foofart" hasPrefix:@"foo"]);
    [handler setDelegate:nil];
    UKTrue(reportedStatus);
}

- (void) testUKNil_withNil
{
    UKNil(nil);
    [handler setDelegate:nil];
    UKTrue(reportedStatus);
}

- (void) testUKNil_withNull
{
    UKNil(NULL);
    [handler setDelegate:nil];
    UKTrue(reportedStatus);
}

- (void) testUKNil_with0
{
    // since zero is zero *and* the value of the nil pointer...
    UKNil(0);
    [handler setDelegate:nil];
    UKTrue(reportedStatus);
}

- (void) testUKNil_with
{
    // XXX
}

- (void) testUKNil_NegativeWithObject
{
    UKNil(@"");
    [handler setDelegate:nil];
    UKFalse(reportedStatus);
}

- (void) testUKNil_NegativeWithPointer
{
    // XXX
}

- (void) testUKNotNil
{
    UKNotNil(@"");
    [handler setDelegate:nil];
    UKTrue(reportedStatus);
}

- (void) testUKNotNil_NegativeWithNil
{
    UKNotNil(nil);
    [handler setDelegate:nil];
    UKFalse(reportedStatus);
}

- (void) testUKNotNil_NegativeWithNull
{
    UKNotNil(NULL);
    [handler setDelegate:nil];
    UKFalse(reportedStatus);
}

- (void) testUKNotNil_NegativeWith0
{
    UKNotNil(0);
    [handler setDelegate:nil];
    UKFalse(reportedStatus);
}

- (void) testUKIntsEqual
{
    UKIntsEqual(42, 42);
    [handler setDelegate:nil];
    UKTrue(reportedStatus);
}

- (void) testUKIntsEqual_Negative
{
    UKIntsEqual(42, 41);
    [handler setDelegate:nil];
    UKFalse(reportedStatus);
}

- (void) testUKFloatsEqual1
{
    UKFloatsEqual(42.100, 42.100, 0.01);
    [handler setDelegate:nil];
    UKTrue(reportedStatus);
}

- (void) testUKFloatsEqual2
{
    UKFloatsEqual(42.100, 42.200, 0.2);
    [handler setDelegate:nil];
    UKTrue(reportedStatus);
}

- (void) testUKFloatsEqual3
{
    UKFloatsEqual(1.0, 1.0, 0.0);
    [handler setDelegate:nil];
    UKTrue(reportedStatus);
}

- (void) testUKFloatsEqual4
{
    UKFloatsEqual(1.0, 1.0, 0.01);
    [handler setDelegate:nil];
    UKTrue(reportedStatus);
}

- (void) testUKFloatsEqual_Negative1
{
    UKFloatsEqual(42.100, 43.100, 0.01);
    [handler setDelegate:nil];
    UKFalse(reportedStatus);
}

- (void) testUKFloatsEqual_Negative2
{
    UKFloatsEqual(42.100, 42.200, 0.08);
    [handler setDelegate:nil];
    UKFalse(reportedStatus);
}


- (void) testUKFloatsNotEqual
{
    UKFloatsNotEqual(42.100, 43.100, 0.01);
    [handler setDelegate:nil];
    UKTrue(reportedStatus);
}

- (void) testUKFloatsEqual_Negative
{
    UKFloatsNotEqual(42.1000, 42.1000, 0.01);
    [handler setDelegate:nil];
    UKFalse(reportedStatus);
}

- (void) testUKObjectsEqual1
{
    UKObjectsEqual(self, self);
    [handler setDelegate:nil];
    UKTrue(reportedStatus);
}

- (void) testUKObjectsEqual2
{
    UKObjectsEqual(@"", [NSString stringWithString:@""]);
    [handler setDelegate:nil];
    UKTrue(reportedStatus);
}

- (void) testUKObjectsEqual_Negative
{
    UKObjectsEqual(@"", @"123");
    [handler setDelegate:nil];
    UKFalse(reportedStatus); 
}

- (void) testUKStringsEqual1
{
    UKStringsEqual(@"abc", @"abc");
    [handler setDelegate:nil];
    UKTrue(reportedStatus);
}

- (void) testUKStringsEqual2
{
    UKStringsEqual(@"abc", [NSString stringWithString:@"abc"]);
    [handler setDelegate:nil];
    UKTrue(reportedStatus);
}

- (void) testUKStringsEqual3
{
    UKStringsEqual(@"abc", [NSString stringWithCString:"abc"]);
    [handler setDelegate:nil];
    UKTrue(reportedStatus);
}

- (void) testUKStringsEqual_Negative
{
    UKStringsEqual(@"abc", @"bea");
    [handler setDelegate:nil];
    UKFalse(reportedStatus);
}

- (void) testUKStringsNotEqual
{
    UKStringsNotEqual(@"abc", @"bea");
    [handler setDelegate:nil];
    UKTrue(reportedStatus);
}

- (void) testUKStringsNotEqual_Negative1
{
    UKStringsNotEqual(@"abc", @"abc");
    [handler setDelegate:nil];
    UKFalse(reportedStatus);    
}

- (void) testUKStringsNotEqual_Negative2
{
    UKStringsNotEqual(@"abc", [NSString stringWithString:@"abc"]);
    [handler setDelegate:nil];
    UKFalse(reportedStatus);    
}

- (void) testUKStringsNotEqual_Negative3
{
    UKStringsNotEqual(@"abc", [NSString stringWithCString:"abc"]);
    [handler setDelegate:nil];
    UKFalse(reportedStatus);    
}


- (void) testUKStringContains
{
    UKStringContains(@"Now is the time", @"the time");
    [handler setDelegate:nil];
    UKTrue(reportedStatus);
}

- (void) testUKStringContains_Negative
{
    UKStringContains(@"asdf", @"zzzzz");
    [handler setDelegate:nil];
    UKFalse(reportedStatus);
}

- (void) testUKStringDoesNotContain
{
    UKStringDoesNotContain(@"asdf", @"zzzzz");
    [handler setDelegate:nil];
    UKTrue(reportedStatus);
}

- (void) testUKStringDoesNotContain_Negative
{
    UKStringDoesNotContain(@"Now is the time", @"the time");
    [handler setDelegate:nil];
    UKFalse(reportedStatus);
}

- (void) raiseException:(id)objectToRaise
{
    @throw objectToRaise;
}

- (void) doNotRaiseException
{
    // this is fun... do nothing
}

- (void) testUKRaisesException
{
    UKRaisesException([self raiseException:@"Hi"]);
    [handler setDelegate:nil];
    UKTrue(reportedStatus);
}

- (void) testUKRaisesException_Negative
{
    UKRaisesException([self doNotRaiseException]);
    [handler setDelegate:nil];
    UKFalse(reportedStatus);
}

- (void) testUKDoesNotRaisesException
{
    UKDoesNotRaiseException([self doNotRaiseException]);
    [handler setDelegate:nil];
    UKTrue(reportedStatus);
}

- (void) testUKDoesNotRaisesException_Negative
{
    UKDoesNotRaiseException([self raiseException:@"Hi"]);
    [handler setDelegate:nil];
    UKFalse(reportedStatus);
    }
 
- (void) testUKRaisesExceptionNamed
{
    UKRaisesExceptionNamed([self raiseException:[NSException exceptionWithName:@"Test" reason:@"For testing" userInfo:nil]], @"Test");
    [handler setDelegate:nil];
    UKTrue(reportedStatus);
}

- (void) testUKRaisesExceptionNamed_WrongNSException
{
    UKRaisesExceptionNamed([self raiseException:[NSException exceptionWithName:@"Test" reason:@"For testing" userInfo:nil]], @"Wrong");
    [handler setDelegate:nil];
    UKFalse(reportedStatus);
}

- (void) testUKRaisesExceptionNamed_WrongClass
{
    UKRaisesExceptionNamed([self raiseException:@"Not an NSException"], @"Wrong");
    [handler setDelegate:nil];
    UKFalse(reportedStatus);
}

- (void) testUKRaisesExceptionClass
{
    UKRaisesExceptionClass([self raiseException:@"aSTring"], NSString);
    [handler setDelegate:nil];
    UKTrue(reportedStatus);
}
 
- (void) testUKRaisesClass_Wrong
{
    UKRaisesExceptionClass([self raiseException:@"aSTring"], NSException);
    [handler setDelegate:nil];
    UKFalse(reportedStatus);
}


@end
