/*
	Copyright (C) 2004 James Duncan Davidson, Nicolas Roard, Quentin Mathe, Christopher Armstrong, Eric Wasylishen

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

#import "UKRunner.h"
#import "UKTest.h"
#import "UKTestHandler.h"

#include <objc/runtime.h>

// NOTE: From EtoileFoundation/Macros.h
#define INVALIDARG_EXCEPTION_TEST(arg, condition) do { \
	if (NO == (condition)) \
	{ \
		[NSException raise: NSInvalidArgumentException format: @"For %@, %s " \
			"must respect %s", NSStringFromSelector(_cmd), #arg , #condition]; \
	} \
} while (0);
#define NILARG_EXCEPTION_TEST(arg) do { \
	if (nil == arg) \
	{ \
		[NSException raise: NSInvalidArgumentException format: @"For %@, " \
			"%s must not be nil", NSStringFromSelector(_cmd), #arg]; \
	} \
} while (0);


@implementation UKRunner

#pragma mark - Localization Support

+ (NSString *)localizedString: (NSString *)key
{
	NSBundle *bundle = [NSBundle bundleForClass: [self class]];
	return NSLocalizedStringFromTableInBundle(key, @"UKRunner", bundle, @"");
}

+ (NSString *)displayStringForException: (id)exc
{
	if ([exc isKindOfClass: [NSException class]])
	{
		return [NSString stringWithFormat: @"NSException: %@ %@",
		                                   [exc name], [exc reason]];
	}
	else
	{
		return NSStringFromClass([exc class]);
	}
}

/**
 * For now, we still support -classRegex as an alias to -c.
 *
 * This options read with NSUserDefaults is overwritten by 
 * -parseArgumentsWithCurrentDirectory:. This NSUserDefaults use should probably 
 * be removed at some point.
 */
- (NSString *)classRegexFromArgumentDomain
{
	NSDictionary *argumentDomain = [[NSUserDefaults standardUserDefaults] 
    	volatileDomainForName: NSArgumentDomain];
	NSString *regex = [argumentDomain objectForKey: @"c"];

    if (regex != nil)
    	return regex;

    return [argumentDomain objectForKey: @"classRegex"];
}

- (id)init
{
	self = [super init];
	if (self == nil)
    	return nil;

   	classRegex = [[self classRegexFromArgumentDomain] copy];
    return self;
}


- (void)dealloc
{
	[classRegex release];
    [super dealloc];
}

#pragma mark - Settings

- (NSString *)classRegex
{
	return classRegex;
}

- (void)setClassRegex: (NSString *)aRegex
{
	[classRegex autorelease];
    classRegex = [aRegex copy];
}

#pragma mark - Loading Test Bundles

- (id)loadBundleAtPath: (NSString *)bundlePath
{
	NSBundle *testBundle = [NSBundle bundleWithPath: bundlePath];

	if (testBundle == nil)
	{
		NSLog(@"\n == Test bundle '%@' could not be found ==\n", [bundlePath lastPathComponent]);
		return nil;
	}

	if (![[bundlePath pathExtension] isEqual: [self testBundleExtension]])
	{
		NSLog(@"\n == Directory '%@' is not a test bundle ==\n", [bundlePath lastPathComponent]);
	}

	NSError *error = nil;

	/* For Mac OS X (10.8), the test bundle info.plist must declare a principal
	   class, to prevent +load from instantiating NSApp. */
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

- (NSString *)testBundleExtension
{
	return @"bundle";
}

- (NSArray *)bundlePathsInCurrentDirectory: (NSString *)cwd
{
	NSError *error = nil;
	NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: cwd
	                                                                     error: &error];
	NSAssert(error == nil, [error description]);

	return [files filteredArrayUsingPredicate:
    	[NSPredicate predicateWithFormat: @"pathExtension == %@", [self testBundleExtension]]];
}

- (NSArray *)bundlePathsFromArgumentsAndCurrentDirectory: (NSString *)cwd
{
	NSArray *bundlePaths = [self parseArgumentsWithCurrentDirectory: cwd];
	NSAssert(bundlePaths != nil, @"");
	BOOL hadBundleInArgument = ([bundlePaths count] > 0);

	if (hadBundleInArgument)
    	return bundlePaths;

	/* If no bundles is specified, then just collect every bundle in this folder */
	return [self bundlePathsInCurrentDirectory: cwd];
}

#pragma mark - Tool Support

+ (int)runTests
{
	NSString *version = [[[NSBundle bundleForClass: self] infoDictionary]
    	objectForKey: @"CFBundleShortVersionString"];

	NSLog(@"UnitKit version %@ (Etoile)", version);

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	UKRunner *runner = [[UKRunner alloc] init];

	NSString *cwd = [[NSFileManager defaultManager] currentDirectoryPath];

	for (NSString *bundlePath in [runner bundlePathsFromArgumentsAndCurrentDirectory: cwd])
	{
		[runner runTestsInBundleAtPath: bundlePath
		              currentDirectory: cwd];
	}

	int result = [runner reportTestResults];

	[runner release];
	[pool release];

	return result;
}

/**
 * Don't try to parse options without value e.g. -q with NSUserDefaults, 
 * otherwise the option will be ignored or its value set to the next argument. 
 * For example, the NSArgumentDomain dictionary would be:
 *
 * 'ukrun -q' => { }
 * 'ukrun -q TestBundle.bundle' => { -q = TestBundle.bundle }
 */
- (NSArray *)parseArgumentsWithCurrentDirectory: (NSString *)cwd
{
	NSArray *args = [[NSProcessInfo processInfo] arguments];
	NSMutableArray *bundlePaths = [NSMutableArray array];
	BOOL noOptions = ([args count] <= 1);

	if (noOptions)
		return bundlePaths;
	
	for (int i = 1; i < [args count]; i++)
	{
		NSString *arg = [args objectAtIndex: i];

		/* We parse all supported options to skip them and process the test 
		   bundle list at the end */
		if ([arg isEqualToString: @"-q"])
		{
			[[UKTestHandler handler] setQuiet: YES];
		}
		else if ([arg isEqualToString: @"-c"] || [arg isEqualToString: @"-classRegex"])
		{
            i++;

            if (i >= [args count] || [[args objectAtIndex: i] hasPrefix: @"-"])
			{
				NSLog(@"-c argument must be followed by a test class regex");
				exit(-1);
			}

			[self setClassRegex: [args objectAtIndex: i]];
		}
		else
		{
			[bundlePaths addObject: [args objectAtIndex: i]];
		}
	}
	return bundlePaths;
}

- (void)runTestsInBundleAtPath: (NSString *)bundlePath
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
		[self runTestsInBundle: testBundle];
	}
	[pool release];
}

#pragma mark - Running Test Method

- (void)internalRunTest: (NSTimer *)timer
{
	NSDictionary *testParameters = [timer userInfo];
	SEL testSel = NSSelectorFromString([testParameters objectForKey: @"TestSelector"]);
	id testObject = [testParameters objectForKey: @"TestObject"];

	[testObject performSelector: testSel];
}

- (void)runTest: (SEL)testSelector onObject: (id)testObject class: (Class)testClass
{
	NSLog(@"=== [%@ %@] ===", [testObject class], NSStringFromSelector(testSelector));

	NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
	NSDictionary *testParams = [NSDictionary dictionaryWithObjectsAndKeys:
		testObject, @"TestObject",
		NSStringFromSelector(testSelector), @"TestSelector",
	 	testClass, @"TestClass", nil];
	NSTimer *runTimer = [NSTimer scheduledTimerWithTimeInterval: 0
	                                                     target: self
	                                                   selector: @selector(internalRunTest:)
	                                                   userInfo: testParams
	                                                    repeats: NO];

	[runTimer retain];

	while ([runTimer isValid])
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

#pragma mark - Creating Test Object

- (id)newTestObjectOfClass: (Class)testClass
{
	id object = [testClass alloc];

	@try
	{
		object = [object init];
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
		[object release];
		object = nil;
	}
	@catch (NSException *exception)
	{
		[[UKTestHandler handler] reportException: exception
		                                 inClass: [object class]
			                                hint: @"errExceptionOnRelease"];
	}
}

#pragma mark - Running Tests

- (void)runTests: (NSArray *)testMethods onInstance: (BOOL)instance ofClass: (Class)testClass
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

				// N.B.: If -init throws an exception or returns nil, we don't
				// attempt to run any more methods on this class
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
				   objects in relation to a db are deallocated before closing 
				   the db connection in -dealloc (see TestCommon.h in CoreObject 
				   for details) */
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

- (void)runTestsInClass: (Class)testClass
{
	testClassesRun++;

	NSArray *testMethods = nil;

	/* Test class methods */

	if (testClass != nil)
	{
		testMethods = UKTestMethodNamesFromClass(objc_getMetaClass(class_getName(testClass)));
	}
	[self runTests: testMethods onInstance: NO ofClass: testClass];

	/* Test instance methods */

	testMethods = UKTestMethodNamesFromClass(testClass);
	[self runTests: testMethods onInstance: YES ofClass: testClass];
}

- (NSArray *)filterTestClassNames: (NSArray *)testClassNames
{
	NSMutableArray *filteredClassNames = [NSMutableArray array];

	for (NSString *className in testClassNames)
	{
		if (classRegex == nil  || [className rangeOfString: [self classRegex]
                                                   options: NSRegularExpressionSearch].location != NSNotFound)
		{
			[filteredClassNames addObject: className];
		}
	}

	return filteredClassNames;
}

- (void)runTestsInBundle: (NSBundle *)bundle
{
	NILARG_EXCEPTION_TEST(bundle);

	[self runTestsWithClassNames: nil
                        inBundle: bundle
                  principalClass: [bundle principalClass]];
}

- (void)runTestsWithClassNames: (NSArray *)testClassNames
                principalClass: (Class)principalClass
{
	NILARG_EXCEPTION_TEST(testClassNames);

	[self runTestsWithClassNames: testClassNames
                        inBundle: nil
                  principalClass: principalClass];
}

/**
 * We must call UKTestClasseNamesFromBundle() after +willRunTestSuite, otherwise 
 * the wrong app object can be created in a UI related test suite on Mac OS X...
 * 
 * On Mac OS X, we have -bundleForClass: that invokes class_respondsToSelector() 
 * which results in +initialize being called, and +[NSWindowBinder initialize] 
 * has the bad idea to use +sharedApplication. 
 * When no app object is available yet, an NSApplication instance will be 
 * created rather than the subclass instance we might want.
 *
 * This is why we don't call UKTestClasseNamesFromBundle() in
 * -runTestsInBundle:principalClass:. 
 */
- (void)runTestsWithClassNames: (NSArray *)testClassNames
                      inBundle: (NSBundle *)bundle
                principalClass: (Class)principalClass
{
	if ([principalClass respondsToSelector: @selector(willRunTestSuite)])
	{
		[principalClass willRunTestSuite];
	}

	NSArray *classNames =
    		(testClassNames != nil ? testClassNames : UKTestClasseNamesFromBundle(bundle));

	for (NSString *className in [self filterTestClassNames: classNames])
	{
        [self runTestsInClass: NSClassFromString(className)];
	}

	if ([principalClass respondsToSelector: @selector(didRunTestSuite)])
	{
		[principalClass didRunTestSuite];
	}
}

#pragma mark - Reporting Test Results

- (int)reportTestResults
{
	int testsPassed = [[UKTestHandler handler] testsPassed];
	int testsFailed = [[UKTestHandler handler] testsFailed];
	int exceptionsReported = [[UKTestHandler handler] exceptionsReported];

	// TODO: May be be extract in -testResultSummary
	NSLog(@"Result: %i classes, %i methods, %i tests, %i failed, %i exceptions",
	  testClassesRun, testMethodsRun, (testsPassed + testsFailed), testsFailed, exceptionsReported);

	return (testsFailed == 0 && exceptionsReported == 0 ? 0 : -1);
}

@end

BOOL UKTestClassConformsToProtocol(Class aClass)
{
	Class class = aClass;
	BOOL isTestClass = NO;

	while (class != Nil && !isTestClass)
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

	return [testMethods sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
}
