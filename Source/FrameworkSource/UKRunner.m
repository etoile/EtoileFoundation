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

// FIXME: we shouldn't need to put import for AppKit.h here (see UKRunner.h)
#import <AppKit/AppKit.h>

/* For GNUstep, but we should check if it is really needed */
#import <Foundation/NSException.h>

#ifndef GNUSTEP
	#ifdef AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER
		#define NEW_EXCEPTION_MODEL
	#endif
	#import <objc/objc-runtime.h>
#else
	#import <GNUstepBase/GSObjCRuntime.h>
#endif 


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

+ (int) runTests
{    
    /*
     We expect the following usage:
          $ ukrun [BundleName]
     
     If there are no arguments given, then we'll just execute every 
     test class found. Otherwise
     */
    
	NSApplication *app = [NSApplication sharedApplication];
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    NSString *cwd = [[NSFileManager defaultManager] currentDirectoryPath];
    //printf("ukrun starting\n");
    //printf("cwd: %s\n", [cwd UTF8String]);

    NSArray *args = [[NSProcessInfo processInfo] arguments];
    int argCount = [args count];
    
    UKRunner *runner = [[UKRunner alloc] init];
    NSBundle *testBundle;
    
    if (argCount >= 2) {
        printf("ukrun version 1.1\n"); // XXX replace with a real auto version
        int i = 1;

        // Mark Dalrymple contributed this bit about going quiet.
        
        if ([[args objectAtIndex:1] isEqualToString: @"-q"]) {
            [[UKTestHandler handler] setQuiet: YES];
            i++;
        }

        while (i < argCount) {
            NSString *bundlePath = [args objectAtIndex:i];
            NSLog (@"bundle path: %@", bundlePath);
            bundlePath = [bundlePath stringByExpandingTildeInPath];
            if ( ![bundlePath isAbsolutePath]) {
                bundlePath = [cwd stringByAppendingPathComponent:bundlePath];
                bundlePath = [bundlePath stringByStandardizingPath];
            }
        
            printf("looking for bundle at path: %s\n", [bundlePath UTF8String]);
            // make sure bundle exists and is loaded
        
            testBundle = [NSBundle bundleWithPath:bundlePath];
            if (testBundle == nil) {
                // XXX i18n as well as message improvements
                printf("Test bundle %s could not be found\n", [bundlePath UTF8String]);
                [pool release];
                return -1;
            }
            if (![testBundle load]) {
                // XXX i18n as well as message improvements
                printf("Test bundle could not be loaded\n");
                [pool release];
                return -1;            
            }
            [runner runTestsInBundle:testBundle];
            i++;
        }
    } else {
        printf("Usage: ukrun [-q] [bundlename]\n");
        [pool release];
        return -1;
    }
    
        
    int testsPassed = [[UKTestHandler handler] testsPassed];
    int testsFailed = [[UKTestHandler handler] testsFailed];
    int testClasses = runner->testClassesRun;
    int testMethods = runner->testMethodsRun;
    
    [runner release];
    [pool release];
    
    // XXX i18n
    printf("Result: %i classes, %i methods, %i tests, %i failed\n", testClasses, testMethods, (testsPassed + testsFailed), testsFailed);
    
    if (testsFailed == 0) {
        return 0;
    } else {
        return -1;
    }

}

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
 @method runTests:onClass:
 @param testMethods An array containing the list of method names to execute on the test class.
 @param testClass The class on which to perform the test methods on
 @abstract Runs a set of tests on instances of the given class
 @discussion This method takes a class and a list of methods that should be executed on it. For each method in the list, an object instance of the class will be created and the method called on it. If there is a problem with the instanation of the class, or in the release of that object instance, an error will be reported and all test execution on the class will end. If there is an error while running the test method, an error will be reported and execution will move on to the next method.
 */

- (void) runTests:(NSArray *)testMethods onClass:(Class)testClass
{
    /*
     The hairy thing about this method is catching and dealing with all of 
     the permutations of uncaught exceptions that might be heading our way. 
     */
	 
	//NSLog(@"testClass %@", testClass);
    
    NSEnumerator *e = [testMethods objectEnumerator];
    NSString *testMethodName;
    while (testMethodName = [e nextObject]) {
        testMethodsRun++;
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        id testObject;

// FIXME: old objc exceptions macro don't work inside #ifdef statements	?	
/*
#ifdef NEW_EXCEPTION_MODEL

        @try {
            testObject = [[testClass alloc] init];
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
        
        @try {
            SEL testSel = NSSelectorFromString(testMethodName);
            [self runTest:testSel onObject:testObject];
        }
        @catch (id exc) {
            NSString *msg = [UKRunner 
                localizedString:@"errExceptionInTestMethod"];            
            NSString *excstring = [UKRunner displayStringForException:exc];
            msg = [NSString stringWithFormat:msg, NSStringFromClass(testClass),
                testMethodName, excstring];
            [[UKTestHandler handler] reportWarning:msg];
        }
        
        @try {
            [testObject release];
        }
        @catch (id exc) {
            NSString *msg = [UKRunner localizedString:@"errExceptionOnRelease"];
            NSString *excstring = [UKRunner displayStringForException:exc];
            msg = [NSString stringWithFormat:msg, NSStringFromClass(testClass),
                excstring];
            [[UKTestHandler handler] reportWarning:msg];
            [pool release];
            return;
        }
*/	
//#else

        NS_DURING
		{
            testObject = [testClass alloc];
			if ([testObject respondsToSelector: @selector(initForTest)])
			{
				testObject = [testObject initForTest];
			}
			else
			{
				testObject = [testObject init];
			}
			NSLog(@"testObject %@", testObject);
		}
        NS_HANDLER
		{
            NSString *msg = [UKRunner localizedString:@"errExceptionOnInit"];
            msg = [NSString stringWithFormat:msg, NSStringFromClass(testClass), [localException name]];
            [[UKTestHandler handler] reportWarning:msg];
            [pool release];
            return;	
		}
        NS_ENDHANDLER
        
        NS_DURING
		{
            SEL testSel = NSSelectorFromString(testMethodName);
            [testObject performSelector:testSel];
		}
        NS_HANDLER
		{
            NSString *msg = [UKRunner localizedString:@"errExceptionInTestMethod"];            
            msg = [NSString stringWithFormat:msg, NSStringFromClass(testClass), testMethodName, [localException name]];
            [[UKTestHandler handler] reportWarning:msg];
			[pool release];
			return;
		}
        NS_ENDHANDLER
        
        NS_DURING
		{
            if ([testObject respondsToSelector: @selector(releaseForTest)])
			{
				[testObject releaseForTest];
			}
			else
			{
				[testObject release];
			}
		}
        NS_HANDLER
		{
            NSString *msg = [UKRunner localizedString:@"errExceptionOnRelease"];
            msg = [NSString stringWithFormat:msg, NSStringFromClass(testClass), [localException name]];
            [[UKTestHandler handler] reportWarning:msg];
            [pool release];
            return;
		}
        NS_ENDHANDLER
        
//#endif        
        
        [pool release];
    }
}

- (void) runTestsInClass:(Class)testClass
{
    testClassesRun++;
    NSArray *testMethods = UKTestMethodNamesFromClass(testClass);
    [self runTests:testMethods onClass:testClass];
}

- (void) runTestsInBundle:(NSBundle *)bundle
{
    NSArray *testClasses = UKTestClasseNamesFromBundle(bundle);
    NSEnumerator *e = [testClasses objectEnumerator];
    NSString *testClassName;
    while (testClassName = [e nextObject]) {
        [self runTestsInClass:NSClassFromString(testClassName)];
    }
}

@end

NSArray *UKTestClasseNamesFromBundle(NSBundle *bundle)
{        
    NSMutableArray *testClasseNames = [NSMutableArray array];
    
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
    while ((c = objc_next_class (&es)) != Nil)
    {
        NSBundle *classBundle = [NSBundle bundleForClass: c];
        if (bundle == classBundle && 
            [c conformsToProtocol:@protocol(UKTest)]) {
            [testClasseNames addObject:NSStringFromClass(c)];
        }
    }
	
	//NSLog(@"testClasses %@", testClasseNames);

#endif
    
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
