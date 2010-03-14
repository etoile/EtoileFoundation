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

#ifndef GNUSTEP	
#import <objc/objc-runtime.h>
#else
#import <GNUstepBase/GSObjCRuntime.h>
#import <objc/Protocol.h>
#endif 

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

static void loadBundle(UKRunner *runner, NSString *cwd, NSString *bundlePath)
{
	bundlePath = [bundlePath stringByExpandingTildeInPath];
	if ( ![bundlePath isAbsolutePath]) {
		bundlePath = [cwd stringByAppendingPathComponent:bundlePath];
		bundlePath = [bundlePath stringByStandardizingPath];
	}
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	//NSLog (@"bundle path: %@", bundlePath);

	printf("looking for bundle at path: %s\n", [bundlePath UTF8String]);
	// make sure bundle exists and is loaded

    NSBundle *testBundle = [NSBundle bundleWithPath:bundlePath];
	if (testBundle == nil) {
		// XXX i18n as well as message improvements
		printf("Test bundle %s could not be found\n", 
				[bundlePath UTF8String]);
		[pool release];
		return;
	}
	if (![testBundle load]) {
		// XXX i18n as well as message improvements
		printf("Test bundle could not be loaded\n");
		[pool release];
		return;            
	}
	[runner runTestsInBundle:testBundle];
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
    
	NSFileManager *fm = [NSFileManager defaultManager];
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    NSString *cwd = [fm currentDirectoryPath];
    //printf("ukrun starting\n");
    //printf("cwd: %s\n", [cwd UTF8String]);

    NSArray *args = [[NSProcessInfo processInfo] arguments];
    int argCount = [args count];
    
    UKRunner *runner = [[UKRunner alloc] init];
    
	int bundles = 0;
    if (argCount >= 2) 
	{
        printf("ukrun version 1.3 (GNUstep)\n"); // XXX replace with a real auto version

        // Mark Dalrymple contributed this bit about going quiet.
        
        for (int i=1 ; i < argCount ; i++)
		{
			if ([[args objectAtIndex:i] isEqualToString: @"-q"])
			{
				[[UKTestHandler handler] setQuiet: YES];
				i++;
			}
			else
			{
				NSString *bundlePath = [args objectAtIndex:i];
				loadBundle(runner, cwd, bundlePath);
				bundles++;
			}
        }
    } 
	// If no bundles are specified, then just run every bundle in this folder.
	if (bundles == 0)
	{
		NSArray *files = [fm directoryContentsAtPath:cwd];
		NSEnumerator *e = [files objectEnumerator];
		NSString *file;
		while (nil != (file = [e nextObject]))
		{
			BOOL isDir = NO;
			if ([fm fileExistsAtPath:file isDirectory:&isDir] && isDir)
			{
				int len = [file length];
				if(len > 8 && [[file substringFromIndex:(len - 6)] isEqualToString:@"bundle"])
				{
					loadBundle(runner, cwd, file);
				}
			}
		}

	}
    
        
    int testsPassed = [[UKTestHandler handler] testsPassed];
    int testsFailed = [[UKTestHandler handler] testsFailed];
    int testClasses = runner->testClassesRun;
    int testMethods = runner->testMethodsRun;
    
    [runner release];
    [pool release];
    
    // XXX i18n
    printf("Result: %i classes, %i methods, %i tests, %i failed\n", testClasses, testMethods, (testsPassed + testsFailed), testsFailed);

#ifndef GNUSTEP
    [self performGrowlNotification: testsPassed :testsFailed :testClasses :testMethods];
#endif

    if (testsFailed == 0) {
        return 0;
    } else {
        return -1;
    }

}

#ifndef GNUSTEP
+ (void) performGrowlNotification
:(int) testsPassed 
:(int) testsFailed
:(int) testClassesRun
:(int) testMethodsRun
{
    NSString *title;
    
    if (testsFailed == 0) {
        title = @"UnitKit Test Run Passed";
    } else {
        title = @"UnitKit Test Run Failed";
    }
    
    NSString *msg = [NSString stringWithFormat:
					 @"%i test classes, %i methods\n%i assertions passed, %i failed",
					 testClassesRun, testMethodsRun,  testsPassed, testsFailed];
    
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

#ifndef GNUSTEP
- (void) runTest:(SEL)testSelector onObject:(id)testObject
{
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop performSelector:testSelector 
                      target:testObject 
                    argument:nil 
                       order:0 
                       modes:[NSArray arrayWithObject:NSDefaultRunLoopMode]];
    CFRunLoopRef cfRunLoop = [runLoop getCFRunLoop];
    [runLoop runUntilDate:nil];
    while (CFRunLoopIsWaiting(cfRunLoop)) {
        [runLoop runUntilDate:nil];
    }
}
#endif

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
#ifndef GNU_RUNTIME
    BOOL isClass = testObject != nil && testObject->isa != nil && (testObject->isa->info & CLS_META);
#else
	BOOL isClass = object_is_class(testObject);
#endif
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
        /* It is instance, we instanize and release it in the loop */
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
                NSString *msg = [UKRunner localizedString:@"errExceptionOnInit"];
                NSString *excstring = [UKRunner displayStringForException:exc];
                msg = [NSString stringWithFormat:msg, 
                    NSStringFromClass(testClass), excstring];
                [[UKTestHandler handler] reportWarning:msg];
                [pool release];
                return;
           }
        } 

        @try {
            SEL testSel = NSSelectorFromString(testMethodName);
            [self runTest:testSel onObject: object];
        }
        @catch (id exc) {
            NSString *msg = [UKRunner 
                localizedString:@"errExceptionInTestMethod"];            
            NSString *excstring = [UKRunner displayStringForException:exc];
            msg = [NSString stringWithFormat:msg, NSStringFromClass(testClass),
                testMethodName, excstring];
            [[UKTestHandler handler] reportWarning:msg];
        }
        
        if (isClass == NO)
        {
            @try {
                [object release];
            }
            @catch (id exc) {
                NSString *msg = [UKRunner localizedString:@"errExceptionOnRelease"];
                NSString *excstring = [UKRunner displayStringForException:exc];
                msg = [NSString stringWithFormat:msg, 
                                  NSStringFromClass(testClass), excstring];
                [[UKTestHandler handler] reportWarning:msg];
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
            NSString *msg = [UKRunner localizedString:@"errExceptionOnInit"];
            msg = [NSString stringWithFormat:msg, NSStringFromClass(testClass), [localException name]];
            [[UKTestHandler handler] reportWarning:msg];
            [pool release];
            NS_VOIDRETURN;	
	}
        NS_ENDHANDLER
        
        NS_DURING
	{
            SEL testSel = NSSelectorFromString(testMethodName);
            [object performSelector:testSel];
	}
        NS_HANDLER
	{
            NSString *msg = [UKRunner localizedString:@"errExceptionInTestMethod"];            
            msg = [NSString stringWithFormat:msg, NSStringFromClass(testClass), testMethodName, [localException name]];
            [[UKTestHandler handler] reportWarning:msg];
            [[UKTestHandler handler] reportWarning:[localException reason]];
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
            NSString *msg = [UKRunner localizedString:@"errExceptionOnRelease"];
            msg = [NSString stringWithFormat:msg, NSStringFromClass(testClass), [localException name]];
            [[UKTestHandler handler] reportWarning:msg];
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
#ifndef GNU_RUNTIME
	if (testClass != nil)
		testMethods = UKTestMethodNamesFromClass(objc_getMetaClass(testClass->name));
    //testMethods = UKTestMethodNamesFromClass(objc_getClass(testClass));
#else
    testMethods = UKTestMethodNamesFromClass(object_get_meta_class(testClass));
#endif
    [self runTests:testMethods onObject:testClass];
    /* Test instance methods */
    testMethods = UKTestMethodNamesFromClass(testClass);
    [self runTests:testMethods onObject: [testClass alloc]];
}

- (void) runTestsInBundle:(NSBundle *)bundle
{
	// NOTE: First we must create the app object, because on Mac OS X (10.6) in 
	// UKTestClasseNamesFromBundle(), we have -bundleForClass: that invokes 
	// class_respondsToSelector() which results in +initialize being called and 
	// +[NSWindowBinder initialize] has the bad idea to use +sharedApplication. 
	// When no app object is available yet, an NSApplication instance will be 
	// created rather than the subclass instance we might want.
    [self setUpAppObjectIfNeededForBundle: bundle];

    NSArray *testClasses = UKTestClasseNamesFromBundle(bundle);
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
- (void) setUpAppObjectIfNeededForBundle: (NSBundle *)testBundle
{
	Class appClass = NSClassFromString(@"NSApplication");

	if (appClass == nil) /* AppKit not loaded */
		return;

	appClass = NSClassFromString(@"ETApplication");
	if (appClass == nil) /* EtoileUI not loaded */
		return;

	Class principalClass = [testBundle principalClass];

	/* Use NSApplication subclass if declared as the bundle principal class */
	if ([principalClass isKindOfClass: appClass])
		appClass = principalClass;

	id app = [appClass sharedApplication];

	if ([app respondsToSelector: @selector(setUp)])
	{
		[app setUp];
	}
}

@end

#ifdef GNU_RUNTIME
/**
 * Implementation of +conformsToProtocol that does not require sending a
 * message to the class.  This prevents +initialize being sent to classes that
 * are not explicitly used.
 */
BOOL conformsToProtocol(Class aClass, Protocol * aProtocol)
{
	struct objc_protocol_list* protocol_list =((struct objc_class*)aClass)->protocols;

	while(NULL != protocol_list)
	{
		for(unsigned int i=0 ; i<protocol_list->count ; i++)
		{
			if([protocol_list->list[i] conformsTo:aProtocol])
			{
				return YES;
			}
		}
		protocol_list = protocol_list->next;
	}
	if(Nil != (Class)((struct objc_class*)aClass)->super_class)
	{
		return conformsToProtocol(((struct objc_class*)aClass)->super_class, aProtocol);
	}
	return NO;
}
#endif

NSArray *UKTestClasseNamesFromBundle(NSBundle *bundle)
{        
    NSMutableArray *testClasseNames = [[NSMutableArray alloc] init];
    
#ifndef GNU_RUNTIME

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
            if (bundle == classBundle && 
                [c conformsToProtocol:@protocol(UKTest)]) {
                [testClasseNames addObject:NSStringFromClass(c)];
            }
        }
        free(classes);
    }    

#else
    
    /*
     Nicolas Roard contributed the following code to pick up test classes
     from a bundle.
     */
    
    Class c;
    void *es = NULL;
    int i = 0;
    /* We clean up memory every 20 iteration,
       otherwise, GNUstep will complain that there are too many open files.
       The number of iteration may need to be adjusted. */
    NSAutoreleasePool *x = [[NSAutoreleasePool alloc] init];
    while ((c = objc_next_class (&es)) != Nil)
    {
		i++;
        NSBundle *classBundle = [NSBundle bundleForClass: c];
        if (bundle == classBundle && 
			conformsToProtocol(c, @protocol(UKTest))) 
		{
            [testClasseNames addObject:NSStringFromClass(c)];
        }
        if (i > 20)
        {
	    DESTROY(x);
            x = [[NSAutoreleasePool alloc] init];
	    i = 0;
        }
    }
    DESTROY(x);
	
	//NSLog(@"testClasses %@", testClasseNames);

#endif
    
    [testClasseNames autorelease];
    return [testClasseNames
        sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

NSArray *UKTestMethodNamesFromClass(Class c)
{
    
    NSMutableArray *testMethods = [NSMutableArray array];
    
#ifndef GNU_RUNTIME

    /*
     I think I picked this code up originaly from some Apple sample code. But
     I could be wrong. It's landed here from all of my previous UnitKit
     iterations. Of course, it's been modified to look for methods that start
     with a test prefix.
     */
    
    void *iterator = 0;
    struct objc_method_list *mlist = class_nextMethodList(c, &iterator);
    while (mlist != NULL) {
        int i;
        for (i = 0; i < mlist->method_count; i++) {
            Method method = &(mlist->method_list[i]);
            if (method == NULL) {
                continue;
            }
            SEL sel = method->method_name;
            NSString *methodName = NSStringFromSelector(sel);
            if ([methodName hasPrefix:@"test"]) {
                [testMethods addObject:methodName];
            }
        }
        mlist = class_nextMethodList(c, &iterator);
    }  

#else

    /*
     Nicolas Roard contributed the following code to pick up test classes
     from a bundle.
     */
	 
	MethodList_t methods = c->methods;	
	while (methods != NULL) {
		int i;		
		for (i = 0; i < methods->method_count; i++) {
			Method_t method = &(methods->method_list[i]);			
			if (method == METHOD_NULL) {
				continue;
			}
			SEL sel = method->method_name;
			NSString *methodName = NSStringFromSelector(sel);
			if ([methodName hasPrefix:@"test"]) {
				[testMethods addObject:methodName];
			}
		}
		methods = methods->method_next;
	}
	
	//NSLog(@"testMethods %@", testMethods);
        
#endif

    return [testMethods 
        sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}
