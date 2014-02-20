/**
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

#import <Foundation/Foundation.h>

@interface UKRunner : NSObject
{
	@private
	NSMutableSet *setUpClasses;
	int testClassesRun;
	int testMethodsRun;
}

/** @taskunit Tool Support */

/**
 * Creates a new runner and uses it to run the tests based on the command-line
 * arguments.
 *
 * For all the test bundles collected (or provided as arguments), this method
 * uses -runTests:inBundleAtPath:currrentDirectory: to run the tests contained
 * in each one. When all test bundles have been run, -reportTestResults is
 * called to output the combined results.
 *
 * ukrun main() creates an autorelease pool, and uses this method to run the
 * tests.
 */
+ (int)runTests;
/**
 * Loads the given test bundle, and runs all its tests.
 *
 * If the bundle path is not an absolute path, the method searches the test
 * bundles to load in the given directory (the current directory, when +runTests
 * is used).
 */
- (void)runTests: (NSArray *)testClasses
  inBundleAtPath: (NSString *)bundlePath
currentDirectory: (NSString *)cwd;
/**
 * Runs all the tests in the given test bundle.
 *
 * If the bundle is nil, a principal class can still be provided in argument.
 *
 * For a valid bundle, the principal class argument is ignored.
 *
 * For test related configuration, +willRunTestSuite and +didRunTestSuite
 * are sent to the principal class (see UKPrincipalClassNotifications).
 */
- (void)runTestsInBundle: (NSBundle *)bundle
          principalClass: (Class)principalClass;
/**
 * Runs all the tests in the tested classes in the given test bundle.
 *
 * This method behaves the same than -runTestsInBundle:principalClass:.
 *
 * If testedClasses is nil, then it is the same than passing all the test
 * classes present in the bundle.
 */
- (void)runTests: (NSArray *)testedClasses
        inBundle: (NSBundle *)bundle
  principalClass: (Class)principalClass;


/** @taskunit Running Tests */


- (void)runTestsInClass: (Class)testClass;
- (void)runTests: (NSArray *)testMethods
      onInstance: (BOOL)instance
		 ofClass: (Class)testClass;


/** @taskunit Test Reporting */


/**
 * Logs a summary that reports the current run results:
 *
 * <list>
 * <item>how many test classes and test methods were executed</item>
 * <item>how many tests failed and passed</item>
 * <item>how many uncaught exceptions occurred</item>
 * </list>
 *
 * If no tests failed and no uncaught exceptions occured, returns 0 to indicate
 * success, otherwise returns -1.
 */
- (int)reportTestResults;

@end

@interface NSObject (UKPrincipalClassNotifications)
+ (void)willRunTestSuite;
+ (void)didRunTestSuite;
@end

/**
 * Returns all the test classes present in the given bundle, and sorted by name.
 *
 * To be a test class, a class (or its superclass) must conform to UKTest
 * protocol.
 */
NSArray *UKTestClasseNamesFromBundle (NSBundle *bundle);
/**
 * Returns all the test method names sorted by name, for the given class.
 *
 * All the superclass methods are collected (until the root class is reached).
 */
NSArray *UKTestMethodNamesFromClass(Class c);
