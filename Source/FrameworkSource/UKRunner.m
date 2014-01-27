/*
 This source is part of UnitKit, a unit test framework for Mac OS X 
 development. You can find more information about UnitKit at:
 
 http://x180.net/Code/UnitKit
 
 Copyright (c)2004 James Duncan Davidson
 
 Contributions by Mark Dalrymple, Nicolas Roard, Quentin mathe
 
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

#import "UKRunner.h"
#import "UKTest.h"
#import "UKTestHandler.h"

/* For -pathForImageResource: */
#import <AppKit/AppKit.h>

#include <objc/runtime.h>

@interface NSObject (Application)
+ (id) sharedApplication;
- (void) setUp;
@end


@implementation UKRunner

+ (NSString *) localizedString:(NSString *)key
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    return NSLocalizedStringFromTableInBundle(key, @"UKRunner", 
                                              bundle, @"");
}

+ (NSString *) displayStringForException:(id)exc
{
    if ([exc isKindOfClass:[NSException class]]) {
        return [NSString stringWithFormat:@"NSException: %@ %@", [exc name],
            [exc reason]];
    } else {
        return NSStringFromClass([exc class]);
    }
}

- (id) init
{
	self = [super init];
	if (self == nil)
		return nil;

	setUpClasses = [[NSMutableSet alloc] init];
	return self;
}

- (void) dealloc
{
	[setUpClasses release];
	[super dealloc];
}

- (id) loadBundleAtPath: (NSString *)bundlePath
{
    NSBundle *testBundle = [NSBundle bundleWithPath: bundlePath];
	
	if (testBundle == nil)
	{
		NSLog(@"\n == Test bundle '%@' could not be found ==\n", [bundlePath lastPathComponent]);
		return nil; 
	}

    if ([[bundlePath pathExtension] isEqual: @"bundle"] == NO)
    {
 		NSLog(@"\n == Directory '%@' is not a test bundle ==\n", [bundlePath lastPathComponent]);
    }

    NSError *error = nil;

    /* For Mac OS X (10.8), the test bundle info.plist must declare a principal 
       class, to prevent +load from instantiating NSApp (see -setUpAppObjectIfNeededForBundle:). */
#ifdef GNUSTEP
    if (![testBundle load])
#else
	if (![testBundle loadAndReturnError: &error])
#endif
	{
		NSLog(@"\n == Test bundle could not be loaded: %@ ==\n", [error description]);
		return nil;            
	}
	return testBundle;
}

- (NSArray *) bundlePathsInCurrentDirectory: (NSString *)cwd
{
	NSMutableArray *bundlePaths = [NSMutableArray array];
	NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: cwd error: NULL];

	for (NSString *file in files)
	{
		BOOL isDir = NO;
		if ([[NSFileManager defaultManager] fileExistsAtPath: file isDirectory: &isDir] && isDir)
		{
			int len = [file length];
	
			if (len > 8 
			 && [[file substringFromIndex: (len - 6)] isEqualToString: @"bundle"])
			{
				[bundlePaths addObject: file];
			}
		}
	}
	return bundlePaths;
}

- (void) runTests: (NSArray*)testClasses 
   inBundleAtPath: (NSString *)bundlePath 
 currentDirectory: (NSString *)cwd
{
	bundlePath = [bundlePath stringByExpandingTildeInPath];

	if (![bundlePath isAbsolutePath])
	{
		bundlePath = [cwd stringByAppendingPathComponent: bundlePath];
		bundlePath = [bundlePath stringByStandardizingPath];
	}

	NSLog(@"Looking for bundle at path: %@", bundlePath);

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSBundle *testBundle = [self loadBundleAtPath: bundlePath];

	if (testBundle != nil)
	{
		[self runTests: testClasses inBundle: testBundle principalClass: [testBundle principalClass]];
	}
	[pool release];
}

+ (NSString *)ukrunVersion
{
	return @"1.3";
}

+ (int) runTests
{
	NSLog(@"ukrun version %@ (Etoile)", [self ukrunVersion]);

    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSString *cwd = [[NSFileManager defaultManager] currentDirectoryPath];
    UKRunner *runner = [[UKRunner alloc] init];

    //NSLog(@"cwd: %@\n", cwd);

	NSArray *bundleDicts = [runner parseArgumentsWithCurrentDirectory: cwd];

	// Return an error if an error occurs
	if (nil == bundleDicts)
	{
		return -1;
	}
	else if ([bundleDicts count] == 0) // If no bundles are specified, then just run every bundle in this folder
	{
    	NSLog(@"Will run every bundle");
		NSArray *bundlePathsInCWD = [runner bundlePathsInCurrentDirectory: cwd];
		for (NSString *bundlePath in bundlePathsInCWD)
		{
			[(NSMutableArray*)bundleDicts addObject: 
				[NSDictionary dictionaryWithObject: bundlePath forKey: @"Bundle"]];
		}
	}

	for (NSDictionary *bundleDict in bundleDicts)
	{
		NSString *testBundle =[bundleDict objectForKey: @"Bundle"];
    		NSArray *testClasses = [bundleDict objectForKey: @"Classes"];	
		[runner runTests: testClasses
		  inBundleAtPath: testBundle 
		currentDirectory: cwd];
	}
	
	int result = [runner reportTestResults];

    [runner release];
    [pool release];

	return result;
}

- (NSArray *) parseArgumentsWithCurrentDirectory: (NSString *)cwd 
{
    NSArray *args = [[NSProcessInfo processInfo] arguments];
	NSMutableArray *bundlePaths = [NSMutableArray array];
	BOOL noOptions = ([args count] <= 1);

	if (noOptions)
		return bundlePaths;

	NSMutableDictionary *testBundleDict = nil;
        
	for (int i = 1; i < [args count]; i++)
	{
		NSString *arg = [args objectAtIndex: i];
		if ([arg isEqualToString: @"-q"])
		{
			[[UKTestHandler handler] setQuiet: YES];
		}
		else if ([arg isEqualToString: @"-c"])
		{
			if (++i >= [args count])
			{
				NSLog(@"-c argument must be followed by list of test classes");
				return nil;
			}
			arg = [args objectAtIndex: i];
			NSArray *testClasses = [arg componentsSeparatedByString: @","];
			[testBundleDict setObject: testClasses forKey: @"Classes"];
		}
		else
		{
			testBundleDict = [NSMutableDictionary dictionary];
			[testBundleDict setObject: [args objectAtIndex: i] forKey: @"Bundle"];
			[bundlePaths addObject: testBundleDict];
		}
	}
	return bundlePaths;
}

- (int) reportTestResults
{
    int testsPassed = [[UKTestHandler handler] testsPassed];
    int testsFailed = [[UKTestHandler handler] testsFailed];
	int exceptionsReported = [[UKTestHandler handler] exceptionsReported];
    
    // TODO: May be be extract in -testResultSummary
    NSLog(@"Result: %i classes, %i methods, %i tests, %i failed, %i exceptions",
		testClassesRun, testMethodsRun, (testsPassed + testsFailed), testsFailed, exceptionsReported);

#ifndef GNUSTEP
    [[self class] performGrowlNotification: testsPassed :testsFailed :exceptionsReported :testClassesRun :testMethodsRun];
#endif

    return (testsFailed == 0 && exceptionsReported == 0 ? 0 : -1);
}

#ifndef GNUSTEP
+ (void) performGrowlNotification
:(int) testsPassed 
:(int) testsFailed
:(int) exceptionsReported
:(int) testClassesRun
:(int) testMethodsRun
{
    NSString *title;
    
    if (testsFailed == 0 && exceptionsReported == 0) {
        title = @"UnitKit Test Run Passed";
    } else {
        title = @"UnitKit Test Run Failed";
    }
    
    NSString *msg = [NSString stringWithFormat:
					 @"%i test classes, %i methods\n%i assertions passed, %i failed, %i exceptions",
					 testClassesRun, testMethodsRun,  testsPassed, testsFailed, exceptionsReported];
	
    NSMutableDictionary *notiInfo = [NSMutableDictionary dictionary];
    [notiInfo setObject:@"UnitKit Notification" forKey:@"NotificationName"];
    [notiInfo setObject:@"UnitKit" forKey:@"ApplicationName"];
    [notiInfo setObject:title forKey:@"NotificationTitle"];
    [notiInfo setObject:msg forKey:@"NotificationDescription"];
    
    NSString *iconPath;
    
    if (testsFailed == 0) {
        iconPath = [[NSBundle bundleForClass:[self class]]
					pathForImageResource:@"Icon-Pass"];
    } else {
        iconPath = [[NSBundle bundleForClass:[self class]]
					pathForImageResource:@"Icon-Fail"];
    }
    
    NSData *icon = [NSData dataWithContentsOfFile:iconPath];
    
    [notiInfo setObject:icon forKey:@"NotificationIcon"];
    
    [[NSDistributedNotificationCenter defaultCenter]
	 postNotificationName:@"GrowlNotification" 
	 object:nil userInfo:notiInfo];    
}
#endif

- (void) internalRunTest: (NSTimer*)timer
{
	NSDictionary* testParameters = [timer userInfo];
	SEL testSel = NSSelectorFromString([testParameters objectForKey: @"TestSelector"]);
	id testObject = [testParameters objectForKey: @"TestObject"]; 

    [testObject performSelector: testSel];
}
- (void) runTest: (SEL)testSelector onObject: (id)testObject class: (Class)testClass
{
	NSLog(@"=== [%@ %@] ===", [testObject class], NSStringFromSelector(testSelector));

	NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
	NSDictionary *testParams = [NSDictionary dictionaryWithObjectsAndKeys: testObject, @"TestObject", 
		NSStringFromSelector(testSelector), @"TestSelector",
		testClass, @"TestClass", nil];
	NSTimer *runTimer = [NSTimer
		scheduledTimerWithTimeInterval: 0
		                        target: self
		                      selector: @selector(internalRunTest:)
		                      userInfo: testParams
		                       repeats: NO];

	[runTimer retain];
	while ([runTimer isValid] == YES)
	{
		// NOTE: nil, [NSDate date], time intervals such as 0, 0.0000001 or
		// LDBL_EPSILON don't work on GNUstep
#ifdef GNUSTEP
		NSTimeInterval interval = 0.000001;
#else
		NSTimeInterval interval = 0;
#endif
		[runLoop runUntilDate: [NSDate dateWithTimeIntervalSinceNow: interval]];
	}
	[runTimer release];
}

- (id)newTestObjectOfClass: (Class)testClass
{
	id object = [testClass alloc];

	@try
	{
		if ([object respondsToSelector: @selector(initForTest)])
		{
			object = [object initForTest];
		}
		else if ([object respondsToSelector: @selector(init)])
		{
			object = [object init];
		}
	}
	@catch (NSException *exception)
	{
		[[UKTestHandler handler] reportException: exception
		                                 inClass: testClass
		                                    hint: @"errExceptionOnInit"];
		return nil;
	}

	return object;
}

- (void)releaseTestObject: (id)object
{
	@try
	{
		if ([object respondsToSelector: @selector(releaseForTest)])
		{
			[object releaseForTest];
		}
		else if ([object respondsToSelector: @selector(release)])
		{
			[object release];
		}
		object = nil;
	}
	@catch (NSException *exception)
	{
		[[UKTestHandler handler] reportException: exception
		                                 inClass: [object class]
		                                    hint: @"errExceptionOnRelease"];
	}
}

/*!
 @method runTests:onInstance:ofClass:
 @param testMethods An array containing the list of method names to execute on the test object.
 @param instance YES if testMethods contains instance method names that should be run on an instantiated testClass. NO if testMethods contains class method names that should be run directly on testClass
 @param testClass The instance or the class object on which to perform the test methods on
 @abstract Runs a set of tests on the given object (either an instance or a class)
 @discussion This method takes an object and a list of methods that should be executed on it. For each method in the list, the test object will be initialized by -initForTest when implemented or -init as a fallback and the method called on it. If there is a problem with the initialization, or in the release of that object instance, an error will be reported and all test execution on the object will end. If there is an error while running the test method, an error will be reported and execution will move on to the next method.
 */
- (void) runTests:(NSArray *)testMethods onInstance: (BOOL)instance ofClass:(Class)testClass
{
    for (NSString *testMethodName in testMethods)
    {
        testMethodsRun++;

        @autoreleasepool
        {
            id object = nil;
            
            // Create the object to test
            
            if (instance)
            {
				object = [self newTestObjectOfClass: testClass];

				// N.B.: If -init throws an exception or returns nil, we don't attempt to run any
				// more methods on this class
				if (object == nil)
					return;
            }
            else
            {
                object = testClass;
            }

            // Run the test method
            
            @try
            {
                SEL testSel = NSSelectorFromString(testMethodName);
                
                /* This pool makes easier to separate autorelease issues between:
                 - test method
                 - test object configuration due to -init and -dealloc
                 
                 For testing CoreObject, this also ensures all autoreleased
                 objects in relation to a db are deallocated before closing the
                 db connection in -dealloc (see TestCommon.h in CoreObject for details) */
                @autoreleasepool
                {
                    [self runTest: testSel onObject: object class: testClass];
                }
            }
            @catch (NSException *exception)
            {
                [[UKTestHandler handler] reportException: exception
				                                 inClass: testClass
				                                    hint: testMethodName];
            }

            // Release the object

            if (instance)
            {
				[self releaseTestObject: object];
            }
        }
    }
}

- (void) runTestsInClass:(Class)testClass
{
    testClassesRun++;

    NSArray *testMethods = nil;

    /* Test class methods */

	if (testClass != nil)
		testMethods = UKTestMethodNamesFromClass(objc_getMetaClass(class_getName(testClass)));
    
    [self runTests:testMethods onInstance: NO ofClass: testClass];
    /* Test instance methods */
    testMethods = UKTestMethodNamesFromClass(testClass);
    [self runTests:testMethods onInstance: YES ofClass: testClass];
}

- (void) runTestsInBundle: (NSBundle *)bundle principalClass: (Class)principalClass
{
    [self runTests: nil inBundle: bundle principalClass: principalClass];
}

- (void) runTests: (NSArray*)testedClasses
         inBundle: (NSBundle*)bundle
   principalClass: (Class)principalClass
{
    if ([principalClass respondsToSelector: @selector(willRunTestSuite)])
    {
        [principalClass willRunTestSuite];
    }

	// NOTE: First we must create the app object, because on Mac OS X in
	// UKTestClasseNamesFromBundle(), we have -bundleForClass: that invokes
	// class_respondsToSelector() which results in +initialize being called and
	// +[NSWindowBinder initialize] has the bad idea to use +sharedApplication.
	// When no app object is available yet, an NSApplication instance will be
	// created rather than the subclass instance we might want.
    BOOL setUpCalledOnAppObject = [self setUpAppObjectIfNeededForBundle: bundle];

	/* In addition, -setUp is also sent to the principal class */
	Class setUpClass = (principalClass != nil ? principalClass : [bundle principalClass]);
	BOOL setUpCalled = (setUpCalledOnAppObject 
		&& [principalClass isKindOfClass: NSClassFromString(@"NSApplication")]
		&& [setUpClasses containsObject: setUpClass] == NO );

	if (setUpCalled == NO && [setUpClass respondsToSelector: @selector(setUp)])
	{
		[setUpClass setUp];
		[setUpClasses addObject: setUpClass];
	}

    NSArray *testClasses = (testedClasses == nil ? UKTestClasseNamesFromBundle(bundle) : testedClasses);

	for (NSString *testClassName in testClasses)
	{
		[self runTestsInClass: NSClassFromString(testClassName)];
	}

    if ([principalClass respondsToSelector: @selector(didRunTestSuite)])
    {
        [principalClass didRunTestSuite];
    }
}

/* GNUstep doesn't take care of calling -[NSApp sharedApplication] if your code 
   doesn't. Unlike Cocoa, it just raises an exception if you try to create a 
   window. 
   By decreasing order of priority, this method tries to create an app
   instance by sending -sharedApplication to:
   - The principal class of the test bundle (declared in the bundle property list)
   - ETApplication 
   - NSApplication
*/
- (BOOL) setUpAppObjectIfNeededForBundle: (NSBundle *)testBundle
{
	Class appClass = NSClassFromString(@"NSApplication");
	Class etAppClass = NSClassFromString(@"ETApplication");

	if (appClass == Nil) /* AppKit and EtoileUI not loaded */
	{
		return NO;
	}
	else if (etAppClass != Nil) /* EtoileUI loaded */
	{
		appClass = etAppClass;
	}

	Class principalClass = [testBundle principalClass];

	/* Use NSApplication subclass if declared as the bundle principal class */
	if ([principalClass isKindOfClass: appClass])
		appClass = principalClass;

	id app = [appClass sharedApplication];
    NSAssert([app isKindOfClass: appClass], @"+sharedApplication returns an app "
        "object of the wrong kind, this usually means +sharedApplication has "
        "been sent before. For Mac OS X, the test bundle info.plist must declare "
        "a principal class to ensure loading the bundle won't instantiate NSApp.");

	if ([app respondsToSelector: @selector(setUp)] && [setUpClasses containsObject: appClass] == NO)
	{
		[app setUp];
		[setUpClasses addObject: appClass];
		return YES;
	}
	return NO;
}

@end

BOOL UKTestClassConformsToProtocol(Class aClass)
{
	Class class = aClass;
	BOOL isTestClass = NO;

	while (class != Nil && isTestClass == NO)
	{
		isTestClass = class_conformsToProtocol(class, @protocol(UKTest));
		class = class_getSuperclass(class);
	}
	return isTestClass;
}

NSArray *UKTestClasseNamesFromBundle(NSBundle *bundle)
{
	NSMutableArray *testClasseNames = [NSMutableArray array];
	int numClasses = objc_getClassList(NULL, 0);

	if (numClasses > 0)
	{
		Class *classes = malloc(sizeof(Class) * numClasses);

		objc_getClassList(classes, numClasses);

		for (int i = 0; i < numClasses; i++)
		{
			Class c = classes[i];
			NSBundle *classBundle = [NSBundle bundleForClass: c];

			/* Using class_conformsToProtocol() intead of +conformsToProtocol:
			   does not require sending a message to the class. This prevents
			   +initialize being sent to classes that are not explicitly used. */
			if (bundle == classBundle && UKTestClassConformsToProtocol(c))
			{
				[testClasseNames addObject: NSStringFromClass(c)];
			}
		}
		free(classes);
	}

	return [testClasseNames sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
}


NSArray *UKTestMethodNamesFromClass(Class sourceClass)
{
    NSMutableArray *testMethods = [NSMutableArray array];
    
    for (Class c = sourceClass; c != Nil; c = class_getSuperclass(c))
    {
        unsigned int methodCount = 0;
        Method *methodList = class_copyMethodList(c, &methodCount);
        Method method = NULL;

        for (int i = 0; i < methodCount; i++)
        {
            method = methodList[i];
            SEL sel = method_getName(method);
            NSString *methodName = NSStringFromSelector(sel);
        
            if ([methodName hasPrefix: @"test"])
            {
                [testMethods addObject: methodName];
            }
        }
        free(methodList);
    }
    
    return [testMethods 
        sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}
