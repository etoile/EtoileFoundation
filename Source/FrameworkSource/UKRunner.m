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

/* For GNUstep, but we should check if it is really needed */
#import <Foundation/NSException.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSTimer.h>
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
		// XXX i18n as well as message improvements
		printf("\n == Test bundle '%s' could not be found ==\n\n", [[bundlePath lastPathComponent] UTF8String]);
		return nil; 
	}

    if ([[bundlePath pathExtension] isEqual: @"bundle"] == NO)
    {
 		printf("\n == Directory '%s' is not a test bundle ==\n\n", [[bundlePath lastPathComponent] UTF8String]);
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
		// XXX i18n as well as message improvements
		printf("\n == Test bundle could not be loaded: %s ==\n\n", [[error description] UTF8String]);
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

	printf("Looking for bundle at path: %s\n", [bundlePath UTF8String]);

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSBundle *testBundle = [self loadBundleAtPath: bundlePath];

	if (testBundle != nil)
	{
		[self runTests: testClasses inBundle: testBundle principalClass: nil];
	}
	[pool release];
}

+ (int) runTests
{    
    /*
     We expect the following usage:
          $ ukrun [BundleName]
     
     If there are no arguments given, then we'll just execute every 
     test class found. Otherwise
     */

	printf("ukrun version 1.3 (Etoile)\n"); // XXX replace with a real auto version

    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSString *cwd = [[NSFileManager defaultManager] currentDirectoryPath];
    UKRunner *runner = [[UKRunner alloc] init];

    //printf("cwd: %s\n", [cwd UTF8String]);

	NSArray *bundleDicts = [runner parseArgumentsWithCurrentDirectory: cwd];

	// Return an error if an error occurs
	if (nil == bundleDicts)
	{
		return -1;
	}
	// If no bundles are specified, then just run every bundle in this folder
	else if ([bundleDicts count] == 0)
	{
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

    if ([args count] >= 2) 
	{
        // Mark Dalrymple contributed this bit about going quiet.
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
    }
	return bundlePaths;
}

- (int) reportTestResults
{
    int testsPassed = [[UKTestHandler handler] testsPassed];
    int testsFailed = [[UKTestHandler handler] testsFailed];
	int exceptionsReported = [[UKTestHandler handler] exceptionsReported];
    
    // TODO: XXX i18n and may be extract in -testResultSummary
    printf("Result: %i classes, %i methods, %i tests, %i failed, %i exceptions\n", 
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
	Class testClass = [testParameters objectForKey: @"TestClass"];
        @try {
		[testObject performSelector: testSel];
        }
        @catch (id exc) {
                [[UKTestHandler handler] reportException: exc inClass: testClass hint: @"errExceptionInTestMethod"];
        }
}
- (void) runTest: (SEL)testSelector onObject: (id)testObject class: (Class)testClass
{
	NSLog(@"=== [%@ %@] ===", [testObject class], NSStringFromSelector(testSelector));
	NSRunLoop *runLoop = [NSRunLoop currentRunLoop];

	/*[runLoop performSelector: testSelector 
	                  target: testObject 
 	                argument: nil 
 	                   order: 0 
	                   modes: [NSArray arrayWithObject:NSDefaultRunLoopMode]];
	// NOTE: nil, [NSDate date] or LDBL_EPSILON don't work on GNUstep
	[runLoop runUntilDate: nil]; //[NSDate dateWithTimeIntervalSinceNow: 0.0001]];
	*/
	NSDictionary *testParams = [NSDictionary dictionaryWithObjectsAndKeys: testObject, @"TestObject", 
		NSStringFromSelector(testSelector), @"TestSelector",
		testClass, @"TestClass", nil];
	NSTimer *runTimer = [NSTimer
		scheduledTimerWithTimeInterval: 0.0
		                        target: self
		                      selector: @selector(internalRunTest:)
		                      userInfo: testParams
		                       repeats: NO];
	[runTimer retain];
	while ([runTimer isValid] == YES)
	{
		[runLoop runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 0.1]];
	}
	[runTimer release];
	/* The code below is unsupported on GNUstep and this doesn't seem to matter

	CFRunLoopRef cfRunLoop = [runLoop getCFRunLoop];
	
	while (CFRunLoopIsWaiting(cfRunLoop))
	{
		[runLoop runUntilDate: nil];
	}*/
}

/*!
 @method runTests:onObject:
 @param testMethods An array containing the list of method names to execute on the test object.
 @param testObject The instance or the class object on which to perform the test methods on
 @abstract Runs a set of tests on the given object (either an instance or a class)
 @discussion This method takes an object and a list of methods that should be executed on it. For each method in the list, the test object will be initialized by -initForTest when implemented or -init as a fallback and the method called on it. If there is a problem with the initialization, or in the release of that object instance, an error will be reported and all test execution on the object will end. If there is an error while running the test method, an error will be reported and execution will move on to the next method.
 */

- (void) runTests:(NSArray *)testMethods onObject:(id)testObject
{
    /*
     The hairy thing about this method is catching and dealing with all of 
     the permutations of uncaught exceptions that might be heading our way. 
     */
	 
    //NSLog(@"testObject %@", testObject);
    
    Class testClass = nil;
    NSEnumerator *e = [testMethods objectEnumerator];
    NSString *testMethodName;

    BOOL isClass = testObject != nil && object_getClass(testObject) != nil 
		&& class_isMetaClass(object_getClass(testObject));

    id object = nil;

    /* We use local variable so that the testObject will not be messed up.
       And we have to distinguish class and instance
       because -init and -release apply to instance.
       And -release also dealloc object, which will cause memory problem */
    /* FIXME: there is a memory leak because testObject comes 
       here as allocated to tell whether it is class or instance.
       We can dealloc it here, but it is not really a good practice.
       Object is better to be pass as autoreleased. */

    if (isClass)
    {
	testClass = testObject;
	object = testClass;
    }
    else
    {
	testClass = [testObject class];
        /* It is instance, we instantiate it and release it in the loop */
    }

    while ((testMethodName = [e nextObject])) {
        testMethodsRun++;
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

#ifdef NEW_EXCEPTION_MODEL

        if (isClass == NO)
        {
            object = [testClass alloc];
            @try {
                 object = [object init];
            }
            @catch (id exc) {
                [[UKTestHandler handler] reportException: exc inClass: testClass hint: @"errExceptionOnInit"];
                [pool release];
                return;
           }
        } 

        @try {
            SEL testSel = NSSelectorFromString(testMethodName);
	    NSAutorelease *testMethodPool = [NSAutoreleasePool new];
            [self runTest:testSel onObject: object class: testClass];
	    [testMethodPool release];
        }
        @catch (id exc) {
                [[UKTestHandler handler] reportException: exc inClass: testClass hint: @"errExceptionInTestMethod"];
        }
        
        if (isClass == NO)
        {
            @try {
                [object release];
            }
            @catch (id exc) {
                [[UKTestHandler handler] reportException: exc inClass: testClass hint: @"errExceptionOnRelease"];
                [pool release];
                return;
            }
        }

#else

        NS_DURING
	{
	    if (isClass == NO)
	    {
		object = [testClass alloc];
		if ([object respondsToSelector: @selector(initForTest)])
		{
			object = [object initForTest];
		}
		else if ([object respondsToSelector: @selector(init)])
		{
			object = [object init];
		}
	    }
	}
        NS_HANDLER
	{
            [[UKTestHandler handler] reportException: localException inClass: testClass hint: @"errExceptionOnInit"];
            [pool release];
            NS_VOIDRETURN;	
	}
        NS_ENDHANDLER
        
        NS_DURING
	{
            SEL testSel = NSSelectorFromString(testMethodName);
	    /* This pool makes easier to separate autorelease issues between:
	       - test method
	       - test object configuration due to -init and -dealloc 

	       For testing CoreObject, this also ensures all autoreleased 
	       objects in relation to a db are deallocated before closing the 
	       db connection in -dealloc (see TestCommon.h in CoreObject for details) */
            NSAutoreleasePool *testMethodPool = [NSAutoreleasePool new];
            [self runTest: testSel onObject: object class: testClass];
	    [testMethodPool release];
	}
        NS_HANDLER
	{
            [[UKTestHandler handler] reportException: localException inClass: testClass hint: @"errExceptionInTestMethod"];
	    [pool release];
	    NS_VOIDRETURN;
	}
        NS_ENDHANDLER
        
        NS_DURING
	{
	    if (isClass == NO)
	    {
		if ([object respondsToSelector: @selector(releaseForTest)])
		{
		    [object releaseForTest];
		}
		else if ([testObject respondsToSelector: @selector(release)])
		{
		    [object release];
		}
		object = nil;
	    }
	}
        NS_HANDLER
	{
            [[UKTestHandler handler] reportException: localException inClass: testClass hint: @"errExceptionOnRelease"];
            [pool release];
            NS_VOIDRETURN;
	}
        NS_ENDHANDLER
        
#endif        
        [pool release];
    }
}

- (void) runTestsInClass:(Class)testClass
{
    testClassesRun++;

    NSArray *testMethods = nil;

    /* Test class methods */

	if (testClass != nil)
		testMethods = UKTestMethodNamesFromClass(objc_getMetaClass(class_getName(testClass)));
    
    [self runTests:testMethods onObject:testClass];
    /* Test instance methods */
    testMethods = UKTestMethodNamesFromClass(testClass);
    [self runTests:testMethods onObject: [testClass alloc]];
}

- (void) runTestsInBundle: (NSBundle *)bundle principalClass: (Class)principalClass
{
    [self runTests: nil inBundle: bundle principalClass: principalClass];
}

- (void) runTests: (NSArray*)testedClasses
         inBundle: (NSBundle*)bundle
   principalClass: (Class)principalClass
{

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

    // NOTE: First we must create the app object, because on Mac OS X in
	// UKTestClasseNamesFromBundle(), we have -bundleForClass: that invokes
	// class_respondsToSelector() which results in +initialize being called and
	// +[NSWindowBinder initialize] has the bad idea to use +sharedApplication.
	// When no app object is available yet, an NSApplication instance will be
	// created rather than the subclass instance we might want.
    NSArray *testClasses = (testedClasses == nil ? UKTestClasseNamesFromBundle(bundle) : testedClasses);
    NSEnumerator *e = [testClasses objectEnumerator];
    NSString *testClassName;

    while ((testClassName = [e nextObject])) {
        [self runTestsInClass:NSClassFromString(testClassName)];
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
    NSMutableArray *testClasseNames = [[NSMutableArray alloc] init];
    

    /*
     I found the code to walk the classes in the system from an example in
     Apple's documentation. Pretty much all I changed was the bit that tested
     which bundle a class came from and that it implements the UKTest protocol.
     It's a bit low level (hell, there's a malloc and free here!), but there
     doesn't seem to be any easier way to get a list of classes from a bundle.
     
     I keep thinking that this kind of functionality could be factored out
     into a general "What classes are in which bundles and what classes 
     implement what protocols. But so far I've resisted the urge.
     */    
    
    int numClasses;
    numClasses = objc_getClassList(NULL, 0);
    if (numClasses > 0) {
        Class *classes = malloc(sizeof(Class) * numClasses);
        (void) objc_getClassList (classes, numClasses);
        int i;
        for (i = 0; i < numClasses; i++) {
            Class c = classes[i];
            NSBundle *classBundle = [NSBundle bundleForClass:c];

			/* Using class_conformsToProtocol() intead of +conformsToProtocol: 
			   does not require sending a message to the class. This prevents 
			   +initialize being sent to classes that are not explicitly used. */	 
            if (bundle == classBundle && UKTestClassConformsToProtocol(c)) {
                [testClasseNames addObject:NSStringFromClass(c)];
            }
        }
        free(classes);
    }    
    
    [testClasseNames autorelease];
    return [testClasseNames
        sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

NSArray *UKTestMethodNamesFromClass(Class c)
{
    NSMutableArray *testMethods = [NSMutableArray array];
    
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

    return [testMethods 
        sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}
