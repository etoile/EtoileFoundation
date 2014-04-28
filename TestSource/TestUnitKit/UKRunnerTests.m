/*
	Copyright (C) 2004 James Duncan Davidson, Quentin Mathe

	License:  Apache License, Version 2.0  (see LICENSE)
 
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
#import "TestObject.h"

@interface RandomObject : NSObject
@end

@implementation RandomObject

static BOOL randomObjectInitialized = NO;

+ (void)initialize
{
	randomObjectInitialized = YES;
}

@end

@interface TestedObject : NSObject <UKTest>
@end

@implementation TestedObject

static BOOL testedObjectInitialized = NO;

+ (void)initialize
{
	testedObjectInitialized = YES;
}

@end

@implementation UKRunnerTests

- (id)init
{
	self = [super init];
    if (self == nil)
    	return nil;

	handler = [UKTestHandler handler];

#if !(TARGET_OS_IPHONE)
	NSString *testBundlePath = [[[NSFileManager defaultManager] currentDirectoryPath]
		stringByAppendingPathComponent: @"TestBundle.bundle"];

	testBundle = [[NSBundle alloc] initWithPath: testBundlePath];
    NSAssert1(testBundle != nil, @"Found not test bundle at %@", testBundlePath);
	[testBundle load];
#endif

	return self;
}

- (void)dealloc
{
	[testBundle release];
    [reportedException release];
    [reportedTestClass release];
    [reportedMethodName release];
	[super dealloc];
}

- (void)reportException: (NSException *)exception
                inClass: (Class)testClass
                   hint: (NSString *)hint
{
    [reportedException autorelease];
    [reportedTestClass autorelease];
    [reportedMethodName autorelease];
    reportedException = [exception retain];
    reportedTestClass = [testClass retain];
    reportedMethodName = [hint retain];
}

- (void)testRunLoopAddition
{
	NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
	[runLoop performSelector: @selector(runLoopTrigger)
	                  target: self
	                argument: nil
	                   order: 0
	                   modes: [NSArray arrayWithObject: NSDefaultRunLoopMode]];
}

- (void)runLoopTrigger
{
	NSThread *thread = [NSThread currentThread];
	[[thread threadDictionary] setObject: @"YES" forKey: @"UKLoopTriggerRan"];
}

- (void)testRunLoopAdditionExecuted
{
    NSThread *thread = [NSThread currentThread];
    NSString *result = [[thread threadDictionary] objectForKey: @"UKLoopTriggerRan"];

    UKStringsEqual(result, @"YES");

    [[thread threadDictionary] removeObjectForKey:@"UKLoopTriggerRan"];
}

- (void)testRunLoopMode
{
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    UKStringsEqual([runLoop currentMode], NSDefaultRunLoopMode);
    
}

#if !(TARGET_OS_IPHONE)
- (void)testClassesFromBundle
{
    NSArray *testClasses = UKTestClasseNamesFromBundle(testBundle);

    UKIntsEqual(2, [testClasses count]);
    UKTrue([testClasses containsObject: @"TestTwo"]);
    UKTrue([testClasses containsObject: @"TestThree"]);

    UKFalse(randomObjectInitialized);
#ifdef GNUSTEP
    UKFalse(testedObjectInitialized);
#else
	UKTrue(testedObjectInitialized);
#endif
}
#endif

- (void)testMethodNamesFromClass
{
    NSArray *testMethods = UKTestMethodNamesFromClass(NSClassFromString(@"TestTwo"));

    UKIntsEqual(3, [testMethods count]);
    UKTrue([testMethods containsObject: @"testOne"]);
    UKTrue([testMethods containsObject: @"testTwo"]);
    UKTrue([testMethods containsObject: @"testThree"]);
}

- (void)testReportInitException
{
	UKRunner *runner = [[UKRunner alloc] init];
	[handler setDelegate: self];

	UKDoesNotRaiseException([runner runTests: [NSArray arrayWithObject: @"testEmpty"]
                                  onInstance: YES
                                     ofClass: [TestObjectInit class]]);

	UKStringsEqual(@"For exception in init", [reportedException reason]);
	UKObjectsEqual([TestObjectInit class], reportedTestClass);
    UKStringsEqual(@"errExceptionOnInit", reportedMethodName);

    [handler setDelegate: nil];
    [runner release];
}

- (void)testReportDeallocException
{
	UKRunner *runner = [[UKRunner alloc] init];
	[handler setDelegate: self];

	UKDoesNotRaiseException([runner runTests: [NSArray arrayWithObject: @"testEmpty"]
                                  onInstance: YES
                                     ofClass: [TestObjectDealloc class]]);

	UKStringsEqual(@"For exception in dealloc", [reportedException reason]);
	UKObjectsEqual([TestObjectDealloc class], reportedTestClass);
    UKStringsEqual(@"errExceptionOnRelease", reportedMethodName);

    [handler setDelegate: nil];
    [runner release];
}

- (void)testReportTestMethodException
{
	UKRunner *runner = [[UKRunner alloc] init];
	[handler setDelegate: self];

	UKDoesNotRaiseException([runner runTests: [NSArray arrayWithObject: @"testRaisesException"]
                                  onInstance: YES
                                     ofClass: [TestObjectTestMethod class]]);

	UKStringsEqual(@"For exception in test method", [reportedException reason]);
	UKObjectsEqual([TestObjectTestMethod class], reportedTestClass);
    UKStringsEqual(@"testRaisesException", reportedMethodName);

    [handler setDelegate: nil];
    [runner release];
}

/*
- (void) testBundleInOutsideExecution
{
    NSString *ukrunPath = [[[NSFileManager defaultManager] currentDirectoryPath] stringByAppendingPathComponent:@"ukrun"];
    UKTask *task = [[UKTask alloc] init];
    [task setLaunchPath:ukrunPath];
    [task setArguments:[NSArray arrayWithObjects:[[[NSFileManager defaultManager] currentDirectoryPath] stringByAppendingPathComponent:@"TestBundle.bundle"], nil]];
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
