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

#import "UKRunnerTests.h"

@implementation UKRunnerTests

- (id) init
{
    self = [super init];
    NSString *testBundlePath = [[[NSFileManager defaultManager] currentDirectoryPath] stringByAppendingPathComponent:@"UKTestBundleOne.bundle"];
    testBundle = [[NSBundle alloc] initWithPath:testBundlePath];
    [testBundle load];
    return self;
}

- (void) dealloc
{
    [testBundle release];
    [super dealloc];
}

- (void) testRunLoopAddition
{
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop performSelector:@selector(runLoopTrigger) 
                      target:self 
                    argument:nil 
                       order:0 
                       modes:[NSArray arrayWithObject:NSDefaultRunLoopMode]]; 
}

- (void) runLoopTrigger
{
    NSThread *thread = [NSThread currentThread];
    [[thread threadDictionary] setObject:@"YES" forKey:@"UKLoopTriggerRan"];
}

- (void) testRunLoopAdditionExecuted
{
    NSThread *thread = [NSThread currentThread];
    NSString *result = [[thread threadDictionary] 
                        objectForKey:@"UKLoopTriggerRan"];
    UKStringsEqual(result, @"YES");
    [[thread threadDictionary] removeObjectForKey:@"UKLoopTriggerRan"];
}

- (void) testRunLoopMode
{
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    UKStringsEqual([runLoop currentMode], NSDefaultRunLoopMode);
    
}

/*

- (void) testClassesFromBundle
{
    NSArray *testClasses = UKTestClassesFromBundle(testBundle);
    UKIntsEqual(2, [testClasses count]);
    UKTrue([testClasses containsObject:NSClassFromString(@"TestTwo")]);
    UKTrue([testClasses containsObject:NSClassFromString(@"TestThree")]);
}

- (void) testMethodNamesFromClass
{
    NSArray *testMethods = UKTestMethodNamesFromClass(NSClassFromString(@"TestTwo"));
    UKIntsEqual(3, [testMethods count]);
    UKTrue([testMethods containsObject:@"testOne"]);
    UKTrue([testMethods containsObject:@"testTwo"]);
    UKTrue([testMethods containsObject:@"testThree"]);
}
*/
// XXX need to test the various exception handling mechanisms

/*
- (void) testBundleInOutsideExecution
{
    NSString *ukrunPath = [[[NSFileManager defaultManager] currentDirectoryPath] stringByAppendingPathComponent:@"ukrun"];
    UKTask *task = [[UKTask alloc] init];
    [task setLaunchPath:ukrunPath];
    [task setArguments:[NSArray arrayWithObjects:[[[NSFileManager defaultManager] currentDirectoryPath] stringByAppendingPathComponent:@"UKTestBundleOne.bundle"], nil]];
    [task run];
    
    // task run should fail...
    UKIntsEqual(255, [task terminationStatus]);
    NSArray *outputLines = [[task standardOutput] componentsSeparatedByString:@"\n"];
    
    // 6 lines from tests, 1 line of summary, 1 empty line at end
    UKIntsEqual(8, [outputLines count]);
    
    // XXX sometime get around to testing other lines. But we're seeing it
    // all work well enough in Xcode that I think it's ok for now...
    
    // test last line of output
    UKStringsEqual(@"Result: 2 classes, 6 methods, 6 tests, 1 failed",
                   [outputLines objectAtIndex:6]);
    
    [task release];
}
*/
@end
