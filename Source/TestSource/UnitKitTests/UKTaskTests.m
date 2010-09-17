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

#import <UnitKit/UKTask.h>
#import "UKTaskTests.h"

@implementation UKTaskTests

- (id) init
{
    self = [super init];
    task = [[UKTask alloc] init];
    return self;
}

- (void) dealloc
{
    [task release];
    [super dealloc];
}

/*
 Yes, for the most part unit tests should focus on one thing at a time. However
 to test UKTask, these two things are pretty much intertwined in any test. So
 here they are combined as is.
 */

- (void) testSetLaunchPathAndGetStandardOut
{
    [task setLaunchPath:@"/bin/pwd"];
    [task run];
    NSString *pwd = [[NSFileManager defaultManager] currentDirectoryPath];
    NSString *expected = [pwd stringByAppendingString:@"\n"];
    UKStringsEqual(expected, [task standardOutput]);
}

- (void) testSetArguments
{
    [task setLaunchPath:@"/bin/echo"];
    [task setArguments:[NSArray arrayWithObjects:@"one", @"two", nil]];
    [task run];
    UKStringsEqual(@"one two\n", [task standardOutput]);
}

- (void) testSetWorkingDirectoryPath
{
    [task setLaunchPath:@"/bin/pwd"];
    [task setWorkingDirectoryPath:@"/private/tmp"];
    [task run];
    UKStringsEqual(@"/private/tmp\n", [task standardOutput]);
}

- (void) testSetEnvironment
{
    [task setLaunchPath:@"/usr/bin/env"];
    [task setEnvironmentValue:@"bar" forKey:@"FOO"];
    [task run];
    UKStringContains([task standardOutput], @"FOO=bar");
}

- (void) testSetStandardInput
{
    [task setLaunchPath:@"/bin/cat"];
    [task setStandardInput:@"Now is the time"];
    [task run];
    UKStringsEqual(@"Now is the time", [task standardOutput]);
}

- (void) testStandardInputAndOutputWithData
{
    NSString *ukrunPath = [[[NSProcessInfo processInfo] arguments] objectAtIndex:0];
    NSData *binaryData = [NSData dataWithContentsOfFile:ukrunPath];
    [task setLaunchPath:@"/bin/cat"];
    [task setStandardInputWithData:binaryData];
    [task run];
    UKObjectsEqual(binaryData, [task standardOutputAsData]);
}

@end
